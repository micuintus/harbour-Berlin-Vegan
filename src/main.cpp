/**
 *
 *  This file is part of the Berlin-Vegan guide,
 *  Copyright 2015-2018 (c) by micu <micuintus.de> (post@micuintus.de).
 *  Copyright 2017-2018 (c) by jmastr <veggi.es> (julian@veggi.es).
 *
 *      <https://github.com/micuintus/harbour-Berlin-vegan>.
 *
 *  The Berlin-Vegan guide is Free Software:
 *  you can redistribute it and/or modify it under the terms of the
 *  GNU General Public License as published by the Free Software Foundation,
 *  either version 2 of the License, or (at your option) any later version.
 *
 *  Berlin-Vegan is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with The Berlin Vegan Guide.
 *
 *  If not, see <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.
 *
**/

#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QPermissions>
#include <QFileInfo>
#include <QObject>
#include <QScreen>
#include <QQmlContext>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#include <QJniEnvironment>
#include <QtCore/qnativeinterface.h>
#endif

#ifdef BV_HAS_MAPLIBRE
// Declared rather than included. The Felgo SDK bundles its own QMapLibre 3
// framework and its -F path wins over ours no matter the ordering, so
// <QMapLibre/Utils> resolves to a header without this function. The enum
// values are fixed by QMapLibre to match QSGRendererInterface.
namespace QMapLibre {
enum RendererType { OpenGL = 3, Vulkan = 5, Metal = 6 };
RendererType supportedRendererType();
}
#endif

namespace {
// MapLibre renders beside Qt on the same device, so the scene graph has to run
// the API the map was built for. Asking beats hardcoding: the answer is a
// compile-time choice inside QMapLibre (Metal on Apple, Vulkan or GL
// elsewhere), and pinning OpenGL here drags the whole app onto a deprecated
// backend for the sake of one item.
void selectGraphicsApi()
{
#ifdef BV_HAS_MAPLIBRE
    const auto renderer = QMapLibre::supportedRendererType();
    QQuickWindow::setGraphicsApi(static_cast<QSGRendererInterface::GraphicsApi>(renderer));
#else
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);
#endif
}
}

namespace {
#ifdef Q_OS_ANDROID
// Android's WindowInsets via JNI (public Qt API): the only reliable source
// under edge-to-edge, where Qt's availableGeometry() equals geometry().
// Returns device-independent px (status/nav bar heights); 0 on failure.
static qreal bvAndroidInsetTop()
{
    using namespace QNativeInterface;
    auto check = [](const char *step, bool ok) {
        QJniEnvironment env;
        const bool ex = env->ExceptionCheck();
        if (ex)
            env->ExceptionClear();
        if (!ok || ex)
            qInfo("BVApp: insets %s failed (ok=%d exc=%d)", step, ok, ex);
        return ok && !ex;
    };
    QJniObject activity = QAndroidApplication::context();
    if (!check("context", activity.isValid()))
        return 0;
    const jint sdk = QJniObject::getStaticField<jint>("android/os/Build$VERSION", "SDK_INT");
    qInfo("BVApp: insets sdk=%d", sdk);
    if (sdk < 30)
        return 0;
    QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
    if (!check("window", window.isValid()))
        return 0;
    QJniObject decor = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
    if (!check("decor", decor.isValid()))
        return 0;
    QJniObject insets = decor.callObjectMethod("getRootWindowInsets", "()Landroid/view/WindowInsets;");
    if (!check("insets", insets.isValid()))
        return 0;
    const jint type = QJniObject::callStaticMethod<jint>("android/view/WindowInsets$Type", "statusBars", "()I");
    QJniObject rect = insets.callObjectMethod("getInsets", "(I)Landroid/graphics/Insets;", type);
    if (!check("rect", rect.isValid()))
        return 0;
    QJniObject res = activity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
    QJniObject metrics = res.callObjectMethod("getDisplayMetrics", "()Landroid/util/DisplayMetrics;");
    const jfloat density = metrics.getField<jfloat>("density");
    const jint top = rect.getField<jint>("top");
    qInfo("BVApp: insets top_px=%d density=%g", top, density);
    return density > 0 ? top / density : 0;
}
#endif
// Window system insets (status bar, notch, gesture bar) as QML-readable values.
// Qt 6.8 exposes them only through the QPA layer, so derive them from the
// public pair: availableGeometry() excludes system areas, geometry() does not.
// The app is portrait-locked, so margins are effectively static after show.
class BvWindowInsets : public QObject {
    Q_OBJECT
    Q_PROPERTY(qreal top READ top NOTIFY insetsChanged)
    Q_PROPERTY(qreal left READ left NOTIFY insetsChanged)
    Q_PROPERTY(qreal right READ right NOTIFY insetsChanged)
    Q_PROPERTY(qreal bottom READ bottom NOTIFY insetsChanged)
public:
    explicit BvWindowInsets(QObject *parent = nullptr) : QObject(parent)
    {
        if (QScreen *s = QGuiApplication::primaryScreen()) {
            connect(s, &QScreen::availableGeometryChanged,
                    this, &BvWindowInsets::refresh);
        }
        refresh();
    }
    qreal top() const { return m_top; }
    qreal left() const { return m_left; }
    qreal right() const { return m_right; }
    qreal bottom() const { return m_bottom; }
    void refresh()
    {
        if (QScreen *s = QGuiApplication::primaryScreen()) {
            const QRect geo = s->geometry();
            const QRect avail = s->availableGeometry();
            qreal top = avail.top() - geo.top();
#ifdef Q_OS_ANDROID
            // Edge-to-edge collapses the pair; use WindowInsets instead.
            if (const qreal jniTop = bvAndroidInsetTop(); jniTop > 0)
                top = jniTop;
#endif
            set(top,
                avail.left() - geo.left(),
                geo.right() - avail.right(),
                geo.bottom() - avail.bottom());
        }
    }
signals:
    void insetsChanged();
private:
    void set(qreal t, qreal l, qreal r, qreal b)
    {
        if (t == m_top && l == m_left && r == m_right && b == m_bottom)
            return;
        m_top = t;
        m_left = l;
        m_right = r;
        m_bottom = b;
        qInfo("BVApp: window insets t=%g l=%g r=%g b=%g", t, l, r, b);
        emit insetsChanged();
    }
    qreal m_top = 0, m_left = 0, m_right = 0, m_bottom = 0;
};
}

