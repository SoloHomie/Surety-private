#pragma once
#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QString>
#include <QPoint>
#include <QSize>

// =========================================================================
//  UserSettings — 用户偏好单例 (QSettings 后端)
//  存储位置: QStandardPaths::AppDataLocation / Surety.ini
//
//  大厂分层惯例:
//    Window/*   — 窗口几何 / 状态
//    UI/*       — 界面状态 (标签页 / 侧栏 / 筛选器选中项)
//    Input/*    — 用户最近输入 (搜索词 / 表单字段)
//    General/*  — 全局偏好 (主题 / 语言)
// =========================================================================

class UserSettings : public QObject
{
    Q_OBJECT

public:
    static UserSettings *instance();

    explicit UserSettings(QObject *parent = nullptr);
    ~UserSettings() override;

    // ---- 通用键值存取 (QML 可调) ----
    Q_INVOKABLE void    setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void    sync();   // 立即落盘

    // ---- 窗口状态 ------------------------------------------------------
    Q_PROPERTY(QPoint windowPos    READ windowPos    WRITE setWindowPos    NOTIFY windowPosChanged)
    Q_PROPERTY(QSize  windowSize   READ windowSize   WRITE setWindowSize   NOTIFY windowSizeChanged)
    Q_PROPERTY(bool   windowMaxed  READ windowMaxed  WRITE setWindowMaxed  NOTIFY windowMaxedChanged)

    QPoint windowPos()    const { return _pos;    }
    QSize  windowSize()   const { return _size;   }
    bool   windowMaxed()  const { return _maxed;  }
    void   setWindowPos(const QPoint &v)   { if (v == _pos) return;   _pos   = v; _set("Window/pos",    v); emit windowPosChanged();   }
    void   setWindowSize(const QSize &v)   { if (v == _size) return;  _size  = v; _set("Window/size",   v); emit windowSizeChanged();  }
    void   setWindowMaxed(bool v)          { if (v == _maxed) return; _maxed = v; _set("Window/maxed",  v); emit windowMaxedChanged(); }

    // ---- UI 状态 -------------------------------------------------------
    Q_PROPERTY(int   lastTabIndex   READ lastTabIndex   WRITE setLastTabIndex   NOTIFY lastTabIndexChanged)
    Q_PROPERTY(int   homeTabIndex   READ homeTabIndex   WRITE setHomeTabIndex   NOTIFY homeTabIndexChanged)   // 主页内子标签
    Q_PROPERTY(QString lastAssetType READ lastAssetType WRITE setLastAssetType NOTIFY lastAssetTypeChanged)  // 资产类型筛选

    int     lastTabIndex()   const { return _lastTabIdx;   }
    int     homeTabIndex()   const { return _homeTabIdx;   }
    QString lastAssetType()  const { return _assetType;    }
    void    setLastTabIndex(int v)   { if (v == _lastTabIdx) return;  _lastTabIdx  = v; _set("UI/lastTab",    v); emit lastTabIndexChanged();   }
    void    setHomeTabIndex(int v)   { if (v == _homeTabIdx) return;  _homeTabIdx  = v; _set("UI/homeTab",    v); emit homeTabIndexChanged();   }
    void    setLastAssetType(const QString &v) { if (v == _assetType) return; _assetType = v; _set("UI/assetType", v); emit lastAssetTypeChanged(); }

    // ---- 用户最近输入 ---------------------------------------------------
    Q_PROPERTY(QString lastSearch    READ lastSearch    WRITE setLastSearch    NOTIFY lastSearchChanged)
    Q_PROPERTY(QString lastUsername   READ lastUsername   WRITE setLastUsername   NOTIFY lastUsernameChanged)

    QString lastSearch()   const { return _lastSearch;  }
    QString lastUsername() const { return _lastUser;    }
    void    setLastSearch(const QString &v)  { if (v == _lastSearch) return; _lastSearch  = v; _set("Input/search",  v); emit lastSearchChanged();  }
    void    setLastUsername(const QString &v) { if (v == _lastUser) return;  _lastUser    = v; _set("Input/username",v); emit lastUsernameChanged(); }

    // ---- 通用偏好 -------------------------------------------------------
    Q_PROPERTY(bool   rememberMe READ rememberMe WRITE setRememberMe NOTIFY rememberMeChanged)

    bool   rememberMe() const { return _remember; }
    void   setRememberMe(bool v) { if (v == _remember) return; _remember = v; _set("General/remember", v); emit rememberMeChanged(); }

signals:
    void windowPosChanged();
    void windowSizeChanged();
    void windowMaxedChanged();
    void lastTabIndexChanged();
    void homeTabIndexChanged();
    void lastAssetTypeChanged();
    void lastSearchChanged();
    void lastUsernameChanged();
    void rememberMeChanged();

private:
    void _load();
    void _set(const QString &key, const QVariant &v);

    QSettings *_settings = nullptr;

    QPoint   _pos        = {100, 100};
    QSize    _size       = {1600, 1000};
    bool     _maxed      = false;
    int      _lastTabIdx = 0;
    int      _homeTabIdx = 0;
    QString  _assetType;
    QString  _lastSearch;
    QString  _lastUser;
    bool     _remember  = false;
};
