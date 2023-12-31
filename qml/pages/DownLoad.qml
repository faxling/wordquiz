import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

RectRounded {
  id: idContainer
  y: 20
  visible: false
  width: parent.width
  height: parent.width / 1.5
  property bool bIsDownloading: false
  property bool bIsDownloadingList
  property bool bIsDeleting: false
  property string sSelectedQ
  property int nSelectedQ
  property string sImportMsg: ""
  property string sDesc1: ""
  property string sDescDate: ""
  property int nError

  property alias currentIndex: idServerListView.currentIndex
  property alias currentItem: idServerListView.currentItem
  function positionViewAtIndex(nIndex) {
    idServerListView.positionViewAtIndex(nIndex, ListView.Center)
  }

  onNErrorChanged: {
    if (nError === 0) {
      sImportMsg = ""
    }
    if (nError === 1) {
      sImportMsg = "Network Error!"
    }
    if (nError === 2) {
      sImportMsg = "No Quiz aviailable!"
    }
  }

  onCloseClicked: {
    idContainer.state = ""
    idPwdDialog.visible = false
    bIsDeleting = false
    idPwdTextInput.text = ""
  }

  Text {
    id: idDescText
    font.pixelSize: Theme.fontSizeTiny
    color: Theme.highlightColor
    anchors.top: idImport.top
    anchors.topMargin: 10
    x: 20
    text: sDesc1
  }

  Text {
    id: idDescDate
    font.pixelSize: Theme.fontSizeTiny
    color: Theme.highlightColor
    anchors.top: idDescText.bottom
    anchors.topMargin: 5
    x: 20
    text: sDescDate
  }

  Row {
    id: idFilterRow
    width: parent.width
    height: Theme.fontSizeLarge
    anchors.top: idImport.bottomClose
    anchors.topMargin: 15
    InputTextQuizSilicaEx {
      id: idTextEdit1
      placeholderText: "Filter on name and lang (eg en_)"

      onDisplayTextChanged: {
        MyDownloader.setFilterQList(displayText)
      }
      height: Theme.fontSizeLarge * 1.5
      labelVisible: false
      width: parent.width - 10
    }
  }

  TextList {
    id: idImportMsg
    x: parent.width / 2
    anchors.top: idDescText.top
    color: "red"
    text: sImportMsg
  }

  ListViewHi {
    id: idServerListView

    highlightFollowsCurrentItem: true
    anchors.top: idFilterRow.bottom
    anchors.topMargin: 5
    width: idImport.width - 20
    x: 10
    height: parent.height - idDeleteQuiz.height * 3 + 10
    model: oFilteredQListModel

    onCurrentItemChanged: {
      if (currentItem == null) {
        idContainer.sSelectedQ = ""
        nSelectedQ = -1
        idContainer.sImportMsg = ""
        idContainer.sDesc1 = "-"
        idContainer.sDescDate = "-"
        return
      }
      var j = currentItem.nNumber
      j = MyDownloader.indexFromGlosNr(idServerQModel, j)
      var o = idServerQModel.get(j)
      idContainer.sSelectedQ = o.qname
      nSelectedQ = o.number
      idContainer.sImportMsg = ""
      idContainer.sDesc1 = o.desc1
      idContainer.sDescDate = o.date1
    }

    delegate: Item {
      property int nW: idServerListView.width / 6
      property int nNumber: number
      width: idServerListView.width
      height: idServerRow.height
      Row {
        id: idServerRow

        TextList {
          width: nW * 4
          id: idTextQname
          text: qname
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

      MouseArea {
        anchors.fill: idServerRow
        onClicked: {


          /*
          nSelectedQ = number
          idContainer.sImportMsg = ""
          idContainer.sDesc1 = desc1
          idContainer.sDescDate = date1
          idContainer.sSelectedQ = qname
          */
          idServerListView.currentIndex = index
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
        text: "Password to remove '" + idImport.sSelectedQ.substring(0, 7) + "'"
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
    bProgVisible: bIsDeleting
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
                                idPwdTextInput.displayText, idImport.nSelectedQ)
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
      sQuizName = idImport.sSelectedQ
      MyDownloader.importQuiz(idImport.sSelectedQ, idProgress)
    }
  }

  Rectangle {
    id: idProgress
    anchors.bottom: idLoadQuiz.top
    anchors.bottomMargin: 10
    x: 20
    property double progress
    color: "orange"
    height: Theme.paddingSmall
    width: (parent.width - 40) * progress
  }

  states: [
    State {
      name: "Back"
      PropertyChanges {
        target: idContainer
        visible: true
      }
    }
  ]
}
