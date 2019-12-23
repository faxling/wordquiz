#ifndef SPEECHDOWNLOADER_H
#define SPEECHDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QEventLoop>

class Speechdownloader : public QObject
{
  Q_OBJECT
public:
  explicit Speechdownloader(const QString& sStoragePath, QObject *pParent);
  Q_INVOKABLE void deleteWord(QString sWord, QString sLang);
  Q_INVOKABLE void downloadWord(QString sWord, QString sLang);
  Q_INVOKABLE void playWord(QString sWord, QString sLang);
  Q_INVOKABLE void exportCurrentQuiz(QVariant p, QString sName, QString sLang,  QString sPwd,QString sDesc);
  Q_INVOKABLE void updateCurrentQuiz(QVariant p, QString sName, QString sLang,  QString sPwd,QString sDesc);
  Q_INVOKABLE void importQuiz(QString sName);
  Q_INVOKABLE void listQuiz();
  Q_INVOKABLE void deleteQuiz(QString sName, QString sPwd, QString sId);
  Q_INVOKABLE void toClipBoard(QString s);
  Q_INVOKABLE void downLoadAllSpeech(QVariant p,QString sLang);
  Q_INVOKABLE void initUrls(QVariant p);



signals:
  void quizDownloadedSignal(int nQCount, QVariantList oDD, QString sLang);
  void quizListDownloadedSignal(int nQCount, QStringList oDD);
  void downloadedSignal();
  void exportedSignal(int nResponce);
  void deletedSignal(int nResponce);

private:
  void quizDownloaded(QNetworkReply* pReply);
  void listDownloaded(QNetworkReply* pReply);
  void quizExported(QNetworkReply* pReply);
  void quizDeleted(QNetworkReply* pReply);
  void wordDownloaded(QNetworkReply* pReply);
private:
  void currentQuizCmd(QVariant p,QString sName, QString sLang,  QString sPwd,QString sDesc, QString sCmd);
  QVector<int> m_ocIndexMap;
  QString AudioPath(const QString&s , const QString& sLang);
  QString m_sStoragePath;
  QNetworkAccessManager m_oQuizExpNetMgr;
  QNetworkAccessManager m_oWordNetMgr;
  QNetworkAccessManager m_oQuizNetMgr;
  QNetworkAccessManager m_oListQuizNetMgr;
  QNetworkAccessManager m_oDeleteQuizNetMgr;

  QByteArray m_oDownloadedData;
  bool m_bPlayAfterDownload = false;
};

#endif // SPEECHDOWNLOADER_H
