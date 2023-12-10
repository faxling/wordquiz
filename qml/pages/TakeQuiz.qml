import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id: idRectTakeQuiz
  property bool bExtraInfoVisible: false
  property bool bTextMode: false
  property bool bImageMode: false
  property bool bVoiceMode: false
  property bool bAnswerVisible: false
  property bool allok: idWindow.bAllok
  Component.onCompleted: {
    idWindow.oTakeQuiz = idRectTakeQuiz
  }

  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  PathView {
    id: idTakeQuizView
    clip: true

    // Making it lock if bTextMode and not correct answer
    interactive: (!bTextMode || moving || bAnswerVisible)
    width: idRectTakeQuiz.width
    height: idRectTakeQuiz.height

    onCurrentIndexChanged: {
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
