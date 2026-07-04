#include "LanguageManager.h"
#include "UserSettings.h"
#include <QQmlEngine>
#include <QCoreApplication>
#include <QMap>

// ── 内嵌 QTranslator：直接查表，无需 .qm 文件 ──
class MapTranslator : public QTranslator {
public:
    QMap<QString,QString> map;
    QString translate(const char *ctx, const char *src, const char *disambig, int n) const override {
        Q_UNUSED(ctx); Q_UNUSED(disambig); Q_UNUSED(n);
        return map.value(QString::fromUtf8(src));
    }
};

static MapTranslator *s_translator = nullptr;

LanguageManager *LanguageManager::instance() { static LanguageManager s; return &s; }

LanguageManager::LanguageManager(QObject *parent) : QObject(parent) {
    QString saved = UserSettings::instance()->value("General/language").toString();
    m_current = saved.isEmpty() ? "zh" : saved;
    s_translator = new MapTranslator;
    QCoreApplication::installTranslator(s_translator);
    loadTranslations();
}

QString LanguageManager::languageName() const {
    return m_current == "en" ? "English" : QString::fromUtf8("简体中文");
}

void LanguageManager::loadTranslations() {
    s_translator->map.clear();
    if (m_current == "en") {
        // 英文翻译表 — 同之前 Lang.tr 的那套
        QMap<QString,QString> &en = s_translator->map;
        en["首页"]="Home"; en["主页"]="Home"; en["资产"]="Assets"; en["市场"]="Market"; en["设置"]="Settings";
        en["个人"]="Personal"; en["订阅"]="Subscribed"; en["本地"]="Local";
        en["Skill"]="Skill"; en["Script"]="Script"; en["Tool"]="Tool";
        en["Model"]="Model"; en["Workflow"]="Workflow"; en["Prompt"]="Prompt";
        en["资产名称"]="Asset Name"; en["版本号"]="Version";
        en["订阅定价"]="Subscription Pricing";
        en["输入价格"]="Price"; en["天"]="days";
        en["+ 自定义类型"]="+ Custom Type";
        en["输入自定义类型名称（回车确认）"]="Custom type name (Enter to confirm)";
        en["请输入资产相关信息..."]="Enter asset description...";
        en["保存资产"]="Save Asset"; en["创建资产"]="Create Asset";
        en["热度榜"]="Hot Ranking"; en["资产总数"]="Total Assets"; en["余额"]="Balance";
        en["上架数量"]="Listed"; en["订阅数量"]="Subscribed";
        en["待审核"]="Pending";
        en["快速管理"]="Quick Manage";
        en["次订阅"]="subs"; en["次"]="times";
        en["常规设置"]="General"; en["常规"]="General";
        en["外观"]="Appearance"; en["高级"]="Advanced";
        en["关于"]="About"; en["Beta"]="Beta";
        en["外观设置"]="Appearance"; en["高级设置"]="Advanced";
        en["主题"]="Theme"; en["字体"]="Font";
        en["暗色深空"]="Dark Space"; en["微软雅黑"]="Microsoft YaHei";
        en["网络"]="Network"; en["API 端点"]="API Endpoint";
        en["版本"]="Version"; en["可用"]="available";
        en["检查更新"]="Check Updates"; en["开发者"]="Developer";
        en["快速上架资产"]="Quick List Asset"; en["添加快捷功能"]="Add Shortcut";
        en["登录成功"]="Login Success"; en["欢迎回来"]="Welcome back";
        en["登录失败"]="Login Failed"; en["注册成功，请登录"]="Registered, please login";
        en["注册失败"]="Registration Failed"; en["发送失败"]="Send Failed";
        en["密码已重置，请登录"]="Password reset, please login";
        en["重置失败"]="Reset Failed"; en["重置成功"]="Reset OK";
        en["跳转授权中..."]="Redirecting..."; en["授权暂不可用"]="Auth unavailable";
        en["关联成功"]="Linked"; en["请填写邮箱和密码"]="Enter email and password";
        en["请输入有效邮箱"]="Invalid email"; en["两次密码不一致"]="Passwords do not match";
        en["请先创建账号密码"]="Create password first";
        en["请确认后端已启动"]="Check server is running";
        en["请重试"]="Please retry"; en["提示"]="Info";
        en["注册成功"]="Registered"; en["重置成功"]="Reset OK";
        en["第三方登录"]="Third-party Login";
        en["未命名"]="Untitled";
        en["用户名"]="Username"; en["邮箱"]="Email";
        en["状态"]="Status"; en["已登录"]="Logged in";
        en["关联第三方账号"]="Link Accounts"; en["退出登录"]="Logout";
        en["返回"]="Back"; en["已关联"]="Linked"; en["未关联"]="Unlinked";
        en["解除"]="Unlink"; en["关联"]="Link";
        en["已解除关联"]="Unlinked"; en["请先设置账户密码再解除绑定"]="Set password first before unlinking";
        en["请在浏览器中授权"]="Authorize in browser";
        en["关联第三方账号后，可使用第三方快速登录"]="Link third-party accounts for quick login";
        en["登录"]="Login"; en["登录中..."]="Logging in...";
        en["密码"]="Password"; en["邮箱地址"]="Email";
        en["保存登录信息"]="Remember me"; en["忘记密码？"]="Forgot password?";
        en["注册账号"]="Register"; en["验证码"]="Verify Code";
        en["发送验证码"]="Send Code"; en["重置密码"]="Reset Password";
        en["新密码"]="New Password"; en["确认密码"]="Confirm Password";
        en["注册"]="Register"; en["注册中..."]="Registering...";
        en["弱"]="Weak"; en["中"]="Medium"; en["强"]="Strong";
        en["请输入邮箱地址"]="Enter email"; en["请输入邮箱验证码"]="Enter code";
        en["请输入密码（6-20 位，需含字母+数字）"]="Password (6-20 chars, letters+numbers)";
        en["请再次输入密码"]="Confirm password";
        en["· 邮箱格式不正确"]="· Invalid email";
        en["· 验证码至少 4 位"]="· Code at least 4 digits";
        en["· 密码不能包含空格"]="· No spaces";
        en["· 密码长度 6-20 位"]="· 6-20 characters";
        en["· 需包含至少一个字母"]="· At least one letter";
        en["· 需包含至少一个数字"]="· At least one number";
        en["· 两次输入的密码不一致"]="· Passwords mismatch";
        en["已有账号？"]="Have an account?"; en["还没有账号？"]="No account?";
        en["去注册"]="Register"; en["注册即表示同意"]="By registering you agree to";
        en["服务条款"]="Terms"; en["和"]="and"; en["隐私政策"]="Privacy";
        en["返回登录"]="Back"; en["重置中..."]="Resetting...";
        en["请输入您的邮箱，获取验证码后即可在本页面重置密码。"]="Enter email to receive code.";
        en["请输入验证码"]="Enter code"; en["新密码（至少 8 位）"]="New password (min 8)";
        en["确认新密码"]="Confirm new password";
        en["请先登录"]="Please login first"; en["未登录"]="Not logged in";
        en["请先登录后再购买"]="Please login before purchasing";
        en["立即订阅"]="Subscribe Now";
        en["免费订阅"]="Free Subscribe";
        en["买断"]="Buy Once"; en["永久买断"]="Buy Once";
        en["免费获取"]="Get Free";
        en["我的资产"]="My Asset";
        en["来自热度排行榜"]="From Hot List";
        en["暂无描述"]="No description";
        en["免费"]="Free";
        en["上架"]="List"; en["下架"]="Unlist";
        en["删除"]="Delete"; en["管理"]="Manage";
        en["选择"]="Select"; en["取消"]="Cancel"; en["确定"]="OK"; en["保存"]="Save";
        en["资产已创建"]="Asset created";
        en["保存成功"]="Saved"; en["操作成功"]="Success"; en["操作失败"]="Failed";
        en["没有修改，无需保存"]="No changes";
        en["请先下架资产再修改"]="Please unlist before editing";
        en["已导入，请审核后保存"]="Imported, review before saving";
        en["存储位置已更新"]="Storage location updated";
        en["存储位置已更新，文件已迁移"]="Storage updated, files migrated";
        en["正在迁移文件..."]="Migrating files...";
        en["迁移失败，请检查磁盘空间"]="Migration failed";
        en["无法创建目录"]="Cannot create directory";
        en["订阅成功，可在「订阅」页查看"]="Subscribed! View in Subscriptions";
        en["订阅失败"]="Subscription failed";
        en["不能购买/订阅自己的资产"]="Cannot subscribe to your own asset";
        en["价格已更新，请查看最新价格"]="Price updated";
        en["商品已下架或不存在"]="Listing removed";
        en["商品信息已更新，请查看最新价格"]="Updated, please check new price";
        en["搜索商品..."]="Search...";
        en["存储"]="Storage";
        en["资产数据存储位置（更改后自动迁移已有文件）"]="Asset storage location (auto-migrate on change)";
        en["更改"]="Change";
        en["语言"]="Language";
        en["简体中文"]="Chinese";
        en["发布到市场"]="Publish";
        en["发现新版本"]="New Version Available";
        en["已发布，建议更新以获取最新功能。"]="released, update recommended.";
        en["当前版本"]="Current"; en["最新版本"]="Latest";
        en["更新内容"]="Release Notes"; en["下载方式"]="Download";
        en["稍后提醒"]="Remind Later";
        en["• 性能优化与稳定性改进\n• 修复若干已知问题"]="• Performance & stability improvements\n• Bug fixes";
        en["打开 Surety"]="Open Surety"; en["退出 Surety"]="Quit Surety";
        en["此版本必须更新，升级后才能继续使用"]="This update is required. Please upgrade to continue.";
        // Wallet
        en["钱包"]="Wallet"; en["Surety 余额"]="Surety Balance";
        en["充值"]="Recharge"; en["提现"]="Withdraw";
        en["提现功能即将上线"]="Withdrawal coming soon";
        en["交易记录"]="Transactions"; en["选择充值金额"]="Select Amount";
        en["自定义"]="Custom"; en["支付方式"]="Payment Method";
        en["支付金额"]="Amount"; en["确认充值"]="Confirm";
        en["扫一扫支付"]="Scan to Pay";
        en["模拟充值成功"]="Recharge Success";
        en["新人福利"]="Welcome Gift"; en["已领取"]="Claimed";
        en["领取成功"]="+100 Surety!";
        en["Homie为你准备的一点小礼物，以后礼物发放都在这里"]="A small gift from Homie. Future rewards will appear here.";
        en["subscribe"]="Subscribe"; en["revenue"]="Revenue"; en["claim"]="Reward";
        en["recharge"]="Recharge";
        en["微信支付"]="WeChat Pay"; en["支付宝"]="Alipay";
        en["卡密充值"]="Card";
    }
}

void LanguageManager::setLanguage(const QString &lang) {
    if (lang == m_current || (lang != "zh" && lang != "en")) return;
    m_current = lang;
    UserSettings::instance()->setValue("General/language", lang);
    UserSettings::instance()->sync();
    loadTranslations();
    if (m_engine) m_engine->retranslate();
    emit languageChanged();
}
