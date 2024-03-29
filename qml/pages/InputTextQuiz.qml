import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
  signal gotFocus
  property alias displayText: idTextInput.displayText
  property alias text: idTextInput.text
  color: "grey"
  width: parent.width
  height: Theme.fontSizeLarge
  TextInput {

    onActiveFocusChanged: {

      // Emit signal
      if (activeFocus)
        gotFocus()
    }

    cursorDelegate: Rectangle {
      visible: idTextInput.focus
      height: parent.height
      width: 6
      color: Theme.highlightColor
    }

    anchors.topMargin: 2
    font.pixelSize: Theme.fontSizeMedium
    anchors.fill: parent
    id: idTextInput
  }

  ButtonQuizImg {
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    source: "image://theme/icon-s-clear-opaque-cross"
    onClicked: {
      parent.text = parent.displayText
      parent.text = ""
    }
  }
}
