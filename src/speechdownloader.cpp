#include "speechdownloader.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include "filehelpers.h"
#include <QSound>
#include <QDataStream>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QAbstractListModel>
#include <QGuiApplication>
#include <QClipboard>
#include <QUrlQuery>
#include <QImage>
#include <QImageReader>
#include <QBuffer>
#include <QUrl>
/// Faxling     Raggo100 trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f

// https://cloud.yandex.com/docs/speechkit/tts/request
// https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&text=groda&lang=sv-ru
// dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739

// speaker=<jane|oksana|alyss|omazh|zahar|ermil>
//http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=ermil&text=да&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7

//https://dictionary.yandex.net/api/v1/dicservice/getLangs?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739


static const QString GLOS_SERVER2("http://212.112.183.157/glosquiz");
static const QString GLOS_SERVER1("http://192.168.2.1");

Speechdownloader::Speechdownloader(const QString& sStoragePath, QObject *pParent) : QObject(pParent)
{
  QObject::connect(&m_oImgNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::imgDownloaded);
  QObject::connect(&m_oWordNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::wordDownloaded);
  QObject::connect(&m_oQuizExpNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::quizExported);
  QObject::connect(&m_oQuizNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::quizDownloaded);
  QObject::connect(&m_oListQuizNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::listDownloaded);
  QObject::connect(&m_oDeleteQuizNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::quizDeleted);
  m_sStoragePath = sStoragePath;
  QSound::play("qrc:welcome_en.wav");
  m_pStopWatch = nullptr;

}

static const QString sReqDictUrlBase = "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=";
static const QString sReqDictUrl = "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text=";
static const QString sReqDictUrlRev = "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=ru-sv&text=";
static const QString sReqDictUrlEn = "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=en-ru&text=";
static const QString sReqUrlBase = "https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang=";


void Speechdownloader::initUrls(QVariant p)
{

  QObject* pp = qvariant_cast<QObject*>(p);
  pp->setProperty("sReqDictUrlBase", sReqDictUrlBase);
  pp->setProperty("sReqDictUrl", sReqDictUrl);
  pp->setProperty("sReqDictUrlRev", sReqDictUrlRev);
  pp->setProperty("sReqDictUrlEn", sReqDictUrlEn);
  pp->setProperty("sReqUrlBase", sReqUrlBase);

}

void Speechdownloader::setImgWord(QString sWord, QString sLang)
{
  QString s = ImgPath(sWord, sLang);
  bool bEx = QFile::exists(s);


  if (bEx == true)
    m_oImgPath = QUrl::fromLocalFile(s);
  else
    m_oImgPath = QUrl();


  if (bEx != m_bHasImg)
  {
    m_bHasImg = bEx;
    emit hasImgChanged();
  }

  emit urlImgChanged();

}

bool Speechdownloader::hasImage(QString sWord, QString sLang)
{
  QString s = ImgPath(sWord, sLang);
  bool bEx = QFile::exists(s);

}


bool Speechdownloader::hasImg()
{
  return m_bHasImg;
}

QUrl Speechdownloader::urlImg()
{
  return m_oImgPath;
}



void Speechdownloader::imgDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();

  if (m_oDownloadedData.size() < 5000)
    return;
  QString sCT = pReply->header(QNetworkRequest::ContentTypeHeader).toString();
  if ( sCT.contains("image") == false)
    return;
  QUrlQuery uQ(pReply->url());
  QString sWord, sLang;

  sWord = uQ.queryItemValue("text");
  sLang = uQ.queryItemValue("lang");

  QString sFileName = ImgPath(sWord, sLang);
  QBuffer oBuff(&m_oDownloadedData);
  QImageReader oImageReader(&oBuff);
  oImageReader.setAutoTransform(true);
  QImage oImage = oImageReader.read();
  QImage oImageScaled = oImage.scaledToHeight(128);
  oImageScaled.save(sFileName);
  setImgWord(sWord, sLang);
}

void Speechdownloader::wordDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();

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
  return (m_sStoragePath ^ s) + "_" + sLang + ".wav";
}


