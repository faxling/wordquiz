import QtQuick 2.0
import Sailfish.Silica 1.0


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
      height:Theme.itemSizeMedium * 5
      model:glosModelIndex
      clip:true
      spacing:5
      function loadFromServerList(nCount, oDD) {
        idImport.visible = true
        idServerQModel.clear()

        if (nCount===0)
        {
          idDescText.text = ""
          idImport.sSelectedQ = "";
          return;
        }

        idDescText.text = oDD[1];
        idImport.sSelectedQ = oDD[0];

        for(var i = 0; i < nCount; i+=4) {
          idServerQModel.append({"qname":oDD[i], "desc1":oDD[i+1],  "code":oDD[i+2],  "state1":oDD[i+3]});
        }
        idDownloadBtn.bProgVisible = false
      }
      function quizDeleted(nResponce)
      {
        idDeleteQuiz.bProgVisible = false
        idDescText.text = ""

        if (nResponce>=0)
        {
          idServerQModel.remove(nResponce);
          if (nResponce>0)
          {
            idServerListView.currentIndex = nResponce - 1
            idDescText.text = idServerQModel.get(nResponce - 1).desc1;
            idImport.sSelectedQ = idServerQModel.get(nResponce - 1).qname;
            idImportMsg.text = ""
          }
        }
        else
          idImportMsg.text = "Not deleted"
      }
      function quizExported(nResponce)
      {
        idExportBtn.bProgVisible = false
        if (nResponce === 0)
        {
          idExportError.text = "Network error";
          idExportError.visible = true;
        }
        else
        {
          if (nResponce === 206)
          {
            idExportError.text = "Quiz with name '"+sQuizName+"' Exists"
            idExportError.visible = true;
          }
          else if (nResponce === 200)
          {
            idExport.visible = false;
          }
          else
          {
            idExportError.text = nResponce
            idExportError.visible = true;
          }

        }
      }
      function loadFromList(nCount, oDD, sLangLoaded) {
        if (nCount < 0)
        {
          idLoadQuiz.bProgVisible = false
          idImportMsg.text = "error importing"

          return
        }


        db.transaction(
              function(tx) {
                console.log("Load: " + nCount)
                var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
                var nNr = 1
                if (rs.rows.length > 0)
                {
                  nNr = rs.rows.item(0).newnr + 1
                }

                nDbNumber = nNr;

                tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nNr + '( number INT , quizword TEXT, answer TEXT, state INT)');

                var sState1 = nCount/3 + "/" +nCount/3
                tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nDbNumber,idDescText.text]);
                tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',[nDbNumber, idTextInputQuizName.text,sState1,sLangLoaded  ]);

                glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.text , "state1": sState1 , "langpair" : sLangLoaded,"desc1":idDescText.text })
                // answer, question , state

                for(var i = 0; i < nCount; i+=3) {
                  var sAnswString =oDD[i]+"###"+oDD[i+1]
                  tx.executeSql('INSERT INTO Glosa' +nNr+' VALUES(?, ?, ?, ?)', [i/2,  oDD[i+2], sAnswString, 0 ]);
                }
                idLoadQuiz.bProgVisible = false
                idImport.visible = false
              }
              );

      }

      Component.onCompleted: {
        MyDownloader.exportedSignal.connect(quizExported)
        MyDownloader.quizDownloadedSignal.connect(loadFromList)
        MyDownloader.quizListDownloadedSignal.connect(loadFromServerList)
        MyDownloader.deletedSignal.connect(quizDeleted)
      }

      onCurrentIndexChanged:
      {

        var nTheIndex = currentIndex;
        if (nTheIndex<0)
          return;

        if (nTheIndex >= glosModelIndex.count)
          return;


        getDb().transaction(

              function(tx) {
                tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',[nTheIndex]);
              }
              )

        if (glosModelIndex.count === 0)
          return;

        sQuizName = glosModelIndex.get(nTheIndex).quizname;
        sLangLang = glosModelIndex.get(nTheIndex).langpair;
        nDbNumber  = glosModelIndex.get(nTheIndex).dbnumber;
        sScoreText = glosModelIndex.get(nTheIndex).state1;
        idDescTextOnPage.text = glosModelIndex.get(nTheIndex).desc1

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

                  var sA;
                  var sE = "";

                  var ocA = rs.rows.item(i).answer.split("###")
                  sA = ocA[0]
                  if (ocA.length > 1)
                    sE = ocA[1]

                  glosModel.append({"number": rs.rows.item(i).number, "question": rs.rows.item(i).quizword , "answer": sA, "extra": sE, "state1" : rs.rows.item(i).state })


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
    height:parent.width / 1.7

    TextList {
      x:20
      id:idExportTitle
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
      text: "Export"
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idCancelExport.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        MyDownloader.exportCurrentQuiz( glosModel, sQuizName,sLangLang, idTextInputQuizPwd.text, idTextInputQuizDesc.text )
      }
    }

    ButtonQuiz
    {
      id:idCancelExport
      width: n3BtnWidth
      text: "Cancel"
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.bottomMargin: 20
      anchors.rightMargin: 20
      onClicked:
      {
        idExport.visible = false
      }
    }
  }


  RectRounded{
    id:idImport
    y:20
    visible: false;
    width:parent.width
    height:parent.width / 1.7

    TextList {
      id:idImportMsg
      x:parent.width / 2
      anchors.top :idDescText.top
      color:"red"
      text:""
    }

    TextList {
      id: idImportTitle
      text:"Available Quiz"
    }

    Text
    {
      id:idDescText
      color:Theme.highlightColor
      font.pixelSize: Theme.fontSizeSmall
      anchors.top :idImportTitle.bottom
      x:20
      text:"---"
    }

    TextList {
      anchors.right: parent.right
      anchors.rightMargin:30
      text:"Questions"
    }
    property string sSelectedQ : ""
    ListViewHi
    {
      id:idServerListView
      anchors.top :idDescText.bottom
      anchors.bottom:idDeleteQuiz.top
      width:idImport.width
      height:parent.height
      clip:true
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
      visible:false
      height:70
      anchors.bottom: idDeleteQuiz.top
      anchors.bottomMargin: 20
      width:idServerListView.width
      Row
      {
        x:20
        anchors.verticalCenter:parent.verticalCenter
        spacing:20
        Text
        {
          anchors.verticalCenter:parent.verticalCenter
          color: "white"
          text: "Password to remove '" + idImport.sSelectedQ +"'"
        }

        InputTextQuiz
        {
          width:parent.width / 2
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
      text: "Load"
      width:n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.right: idCancelLoad.left
      anchors.rightMargin: 20
      onClicked:
      {
        bProgVisible = true
        idTextInputQuizName.text = idImport.sSelectedQ
        MyDownloader.importQuiz(idImport.sSelectedQ)
      }
    }

    ButtonQuiz
    {
      id:idCancelLoad
      text: "Cancel"
      width:n4BtnWidth
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.bottomMargin: 20
      anchors.rightMargin: 20
      onClicked:
      {
        idPwdDialog.visible = false;
        idDeleteQuiz.bProgVisible = false
        idImport.visible = false
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
      x:5
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
        width: parent.width  - 10
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
            glosModelIndex.setProperty(idQuizList.currentIndex,"quizname", idQuizNameInput.displayText)
            db.transaction(
                  function(tx) {
                    var nId = glosModelIndex.get(idQuizList.currentIndex).dbnumber;
                    tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[idQuizNameInput.displayText, nId]);
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
        ButtonQuiz {
          id:idBtnCancel
          width:n3BtnWidth
          text:  "Cancel"
          onClicked: {
            idEditQuizEntryDlg.visible = false
          }
        }
      } // Row
    } // Col
  } // Rectangle
} // Item

