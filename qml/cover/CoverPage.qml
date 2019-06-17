import QtQuick 2.0
import Sailfish.Silica 1.0

import QtQml.Models 2.2

CoverBackground {



    Label {
        id: label
        anchors.centerIn: parent
        text: "Word Quiz"
        Image
        {
            y:100
            source: "qrc:qml/pages/harbour-wordquiz.png"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
