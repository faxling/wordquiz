import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0

WebViewPage {
  property alias url: idWebView.url
  WebView {
    id: idWebView
    anchors.fill: parent
    anchors.leftMargin: 25
  }
}
