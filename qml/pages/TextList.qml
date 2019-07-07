import QtQuick 2.0
import Sailfish.Silica 1.0

Text {
  id:idText
  signal click
  color:Theme.highlightColor
  font.pixelSize: Theme.fontSizeMedium
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
  }
}

