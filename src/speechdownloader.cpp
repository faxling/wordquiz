#include "speechdownloader.h"

#include <QAbstractListModel>
#include <QBuffer>
#include <QClipboard>
#include <QDataStream>
#include <QDebug>
#include <QDesktopServices>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QImageReader>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonValue>
#include <QSound>
#include <QTextDocument>
#include <QUrl>
#include <QUrlQuery>
#include <random>

#include "filehelpers.h"

// https://cloud.ibm.com/resources
// https://api.eu-gb.language-translator.watson.cloud.ibm.com
// https://cloud.ibm.com/apidocs/language-translator
// Softfrax2020 ibm     key 5oqs7wWEFhW37qCqqXTI5xncIPT69580V3l1998ScAWv

// Faxling     Raggo100
// trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f

// https://cloud.yandex.com/docs/speechkit/tts/request
// https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&text=groda&lang=sv-ru
// dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739

// speaker=<jane|oksana|alyss|omazh|zahar|ermil>
// http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=ermil&text=да&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7

// https://dictionary.yandex.net/api/v1/dicservice/getLangs?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739

#define GLOS_SERVER2 "http://mss7000.com/glosquiz/"

static const QString GLOS_SERVER1("http://192.168.2.1");

struct EncUrl
{

  operator QUrl()
  {
    QByteArray ocRet = oc;
    oc.clear();
    m_bFirstPar = true;
    return QUrl::fromEncoded(ocRet);
  }

  EncUrl& operator<<(const QString& s)
  {
    oc.append(QUrl::toPercentEncoding(s));
    return *this;
  }

  EncUrl& operator<<(const char* sz)
  {
    size_t n = strlen(sz);
    if (sz[n-1] != '=')
    {
      oc.append(sz);
      return *this;
    }
    if (m_bFirstPar)
    {
      m_bFirstPar = false;
      oc.append("?");
    }
    else
    {
      oc.append("&");
    }
    oc.append(sz);
    return *this;
  }
  EncUrl& operator<<(int n)
  {
    char sz[20];
    sprintf(sz, "%d", n);
    oc.append(QByteArray(sz));
    return *this;
  }

private:
  bool m_bFirstPar = true;
  QByteArray oc;
};


namespace
{
  EncUrl url;
}

Speechdownloader::Speechdownloader(const QString& sStoragePath, QObject* pParent) : QObject(pParent)
{
  QObject::connect(&m_oImgNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::imgDownloaded);
  QObject::connect(&m_oWordNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::wordDownloaded);
  QObject::connect(&m_oQuizExpNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::quizExported);
  QObject::connect(&m_oQuizNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::quizDownloaded);
  QObject::connect(&m_oListQuizNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::listDownloaded);
  QObject::connect(&m_oDeleteQuizNetMgr, &QNetworkAccessManager::finished, this,
                   &Speechdownloader::quizDeleted);
  m_sStoragePath = sStoragePath;

  qDebug() << "WordQuiz StoragePath: " << m_sStoragePath;
  QSound::play("qrc:welcome_en.wav");
  m_pStopWatch = nullptr;
}

static const QString sReqDictUrlBase = "https://dictionary.yandex.net/api/v1/dicservice/"
                                       "lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478."
                                       "20679d5d18a62fa88bd53b643af2dee64416b739&lang=";
static const QString sReqDictUrl = "https://dictionary.yandex.net/api/v1/dicservice/"
                                   "lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478."
                                   "20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text=";
static const QString sReqDictUrlRev = "https://dictionary.yandex.net/api/v1/dicservice/"
                                      "lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478."
                                      "20679d5d18a62fa88bd53b643af2dee64416b739&lang=ru-sv&text=";
static const QString sReqDictUrlEn = "https://dictionary.yandex.net/api/v1/dicservice/"
                                     "lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478."
                                     "20679d5d18a62fa88bd53b643af2dee64416b739&lang=en-ru&text=";
static const QString sReqUrlBase = "https://translate.yandex.net/api/v1.5/tr/"
                                   "translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d."
                                   "d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang=";

void Speechdownloader::initUrls(QVariant p)
{
  QObject* pp = qvariant_cast<QObject*>(p);
  pp->setProperty("sReqDictUrlBase", sReqDictUrlBase);
  pp->setProperty("sReqDictUrl", sReqDictUrl);
  pp->setProperty("sReqDictUrlRev", sReqDictUrlRev);
  pp->setProperty("sReqDictUrlEn", sReqDictUrlEn);
  pp->setProperty("sReqUrlBase", sReqUrlBase);
}

