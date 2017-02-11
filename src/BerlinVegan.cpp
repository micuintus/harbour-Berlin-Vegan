/**
 *
 *  This file is part of the Berlin-Vegan guide (SailfishOS app version),
 *  Copyright 2015-2016 (c) by micu <micuintus.de> (micuintus@gmx.de).
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

#include <3rdparty/Cutehacks/gel/gel.h>
#ifdef Q_OS_SAILFISH
#include <sailfishapp.h>
#include <QGuiApplication>
#else
#include <QApplication>
#include <VPApplication>

#include <QQmlApplicationEngine>
#endif

namespace com { namespace cutehacks { namespace gel {

static inline void registerCutehacksgel()
{
    qmlRegisterType<JsonListModel>("harbour.berlin.vegan.gel", 1, 0, "JsonListModel");
    qmlRegisterType<Collection>("harbour.berlin.vegan.gel", 1, 0, "Collection");

}

} } }

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    com::cutehacks::gel::registerCutehacksgel();

#ifdef Q_OS_SAILFISH
    SailfishApp::application(argc, argv)->setApplicationVersion(APP_VERSION);
    return SailfishApp::main(argc, argv);
#else
    QApplication app(argc, argv);
    VPApplication vplay;

    // Use platform-specific fonts instead of V-Play's default font
    vplay.setPreservePlatformFonts(true);

    QQmlApplicationEngine engine;
    vplay.initialize(&engine);

    // use this during development
    // for PUBLISHING, use the entry point below
    vplay.setMainQmlFileName(QStringLiteral("qml/harbour-berlin-vegan.qml"));

    // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
    // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
    // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
    // also see the .pro file for more details
    //vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/harbour-berlin-vegan.qml"));

    engine.load(QUrl(vplay.mainQmlFileName()));

    return app.exec();
#endif
}



