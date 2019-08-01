import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0

Item {
  id:idEditQuiz

  function downloadDictOnWord(sUrl, sWord, oBtn)
  {
    var doc = new XMLHttpRequest();
    doc.open("GET",sUrl+ sWord);

    idErrorText.visible = false;

    doc.onreadystatechange = function() {

      if (doc.readyState === XMLHttpRequest.DONE) {

        oBtn.bProgVisible = false;


        if (doc.status === 200) {

          idTrSynModel.xml = doc.responseText
          idTrTextModel.xml = doc.responseText
          idTrMeanModel.xml = doc.responseText
        }
        else
        {
          idErrorText.text = "error from dictionary server"
          idErrorText.visible = true;
        }
      }
    }
    doc.send()
  }

  function insertGlosa(dbnumber, nC, question, answer)
  {
    db.transaction(
          function(tx) {
            tx.executeSql('INSERT INTO Glosa'+dbnumber+' VALUES(?, ?, ?, ?)', [nC,  question, answer, 0 ]);
          })



    glosModel.append({"number": nC, "question": question , "answer": answer, "state1":0})

    glosModelWorking.append({"number": nC, "question": question , "answer": answer, "state1":0})
    idGlosList.positionViewAtEnd()
    sScoreText = glosModelWorking.count + "/" + glosModel.count


    if (glosModel.count === 1)
    {
      for (var  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = false;
        idQuizModel.get(i).question = question;
        idQuizModel.get(i).answer = answer;
        idQuizModel.get(i).number = nC;
        idQuizModel.get(i).visible1 = false
      }

      return;
    }
  }


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
      query: "/Translation"
      XmlRole { name: "trans"; query: "text/string()" }
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          if (idTranslateModel.count <= 0)
          {
            idTextTrans.text = "-"
            return
          }

          idTextTrans.text =  idTranslateModel.get(0).trans
        }
      }
    }

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


    Row
    {
      spacing : 20
      width:parent.width
      height: Theme.fontSizeLarge
      InputTextQuiz
      {
        id:idTextInput
        width: parent.width / 2 - 10
        ButtonQuizImg {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          source: "image://theme/icon-s-clear-opaque-cross"
          onClicked: idTextInput.text = ""
        }
      }
      InputTextQuiz
      {
        id:idTextInput2
        width: parent.width / 2 - 10
        ButtonQuizImg {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          source: "image://theme/icon-s-clear-opaque-cross"
          onClicked: idTextInput2.text = ""
        }
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
          downloadDictOnWord(sReqDictUrl , oInText,idBtn1 )
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
          downloadDictOnWord(sReqDictUrlRev , oInText,idBtn2)
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
          downloadDictOnWord(sReqDictUrlEn , oInText,idBtn3)
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

          insertGlosa(nDbNumber,nC, sNewWordFrom, sNewWordTo)

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
          MouseArea
          {
            anchors.fill: parent
            onClicked:
            {
              if (nLastSearch != 1)
                idTextInput2.text = idSynText.text;
              else
                idTextInput.text = idSynText.text;
            }
          }
        }
      }
      ListView
      {
        model : idTrMeanModel
        width:n3BtnWidth
        height : parent.height
        delegate: TextList {
          id:idSMeanText
          text:mean
        }
      }
    }

    Row {
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
    SilicaListView {
      id:idGlosList
      height: idAppWnd.height - idDictRow.height - idBtnRow.height * 6 - idTextInput.height - idHeader1Text.height - 80
      clip:true
      width:parent.width

      spacing: 3
      VerticalScrollDecorator { flickable: idGlosList }
      //   header:idHeaderGlos
      //   headerPositioning :ListView.OverlayHeader
      model: glosModel
      delegate: Row {
        spacing:5

        TextList {
          id: idQuestionText
          width: n25BtnWidth
          text:  question
          color: state1 === 0 ? Theme.primaryColor : "green"
          onPressAndHold: idTextInput.text = question
        }

        TextList {
          width: n25BtnWidth
          id:idAnswer
          text: answer
          color: state1 === 0 ? Theme.primaryColor : "green"
          onPressAndHold: idTextInput2.text = answer
        }

        ButtonQuizImg
        {
          height:idAnswer.height
          width:idAnswer.height
          //    y:-5
          source: "qrc:qml/pages/rm.png"
          onClicked:
          {
            db.transaction(
                  function(tx) {
                    tx.executeSql('DELETE FROM Glosa'+nDbNumber+' WHERE number = ?',[number]);
                  }
                  )
            glosModel.remove(index)

            var nC = glosModelWorking.count;
            for ( var i = 0; i < nC;++i) {
              if (glosModelWorking.get(i).number === number)
              {
                glosModelWorking.remove(i);
                break;
              }
            }

            sScoreText = glosModelWorking.count + "/" + glosModel.count

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
    y: idAppWnd.height- 480
    spacing:10
    Button
    {

      text : "Reset"
      onClicked:
      {
        db.transaction(
              function(tx) {
                tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
              }
              )



        glosModelWorking.clear()
        var nC = glosModel.count

        sScoreText = nC + "/" + nC
        for ( var i = 0; i < nC;++i) {
          glosModel.get(i).state1=0;
          glosModelWorking.append(glosModel.get(i))
        }

        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

        i =  nQuizIndex

        idQuizModel.get(i).question = glosModelWorking.get(nIndexOwNewWord).question
        idQuizModel.get(i).answer = glosModelWorking.get(nIndexOwNewWord).answer
        idQuizModel.get(i).number = glosModelWorking.get(nIndexOwNewWord).number
        idQuizModel.get(i).visible1 = false
        idQuizModel.get(i).allok = false

      }

    }

    Button
    {

      text : "Reverse"
      onClicked:
      {
        bIsReverse =  !bIsReverse
        glosModelWorking.clear()
        var nC = glosModel.count
        for ( var i = 0; i < nC;++i) {
          var nState = glosModel.get(i).state1;
          var squestion = glosModel.get(i).answer
          var sanswer = glosModel.get(i).question
          var nnC  = glosModel.get(i).number
          if (nState === 0 )
            glosModelWorking.append({"number": nnC, "question": squestion , "answer": sanswer})
        }

        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

        i =  nQuizIndex

        idQuizModel.get(i).question = glosModelWorking.get(nIndexOwNewWord).question
        idQuizModel.get(i).answer = glosModelWorking.get(nIndexOwNewWord).answer
        idQuizModel.get(i).number = glosModelWorking.get(nIndexOwNewWord).number
        idQuizModel.get(i).visible1 = false
        idQuizModel.get(i).allok = false

      }

    }


  }

  Text {
    color:Theme.primaryColor
    y: idAppWnd.height- 330
    text: "Powered by Yandex.Translate"
  }

}

