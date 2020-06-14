import QtQuick 2.0
import Sailfish.Silica 1.0

RectRounded {
  id: idImport
  y: 20
  visible: false
  width: parent.width
  height: parent.width / 1.5
  property bool bIsDownloading : false
  property bool bIsDeleting : false
  property string sSelectedQ
  property string sImportMsg: ""
  property string sDesc1: ""
  property string sDescDate : ""

  property alias currentIndex : idServerListView.currentIndex

  function positionViewAtIndex(nIndex)
  {
    idServerListView.positionViewAtIndex(nIndex,
                                         ListView.Center)
  }

  onCloseClicked: {
    idPwdDialog.visible = false
    bIsDeleting = false
    idImport.state = ""
    idPwdTextInput.text = ""
  }

  Text {
    id: idDescText
    font.pixelSize: Theme.fontSizeTiny
    color: Theme.highlightColor
    anchors.top: idImport.top
    anchors.topMargin: 10
    x: 20
    text: "---"
  }

  Text {
    id: idDescDate
    font.pixelSize: Theme.fontSizeTiny
    color: Theme.highlightColor
    anchors.top: idDescText.bottom
    anchors.topMargin: 5
    x: 20
    text: "-"
  }

  TextList {
    id: idImportMsg
    x: parent.width / 2
    anchors.top: idDescText.top
    color: "red"
    text: ""
  }

  TextList {
    id: idImportTitle
    x: 10
    color: "steelblue"
    anchors.top: idImport.bottomClose
    text: "Downloadable Quiz's"
  }
  TextList {
    anchors.right: idImport.right
    anchors.top: idImport.bottomClose
    anchors.rightMargin: 20
    color: "steelblue"
    text: "Questions"
  }

  ListViewHi {
    id: idServerListView
    anchors.top: idImportTitle.bottom
    width: idImport.width - 20
    x: 10
    height: parent.height - idDeleteQuiz.height * 3 + 10
    model: idServerQModel
    delegate: Item {
      property int nW: idServerListView.width / 6
      width: idServerListView.width
      height: idServerRow.height
      Row {
        id: idServerRow
        TextList {
          width: nW * 4
          id: idTextQname
          text: qname
          onClick: {
            idImportMsg.text = ""
            idDescText.text = desc1
            idDescDate.text = date1
            idImport.sSelectedQ = qname
            idServerListView.currentIndex = index
          }
        }

        TextList {
          width: nW
          text: code
          height: parent.height
        }

        TextList {
          width: nW
          text: state1
          height: parent.height
        }
      }
    }
  }


  RectRounded {
    id: idPwdDialog
    border.width: 2
    border.color: Theme.primaryColor
    showClose: false
    visible: false
    height: 70
    anchors.bottom: idDeleteQuiz.top
    anchors.bottomMargin: 60
    width: idServerListView.width
    Row {
      x: 20
      anchors.verticalCenter: parent.verticalCenter
      spacing: 20
      TextList {
        id: idPwdLabelText
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.verticalCenter: parent.verticalCenter
        text: "Password to remove '" + idImport.sSelectedQ + "'"
      }

      InputTextQuiz {
        width: idServerListView.width - idPwdLabelText.width - 60
        id: idPwdTextInput
      }
    }
  }

  ButtonQuiz {
    id: idDeleteQuiz
    width: n4BtnWidth
    text: "Remove"
    bProgVisible : bIsDeleting
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    anchors.right: idLoadQuiz.left
    anchors.rightMargin: 20
    onClicked: {

      idTextInputQuizName.text = idImport.sSelectedQ
      idPwdTextInput.text = idPwdTextInput.displayText
      if (idPwdTextInput.text.length > 0) {
        bIsDeleting = true
        idPwdDialog.visible = false
        MyDownloader.deleteQuiz(idImport.sSelectedQ,
                                idPwdTextInput.displayText,
                                idServerListView.currentIndex)
        idPwdTextInput.text = ""
      } else
        idPwdDialog.visible = true
    }
  }

  ButtonQuiz {
    id: idLoadQuiz
    text: "Download"
    bProgVisible: bIsDownloading
    width: n4BtnWidth
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    anchors.right: parent.right
    anchors.rightMargin: 20
    onClicked: {
      bIsDownloading = true
      idTextInputQuizName.text = idImport.sSelectedQ
      sQuizName  = idImport.sSelectedQ
      MyDownloader.importQuiz(idImport.sSelectedQ)
    }
  }


  states:
    State {
      name: "Show"
      PropertyChanges { target: idContainer; visible: true }
    }
}
