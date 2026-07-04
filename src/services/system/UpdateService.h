#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QString>
#include <functional>

class UpdateService : public QObject {
public:
    static UpdateService* instance();

    Q_INVOKABLE void downloadAndInstall(const QString &url, const QString &version);
    Q_INVOKABLE void openGitHub(const QString &url);

    bool downloading() const { return m_downloading; }
    int  progress()   const { return m_progress; }

    // Callbacks — set from QML via JS functions
    std::function<void()> onDownloadingChanged;
    std::function<void()> onProgressChanged;
    std::function<void()> onInstallReady;
    std::function<void(const QString&)> onErrorOccurred;

private:
    explicit UpdateService(QObject *p = nullptr);
    bool writeUpdateBat(const QString &exeDir, const QString &zipPath,
                        const QString &newExe, const QString &oldExe);

    QNetworkAccessManager m_nam;
    bool m_downloading = false;
    int  m_progress = 0;
};
