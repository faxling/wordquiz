#include "filehelpers.h"

#include <QRegExp>

QString operator^(const QString &sIn, const QString &s2In)
{
  QString s(sIn), s2(s2In);
  int nLen1 = s.length() - 1;
  int nLen2 = s2.length() - 1;
  bool bIsBack = true;
  static const QRegExp SLASH("[\\\\/]");
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

