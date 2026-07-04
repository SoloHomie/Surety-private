#pragma warning(disable:4996)
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QUrl>
#include <QMetaObject>

#include "src/network/ApiClient.h"
#include "src/services/auth/AuthService.h"
#include "src/services/asset/AssetService.h"
#include "src/services/auth/OAuthServer.h"
#include "src/services/system/UserSettings.h"
#include "src/services/asset/AssetWatcher.h"
#include "src/services/system/SystemTray.h"
#include "src/services/system/FileHelper.h"
#include "src/services/wallet/CryptoHelper.h"
#include "src/services/wallet/SubscriptionStore.h"
#include "src/services/system/LanguageManager.h"
#include "src/model/AssetListModel.h"
#include "src/model/MarketListModel.h"

#ifdef Q_OS_WIN
#define NOMINMAX
#include <Windows.h>
#endif

int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
    SetProcessDPIAware();
#endif
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "0");
    qputenv("QT_ENABLE_HIGHDPI_SCALING",  "0");
    qputenv("QT_SCALE_FACTOR",            "1");

    QApplication app(argc, argv);
    app.setOrganizationName("Surety");
    app.setApplicationName("Surety");
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::RoundPreferFloor);

    // ── OAuth ──
    auto *oauthServer = new OAuthServer(&app);
    oauthServer->start();

    // ── 服务层 ──
    auto *api    = ApiClient::instance();
    auto *auth   = AuthService::instance();
    auto *assets = AssetService::instance();

    // ── 数据模型 ──
    auto *assetModel  = new AssetListModel(&app);
    auto *subModel    = new AssetListModel(&app);
    auto *marketModel = new MarketListModel(&app);

    // ── ApiClient 关联 model ──
    api->setAssetModel(assetModel);
    api->setSubModel(subModel);
    api->setMarketModel(marketModel);

    // ── 登录成功后自动拉取数据 + 检查更新 ──
    (QObject::connect)(api, &ApiClient::authChanged, assets, [api, assets]() {
        if (api->isLoggedIn()) {
            assets->listAssets(api->email(), "");
            assets->listSubscriptions(api->email());
            api->fetchOAuthLinks();
            api->checkUpdate();
            api->fetchListings();
            api->fetchBalance();
            api->fetchTransactions();
        }
    });

    // ── Model → 本地统计自动更新 ──
    (QObject::connect)(assetModel, &AssetListModel::countChanged, api, &ApiClient::updateLocalStats);
    (QObject::connect)(subModel,   &AssetListModel::countChanged, api, &ApiClient::updateLocalStats);

    // AssetModel 数据加载连线
    (QObject::connect)(assets, &AssetService::assetsLoaded, assetModel, [assetModel](const QString &json) {
        assetModel->loadFromJson(json, false);
    });

    // SubModel 数据加载连线
    (QObject::connect)(assets, &AssetService::subscriptionsLoaded, subModel, [subModel](const QString &json) {
        subModel->loadFromJson(json, true);
    });

    app.setWindowIcon(QIcon(":/qml/images/surety-icon.svg"));

    QQmlApplicationEngine engine;

    qmlRegisterSingletonInstance("Surety", 1, 0, "Api", api);
    qmlRegisterSingletonInstance("Surety", 1, 0, "Auth", auth);
    qmlRegisterSingletonInstance("Surety", 1, 0, "Assets", assets);
    qmlRegisterSingletonInstance("Surety", 1, 0, "Settings", UserSettings::instance());
    qmlRegisterSingletonInstance("Surety", 1, 0, "AssetWatcher", AssetWatcher::instance());

    auto *tray = SystemTray::instance();
    engine.rootContext()->setContextProperty("SystemTray", tray);
    engine.rootContext()->setContextProperty("FileHelper", FileHelper::instance());
    engine.rootContext()->setContextProperty("Crypto", CryptoHelper::instance());
    engine.rootContext()->setContextProperty("SubStore", SubscriptionStore::instance());
    LanguageManager::instance()->setEngine(&engine);
    engine.rootContext()->setContextProperty("Lang", LanguageManager::instance());

    engine.rootContext()->setContextProperty("OAuthServer", oauthServer);
    engine.rootContext()->setContextProperty("AssetModel", assetModel);
    engine.rootContext()->setContextProperty("SubModel", subModel);
    engine.rootContext()->setContextProperty("MarketModel", marketModel);

    // 启动时自动恢复登录（先加载 QML，确保 Connections 已建立）
    engine.load(QUrl(QStringLiteral("qrc:/qml/App.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    // 启动时加载公共数据（市场 + 热榜，无需登录）
    api->fetchListings();
    api->fetchHotListings(10);

    // 延迟到 QML 就绪后再拉取数据
    QMetaObject::invokeMethod(api, "tryAutoLogin", Qt::QueuedConnection);

    return app.exec();
}
