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

static const QString GLOS_SERVER2("http://212.112.183.157");
static const QString GLOS_SERVER1("http://192.168.2.1");

Speechdownloader::Speechdownloader(const QString& sStoragePath, QObject *pParent ) :  QObject(pParent)
{
  QObject::connect(&m_oQuizExpNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizExported);
  QObject::connect(&m_oQuizNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizDownloaded);
  QObject::connect(&m_oListQuizNetMgr, &QNetworkAccessManager::finished, this, &Speechdownloader::listDownloaded);
  QObject::connect(&m_oDeleteQuizNetMgr, &QNetworkAccessManager::finished,this, &Speechdownloader::quizDeleted);
  m_sStoragePath = sStoragePath;
}

class WordDownloadRecv : public QObject
{
public:
  WordDownloadRecv(const QString& sWordPath, bool bPlayAfterDownload)
  {
    m_sWordPath = sWordPath;
    m_bPlayAfterDownload = bPlayAfterDownload;
  }
  void wordDownloaded(QNetworkReply* pReply)
  {
    QByteArray oDownloadedData = pReply->readAll();

    if (oDownloadedData.size() < 1000)
      return;
    QFile oWav(m_sWordPath);
    oWav.open(QIODevice::ReadWrite);
    oWav.write(oDownloadedData);
    oWav.close();

    if (m_bPlayAfterDownload == true)
    {
      QSound::play(m_sWordPath);
    }
    delete this;
  }
  QString m_sWordPath;
  bool m_bPlayAfterDownload;
};

QString Speechdownloader::AudioPath(const QString& s, const QString& sLang)
{
  if (sLang.isEmpty())
    return (m_sStoragePath ^ s ) + ".wav";
  return (m_sStoragePath ^ s ) + "_" + sLang + ".wav";
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
    emit exportedSignal(pReply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt());
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
  for ( auto oI : ocJson)
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



QString sVoicetechFr(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&r=2&hl=fr-fr&src="));
QString sVoicetechSe(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=sv-se&src="));
QString sVoicetechIt(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=it-it&src="));
QString sVoicetechDe(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=de-de&src="));
QString sVoicetechPl(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=pl-pl&src="));
QString sVoicetechEs(QStringLiteral("http://api.voicerss.org/?key=0f8ca674a1914587918727ad03cd0aaf&f=44khz_16bit_mono&hl=es-es&src="));

void Speechdownloader::playWord(QString sWord,QString sLang)
{
  QString sFileName = AudioPath(sWord,sLang);
  QFileInfo oWavFile(sFileName);
  if (oWavFile.size() > 10000)
  {
    QSound::play(sFileName);
  }
  else
  {
    m_bPlayAfterDownload = true;
    downloadWord(sWord,sLang);
  }
}


void Speechdownloader::deleteWord(QString sWord, QString sLang)
{

  if (QFile::exists(AudioPath(sWord, sLang)))
    QFile::remove(AudioPath(sWord, sLang));

}

void Speechdownloader::downloadWord(QString sWord, QString sLang)
{
  static QMap<QString, QString> ocUrlMap{ { "ru", sVoicetechRu }, { "en", sVoicetechEn }, { "sv", sVoicetechSe }, { "fr", sVoicetechFr }, { "pl", sVoicetechPl }, { "de", sVoicetechDe },{"it",sVoicetechIt}, { "es", sVoicetechEs } };
  QObject::connect(&m_oWordNetMgr, &QNetworkAccessManager::finished, new WordDownloadRecv(AudioPath(sWord,sLang),m_bPlayAfterDownload), &WordDownloadRecv::wordDownloaded);
  m_bPlayAfterDownload = false;
  QNetworkRequest request(ocUrlMap[sLang] + sWord);
  m_oWordNetMgr.get(request);
}


void  Speechdownloader::listQuiz()
{
  QNetworkRequest request(QUrl(GLOS_SERVER2 ^ "quizlist.php"));
  m_oListQuizNetMgr.get(request);
}

/*
answer
extra
question
*/
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
    QFile oWav(AudioPath(s,""));
    oWav.open(QIODevice::ReadWrite);
    oWav.write(oc);
    oWav.close();
  }

  emit quizDownloadedSignal(oDataDownloaded.size(), oDataDownloaded, sLang);
}

void Speechdownloader::deleteQuiz(QString sName, QString sPwd, QString nDbId)
{
  QString sUrl = GLOS_SERVER2 ^ ("deletequiz.php?qname="+sName+"&qpwd="+sPwd+"&dbid="+ nDbId);
  QNetworkRequest request(sUrl);
  m_oDeleteQuizNetMgr.get(request);
}

void Speechdownloader::importQuiz(QString sName)
{
  QString sUrl = GLOS_SERVER2 ^ ("quizload.php?qname="  + sName + ".txt");
  QNetworkRequest request(sUrl);
  m_oQuizNetMgr.get(request);
}


// {"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE, "state1" : rs.rows.item(i).state }
//0 answer
//1 extra
//2 number
//3 question
//4 state

void Speechdownloader::exportCurrentQuiz(QVariant p, QString sName, QString sLang,  QString sPwd,QString sDesc)
{
  QAbstractListModel* pp = qvariant_cast<QAbstractListModel*>(p);
  QByteArray ocArray;
  QDataStream  ss(&ocArray, QIODevice::WriteOnly);
  QStringList ocAudio;
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
    if (QFile::exists(AudioPath(sWord, ocLang[0])))
      ocAudio.append(sWord + "_" + ocLang[0]);
    sWord = pp->data(pp->index(i), 2).toString();
    if (QFile::exists(AudioPath(sWord, ocLang[1])))
      ocAudio.append(sWord  + "_" + ocLang[1]);

  }

  ss << ocAudio.size();
  for (auto& oI : ocAudio)
  {
    QFile oF(AudioPath(oI,""));
    ss << oI;
    oF.open(QIODevice::ReadOnly);
    ss << oF.readAll();
    oF.close();
  }
  QString sFmt = GLOS_SERVER2 ^ "store.php?qname=%ls&slang=%ls&qcount=%d&desc1=%ls&pwd=%ls";
  QString sUrl = QString::asprintf(sFmt.toLatin1(), sName.utf16(), sLang.utf16(), nC,sDesc.utf16(), sPwd.utf16() );
  qDebug() << " size " << ocArray.size();

  QNetworkRequest request(sUrl);
  request.setRawHeader("Content-Type", "application/octet-stream");
  request.setRawHeader("Content-Length", QByteArray::number(ocArray.size()));
  m_oQuizExpNetMgr.post(request, ocArray);

}
