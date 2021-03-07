
#include "QImage"
#include "QPainter"
#include "QDebug"
#include "QMutex"
#include "svgdrawing.h"
#include <QDomElement>
#include <QDomDocument>
#include "filehelpers.h"

SvgDrawing::SvgDrawing()
{
  QFile file(":/gubbe.svg");
  file.open(QIODevice::ReadOnly);
  QByteArray oSvgXml = file.readAll();
  // "path839", "path839-4"  path893
  m_oSvgIds = {"path817", "path946","path946-6","path946-3", "path946-0", "path881","path883", "path887", "path889", "path887-0", "path887-0-8","path891",  "path839-4","path893", "path839"};
  m_oSvgHIds = {"path891-8", "path881","path893", "path839","path839-4" };
  file.close();
  m_oSvg.setViewBox(QRect(0,0,200,200));
  m_oDomSvg.setContent(oSvgXml);
  auto oSvgE = m_oDomSvg.elementsByTagName("svg");
  QDomNode oSvgNodes = oSvgE.item(0);
  QDomNode n = oSvgNodes.firstChild();
  while (n.isNull() == false) {
    QDomNode oId = n.attributes().namedItem("id");
    if (oId.isNull() == false)
    {
      QDomNode oStyle = n.attributes().namedItem("style");
      if (oStyle.isNull() == false)
      {
        QString sId = oId.nodeValue();
        auto ocAtt = oStyle.nodeValue().split(';');
        SMap_t attrMap;
        for (auto& oI : ocAtt)
        {
          auto sl = oI.split(':');
          attrMap[sl[0]] = sl[1];
        }

        m_ocStyleMap[sId] = { attrMap, oStyle };
      }
    }
    n = n.nextSibling();
  }
  renderId(0);
}



void SvgDrawing::setOpacityOnId(const QString& id, const QString& op)
{
  auto tS = m_ocStyleMap.find(id);
  if (tS == m_ocStyleMap.end())
    return;

  auto& tSS = tS->first;
  tS->first["opacity"] = op;
  QString sStyle;
  for (auto oI = tSS.begin(); oI != tSS.end(); ++oI)
  {
    if (oI != tSS.begin())
      sStyle += ";";
    sStyle += (oI.key() + ":" + oI.value());
  }
  tS->second.setNodeValue(sStyle);
}

bool SvgDrawing::renderId(int sId)
{
  bool bRet = true;
  if (sId == 0)
  {
    m_nIndex = 0;
    for (auto& oI : m_oSvgIds)
      setOpacityOnId(oI,"0");

    for (auto& oI : m_oSvgHIds)
      setOpacityOnId(oI,"1");

  }
  else if (sId == 1)
  {
    m_nIndex = 0;
    for (auto& oI : m_oSvgIds)
      setOpacityOnId(oI,"0");
    setOpacityOnId("path891-8","0");

  }
  else if (sId == 2)
  {
    setOpacityOnId(m_oSvgIds[m_nIndex],"1");
    if (m_nIndex == m_oSvgIds.size()- 4)
    {
      setOpacityOnId(m_oSvgIds[++m_nIndex],"1");
      setOpacityOnId(m_oSvgIds[++m_nIndex],"1");
      setOpacityOnId(m_oSvgIds[++m_nIndex],"1");
    }

    if (m_nIndex < (m_oSvgIds.size()- 1))
      ++m_nIndex;

    if (m_nIndex >= (m_oSvgIds.size()-1))
      bRet = false;
  }

  m_oSvg.load(m_oDomSvg.toByteArray());
  QMutexLocker o(&m_Mutex);
  m_oSvgImage = QImage(width(), height(), QImage::Format_ARGB32_Premultiplied);
  QPainter oImgPainter(&m_oSvgImage);
  if (oImgPainter.isActive() == false)
    return true;

  m_oSvg.render(&oImgPainter);
  update();
  return bRet;
}


void SvgDrawing::clearSvg()
{
}


void SvgDrawing::geometryChanged(const QRectF &newGeometry,
                                 const QRectF &oldGeometry)
{
  if (newGeometry.size() == oldGeometry.size())
    return;


  QMutexLocker o(&m_Mutex);
  m_oSvgImage = QImage(width(), height(), QImage::Format_ARGB32_Premultiplied);
  QPainter oImgPainter(&m_oSvgImage);

  if (oImgPainter.isActive() == false)
    return;

  m_oSvg.render(&oImgPainter);
}


void SvgDrawing::paint(QPainter *painter)
{
  QMutexLocker o(&m_Mutex);
  painter->drawImage(0,0, m_oSvgImage);
}
