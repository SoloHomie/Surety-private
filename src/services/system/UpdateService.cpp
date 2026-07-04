#include "UpdateService.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <iostream>
#define NOMINMAX
#include <windows.h>

UpdateService* UpdateService::instance() { static UpdateService s; return &s; }
UpdateService::UpdateService(QObject *p) : QObject(p) {}

void UpdateService::openGitHub(const QString &url) {
    QProcess::startDetached("cmd", {"/c", "start", url});
}

void UpdateService::downloadAndInstall(const QString &url, const QString &version) {
    if (m_downloading) return;
    m_downloading = true;
    m_progress = 0;
    if (onDownloadingChanged) onDownloadingChanged();
    if (onProgressChanged) onProgressChanged();

    QString tmpDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    QString zipPath = tmpDir + "/Surety-" + version + ".zip";

    QUrl qurl(url);
    QNetworkRequest req(qurl);
    QNetworkReply *reply = m_nam.get(req);

    connect(reply, &QNetworkReply::downloadProgress, this,
        [this](qint64 rx, qint64 total) {
            if (total > 0) {
                m_progress = (int)(rx * 100 / total);
                if (onProgressChanged) onProgressChanged();
            }
        });

    connect(reply, &QNetworkReply::finished, this, [this, reply, zipPath, version]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            m_downloading = false;
            if (onDownloadingChanged) onDownloadingChanged();
            if (onErrorOccurred) onErrorOccurred("下载失败: " + reply->errorString());
            return;
        }

        QByteArray data = reply->readAll();
        QFile f(zipPath);
        if (!f.open(QIODevice::WriteOnly)) {
            m_downloading = false;
            if (onDownloadingChanged) onDownloadingChanged();
            if (onErrorOccurred) onErrorOccurred("无法写入临时文件");
            return;
        }
        f.write(data);
        f.close();

        QString extractDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                             + "/Surety-" + version;
        QDir().mkpath(extractDir);

        QProcess ps;
        ps.start("powershell", {"-NoProfile", "-Command",
            "Expand-Archive -Path '" + zipPath + "' -DestinationPath '" + extractDir + "' -Force"});
        ps.waitForFinished(60000);

        QString appDir = QCoreApplication::applicationDirPath();
        QString newExe = extractDir + "/Surety.exe";
        QString oldExe = QCoreApplication::applicationFilePath();

        if (!QFile::exists(newExe)) {
            QDir d(extractDir);
            auto entries = d.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
            for (auto &e : entries) {
                if (e.isDir()) {
                    QString candidate = e.absoluteFilePath() + "/Surety.exe";
                    if (QFile::exists(candidate)) { newExe = candidate; break; }
                }
            }
        }

        if (!QFile::exists(newExe)) {
            m_downloading = false;
            if (onDownloadingChanged) onDownloadingChanged();
            if (onErrorOccurred) onErrorOccurred("压缩包中未找到 Surety.exe");
            return;
        }

        if (!writeUpdateBat(appDir, zipPath, newExe, oldExe)) {
            m_downloading = false;
            if (onDownloadingChanged) onDownloadingChanged();
            if (onErrorOccurred) onErrorOccurred("无法创建更新脚本");
            return;
        }

        if (onInstallReady) onInstallReady();
    });
}

bool UpdateService::writeUpdateBat(const QString &exeDir, const QString &zipPath,
                                    const QString &newExe, const QString &oldExe) {
    QString batPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                      + "/surety_update.bat";
    QFile bat(batPath);
    if (!bat.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;

    QString script;
    script += "@echo off\r\n";
    script += "if not defined IS_MINIMIZED set IS_MINIMIZED=1 & start \"\" /min cmd /c \"%~f0\" %* & exit\r\n";
    script += "echo Updating Surety...\r\n";
    script += ":wait\r\n";
    script += "tasklist /FI \"IMAGENAME eq Surety.exe\" 2>NUL | find /I /N \"Surety.exe\" >NUL\r\n";
    script += "if %ERRORLEVEL% equ 0 (\r\n";
    script += "  timeout /t 1 /nobreak >NUL\r\n";
    script += "  goto wait\r\n";
    script += ")\r\n";

    QString newExeWin = QString(newExe).replace('/', '\\');
    QString oldExeWin = QString(oldExe).replace('/', '\\');
    QString zipPathWin = QString(zipPath).replace('/', '\\');
    QString extractDirWin = QString(QFileInfo(newExe).absolutePath()).replace('/', '\\');
    script += "move /Y \"" + newExeWin + "\" \"" + oldExeWin + "\"\r\n";
    script += "if %ERRORLEVEL% equ 0 (\r\n";
    script += "  start \"\" \"" + oldExeWin + "\"\r\n";
    script += ")\r\n";
    script += "del /Q \"" + zipPathWin + "\" 2>NUL\r\n";
    script += "rmdir /S /Q \"" + extractDirWin + "\" 2>NUL\r\n";
    script += "del \"%~f0\"\r\n";

    bat.write(script.toUtf8());
    bat.close();

    QProcess proc;
    proc.setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *args) {
        args->flags |= CREATE_NO_WINDOW;
        args->startupInfo->dwFlags |= STARTF_USESHOWWINDOW;
        args->startupInfo->wShowWindow = SW_HIDE;
    });
    proc.startDetached("cmd", {"/c", batPath});
    return true;
}
