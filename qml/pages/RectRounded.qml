import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
  id:idDlgPopup
  property alias showClose : idBtnCancel.visible
  property alias leftClose : idBtnCancel.left
  property alias bottomClose : idBtnCancel.bottom
  radius : 20
  color: Theme.overlayBackgroundColor
  signal closeClicked()

  ButtonQuizImg {

    id:idBtnCancel
    anchors.top : parent.top
    anchors.right : parent.right
    anchors.topMargin: 10
    anchors.rightMargin: 10
    source: "image://theme/icon-m-cancel"
    onClicked: {
      idDlgPopup.closeClicked()
    }
  }
}
