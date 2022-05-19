#include "crosswordq.h"

#include <QAbstractListModel>
#include <QDebug>
#include <QMap>
#include <QEventLoop>


#include <random>

#include "filehelpers.h"

constexpr int _nH = 30;
constexpr int _nW = 30;
constexpr int _nX = 10;

CrossWordQ::CrossWordQ(QObject* parent) : QObject(parent) {

}

bool CrossWordQ::sluggOneWord() {
  if (m_pCrossWord->IterateArea(_nX, _nX, _nW - _nX, _nH - _nX) == 0) {
    m_ocRet = m_pCrossWord->Get();
    return false;
  }

  m_ocRet = m_pCrossWord->Get();
  return true;
}

void CrossWordQ::createCrossWordFromList(QObject* p) {
  QAbstractListModel* pp = dynamic_cast<QAbstractListModel*>(p);
  int nC = pp->rowCount();

  if (nC < 6)
    return;

  m_pCrossWord.reset(new CrossWord(_nW, _nH));

  QEventLoop loop;
  loop.processEvents();

  CrossWord::Vec ocWordList;
  QMap<int, QString> ocWordMap;

  for (int i = 0; i < nC; i++) {
    QString sAnswer = pp->data(pp->index(i), 0).toString().toUpper();
    if (sAnswer.length() + _nX >= _nW)
      sAnswer = "#";
    ocWordList.push_back(sAnswer);
    QString sQuestion = pp->data(pp->index(i), 3).toString().toUpper();
    ocWordMap[i] = sQuestion;
  }

  m_pCrossWord->AssignWordList(ocWordList);

  static std::mt19937 gen(time(0));
  std::uniform_int_distribution<> dis(0, ocWordList.length() - 1);

  int nII = dis(gen);

  for (int i = 0; i < 10; ++i) {
    if (nII < ocWordList.length())
    {
      if (ocWordList[nII] != "#")
        break;
    }
    else
      qDebug() << "StrangeW << " << nII;

    nII = dis(gen);
  }
  m_pCrossWord->SetSeedWordHorizontal(10, _nW / 2, ocWordList[nII], nII);
}

void CrossWordQ::assignQuestionSquares(QJSValue pPF) {
  for (auto oI : IterRange(m_ocRet.second)) {
    int nIndex = oI.key().first + oI.key().second * nW();
    pPF.call(QJSValueList({nIndex, oI.val().HorizontalQ, oI.val().VerticalQ}));
  }
}

void CrossWordQ::assignCharSquares(QJSValue pPF) {
  for (auto& oI : IterRange(m_ocRet.first)) {
    for (auto& oJ : IterRange(oI.val())) {
      int nIndex = oI.index() * nW() + oJ.index();
      if (m_pCrossWord->IsChar(oJ.val()) == true)
        pPF.call(QJSValueList({nIndex, QString(oJ.val())}));
    }
  }
}

int CrossWordQ::nH() {
  return m_ocRet.first.length();
}

int CrossWordQ::nW() {
  if (m_ocRet.first.isEmpty())
    return 0;
  return m_ocRet.first.first().length();
}