QString Speechdownloader::ignoreAccentLC(QString str)
{
  static QString sssIn = QString::fromWCharArray(L"íîàáâãèéêëòóôõõùúûçёщąćęłńóśźż");
  static QString sssOut = QString::fromWCharArray(L"iiaaaaeeeeooooouuucешacelnoszz");
  static QRegExp oReg("[\\W]"); // Matches a non-word character.
  str.replace(oReg, "");

  str = str.toLower();

  for (auto i = str.begin(); i != str.end(); i++)
  {
    int nI = sssIn.indexOf(*i);

    if (nI >= 0)
      *i = sssOut[nI];
  }

  return str;
}

bool Speechdownloader::isSpecial(QString str)
{
  static QString sssIn = QString::fromWCharArray(L"\".! '?");
  return sssIn.indexOf(str) >= 0;
}

QString Speechdownloader::ignoreAccent(QString str)
{
  static QString sssIn = QString::fromWCharArray(L"ÍÎÀÁÂÃÈÉÊËÒÓÔÕÕÙÚÛÇЁЩĄĆĘŁŃÓŚŹŻ");
  static QString sssOut = QString::fromWCharArray(L"IIAAAAEEEEOOOOOUUUCЕШACELNOSZZ");
  static QRegExp oReg("[\\W]"); // Matches a non-word character.
  str.replace(oReg, "");

  str = str.toUpper();

  for (auto i = str.begin(); i != str.end(); i++)
  {
    int nI = sssIn.indexOf(*i);

    if (nI >= 0)
      *i = sssOut[nI];
  }

  return str;
}

void Speechdownloader::openUrl(QString sUrl)
{
  //  QProcess::startDetached("/usr/bin/sailfish-browser " + sUrl);
  QDesktopServices::openUrl(QUrl(sUrl));
}

QString Speechdownloader::removeDiacritics(QString str)
{
  QString filtered;
  for (int i = 0; i < str.length(); i++)
  {
    if (str.at(i).category() != QChar::Mark_NonSpacing)
    {
      filtered.append(str.at(i));
    }
  }
  return filtered;
}

QString Speechdownloader::dateStr()
{
  const wchar_t* szFormat = L"%Y-%m-%d  %H:%M";
  wchar_t szStr[20];
  time_t tNow = time(0);
  wcsftime(szStr, 20, szFormat, localtime(&tNow));
  return QString::fromWCharArray(szStr);
}
/*
void Speechdownloader::setImgWord(QString sWord, QString sLang)
{
  m_sImgPath = ImgPath(sWord, sLang);
  bool bEx = QFile::exists(m_sImgPath);

  if (bEx == true)
    m_oImgUrl = QUrl::fromLocalFile(m_sImgPath);
  else
    m_oImgUrl = QUrl();

  if (bEx != m_bHasImg)
  {
    m_bHasImg = bEx;
    emit hasImgChanged();
  }

  emit urlImgChanged();
}
*/
// Try Select image from both languages in a pair
QUrl Speechdownloader::imageSrc(QString sWord, QString sLang)
{
  auto oc = sLang.split("-");

  auto GetImg = [&] (QString sWord, QString sLang, QUrl& oOut)
  {
    QString s = ImgPath(sWord, sLang);
    bool bEx = QFile::exists(s);
    if (bEx == true)
    {
     oOut = QUrl::fromLocalFile(s);
     return true;
    }
    else
    {
      oOut =  QUrl("image://theme/icon-m-file-image");
      return false;
    }
  };

  QUrl oRet;
  if (GetImg(sWord, oc[0],oRet))
    return oRet;

  if (oc.size() < 2)
    return oRet;
  GetImg(sWord, oc[1],oRet);
  return oRet;
}
/*
void Speechdownloader::checkAndEmit(QString sPath1, QString sPath2)
{
  if (m_sImgPath == sPath1 || m_sImgPath == sPath2)
  {
    if (m_bHasImg == true)
    {
      m_oImgUrl = QUrl();
      emit urlImgChanged();
    }
    else
    {
      m_bHasImg = true;
      emit hasImgChanged();
    }
    m_oImgUrl = QUrl::fromLocalFile(m_sImgPath);
    emit urlImgChanged();
  }
}
*/


/*
void Speechdownloader::setImgFile(QString sWord, QString sLang, QString sWord2, QString sLang2,
                                  QString sImgFilePath)
{
  QImageReader oImageReader(sImgFilePath);
  oImageReader.setAutoTransform(true);
  QImage oImage = oImageReader.read();
  QImage oImageScaled = oImage.scaledToHeight(230);
  QString sImg1 = ImgPath(sWord, sLang);
  oImageScaled.save(sImg1);
  QString sImg2 = ImgPath(sWord2, sLang2);
  QFile::copy(sImg1, sImg2);
   checkAndEmit(sImg1, sImg2);
}
*/
bool Speechdownloader::hasImage(QString sWord, QString sLang)
{
  if (sWord.isEmpty())
    return false;
  if (sLang.isEmpty())
    return false;

  QString s = ImgPath(sWord, sLang);
  return QFile::exists(s);
}

