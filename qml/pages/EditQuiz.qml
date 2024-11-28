import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib
import Sailfish.Pickers 1.0
import QtQuick.Layouts 1.1

Item {
  id: idEditQuiz
  property int nLastSearch: 0
  property bool bTabActive: false
  property bool bDoLookUppText1: true

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
                                                       sLangLang)
        idGlosList.currentItem.hasImg = true
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
        Component.onCompleted: MyDownloader.storeTransText(idTextTrans,
                                                           idErrorText,
                                                           idDicList)

        text: "-"
        onTextChanged: QuizLib.assignTextInputField(idTextTrans.text)
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
          // focus = true
          // sSearchQuery = idTextInput.text
          MyDownloader.toClipBoard(idTextInput.text)
        }
      }

      ButtonQuizImg {
        x: idTextInput2.x
        source: "image://theme/icon-cover-transfers"
        anchors.bottom: parent.bottom
        onClicked: {
          var sFirst = idTextInput.displayText
          idTextInput.text = idTextInput2.displayText
          idTextInput2.text = sFirst
        }
      }

      ButtonQuizImg {
        x: idTextInput2.x + idTextInput.width - width
        anchors.bottom: parent.bottom
        source: "image://theme/icon-s-clipboard?"
                + (focus ? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
          //focus = true
          // sSearchQuery = idTextInput2.text
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
        onGotFocus: bDoLookUppText1 = true
        width: parent.width / 2 - 10
      }
      InputTextQuiz {
        id: idTextInput2
        onGotFocus: bDoLookUppText1 = false
        width: parent.width / 2 - 10
      }
    }

    RowLayout {
      id: idDictBtnRow
      spacing: 9
      height: idBtn1.height
      width: parent.width

      ButtonQuiz {
        id: idBtn1
        Layout.fillWidth: true
        Layout.minimumHeight: Theme.itemSizeExtraSmall
        Layout.minimumWidth: Theme.itemSizeExtraSmall
        text: sLangLang
        onClicked: {
          QuizLib.reqTranslation(idBtn1, false)
        }
      }

      ButtonQuiz {
        id: idBtn2
        Layout.fillWidth: true
        Layout.minimumHeight: Theme.itemSizeExtraSmall
        Layout.minimumWidth: Theme.itemSizeExtraSmall
        text: sLangLangRev
        onClicked: {
          QuizLib.reqTranslation(idBtn2, true)
        }
      }

      ButtonQuiz {
        id: idBtn3
        Layout.fillWidth: true
        Layout.minimumHeight: Theme.itemSizeExtraSmall
        Layout.minimumWidth: Theme.itemSizeExtraSmall
        text: (bDoLookUppText1 ? sFromLang : sToLang) + " Wiki"
        onClicked: {
          QuizLib.lookUppInWiki()
        }
      }
      ButtonQuiz {
        text: "Context"
        Layout.fillWidth: true
        Layout.minimumWidth: Theme.itemSizeExtraSmall
        Layout.minimumHeight: Theme.itemSizeExtraSmall
        onClicked: {
          QuizLib.lookUppInReverso()
        }
      }
      ButtonQuiz {
        id: idAddBtn
        text: "Add"
        Layout.fillWidth: true
        Layout.minimumWidth: Theme.itemSizeExtraSmall
        Layout.minimumHeight: Theme.itemSizeExtraSmall
        onClicked: QuizLib.getTextInputAndAdd()
      }
    }

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

    Row {
      id: idDictRow
      height: n4BtnWidth - 20
      width: parent.width

      ListViewHi {
        id: idDicList
        width: n3BtnWidth + 60
        height: parent.height
        highlightFollowsCurrentItem: true

        delegate: Row {

          TextList {
            id: idSearchItem
            width: idDicList.width
            text: modelData
            MouseArea {
              anchors.fill: parent
              onClicked: {
                idDicList.currentIndex = index
                var sText = idSearchItem.text
                QuizLib.assignTextInputField(sText)
                idSynListView.model = MyDownloader.synListFromWord(sText)
                idMeanListView.model = MyDownloader.meanListFromWord(sText)
              }
            }
          }
        }
      }
      ListView {
        id: idSynListView
        clip: true
        width: n3BtnWidth
        height: parent.height
        delegate: TextList {
          id: idSynText
          text: modelData
          onClick: {
            QuizLib.assignTextInputField(idSynText.text)
          }
        }
      }
      ListView {
        id: idMeanListView
        width: n3BtnWidth
        height: parent.height
        delegate: TextList {
          id: idMeanText
          text: modelData
        }
      }
    }

    Row {
      id: idTableHeaderRow
      height: idHeader1Text.height - 20
      spacing: 5
      TextList {
        id: idHeader1Text
        color: "steelblue"
        font.bold: nQuizSortRole === 0
        width: n3BtnWidth
        text: "Question"
        property bool bSortAsc: true
        onClick: {
          QuizLib.sortQuestionModel(0, this)
        }
      }

      TextList {
        color: "steelblue"
        font.bold: nQuizSortRole === 1
        width: n25BtnWidth
        text: "Answer"
        property bool bSortAsc: true
        onClick: {
          QuizLib.sortQuestionModel(1, this)
        }
      }
    }
    ListViewHi {
      id: idGlosList
      height: idEditQuiz.height - idDictRow.height - idTextInput.height
              - idHeader1Text.height - Theme.itemSizeSmall * 4
      width: parent.width
      spacing: 3
      Component.onCompleted: {
        idWindow.glosListView = idGlosList
      }
      model: glosModel
      delegate: Row {

        spacing: 5
        property bool hasImg: MyDownloader.hasImage(question, sFromLang)
        TextList {
          id: idQuestionText
          width: n3BtnWidth
          text: question
          color: state1 === 0 ? Theme.primaryColor : "green"
          onClick: {
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
          onClick: {
            idTextInput2.text = answer
            bDoLookUppText1 = false
          }
        }

        ButtonQuizImg {
          id: idRmBtn
          height: idAnswer.height
          width: idAnswer.height

          source: "image://theme/icon-s-edit?"
                  + (hasImg ? Theme.highlightColor : Theme.primaryColor)
          onClicked: {
            idEditDlg.visible = true
            idTextEdit1.text = question
            idTextEdit2.text = answer
            idTextEdit3.text = extra
            idGlosState.checked = state1 !== 0
            idGlosList.currentIndex = index
            idEditWordImage.source = MyDownloader.imageSrc(idTextEdit1.text,
                                                           sLangLang)
            idWindow.nGlosaTakeQuizIndex = index
          }
        }
        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          source: "qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(question, sFromLang)
        }
        ButtonQuizImg {
          height: idAnswer.height
          width: idAnswer.height
          source: "qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(answer, sToLang)
        }
      }
    }
  }

  RowLayout {
    id: idLowerButtonRow
    width: parent.width
    anchors.bottom: idEditQuiz.bottom
    anchors.bottomMargin: 20
    spacing: 10

    ButtonQuiz {
      id: idResetBtn
      text: "Reset"
      Layout.fillWidth: true
      Layout.minimumWidth: Theme.itemSizeExtraSmall
      onClicked: {
        idGlosState.checked = false
        QuizLib.resetQuiz()
      }
    }

    ButtonQuiz {
      id: idReverseBtn
      Layout.fillWidth: true
      Layout.minimumWidth: Theme.itemSizeExtraSmall

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
      source: sDEFAULT_IMG
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
}
