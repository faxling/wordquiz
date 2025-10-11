import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id: idRectTakeQuiz
  property bool bExtraInfoVisible: false
  property bool bTextMode: false
  property bool bImageMode: false
  property bool bVoiceMode: false
  property bool bCarMode: false
  property int nCarModeSpeed: 10
  property bool bTextAnswerOk: false

  Component.onCompleted: {
    idWindow.oTakeQuiz = idRectTakeQuiz
  }

  Timer {
    id: idMoveTimer
    interval: 500
    repeat: false
    onTriggered: QuizLib.handleMovmentEnded(false)
  }

  Timer {
    id: idCarTimer
    interval: (18 - nCarModeSpeed) * 1000
    repeat: false
    onTriggered: QuizLib.exeCarMode()
  }

  PathView {
    id: idTakeQuizView
    clip: true
    // Making it lock if bTextMode and not correct answer
    interactive: (!bTextMode || bTextAnswerOk || moving)
    width: idRectTakeQuiz.width
    height: idRectTakeQuiz.height
    property int nLastIndex
    onMovementEnded: {
      // Manual movement = true
      QuizLib.handleMovmentEnded(true)
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
