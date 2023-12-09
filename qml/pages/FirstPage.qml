import QtQuick 2.2
// import Nemo.DBus 2.0
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
  property string sQuestionLang: bIsReverse ? sToLang : sFromLang
  property string sAnswerLang: bIsReverse ? sFromLang : sToLang
  property bool bIsReverse: false
  property bool bHasDictTo: sToLang === "ru" || sToLang === "en"
  property bool bHasDictFrom: sFromLang === "ru" || sFromLang === "en"
  property string sLangLangEn
  property string sQuizName: "-"
  property string sQuizDate: "-"
  property string sQuizDesc: "-"
  property string sScoreText: "-"
  property int nDbNumber: 0
  property int nQuizIndex: 1
  property int n3BtnWidth: idTabMain.width / 3 - 8
  property int n4BtnWidth: idTabMain.width / 4 - 7
  property int n5BtnWidth: idTabMain.width / 8
  property int n25BtnWidth: idTabMain.width / 2.4 - 7
  property int n2BtnWidth: idTabMain.width / 2
  property int nDlgHeight: idWindow.height / 5 + 45
  property bool bQSort: true
  property string sQSort: bQSort ? "UPPER(quizword)" : "UPPER(answer)"
  property variant glosListView
  property variant quizListView
  property variant oTakeQuiz
  property bool bAllok: false
  property int nGlosaDbLastIndex: -1
  property string sSearchQuery
  property int nGlosaTakeQuizIndex
  property int nMargin: Screen.height > 1000 ? 50 : 25
  property bool bInitHangMan: true
  property bool bCWBusy: false

  state: "idTab1"
  onSScoreTextChanged: {
    db.transaction(function (tx) {
      tx.executeSql('UPDATE GlosaDbIndex SET state1=? WHERE dbnumber=?',
                    [sScoreText, nDbNumber])

      var i = MyDownloader.indexFromGlosNr(glosModelIndex, nDbNumber)
      glosModelIndex.setProperty(i, "state1", sScoreText)
    })
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

  // Used by idTakeQuizView in TakeQuiz
  ListModel {
    id: idQuizModel
    property string question
    property string extra
    property string answer
    property string answerDisp
    property int number

    onQuestionChanged: {
      MyDownloader.setImgWord(question, sQuestionLang)
    }

    ListElement {
      number: 0
      answerVisible: false
    }
    ListElement {
      number: 1
      answerVisible: false
    }
    ListElement {
      number: 2
      answerVisible: false
    }
  }

  ListModel {
    id: idLangModel
  }

  objectName: "idFirstPage"

  Component.onCompleted: {
    QuizLib.initLangList()
    QuizLib.getAndInitDb()
  }

  Rectangle {
    height: idTab2Btn.height
    x: idTab2Btn.x + nMargin + idTab2Btn.width + idTabMain.spacing
    y: idTabRow.y + idTabMain.y
    width: Screen.width / 2
    opacity: 0.4
    radius: 4
    color: "steelblue"
  }

  SilicaListView {
    id: idSilicaListView
    anchors.fill: parent

    Column {
      id: idTabMain
      anchors.fill: parent
      anchors.leftMargin: nMargin
      anchors.rightMargin: nMargin
      anchors.topMargin: nMargin
      spacing: 10

      Item {
        width: parent.width
        height: idTitle.height

        Label {
          id: idTitle
          font.italic: glosModelIndex.count === 0
          anchors.horizontalCenter: parent.horizontalCenter
          text: {
            if (glosModelIndex.count === 0)
              return "No Quiz create one or download"

            return sQuizName + " " + sFromLang + (bIsReverse ? "<-" : "->")
                + sToLang + " " + sScoreText
          }

          onTextChanged: sAppTitle = sQuizName
        }

        ButtonQuizImg {
          id: idBtnHelp
          anchors.right: parent.right
          anchors.topMargin: -nMargin
          anchors.rightMargin: -nMargin
          anchors.top: parent.top
          source: "image://theme/icon-m-question"

          onClicked: {
            QuizLib.openManPage()
          }
        }

        ButtonQuizImg {
          id: idBtnSearch
          anchors.left: parent.left
          anchors.topMargin: -nMargin
          anchors.leftMargin: -nMargin
          anchors.top: parent.top
          source: "image://theme/icon-m-search"
          onClicked: QuizLib.openWwwPage(
                       "https://www.google.com/search?q=" + sSearchQuery)
        }
      }

      Row {
        id: idTabRow
        width: parent.width
        spacing: 10

        ButtonQuizImg {
          id: idTab1Btn
          source: "image://theme/icon-m-home?"
                  + (idWindow.state === "idTab1" ? Theme.highlightColor : Theme.primaryColor)
          onClicked: idWindow.state = "idTab1"
        }

        ButtonQuizImg {
          id: idTab2Btn
          fillMode: Image.PreserveAspectFit
          width: idTab1Btn.width * 2
          source: "image://theme/icon-m-edit?"
                  + (idWindow.state === "idTab2" ? Theme.highlightColor : Theme.primaryColor)
          onClicked: idWindow.state = "idTab2"
        }

        ComboBox {

          id: idCombo
          //  width: 200
          label: "Games"

          menu: ContextMenu {

            MenuItem {
              text: "Quiz"
              onClicked: idWindow.state = "idTab3"
            }
            MenuItem {
              text: "Hang Man"
              onClicked: {
                if (idWindow.state === "idTab1" || bInitHangMan) {
                  bInitHangMan = false
                  idTab4.newQ()
                }
                idWindow.state = "idTab4"
              }
            }

            MenuItem {
              text: "Crossword"
              onClicked: {
                idTab5.loadCW()
                idWindow.state = "idTab5"
              }
            }
          }
        }
      }

      CreateNewQuiz {
        id: idTab1
        width: parent.width
        height: idTabMain.height - idTabRow.height - idTitle.height - 20
        visible: false
      }
      EditQuiz {
        id: idTab2
        width: parent.width
        height: idTabMain.height - idTabRow.height - idTitle.height - 20
        visible: false
      }
      TakeQuiz {
        id: idTab3
        width: parent.width
        height: Screen.height - idTabRow.height - idTitle.height - 20
        visible: false
      }
      HangMan {
        id: idTab4
        width: parent.width
        height: Screen.height - idTabRow.height - 2 * idTitle.height
        visible: false
      }

      CrossWord {
        id: idTab5
        width: Screen.width
        height: Screen.height
        visible: false
      }
    }
  }

  states: [
    State {
      name: "idTab1"
      PropertyChanges {
        target: idTab1
        visible: true
      }
    },
    State {
      name: "idTab2"
      PropertyChanges {
        target: idTab2
        visible: true
        bTabActive: true
      }
    },
    State {
      name: "idTab3"
      PropertyChanges {
        target: idTab3
        visible: true
      }
      PropertyChanges {
        target: idCombo
        labelColor: Theme.secondaryHighlightColor
      }
    },
    State {
      name: "idTab4"
      PropertyChanges {
        target: idTab4
        visible: true
      }
      PropertyChanges {
        target: idCombo
        labelColor: Theme.secondaryHighlightColor
      }
    },
    State {
      name: "idTab5"
      PropertyChanges {
        target: idTab5
        visible: true
      }
      PropertyChanges {
        target: idCombo
        labelColor: Theme.secondaryHighlightColor
      }
    }
  ]
}
