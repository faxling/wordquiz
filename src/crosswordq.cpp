#include "crosswordq.h"

#include <QAbstractListModel>
#include <QDebug>
#include <QMap>
#include <random>

#include "filehelpers.h"

constexpr int _nH = 30;
constexpr int _nW = 30;

CrossWordQ::CrossWordQ(QObject* parent) : QObject(parent) {
  m_pCrossWord = nullptr;
}

void CrossWordQ::createCrossWordFromList(QObject* p) {
  delete m_pCrossWord;
  m_pCrossWord = new CrossWord(_nW, _nH);
  QAbstractListModel* pp = dynamic_cast<QAbstractListModel*>(p);
  int nC = pp->rowCount();
  CrossWord::Vec ocWordList;
  QMap<QString, QString> ocWordMap;

  for (int i = 0; i < nC; i++) {
    QString sAnswer = pp->data(pp->index(i), 0).toString();
    ocWordList.push_back(sAnswer);
    QString sQuestion = pp->data(pp->index(i), 3).toString();
    ocWordMap[sAnswer] = sQuestion;
  }

  m_pCrossWord->AssignWordList(ocWordList);

  static std::mt19937 gen(time(0));
  static std::uniform_int_distribution<> dis(0, ocWordList.length());
  static std::uniform_int_distribution<> dis2(0, 1);
  if (dis2(gen) == 0)
    m_pCrossWord->SetSeedWordHorizontal(10, _nW / 2, ocWordList[dis(gen)]);
  else
    m_pCrossWord->SetSeedWordVertical(_nH / 2, 10, ocWordList[dis(gen)]);

  while (m_pCrossWord->IterateArea(10, 10, _nW - 10, _nH - 10) != 0)
    ;
  m_ocRet = m_pCrossWord->Get();
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
        pPF.call(QJSValueList({nIndex, QString(oJ.val().toUpper())}));
    }
  }
}

int CrossWordQ::nH() {
  return m_ocRet.first.size();
}

int CrossWordQ::nW() {
  return m_ocRet.first.first().length();
}
/*
QString CrossWordQ::QAt(int x, int y) {
  auto i = m_ocRet.second.find({x, y});
  if (i == m_ocRet.second.end())
    return QString();
  return *i;
}
*/
QString CrossWordQ::ChAt(int x, int y) {
  return m_ocRet.first[y][x];
}
