#include "SailfishAndroidBridge.h"

#include <QDebug>
#include <QFile>
#include <QCoreApplication>
#include <QProcess>

#include <iostream>


#include <sys/types.h>
#include <unistd.h>

// Stolen from aliendalvik-control
// https://github.com/CODeRUS/aliendalvik-control/tree/588e8f2e4012a9efd2e9b1644a521bf7809b8f5e
void appProcess(const QString &jar, const QStringList &params)
{

    qputenv("CLASSPATH", QString("/system/framework/%1").arg(jar).toUtf8());

    QString program = "/system/bin/app_process";
    QStringList arguments;
    arguments << "/system/bin" << params;

    qDebug() << "Executing" << program << arguments;

    QProcess::startDetached(program, arguments);
}

void SailfishAndroidBridge::startURIIntent(const QString& intent, const QString& intentDataURI)
{
    appProcess("am.jar", QStringList() << "com.android.commands.am.Am" << "start" << "-a" << intent << "-d" << intentDataURI);
}

void SailfishAndroidBridge::initBridge()
{

    int croot = ::chroot("/opt/alien");
    std::cout << croot << std::endl;
    ::chdir("/");

       qputenv("LD_LIBRARY_PATH", "/system/vendor/lib:/system/lib:/vendor/lib:/system_jolla/lib:");
       qputenv("SYSTEM_USER_LANG", "C");

       qputenv("ANDROID_ROOT", "/system");
       qputenv("ANDROID_DATA", "/data");

       QFile init("/system/script/start_alien.sh");
       if (init.open(QIODevice::ReadOnly | QIODevice::Text)) {
           QTextStream in(&init);
           while (!in.atEnd()) {
               QString line = in.readLine();
               if (line.startsWith("export BOOTCLASSPATH=")) {
                   line=line.mid(21).replace("$FRAMEWORK", "/system/framework");
                   qputenv("BOOTCLASSPATH", line.toUtf8());
                   break;
               }
           }
       }
       else {
           return;
       }

       QFile envsetup("/system/script/platform_envsetup.sh");
       if (envsetup.open(QIODevice::ReadOnly | QIODevice::Text)) {
           QTextStream in(&envsetup);
           while (!in.atEnd()) {
               QString line = in.readLine();
               if (line.startsWith("export ALIEN_ID=")) {
                   line=line.mid(16);
                   qputenv("ALIEN_ID", line.toUtf8());
                   break;
               }
           }
       }
       else {
           return;
   }
}
