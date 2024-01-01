import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id: idRectTakeQuiz
  property bool bExtraInfoVisible: false
  property bool bTextMode: false
  property bool bImageMode: false
  property bool bVoiceMode: false
  property bool bTextAnswerOk: false
  property bool allok: idWindow.bAllok
  Component.onCompleted: {
    idWindow.oTakeQuiz = idRectTakeQuiz
  }

  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  PathView {
    id: idTakeQuizView
    clip: true
    flickDeceleration: 1000

    // Making it lock if bTextMode and not correct answer
    interactive: (!bTextMode || bTextAnswerOk || moving)
    width: idRectTakeQuiz.width
    height: idRectTakeQuiz.height

    property int nLastIndex
    onMovementEnded: {
      if (nLastIndex === currentIndex)
        return
      nLastIndex = currentIndex
      QuizLib.calcSwipeDirection(currentIndex)
      QuizLib.assigNextQuizWord()
    }

    model: idQuizModel
    delegate: QuestionPanel {}
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -(idTakeQuizView.width / 2 + 100)
      startY: idTakeQuizView.height / 2
      PathLine {
        relativeX: idTakeQuizView.width * 3 + 300
        relativeY: 0
      }
    }
  }
}