#ifdef Q_OS_SAILFISH
#include <sailfishapp.h>
#include <QGuiApplication>
#elif defined(BV_KIRIGAMI)
#include <QTranslator>
#include <QLocale>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>
#include <QDir>
#else
#include <QTranslator>
#include <QLocale>
#include <QGuiApplication>
#include <FelgoApplication>
#include <QQmlApplicationEngine>
#endif

#ifdef BV_HARNESS
#include "RenderHarness.h"
#endif

int main(int argc, char *argv[])
{
    auto const mainQMLFile = QString("qml/harbour-berlin-vegan.qml");

#ifdef BV_HARNESS
    bv::installHarnessMessageHandler();
#endif

#ifdef Q_OS_SAILFISH
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    app->setApplicationVersion(APP_VERSION);
    view->setSource(mainQMLFile);
    view->show();
#elif defined(BV_KIRIGAMI)
    selectGraphicsApi();

    // Force Fusion style so QQC2 controls support custom background/contentItem.
    // The macOS native style blocks customization; Fusion is always available in Qt.
    // The env var is read at plugin init time; setStyle alone proved insufficient
    // on Android, where the default Material style made Kirigami's Theme sync
    // fail (styles/Material/Theme.qml fatal to item rendering).
    qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    // Kirigami prepends "Material" to its theme style-chain on Android,
    // which selects the Material theme sync that breaks control rendering.
    // Force the chain to the actual QuickControls style instead.
    qputenv("KIRIGAMI_FORCE_STYLE", "1");

    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
    app->setApplicationName(QStringLiteral("Berlin-Vegan"));
    app->setOrganizationName(QStringLiteral("berlin-vegan.org"));
    app->setApplicationVersion(QStringLiteral(APP_VERSION));
    qInfo("BVApp: QuickControls2 style = %s", qPrintable(QQuickStyle::name()));

#ifdef Q_OS_ANDROID
    // Kirigami's PlatformPluginFactory looks for
    // libplugins_kf6_kirigami_platform_<style>.so under
    // QCoreApplication::libraryPaths(); Android does not list the app's
    // native lib dir there by default.
    QCoreApplication::addLibraryPath(QCoreApplication::applicationDirPath());
#endif

    // -------------------------------------------------------------------------
    // Icon theme setup — Kirigami.Icon needs Breeze to resolve symbolic icon
    // names such as starred-symbolic, non-starred-symbolic, go-home-symbolic.
    // On Linux they are usually system-wide; on macOS they are installed by
    // Homebrew into /opt/homebrew/share/icons (Apple Silicon) or
    // /usr/local/share/icons (Intel).  We add all plausible paths so QIcon /
    // KIconLoader finds Breeze regardless of how the system is configured.
    // -------------------------------------------------------------------------
    {
        QStringList searchPaths = QIcon::themeSearchPaths();
        for (const QString &candidate : {
                 // macOS – Homebrew Apple Silicon / Intel
                 QStringLiteral("/opt/homebrew/share/icons"),
                 QStringLiteral("/usr/local/share/icons"),
                 // Linux/BSD system-wide
                 QStringLiteral("/usr/share/icons"),
                 QStringLiteral("/usr/local/share/icons"),
                 // Bundled inside the .app (populated by CMake post-build step)
                 QCoreApplication::applicationDirPath() + QStringLiteral("/../Resources/icons"),
             }) {
            if (!searchPaths.contains(candidate) && QDir(candidate).exists())
                searchPaths << candidate;
        }
        QIcon::setThemeSearchPaths(searchPaths);

        // Prefer Breeze (KDE symbolic icons); hicolor is the Qt built-in fallback.
        const QString currentTheme = QIcon::themeName();
        if (currentTheme.isEmpty() || currentTheme == QStringLiteral("hicolor"))
            QIcon::setThemeName(QStringLiteral("breeze"));
    }

    // Request location permission (required on macOS, iOS, Android)
    QLocationPermission locationPermission;
    locationPermission.setAccuracy(QLocationPermission::Precise);
    if (app->checkPermission(locationPermission) == Qt::PermissionStatus::Undetermined) {
        app->requestPermission(locationPermission, [](const QPermission &) {});
    }

    QTranslator translator;
    if (translator.load(QLocale(), QLatin1String("harbour-berlin-vegan"),
                        QLatin1String("-"), QLatin1String(":/translations"))) {
        app->installTranslator(&translator);
    }

    QQmlApplicationEngine qmlEngine;
    qmlEngine.addImportPath(QStringLiteral("qrc:/"));
    // KF6 Kirigami QML modules — check standard locations and KF6_QML_IMPORT_PATH env
    qmlEngine.addImportPath(QLibraryInfo::path(QLibraryInfo::QmlImportsPath));
    qmlEngine.addImportPath(QCoreApplication::applicationDirPath() + QStringLiteral("/../lib/qml"));
    const QString kf6Env = qEnvironmentVariable("KF6_QML_IMPORT_PATH");
    if (!kf6Env.isEmpty())
        qmlEngine.addImportPath(kf6Env);
    // System insets for the QML safe-area handling (top = status bar etc.).
    auto insets = new BvWindowInsets(app.data());
    qmlEngine.rootContext()->setContextProperty(QStringLiteral("bvWindowInsets"), insets);
    qmlEngine.load(QUrl(QStringLiteral("qrc:/qml/harbour-berlin-vegan.qml")));
    // The window exists only after load; re-read so post-show insets apply.
    insets->refresh();
    QObject::connect(app.data(), &QGuiApplication::focusWindowChanged,
                     insets, &BvWindowInsets::refresh);
#else
    selectGraphicsApi();
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));

    // Request location permission (required on macOS, iOS, Android)
    QLocationPermission locationPermission;
    locationPermission.setAccuracy(QLocationPermission::Precise);
    if (app->checkPermission(locationPermission) == Qt::PermissionStatus::Undetermined) {
        app->requestPermission(locationPermission, [](const QPermission &) {});
    }

    QTranslator translator;
    if (translator.load(QLocale(), QLatin1String("harbour-berlin-vegan"),
                        QLatin1String("-"), QLatin1String(":/translations"))) {
        app->installTranslator(&translator);
    }

    FelgoApplication felgoApp;
    felgoApp.setPreservePlatformFonts(true);

    QQmlApplicationEngine qmlEngine;
    felgoApp.initialize(&qmlEngine);
    qmlEngine.addImportPath(QStringLiteral("qrc:/"));
    felgoApp.setMainQmlFileName(mainQMLFile);

    // Felgo resolves the main QML against the bundle's Resources directory,
    // which a qt_add_qml_module build never populates, so an installed .app
    // cannot start. The module already embeds the file; prefer that.
    QUrl mainQmlUrl(felgoApp.mainQmlFileName());
    const bool resolvesOnDisk = mainQmlUrl.isLocalFile()
                                && QFileInfo::exists(mainQmlUrl.toLocalFile());
    if (!resolvesOnDisk)
        mainQmlUrl = QUrl(QStringLiteral("qrc:/") + mainQMLFile);
    qmlEngine.load(mainQmlUrl);
#endif

#if defined(BV_HARNESS) && !defined(Q_OS_SAILFISH)
    bv::runRenderHarness(qmlEngine, *app);
#endif

    return app->exec();
}

#include "main.moc"
