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
    onTriggered: QuizLib.handleMovmentEnded()
  }

  Timer {
    id: idCarTimer
    interval: (20 - nCarModeSpeed) * 1000
    repeat: true
    onTriggered: QuizLib.exeCarMode()
  }


  /*
  Timer {
    id: idCarTimerPlayQuestion
    interval: 1000
    repeat: false
    onTriggered: QuizLib.playQuestion()
  }

  Timer {
    id: idCarTimerPlayAnswer
    interval: idCarTimer.interval - 2000
    repeat: false
    onTriggered: QuizLib.playAnswer()
  }

  */
  PathView {
    id: idTakeQuizView
    clip: true

    // onMovementEnded: QuizLib.handleMovmentEnded()
    onMovingChanged: console.log("movingchanged")
    // Making it lock if bTextMode and not correct answer
    interactive: (!bTextMode || bTextAnswerOk || moving)
    width: idRectTakeQuiz.width
    height: idRectTakeQuiz.height

    onFlickEnded: console.log("onFlic Ended")
    property int nLastIndex
    onMovementEnded: {
      console.log("onMovementEnded")

      // Manual movement
      idCarTimer.stop()
      QuizLib.handleMovmentEnded()
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
