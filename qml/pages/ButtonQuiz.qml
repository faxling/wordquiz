import QtQuick 2.0
import Sailfish.Silica 1.0

Button
{
  property alias bProgVisible : idProgres.visible
  Rectangle
  {
    y: parent.height / 8
    id:idProgres
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    color: Theme.secondaryHighlightColor
    width:parent.width - 20
    height:parent.height / 4
  }

}
