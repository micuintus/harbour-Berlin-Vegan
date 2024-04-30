/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
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

#include <QtQuick>

#include "FileIO.h"
#include "VenueSortFilterProxyModel.h"
#include "VenueModel.h"
#include "VenueHandle.h"

#ifdef Q_OS_SAILFISH
#include <sailfishapp.h>
#include <QGuiApplication>
#else

#include <QTranslator>
#include <QLocale>
#include <QApplication>
#include <FelgoApplication>
#include <QQmlApplicationEngine>
#endif

#include <QtQml/qqmlextensionplugin.h>
Q_IMPORT_QML_PLUGIN(Sailfish_SilicaPlugin);
Q_IMPORT_QML_PLUGIN(BerlinVegan_components_platformPlugin);
Q_IMPORT_QML_PLUGIN(BerlinVegan_components_genericPlugin);

int main(int argc, char *argv[])
{
    qmlRegisterType<VenueModel>("harbour.berlin.vegan", 1, 0, "VenueModel");
    qmlRegisterType<VenueSortFilterProxyModel>("harbour.berlin.vegan", 1, 0, "VenueSortFilterProxyModel");
    qmlRegisterUncreatableType<VenueHandle>("harbour.berlin.vegan", 1, 0, "VenueHandle", "VenueHandle is not createable from QML");
    auto const mainQMLFile = QString("qml/harbour-berlin-vegan.qml");

#ifdef Q_OS_SAILFISH
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    auto& qmlEngine = *(view->engine());
#else
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QScopedPointer<QApplication> app(new QApplication(argc, argv));

    // Load translations
    QTranslator translator;
    // Look up e.g. :/translations/harbour-berlin-vegan-de.qm
    if (translator.load(QLocale(), QLatin1String("harbour-berlin-vegan"), QLatin1String("-"), QLatin1String(":/translations"))) {
        app->installTranslator(&translator);
        qInfo() << "Translations loaded";
    } else {
        qInfo() << "Could not load translation";
    }

    FelgoApplication felgoApp;

    // Use platform-specific fonts instead of Felgo's default font
    felgoApp.setPreservePlatformFonts(true);

    QQmlApplicationEngine qmlEngine;
#endif

    qmlEngine.addImportPath(QStringLiteral("qrc:/imports/"));
    qmlEngine.addImportPath(QStringLiteral("qrc:/"));
    FileIO fileIO;

#ifdef Q_OS_SAILFISH
    app->setApplicationVersion(APP_VERSION);
    view->setSource(mainQMLFile);
    view->show();
    view->rootContext()->setContextProperty("FileIO", &fileIO);
#else
    felgoApp.initialize(&qmlEngine);
    felgoApp.setMainQmlFileName(mainQMLFile);
    qmlEngine.load(QUrl(felgoApp.mainQmlFileName()));
    qmlEngine.rootContext()->setContextProperty("FileIO", &fileIO);
#endif
    return app->exec();
}
