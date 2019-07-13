import QtQuick 2.0
import Sailfish.Silica 1.0

import QtQml.Models 2.2

CoverBackground {

  Column {
    spacing: 40
    anchors.centerIn: parent
    Label {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Word Quiz"
    }
    Image
    {
      source: "qrc:qml/pages/harbour-wordquiz.png"
      anchors.horizontalCenter: parent.horizontalCenter
    }
    Label {
      text: sAppTitle
      font.pixelSize: Theme.fontSizeSmall
    }
  }

}
