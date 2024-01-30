import QtQuick 2.0
// ButtonQuizImg.qml
Image {
  fillMode: Image.Stretch
  id: idImageBtn
  property bool bgColorDefault: true
  signal clicked

  Rectangle {
    id: idRect
    opacity: 0.4
    radius: 8
    color: bgColorDefault ? "steelblue" : "green"
    anchors.fill: parent
  }
  MouseArea {
    anchors.fill: parent
    onClicked: idImageBtn.clicked()
    onPressed: idRect.opacity = 0.6
    onReleased: idRect.opacity = 0.4
  }
}
