

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0 as Sql
import "../QuizFunctions.js" as QuizLib

Page {
  id: idWindow
  // init in initUrls
  property string sReqDictUrlBase
  property string sReqDictUrl
  property string sReqDictUrlRev
  property string sReqDictUrlEn
  property string sReqUrlBase


  property string sReqUrl
  property string sReqUrlRev
  property string sReqUrlEn


  property variant db
  property string sLangLangSelected
  property string sLangLang
  property string sLangLangRev
  property string sToLang
  property string sFromLang
  property bool bIsReverse
  property bool bHasSpeech : sToLang !== "hu"
  property bool bHasSpeechFrom : sFromLang !=="hu"
  property bool bHasDictTo : sToLang ==="ru" || sToLang ==="en"
  property bool bHasDictFrom : sFromLang ==="ru" || sFromLang ==="en"
  property string sLangLangEn
  property string sQuizName : "-"
  property string sScoreText : "-"
  property int nDbNumber : 0;
  property int nQuizIndex: 1
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2
  property bool bQSort : true
  property string sQSort : bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property int nGlosaDbLastIndex;

  onSScoreTextChanged:
  {
    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);

            var nC = glosModelIndex.count
            for ( var i = 0; i < nC;++i) {
              if (glosModelIndex.get(i).dbnumber === nDbNumber)
              {
                glosModelIndex.setProperty(i,"state1", sScoreText)
                break;
              }
            }
          }
          )
  }

  function loadQuiz()
  {
    glosModelWorking.clear();
    if (glosModel.count < 1)
    {
      for (var  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = false;
        idQuizModel.get(i).question = "-";
        idQuizModel.get(i).answer = "-";
        idQuizModel.get(i).number = "-";
        idQuizModel.get(i).extra = "-";
        idQuizModel.get(i).visible1 = false
      }
      return;
    }

    var nC = glosModel.count

    bIsReverse = false

    for (  i = 0; i < nC;++i) {
      if (glosModel.get(i).state1 === 0)
        glosModelWorking.append(glosModel.get(i))
    }

    var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

    // sScoreText =  glosModelWorking.count + "/" + nC

    if (glosModelWorking.count === 0)
    {
      for (  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = true;
      }
    }
    else
    {
      for (  i = 0; i < 3;++i) {
        idQuizModel.get(i).allok = false;
      }
      idQuizModel.get(nQuizIndex).question = glosModelWorking.get(nIndexOwNewWord).question;
      idQuizModel.get(nQuizIndex).answer = glosModelWorking.get(nIndexOwNewWord).answer;
      idQuizModel.get(nQuizIndex).number = glosModelWorking.get(nIndexOwNewWord).number;
      idQuizModel.get(nQuizIndex).extra = glosModelWorking.get(nIndexOwNewWord).extra;
      idQuizModel.get(nQuizIndex).visible1 = false
    }

  }

  ListModel {
    id: glosModel
    objectName:"glosModel"


    function sortModel()
    {

      db.transaction(
            function(tx) {
              glosModel.clear();

              var rs = tx.executeSql("SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort);

              for(var i = 0; i < rs.rows.length; i++) {

                var sA;
                var sE = "";
                var ocA = rs.rows.item(i).answer.split("###")
                sA = ocA[0]
                if (ocA.length > 1)
                  sE = ocA[1]

                glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE,  "state1" : rs.rows.item(i).state })

              }
            }
            )

    }

  }
  ListModel {
    id: glosModelWorkingRev
  }

  ListModel {
    id: glosModelWorking
  }


  // Used by idQuizList
  ListModel {
    id: glosModelIndex
  }

  // Used by idView in TakeQuiz

  ListModel {
    id:idQuizModel

    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:0
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:1
      visible1:false
      allok:false
    }
    ListElement {
      question: "-"
      answer:"-"
      extra:""
      number:2
      visible1:false
      allok:false
    }
  }


  objectName: "idFirstPage"


  Column  {
    id:idTabMain
    anchors.fill : parent
    anchors.leftMargin : 50
    anchors.rightMargin : 50
    anchors.topMargin : 50
    spacing :10

    Label {
      anchors.horizontalCenter: parent.horizontalCenter
      id: idTitle
      text: sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") +  sToLang + " " + sScoreText
      onTextChanged: sAppTitle = sQuizName
    }

    Row {
      id:idTabRow
      width:parent.width
      spacing :10
      Button
      {
        id:idTab1Btn
        width: n3BtnWidth
        text:"Home"
        onClicked: idWindow.state = "idTab1"
      }

      Button
      {
        id:idTab2Btn
        width: n3BtnWidth
        text:"Edit"

        onClicked:  idWindow.state =  "idTab2"
      }
      Button
      {
        id:idTab3Btn
        width: n3BtnWidth
        text:"Quiz"
        onClicked:  idWindow.state ="idTab3"
      }
    }

    CreateNewQuiz
    {
      id:idTab1
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      visible:false
    }
    EditQuiz
    {
      id:idTab2
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      visible:false
      Component.onCompleted:
      {
        idWindow.glosListView = idTab2.glosListView
      }
      Text {
        font.pixelSize: Theme.fontSizeTiny
        color:Theme.primaryColor
        y:  Screen.height - parent.y - 95
        text: "Powered by Yandex.Translate "
      }
    }
    TakeQuiz
    {
      id:idTab3
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      visible:false
      Component.onCompleted:
      {
        QuizLib.getAndInitDb();
        idTab1.nQuizListCurrentIndex = idWindow.nGlosaDbLastIndex
      }
    }

  }

  /*
  Image
  {
    anchors.left: idTabMain.left
    anchors.bottom: idTabMain.top
    source: "qrc:qml/pages/harbour-wordquiz.png"
  }
  */


  states: [
    State {
      name: "idTab1"
      PropertyChanges {
        target: idTab1
        visible:true
      }

      PropertyChanges {
        target: idTab1Btn
        color:Theme.highlightColor

      }
    },
    State {
      name: "idTab2"
      PropertyChanges {
        target: idTab2
        visible:true

      }
      PropertyChanges {
        target: idTab2Btn
        color:Theme.highlightColor

      }
    },
    State {
      name: "idTab3"
      PropertyChanges {
        target: idTab3
        visible:true
      }

      PropertyChanges {
        target: idTab3Btn
        color:Theme.highlightColor
      }

    }

  ]

}
