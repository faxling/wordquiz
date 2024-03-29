import QtQuick 2.0
import Sailfish.Silica 1.0

Text {
  id: idText
  signal click
  signal pressAndHold
  color: Theme.primaryColor
  font.pixelSize: Theme.fontSizeMedium
  MouseArea {
    anchors.fill: parent
    onClicked: idText.click()
    onPressAndHold: idText.pressAndHold()
  }
}
