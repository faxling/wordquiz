function downloadDictOnWord(sUrl, sWord)
{
  var doc = new XMLHttpRequest();
  doc.open("GET",sUrl+ sWord);

  doc.onreadystatechange = function() {

    if (doc.readyState === XMLHttpRequest.DONE) {
      if (doc.status === 200) {
        idErrorText.visible = false;
        idTrSynModel.xml = doc.responseText
        idTrTextModel.xml = doc.responseText
        idTrMeanModel.xml = doc.responseText
      }
      else
      {
        idErrorText.text = "-"
        idErrorText.visible = true;
      }
    }

  }
  doc.send()
}


function getAndInitDb()
{

  if (idWindow.db !== undefined)
    return idWindow.db;

  console.log("init Word Quiz")

  MyDownloader.initUrls(idWindow);

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

          idWindow.nGlosaDbLastIndex = nGlosaDbLastIndex;

        }
        )
  return db;
}


/*
ocL.append(oJJ["qname"].toString());
ocL.append(oJJ["desc1"].toString());
ocL.append(oJJ["slang"].toString());
ocL.append(oJJ["qcount"].toString());
*/


function insertGlosa(dbnumber, nC, question, answer)
{
  db.transaction(
        function(tx) {
          tx.executeSql('INSERT INTO Glosa'+dbnumber+' VALUES(?, ?, ?, ?)', [nC,  question, answer, 0 ]);
        })

  glosModel.append({"number": nC, "question": question , "answer": answer, "extra": "", "state1":0})

  glosModelWorking.append({"number": nC, "question": question , "answer": answer, "extra": "","state1":0})
  idTab2.glosListView.positionViewAtEnd()
  idTab2.glosListView.currentIndex = glosModel.count -1
  sScoreText = glosModelWorking.count + "/" + glosModel.count

  if (glosModel.count === 1)
  {
    for (var  i = 0; i < 3;++i) {
      idQuizModel.get(i).allok = false;
      idQuizModel.get(i).question = question;
      idQuizModel.get(i).answer = answer;
      idQuizModel.get(i).number = nC;
      idQuizModel.get(i).extra = "";
      idQuizModel.get(i).visible1 = false
    }
  }
}

function loadFromQuizList (){

  db = getAndInitDb();

  db.transaction(
        function(tx) {
          tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',[idQuizList.currentIndex]);
        }
        )

  if (glosModelIndex.count === 0)
    return;



  sQuizName = glosModelIndex.get(idQuizList.currentIndex).quizname;
  sLangLang = glosModelIndex.get(idQuizList.currentIndex).langpair;
  nDbNumber  = glosModelIndex.get(idQuizList.currentIndex).dbnumber;
  sScoreText = glosModelIndex.get(idQuizList.currentIndex).state1;
  idDescTextOnPage.text  = glosModelIndex.get(idQuizList.currentIndex).desc1;



  var res = sLangLang.split("-");
  sLangLangRev = res[1] + "-" + res[0];
  sToLang = res[1]
  sFromLang = res[0]
  sLangLangEn = "en"+ "-" + res[1];
  sReqDictUrl = sReqDictUrlBase +  sLangLang + "&text=";
  sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text=";
  sReqDictUrlEn= sReqDictUrlBase + sLangLangEn + "&text=";

  sReqUrl = sReqUrlBase +  sLangLang + "&text=";

  idWindow.db.transaction(
        function(tx) {
          // tx.executeSql('DROP TABLE Glosa');

          glosModel.clear();
          tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber + '( number INT , quizword TEXT, answer TEXT, state INT)');

          var rs = tx.executeSql('SELECT * FROM Glosa' + nDbNumber );
          var nLen = rs.rows.length

          for(var i = 0; i < nLen; i++) {
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



function newQuiz()
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
          tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nNr,"-"]);
          glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.displayText.trim() , "state1": "0/0", "langpair" : sLangLangSelected, "desc1":"-" });

          idQuizList.positionViewAtEnd();
          idQuizList.currentIndex = glosModelIndex.count -1;

        }
        )
}


function loadFromServerList(nCount, oDD) {
  idServerQModel.clear()
  idDownloadBtn.bProgVisible = false
  idImport.visible = true
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
          var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
          var nNr = 1
          if (rs.rows.length > 0)
          {
            nNr = rs.rows.item(0).newnr + 1
          }

          nDbNumber = nNr;

          tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nNr + '( number INT , quizword TEXT, answer TEXT, state INT )');

          var sState1 = nCount/3 + "/" +nCount/3
          tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nDbNumber,idDescText.text]);
          tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',[nDbNumber, idTextInputQuizName.text,sState1,sLangLoaded  ]);

          glosModelIndex.append({"dbnumber": nNr, "quizname": idTextInputQuizName.text , "state1": sState1 , "langpair" : sLangLoaded, "desc1":idDescText.text })

          // answer, question , state
          /*
          answer
          extra
          question
          */
          for(var i = 0; i < nCount; i+=3) {
            var sAnswString =oDD[i]+"###"+oDD[i+1]
            tx.executeSql('INSERT INTO Glosa' +nNr+' VALUES(?, ?, ?, ?)', [i/2,  oDD[i+2], sAnswString, 0 ]);
          }
          idLoadQuiz.bProgVisible = false
          idImport.visible = false
        }
        );

}
