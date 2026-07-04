#include "CryptoHelper.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDataStream>

#ifdef Q_OS_WIN
#define NOMINMAX
#include <Windows.h>
#include <dpapi.h>
#include <wincrypt.h>
#pragma comment(lib, "crypt32.lib")
#endif

CryptoHelper *CryptoHelper::instance() { static CryptoHelper s; return &s; }

CryptoHelper::CryptoHelper(QObject *parent) : QObject(parent) {}

// ── DPAPI 加密 (with application-specific entropy) ──
static QByteArray dpapiEncrypt(const QByteArray &plain) {
#ifdef Q_OS_WIN
    DATA_BLOB in, out, e;
    in.pbData = (BYTE*)plain.constData();
    in.cbData = (DWORD)plain.size();
    e.pbData = (BYTE*)SUREITY_ASSET_ENTROPY;
    e.cbData = sizeof(SUREITY_ASSET_ENTROPY);
    if (!CryptProtectData(&in, L"SuretyAssetV1", &e, nullptr, nullptr, 0, &out))
        return {};
    QByteArray result((const char*)out.pbData, (int)out.cbData);
    LocalFree(out.pbData);
    return result;
#else
    return plain;
#endif
}

// ── DPAPI 解密 (backward compatible: try new entropy first, then legacy) ──
static QByteArray dpapiDecrypt(const QByteArray &cipher) {
#ifdef Q_OS_WIN
    DATA_BLOB in, out, e;
    in.pbData = (BYTE*)cipher.constData();
    in.cbData = (DWORD)cipher.size();
    // Try with new entropy first
    e.pbData = (BYTE*)SUREITY_ASSET_ENTROPY;
    e.cbData = sizeof(SUREITY_ASSET_ENTROPY);
    if (CryptUnprotectData(&in, nullptr, &e, nullptr, nullptr, 0, &out)) {
        QByteArray result((const char*)out.pbData, (int)out.cbData);
        LocalFree(out.pbData);
        return result;
    }
    // Fallback: legacy files without entropy
    if (CryptUnprotectData(&in, nullptr, nullptr, nullptr, nullptr, 0, &out)) {
        QByteArray result((const char*)out.pbData, (int)out.cbData);
        LocalFree(out.pbData);
        return result;
    }
    return {};
#else
    return cipher;
#endif
}

// ── 加密：QVariantMap → .surety 文件字节 ──
QByteArray CryptoHelper::encrypt(const QVariantMap &data) const {
    QJsonObject obj = QJsonObject::fromVariantMap(data);
    QByteArray json = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    QByteArray encrypted = dpapiEncrypt(json);
    if (encrypted.isEmpty()) return {};

    // 组装 SUR1 头部
    QByteArray result;
    QDataStream stream(&result, QIODevice::WriteOnly);
    stream.setByteOrder(QDataStream::LittleEndian);
    stream << MAGIC << VERSION;
    stream.writeRawData(encrypted.constData(), encrypted.size());
    return result;
}

// ── 解密：.surety 文件字节 → QVariantMap ──
QVariantMap CryptoHelper::decrypt(const QByteArray &fileBytes) const {
    if (fileBytes.size() < 8) return {};

    QDataStream stream(fileBytes);
    stream.setByteOrder(QDataStream::LittleEndian);
    quint32 magic = 0, version = 0;
    stream >> magic >> version;
    if (magic != MAGIC || version > VERSION) return {};

    int payloadSize = fileBytes.size() - 8;
    QByteArray cipher = fileBytes.mid(8, payloadSize);
    QByteArray json = dpapiDecrypt(cipher);
    if (json.isEmpty()) return {};

    QJsonDocument doc = QJsonDocument::fromJson(json);
    if (!doc.isObject()) return {};
    return doc.object().toVariantMap();
}

// ── 保存 .surety 文件 ──
bool CryptoHelper::saveSuretyFile(const QString &filePath, const QVariantMap &data) const {
    QByteArray bytes = encrypt(data);
    if (bytes.isEmpty()) return false;
    QFile f(filePath);
    if (!f.open(QIODevice::WriteOnly)) return false;
    qint64 written = f.write(bytes);
    f.close();
    return written == bytes.size();
}

// ── 加载 .surety 文件 ──
QVariantMap CryptoHelper::loadSuretyFile(const QString &filePath) const {
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly)) return {};
    QByteArray bytes = f.readAll();
    f.close();
    return decrypt(bytes);
}
