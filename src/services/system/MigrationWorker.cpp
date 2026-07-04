#include "MigrationWorker.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>

int MigrationWorker::countFiles(const QString &dir) {
    int n = 0;
    QDir d(dir);
    auto list = d.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
    for (auto &e : list) {
        if (e.isDir()) n += countFiles(e.absoluteFilePath());
        else n++;
    }
    return n;
}

bool MigrationWorker::copyDir(const QString &src, const QString &dst, int &done, int total) {
    QDir().mkpath(dst);
    QDir srcDir(src);
    auto list = srcDir.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
    for (auto &e : list) {
        QString dstPath = dst + "/" + e.fileName();
        if (e.isDir()) {
            if (!copyDir(e.absoluteFilePath(), dstPath, done, total)) return false;
        } else {
            if (QFile::exists(dstPath)) QFile::remove(dstPath);
            if (!QFile::copy(e.absoluteFilePath(), dstPath)) return false;
            done++;
            emit fileMigrated(e.fileName());
            if (total > 0) emit progress(done * 100 / total);
        }
    }
    return true;
}

void MigrationWorker::run() {
    if (!QDir(m_old).exists()) {
        emit finished(true, "nothing to migrate");
        return;
    }
    emit progress(0);

    int total = countFiles(m_old);
    int done = 0;

    emit progress(10); // 准备阶段

    // 复制
    auto list = QDir(m_old).entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
    for (auto &e : list) {
        QString dstPath = m_new + "/" + e.fileName();
        if (e.isDir()) {
            if (!copyDir(e.absoluteFilePath(), dstPath, done, total)) {
                emit finished(false, "copy failed: " + e.fileName());
                return;
            }
        } else {
            if (QFile::exists(dstPath)) QFile::remove(dstPath);
            if (!QFile::copy(e.absoluteFilePath(), dstPath)) {
                emit finished(false, "copy failed: " + e.fileName());
                return;
            }
            done++;
            emit fileMigrated(e.fileName());
            if (total > 0) emit progress(done * 90 / total + 10);
        }
    }

    // 删除源目录
    emit progress(95);
    QDir(m_old).removeRecursively();

    emit progress(100);
    emit finished(true, "ok");
}
