

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
  property string sQuestonLang : bIsReverse ? sToLang : sFromLang
  property string sAnswerLang : bIsReverse ? sFromLang : sToLang
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
  property variant quizListView
  property variant oTakeQuiz
  property bool bAllok : false
  property int nGlosaDbLastIndex:  -1
  property string sSearchQuery
  property int nGlosaTakeQuizIndex
  onSScoreTextChanged:
  {
    db.transaction(
          function(tx) {
            tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',[sScoreText, nDbNumber]);

            var i = MyDownloader.indexFromGlosNr(glosModelIndex, nDbNumber)
            glosModelIndex.setProperty(i,"state1", sScoreText)

          }
          )
  }


  ListModel {
    id: glosModel
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
    property string question
    property string extra
    property string answer
    property int number

    onQuestionChanged:
    {
      idQuizModel.get(idWindow.nQuizIndex).question = question
      MyDownloader.setImgWord(question,sQuestonLang )
    }

    ListElement {
      number:0
      question:"-"
      allok:false
    }
    ListElement {
      number:1
      question:"-"
      allok:false
    }
    ListElement {
      number:2
      question:"-"
      allok:false
    }
  }



  objectName: "idFirstPage"

  Component.onCompleted:
  {
    QuizLib.getAndInitDb();
  }

  SilicaListView {
    anchors.fill: parent

    Column  {
      id:idTabMain
      anchors.fill : parent
      anchors.leftMargin : 50
      anchors.rightMargin : 50
      anchors.topMargin : 50
      spacing :10

      Item
      {
        width:parent.width
        height: idTitle.height
        Label {
          id: idTitle
          anchors.horizontalCenter: parent.horizontalCenter
          text: sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") +  sToLang + " " + sScoreText
          onTextChanged: sAppTitle = sQuizName
        }

        ButtonQuizImg
        {
          id: idBtnHelp
          anchors.right: parent.right
          anchors.topMargin : -40
          anchors.rightMargin : -40
          anchors.top : parent.top
          source:"image://theme/icon-m-question"
          onClicked: Qt.openUrlExternally("https://faxling.github.io/WordQuizWin/index.html");
        }

        ButtonQuizImg
        {
          id: idBtnSearch
          anchors.left: parent.left
          anchors.topMargin : -40
          anchors.leftMargin : -40
          anchors.top : parent.top
          source:"image://theme/icon-m-search"
          onClicked: Qt.openUrlExternally("https://www.google.com/search?q="+sSearchQuery);
        }
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

        Text {
          font.pixelSize: Theme.fontSizeTiny
          color:Theme.primaryColor
          y:  Screen.height - parent.y - 98
          text: "Powered by Yandex.Translate "
        }
      }
      TakeQuiz
      {
        id:idTab3
        width:parent.width
        height: idTabMain.height - idTabRow.height - idTitle.height - 20
        visible:false

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
        bTabActive:true
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
