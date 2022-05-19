import QtQuick 2.6
import Sailfish.Silica 1.0

import "../QuizFunctions.js" as QuizLib
import "../CrossWordFunctions.js" as CWLib

Item {
  id: idCrossWordItem
  readonly property int cChar: 0
  readonly property int cGrey: 1
  readonly property int cQuestion: 2
  readonly property int cQuestionH: 3
  readonly property int cQuestionV: 4
  readonly property int cSpace: 5
  readonly property int cDone: 6

  // width in pixel of a char square
  property int nW: 0
  property int nLastCrossDbId: -1

  function loadCW() {
    CWLib.loadCW()
  }

  FontLoader {
    id: webFont
    source: "qrc:/ITCKRIST.TTF"
  }

  Component {
    id: idDline

    Item {
      anchors.fill: parent
      property string textH
      property string textV
      Image {
        opacity: 0.35
        anchors.fill: parent
        source: "qrc:dline.svg"
      }

      Text {
        id: idTV
        text: textV
        x: parent.width * 0.10
        y: parent.height * 0.70
        font.pointSize: 8
      }
      Text {
        id: idTH
        text: textH
        x: parent.width * 0.30
        y: parent.height * 0.10
        font.pointSize: 8
      }
    }
  }

  SilicaFlickable {
    id: idCrossWord
    clip: true
    anchors.fill: parent

    // gradient:  "NearMoon"
    contentHeight: idCrossWordGrid.height + Screen.height - 50
    contentWidth: idCrossWordGrid.width + Screen.width - 50
    Component {
      id: idCWCharComponent
      Rectangle {
        id: idCharRect

        Component.onCompleted: {
          if (nW === 0)
            nW = idT.font.pixelSize * 1.3
          idCharRect.height = nW
          idCharRect.width = nW
        }

        property int nIndex
        property int eSquareType: idCrossWordItem.cGrey
        property alias text: idT.text
        property string textA
        color: {
          switch (eSquareType) {
          case idCrossWordItem.cGrey:
            return "grey"
          case idCrossWordItem.cChar:
            return "white"
          case idCrossWordItem.cSpace:
            return "#feffcc"
          case idCrossWordItem.cQuestionV:
          case idCrossWordItem.cQuestionH:
          case idCrossWordItem.cQuestion:
            return "#e2f087"
          case idCrossWordItem.cDone:
            return "#71ff96"
          }
        }

        Text {
          id: idT
          visible: eSquareType !== idCrossWordItem.cQuestion
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          anchors.fill: parent
          wrapMode: Text.WrapAnywhere
          font.pixelSize: CWLib.isQ(eSquareType) ? 10 : Theme.fontSizeSmall
        }

        MouseArea {
          anchors.fill: parent
          onPressed: CWLib.popupOnPressJolla(idCharRect, idT)
        }
      }
    }

    Grid {
      id: idCrossWordGrid
      spacing: 2
    }
  }
  FontMetrics {
    id: fontMetrics
    font: idInfoBox.t.font
  }
  Rectangle {
    id: idInfoBox
    visible: false
    color: Theme.overlayBackgroundColor
    property alias t: idTextInfo
    Text {
      color: Theme.highlightColor
      font.pixelSize: Theme.fontSizeMedium
      font.family: Theme.fontFamilyHeading
      id: idTextInfo
    }
  }
  TextMetrics {
    id: fontMetrics2
    font: idInputBox.t.font
    text: idInputBox.t.displayText + "   "
  }
  Rectangle {
    id: idInputBox
    property int nIndex
    visible: false
    height: fontMetrics2.boundingRect.height
    width: fontMetrics2.boundingRect.width
    color: Theme.overlayBackgroundColor
    property alias t: idTextInput
    //    width: idTextInput.width + idTextInput.font.pixelSize
    TextInput {
      id: idTextInput
      color: Theme.highlightColor
      anchors.fill: parent
      font.pixelSize: Theme.fontSizeMedium
      font.capitalization: Font.AllUppercase
      onAccepted: {
        idInputBox.visible = false
        CWLib.handleCharInput(text)
      }
    }
  }

  ButtonQuizImg {
    id: idRefresh
    x: idTabMain.width - width - 20
    y: 20
    source: "image://theme/icon-m-refresh?Theme.highlightColor"
    onClicked: {
      CWLib.sluggCW()
    }


    /*
    TextList {
      anchors.bottom: parent.bottom
      text: "New"
      horizontalAlignment: Text.AlignHCenter
      anchors.horizontalCenter: parent.horizontalCenter
    }
*/
    BusyIndicator {
      running: bCWBusy
      id: idBusyIndicator
      anchors.fill: parent
    }
  }

  Text {
    id: idErrMsg
    text: "Select Quiz with more than 6 questions"
    visible: false
    anchors.centerIn: parent
    color: "red"
    font.pixelSize: idCrossWordItem.width / 40
  }

  Text {
    id: idCrossResultMsg
    text: "Nice job!"
    visible: false
    anchors.centerIn: parent
    color: "tomato"
    font.family: webFont.name
    font.pixelSize: idCrossWordItem.width / 5
  }
}
