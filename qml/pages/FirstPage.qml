

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
  property string sQuestionLang : bIsReverse ? sToLang : sFromLang
  property string sAnswerLang : bIsReverse ? sFromLang : sToLang
  property bool bIsReverse
  property bool bHasDictTo : sToLang ==="ru" || sToLang ==="en"
  property bool bHasDictFrom : sFromLang ==="ru" || sFromLang ==="en"
  property string sLangLangEn
  property string sQuizName : "-"
  property string sQuizDate : "-"
  property string sQuizDesc : "-"
  property string sScoreText : "-"
  property int nDbNumber : 0;
  property int nQuizIndex: 1
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2
  property int nDlgHeight: idWindow.height / 5 + 45
  property bool bQSort : true
  property string sQSort : bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property variant quizListView
  property variant oTakeQuiz
  property bool bAllok : false
  property int nGlosaDbLastIndex:  -1
  property string sSearchQuery
  property int nGlosaTakeQuizIndex
  property int nMargin : Screen.height > 1000 ? 50 : 25
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
      MyDownloader.setImgWord(question,sQuestionLang )
    }

    ListElement {
      number:0
    }
    ListElement {
      number:1
    }
    ListElement {
      number:2
    }
  }

  ListModel {
    id:idLangModel
  }

  objectName: "idFirstPage"

  Component.onCompleted:
  {
    QuizLib.initLangList()
    QuizLib.getAndInitDb();
  }

  SilicaListView {
    anchors.fill: parent

    Column  {
      id:idTabMain
      anchors.fill : parent
      anchors.leftMargin : nMargin
      anchors.rightMargin : nMargin
      anchors.topMargin : nMargin
      spacing :10

      Item
      {
        width:parent.width
        height: idTitle.height
        Label {
          id: idTitle
          font.italic: glosModelIndex.count === 0
          anchors.horizontalCenter: parent.horizontalCenter
          text: {
            if (glosModelIndex.count === 0)
              return "No Quiz create one or download"

            return sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->") +  sToLang + " " + sScoreText

          }

          onTextChanged: sAppTitle = sQuizName
        }

        ButtonQuizImg
        {
          id: idBtnHelp
          anchors.right: parent.right
          anchors.topMargin : -nMargin
          anchors.rightMargin :-nMargin
          anchors.top : parent.top
          source:"image://theme/icon-m-question"
          onClicked: Qt.openUrlExternally("https://faxling.github.io/WordQuizWin/index.html");
        }

        ButtonQuizImg
        {
          id: idBtnSearch
          anchors.left: parent.left
          anchors.topMargin : -nMargin
          anchors.leftMargin : -nMargin
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
          width: n4BtnWidth
          text:"Home"
          onClicked: idWindow.state = "idTab1"
        }

        Button
        {
          id:idTab2Btn
          width: n4BtnWidth
          enabled: glosModelIndex.count > 0
          text:"Edit"
          onClicked:  idWindow.state =  "idTab2"
        }
        Button
        {
          id:idTab3Btn
          width: n4BtnWidth
          enabled: glosModelIndex.count > 0
          text:"Quiz"
          onClicked:  idWindow.state ="idTab3"
        }
        Button
        {
          id:idTab4Btn
          width: n4BtnWidth
          enabled: glosModelIndex.count > 0
          text:"Hang\n Man"
          onClicked:  {
            idWindow.state ="idTab4"
            idTab4.newQ()
          }
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
      }
      TakeQuiz
      {
        id:idTab3
        width:parent.width
        height: idTabMain.height - idTabRow.height - idTitle.height - 20
        visible:false
      }

      HangMan
      {
        id:idTab4
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
    },
    State {
      name: "idTab4"
      PropertyChanges {
        target: idTab4
        visible:true
      }

      PropertyChanges {
        target: idTab4Btn
        color:Theme.highlightColor
      }
    }

  ]

}
