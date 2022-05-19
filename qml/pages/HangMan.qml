import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib
import SvgDrawing 1.0

Item {
  id: idHangMan
  property string sHangWord: ""
  property bool bIsReverseHang: false
  property int nBtnWidthQuote: idTTrans.visible ? 3 : 1
  property int nUsedCharColLen: 8
  property variant sCurrentRow: []
  function newQ() {
    idDrawing.setColor(Theme.secondaryColor)
    QuizLib.hangNewQ()
  }
  Component {
    id: idChar
    Rectangle {
      property alias text: idT.text
      color: bIsSpecial ? "white" : "grey"
      property bool bIsSpecial: false
      height: Theme.fontSizeMedium * 1.3
      width: Theme.fontSizeMedium * 1.3
      Text {
        id: idT
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeMedium
      }
    }
  }

  SvgDrawing {
    id: idDrawing
    anchors.fill: parent
    anchors.topMargin: Theme.fontSizeMedium * 1.3 + 20
  }

  Row {
    id: idOrdRow
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 10
    y: 10
  }

  Column {
    id: idOrdCol
    anchors.top: idOrdRow.bottom
    anchors.topMargin: 20
    anchors.right: parent.right
    anchors.rightMargin: 10
    spacing: 10
  }
  Column {
    id: idOrdCol2
    anchors.top: idOrdRow.bottom
    anchors.topMargin: 20
    anchors.right: idOrdCol.left
    anchors.rightMargin: 20
    spacing: 10
  }
  Column {
    id: idOrdCol3
    anchors.top: idOrdRow.bottom
    anchors.topMargin: 20
    anchors.right: idOrdCol2.left
    anchors.rightMargin: 20
    spacing: 10
  }
  // @disable-check M301
  ButtonQuiz {
    id: idHangBtn
    width: n25BtnWidth
    anchors.centerIn: parent
    text: "Start"
    onClicked: {
      idDrawing.renderId(1)
      QuizLib.hangAddWord()
      visible = !visible
    }
  }
  Image {
    id: idFlagImg
    visible: idHangBtn.visible
    anchors.top: idHangBtn.bottom
    anchors.topMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter
  }
  MouseArea {
    enabled: idFlagImg.visible
    anchors.fill: idFlagImg
    onClicked: {
      bIsReverseHang = !bIsReverseHang
      QuizLib.hangUpdateImage()
    }
  }

  Component {
    id: idCursorDelegate
    Rectangle {
      color: parent.focus ? "grey" : "#BDC3C7"
      anchors.fill: parent
    }
  }

  Rectangle {
    id: idCharRect
    anchors.top: idOrdRow.bottom
    anchors.topMargin: 20
    x: 20
    visible: !idHangBtn.visible
    height: idHangBtn2.height
    width: idHangBtn2.width
    property alias text: idT.text
    color: "#BDC3C7"

    TextInput {
      id: idTextInput
      color: "transparent"
      anchors.fill: parent
      cursorDelegate: idCursorDelegate
      onDisplayTextChanged: {
        if (displayText.length < 1)
          return
        var inCh = displayText[displayText.length - 1]
        if (!/\s/.test(inCh))
          idCharRect.text = displayText[displayText.length - 1].toUpperCase()

        idTextInput.text = " "
      }
    }

    Text {
      id: idT
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      anchors.centerIn: parent
      font.pixelSize: Theme.fontSizeMedium * 1.3
    }
  }

  ButtonQuizImg {
    id: idHangBtn2
    y: idCharRect.y
    width: height
    anchors.left: idCharRect.right
    anchors.leftMargin: 10
    visible: !idHangBtn.visible
    source: "image://theme/icon-m-enter"
    onClicked: {
      QuizLib.hangEnterChar()
    }
  }

  ButtonQuizImg {
    id: idHangKbdBtn
    width: height
    anchors.left: idCharRect.left
    anchors.topMargin: 10
    anchors.top: idCharRect.bottom
    visible: !idHangBtn.visible
    source: "image://theme/icon-m-keyboard"
    onClicked: {
      Qt.inputMethod.show()
    }
  }

  Text {
    id: idTTrans
    visible: false
    anchors.left: parent.left
    anchors.leftMargin: 50
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    color: Theme.highlightColor
    font.pixelSize: Theme.fontSizeMedium
  }
  // @disable-check M301
  ButtonQuiz {
    id: idHangBtn5
    visible: !idHangBtn.visible
    width: n4BtnWidth / nBtnWidthQuote
    anchors.right: idHangBtn3.left
    anchors.rightMargin: 20
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    text: idTTrans.visible ? "Tr" : "Translation"
    onClicked: {
      idDrawing.answerShown()
      idTTrans.visible = !idTTrans.visible
    }
  }
  // @disable-check M301
  ButtonQuiz {
    id: idHangBtn3
    width: n4BtnWidth / nBtnWidthQuote
    visible: !idHangBtn.visible
    property bool bAV: false
    anchors.right: idHangBtn4.left
    anchors.rightMargin: 20
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    text: idTTrans.visible ? "An" : "Answer"
    onClicked: {
      bAV = !bAV
      idDrawing.answerShown()
      QuizLib.hangShowAnswer(bAV)
    }
  }

  ButtonQuizImg {
    id: idHangBtn4
    width: idHangBtn3.height
    height: idHangBtn3.height
    visible: !idHangBtn.visible
    anchors.right: idSoundBtn.left
    anchors.rightMargin: 20
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    source: "image://theme/icon-m-repeat"
    onClicked: {
      idDrawing.setColor(Theme.secondaryColor)
      idDrawing.renderId(1)
      QuizLib.hangAddWord()
    }
  }

  ButtonQuizImg {
    id: idSoundBtn
    visible: !idHangBtn.visible
    width: idHangBtn3.height
    height: idHangBtn3.height
    anchors.right: parent.right
    anchors.rightMargin: 20
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    source: "image://theme/icon-m-speaker-on"
    onClicked: {
      var sL = bIsReverseHang ? sToLang : sFromLang
      idDrawing.answerShown()
      MyDownloader.playWord(sHangWord, sL)
    }
  }

  Timer {
    id: idResultMsgTimer
    interval: 600
    repeat: true
    onTriggered: idResultMsg.visible = !idResultMsg.visible
  }
  FontLoader {
    id: webFont
    source: "qrc:/ITCKRIST.TTF"
  }
  Text {
    id: idResultMsg
    visible: false
    anchors.centerIn: parent
    color: "Tomato"
    font.family: webFont.name
    font.pixelSize: idHangMan.width / 7
  }

  Keys.onReturnPressed: {
    QuizLib.hangEnterChar()
  }

  Keys.onEnterPressed: {
    QuizLib.hangEnterChar()
  }

  RectRounded {
    id: idErrorDialogHangMan
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    y: 20
    height: nDlgHeight
    width: parent.width
    property alias text: idWhiteText.text

    TextList {
      id: idWhiteText
      x: 20
      anchors.top: idErrorDialogHangMan.bottomClose
    }
    onCloseClicked: {
      idErrorDialogHangMan.visible = false
    }
  }
}
