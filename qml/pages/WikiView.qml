import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

WebViewPage {
  property alias url: idWebView.url
  property string sTitle: idHeadLine.text
  Item {
    width: parent.width
    height: Theme.itemSizeLarge
    Text {
      anchors.centerIn: parent
      id: idHeadLine
      font.pixelSize: Theme.fontSizeLarge
      text: sTitle
      color: Theme.highlightColor
    }
  }
  WebView {
    id: idWebView
    anchors.fill: parent
    anchors.topMargin: Theme.itemSizeLarge
  }
}
