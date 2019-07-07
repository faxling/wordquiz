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
          idErrorText.text = "error from translation server"
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
  }


  property int nLastSearch : 0

  Column
  {
    id: idMainColumn
    spacing:20
    anchors.topMargin: 20
    anchors.fill: parent
    Component
    {
      id:idHeaderGlos

      Row {
        TextList {
          width:n3BtnWidth / 2
          text:  "No"
        }
        TextList {

          width:n3BtnWidth
          text:  "word"
        }

        TextList {
          width:n3BtnWidth
          text: "answer"
        }
      }
    }

    XmlListModel {
      id: idTrTextModel
      onStatusChanged:
      {
        if (status === XmlListModel.Ready)
        {
          if (idTrTextModel.count <= 0)
          {
            idText.text = "-"
            return
          }
          idText.text =  idTrTextModel.get(0).text1
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

    Row
    {
      width:parent.width

      TextList
      {
        width:n3BtnWidth*2
        id:idText
        text :"-"
      }
      TextList
      {
        id:idTextTrans
        text :"-"
        onClick: idText.text = idTextTrans.text
      }
    }

    InputTextQuiz
    {
      text:""
      id:idTextInput
    }

    Row
    {
      spacing:10

      ButtonQuiz {
        id:idBtn1
        width:n4BtnWidth
        text:  sLangLang
        onClicked: {
          nLastSearch = 0
          bProgVisible = true
          downloadDictOnWord(sReqDictUrl , idTextInput.text,idBtn1 )
          idTranslateModel.source = sReqUrl + idTextInput.text
        }
      }


      ButtonQuiz {
        id:idBtn2
        width:n4BtnWidth
        text:  sLangLangRev
        onClicked: {
          nLastSearch = 1
          bProgVisible = true
          downloadDictOnWord(sReqDictUrlRev , idTextInput.text,idBtn2)
          idTranslateModel.source = sReqUrlRev + idTextInput.text
        }
      }

      ButtonQuiz {
        id:idBtn3
        width:n4BtnWidth
        text:  sLangLangEn
        onClicked: {
          nLastSearch = 2
          bProgVisible = true
          downloadDictOnWord(sReqDictUrlEn , idTextInput.text,idBtn3)
        }
      }

      ButtonQuiz {
        width:n4BtnWidth
        text: "Add"
        onClicked: {

          // Find a new Id
          var nC = 0;
          for(var i = 0; i < glosModel.count; i++) {
            if (glosModel.get(i).number > nC)
              nC = glosModel.get(i).number;
          }

          nC += 1;

          if (nLastSearch !== 1)
          {
            insertGlosa(nDbNumber,nC, idTextInput.text, idText.text)
          }
          else
          {
            insertGlosa(nDbNumber, nC, idText.text, idTextInput.text)
          }

          if (bHasSpeech)
            MyDownloader.downloadWord(idText.text,sToLang)

        }
      }

    }

    TextList
    {
      visible:false
      id:idErrorText
      color: "red"

    }

    Row
    {
      height: n3BtnWidth
      width:parent.width

      ListViewHi {
        id:idDicList
        width:n3BtnWidth
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
                idText.text = idSearchItem.text;
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
              idText.text = idSynText.text;
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


    ListView {
      id:idGlosList
      height:n3BtnWidth * 2
      clip: true
      width:parent.width

      spacing: 3

      header:idHeaderGlos

      model: glosModel
      delegate: Row {
        spacing:5
        TextList {
          id:idNumberText
          width:n3BtnWidth / 2
          text:  number
        }

        TextList {
          width: n3BtnWidth
          text:  question
          color: state1 === 0 ? idNumberText.color : "green"
        }

        TextList {
          width: n3BtnWidth
          id:idAnswer
          text: answer
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
    Row
    {
      spacing:10
      ButtonQuiz
      {
        text : "Reset"
        onClicked:
        {
          db.transaction(
                function(tx) {
                  tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
                })


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

      ButtonQuiz
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
            glosModelWorking.append({"number": nnC, "question": squestion , "answer": sanswer, "state1":nState})
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
  }
}

