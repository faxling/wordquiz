import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib

Item
{
  property alias nQuizListCurrentIndex: idQuizList.currentIndex

  ListModel {
    id:idServerQModel
    ListElement {
      qname: "-"
      code:""
      state1:""
      desc1:""
    }
  }

  ListModel {
    id:idLangModel
    ListElement {
      lang: "Swedish"
      code:"sv"
    }
    ListElement {
      lang: "Russian"
      code:"ru"
    }
    ListElement {
      lang: "French"
      code:"fr"
    }
    ListElement {
      lang: "Italian"
      code:"it"
    }
    ListElement {
      lang: "English"
      code:"en"
    }
    ListElement {
      lang: "Hungarian"
      code:"hu"
    }
    ListElement {
      lang: "Norvegian"
      code:"no"
    }
    ListElement {
      lang: "Spanish"
      code:"es"
    }
    ListElement {
      lang: "Polish"
      code:"pl"
    }
  }

  Column
  {
    id:idTopColumn
    spacing:20
    anchors.topMargin: 20
    anchors.bottomMargin: 50
    anchors.fill: parent

    Row
    {
      TextList
      {
        id:idTextSelected
        width:idTopColumn.width/2
        onClick: idTextInputQuizName.text = idTextSelected.text
      }

      TextList
      {
        id:idDescTextOnPage
        text:"---"
      }
    }

    InputTextQuiz
    {
      id:idTextInputQuizName
      width:parent.width
      text:"new"
    }

    Row
    {
      id:rowCreateButtons
      spacing:10
      width:parent.width
      ButtonQuiz
      {
        text:"New Quiz"
        width: n3BtnWidth

        onClicked:
        {
          QuizLib.newQuiz()
        }
      }

      ButtonQuiz
      {
        width: n3BtnWidth
        text:"Upload"
        onClicked:
        {
          idExport.visible = true
          idExportError.visible = false
        }
      }

      ButtonQuiz
      {
        id: idDownloadBtn
        width: n3BtnWidth
        text:"Download"
        onClicked:
        {
          bProgVisible = true
          MyDownloader.listQuiz()
        }
      }

    }

    Row
    {
      id:idLangListRow
      width:parent.width
      height : n3BtnWidth
      spacing:20

      function doCurrentIndexChanged()
      {
        if (idLangList1.currentIndex < 0 || idLangList1.currentIndex < 0)
          return
        sLangLangSelected = idLangModel.get(idLangList1.currentIndex).code + "-" + idLangModel.get(idLangList2.currentIndex).code
      }

      ListViewHi
      {
        id:idLangList1
        onCurrentIndexChanged:
        {
          idLangListRow.doCurrentIndexChanged()
        }
        width:n3BtnWidth
        height:parent.height
        model: idLangModel
        delegate: TextList {
          text:lang
          onClick: idLangList1.currentIndex = index
        }
      }

      Text
      {
        id:idLangPair
        font.pixelSize:Theme.fontSizeLarge
        width: n3BtnWidth
        text:sLangLangSelected
        color:Theme.primaryColor
      }

      ListViewHi
      {
        id:idLangList2
        width:n3BtnWidth
        height:parent.height
        model: idLangModel
        onCurrentIndexChanged:
        {
          idLangListRow.doCurrentIndexChanged()
        }

        delegate: TextList {
          text:lang
          onClick:idLangList2.currentIndex = index
        }
      }
    }

    TextList
    {
      id:idTextAvailable
      color: "steelblue"
      text:"Available Quiz's:"
    }

    ListViewHi
    {
      id:idQuizList
      width:parent.width
      height:Theme.itemSizeMedium * 4
      model:glosModelIndex
      spacing:5

      Component.onCompleted: {
        MyDownloader.exportedSignal.connect(QuizLib.quizExported)
        MyDownloader.quizDownloadedSignal.connect(QuizLib.loadFromList)
        MyDownloader.quizListDownloadedSignal.connect(QuizLib.loadFromServerList)
        MyDownloader.deletedSignal.connect(QuizLib.quizDeleted)
        idWindow.quizListView = idQuizList
      }

      onCurrentIndexChanged:
      {
        if (nGlosaDbLastIndex >= 0)
        {
          QuizLib.loadFromQuizList()
          idQuizNameInput.text = sQuizName
        }
        else
        {
          nGlosaDbLastIndex = 0
        }
      }

      delegate:
          Row
      {
        id:idQuizListRow

        TextList
        {
          id:idCol1
          width: Theme.itemSizeMedium*2.5
          text:quizname
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol2
          width: Theme.itemSizeMedium
          text:langpair
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol3
          width: Theme.itemSizeMedium
          text:state1
          onClick: idQuizList.currentIndex = index
        }

        ButtonQuizImg
        {
          id:idEdtBtn
          height:idCol1.height
          width:idCol1.height
          source: "image://theme/icon-s-edit"
          onClicked:
          {
            idEditQuizEntryDlg.visible = true
            idQuizList.currentIndex = index
          }
        }
      }
    }
  }

  RectRounded{
    id:idExport
    y:20
    visible: false
    width:parent.width
    height:parent.width / 1.5

    onCloseClicked: {
      idExport.visible = false
    }

    TextList {
      id:idExportTitle
      anchors.top :idExport.bottomClose
      x:20
      text:"Add a description off the quiz '" +sQuizName + "'"
    }

    InputTextQuiz
    {
      id:idTextInputQuizDesc
      width : parent.width - 20
      x:10
      anchors.top :idExportTitle.bottom
    }

    TextList {
      id:idExportPwd
      x:20
      anchors.top :idTextInputQuizDesc.bottom
      text:"and a pwd used for deletion/update"
    }

    InputTextQuiz
    {
      id:idTextInputQuizPwd
      width : parent.width - 20
      x:10
      anchors.top :idExportPwd.bottom
      text:"*"
    }

    TextList {
      id:idExportError
      x:20
      anchors.top :idTextInputQuizPwd.bottom
      color:"red"
      text:"error"
    }

    ButtonQuiz
    {
      id:idExportBtn
      width: n3BtnWidth
      text: "Upload"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        MyDownloader.exportCurrentQuiz( glosModel, sQuizName,sLangLang, idTextInputQuizPwd.displayText, idTextInputQuizDesc.displayText )
      }
    }

  }


  RectRounded{
    id:idImport
    y:20
    visible: false;
    width:parent.width
    height:parent.width / 1.5
    onCloseClicked:  {
      idPwdDialog.visible = false;
      idDeleteQuiz.bProgVisible = false
      idImport.visible = false
      idPwdTextInput.text = ""
    }

    TextList {
      id:idImportMsg
      x:parent.width / 2
      anchors.top :idDescText.top
      color:"red"
      text:""
    }

    TextList {
      id: idImportTitle
      anchors.top :idImport.bottomClose
      text:"Available Quiz"
    }
    TextList {
      anchors.right: idImport.right
      anchors.top :idImport.bottomClose
      anchors.rightMargin:20
      text:"Questions"
    }
    Text
    {
      id:idDescText
      color:Theme.highlightColor
      anchors.top :idImport.top
      anchors.topMargin:20
      x:20
      text:"---"
    }

    property string sSelectedQ : ""
    ListViewHi
    {
      id:idServerListView
      anchors.top :idImportTitle.bottom
      width:idImport.width
      height:parent.height - idDeleteQuiz.height *3
      model: idServerQModel
      delegate: Item {
        property int nW : idServerListView.width / 6
        width:idServerListView.width
        height: idServerRow.height
        Row
        {
          id:idServerRow
          TextList {
            width: nW *4
            id:idTextQname
            text:qname
            onClick:
            {
              idImportMsg.text = ""
              idDescText.text = desc1
              idImport.sSelectedQ = qname;
              idServerListView.currentIndex = index
            }
          }

          TextList
          {
            width:nW
            text:code
            height:parent.height
          }

          TextList
          {
            width:nW
            text:state1
            height:parent.height
          }
        }
      }
    }
    RectRounded
    {
      id:idPwdDialog
      border.width: 2
      border.color: Theme.primaryColor
      showClose: false
      visible:false
      height:70
      anchors.bottom: idDeleteQuiz.top
      anchors.bottomMargin: 60
      width:idServerListView.width
      Row
      {
        x:20
        anchors.verticalCenter:parent.verticalCenter
        spacing:20
        TextList
        {
          id:idPwdLabelText
          font.pixelSize: Theme.fontSizeExtraSmall
          anchors.verticalCenter:parent.verticalCenter
          text: "Password to remove '" + idImport.sSelectedQ +"'"
        }

        InputTextQuiz
        {
          width:idServerListView.width - idPwdLabelText.width - 60
          id:idPwdTextInput
        }
      }
    }

    ButtonQuiz
    {
      id:idDeleteQuiz
      width:n4BtnWidth
      text: "Remove"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idLoadQuiz.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        idPwdTextInput.text = idPwdTextInput.displayText
        if (idPwdTextInput.text.length > 0)
        {
          idPwdDialog.visible = false;
          MyDownloader.deleteQuiz(idImport.sSelectedQ, idPwdTextInput.displayText,idServerListView.currentIndex)
          idPwdTextInput.text = ""
        }
        else
          idPwdDialog.visible = true
      }
    }

    ButtonQuiz
    {
      id:idLoadQuiz
      text: "Download"
      width:n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: parent.right
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        MyDownloader.importQuiz(idImport.sSelectedQ)
      }
    }
  }

  RectRounded
  {
    id:idEditQuizEntryDlg
    visible : false
    y:50
    width:parent.width
    height:Theme.itemSizeExtraSmall*4
    Column
    {
      x:10
      width:parent.width
      anchors.verticalCenter: parent.verticalCenter
      spacing : 20
      Label
      {
        id:idAddInfo
        text: "Quiz Name:"
      }

      InputTextQuiz
      {
        id:idQuizNameInput
        width: parent.width  - 20
      }

      Row
      {
        id:idQuizUpdateBtnRow
        spacing:10
        ButtonQuiz {
          id:idBtnRename
          width:n3BtnWidth
          text:  "Rename"
          onClicked: {
            glosModelIndex.setProperty(idQuizList.currentIndex,"quizname", idQuizNameInput.displayText.trim())
            db.transaction(
                  function(tx) {
                    var nId = glosModelIndex.get(idQuizList.currentIndex).dbnumber;
                    tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[idQuizNameInput.displayText.trim(), nId]);
                    idTextSelected.text = idQuizNameInput.displayText
                    sQuizName = idTextSelected.text
                  }

                  )
            idEditQuizEntryDlg.visible = false
          }
        }
        ButtonQuiz {
          id:idBtnQuizDelete
          width:n3BtnWidth
          text:  "Delete"
          onClicked: Remorse.popupAction(idTopColumn,"Delete Quiz " + idTextSelected.text, function()
          {

            db.transaction(
                  function(tx) {

                    tx.executeSql('DELETE FROM GlosaDbIndex WHERE dbnumber = ?',[nDbNumber]);
                    tx.executeSql('DROP TABLE Glosa'+nDbNumber);
                    tx.executeSql('DELETE FROM GlosaDbDesc WHERE dbnumber = ?',[nDbNumber]);

                  }
                  )

            glosModelIndex.remove(idQuizList.currentIndex)

            if(idQuizList.currentIndex > 0)
              idQuizList.currentIndex = idQuizList.currentIndex -1;
            idEditQuizEntryDlg.visible = false
          }
          );
        }

      } // Row

    } // Col

    onCloseClicked:  {
      idEditQuizEntryDlg.visible = false
    }

  } // Rectangle
} // Item

