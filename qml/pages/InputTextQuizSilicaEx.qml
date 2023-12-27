import QtQuick 2.0
import Sailfish.Silica 1.0

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
    anchors.rightMargin: 10
    source: "image://theme/icon-s-clear-opaque-cross"
    onClicked: {
      idTextField.text = ""
    }
  }
}
