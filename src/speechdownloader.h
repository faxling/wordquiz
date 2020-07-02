#ifndef SPEECHDOWNLOADER_H
#define SPEECHDOWNLOADER_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QEventLoop>
#include <QMap>
#include <QVector>
#include <QJSValue>
class QAbstractListModel;
class StopWatch;
class Speechdownloader : public QObject
{
  Q_OBJECT
public:
  explicit Speechdownloader(const QString& sStoragePath, QObject *pParent);
  Q_INVOKABLE void deleteWord(QString sWord, QString sLang);
  Q_INVOKABLE void downloadWord(QString sWord, QString sLang);
  Q_INVOKABLE void downloadImage(const QList<QUrl>& sImgUrl,  QString sWord,QString sLang, QString sWord2, QString sLang2, bool bSignalDownloaded = false);
  Q_INVOKABLE void playWord(QString sWord, QString sLang);
  Q_INVOKABLE void exportCurrentQuiz(QVariant p, QString sName, QString sLang,  QString sPwd,QString sDesc);
  Q_INVOKABLE void updateCurrentQuiz(QVariant p, QString sName, QString sLang,  QString sPwd,QString sDesc);
  Q_INVOKABLE void importQuiz(QString sName);
  Q_INVOKABLE void listQuiz();
  Q_INVOKABLE void listQuizLang(QString sLang);
  Q_INVOKABLE void deleteQuiz(QString sName, QString sPwd, QString sId);
  Q_INVOKABLE void storeTextInputField(QObject* p);
  Q_INVOKABLE void storeCurrentIndex(int);
  Q_INVOKABLE void toClipBoard(QString s);
  Q_INVOKABLE void pushIndex(int);
  Q_INVOKABLE int popIndex();
  bool isStackEmpty();
  Q_INVOKABLE void sortRowset(QJSValue p,QJSValue p1, int nCount,  QJSValue jsArray);
  Q_INVOKABLE void downLoadAllSpeech(QVariant p,QString sLang);
  Q_INVOKABLE void initUrls(QVariant p);
  Q_INVOKABLE int  indexFromGlosNr(QVariant p, int nNr);
  Q_INVOKABLE void startTimer();
  Q_INVOKABLE void stopTimer();
  Q_INVOKABLE QString ignoreAccent(QString s);
  QString ignoreAccentLC(QString s);
  Q_INVOKABLE bool hasImage(QString sWord, QString sLang);
  Q_INVOKABLE QUrl imageSrc(QString sWord, QString sLang);
  Q_INVOKABLE void setImgWord(QString sWord, QString sLang);
  void checkAndEmit(QString sPath1, QString sPath2);
  Q_INVOKABLE void setImgFile(QString sWord, QString sLang,QString sWord2, QString sLang2, QString sImgFilePath);
  Q_PROPERTY(QUrl urlImg READ urlImg NOTIFY urlImgChanged)
  Q_PROPERTY(bool hasImg READ hasImg NOTIFY hasImgChanged)
  Q_INVOKABLE QString dateStr();
signals:
  void quizDownloadedSignal(int nQCount, QVariantList oDD, QString sLang);
  void quizListDownloadedSignal(int nQCount, QStringList oDD);
  void downloadedSignal();
  void downloadedImgSignal();
  void exportedSignal(int nResponce);
  void deletedSignal(int nResponce);
  void hasImgChanged();
  void urlImgChanged();
private:
  QUrl urlImg();
  bool hasImg();
  void quizDownloaded(QNetworkReply* pReply);
  void listDownloaded(QNetworkReply* pReply);
  void quizExported(QNetworkReply* pReply);
  void quizDeleted(QNetworkReply* pReply);

  void wordDownloaded(QNetworkReply* pReply);
  void imgDownloaded(QNetworkReply* pReply);
private:
  void currentQuizCmd(QVariant p,QString sName, QString sLang,  QString sPwd,QString sDesc, QString sCmd);
  // QVector<int> m_ocIndexMap;
  QString AudioPath(const QString&s , const QString& sLang);
  QString ImgPath(const QString&s , const QString& sLang);
  QString m_sStoragePath;
  QNetworkAccessManager m_oQuizExpNetMgr;
  QNetworkAccessManager m_oWordNetMgr;
  QNetworkAccessManager m_oImgNetMgr;
  QNetworkAccessManager m_oQuizNetMgr;
  QNetworkAccessManager m_oListQuizNetMgr;
  QNetworkAccessManager m_oDeleteQuizNetMgr;
  QVector<int> m_ocIndexStack;
  QVector<QObject*> m_ocTextInputElem;
  QByteArray m_oDownloadedData;
  bool m_bPlayAfterDownload = false;
  int NumberRole(QAbstractListModel* pp);
  StopWatch* m_pStopWatch;
  QUrl m_oImgUrl;
  QString m_sImgPath;
  bool m_bHasImg = false;
};

#endif // SPEECHDOWNLOADER_H
