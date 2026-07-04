#pragma once
#include <QObject>
#include <QString>
#include <QThread>

// 后台线程执行文件迁移，不阻塞 UI
class MigrationWorker : public QObject {
    Q_OBJECT
public:
    explicit MigrationWorker(const QString &oldPath, const QString &newPath)
        : m_old(oldPath), m_new(newPath) {}

public slots:
    void run();  // 在 worker 线程中执行

signals:
    void progress(int percent);          // 0-100
    void finished(bool ok, QString msg); // 完成
    void fileMigrated(QString fileName); // 当前文件

private:
    bool copyDir(const QString &src, const QString &dst, int &done, int total);
    int  countFiles(const QString &dir);

    QString m_old, m_new;
};
