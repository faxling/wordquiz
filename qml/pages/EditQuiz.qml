import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib
import Sailfish.Pickers 1.0

Item {
  id: idEditQuiz
  property int nLastSearch: 0
  property bool bTabActive: false
  property bool bDoLookUppText1 : true

  onBTabActiveChanged: {
    if (bTabActive) {
      idGlosList.currentIndex = idWindow.nGlosaTakeQuizIndex
      idGlosList.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                     ListView.Center)
    } else {
      idEditDlg.visible = false
    }
  }

  Component {
    id: idImagePickerPage
    ImagePickerPage {
      onSelectedContentPropertiesChanged: {

        MyDownloader.setImgFile(idTextEdit1.text, sFromLang, idTextEdit2.text,
                                sToLang, selectedContentProperties.filePath)
        idEditWordImage.visible = true
        idEditWordImage.source = ""
        idEditWordImage.source = MyDownloader.imageSrc(idTextEdit1.text,
                                                       sFromLang)
      }
    }
  }

  Column {
    id: idMainColumn
    spacing: 20
    anchors.topMargin: 20
    anchors.fill: parent

    Item {
      id: idSearchResultRowItem
      height: idTextInput.height
      width: parent.width
      TextList {
        id: idTextTrans
        text: "-"
        onClick: {
          QuizLib.assignTextInputField(idTextTrans.text)
        }
      }
      ButtonQuizImg {
        anchors.bottom: parent.bottom
        x: idTextInput.width - width
        source: "image://theme/icon-s-clipboard?"
                + (focus ? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
          focus = true
          sSearchQuery = idTextInput.text
          MyDownloader.toClipBoard(idTextInput.text)
        }
      }

      ButtonQuizImg {
        x: idTextInput2.x + idTextInput.width - width
        anchors.bottom: parent.bottom
        source: "image://theme/icon-s-clipboard?"
                + (focus ? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
          focus = true
          sSearchQuery = idTextInput2.text
          MyDownloader.toClipBoard(idTextInput2.text)
        }
      }
    }

    Row {
      id: idIextInputToDictRow
      spacing: 20
      width: parent.width
      height: Theme.fontSizeLarge
      InputTextQuiz {
        id: idTextInput
        onGotFocus:  bDoLookUppText1 = true
        width: parent.width / 2 - 10
      }
      InputTextQuiz {
        id: idTextInput2
        onGotFocus:  bDoLookUppText1 = false
        width: parent.width / 2 - 10
      }
    }

    Row {
      id: idBtnRow
      spacing: 10
      height: idBtn1.height

      ButtonQuiz {
        id: idBtn1
        width: n4BtnWidth
        text: sLangLang
        onClicked: {
          nLastSearch = 0

          var oInText = QuizLib.getTextFromInput(idTextInput)
          if (oInText.length < 1) {
            return
          }

          bProgVisible = true
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrl, oInText)
          idTranslateModel.oBtn = idBtn1
          idTranslateModel.source = sReqUrl + oInText
        }
      }

      ButtonQuiz {
        id: idBtn2
        width: n4BtnWidth
        text: sLangLangRev
        onClicked: {
          nLastSearch = 1
          var oInText = QuizLib.getTextFromInput(idTextInput2)
          if (oInText.length < 1) {
            return
          }
          bProgVisible = true
          if (bHasDictFrom)
            QuizLib.downloadDictOnWord(sReqDictUrlRev, oInText)
          idTranslateModel.oBtn = idBtn2
          idTranslateModel.source = sReqUrlRev + oInText
        }
      }

      ButtonQuiz {
        id: idBtn3
        width: n4BtnWidth
        text:   (bDoLookUppText1 ? sQuestionLang : sAnswerLang) + " Wiki"
        onClicked: {
          var oInText
          var sLang = bDoLookUppText1 ? sQuestionLang : sAnswerLang

          if (bDoLookUppText1)
            oInText   = QuizLib.getTextFromInput(idTextInput)
          else
            oInText   = QuizLib.getTextFromInput(idTextInput2)

          onClicked: Qt.openUrlExternally("http://"+sLang+ ".wiktionary.org/w/index.php?title=" +oInText.toLowerCase() )
        }
      }

      ButtonQuiz {
        id:idAddBtn
        text: "Add"
        width: n4BtnWidth
        onClicked: QuizLib.getTextInputAndAdd()
      }
    }


    Row {
      id: idDictRow
      height: n4BtnWidth - 20
      width: parent.width

      TextList {
        id: idErrorText
        visible: false
        color: "red"
        onClick: visible = false
      }
      TextList {
        id: idErrorText2
        visible: false
        color: "red"
        onClick: visible = false
      }

      ListViewHi {
        id: idDicList
        width: n3BtnWidth + 60
        height: parent.height
        model: idTrTextModel
        highlightFollowsCurrentItem: true

        delegate: Row {

          TextList {
            id: idSearchItem
            width: idDicList.width
            text: text1 + " " + (count1 > 0 ? "..." : "")
            MouseArea {
              anchors.fill: parent
              onClicked: {
                idDicList.currentIndex = index

                var sText = idSearchItem.text.replace("...", "")
                QuizLib.assignTextInputField(sText)

                idTrSynModel.query = "/DicResult/def/tr[" + (index + 1) + "]/syn"
                idTrMeanModel.query = "/DicResult/def/tr[" + (index + 1) + "]/mean"
              }
            }
          }
        }
      }
      ListView {
        model: idTrSynModel
        clip: true
        width: n3BtnWidth
        height: parent.height
        delegate: TextList {
          id: idSynText
          text: syn
          onClick: {
            QuizLib.assignTextInputField(idSynText.text)
          }
        }
      }
      ListView {
        model: idTrMeanModel
        width: n3BtnWidth
        height: parent.height
        delegate: TextList {
          id: idMeanText
          text: mean
          onClick: {
            QuizLib.assignTextInputField(idMeanText.text)
          }
        }
      }
    }

    Row {
      id: idTableHeaderRow
      height : idHeader1Text.height - 20
      spacing: 5
      TextList {
        id: idHeader1Text
        color: "steelblue"
        font.bold: bQSort
        width: n3BtnWidth
        text: "Question"
        onClick: {
          bQSort = true
          QuizLib.sortModel()
        }
      }

      TextList {
        color: "steelblue"
        font.bold: !bQSort
        width: n25BtnWidth
        text: "Answer"
        onClick: {
          bQSort = false
          QuizLib.sortModel()
        }
      }
    }
    ListViewHi {
      id: idGlosList
      height: idAppWnd.height - idDictRow.height - idBtnRow.height * 6.2
              - idTextInput.height - idHeader1Text.height - Theme.itemSizeExtraSmall

      width: parent.width
      spacing: 3
      Component.onCompleted: {
        idWindow.glosListView = idGlosList
      }
      model: glosModel
      delegate: Row {
        spacing: 5

        TextList {
          id: idQuestionText
          width: n3BtnWidth
          text: question
          color: state1 === 0 ? Theme.primaryColor : "green"
          onClick:
          {
            idTextInput.text = question
            bDoLookUppText1 = true
          }
        }

        TextList {
          id: idAnswer
          width: n25BtnWidth
          text: answer
          font.bold: extra.length > 0
          color: state1 === 0 ? Theme.primaryColor : "green"
          onClick:
          {
            idTextInput2.text = answer
            bDoLookUppText1 = false
          }
        }

        ButtonQuizImg {
          id: idRmBtn
          height: idAnswer.height
          width: idAnswer.height
          source: "image://theme/icon-s-edit"
          onClicked: {
            idEditDlg.visible = true
            idTextEdit1.text = question
            idTextEdit2.text = answer
            idTextEdit3.text = extra
            idGlosState.checked = state1 !== 0
            idGlosList.currentIndex = index
            idEditWordImage.visible = MyDownloader.hasImage(idTextEdit1.text,
                                                            sFromLang)
            idEditWordImage.source = idEditWordImage.visible ? MyDownloader.imageSrc(
                                                                 idTextEdit1.text,
                                                                 sFromLang) : ""
            idWindow.nGlosaTakeQuizIndex = index
          }
        }
        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          visible: bHasSpeechFrom
          source: "qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(question, sFromLang)
        }
        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          visible: bHasSpeech
          source: "qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(answer, sToLang)
        }
      }
    }
  }
  Row {
    id: idLowerButtonRow
    y: idTab2.height - (Theme.itemSizeExtraSmall * 1.6)
    spacing: 10
    Button {
      id: idResetBtn

      text: "Reset"
      onClicked: {
        QuizLib.resetQuiz()
      }
    }

    Button {
      id: idReverseBtn
      text: "Reverse"
      onClicked: {
        QuizLib.reverseQuiz()
      }
    }
  }

  RectRounded {
    id: idEditDlg
    visible: false
    width: parent.width
    height: Theme.itemSizeExtraSmall * 4
    color: Theme.overlayBackgroundColor
    onCloseClicked: idEditDlg.visible = false

    Column {
      id: idEditDldColumn
      anchors.top: idEditDlg.bottomClose

      InputTextQuizSilica {
        id: idTextEdit3
        width: idEditDlg.width
        labelVisible: false
        placeholderText: "Additional Information e.g wordclass"
      }

      Row {
        width: parent.width
        InputTextQuizSilica {
          id: idTextEdit1
          height: Theme.fontSizeLarge * 1.5
          labelVisible: false
          width: parent.width / 2
        }
        InputTextQuizSilica {
          id: idTextEdit2
          height: Theme.fontSizeLarge * 1.5
          labelVisible: false
          width: parent.width / 2
        }
      }
    }

    ButtonQuizImg {
      id: idAddImgBtn
      anchors.left: idEditDlg.left
      anchors.leftMargin: 20
      anchors.top: idEditDlg.top
      anchors.topMargin: 20
      source: "image://theme/icon-m-file-image"
      onClicked: {
        pageStack.push(idImagePickerPage)
      }
    }

    Image {
      id: idEditWordImage
      cache: false
      fillMode: Image.PreserveAspectFit
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 20
      height: 100
      width: 140
    }

    Label {
      id: idDoneLabel
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idGlosState.left
      anchors.rightMargin: 20
      text: "Done:"
    }

    ButtonQuiz {
      id: idGlosState
      property bool checked: false
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idBtnUpdate.left
      anchors.rightMargin: 20
      Image {
        visible: parent.checked
        anchors.centerIn: parent
        source: "image://theme/icon-m-accept"
      }
      height: Theme.itemSizeExtraSmall
      width: Theme.itemSizeExtraSmall
      onClicked: {
        checked = !checked
      }
    }

    ButtonQuiz {
      id: idBtnUpdate
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idBtnDelete.left
      anchors.rightMargin: 20
      text: "Update"
      onClicked: {
        QuizLib.updateQuiz()
        idGlosList.positionViewAtIndex(idGlosList.currentIndex, ListView.Center)
      }
    }

    ButtonQuiz {
      id: idBtnDelete
      width: n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      text: "Delete"
      onClicked: {
        QuizLib.deleteWordInQuiz()
      }
    }
  }

  XmlListModel {
    id: idTrTextModel
    onStatusChanged: {
      if (status === XmlListModel.Ready) {
        if (idTrTextModel.count <= 0) {
          return
        }

        QuizLib.assignTextInputField(idTrTextModel.get(0).text1)

        idTrSynModel.query = "/DicResult/def/tr[1]/syn"
        idTrMeanModel.query = "/DicResult/def/tr[1]/mean"
      }
    }

    query: "/DicResult/def/tr"
    XmlRole {
      name: "count1"
      query: "count(syn)"
    }
    XmlRole {
      name: "text1"
      query: "text/string()"
    }
  }

  XmlListModel {
    id: idTrSynModel
    XmlRole {
      name: "syn"
      query: "text/string()"
    }
  }

  XmlListModel {
    id: idTrMeanModel
    XmlRole {
      name: "mean"
      query: "text/string()"
    }
  }

  // From the translation API
  XmlListModel {
    id: idTranslateModel
    property var oBtn
    query: "/Translation"
    XmlRole {
      name: "trans"
      query: "text/string()"
    }
    onStatusChanged: {
      if (status === XmlListModel.Ready) {
        oBtn.bProgVisible = false
        if (idTranslateModel.count <= 0) {
          idTextTrans.text = "-"
          return
        }

        idTextTrans.text = idTranslateModel.get(0).trans
      }
    }
  }
}
