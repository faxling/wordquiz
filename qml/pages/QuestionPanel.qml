import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Flipable {
  id: flipable
  property bool bTextAnswerOk: false
  width: idTakeQuizView.width
  height: idRectTakeQuiz.height - 200
  front: QuestionPanelRect {

    ButtonQuizImg {
      id: idInfoBtn
      anchors.left: parent.left
      anchors.leftMargin: 20
      anchors.top: parent.top
      anchors.topMargin: 20
      source: "image://theme/icon-m-about"
      visible: idQuizModel.extra.length > 0
      onClicked: bExtraInfoVisible = !bExtraInfoVisible
    }

    ButtonQuizImg {
      id: idTextBtn
      visible: !allok
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.top: parent.top
      anchors.topMargin: 20
      source: "image://theme/icon-m-keyboard?"
              + (bTextMode ? Theme.highlightColor : Theme.primaryColor)
      onClicked: bTextMode = !bTextMode
    }

    ButtonQuizImg {
      id: idVoiceModeBtn
      visible: !allok
      anchors.left: parent.left
      anchors.leftMargin: 20
      anchors.top: idInfoBtn.bottom
      anchors.topMargin: 20
      source: "image://theme/icon-m-headphone?"
              + (bVoiceMode ? Theme.highlightColor : Theme.primaryColor)
      onClicked: bVoiceMode = !bVoiceMode
    }

    ButtonQuizImg {
      id: idImgBtn
      visible: !allok
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.top: idTextBtn.bottom
      anchors.topMargin: 20
      source: "image://theme/icon-m-image?"
              + (bImageMode ? Theme.highlightColor : Theme.primaryColor)
      onClicked: bImageMode = !bImageMode
    }


    /*
    ButtonQuizImg {
      id: idSoundBtn
      visible: bTextAnswerOk && bTextMode && !allok
      anchors.right: parent.right
      anchors.rightMargin: 20
      anchors.top: idTextBtn.bottom
      anchors.topMargin: 20
      source: "image://theme/icon-m-speaker"
      onClicked: MyDownloader.playWord(idQuizModel.answer, sAnswerLang)
    }
*/
    Text {
      id: idTextExtra
      anchors.left: idInfoBtn.right
      anchors.leftMargin: 20
      anchors.verticalCenter: idInfoBtn.verticalCenter
      color: Theme.primaryColor
      font.pixelSize: Theme.fontSizeExtraSmall
      visible: bExtraInfoVisible
      text: idQuizModel.extra
    }


    /*
    Image {
      id: idTextAnswerOkImage
      anchors.left: idVoiceModeBtn.left
      anchors.top: idVoiceModeBtn.bottom
      anchors.topMargin: 20
      visible: bTextAnswerOk && bTextMode && !allok
      source: "image://theme/icon-m-like"
    }
*/
    TextField {
      id: idTextEditYourAnswer
      Component.onCompleted: {
        MyDownloader.storeTextInputField(idTextEditYourAnswer)
      }
      y: 50
      anchors.horizontalCenter: parent.horizontalCenter
      visible: bTextMode && (!allok)
      width: parent.width - 150
      labelVisible: false
      placeholderText: "your answer"
      onTextChanged: {
        var bAnswerVisible = QuizLib.isAnswerOk(text, idQuizModel.answer)
        if (bAnswerVisible)
          QuizLib.setAnswerVisible()
      }
    }
    ButtonQuizImg {
      visible: !allok
      anchors.right: parent.right
      anchors.rightMargin: 20
      width: Theme.itemSizeExtraSmall
      height: Theme.itemSizeExtraSmall
      y: idBtnAnswer.y + idQuizColumn.y
      source: "image://theme/icon-m-speaker-on"
      onClicked: MyDownloader.playWord(idQuizModel.question,
                                       bIsReverse ? sToLang : sFromLang)
    }
    Column {
      id: idQuizColumn
      spacing: 20
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height / 4.5
      visible: !allok
      // && (idWindow.nQuizIndex === index)
      Image {
        id: idWordImage
        //         cache:false
        height: 350
        width: 500
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        visible: bImageMode && MyDownloader.hasImg
        source: MyDownloader.urlImg
      }

      Text {
        id: idTextQuestion
        height: Theme.itemSizeExtraSmall
        opacity: bVoiceMode ? 0 : 1
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeExtraLarge
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        text: idQuizModel.question
      }

      ButtonQuizImg {
        id: idBtnAnswer
        fillMode: Image.Pad
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.itemSizeExtraSmall * 2
        height: Theme.itemSizeExtraSmall * 2
        source: "image://theme/icon-m-flip"
        onClicked: {
          idQuizModel.answerDisp = idQuizModel.answer
          QuizLib.toggleAnswerVisible()
        }
      }


      /*
      ButtonQuiz {
        id: idBtnAnswer

        anchors.horizontalCenter: parent.horizontalCenter
        text: "Show Answer"
        onClicked: {
          bAnswerVisible = !bAnswerVisible
        }
      }
      */
    }

    Image {
      visible: allok
      anchors.centerIn: parent
      source: "qrc:qml/pages/thumb.png"
    }
  }

  back: QuestionPanelRect {

    Column {
      y: parent.height / 4.5
      spacing: 20
      anchors.horizontalCenter: parent.horizontalCenter
      Text {
        id: idTextAnswer
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeExtraLarge
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        text: idQuizModel.answerDisp
      }

      ButtonQuizImg {
        fillMode: Image.Pad
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.itemSizeExtraSmall * 2
        height: Theme.itemSizeExtraSmall * 2
        source: "image://theme/icon-m-flip"
        onClicked: QuizLib.toggleAnswerVisible()
      }


      /*
      ButtonQuiz {
        id: idBtnAnswer2
        text: "Back"
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
          bAnswerVisible = !bAnswerVisible
        }
      }
      */
      ButtonQuizImg {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.itemSizeExtraSmall
        height: Theme.itemSizeExtraSmall
        source: "image://theme/icon-m-speaker-on"
        onClicked: MyDownloader.playWord(idQuizModel.answer, sAnswerLang)
      }
    }
  }

  transform: Rotation {
    id: rotation
    origin.x: flipable.width / 2
    origin.y: flipable.height / 2
    axis.x: 0
    axis.y: 1
    axis.z: 0 // set axis.y to 1 to rotate around y-axis
    angle: 0 // the default angle
  }

  states: State {
    name: "back"
    PropertyChanges {
      target: rotation
      angle: 180
    }
    when: answerVisible
  }

  transitions: Transition {
    NumberAnimation {
      target: rotation
      property: "angle"
      duration: 1000
    }
  }
}