/*
bool Speechdownloader::hasImg()
{
  return m_bHasImg;
}
*/
/*
QUrl Speechdownloader::urlImg()
{
  return m_oImgUrl;
}
*/
void Speechdownloader::imgDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();
  pReply->deleteLater();

  if (m_oDownloadedData.size() < 5000)
    return;
  QString sCT = pReply->header(QNetworkRequest::ContentTypeHeader).toString();

  if (sCT.isEmpty() == false)
    if (sCT.contains("image") == false)
      return;

  QUrlQuery uQ(pReply->url());
  QString sWord, sLang, sWord2, sLang2;

  sWord = uQ.queryItemValue("text");
  sLang = uQ.queryItemValue("lang");
  sWord2 = uQ.queryItemValue("text2");
  sLang2 = uQ.queryItemValue("lang2");
  QString sFileName = ImgPath(sWord, sLang);
  QBuffer oBuff(&m_oDownloadedData);
  QImageReader oImageReader(&oBuff);
  oImageReader.setAutoTransform(true);
  QImage oImage = oImageReader.read();
  QImage oImageScaled = oImage.scaledToHeight(160);
  if (oImageScaled.height() < 100)
    return;
  oImageScaled.save(sFileName);
  QString sImg2 = ImgPath(sWord2, sLang2);
  QFile::copy(sFileName, sImg2);

 //  checkAndEmit(sFileName, sImg2);

  if (uQ.queryItemValue("emit").toInt() == 1)
  {
    emit downloadedImgSignal();
  }
}

void Speechdownloader::wordDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();
  pReply->deleteLater();
  if (m_oDownloadedData.size() < 10000)
    return;

  QUrlQuery uQ(pReply->url());

  QString sWord, sLang;
  QStringList ocLang;
  if (uQ.hasQueryItem("src") == true)
  {
    sWord = uQ.queryItemValue("src");
    ocLang = uQ.queryItemValue("hl").split("-");
  }
  else
  {
    sWord = uQ.queryItemValue("text");
    ocLang = uQ.queryItemValue("lang").split("_");
  }

  sLang = ocLang.first();

  QString sFileName = AudioPath(sWord, sLang);

  QFile oWav(sFileName);
  oWav.open(QIODevice::WriteOnly);
  oWav.write(m_oDownloadedData);
  oWav.close();

  emit downloadedSignal();
  if (uQ.hasQueryItem("PlayAfterDownload") == true)
  {
    QSound::play(sFileName);
  }
}

QString Speechdownloader::AudioPath(const QString& s, const QString& sLang)
{
  if (sLang.isEmpty())
    return (m_sStoragePath ^ s) + ".wav";

  return (m_sStoragePath ^ ignoreAccentLC(s)) + "_" + sLang + ".wav";
}

QString Speechdownloader::ImgPath(const QString& sIn, const QString& sLang)
{
  if (sLang.isEmpty())
    return (m_sStoragePath ^ sIn) + ".jpg";

  QString sRet = (m_sStoragePath ^ ignoreAccent(sIn)) + "_" + sLang + ".jpg";
  return sRet;
}

void Speechdownloader::quizDeleted(QNetworkReply* pReply)
{
  int nRet = pReply->error();
  QString oc = QString(pReply->readAll());
  if (nRet == QNetworkReply::NoError)
    emit deletedSignal(oc.toInt());
  else
    emit deletedSignal(-2);
  pReply->deleteLater();
}

