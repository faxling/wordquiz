import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

WebViewPage {
  height: Screen.height
  width: Screen.width
  property alias url: idWebView.url
  WebView {
    id: idWebView
    anchors.fill: parent
    url: "https://faxling.github.io/wordquiz/doc.html"
  }
}
