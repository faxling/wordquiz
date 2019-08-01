import QtQuick 2.0
import Sailfish.Silica 1.0

Button
{
  property alias bProgVisible : idProgres.visible
  Rectangle
  {
    id:idProgres
    y: parent.height / 8
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    color: Theme.secondaryHighlightColor
    width:parent.width - 20
    height:parent.height / 4
  }

}
