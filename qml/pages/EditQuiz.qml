import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib

Item {

  id:idEditQuiz

  property int nLastSearch : 0
  onVisibleChanged:
  {
    if (visible)
    {
      idGlosList.currentIndex = idWindow.nGlosaTakeQuizIndex
      idGlosList.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex, ListView.Center)
    }
  }

  Column
  {
    id: idMainColumn
    spacing:20
    anchors.topMargin: 20
    anchors.fill: parent

    XmlListModel {
      id: idTrTextModel
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          if (idTrTextModel.count <= 0)
          {
            return
          }

          if (nLastSearch != 1)
            idTextInput2.text =  idTrTextModel.get(0).text1
          else
            idTextInput.text =  idTrTextModel.get(0).text1

          idTrSynModel.query = "/DicResult/def/tr[1]/syn"
          idTrMeanModel.query = "/DicResult/def/tr[1]/mean"
        }
      }

      query: "/DicResult/def/tr"
      XmlRole { name: "count1"; query: "count(syn)" }
      XmlRole { name: "text1"; query: "text/string()" }
    }

    XmlListModel {
      id: idTrSynModel
      XmlRole { name: "syn"; query: "text/string()" }
    }

    XmlListModel {
      id: idTrMeanModel
      XmlRole { name: "mean"; query: "text/string()" }
    }

    // From the translation API
    XmlListModel {
      id: idTranslateModel
      property var oBtn
      query: "/Translation"
      XmlRole { name: "trans"; query: "text/string()" }
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          oBtn.bProgVisible = false;
          if (idTranslateModel.count <= 0)
          {
            idTextTrans.text = "-"
            return
          }

          idTextTrans.text =  idTranslateModel.get(0).trans
        }
      }
    }

    Item
    {
      height:idTextInput.height
      width:parent.width
      TextList
      {
        id:idTextTrans
        text :"-"
        onClick:
        {
          if (nLastSearch != 1)
            idTextInput2.text = idTextTrans.text
          else
            idTextInput.text = idTextTrans.text
        }
      }
      ButtonQuizImg
      {
        anchors.bottom: parent.bottom
        x:idTextInput.width - width
        source: "image://theme/icon-s-clipboard?" + (focus ? Theme.highlightColor : Theme.primaryColor)
        onClicked:
        {
          focus = true
          sSearchQuery = idTextInput.text
          MyDownloader.toClipBoard(idTextInput.text)
        }
      }

      ButtonQuizImg
      {
        x :idTextInput2.x + idTextInput.width - width
        anchors.bottom: parent.bottom
        source: "image://theme/icon-s-clipboard?" + (focus ? Theme.highlightColor : Theme.primaryColor)
        onClicked:{
          focus = true
          sSearchQuery = idTextInput2.text
          MyDownloader.toClipBoard(idTextInput2.text)
        }

      }
    }

    Row
    {
      spacing : 20
      width:parent.width
      height: Theme.fontSizeLarge
      InputTextQuiz
      {
        id:idTextInput
        width: parent.width / 2 - 10
      }
      InputTextQuiz
      {
        id:idTextInput2
        width: parent.width / 2 - 10
      }
    }

    Row
    {
      id:idBtnRow
      spacing:10
      height: idBtn1.height


      ButtonQuiz {
        id:idBtn1
        width:n4BtnWidth
        text:  sLangLang
        onClicked: {
          nLastSearch = 0

          var oInText  = QuizLib.getTextFromInput(idTextInput)
          if (oInText.length < 1 )
          {
            return
          }

          bProgVisible = true
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrl , oInText )
          idTranslateModel.oBtn = idBtn1
          idTranslateModel.source = sReqUrl + oInText
        }
      }


      ButtonQuiz {
        id:idBtn2
        width:n4BtnWidth
        text:  sLangLangRev
        onClicked: {
          nLastSearch = 1
          var oInText  = QuizLib.getTextFromInput(idTextInput2)
          if (oInText.length < 1 )
          {
            return
          }
          bProgVisible = true
          if (bHasDictFrom)
            QuizLib.downloadDictOnWord(sReqDictUrlRev , oInText)
          idTranslateModel.oBtn = idBtn2
          idTranslateModel.source = sReqUrlRev + oInText
        }
      }

      ButtonQuiz {
        id:idBtn3
        width:n4BtnWidth
        text:  sLangLangEn
        onClicked: {
          nLastSearch = 2
          var oInText  = QuizLib.getTextFromInput(idTextInput)
          if (oInText.length < 1 )
          {
            return
          }

          bProgVisible = true
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrlEn , oInText)
          idTranslateModel.oBtn = idBtn3
          idTranslateModel.source = sReqUrlEn + oInText

        }
      }

      ButtonQuiz {
        width:n4BtnWidth
        text: "Add"
        onClicked: {

          // Find a new Id
          var nC = 0;

          var sNewWordFrom = QuizLib.getTextFromInput(idTextInput)
          var sNewWordTo = QuizLib.getTextFromInput(idTextInput2)

          for(var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).question === sNewWordFrom && glosModel.get(i).answer === sNewWordTo)
            {
              idErrorText2.visible = true
              idErrorText2.text = idTextInput.text + " Already in quiz!"
              return;
            }

            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number;
          }

          nC += 1;

          if (bHasSpeech)
            MyDownloader.downloadWord(sNewWordTo,sToLang)
          if (bHasSpeechFrom)
            MyDownloader.downloadWord(sNewWordFrom,sFromLang)

          QuizLib.insertGlosa(nDbNumber,nC, sNewWordFrom, sNewWordTo)

        }
      }

    }

    TextList
    {
      visible:false
      id:idErrorText
      color: "red"
      onClick: visible = false
    }
    TextList
    {
      visible:false
      id:idErrorText2
      color: "red"
      onClick: visible = false
    }
    Row
    {
      id:idDictRow
      height: n3BtnWidth
      width:parent.width

      ListViewHi {
        id:idDicList
        width:n3BtnWidth + 60
        height : parent.height
        model:idTrTextModel
        highlightFollowsCurrentItem: true

        delegate: Row {

          TextList {
            id:idSearchItem
            width:idDicList.width
            text:  text1 + " " + ( count1 > 0 ? "..." : "")
            MouseArea
            {
              anchors.fill: parent
              onClicked:
              {
                idDicList.currentIndex = index

                if (nLastSearch != 1)
                  idTextInput2.text = idSearchItem.text.replace("...","");
                else
                  idTextInput.text = idSearchItem.text.replace("...","");

                idTrSynModel.query = "/DicResult/def/tr["  +(index + 1) + "]/syn"
                idTrMeanModel.query = "/DicResult/def/tr["  +(index + 1) + "]/mean"
              }
            }
          }
        }
      }
      ListView
      {
        model : idTrSynModel
        width:n3BtnWidth
        height : parent.height
        delegate: TextList {
          id:idSynText
          text:syn
          onClick:
          {
            if (nLastSearch != 1)
              idTextInput2.text = idSynText.text;
            else
              idTextInput.text = idSynText.text;
          }
        }
      }
      ListView
      {
        model : idTrMeanModel
        width:n3BtnWidth
        height : parent.height
        delegate: TextList {

          id:idMeanText
          text:mean
          onClick:
          {
            if (nLastSearch != 1)
              idTextInput.text = idMeanText.text;
            else
              idTextInput2.text = idMeanText.text;
          }
        }
      }
    }

    Row {
      id:idTableHeaderRow
      spacing: 5
      TextList {
        id:idHeader1Text
        color:"steelblue"
        font.bold:bQSort
        width:n25BtnWidth
        text:  "Question"
        onClick: {
          bQSort = true
          QuizLib.sortModel()
        }
      }

      TextList {
        color:"steelblue"
        font.bold:!bQSort
        width:n25BtnWidth
        text: "Answer"
        onClick: {
          bQSort = false
          QuizLib.sortModel()
        }
      }
    }
    ListViewHi {
      id:idGlosList
      height: idAppWnd.height - idDictRow.height - idBtnRow.height * 6
              - idTextInput.height - idHeader1Text.height - Theme.itemSizeExtraSmall

      width:parent.width
      spacing: 3
      Component.onCompleted:
      {
        idWindow.glosListView = idGlosList
      }
      model: glosModel
      delegate: Row {
        spacing:5

        TextList {
          id: idQuestionText
          width: n3BtnWidth
          text:  question
          color: state1 === 0 ? Theme.primaryColor : "green"
          onPressAndHold: idTextInput.text = question
        }

        TextList {
          id:idAnswer
          width: n25BtnWidth
          text: answer
          font.bold: extra.length > 0
          color: state1 === 0 ? Theme.primaryColor : "green"
          onPressAndHold: idTextInput2.text = answer
        }

        ButtonQuizImg
        {
          id:idRmBtn
          height:idAnswer.height
          width:idAnswer.height
          source: "image://theme/icon-s-edit"
          onClicked:
          {
            idEditDlg.visible = true
            idTextEdit1.text = question
            idTextEdit2.text = answer
            idTextEdit3.text = extra
            idGlosState.checked = state1 !== 0
            idGlosList.currentIndex = index
            idWindow.nGlosaTakeQuizIndex = index
          }
        }
        ButtonQuizImg
        {
          height:idAnswer.height
          width:idAnswer.height
          visible:bHasSpeechFrom
          source:"qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(question,sFromLang)
        }
        ButtonQuizImg
        {
          height:idAnswer.height
          width:idAnswer.height
          visible:bHasSpeech
          source:"qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(answer,sToLang)
        }
      }
    }
  }
  Row
  {
    id:idLowerButtonRow
    y: idTab2.height - (Theme.itemSizeExtraSmall*1.6)
    spacing:10
    Button
    {
      id:idResetBtn

      text : "Reset"
      onClicked:
      {
        QuizLib.resetQuiz()
      }

    }

    Button
    {
      id:idReverseBtn
      text : "Reverse"
      onClicked:
      {
        QuizLib.reverseQuiz()
      }
    }
  }

  RectRounded
  {
    id:idEditDlg
    visible : false
    width:parent.width
    height:Theme.itemSizeExtraSmall*4
    color :Theme.overlayBackgroundColor
    onCloseClicked: idEditDlg.visible = false

    Column
    {
      anchors.top: idEditDlg.bottomClose

      TextField
      {
        id:idTextEdit3
        width:idEditDlg.width
        labelVisible : false
        placeholderText : "Additional Information e.g wordclass"
      }

      Row
      {
        width:parent.width
        TextField
        {
          id:idTextEdit1
          height: Theme.fontSizeLarge * 1.5
          labelVisible : false
          width: parent.width / 2
        }
        TextField
        {
          id:idTextEdit2
          height: Theme.fontSizeLarge * 1.5
          labelVisible : false
          width: parent.width / 2
        }
      }
    }


    Label
    {
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idGlosState.left
      anchors.rightMargin: 20
      text: "Done:"
    }


    ButtonQuiz
    {
      id:idGlosState
      property bool checked : false
      anchors.verticalCenter: idBtnUpdate.verticalCenter
      anchors.right: idBtnUpdate.left
      anchors.rightMargin: 20
      Image {
        visible: parent.checked
        anchors.centerIn: parent
        source: "image://theme/icon-m-accept"
      }
      height :  Theme.itemSizeExtraSmall
      width:  Theme.itemSizeExtraSmall
      onClicked: {
        checked = !checked
      }
    }

    ButtonQuiz {
      id:idBtnUpdate
      width:n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idBtnDelete.left
      anchors.rightMargin: 20
      text:  "Update"
      onClicked: {
        QuizLib.updateQuiz()
        idGlosList.positionViewAtIndex(idGlosList.currentIndex, ListView.Center)
      }
    }

    ButtonQuiz {
      id:idBtnDelete
      width:n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      text:  "Delete"
      onClicked: {
        QuizLib.deleteWordInQuiz()
      }
    }
  }
}

