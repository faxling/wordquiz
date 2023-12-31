import QtQuick 2.0
import Sailfish.Silica 1.0

// InputTextQuizSilicaEx
Item {
  property alias labelVisible: idTextField.labelVisible
  property alias placeholderText: idTextField.placeholderText
  property alias displayText: idTextField.text
  property alias text: idTextField.text
  height: Theme.fontSizeLarge

  TextField {
    id: idTextField
    width: parent.width - idClearBtn.width
  }
  ButtonQuizImg {
    id: idClearBtn
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right

    source: "image://theme/icon-m-backspace"

    Timer {
      id: idTimer
      interval: 50
      repeat: false
      onTriggered: idTextField.forceActiveFocus()
    }
    onClicked: {

      idTextField.text = ""
      idTimer.start()
    }
  }
}
