import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebView.Popups 1.0
import Sailfish.WebEngine 1.0

Page {
  id: idWebViewPage
  property alias url: idWebView.url
  property string sTitle: idHeadLine.text

  Component.onCompleted: {
    idWebView.viewportHeight = Screen.height
  }
  Item {
    id: idHeader
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
  ButtonQuizImg {
    anchors.right: parent.right
    anchors.rightMargin: 10
    anchors.verticalCenter: idHeader.verticalCenter
    source: "image://theme/icon-m-back"
    onClicked: {
      idWebView.goBack()
    }
  }

  WebView {
    id: idWebView


    /*
    Component.onCompleted: {
      WebEngineSettings.useDownloadDir = true
      WebEngineSettings.downloadDir = StandardPaths.download
    }
*/
    popupProvider: PopupProvider {
      id: customPopupProvider
      contextMenu: "qrc:/qml/pages/WebPopup.qml"
    }

    anchors.fill: parent
    anchors.topMargin: Theme.itemSizeLarge
  }
}
