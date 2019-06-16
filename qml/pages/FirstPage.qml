import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    Column  {
        id:idTabMain
        anchors.fill : parent
        anchors.leftMargin : 50
        anchors.rightMargin : 50
        anchors.bottomMargin:  150
        anchors.topMargin : 50
        spacing :10

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            id: idTitle
            text: "Glosor"
        }


        Row {
            width:parent.width
            spacing :10
            Button
            {
                id:idTab1Btn
                width: parent.width / 3 - parent.spacing
                text:"Make"
                onClicked: page.state = "idTab1"
            }

            Button
            {
                id:idTab2Btn
                width: parent.width / 3 - parent.spacing
                text:"Edit"
                onClicked:  page.state =  "idTab2"
            }
            Button
            {
                id:idTab3Btn
                width: parent.width / 3 - parent.spacing
                text:"Quiz"
                onClicked:  page.state ="idTab3"
            }

        }

        Rectangle
        {
            width: parent.width
            height: parent.height - 100
            visible:false
            id:idTab1
            color:"green"
        }
        Rectangle
        {
            width: parent.width
            height: parent.height - 100
            id:idTab2
            color:"blue"
            visible:false
        }
        Rectangle
        {
            width: parent.width
            height: parent.height - 100
            id:idTab3
            color:"red"
            visible:false
        }


    }
    states: [
        State {
            name: "idTab1"
            PropertyChanges {
                target: idTab1
                visible:true
            }

            PropertyChanges {
                target: idTab1Btn
                color:Theme.highlightColor

            }
        },
        State {
            name: "idTab2"
            PropertyChanges {
                target: idTab2
                visible:true

            }
            PropertyChanges {
                target: idTab2Btn
                color:Theme.highlightColor

            }
        },
        State {
            name: "idTab3"
            PropertyChanges {
                target: idTab3
                visible:true
            }

            PropertyChanges {
                target: idTab3Btn
                color:Theme.highlightColor
            }

        }

    ]
}
