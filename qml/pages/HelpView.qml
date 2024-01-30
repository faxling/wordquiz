import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

Page {
  id: idWebViewPage
  height: Screen.height
  width: Screen.width
  property alias url: idWebView.url
  Component.onCompleted: {
    idWebView.viewportHeight = height
  }

  WebView {
    id: idWebView
    anchors.fill: idWebViewPage
    url: "https://faxling.github.io/wordquiz/doc.html"
  }
}
