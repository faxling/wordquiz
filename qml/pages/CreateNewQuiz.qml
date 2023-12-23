import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib

Item {

  property var oFilteredQListModel

  Column {
    id: idTopColumn
    spacing: 20
    anchors.topMargin: 20
    anchors.bottomMargin: 50
    anchors.fill: parent

    TextList {
      x: idDescText.x
      id: idDateDesc1
      text: idWindow.sQuizDate
    }

    Row {
      id: idDescText
      TextList {
        id: idTextSelected
        width: idTopColumn.width / 2
        onClick: idTextInputQuizName.text = idTextSelected.text
      }

      TextList {
        id: idDescTextOnPage
        text: idWindow.sQuizDesc
      }
    }

    InputTextQuiz {
      id: idTextInputQuizName
      visible: idLangListRow.visible
      width: parent.width
    }

    Row {
      id: rowCreateButtons
      spacing: 10
      width: parent.width
      ButtonQuiz {
        id: btnCreate1
        text: ""
        width: n3BtnWidth

        onClicked: {
          idLangListRow.visible = !idLangListRow.visible
        }
        Image {
          anchors.centerIn: parent
          source: "image://theme/icon-m-add?"
                  + (idLangListRow.visible ? Theme.highlightColor : Theme.primaryColor)
        }
      }

      ButtonQuiz {
        width: n3BtnWidth
        text: ""
        onClicked: {
          idExport.visible = true
          idExportError.visible = false
        }
        Image {
          anchors.centerIn: parent
          source: "image://theme/icon-m-cloud-upload"
        }
      }

      ButtonQuiz {
        id: idDownloadBtn
        width: n3BtnWidth
        text: ""
        onClicked: {
          bProgVisible = true
          // signals with quizListDownloadedSignal
          MyDownloader.listQuiz()
        }
        Image {
          anchors.centerIn: parent
          source: "image://theme/icon-m-cloud-download"
        }
      }
    }

    Row {
      id: idLangListRow
      width: parent.width
      height: n3BtnWidth
      spacing: 10
      visible: false

      function doCurrentIndexChanged() {
        if (idLangList1.currentIndex < 0 || idLangList1.currentIndex < 0)
          return
        sLangLangSelected = idLangModel.get(
              idLangList1.currentIndex).code + "-" + idLangModel.get(
              idLangList2.currentIndex).code

        var sPreFix = "New Quiz "
        var nL = sPreFix.length
        if ((idTextInputQuizName.displayText.substring(0, nL) === sPreFix)
            || idTextInputQuizName.displayText.length < 3)
          idTextInputQuizName.text = sPreFix + sLangLangSelected
      }

      ListViewHi {
        id: idLangList1
        onCurrentIndexChanged: {
          idLangListRow.doCurrentIndexChanged()
        }
        width: n3BtnWidth
        height: parent.height
        model: idLangModel
        delegate: TextList {
          text: lang
          width: idLangList1.width
          onClick: idLangList1.currentIndex = index
        }
      }

      Column {
        Text {
          id: idLangPair
          horizontalAlignment: Text.AlignHCenter
          font.pixelSize: Theme.fontSizeLarge
          width: n3BtnWidth
          text: sLangLangSelected
          color: Theme.primaryColor
        }

        ButtonQuiz {
          id: btnCreate2
          width: n3BtnWidth
          text: "Create"
          onClicked: QuizLib.newQuiz()
        }
      }

      ListViewHi {
        id: idLangList2
        width: n3BtnWidth
        height: parent.height
        model: idLangModel
        onCurrentIndexChanged: {
          idLangListRow.doCurrentIndexChanged()
        }

        delegate: TextList {
          text: lang
          width: idLangList1.width
          horizontalAlignment: Text.AlignRight
          onClick: idLangList2.currentIndex = index
        }
      }
    }

    TextList {
      id: idTextAvailable
      color: "steelblue"
      text: "Available Quiz's:"
    }

    ListViewHi {
      id: idQuizList
      width: parent.width
      height: parent.height - idTextAvailable.x - idTextAvailable.height
              - idDownloadBtn.height * 3 - (idLangListRow.visible ? n2BtnWidth : 0)
      model: glosModelIndex
      spacing: 5

      Component.onCompleted: {
        QuizLib.connectMyDownloader()
      }

      onCurrentIndexChanged: {
        if (nGlosaDbLastIndex >= 0) {
          QuizLib.loadFromQuizList()
        } else {
          nGlosaDbLastIndex = 0
        }
      }

      delegate: Item {
        height: idQuizListRow.height
        width: idQuizListRow.width
        Row {
          id: idQuizListRow

          TextList {
            id: idCol1
            width: n4BtnWidth * 2
            text: quizname
          }
          TextList {
            id: idCol2
            width: n4BtnWidth
            text: langpair
          }
          Item {
            width: n4BtnWidth
            height: idCol1.height
            TextList {
              id: idCol3
              text: state1
            }

            ButtonQuizImg {
              id: idEdtBtn
              anchors.right: parent.right
              height: idCol1.height
              source: "image://theme/icon-s-edit"
              onClicked: {
                idQuizNameInput.text = quizname
                idEditQuizEntryDlg.visible = true
                idQuizList.currentIndex = index
              }
            }
          }
        }
        MouseArea {
          anchors.fill: idQuizListRow
          anchors.rightMargin: idEdtBtn.width
          onClicked: {
            idQuizList.currentIndex = index
          }
        }
      }
    }
  }

  RectRounded {
    id: idExport
    y: 20
    visible: false
    width: parent.width
    height: parent.width / 1.5

    onCloseClicked: {
      idExport.visible = false
    }

    TextList {
      id: idExportTitle
      anchors.top: idExport.bottomClose
      x: 20
      text: "Add a description off the quiz '" + sQuizName + "'"
    }

    InputTextQuiz {
      id: idTextInputQuizDesc
      width: parent.width - 20
      x: 10
      anchors.top: idExportTitle.bottom
    }

    TextList {
      id: idExportPwd
      x: 20
      anchors.top: idTextInputQuizDesc.bottom
      text: "and a pwd used for deletion/update"
    }

    InputTextQuiz {
      id: idTextInputQuizPwd
      width: parent.width - 20
      x: 10
      anchors.top: idExportPwd.bottom
      text: "*"
    }

    TextList {
      id: idExportError
      x: 20
      anchors.top: idTextInputQuizPwd.bottom
      color: "red"
      text: "error"
    }

    ButtonQuiz {
      id: idUpdateDescBtn
      text: "OK"
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idUpdateBtn.left
      anchors.rightMargin: 20
      onClicked: {
        idExport.visible = false
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
      }
    }

    ButtonQuiz {
      id: idUpdateBtn
      text: "Update"
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idExportBtn.left
      anchors.rightMargin: 20
      onClicked: {
        bProgVisible = true
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
        MyDownloader.updateCurrentQuiz(glosModel, sQuizName, sLangLang,
                                       idTextInputQuizPwd.displayText,
                                       idTextInputQuizDesc.displayText,
                                       idProgressUpload)
      }
    }

    ButtonQuiz {
      id: idExportBtn
      width: n4BtnWidth
      text: "Upload"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      onClicked: {
        bProgVisible = true
        QuizLib.updateDesc1(idTextInputQuizDesc.displayText)
        MyDownloader.exportCurrentQuiz(glosModel, sQuizName, sLangLang,
                                       idTextInputQuizPwd.displayText,
                                       idTextInputQuizDesc.displayText,
                                       idProgressUpload)
      }
    }

    Rectangle {
      id: idProgressUpload
      x: 10
      anchors.bottom: idExportBtn.top
      anchors.bottomMargin: 5
      property double progress
      color: "orange"
      height: Theme.paddingSmall
      width: (parent.width - 20) * progress
    }
  }

  DownLoad {
    id: idImport
    y: 20
    visible: false
    width: parent.width
    height: parent.width / 1.5
  }

  RectRounded {
    id: idErrorDialog
    property alias text: idWhiteText.text
    visible: false
    anchors.horizontalCenter: parent.horizontalCenter
    y: 20
    height: nDlgHeight
    width: parent.width

    Label {
      id: idWhiteText
      x: 20
      anchors.top: idErrorDialog.bottomClose
      text: "'" + idQuizNameInput.displayText + "'" + " To short Quiz name"
    }

    onCloseClicked: {
      idErrorDialog.visible = false
    }
  }

  RectRounded {
    id: idEditQuizEntryDlg
    visible: false
    y: 50
    width: parent.width
    height: Theme.itemSizeExtraSmall * 3.7
    Column {
      x: 20
      width: parent.width - 40
      anchors.top: parent.bottomClose
      spacing: 5
      Label {
        id: idAddInfo
        text: "Quiz Name:"
      }

      InputTextQuiz {
        id: idQuizNameInput
        width: parent.width
      }
    } // Col

    ButtonQuiz {
      id: idBtnRename
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idBtnQuizDelete.left
      anchors.rightMargin: 20
      text: "Rename"
      onClicked: {
        QuizLib.renameQuiz(idQuizNameInput.displayText)
        idEditQuizEntryDlg.visible = false
      }
    }

    ButtonQuiz {
      id: idBtnQuizDelete
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      text: "Delete"
      onClicked: Remorse.popupAction(idTopColumn,
                                     "Delete Quiz " + idTextSelected.text,
                                     function () {

                                       db.transaction(function (tx) {

                                         tx.executeSql(
                                               'DELETE FROM GlosaDbIndex WHERE dbnumber = ?',
                                               [nDbNumber])
                                         tx.executeSql(
                                               'DROP TABLE Glosa' + nDbNumber)
                                         tx.executeSql(
                                               'DELETE FROM GlosaDbDesc WHERE dbnumber = ?',
                                               [nDbNumber])
                                       })

                                       glosModelIndex.remove(
                                             idQuizList.currentIndex)

                                       idEditQuizEntryDlg.visible = false
                                     })
    }

    onCloseClicked: {
      idEditQuizEntryDlg.visible = false
    }
  } // Rectangle

  ListModel {
    id: idServerQModel
    ListElement {
      qname: "-"
      code: ""
      state1: ""
      desc1: ""
      date1: ""
    }
    Component.onCompleted: {
      oFilteredQListModel = MyDownloader.setFilterProxy(idServerQModel)
    }
  }

  ListModel {
    id: idLangModel
    ListElement {
      lang: "Swedish"
      code: "sv"
    }
    ListElement {
      lang: "Russian"
      code: "ru"
    }
    ListElement {
      lang: "French"
      code: "fr"
    }
    ListElement {
      lang: "Italian"
      code: "it"
    }
    ListElement {
      lang: "English"
      code: "en"
    }
    ListElement {
      lang: "Hungarian"
      code: "hu"
    }
    ListElement {
      lang: "Norvegian"
      code: "no"
    }
    ListElement {
      lang: "Spanish"
      code: "es"
    }
    ListElement {
      lang: "Polish"
      code: "pl"
    }
    ListElement {
      lang: "German"
      code: "de"
    }
  }
} // Item
