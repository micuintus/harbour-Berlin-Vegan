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

#ifdef Q_OS_SAILFISH
#include <sailfishapp.h>
#include <QGuiApplication>
#elif defined(BV_KIRIGAMI)
#include <QTranslator>
#include <QLocale>
#include <QApplication>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>
#include <QDir>
#else
#include <QTranslator>
#include <QLocale>
#include <QApplication>
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
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);

    // Force Fusion style so QQC2 controls support custom background/contentItem.
    // The macOS native style blocks customization; Fusion is always available in Qt.
    QQuickStyle::setStyle(QStringLiteral("Fusion"));

    QScopedPointer<QApplication> app(new QApplication(argc, argv));
    app->setApplicationName(QStringLiteral("Berlin-Vegan"));
    app->setOrganizationName(QStringLiteral("berlin-vegan.org"));
    app->setApplicationVersion(QStringLiteral(APP_VERSION));

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
    qmlEngine.load(QUrl(QStringLiteral("qrc:/qml/harbour-berlin-vegan.qml")));
#else
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);
    QScopedPointer<QApplication> app(new QApplication(argc, argv));

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
