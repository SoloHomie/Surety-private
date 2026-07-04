#pragma once
#include <QObject>
#include <QWindow>
#include <QSystemTrayIcon>

class SystemTray : public QObject {
    Q_OBJECT
public:
    static SystemTray *instance();
    explicit SystemTray(QObject *parent = nullptr);
    ~SystemTray() override;

    Q_INVOKABLE void init(QWindow *window);
    Q_INVOKABLE void showMessage(const QString &title, const QString &msg);
    Q_INVOKABLE void setTrayVisible(bool visible);
    Q_INVOKABLE void forceQuit();

signals:
    void trayActivated();

private:
    QSystemTrayIcon *_tray = nullptr;
    QWindow *_window = nullptr;
};
