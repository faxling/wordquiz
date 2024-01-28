import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Flipable {
  id: flipable

  width: idTakeQuizView.width
  height: idRectTakeQuiz.height - 200

  front: QuestionPanelRect {

    Image {
      visible: allOk1_3
      anchors.centerIn: parent
      source: "qrc:qml/pages/thumb.png"
    }

    Item {
      visible: !allOk1_3
      anchors.fill: parent
      ButtonQuizImg {
        id: idInfoBtn
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        source: "image://theme/icon-m-about"
        visible: extra.length > 0
        onClicked: bExtraInfoVisible = !bExtraInfoVisible
      }

      ButtonQuizImg {
        id: idTextBtn
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        source: "image://theme/icon-m-keyboard?"
                + (bTextMode ? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
          bTextMode = !bTextMode
          if (bTextMode) {
            MyDownloader.focusOnQuizText(nQuizIndex1_3)
          }
        }
      }

      ButtonQuizImg {
        id: idVoiceModeBtn
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
        visible: imgUrl !== "image://theme/icon-m-file-image"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: idTextBtn.bottom
        anchors.topMargin: 20
        source: "image://theme/icon-m-image?"
        onClicked: bImageMode = !bImageMode
      }

      Text {
        id: idTextExtra
        anchors.left: idInfoBtn.right
        anchors.leftMargin: 20
        anchors.verticalCenter: idInfoBtn.verticalCenter
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        visible: bExtraInfoVisible
        text: extra
      }

      TextField {
        id: idTextEditYourAnswer
        focus: true

        Component.onCompleted: MyDownloader.storeTextInputField(
                                 number, idTextEditYourAnswer)

        y: 50
        anchors.horizontalCenter: parent.horizontalCenter
        visible: bTextMode
        width: parent.width - 150
        labelVisible: false
        placeholderText: "your answer"
        onTextChanged: {
          bTextAnswerOk = QuizLib.isAnswerOk(text, answer)
          if (bTextAnswerOk)
            QuizLib.setAnswerVisible()
        }
      }
      ButtonQuizImg {
        anchors.right: parent.right
        anchors.rightMargin: 20
        width: Theme.itemSizeExtraSmall
        height: Theme.itemSizeExtraSmall
        y: idBtnAnswer.y + idQuizColumn.y
        source: "image://theme/icon-m-speaker-on"
        onClicked: MyDownloader.playWord(question,
                                         bIsReverse ? sToLang : sFromLang)
      }

      Column {
        id: idQuizColumn
        visible: !allOk1_3
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height / 4.5

        // && (idWindow.nQuizIndex === index)
        Image {
          id: idWordImage
          //         cache:false
          height: 350
          width: 500
          fillMode: Image.PreserveAspectFit
          anchors.horizontalCenter: parent.horizontalCenter
          visible: bImageMode && imgUrl !== "image://theme/icon-m-file-image"
          // && MyDownloader.hasImg
          source: imgUrl
        }

        Text {
          id: idTextQuestion
          height: Theme.itemSizeExtraSmall
          opacity: bVoiceMode ? 0 : 1
          color: Theme.highlightColor
          font.pixelSize: Theme.fontSizeExtraLarge
          font.bold: true
          anchors.horizontalCenter: parent.horizontalCenter
          text: question
        }

        ButtonQuizImg {
          id: idBtnAnswer
          focus: false
          fillMode: Image.Pad
          anchors.horizontalCenter: parent.horizontalCenter
          width: Theme.itemSizeExtraSmall * 2
          height: Theme.itemSizeExtraSmall * 2
          source: "image://theme/icon-m-flip"
          onClicked: {
            QuizLib.toggleAnswerVisible()
          }
        }
      }
    }
  }
  back: QuestionPanelRect {
    Column {
      visible: !allOk1_3
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
        text: answer
      }

      ButtonQuizImg {
        fillMode: Image.Pad
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.itemSizeExtraSmall * 2
        height: Theme.itemSizeExtraSmall * 2
        source: "image://theme/icon-m-flip"
        onClicked: QuizLib.toggleAnswerVisible()
      }

      ButtonQuizImg {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.itemSizeExtraSmall
        height: Theme.itemSizeExtraSmall
        source: "image://theme/icon-m-speaker-on"
        onClicked: MyDownloader.playWord(answer, sAnswerLang)
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
