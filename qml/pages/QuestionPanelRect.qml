import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
  radius: 10

  anchors.fill: parent
  color: Theme.overlayBackgroundColor
  Image {
    anchors.bottomMargin: 20
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.rightMargin: 20
    source: "qrc:qml/pages/r.png"
  }
  Image {
    anchors.bottomMargin: 20
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.leftMargin: 20
    source: "qrc:qml/pages/left.png"
  }
}
