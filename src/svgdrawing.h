#ifndef SVGDRAWING_H
#define SVGDRAWING_H
#include <QtQuick/QQuickPaintedItem>
#include <QSvgRenderer>
#include <QImage>
#include <QDomNode>
#include "QMutex"
#include <QVector>
class SvgDrawing : public QQuickPaintedItem
{
  Q_OBJECT
  public:
  Q_INVOKABLE bool renderId(int nId);
  Q_INVOKABLE void clearSvg();
  void paint(QPainter *painter) override;
  SvgDrawing();
private:
  void setOpacityOnId(const QString& id, const QString& op);
  void geometryChanged(const QRectF &newGeometry,
                               const QRectF &oldGeometry) override;
  QSvgRenderer m_oSvg;
  QVector<QString> m_oSvgIds;
    QVector<QString> m_oSvgHIds;
  QImage m_oSvgImage;
  QString m_sOrd;
  QMutex m_Mutex;
  int m_nIndex = 0;
  using SMap_t = QMap<QString, QString>;
  using StyleP_t = std::pair<SMap_t, QDomNode>;
  QMap<QString, StyleP_t> m_ocStyleMap;
  QDomDocument m_oDomSvg;
};

#endif // SVGDRAWING_H
