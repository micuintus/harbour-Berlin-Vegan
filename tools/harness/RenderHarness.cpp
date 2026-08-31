#include "RenderHarness.h"

#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkProxy>
#include <QQmlApplicationEngine>
#include <QQmlListReference>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QTimer>
#include <QVariant>

#include <functional>
#include <memory>
#include <vector>

namespace {

struct Message
{
    QtMsgType type;
    QString text;
};

std::vector<Message> g_messages;  // read by the settle poll to detect diagnostic quiescence
QtMessageHandler g_previousHandler = nullptr;

void recordingHandler(QtMsgType type, const QMessageLogContext& ctx, const QString& text)
{
    g_messages.push_back({type, text});
    if (g_previousHandler)
        g_previousHandler(type, ctx, text);
}

QString typeName(const QObject* object)
{
    QString name = QString::fromUtf8(object->metaObject()->className());
    // QML-declared types get a _QMLTYPE_nn suffix whose number changes between
    // runs; strip it so tree dumps are diffable.
    const int marker = name.indexOf(QStringLiteral("_QML"));
    return marker < 0 ? name : name.left(marker);
}

// Text-bearing properties differ per control family; probe the usual suspects.
QString visibleText(const QObject* object)
{
    for (const char* property : {"text", "title", "label", "value", "placeholderText"}) {
        const QVariant variant = object->property(property);
        if (variant.metaType().id() == QMetaType::QString) {
            const QString string = variant.toString();
            if (!string.isEmpty())
                return string;
        }
    }
    return {};
}

QJsonObject dumpItem(QQuickItem* item, int depth, QJsonArray& defects)
{
    QJsonObject node;
    node[QStringLiteral("type")] = typeName(item);
    if (!item->objectName().isEmpty())
        node[QStringLiteral("name")] = item->objectName();

    const QString text = visibleText(item);
    if (!text.isEmpty())
        node[QStringLiteral("text")] = text;

    const QPointF scenePos = item->mapToScene(QPointF(0, 0));
    node[QStringLiteral("x")] = qRound(scenePos.x());
    node[QStringLiteral("y")] = qRound(scenePos.y());
    node[QStringLiteral("w")] = qRound(item->width());
    node[QStringLiteral("h")] = qRound(item->height());
    node[QStringLiteral("visible")] = item->isVisible();
    node[QStringLiteral("opacity")] = item->opacity();

    if (item->isVisible() && item->opacity() > 0.01) {
        const auto flag = [&](const char* kind) {
            QJsonObject defect;
            defect[QStringLiteral("kind")] = QString::fromUtf8(kind);
            defect[QStringLiteral("type")] = typeName(item);
            if (!text.isEmpty())
                defect[QStringLiteral("text")] = text.left(60);
            defects.append(defect);
        };

        const qreal implicitWidth = item->implicitWidth();
        const qreal implicitHeight = item->implicitHeight();

        if (!text.isEmpty() && implicitWidth > item->width() + 0.5) {
            // Elide or wrap is a deliberate answer to overflow; an unset elide
            // mode on an overflowing label is not. elide == 0 is ElideNone.
            const QVariant elide = item->property("elide");
            const QVariant wrapMode = item->property("wrapMode");
            const bool handled = (elide.isValid() && elide.toInt() != 0)
                                 || (wrapMode.isValid() && wrapMode.toInt() != 0);
            if (!handled)
                flag("text-overflow");
        }
        // Only leaves can be clipped in a way we can attribute; a page or
        // flickable whose implicitHeight exceeds its height is just scrollable.
        if (implicitHeight > item->height() + 0.5 && !text.isEmpty()
            && item->childItems().isEmpty())
            flag("vertical-clip");
        if ((item->width() <= 0 || item->height() <= 0) && !text.isEmpty())
            flag("zero-size-with-text");
    }

    QJsonArray children;
    if (depth < 40) {
        const auto childItems = item->childItems();
        for (QQuickItem* child : childItems)
            children.append(dumpItem(child, depth + 1, defects));
    }
    if (!children.isEmpty())
        node[QStringLiteral("children")] = children;

    return node;
}

int countNodes(const QJsonObject& node)
{
    int total = 1;
    const QJsonArray children = node.value(QStringLiteral("children")).toArray();
    for (const QJsonValue& child : children)
        total += countNodes(child.toObject());
    return total;
}

QJsonObject snapshot(QObject* root, int* nodeCount)
{
    QJsonArray defects;
    QJsonObject tree;
    if (auto* window = qobject_cast<QQuickWindow*>(root))
        if (auto* content = window->contentItem())
            tree = dumpItem(content, 0, defects);
    if (nodeCount)
        *nodeCount = countNodes(tree);

    QJsonObject document;
    document[QStringLiteral("tree")] = tree;
    document[QStringLiteral("defects")] = defects;
    return document;
}

// Felgo drives navigation through Navigation::currentIndex rather than a list
// of triggerable actions, so the two platform layers need different hooks.
QObject* findNavigation(QObject* root)
{
    const QString name = QString::fromUtf8(root->metaObject()->className());
    if (name.contains(QStringLiteral("Navigation"))
        && root->metaObject()->indexOfProperty("currentIndex") >= 0)
        return root;
    const auto children = root->children();
    for (QObject* child : children)
        if (QObject* found = findNavigation(child))
            return found;
    return nullptr;
}

// Returns false when no navigation mechanism could be driven at all.
bool activatePage(QObject* root, int pageIndex)
{
    const QVariant drawerVariant = QQmlProperty::read(root, QStringLiteral("globalDrawer"));
    if (QObject* drawer = drawerVariant.value<QObject*>()) {
        // Kirigami: actions is a QQmlListProperty, so it needs a list reference.
        QQmlListReference actions(drawer, "actions");
        if (actions.isValid() && pageIndex < actions.count() && actions.at(pageIndex))
            return QMetaObject::invokeMethod(actions.at(pageIndex), "trigger");
    }
    if (QObject* navigation = findNavigation(root)) {
        navigation->setProperty("currentIndex", pageIndex);
        return navigation->property("currentIndex").toInt() == pageIndex;
    }
    return false;
}

QJsonArray dumpMessages()
{
    QJsonArray array;
    for (const Message& message : g_messages) {
        if (message.type != QtWarningMsg && message.type != QtCriticalMsg
            && message.type != QtFatalMsg)
            continue;
        QJsonObject entry;
        entry[QStringLiteral("type")] = message.type == QtWarningMsg
                                        ? QStringLiteral("warning")
                                        : QStringLiteral("error");
        entry[QStringLiteral("text")] = message.text;
        array.append(entry);
    }
    return array;
}

} // namespace

