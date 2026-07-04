#pragma once
#include <QObject>
#include <QByteArray>
#include <QVariantMap>

// =========================================================================
//  CryptoHelper — 基于 Windows DPAPI 的资产加密
//  订阅资产以 .surety 后缀加密存储，与用户登录 session 绑定
//  即使文件被拷贝到其他机器/用户也无法解密
// =========================================================================

class CryptoHelper : public QObject {
    Q_OBJECT
public:
    static CryptoHelper *instance();

    // 加密 QVariantMap → .surety 文件字节（含 SUR1 头部）
    QByteArray encrypt(const QVariantMap &data) const;
    // 解密 .surety 文件字节 → QVariantMap
    QVariantMap decrypt(const QByteArray &fileBytes) const;

    // 便捷：保存/加载文件
    bool saveSuretyFile(const QString &filePath, const QVariantMap &data) const;
    QVariantMap loadSuretyFile(const QString &filePath) const;

private:
    explicit CryptoHelper(QObject *parent = nullptr);

    static constexpr quint32 MAGIC  = 0x31525553; // 'SUR1' LE
    static constexpr quint32 VERSION = 1;
};

// DPAPI entropy blob — binds encrypted data to this application
#include <cstdint>
static const uint8_t SUREITY_ASSET_ENTROPY[16] = {
    0xB8,0x4E,0xD2,0x99,0x3C,0x6F,0xAC,0x25,0x77,0xE1,0x4E,0x92,0xDB,0x68,0xF3,0x1A
};
