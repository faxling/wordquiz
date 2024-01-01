import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
  id: idSilicaListView

  VerticalScrollDecorator {
    flickable: idSilicaListView
  }
  clip: true
  highlight: Rectangle {
    opacity: 0.5
    color: "#009bff"
  }
}
