#include "filehelpers.h"

#include <QDebug>
#include <QElapsedTimer>
#include <QRegExp>

StopWatch::StopWatch(const QString& sMsg)
{
  m_oTimer = new QElapsedTimer;
  m_sMsg = sMsg;
  m_oTimer->start();
  return;
}

StopWatch::StopWatch()
{
  m_oTimer = new QElapsedTimer;
  m_oTimer->start();
  m_bMsgPrinted = true;
  return;
}

StopWatch::~StopWatch()
{
  // Only print in destructtor if Stop not called
  if (m_bMsgPrinted == false)
  {
    qint64 nanoSec = m_oTimer->nsecsElapsed();
    double fTime = (nanoSec) / 1000000.0; // milliseconds

    QString sMsg(m_sMsg.arg(fTime));
    qDebug() << sMsg;
  }
  delete m_oTimer;
}

double StopWatch::StopTimeSec()
{
  qint64 nanoSec = m_oTimer->nsecsElapsed();
  return (nanoSec) / 1000000000.0;
}

void StopWatch::Stop()
{
  qint64 nanoSec = m_oTimer->nsecsElapsed();
  double fTime = (nanoSec) / 1000000.0; // milliseconds

  QString sMsg(m_sMsg.arg(fTime));
  m_bMsgPrinted = true;
  qDebug() << sMsg;
}

void StopWatch::Pause()
{
  // FIXTIT
}

void StopWatch::Continue()
{
  // FIXTIT
}

static const QRegExp SLASH("[\\\\/]");
QString JustFileName(const QString& sFileName)
{
  int n = sFileName.lastIndexOf(SLASH);
  if (n < 0)
    return sFileName;
  return sFileName.right(sFileName.size() - n - 1);
}

QString BaseName(const QString& sFileName)
{
  return sFileName.left(sFileName.lastIndexOf('.'));
}

QString JustFileNameNoExt(const QString& sFileName)
{
  return BaseName(JustFileName(sFileName));
}

QString operator^(const QString& sIn, const QString& s2In)
{
  QString s(sIn), s2(s2In);
  int nLen1 = s.length() - 1;
  int nLen2 = s2.length() - 1;
  bool bIsBack = true;

  // use  the last dir separator if we need to append
  int nSP = sIn.indexOf(SLASH);
  if (nSP >= 0)
    if (sIn[nSP] == '/')
      bIsBack = false;

  if (nLen1 == -1 && nLen1 == -2)
  {
    return "";
  }

  if (nLen2 == -1)
  {
    if (s[nLen1] == '\\' || s[nLen1] == '/')
      s.remove(nLen1, 1);

    return s;
  }

  if (nLen1 == -1)
    return s2;

  if (s[nLen1] == '\\' || s[nLen1] == '/')
    s.remove(nLen1, 1);

  if (s2[0] == '\\' || s[nLen1] == '/')
    s2.remove(0, 1);

  if (bIsBack == true)
    return s + "\\" + s2;
  else
    return s + "/" + s2;
}
