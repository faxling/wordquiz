import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView.Popups 1.0
import Sailfish.WebEngine 1.0

ContextMenuInterface {
  id: root
  anchors.fill: parent

  function show() {
    opacity = 1.0
  }

  function _hide() {
    opacity = 0.0
  }

  visible: opacity > 0.0
  opacity: 0.0
  Behavior on opacity {
    FadeAnimation {
      duration: 300
    }
  }
  property string targetDirectory
  function myStartDownload() {

    // drop query string from URL and split to sections
    var urlSections = imageSrc.split("?")[0].split("/")
    var leafName = decodeURIComponent(urlSections[urlSections.length - 1])

    if (leafName.length === 0) {
      leafName = "unnamed_file"
    }
    var downloadFileTargetUrl = DownloadHelper.createUniqueFileUrl(
          leafName, StandardPaths.download)

    if (downloadFileTargetUrl) {
      WebEngine.notifyObservers("embedui:download", {
                                  "msg": "addDownload",
                                  "from": imageSrc,
                                  "to": downloadFileTargetUrl,
                                  "contentType": root.contentType,
                                  "viewId": root.viewId
                                })
    }
  }

  onImageSrcChanged: {
    console.log("onImageSrcChanged " + imageSrc)
    if (imageSrc.length < 10)
      text = "Not an image " + contentType
    else {

      if (imageSrc.substr(0, 5) === "data:")
        idImgNameTxt.text = "base64 image"
      else {
        var urlSections = imageSrc.split("?")[0].split("/")
        var leafName = decodeURIComponent(urlSections[urlSections.length - 1])
        idImgNameTxt.text = leafName
      }
    }
  }
  Rectangle {

    anchors.fill: parent
    gradient: Gradient {
      GradientStop {
        position: 0.0
        color: Theme.highlightDimmerColor
      }
      GradientStop {
        position: 1.0
        color: Theme.rgba(Theme.highlightDimmerColor, .81)
      }
    }

    MouseArea {
      id: content
      anchors.fill: parent
      onClicked: root._hide()
    }
    Label {
      id: idImgNameTxt
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WrapAnywhere
      truncationMode: TruncationMode.Elide
      anchors.horizontalCenter: parent.horizontalCenter
      y: Screen.height / 4
    }
    Button {
      id: saveBtn
      anchors.centerIn: parent
      text: "Save for use in WordQuiz"
      onClicked: {
        myStartDownload()
        root._hide()
      }
    }
  }
}