namespace bv {

void installHarnessMessageHandler()
{
    g_previousHandler = qInstallMessageHandler(recordingHandler);

    // Determinism: the app is network-first (berlin-vegan.de, Overpass,
    // Nominatim) with a disk cache behind it. Redirect every standard path to
    // the throwaway test tree so no cache is found, and point the proxy at a
    // closed local port so every request fails immediately. Both loaders then
    // land on their bundled JSON, which is the only fixture that cannot drift.
    QStandardPaths::setTestModeEnabled(true);
    QNetworkProxy::setApplicationProxy(
        QNetworkProxy(QNetworkProxy::HttpProxy, QStringLiteral("127.0.0.1"), 9));
}

void runRenderHarness(QQmlApplicationEngine& engine, QGuiApplication& app)
{
    const QString outDir = qEnvironmentVariable("BV_HARNESS_OUT",
                                                QStringLiteral("harness-out"));
    QDir().mkpath(outDir);

    if (engine.rootObjects().isEmpty()) {
        qCritical("harness: QML root failed to load");
        QTimer::singleShot(0, &app, []{ QCoreApplication::exit(3); });
        return;
    }

    QObject* root = engine.rootObjects().first();
    auto* window = qobject_cast<QQuickWindow*>(root);
    if (!window) {
        qCritical("harness: root object is not a QQuickWindow");
        QTimer::singleShot(0, &app, []{ QCoreApplication::exit(4); });
        return;
    }

    // A fixed window size makes geometry comparable across platform layers and
    // across runs; anything host-dependent would poison the diff.
    //
    // The default is a phone's *physical* pixel count, not its logical size.
    // Felgo's dp() sizes for millimetres rather than layout units, so a 420pt
    // window on a Retina host is a phone half a real one's physical width, and
    // everything appears to overflow when nothing actually would on device.
    const int width = qEnvironmentVariableIntValue("BV_HARNESS_W") > 0
                          ? qEnvironmentVariableIntValue("BV_HARNESS_W") : 840;
    const int height = qEnvironmentVariableIntValue("BV_HARNESS_H") > 0
                           ? qEnvironmentVariableIntValue("BV_HARNESS_H") : 1760;
    window->resize(width, height);
    window->show();

    // Page matrix: indices into the NavigationMenu's action list. Index 0 is
    // whatever the app starts on, so it needs no activation.
    const QStringList pages = qEnvironmentVariable("BV_HARNESS_PAGES",
                                                   QStringLiteral("0,1,2,3"))
                                  .split(QLatin1Char(','), Qt::SkipEmptyParts);

    auto* state = new QObject(&app);
    auto step = std::make_shared<int>(0);
    auto shoot = std::make_shared<std::function<void()>>();

    *shoot = [&app, window, root, outDir, pages, step, shoot, state]() {
        if (*step >= pages.size()) {
            QJsonObject summary;
            summary[QStringLiteral("messages")] = dumpMessages();
            QFile file(outDir + QStringLiteral("/messages.json"));
            if (file.open(QIODevice::WriteOnly))
                file.write(QJsonDocument(summary).toJson(QJsonDocument::Indented));
            QCoreApplication::quit();
            return;
        }

        const int pageIndex = pages.at(*step).toInt();
        const QString tag = QStringLiteral("page%1").arg(pageIndex);

        // Every page, including the first, is entered through its navigation
        // action, which clears the stack before pushing. Sampling whatever
        // startup happened to leave behind is not reproducible: on a cold run
        // an extra venue detail page rides along on top of the list.
        if (!activatePage(root, pageIndex))
            qCritical("harness: could not navigate to page %d", pageIndex);

        // Sampling on a fixed delay makes the score a race: delegate creation
        // and async load failures keep mutating the scene, so item counts and
        // warning multiplicities differ run to run. Wait until both the item
        // count and the diagnostic stream have stopped changing. Warnings must
        // be part of the condition: some pages lazily instantiate others (the
        // venue list preloads a detail page), and sampling before that happens
        // silently drops that page's warnings from the score.
        auto settle = std::make_shared<std::function<void(int, size_t, int, int)>>();
        *settle = [window, root, outDir, tag, step, shoot, settle]
                  (int previous, size_t previousMessages, int stableRounds, int tries) {
            int count = 0;
            snapshot(root, &count);
            const size_t messageCount = g_messages.size();
            const bool stable = (count == previous && messageCount == previousMessages);
            const int rounds = stable ? stableRounds + 1 : 0;

            if (rounds < 5 && tries < 60) {
                QTimer::singleShot(400, window,
                    [settle, count, messageCount, rounds, tries]() {
                    (*settle)(count, messageCount, rounds, tries + 1);
                });
                return;
            }
            if (tries >= 60)
                qWarning("harness: %s never settled (last count %d)",
                         qPrintable(tag), count);

            const QImage image = window->grabWindow();
            if (image.isNull())
                qCritical("harness: grabWindow returned a null image for %s",
                          qPrintable(tag));
            else
                image.save(outDir + QLatin1Char('/') + tag + QStringLiteral(".png"));

            QJsonObject document = snapshot(root, nullptr);
            document[QStringLiteral("page")] = tag;
            QFile file(outDir + QLatin1Char('/') + tag + QStringLiteral(".json"));
            if (file.open(QIODevice::WriteOnly))
                file.write(QJsonDocument(document).toJson(QJsonDocument::Indented));

            ++*step;
            (*shoot)();
        };
        QTimer::singleShot(600, state, [settle]() { (*settle)(-1, 0, 0, 0); });
    };

    // One initial grace period for the first data load, then everything is
    // driven by the settle poll above.
    const int settleMs = qEnvironmentVariableIntValue("BV_HARNESS_SETTLE_MS") > 0
                             ? qEnvironmentVariableIntValue("BV_HARNESS_SETTLE_MS")
                             : 6000;
    QTimer::singleShot(settleMs, state, [shoot]() { (*shoot)(); });

    // Hard stop so a hung harness cannot wedge an evolve iteration.
    QTimer::singleShot(settleMs + 30000 * (pages.size() + 1), &app, []() {
        qCritical("harness: global timeout");
        QCoreApplication::exit(5);
    });
}

} // namespace bv
