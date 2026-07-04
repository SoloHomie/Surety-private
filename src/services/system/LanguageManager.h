#pragma once
#include <QObject>
#include <QTranslator>
#include <QString>

class QQmlEngine;

class LanguageManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
public:
    static LanguageManager *instance();

    QString currentLanguage() const { return m_current; }

    Q_INVOKABLE void setLanguage(const QString &lang);
    Q_INVOKABLE QString languageName() const;

    void setEngine(QQmlEngine *engine) { m_engine = engine; }
    void loadTranslations();

signals:
    void languageChanged();

private:
    explicit LanguageManager(QObject *parent = nullptr);
    bool installTranslator(const QString &lang);

    QTranslator m_translator;
    QQmlEngine *m_engine = nullptr;
    QString m_current;
};
