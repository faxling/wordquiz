﻿#include "speechdownloader.h"
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


// Faxling     Raggo100 trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f

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
  qDebug() << "WordQuiz StoragePath: " << m_sStoragePath;
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
QString Speechdownloader::ignoreAccentLC(QString str)
{
  static QString sssIn = QString::fromWCharArray(L"íîàáâãäåèéêëòóôõõöùúûç");
  static QString sssOut = QString::fromWCharArray(L"iiaaaaaaeeeeoooooouuuc");
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
QString Speechdownloader::ignoreAccent(QString str)
{
  static QString sssIn = QString::fromWCharArray(L"ÍÎÀÁÂÃÄÅÈÉÊËÒÓÔÕÕÖÙÚÛÇ");
  static QString sssOut = QString::fromWCharArray(L"IIAAAAAAEEEEOOOOOOUUUC");
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

QString Speechdownloader::dateStr()
{
  const wchar_t* szFormat = L"%Y-%m-%d  %H:%M";
  wchar_t szStr[20];
  time_t tNow = time(0);
  wcsftime(szStr, 20, szFormat, localtime(&tNow));
  return  QString::fromWCharArray(szStr);
}

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

QUrl Speechdownloader::imageSrc(QString sWord, QString sLang)
{
  return QUrl::fromLocalFile(ImgPath(sWord, sLang));
}

void Speechdownloader::checkAndEmit(QString sPath1, QString sPath2)
{
  if (m_sImgPath == sPath1 || m_sImgPath == sPath2)
  {
    if (m_bHasImg == true)
    {
      m_oImgUrl = QUrl();
      emit urlImgChanged();
    }
    else {
      m_bHasImg = true;
      emit hasImgChanged();
    }
    m_oImgUrl = QUrl::fromLocalFile(m_sImgPath);
    emit urlImgChanged();
  }
}

void Speechdownloader::setImgFile(QString sWord, QString sLang, QString sWord2, QString sLang2, QString sImgFilePath)
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


bool Speechdownloader::hasImage(QString sWord, QString sLang)
{
  if (sWord.isEmpty())
    return false;
  if (sLang.isEmpty())
    return false;

  QString s = ImgPath(sWord, sLang);
  return  QFile::exists(s);
}


bool Speechdownloader::hasImg()
{
  return m_bHasImg;
}

QUrl Speechdownloader::urlImg()
{
  return m_oImgUrl;
}

void Speechdownloader::imgDownloaded(QNetworkReply* pReply)
{
  m_oDownloadedData = pReply->readAll();

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

  checkAndEmit(sFileName, sImg2);

  if (uQ.queryItemValue("emit").toInt() == 1)
  {
    emit downloadedImgSignal();
  }

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

struct QuizInfo
{
  QString qname;
  QString desc1;
  QString slang;
  QString qcount;
};

void Speechdownloader::listDownloaded(QNetworkReply* pReply)
{
  QByteArray oc = pReply->readAll();
  QJsonDocument oJ = QJsonDocument::fromJson(oc);

  QJsonArray ocJson = oJ.array();

  // m_ocIndexMap.clear();

  QList<QuizInfo> ocQuizInfo;

  for (auto oI : ocJson)
  {
    //   id, desc1, slang, qcount,qname
    QJsonArray oJJ = oI.toArray();
    QuizInfo t;
    t.desc1 = oJJ[1].toString();
    t.slang = oJJ[2].toString();
    t.qcount = oJJ[3].toString();
    t.qname = oJJ[4].toString();
    ocQuizInfo.push_back(t);
  }

  std::sort(ocQuizInfo.begin(),ocQuizInfo.end(), [](const QuizInfo& t1, const QuizInfo& t2)
  {
    QString s1 = t1.slang;
    QString s2 = t2.slang;
    std::sort(s1.begin(), s1.end());
    std::sort(s2.begin(), s2.end());
    if (s1 == s2)
      return t1.qname < t2.qname;
    return s1 < s2;
  }
  );


  QStringList ocL;
  for (auto oI : ocQuizInfo)
  {
    ocL.append(oI.qname);
    ocL.append(oI.desc1);
    ocL.append(oI.slang);
    ocL.append(oI.qcount);
    /*
                        "qname"
                        "desc1"
                        "slang"
                        "qcount
                        */
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
    qDebug() << "Download " << sWord;
    downloadWord(sWord, sLang);
  }
}

void Speechdownloader::deleteWord(QString sWord, QString sLang)
{

  if (QFile::exists(AudioPath(sWord, sLang)))
    QFile::remove(AudioPath(sWord, sLang));

}

void Speechdownloader::downloadImageSlot(const QList<QUrl>& vImgUrl, QString sWord, QString sLang, QString sWord2, QString sLang2, bool bEmitlDownloaded)
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
  static QMap<QString, QString> ocUrlMap{ { "no", sVoicetechNo }, { "ru", sVoicetechRu }, { "en", sVoicetechEn }, { "sv", sVoicetechSe }, { "fr", sVoicetechFr }, { "pl", sVoicetechPl }, { "de", sVoicetechDe }, { "it", sVoicetechIt }, { "es", sVoicetechEs } };

  QString sUrl = ocUrlMap[sLang] + sWord;
  if (m_bPlayAfterDownload == true)
    sUrl += "&PlayAfterDownload=1";
  m_bPlayAfterDownload = false;
  QNetworkRequest request(sUrl);
  m_oWordNetMgr.get(request);
}

void  Speechdownloader::listQuizLang(QString sLang)
{
  QString sUrl = (GLOS_SERVER2 ^ "quizlist_lang.php?qlang=") + sLang;
  QNetworkRequest request(sUrl);
  m_oListQuizNetMgr.get(request);
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


void Speechdownloader::sortRowset(QJSValue p0, QJSValue p1 , int nCount, QJSValue jsArray)
{
  struct QI_i
  {
    int nNr;
    QString sLangPair;
    QString sQname;
  };

  QList<QI_i> ocQuizInfo;

  for (int i = 0 ; i < nCount ; ++i)
  {
    QJSValueList oParList {i};
    auto oFullItem = p0.callWithInstance(p1, oParList);
    QI_i tItem;
    tItem.nNr = i;
    tItem.sLangPair = oFullItem.property("langpair").toString();
    tItem.sQname = oFullItem.property("quizname").toString();
    ocQuizInfo.push_back(tItem);
  }

  std::sort(ocQuizInfo.begin(),ocQuizInfo.end(), [](const QI_i& t1, const QI_i& t2)
  {
    QString s1 = t1.sLangPair;
    QString s2 = t2.sLangPair;
    std::sort(s1.begin(), s1.end());
    std::sort(s2.begin(), s2.end());
    if (s1 == s2)
      return t1.sQname < t2.sQname;
    return s1 < s2;
  }
  );

  for (int i = 0 ; i < nCount ; ++i)
  {
    jsArray.setProperty(i, ocQuizInfo[i].nNr);
  }

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
  }

  QString sFmt = GLOS_SERVER2 ^ "%ls.php?qname=%ls&slang=%ls&qcount=%d&desc1=%ls&pwd=%ls";
  QString sUrl = QString::asprintf(sFmt.toLatin1(), sCmd.utf16(), sName.utf16(), sLang.utf16(), nC, sDesc.utf16(), sPwd.utf16());
  qDebug() << "Cmd to glosserver " << sCmd << " size " << ocArray.size();
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


void Speechdownloader::pushIndex(int nI)
{
  if (m_ocIndexStack.isEmpty() == false)
  {
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

  return m_ocIndexStack.takeLast();
}


void Speechdownloader::startTimer()
{
  m_pStopWatch = new StopWatch("timing %1");
}


void Speechdownloader::storeTextInputField(QObject* p)
{
  m_ocTextInputElem.push_back(p);
}

void Speechdownloader::storeCurrentIndex(int n)
{
  m_ocTextInputElem[n]->setProperty("text","");
  if (m_ocTextInputElem[n]->property("visible").toBool() == true)
    QMetaObject::invokeMethod(m_ocTextInputElem[n], "forceActiveFocus");
}

void Speechdownloader::stopTimer()
{
  delete m_pStopWatch;
  m_pStopWatch = nullptr;
}
