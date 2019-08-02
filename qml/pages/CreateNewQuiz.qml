import QtQuick 2.0
import Sailfish.Silica 1.0


Item
{
  property alias nQuizListCurrentIndex: idQuizList.currentIndex

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

    TextList
    {
      id:idTextSelected
      onClick: idTextInputQuizName.text = idTextSelected.text
    }

    InputTextQuiz
    {
      width:parent.width
      id:idTextInputQuizName
      text:"new"
    }

    Row
    {
      spacing:20
      width:parent.width
      ButtonQuiz
      {
        text:"New Quiz"
        width: n3BtnWidth

        onClicked:
        {

          db.transaction(
                function(tx) {

                  var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
                  var nNr = 1
                  if (rs.rows.length > 0)
                  {
                    nNr = rs.rows.item(0).newnr + 1
                  }
                  tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',[nNr, idTextInputQuizName.displayText,"0/0",sLangLangSelected  ]);

                  glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.displayText , "state1": "0/0", "langpair" : sLangLangSelected });

                  idQuizList.positionViewAtEnd();
                  idQuizList.currentIndex = glosModelIndex.count -1;

                }
                )

        }
      }
      ButtonQuiz
      {
        id:idBtnRename
        text:"Rename"
        width: n3BtnWidth

        onClicked:
        {
          glosModelIndex.setProperty(idQuizList.currentIndex,"quizname", idTextInputQuizName.displayText)
          db.transaction(
                function(tx) {
                  var nId = glosModelIndex.get(idQuizList.currentIndex).dbnumber;
                  tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[idTextInputQuizName.displayText, nId]);
                  idTextSelected.text = idTextInputQuizName.displayText
                }

                )
        }
      }
      ButtonQuiz
      {
        id:idBtnDelete
        text:"Delete"
        width: n3BtnWidth
        onClicked: Remorse.popupAction(idTopColumn,"Delete Quiz " + idTextSelected.text, function()
        {

          db.transaction(
                function(tx) {

                  tx.executeSql('DELETE FROM GlosaDbIndex WHERE dbnumber = ?',[nDbNumber]);
                  tx.executeSql('DROP TABLE Glosa'+nDbNumber);

                }
                )

          glosModelIndex.remove(idQuizList.currentIndex)

          if(idQuizList.currentIndex > 0)
            idQuizList.currentIndex = idQuizList.currentIndex -1;


        }

        )
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
        height:idBtnRename.height
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
      height:Theme.itemSizeMedium * 6
      model:glosModelIndex
      spacing:5

      onCurrentIndexChanged:
      {

        var nTheIndex = currentIndex;

        getDb().transaction(

              function(tx) {
                tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',[nTheIndex]);
              }
              )

        if (glosModelIndex.count === 0)
          return;

        sQuizName = glosModelIndex.get(currentIndex).quizname;
        sLangLang = glosModelIndex.get(currentIndex).langpair;
        nDbNumber  = glosModelIndex.get(currentIndex).dbnumber;
        sScoreText = glosModelIndex.get(currentIndex).state1;

        var res = sLangLang.split("-");
        sLangLangRev = res[1] + "-" + res[0];
        sToLang = res[1]
        sFromLang = res[0]
        sLangLangEn = "en"+ "-" + res[1];
        sReqDictUrl = sReqDictUrlBase +  sLangLang + "&text=";
        sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text=";
        sReqDictUrlEn= sReqDictUrlBase + sLangLangEn + "&text=";

        sReqUrl = sReqUrlBase +  sLangLang + "&text=";
        sReqUrlRev = sReqUrlBase +  sLangLangRev + "&text=";
        sReqUrlEn = sReqUrlBase +  sLangLangEn + "&text=";
        db.transaction(
              function(tx) {
                // tx.executeSql('DROP TABLE Glosa');

                glosModel.clear();
                tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber + '( number INT , quizword TEXT, answer TEXT, state INT)');



                var rs = tx.executeSql("SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort);

                for(var i = 0; i < rs.rows.length; i++) {
                  glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": rs.rows.item(i).answer, "state1" : rs.rows.item(i).state })
                }

                loadQuiz();

              }
              )

        idTextSelected.text = sQuizName

      }

      delegate:
          Row
      {
        id:idQuizListRow

        TextList
        {
          id:idCol1
          width:Theme.itemSizeSmall
          text:dbnumber
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol2
          width: Theme.itemSizeMedium*2
          text:quizname
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol3
          width: Theme.itemSizeMedium
          text:langpair
          onClick: idQuizList.currentIndex = index
        }
        TextList
        {
          id:idCol4
          width: Theme.itemSizeMedium
          text:state1
          onClick: idQuizList.currentIndex = index
        }
      }
    }

  }
}

