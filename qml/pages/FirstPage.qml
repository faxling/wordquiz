import QtQuick 2.2
import Sailfish.Silica 1.0

import QtQuick.LocalStorage 2.0 as Sql

Page {
  id: idWindow


  property string sReqDictUrlBase : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang="
  property string sReqDictUrl : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=sv-ru&text="
  property string sReqDictUrlRev : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=ru-sv&text="
  property string sReqDictUrlEn : "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=dict.1.1.20190526T201825Z.ad1b7fb5407a1478.20679d5d18a62fa88bd53b643af2dee64416b739&lang=en-ru&text="

  property string sReqUrlBase: "https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20190526T164138Z.e99d5807bb2acb8d.d11f94738ea722cfaddf111d2e8f756cb3b71f4f&lang="
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
  function getDb()
  {

    if (db !== undefined)
      return db;

    console.log("init Word Quiz")
    db = Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

    Sql.LocalStorage.openDatabaseSync()

    db.transaction(
          function(tx) {

            // tx.executeSql('DROP TABLE GlosaDbIndex');
            var nGlosaDbLastIndex;
            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbLastIndex( dbindex INT )');
            var rs = tx.executeSql('SELECT * FROM GlosaDbLastIndex')
            if (rs.rows.length===0)
            {
              tx.executeSql('INSERT INTO GlosaDbLastIndex VALUES(0)')
            }
            else
            {
              nGlosaDbLastIndex = rs.rows.item(0).dbindex
            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbDesc( dbnumber INT , desc1 TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbIndex( dbnumber INT , quizname TEXT, state1 TEXT, langpair TEXT )');
            rs = tx.executeSql('SELECT * FROM GlosaDbDesc');
            var oc = [];

            for(var i = 0; i < rs.rows.length; i++) {
              var oDescription = {dbnumber:rs.rows.item(i).dbnumber, desc1:rs.rows.item(i).desc1}
              oc.push(oDescription)
            }

            rs = tx.executeSql('SELECT * FROM GlosaDbIndex');

            Array.prototype.indexOfObject = function arrayObjectIndexOf(property, value) {
              for (var i = 0, len = this.length; i < len; i++) {
                if (this[i][property] === value) return i;
              }
              return -1;
            }

            var nRowLen = rs.rows.length


            for(i = 0; i < nRowLen; i++) {
              var nDbnumber = rs.rows.item(i).dbnumber
              var nN = oc.indexOfObject("dbnumber",nDbnumber)
              var sDesc = "-"
              if (nN >= 0)
              {
                sDesc = oc[nN].desc1
              }

              glosModelIndex.append({"dbnumber": nDbnumber, "quizname": rs.rows.item(i).quizname , "state1": rs.rows.item(i).state1, "langpair" : rs.rows.item(i).langpair,"desc1" : sDesc  })
            }

            idTab1.nQuizListCurrentIndex = nGlosaDbLastIndex;

          }
          )
    return db;
  }

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
        text:"File"
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
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      visible:false
      id:idTab1
    }
    EditQuiz
    {
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      id:idTab2
      visible:false

      Text {

        font.pixelSize: Theme.fontSizeTiny
        color:Theme.primaryColor
        y:  Screen.height - parent.y - 85
        text: "Powered by Yandex.Translate "
      }
    }
    TakeQuiz
    {
      width:parent.width
      height: idTabMain.height - idTabRow.height - idTitle.height - 20
      id:idTab3
      visible:false
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
  Component.onCompleted: {
    getDb();
  }
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
