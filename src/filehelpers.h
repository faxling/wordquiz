#ifndef FILEHELPERS_H
#define FILEHELPERS_H
#include <QString>
QString operator ^ (const QString &s, const QString &s2);
class QElapsedTimer;
class StopWatch
{
public:
  // Use %1 for time
  StopWatch(const QString& sMsg);
  StopWatch();
  ~StopWatch();
  void Pause();
  void Continue();
  void Stop();
  double StopTimeSec();

private:
  bool m_bMsgPrinted = false;
  QString m_sMsg;
  QElapsedTimer* m_oTimer;
};


 QString JustFileNameNoExt(const QString & sFileName);
#endif // FILEHELPERS_H
