#include "SystemTray.h"
#pragma warning(disable:4996)
#include <QApplication>
#include <QMenu>
#include <QAction>
#include <QStyle>
#include <QDesktopServices>
#include <QUrl>

SystemTray *SystemTray::instance() {
    static SystemTray s;
    return &s;
}

SystemTray::SystemTray(QObject *parent) : QObject(parent) {}

SystemTray::~SystemTray() {
    if (_tray) { _tray->hide(); delete _tray; }
}

void SystemTray::init(QWindow *window) {
    _window = window;

    _tray = new QSystemTrayIcon(this);
    _tray->setIcon(QIcon(":/qml/images/surety-icon.svg"));
    _tray->setToolTip("Surety");

    auto *menu = new QMenu();
    menu->setStyleSheet(R"(
        QMenu {
            background-color: #161b22;
            border: 1px solid #30363d;
            border-radius: 10px;
            padding: 6px;
        }
        QMenu::item {
            color: #c9d1d9;
            padding: 10px 32px;
            border-radius: 6px;
            margin: 1px 4px;
            font-size: 16px;
        }
        QMenu::item:selected {
            background-color: #1c2128;
            color: #e6edf3;
        }
        QMenu::separator {
            height: 1px;
            background: #30363d;
            margin: 4px 12px;
        }
    )");

    auto *aboutAction = menu->addAction(QString::fromUtf8("关于 Surety"));
    connect(aboutAction, &QAction::triggered, this, []() {
        QDesktopServices::openUrl(QUrl("https://github.com/SoloHomie/Surety"));
    });

    auto *projectAction = menu->addAction(QString::fromUtf8("项目地址"));
    connect(projectAction, &QAction::triggered, this, []() {
        QDesktopServices::openUrl(QUrl("https://github.com/SoloHomie/Surety"));
    });

    menu->addSeparator();
    auto *quitAction = menu->addAction(QString::fromUtf8("退出 Surety"));
    quitAction->setData("danger");
    connect(quitAction, &QAction::triggered, this, &SystemTray::forceQuit);

    // 危险项红色样式
    menu->setStyleSheet(menu->styleSheet() + R"(
        QMenu::item[data="danger"] {
            color: #f85149;
        }
        QMenu::item[data="danger"]:selected {
            background-color: #3d1f1f;
            color: #ff7b72;
        }
    )");

    _tray->setContextMenu(menu);
    _tray->show();

    connect(_tray, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick)
            emit trayActivated();
    });
}

void SystemTray::setTrayVisible(bool visible) {
    if (_tray) _tray->setVisible(visible);
}

void SystemTray::forceQuit() {
    if (_tray) _tray->hide();
    QCoreApplication::exit(0);
}

void SystemTray::showMessage(const QString &title, const QString &msg) {
    if (_tray) _tray->showMessage(title, msg, QSystemTrayIcon::Information, 3000);
}