QString Speechdownloader::ImgPath(const QString& s, const QString& sLang)
{
  if (sLang.isEmpty())
    return (m_sStoragePath ^ s) + ".jpg";
  return (m_sStoragePath ^ s) + "_" + sLang + ".jpg";
}

void Speechdownloader::quizDeleted(QNetworkReply* pReply)
{
  int nRet = pReply->error();
  QString oc = QString(pReply->readAll());
  if (nRet == QNetworkReply::NoError)
    emit deletedSignal(oc.toInt());
  else
    emit deletedSignal(-1);
}

void Speechdownloader::quizExported(QNetworkReply* pReply)
{
  int nRet = pReply->error();

  if (nRet == QNetworkReply::NoError)
    emit exportedSignal(pReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt());
  else
    emit exportedSignal(0);

}


void Speechdownloader::listDownloaded(QNetworkReply* pReply)
{
  QByteArray oc = pReply->readAll();
  QJsonDocument oJ = QJsonDocument::fromJson(oc);

  QJsonArray ocJson = oJ.array();
  QStringList ocL;
  m_ocIndexMap.clear();
  for (auto oI : ocJson)
  {
    // `ID`,  desc1`, `slang`,  `qcount`,  `pwd`,  `qname`
    QJsonArray oJJ = oI.toArray();
    ocL.append(oJJ[4].toString());
    ocL.append(oJJ[1].toString());
    ocL.append(oJJ[2].toString());
    ocL.append(oJJ[3].toString());
    /*
    "qname"
    "desc1"
    "slang"
    "qcount
    */
    m_ocIndexMap.append(oJJ[0].toInt());
  }

  emit quizListDownloadedSignal(ocL.size(), ocL);

}



//  https://cloud.yandex.com/docs/speechkit/tts/request
QString sVoicetechRu(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=oksana&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));
QString sVoicetechEn(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=en_EN&format=wav&speaker=oksana&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));



