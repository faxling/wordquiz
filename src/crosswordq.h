#ifndef CROSSWORDQ_H
#define CROSSWORDQ_H

#include <QObject>
#include <QJSValue>
#include <memory>
#include "../../Crossword/crossword.h"

class CrossWordQ : public QObject
{
  Q_OBJECT
public:
  explicit CrossWordQ(QObject *parent = nullptr);

  Q_INVOKABLE void createCrossWordFromList(QObject* pList);
  Q_INVOKABLE bool sluggOneWord();
//
  Q_INVOKABLE void assignQuestionSquares(QJSValue pPF);
  Q_INVOKABLE void assignCharSquares(QJSValue pPF);
  Q_PROPERTY(int nW READ nW)
  Q_PROPERTY(int nH READ nH)
private:
  int nW();
  int nH();

  std::unique_ptr<CrossWord> m_pCrossWord;
  CrossWord::Vec2D m_ocRet;
};

#endif // CROSSWORDQ_H
