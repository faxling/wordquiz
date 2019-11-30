import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib

Item {

  id:idEditQuiz

  property int nLastSearch : 0

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
      function getTextFromInput(oTextInput)
      {
        var oInText  = oTextInput.displayText.trim()
        if (oInText.length < 1 )
        {
          idErrorText.visible = true
          idErrorText.text = "No input to lookup in dictionary"
          return "";
        }
        return oInText;
      }

      ButtonQuiz {
        id:idBtn1
        width:n4BtnWidth
        text:  sLangLang
        onClicked: {
          nLastSearch = 0

          var oInText  = idBtnRow.getTextFromInput(idTextInput)
          if (oInText.length < 1 )
          {
            return
          }

          bProgVisible = true
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrl , oInText,idBtn1 )
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
          var oInText  = idBtnRow.getTextFromInput(idTextInput2)
          if (oInText.length < 1 )
          {
            return
          }
          bProgVisible = true
          if (bHasDictFrom)
            QuizLib.downloadDictOnWord(sReqDictUrlRev , oInText,idBtn2)
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
          var oInText  = idBtnRow.getTextFromInput(idTextInput)
          if (oInText.length < 1 )
          {
            return
          }

          bProgVisible = true
          if (bHasDictTo)
            QuizLib.downloadDictOnWord(sReqDictUrlEn , oInText,idBtn3)
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

          var sNewWordFrom = idTextInput.displayText.trim()
          var sNewWordTo = idTextInput2.displayText.trim()

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
          glosModel.sortModel()
        }
      }

      TextList {
        color:"steelblue"
        font.bold:!bQSort
        width:n25BtnWidth
        text: "Answer"
        onClick: {
          bQSort = false
          glosModel.sortModel()
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
          width: n25BtnWidth
          id:idAnswer
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
            idGlosList.currentIndex = index
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
        var nC = glosModel.count

        if (nC===0)
          return
        db.transaction(
              function(tx) {
                tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
              }
              )

        glosModelWorking.clear()

        sScoreText = nC + "/" + nC
        for ( var i = 0; i < nC;++i) {
          glosModel.get(i).state1=0;
          glosModelWorking.append(glosModel.get(i))
        }

        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

        QuizLib.assignQuizModel(nIndexOwNewWord)

      }

    }

    Button
    {
      id:idReverseBtn

      text : "Reverse"
      onClicked:
      {
        bIsReverse =  !bIsReverse
        glosModelWorking.clear()
        var nC = glosModel.count
        if (nC === 0)
          return

        for ( var i = 0; i < nC;++i) {
          var nState = glosModel.get(i).state1;
          if (bIsReverse)
          {
            var squestion = glosModel.get(i).answer
            var sanswer = glosModel.get(i).question
          }
          else
          {
            squestion = glosModel.get(i).question
            sanswer = glosModel.get(i).answer
          }

          var sextra = glosModel.get(i).extra
          var nnC  = glosModel.get(i).number
          if (nState === 0 )
            glosModelWorking.append({"number": nnC, "question": squestion , "answer": sanswer,"extra":sextra})
        }

        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
        QuizLib.assignQuizModel(nIndexOwNewWord)
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
    onVisibleChanged:
    {
      if (!visible)
        idGlosList.positionViewAtIndex(idGlosList.currentIndex, ListView.Center)
    }

    Column
    {
      x:20
      anchors.top: idEditDlg.bottomClose
      anchors.topMargin : 10
      spacing : 20
      Row
      {
        spacing : 20
        width:idEditDlg.width - 40
        height: Theme.fontSizeLarge

        Label
        {
          id:idAddInfo
          text: "Additional Info"
        }

        InputTextQuiz
        {
          id:idTextEdit3
          width: parent.width - idAddInfo.width - 20
        }
      }


      Row
      {
        spacing : 20
        width:parent.width
        height: Theme.fontSizeLarge
        InputTextQuiz
        {
          id:idTextEdit1
          width: parent.width / 2 - 10
        }
        InputTextQuiz
        {
          id:idTextEdit2
          width: parent.width / 2 - 10
        }
      }
      Row
      {
        spacing:10
        ButtonQuiz {
          id:idBtnUpdate
          width:n3BtnWidth
          text:  "Update"
          onClicked: {
            idEditDlg.visible = false
            var nNumber = glosModel.get(idGlosList.currentIndex).number
            var sQ =  idTextEdit1.displayText.trim()
            var sA =  idTextEdit2.displayText.trim()
            var sA_Org =  sA

            var sE =  idTextEdit3.displayText.trim()
            db.transaction(
                  function(tx) {
                    if (idTextEdit3.displayText.length > 0)
                    {
                      sA = sA + "###" + idTextEdit3.displayText
                    }

                    tx.executeSql('UPDATE Glosa'+nDbNumber+' SET quizword=?, answer=? WHERE number = ?',[sQ,sA,nNumber]);

                    // Assign The updated values
                    for ( var i = 0; i < 3;++i) {
                      if (idQuizModel.get(i).number === nNumber)
                      {
                        idQuizModel.get(i).question = sQ;
                        idQuizModel.get(i).answer = sA_Org;
                        idQuizModel.get(i).extra = sE;
                      }
                    }
                  }
                  )


            var i = QuizLib.findNumberInModel(glosModelWorking, nNumber)

            if (i >= 0)
            {
              glosModelWorking.get(i).question = sQ
              glosModelWorking.get(i).answer = sA_Org
              glosModelWorking.get(i).extra = sE
            }

            MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).answer,sToLang)
            MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).question,sFromLang)
            glosModel.get(idGlosList.currentIndex).question = sQ
            glosModel.get(idGlosList.currentIndex).answer = sA_Org
            glosModel.get(idGlosList.currentIndex).extra =  sE

          }
        }
        ButtonQuiz {
          id:idBtnDelete
          width:n3BtnWidth
          text:  "Delete"
          onClicked: {
            idEditDlg.visible = false
            var nNumber = glosModel.get(idGlosList.currentIndex).number
            db.transaction(
                  function(tx) {
                    tx.executeSql('DELETE FROM Glosa'+nDbNumber+' WHERE number = ?',[nNumber]);
                  }
                  )

            var sQuestion = glosModel.get(idGlosList.currentIndex).question
            var sAnswer = glosModel.get(idGlosList.currentIndex).answer

            glosModel.remove(idGlosList.currentIndex)
            MyDownloader.deleteWord(sAnswer,sToLang)
            MyDownloader.deleteWord(sAnswer,sFromLang)

            var nC = glosModelWorking.count;
            for ( var i = 0; i < nC;++i) {
              if (glosModelWorking.get(i).number === nNumber)
              {
                glosModelWorking.remove(i);
                break;
              }
            }
            if (glosModel.count > 0)
            {
              for (  i = 0; i < 3;++i) {
                if (idQuizModel.get(i).number === nNumber)
                {
                  // The removed word is displayed in the Quiz tab
                  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
                  idQuizModel.get(i).question = glosModelWorking.get(nIndexOwNewWord).question;
                  idQuizModel.get(i).answer = glosModelWorking.get(nIndexOwNewWord).answer;
                  idQuizModel.get(i).number = glosModelWorking.get(nIndexOwNewWord).number;
                  idQuizModel.get(i).extra = glosModelWorking.get(nIndexOwNewWord).extra;
                  idQuizModel.get(i).visible1 = false
                }
              }
            }
            else
            {
              for (  i = 0; i < 3;++i) {
                idQuizModel.get(i).allok = false;
                idQuizModel.get(i).question = "-";
                idQuizModel.get(i).answer = "-";
                idQuizModel.get(i).number = "-";
                idQuizModel.get(i).extra = "-";
                idQuizModel.get(i).visible1 = false
              }
            }
            sScoreText = glosModelWorking.count + "/" + glosModel.count
          }
        }
      }
    }
  }
}