QString sVoicetechFr(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&r=2&hl=fr-fr&src="));
QString sVoicetechSe(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=sv-se&src="));
QString sVoicetechNo(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=nb-no&src="));
QString sVoicetechIt(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=it-it&src="));
QString sVoicetechDe(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=de-de&src="));
QString sVoicetechPl(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=pl-pl&src="));
QString sVoicetechEs(QStringLiteral("http://api.voicerss.org?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=es-es&src="));

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

void Speechdownloader::downloadImage(const QList<QUrl>& vImgUrl, QString sWord, QString sLang)
{
  if (vImgUrl.count() < 1)
    return;
  QUrl u = vImgUrl.first();
  QUrlQuery oQuery(u.query());
  oQuery.addQueryItem("text", sWord);
  oQuery.addQueryItem("lang", sLang);
  u.setQuery(oQuery);
  QNetworkRequest request(u);
  m_oImgNetMgr.get(request);
}


void Speechdownloader::downloadWord(QString sWord, QString sLang)
{
  static QMap<QString, QString> ocUrlMap{ { "no", sVoicetechNo }, { "ru", sVoicetechRu }, { "en", sVoicetechEn }, { "sv", sVoicetechSe }, { "fr", sVoicetechFr }, { "pl", sVoicetechPl }, { "de", sVoicetechDe }, { "it", sVoicetechIt }, { "es", sVoicetechEs } };

  QString sUrl = ocUrlMap[sLang] + sWord;
  if (m_bPlayAfterDownload == true)
    sUrl += "&PlayAfterDownload=1";
  m_bPlayAfterDownload = false;
  QNetworkRequest request(sUrl);
  m_oWordNetMgr.get(request);
}


void  Speechdownloader::listQuiz()
{
  QNetworkRequest request(QUrl(GLOS_SERVER2 ^ "quizlist.php"));
  m_oListQuizNetMgr.get(request);
}


void Speechdownloader::quizDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();
  QVariantList oDataDownloaded;
  if (m_oDownloadedData.size() < 1000)
  {
    emit quizDownloadedSignal(-1, oDataDownloaded, "");
    return;
  }
  QDataStream  ss(&m_oDownloadedData, QIODevice::ReadOnly);
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

void Speechdownloader::deleteQuiz(QString sName, QString sPwd, QString nDbId)
{
  QString sUrl = GLOS_SERVER2 ^ ("deletequiz.php?qname=" + sName + "&qpwd=" + sPwd + "&dbid=" + nDbId);
  QNetworkRequest request(sUrl);
  m_oDeleteQuizNetMgr.get(request);
}

void Speechdownloader::importQuiz(QString sName)
{
  QString sUrl = GLOS_SERVER2 ^ ("quizload.php?qname=" + sName + ".txt");
  QNetworkRequest request(sUrl);
  m_oQuizNetMgr.get(request);
}

void Speechdownloader::toClipBoard(QString s)
{
  QGuiApplication::clipboard()->setText(s);
}


void Speechdownloader::downLoadAllSpeech(QVariant p, QString sLang)
{
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  QStringList ocLang = sLang.split("-");
  int nC = pp->rowCount();
  for (int i = 0; i < nC; i++)
  {
    QString sAnswer = pp->data(pp->index(i), 0).toString();
    QString sQuestion = pp->data(pp->index(i), 3).toString();
    downloadWord(sQuestion, ocLang[0]);
    downloadWord(sAnswer, ocLang[1]);
  }
}

void Speechdownloader::updateCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd, QString sDesc)
{
  currentQuizCmd(p, sName, sLang, sPwd, sDesc, "updatequiz");
}

void Speechdownloader::exportCurrentQuiz(QVariant p, QString sName, QString sLang, QString sPwd, QString sDesc)
{
  currentQuizCmd(p, sName, sLang, sPwd, sDesc, "store");
}
// {"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE, "state1" : rs.rows.item(i).state }
//0 answer
//1 extra
//2 number
//3 question
//4 state

void Speechdownloader::currentQuizCmd(QVariant p, QString sName, QString sLang, QString sPwd, QString sDesc, QString sCmd)
{
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  QByteArray ocArray;
  QDataStream  ss(&ocArray, QIODevice::WriteOnly);
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
    QString sWord = pp->data(pp->index(i), 0).toString();
    if (QFile::exists(AudioPath(sWord, ocLang[1])))
      ocAudio.append(sWord + "_" + ocLang[1]);
    sWord = pp->data(pp->index(i), 3).toString();
    if (QFile::exists(AudioPath(sWord, ocLang[0])))
      ocAudio.append(sWord + "_" + ocLang[0]);
    if (QFile::exists(ImgPath(sWord, ocLang[0])))
      ocImg.append(sWord + "_" + ocLang[0]);
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
  }

  QString sFmt = GLOS_SERVER2 ^ "%ls.php?qname=%ls&slang=%ls&qcount=%d&desc1=%ls&pwd=%ls";
  QString sUrl = QString::asprintf(sFmt.toLatin1(), sCmd.utf16(), sName.utf16(), sLang.utf16(), nC, sDesc.utf16(), sPwd.utf16());
  qDebug() << " size " << ocArray.size();
  ss.setVersion(2);
  QNetworkRequest request(sUrl);
  request.setRawHeader("Content-Type", "application/octet-stream");
  request.setRawHeader("Content-Length", QByteArray::number(ocArray.size()));
  m_oQuizExpNetMgr.post(request, ocArray);
}

int Speechdownloader::NumberRole(QAbstractListModel* pp)
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
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  int nC = pp->rowCount();
  int nR = NumberRole(pp);
  for (int i = 0; i < nC; i++)
  {
    int nVal = pp->data(pp->index(i), nR).toInt();
    if (nVal == nNr)
      return i;
  }

  return -1;
}

void Speechdownloader::startTimer()
{
  m_pStopWatch = new StopWatch("timing %1");
}
void Speechdownloader::stopTimer()
{
  delete m_pStopWatch;
  m_pStopWatch = nullptr;
}
