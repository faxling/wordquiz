#ifndef CROSSWORDQ_H
#define CROSSWORDQ_H

#include <QObject>
#include <QJSValue>
#include "../../CrossMatch/crossword.h"
class CrossWord;
class CrossWordQ : public QObject
{
  Q_OBJECT
public:
  explicit CrossWordQ(QObject *parent = nullptr);

  Q_INVOKABLE QString QAt(int x,int y);
  Q_INVOKABLE QString ChAt(int x,int y);
  Q_INVOKABLE void createCrossWordFromList(QObject* pList);

//
  Q_INVOKABLE void assignQuestionSquares(QJSValue pPF);
  Q_INVOKABLE void assignCharSquares(QJSValue pPF);
  Q_PROPERTY(int nW READ nW)
  Q_PROPERTY(int nH READ nH)
private:
  int nW();
  int nH();

  CrossWord* m_pCrossWord;
  CrossWord::Vec2D m_ocRet;
};

#endif // CROSSWORDQ_H
