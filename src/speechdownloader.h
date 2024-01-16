#ifndef SPEECHDOWNLOADER_H
#define SPEECHDOWNLOADER_H

#include <QByteArray>
#include <QEventLoop>
#include <QJSValue>
#include <QMap>
#include <QObject>
#include <QVector>
#include <QSortFilterProxyModel>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>

class StopWatch;
class QuizFilterModel;


// Maybe more that just downloading audio
// Handles network connections and some utility functions eg for sorting
// and calculating file names
class Speechdownloader : public QObject
{
  Q_OBJECT
public:
  explicit Speechdownloader(const QString& sStoragePath, QObject* pParent);
  Q_INVOKABLE void openUrl(QString sUrl);
  Q_INVOKABLE void deleteWord(QString sWord, QString sLang);
  Q_INVOKABLE void downloadWord(QString sWord, QString sLang);
  Q_INVOKABLE void translateWord(QString sWord, QString sFromLang, QString sToLang,
                                 QObject* oButton);
  Q_INVOKABLE void playWord(QString sWord, QString sLang);
  Q_INVOKABLE void exportCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd,
                                     QString sDesc, QObject* pProgressIndicator);
  Q_INVOKABLE void updateCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd,
                                     QString sDesc, QObject* pProgressIndicator);
  Q_INVOKABLE void importQuiz(QString sName, QObject* pProgressIndicator);
  // For downloading
  Q_INVOKABLE QObject* setFilterProxy(QObject* pModel);

  // For the ones in the local db
  Q_INVOKABLE QObject* setOLFilterProxy(QObject* pModel);
  // sorts the localquiz list
 /*
      AscendingOrder = 0
      DescendingOrder = 1
  */
  Q_INVOKABLE void sortQuizModel(int nRole, int nOrder);
  Q_INVOKABLE void listQuiz();
  Q_INVOKABLE void listQuizLang(QString sLang);
  Q_INVOKABLE void deleteQuiz(QString sName, QString sPwd, int nDbId);
  Q_INVOKABLE void storeTransText(QObject* p, QObject* pErrorTextField, QObject* pTrTextModel,
                                  QObject* pTrSynModel, QObject* pTrMeanModel);
  Q_INVOKABLE void storeTextInputField(int n,QObject* p);
  void AssignRoles();
  Q_INVOKABLE bool isSpecial(QString s);

  // For taking keyboard input on quiz in textmod on desktop
  Q_INVOKABLE void focusOnQuizText(int nIndex1_3);

  Q_INVOKABLE QString fromClipBoard();
  Q_INVOKABLE void toClipBoard(QString s);
  Q_INVOKABLE void pushIndex(int);
  Q_INVOKABLE int popIndex();
  bool isStackEmpty();

  Q_INVOKABLE void setFilterQList(QString regExp);
  Q_INVOKABLE void sortRowset(QJSValue p, QJSValue p1, int nCount, QJSValue jsArray);

  Q_INVOKABLE void initUrls(QVariant p);
  Q_INVOKABLE int indexFromGlosNr(QVariant p, int nNr);

  Q_INVOKABLE QString ignoreAccent(QString s);
  QString ignoreAccentLC(QString s);
  Q_INVOKABLE QString removeDiacritics(QString str);
  Q_INVOKABLE bool hasImage(QString sWord, QString sLang);
  Q_INVOKABLE QUrl imageSrc(QString sWord, QString sLang);
  Q_INVOKABLE void setImgWord(QString sWord, QString sLang);
  void checkAndEmit(QString sPath1, QString sPath2);
  Q_INVOKABLE void setImgFile(QString sWord, QString sLang, QString sWord2, QString sLang2,
                              QString sImgFilePath);
  Q_PROPERTY(QUrl urlImg READ urlImg NOTIFY urlImgChanged)
  Q_PROPERTY(bool hasImg READ hasImg NOTIFY hasImgChanged)
  Q_INVOKABLE QString dateStr();
  Q_INVOKABLE double rand();
  Q_INVOKABLE void showKey(bool b);
  void loadProgressSlot(qint64 bytesReceived, qint64 bytesTotal);

  void downloadImageSlot(const QList<QUrl>& sImgUrl, QString sWord, QString sLang, QString sWord2,
                         QString sLang2, bool bSignalDownloaded);
signals:
  void downloadImage(const QList<QUrl>& sImgUrl, QString sWord, QString sLang, QString sWord2,
                     QString sLang2, bool bSignalDownloaded = false);
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
  void transDownloaded();
  void errorSlot(QNetworkReply::NetworkError);
  void readyRead();

private:
  void currentQuizCmd(QVariant p, QString sName, QString sLang, QString sPwd, QString sDesc,
                      QString sCmd, QObject* pProgressIndicator);

  QString AudioPath(const QString& s, const QString& sLang);
  QString ImgPath(const QString& s, const QString& sLang);
  QString m_sStoragePath;
  QNetworkAccessManager m_oQuizExpNetMgr;
  QNetworkAccessManager m_oWordNetMgr;
  QNetworkAccessManager m_oImgNetMgr;
  QNetworkAccessManager m_oQuizNetMgr;
  QNetworkAccessManager m_oListQuizNetMgr;
  QNetworkAccessManager m_oDeleteQuizNetMgr;
  QNetworkAccessManager m_oTransNetMgr;
  QVector<int> m_ocIndexStack;
  bool m_bSkipNextPush = false;
  QMap<int, QObject*> m_ocTextInputElem;
  QObject* m_sTranslatedText;
  QObject* m_pErrorTextField;
  QObject* m_pTrTextModel;
  QObject* m_pTrSynModel;
  QObject* m_pTrMeanModel;
  QuizFilterModel*  m_pSortFilterProxyModel = nullptr;
  QSortFilterProxyModel*  m_pOLSortFilterProxyModel = nullptr;
  QByteArray m_oDownloadedData;

  bool m_bPlayAfterDownload = false;
  int NumberRole(QAbstractItemModel* pp);
  StopWatch* m_pStopWatch;
  QUrl m_oImgUrl;
  QString m_sImgPath;
  bool m_bHasImg = false;
};

#endif // SPEECHDOWNLOADER_H