void Speechdownloader::quizExported(QNetworkReply* pReply)
{
  int nRet = pReply->error();

  if (nRet == QNetworkReply::NoError)
    emit exportedSignal(pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
  else
    emit exportedSignal(0);
  QObject* pProgressIndicator = qvariant_cast<QObject*>(pReply->property("progressIndicator"));
  pProgressIndicator->setProperty("visible", false);
  pReply->deleteLater();
}

struct QuizInfo
{
  QString qname;
  QString desc1;
  QString slang;
  QString qcount;
  QString number;
};

void Speechdownloader::listDownloaded(QNetworkReply* pReply)
{
  int nRet = pReply->error();

  if (nRet != QNetworkReply::NoError)
  {
    emit quizListDownloadedSignal(-1, QStringList());
    return;
  }

  QByteArray oc = pReply->readAll();
  QJsonDocument oJ = QJsonDocument::fromJson(oc);

  QJsonArray ocJson = oJ.array();

  // m_ocIndexMap.clear();

  QVector<QuizInfo> ocQuizInfo;

  for (auto oI : ocJson)
  {
    //   id, desc1, slang, qcount,qname
    QJsonArray oJJ = oI.toArray();
    QuizInfo t;
    t.number = oJJ[0].toString();
    t.desc1 = oJJ[1].toString();
    t.slang = oJJ[2].toString();
    t.qcount = oJJ[3].toString();
    t.qname = oJJ[4].toString();
    ocQuizInfo.push_back(t);
  }

  std::sort(ocQuizInfo.begin(), ocQuizInfo.end(), [](const QuizInfo& t1, const QuizInfo& t2) {
    QString s1 = t1.slang;
    QString s2 = t2.slang;
    std::sort(s1.begin(), s1.end());
    std::sort(s2.begin(), s2.end());
    if (s1 == s2)
      return t1.qname < t2.qname;
    return s1 < s2;
  });

  QStringList ocL;
  for (const auto& oI : ocQuizInfo)
  {
    ocL.append(oI.qname);
    ocL.append(oI.desc1);
    ocL.append(oI.slang);
    ocL.append(oI.qcount);
    ocL.append(oI.number);
    /*
                        "qname"
                        "desc1"
                        "slang"
                        "qcount
                        "number"
                        */
  }
  pReply->deleteLater();
  emit quizListDownloadedSignal(ocL.size(), ocL);
}

//  https://cloud.yandex.com/docs/speechkit/tts/request
QString sVoicetechRu(QStringLiteral("http://tts.voicetech.yandex.net/"
                                    "generate?lang=ru_RU&format=wav&speaker=oksana&key=6372dda5-"
                                    "9674-4413-85ff-e9d0eb2f99a7&text="));
QString sVoicetechEn(QStringLiteral("http://tts.voicetech.yandex.net/"
                                    "generate?lang=en_EN&format=wav&speaker=oksana&key=6372dda5-"
                                    "9674-4413-85ff-e9d0eb2f99a7&text="));

QString sVoicetechFr(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&r=2&hl=fr-fr&src="));
QString sVoicetechSe(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=sv-se&src="));
QString sVoicetechNo(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=nb-no&src="));
QString sVoicetechIt(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=it-it&src="));
QString sVoicetechDe(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=de-de&src="));
QString sVoicetechPl(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=pl-pl&src="));
QString sVoicetechEs(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=es-es&src="));
QString sVoicetechHu(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=hu-hu&src="));
QString sVoicetechKo(QStringLiteral("http://"
                                    "api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f="
                                    "44khz_16bit_mono&hl=ko-kr&src="));

void Speechdownloader::playWord(QString sWord, QString sLang)
{
  QString sFileName = AudioPath(sWord, sLang);
  QFileInfo oWavFile(sFileName);
  if (oWavFile.size() > 10000)
  {
    QSound::play(sFileName);
  }
  else
  {
    m_bPlayAfterDownload = true;
    downloadWord(sWord, sLang);
  }
}

void Speechdownloader::deleteWord(QString sWord, QString sLang)
{
  if (QFile::exists(AudioPath(sWord, sLang)))
    QFile::remove(AudioPath(sWord, sLang));
}

void Speechdownloader::downloadImageSlot(const QList<QUrl>& vImgUrl, QString sWord, QString sLang,
                                         QString sWord2, QString sLang2, bool bEmitlDownloaded)
{
  // Must use a signal slot for shifting threads

  if (vImgUrl.count() < 1)
    return;
  QUrl u = vImgUrl.first();
  QUrlQuery oQuery(u.query());
  oQuery.addQueryItem("text", sWord);
  oQuery.addQueryItem("lang", sLang);
  oQuery.addQueryItem("text2", sWord2);
  oQuery.addQueryItem("lang2", sLang2);
  if (bEmitlDownloaded == true)
    oQuery.addQueryItem("emit", "1");
  u.setQuery(oQuery);
  QNetworkRequest request(u);
  m_oImgNetMgr.get(request);
}

void Speechdownloader::downloadWord(QString sWord, QString sLang)
{
  static QMap<QString, QString> ocUrlMap{
      {"no", sVoicetechNo}, {"ru", sVoicetechRu}, {"en", sVoicetechEn}, {"sv", sVoicetechSe},
      {"fr", sVoicetechFr}, {"pl", sVoicetechPl}, {"de", sVoicetechDe}, {"it", sVoicetechIt},
      {"es", sVoicetechEs}, {"hu", sVoicetechHu}, {"ko", sVoicetechKo}};

  QString sUrl = ocUrlMap[sLang] + sWord;
  if (m_bPlayAfterDownload == true)
    sUrl += "&PlayAfterDownload=1";
  m_bPlayAfterDownload = false;
  QNetworkRequest request(sUrl);
  m_oWordNetMgr.get(request);
}

void Speechdownloader::listQuizLang(QString sLang)
{
  url << GLOS_SERVER2 "quizlist_lang.php"
      << "qlang=" << sLang;
  QNetworkRequest request(url);
  m_oListQuizNetMgr.get(request);
}

/*
5   "qname"   0
4   "code"   1
3   "state1"   2
2   "desc1"   3
1   "date1"   4
0   "number"   5
*/

class QuizFilterModel : public QSortFilterProxyModel
{
public:
  QStringList FilterStr;
  bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override
  {
    auto HasColumStr = [&](int n, const QString& sF) {
      QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
      QString s = sourceModel()->data(index0, n).toString();
      return s.contains(sF, Qt::CaseSensitivity::CaseInsensitive);
    };

    for (auto oI : IterRange(FilterStr))
    {
      if (oI.val().endsWith("-"))
      {
        QString s = oI.val();
        QString sExtraCheck("-" + s.remove("-"));
        if (HasColumStr(4, oI.val()) || HasColumStr(4, sExtraCheck))
          continue;
      }

      if ((HasColumStr(5, oI.val()) || HasColumStr(4, oI.val()) || HasColumStr(2, oI.val())) ==
          false)
        return false;
    }

    return true;
  }
};
static int QUIZNUMBER = -1;
static int QUIZNAME = -1;
static int LANGPAIR = -1;

void Speechdownloader::sortQuizModel(int nRole, int sortOrder)
{
  if (nRole == 0)
    m_pOLSortFilterProxyModel->setSortRole(QUIZNAME);
  else if (nRole == 1)
    m_pOLSortFilterProxyModel->setSortRole(LANGPAIR);
  m_pOLSortFilterProxyModel->sort(0, (Qt::SortOrder)sortOrder);

}

// Sort for local quizlist
class QuizSortModel : public QSortFilterProxyModel
{
public:
  bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const override
  {

    if (sortRole() == QUIZNAME)
      return source_left.data(QUIZNAME).toString() < source_right.data(QUIZNAME).toString();

    QString s1 = source_left.data(LANGPAIR).toString();
    QString s2 = source_right.data(LANGPAIR).toString();
    std::sort(s1.begin(), s1.end());
    std::sort(s2.begin(), s2.end());
    return s1 < s2;
  }
};

void Speechdownloader::AssignRoles()
{
  if (QUIZNUMBER != -1)
    return;
  auto* pp = m_pOLSortFilterProxyModel->sourceModel();

  auto oOC = pp->roleNames();

  if (oOC.isEmpty() == false)
    for (auto oJ : IterRange(oOC))
    {
      if (oJ.val() == "langpair")
        LANGPAIR = oJ.key();
      else if (oJ.val() == "quizname")
        QUIZNAME = oJ.key();
      else if (oJ.val() == "number")
        QUIZNUMBER = oJ.key();

      qDebug() << oJ.key() << " " << oJ.val() << " " << oJ.index();
    }
}

QObject* Speechdownloader::setOLFilterProxy(QObject* pModel)
{
  QAbstractListModel* pp = dynamic_cast<QAbstractListModel*>(pModel);
  if (m_pOLSortFilterProxyModel == nullptr)
    m_pOLSortFilterProxyModel = new QuizSortModel;

  m_pOLSortFilterProxyModel->setSourceModel(pp);
  AssignRoles();
  return m_pOLSortFilterProxyModel;
}

void Speechdownloader::setFilterQList(QString regExp)
{
  regExp = regExp.trimmed();
  m_pSortFilterProxyModel->FilterStr = regExp.split(" ");
  //  auto& rFilterStr = m_pSortFilterProxyModel->FilterStr;

  // auto pE = std::remove_if(rFilterStr.begin(), rFilterStr.end(), [](const
  // QString& s) {return s.isEmpty();}); rFilterStr.erase(pE, rFilterStr.end());
  // for (auto oJ : IterRange(rFilterStr))
  //   qDebug() << oJ.val() << " " << oJ.index();

  m_pSortFilterProxyModel->invalidate();
}

QObject* Speechdownloader::setFilterProxy(QObject* pModel)
{
  QAbstractListModel* pp = dynamic_cast<QAbstractListModel*>(pModel);
  if (m_pSortFilterProxyModel == nullptr)
    m_pSortFilterProxyModel = new QuizFilterModel;

  m_pSortFilterProxyModel->setSourceModel(pp);

  auto oOC = pp->roleNames();

  for (auto oJ : IterRange(oOC))
    qDebug() << oJ.key() << " " << oJ.val() << " " << oJ.index();

  return m_pSortFilterProxyModel;
}

void Speechdownloader::listQuiz()
{
  QString ss = GLOS_SERVER2 "quizlist.php";
  QUrl u(ss);
  qDebug() << ss;
  QNetworkRequest request(u);
  m_oListQuizNetMgr.get(request);
}

void Speechdownloader::quizDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();
  QObject* p0 = qvariant_cast<QObject*>(pReply->property("progressIndicator"));
  p0->setProperty("visible", false);

  QVariantList oDataDownloaded;
  pReply->deleteLater();
  if (m_oDownloadedData.size() < 1000)
  {
    emit quizDownloadedSignal(-1, oDataDownloaded, "");
    return;
  }
  QDataStream ss(&m_oDownloadedData, QIODevice::ReadOnly);
  int nC;
  ss >> nC;
  QString sLang;
  ss >> sLang;
  for (int i = 0; i < nC; i++)
  {
    for (int j = 0; j <= 2; ++j)
    {
      QVariant v;
      ss >> v;
      oDataDownloaded.append(v);
    }
  }
  ss >> nC;

  for (int i = 0; i < nC; i++)
  {
    QString s;
    ss >> s;
    QByteArray oc;
    ss >> oc;
    QFile oWav(AudioPath(s, ""));
    oWav.open(QIODevice::ReadWrite);
    oWav.write(oc);
    oWav.close();
  }

  if (ss.version() >= 2)
  {
    ss >> nC;
    for (int i = 0; i < nC; i++)
    {
      QString s;
      ss >> s;
      QByteArray oc;
      ss >> oc;
      QFile oImg(ImgPath(s, ""));
      oImg.open(QIODevice::ReadWrite);
      oImg.write(oc);
      oImg.close();
    }
  }

  emit quizDownloadedSignal(oDataDownloaded.size(), oDataDownloaded, sLang);
}

void Speechdownloader::deleteQuiz(QString sName, QString sPwd, int nDbId)
{
  url << GLOS_SERVER2 "deletequiz.php" << "qname=" << sName << "qpwd=" << sPwd << "dbid=" << nDbId;
  QNetworkRequest request(url);
  m_oDeleteQuizNetMgr.get(request);
}

void Speechdownloader::loadProgressSlot(qint64 bytes, qint64 bytesTotal)
{
  QNetworkReply* pReply = static_cast<QNetworkReply*>(sender());
  QObject* pO = qvariant_cast<QObject*>(pReply->property("progressIndicator"));
  pO->setProperty("progress", bytes / (double)bytesTotal);
  //  qDebug() << "progress " <<  bytesTotal;
}

void Speechdownloader::importQuiz(QString sName, QObject* pProgressIndicator)
{
  //  QString sUrl = QString::asprintf(GLOS_SERVER2 "/quizload.php?qname=%s", Enc()(sName +
  //  ".txt"));

  url << GLOS_SERVER2 "quizload.php" << "qname=" << sName << ".txt";

  QNetworkRequest request(url);
  QNetworkReply* pNR = m_oQuizNetMgr.get(request);
  pNR->setProperty("progressIndicator", QVariant::fromValue(pProgressIndicator));
  pProgressIndicator->setProperty("progress", 0);
  pProgressIndicator->setProperty("visible", true);
  QObject::connect(pNR, &QNetworkReply::downloadProgress, this,
                   &Speechdownloader::loadProgressSlot);
}

QString Speechdownloader::fromClipBoard()
{
  return QGuiApplication::clipboard()->text();
}

void Speechdownloader::toClipBoard(QString s)
{
  QGuiApplication::clipboard()->setText(s);
}

void Speechdownloader::updateCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd,
                                         QString sDesc, QObject* pProgressIndicator)
{
  currentQuizCmd(p, sName, sLang, sPwd, sDesc, "updatequiz", pProgressIndicator);
}

void Speechdownloader::exportCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd,
                                         QString sDesc, QObject* pProgressIndicator)
{
  currentQuizCmd(p, sName, sLang, sPwd, sDesc, "store", pProgressIndicator);
}

void Speechdownloader::sortRowset(QJSValue p0, QJSValue p1, int nCount, QJSValue jsArray)
{
  struct QI_i
  {
    int nNr;
    QString sLangPair;
    QString sQname;
  };

  QList<QI_i> ocQuizInfo;

  for (int i = 0; i < nCount; ++i)
  {
    QJSValueList oParList{i};
    auto oFullItem = p0.callWithInstance(p1, oParList);
    QI_i tItem;
    tItem.nNr = i;
    tItem.sLangPair = oFullItem.property("langpair").toString();
    tItem.sQname = oFullItem.property("quizname").toString();
    ocQuizInfo.push_back(tItem);
  }

  std::sort(ocQuizInfo.begin(), ocQuizInfo.end(), [](const QI_i& t1, const QI_i& t2) {
    QString s1 = t1.sLangPair;
    QString s2 = t2.sLangPair;
    std::sort(s1.begin(), s1.end());
    std::sort(s2.begin(), s2.end());
    if (s1 == s2)
      return t1.sQname < t2.sQname;
    return s1 < s2;
  });

  for (int i = 0; i < nCount; ++i)
  {
    jsArray.setProperty(i, ocQuizInfo[i].nNr);
  }
}

// {"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword ,
// "answer": sA, "extra": sE, "state1" : rs.rows.item(i).state } 0 answer 1
// extra 2 number 3 question 4 state

void Speechdownloader::currentQuizCmd(QVariant p, QString sName, QString sLang, QString sPwd,
                                      QString sDesc, QString sCmd, QObject* pProgressIndicator)
{
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  QByteArray ocArray;
  QDataStream ss(&ocArray, QIODevice::WriteOnly);
  QStringList ocAudio;
  QStringList ocImg;
  QStringList ocLang = sLang.split("-");
  int nC = pp->rowCount();
  ss << nC;
  ss << sLang;
  for (int i = 0; i < nC; i++)
  {
    for (int j = 0; j <= 3; ++j)
    {
      if (j == 2) // SKIP  state1 and number
        continue;
      ss << pp->data(pp->index(i), j);
    }
    QString sFilePath;
    QString sWord = pp->data(pp->index(i), 0).toString();

    sFilePath = AudioPath(sWord, ocLang[1]);
    if (QFile::exists(sFilePath))
      ocAudio.append(JustFileNameNoExt(sFilePath));

    sFilePath = ImgPath(sWord, ocLang[1]);
    if (QFile::exists(sFilePath))
      ocImg.append(JustFileNameNoExt(sFilePath));

    // Question
    sWord = pp->data(pp->index(i), 3).toString();
    sFilePath = AudioPath(sWord, ocLang[0]);
    if (QFile::exists(sFilePath))
      ocAudio.append(JustFileNameNoExt(sFilePath));

    sFilePath = ImgPath(sWord, ocLang[0]);
    if (QFile::exists(sFilePath))
      ocImg.append(JustFileNameNoExt(sFilePath));
  }

  ss << ocAudio.size();
  for (auto& oI : ocAudio)
  {
    QFile oF(AudioPath(oI, ""));
    ss << oI;
    oF.open(QIODevice::ReadOnly);
    ss << oF.readAll();
    oF.close();
  }
  ss << ocImg.size();
  for (auto& oI : ocImg)
  {
    QFile oF(ImgPath(oI, ""));
    ss << oI;
    oF.open(QIODevice::ReadOnly);
    ss << oF.readAll();
    oF.close();
  };

  url << GLOS_SERVER2 << sCmd << ".php"
      << "qname=" << sName << "slang=" << sLang << "qcount=" << nC << "desc1=" << sDesc
      << "pwd=" << sPwd;

  qDebug() << "Cmd to glosserver " << sCmd << " size " << ocArray.size();
  ss.setVersion(2);
  QNetworkRequest request(url);
  request.setRawHeader("Content-Type", "application/octet-stream");
  request.setRawHeader("Content-Length", QByteArray::number(ocArray.size()));
  QNetworkReply* pNR = m_oQuizExpNetMgr.post(request, ocArray);
  pNR->setProperty("progressIndicator", QVariant::fromValue(pProgressIndicator));
  QObject::connect(pNR, &QNetworkReply::uploadProgress, this, &Speechdownloader::loadProgressSlot);
  pProgressIndicator->setProperty("progress", 0);
  pProgressIndicator->setProperty("visible", true);
}

void Speechdownloader::transDownloaded()
{
  QNetworkReply* pReply = static_cast<QNetworkReply*>(sender());
  QByteArray oc = pReply->readAll();
  QJsonDocument oJ = QJsonDocument::fromJson(oc);
  QJsonObject ocJson = oJ.object();
  auto js = ocJson["responseData"];

  if (js.isNull() == true)
  {
    m_pErrorTextField->setProperty("text", "Error in translation");
    m_pErrorTextField->setProperty("visible", true);
  }
  else
  {
    m_pErrorTextField->setProperty("visible", false);
    QTextDocument text;
    text.setHtml(js.toObject()["translatedText"].toString());
    m_sTranslatedText->setProperty("text", text.toPlainText());
  }

  QObject* pO = qvariant_cast<QObject*>(pReply->property("button"));
  pO->setProperty("bProgVisible", false);
  QString sLang = pReply->property("tolang").toString();
  if (sLang != "ru" && sLang != "en")
  {
    auto addText = [](const QJsonValue& s) { return "<tr><text>" + s.toString() + "</text></tr>"; };

    static QString sDictXmlBegin("<DicResult><def>");
    static QString sDictXmlEnd("</def></DicResult>");
    QJsonArray jsMatches = ocJson["matches"].toArray();
    QString sDictXml(sDictXmlBegin);
    for (const auto& oI : jsMatches)
    {
      sDictXml.append(addText(oI.toObject()["translation"]));
    }
    sDictXml.append(sDictXmlEnd);
    m_pTrTextModel->setProperty("xml", sDictXml);
    m_pTrSynModel->setProperty("xml", "");
    m_pTrMeanModel->setProperty("xml", "");
  }

  pReply->deleteLater();
}

void Speechdownloader::translateWord(QString sWord, QString sFromLang, QString sToLang,
                                     QObject* pBtn)
{
  QString sFmt = "https://api.mymemory.translated.net/"
                 "get?q=%ls&mt=1&langpair=%ls|%ls&de=faxling11@gmail.com";

  QString sUrl =
      QString::asprintf(sFmt.toLatin1(), sWord.utf16(), sFromLang.utf16(), sToLang.utf16());

  QNetworkRequest request(sUrl);
  QNetworkReply* pNR = m_oTransNetMgr.get(request);
  pNR->setProperty("button", QVariant::fromValue(pBtn));
  pNR->setProperty("tolang", sToLang);
  QObject::connect(pNR, &QNetworkReply::finished, this, &Speechdownloader::transDownloaded);
}

int Speechdownloader::NumberRole(QAbstractItemModel* pp)
{
  auto oc = pp->roleNames();
  QByteArray sNumber("number");
  for (auto oI = oc.begin(); oI != oc.end(); ++oI)
  {
    if (oI.value() == sNumber)
    {
      return oI.key();
    }
  }
  return -1;
}

int Speechdownloader::indexFromGlosNr(QVariant p, int nNr)
{
  QAbstractItemModel* pp = qvariant_cast<QAbstractItemModel*>(p);

  int nC = pp->rowCount();
  int nR = NumberRole(pp);
  for (int i = 0; i < nC; i++)
  {
    int nVal = pp->data(pp->index(i, 0), nR).toInt();
    if (nVal == nNr)
      return i;
  }

  return -1;
}

void Speechdownloader::showKey(bool b)
{
  QInputMethod* keyboard = QGuiApplication::inputMethod();
  if (b == true)
    keyboard->show();
  else
    keyboard->hide();
}

double Speechdownloader::rand()
{
  static std::mt19937 gen(time(0));
  static std::uniform_real_distribution<> dis(0, 1.0);
  double d = dis(gen);
  return d;
}

void Speechdownloader::pushIndex(int nI)
{
  if (m_bSkipNextPush)
  {
    m_bSkipNextPush = false;
    return;
  }
  if (m_ocIndexStack.isEmpty() == false)
  {
    // No use to push 2 equalas
    if (m_ocIndexStack.last() == nI)
      return;
  }

  m_ocIndexStack.push_back(nI);
}

bool Speechdownloader::isStackEmpty()
{
  return m_ocIndexStack.isEmpty();
}

int Speechdownloader::popIndex()
{
  if (m_ocIndexStack.isEmpty())
    return -1;

  m_bSkipNextPush = true;

  return m_ocIndexStack.takeLast();
}

void Speechdownloader::storeTransText(QObject* p, QObject* pErrorTextField, QObject* pTrTextModel,
                                      QObject* pTrSynModel, QObject* pTrMeanModel)
{
  m_pErrorTextField = pErrorTextField;
  m_sTranslatedText = p;
  m_pTrTextModel = pTrTextModel;
  m_pTrSynModel = pTrSynModel;
  m_pTrMeanModel = pTrMeanModel;
}

void Speechdownloader::storeTextInputField(int n, QObject* p)
{
  m_ocTextInputElem[n] = p;
}

void Speechdownloader::focusOnQuizText(int n)
{
  auto i = m_ocTextInputElem.find(n);
  if (i == m_ocTextInputElem.end())
    return;

  for (auto oI : m_ocTextInputElem)
    oI->setProperty("text", "");

  QObject* pTI = i.value(); // TextInput

  if (pTI->property("visible").toBool() == true)
  {
    QMetaObject::invokeMethod(pTI, "forceActiveFocus");
  }
}
