#include "speechdownloader.h"
#include <QDebug>
#include <QFile>
#include "filehelpers.h"
#include <QSound>

Speechdownloader::Speechdownloader(const QString& sStoragePath) : QObject(nullptr)
{
    connect(&m_oWebCtrl, SIGNAL(finished(QNetworkReply*)),
            SLOT(fileDownloaded(QNetworkReply*)));

    m_sStoragePath = sStoragePath;
}

void Speechdownloader::fileDownloaded(QNetworkReply* pReply)
{
    m_oDownloadedData = pReply->readAll();
    QString sFileName = (m_sStoragePath ^ m_sWord) + ".wav";
    QFile oWav(sFileName);
    oWav.open(QIODevice::ReadWrite);
    oWav.write(m_oDownloadedData);
    emit downloaded();
    oWav.close();

    if (m_bPlayAfterDownload == true)
    {
        QSound::play(sFileName);
    }
}

QString sVoicetechRu(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=ru_RU&format=wav&speaker=oksana&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));
QString sVoicetechEn(QStringLiteral("http://tts.voicetech.yandex.net/generate?lang=en_EN&format=wav&speaker=oksana&key=6372dda5-9674-4413-85ff-e9d0eb2f99a7&text="));


void Speechdownloader::playWord(QString sWord,QString sLang)
{
    QString sFileName = (m_sStoragePath ^ sWord) + ".wav";
    if (QFile::exists(sFileName) == true)
        QSound::play(sFileName);
    else
    {
        downloadWord(sWord,sLang);
        m_bPlayAfterDownload = true;
    }
}

void Speechdownloader::downloadWord(QString sWord, QString sLang)
{
    m_bPlayAfterDownload = false;
    m_sWord = sWord;
    QString sUrl = sLang == "ru" ? sVoicetechRu : sVoicetechEn;
    QNetworkRequest request(sUrl+sWord);
    m_oWebCtrl.get(request);
}
