#include "UserSettings.h"
#include <QStandardPaths>
#include <QDir>
#include <QSettings>

UserSettings *UserSettings::instance()
{
    static UserSettings s;
    return &s;
}

UserSettings::UserSettings(QObject *parent)
    : QObject(parent)
{
    const QString dirPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dirPath);

    const QString filePath = dirPath + "/Surety.ini";
    _settings = new QSettings(filePath, QSettings::IniFormat, this);

    _load();
}

UserSettings::~UserSettings()
{
    _settings->sync();
}

// ---- 加载 ----
void UserSettings::_load()
{
    _pos    = _settings->value("Window/pos",   QPoint(100, 100)).toPoint();
    _size   = _settings->value("Window/size",  QSize(1600, 1000)).toSize();
    _maxed  = _settings->value("Window/maxed", false).toBool();

    _lastTabIdx = _settings->value("UI/lastTab",   0).toInt();
    _homeTabIdx = _settings->value("UI/homeTab",   0).toInt();
    _assetType  = _settings->value("UI/assetType", "").toString();

    _lastSearch = _settings->value("Input/search",   "").toString();
    _lastUser   = _settings->value("Input/username", "").toString();

    _remember   = _settings->value("General/remember", false).toBool();
}

// ---- 写入 ----
void UserSettings::_set(const QString &key, const QVariant &v)
{
    _settings->setValue(key, v);
}

// ---- 通用接口 (QML 侧自定义键值) ----
void UserSettings::setValue(const QString &key, const QVariant &value)
{
    _settings->setValue(key, value);
}

QVariant UserSettings::value(const QString &key, const QVariant &defaultValue) const
{
    return _settings->value(key, defaultValue);
}

void UserSettings::sync()
{
    _settings->sync();
}
