import QtQuick 2.0
import Sailfish.Silica 1.0

Text {
  id:idText
  signal click
  color:Theme.highlightColor
  font.pointSize: Theme.fontSizeExtraSmall
 //  height:Theme.fontSizeExtraSmall*2
  MouseArea{
    anchors.fill: parent
    onClicked: idText.click()
  }
}

