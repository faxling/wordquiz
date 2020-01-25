function sortModel()
{
  db.transaction(
        function(tx) {QuizLib.loadFromDb(tx)}
        )
}


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

function updateDesc1(sDesc)
{

  var nDbId = glosModelIndex.get(idQuizList.currentIndex).number;

  glosModelIndex.get(idQuizList.currentIndex).desc1 = sDesc
  idDescTextOnPage.text = sDesc


  db.transaction(
        function (tx) {
          var rs = tx.executeSql("SELECT dbnumber FROM GlosaDbDesc WHERE dbnumber=?",[nDbId]);
          if (rs.rows.length > 0)
          {
            tx.executeSql("UPDATE GlosaDbDesc SET desc1=? WHERE dbnumber=?",[sDesc, nDbId]);
          }
          else
          {
            tx.executeSql("INSERT INTO GlosaDbDesc (desc1 , dbnumber) VALUES(?,?)",[sDesc, nDbId]);
          }

        }
        )
}


function downloadDictOnWord(sUrl, sWord) {
  var doc = new XMLHttpRequest();
  doc.open("GET", sUrl + sWord);

  doc.onreadystatechange = function () {

    if (doc.readyState === XMLHttpRequest.DONE) {
      if (doc.status === 200) {
        idErrorText.visible = false;
        idTrSynModel.xml = doc.responseText
        idTrTextModel.xml = doc.responseText
        idTrMeanModel.xml = doc.responseText
      }
      else {
        idErrorText.text = "-"
        idErrorText.visible = true;
      }
    }

  }
  doc.send()
}


function getAndInitDb() {

  if (idWindow.db !== undefined)
    return idWindow.db;

  console.log("init Word Quiz")

  MyDownloader.initUrls(idWindow);

  db = Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0", "Glos Databas!", 1000000);

  Sql.LocalStorage.openDatabaseSync()

  db.transaction(
        function (tx) {

          // tx.executeSql('DROP TABLE GlosaDbIndex');
          var nGlosaDbLastIndex = 0;
          tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbLastIndex( dbindex INT )');
          var rs = tx.executeSql('SELECT * FROM GlosaDbLastIndex')
          if (rs.rows.length === 0) {
            tx.executeSql('INSERT INTO GlosaDbLastIndex VALUES(0)')
          }
          else {
            nGlosaDbLastIndex = rs.rows.item(0).dbindex
          }

          tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbDesc( dbnumber INT , desc1 TEXT)');
          tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbIndex( dbnumber INT , quizname TEXT, state1 TEXT, langpair TEXT )');
          rs = tx.executeSql('SELECT * FROM GlosaDbDesc');
          var oc = [];

          for (var i = 0; i < rs.rows.length; i++) {
            var oDescription = { dbnumber: rs.rows.item(i).dbnumber, desc1: rs.rows.item(i).desc1 }
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

          for (i = 0; i < nRowLen; i++) {
            var nDbnumber = rs.rows.item(i).dbnumber
            var nN = oc.indexOfObject("dbnumber", nDbnumber)
            var sDesc = "-"
            if (nN >= 0) {
              sDesc = oc[nN].desc1
            }

            glosModelIndex.append({ "number": nDbnumber, "quizname": rs.rows.item(i).quizname, "state1": rs.rows.item(i).state1, "langpair": rs.rows.item(i).langpair, "desc1": sDesc })
          }

          var bDoChanged = (idWindow.quizListView.currentIndex === -1 && nGlosaDbLastIndex===0)
          idWindow.quizListView.currentIndex = nGlosaDbLastIndex;
          if (bDoChanged)
          {
            idWindow.quizListView.currentIndexChanged()
          }
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


function insertGlosa(dbnumber, nC, question, answer) {
  db.transaction(
        function (tx) {
          tx.executeSql('INSERT INTO Glosa' + dbnumber + ' VALUES(?, ?, ?, ?)', [nC, question, answer, 0]);
        })

  glosModel.append({ "number": nC, "question": question, "answer": answer, "extra": "", "state1": 0 })

  glosModelWorking.append({  "answer": answer, "question": question, "number": nC, "extra": ""})

  idWindow.glosListView.positionViewAtEnd()
  idWindow.glosListView.currentIndex = glosModel.count - 1
  sScoreText = glosModelWorking.count + "/" + glosModel.count

  idWindow.oTakeQuiz.bAllok = false

  if (glosModelWorking.count === 1) {
    for (var i = 0; i < 3; ++i) {
      idQuizModel.get(i).question = question;
      idQuizModel.get(i).answer = answer;
      idQuizModel.get(i).number = nC;
      idQuizModel.get(i).extra = "";
    }
  }
}

function assignQuizModel(nIndexOfNewWord) {
  var sNumberNewWord = glosModelWorking.get(nIndexOfNewWord).number
  idQuizModel.get(nQuizIndex).question = glosModelWorking.get(nIndexOfNewWord).question;
  idQuizModel.get(nQuizIndex).answer = glosModelWorking.get(nIndexOfNewWord).answer;
  idQuizModel.get(nQuizIndex).number = sNumberNewWord;
  idQuizModel.get(nQuizIndex).extra = glosModelWorking.get(nIndexOfNewWord).extra;
  idWindow.nGlosaTakeQuizIndex = MyDownloader.indexFromGlosNr(glosModel, sNumberNewWord)
  // idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(glosModel, sNumberNewWord)
}


function loadQuiz() {
  glosModelWorking.clear();
  if (idWindow.oTakeQuiz !== undefined)
    idWindow.oTakeQuiz.bAllok = false

  if (glosModel.count < 1) {
    for (var i = 0; i < 3; ++i) {
      idQuizModel.get(i).question = "-";
      idQuizModel.get(i).answer = "-";
      idQuizModel.get(i).number = "-";
      idQuizModel.get(i).extra = "-";
    }
    return;
  }

  var nC = glosModel.count

  bIsReverse = false

  for (i = 0; i < nC; ++i) {
    if (glosModel.get(i).state1 === 0)
    {

      //glosModelWorking.append(glosModel.get(i))
      glosModelWorking.append({"answer": glosModel.get(i).answer,"question": glosModel.get(i).question, "number": glosModel.get(i).number,"extra": glosModel.get(i).extra  })
    }
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

  // sScoreText =  glosModelWorking.count + "/" + nC

  if (glosModelWorking.count === 0) {
    if (idWindow.oTakeQuiz !== undefined)
      idWindow.oTakeQuiz.bAllok = true
  }
  else {
    console.log("loadQuiz " + sQuizName)
    assignQuizModel(nIndexOwNewWord)
  }

}


function loadFromDb(tx) {
  // To select the right word at quiz load time
  var nn = idWindow.glosListView.currentIndex
  var nCurrentNumber = -1
  if (nn>= 0)
  {
    nCurrentNumber = glosModel.get(nn).number
  }
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
  if (nCurrentNumber > 0)
  {
    idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(glosModel, nCurrentNumber)
  }
}



function loadFromQuizList() {

  db = getAndInitDb();

  db.transaction(
        function (tx) {
          tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?', [idQuizList.currentIndex]);
        }
        )

  if (glosModelIndex.count === 0)
    return;



  sQuizName = glosModelIndex.get(idQuizList.currentIndex).quizname;
  sLangLang = glosModelIndex.get(idQuizList.currentIndex).langpair;
  nDbNumber = glosModelIndex.get(idQuizList.currentIndex).number;
  sScoreText = glosModelIndex.get(idQuizList.currentIndex).state1;
  idDescTextOnPage.text = glosModelIndex.get(idQuizList.currentIndex).desc1;
  idTextInputQuizDesc.text = idDescTextOnPage.text;

  var res = sLangLang.split("-");
  sLangLangRev = res[1] + "-" + res[0];
  sToLang = res[1]
  sFromLang = res[0]
  sLangLangEn = "en" + "-" + res[1];
  sReqDictUrl = sReqDictUrlBase + sLangLang + "&text=";
  sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text=";
  sReqDictUrlEn = sReqDictUrlBase + sLangLangEn + "&text=";

  sReqUrl = sReqUrlBase + sLangLang + "&text=";
  sReqUrlRev = sReqUrlBase + sLangLangRev + "&text=";
  sReqUrlEn = sReqUrlBase + sLangLangEn + "&text=";

  db.transaction(
        function (tx) {
          // tx.executeSql('DROP TABLE Glosa');

          tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber + '( number INT , quizword TEXT, answer TEXT, state INT)');

          loadFromDb(tx);
          loadQuiz();
        }


        )

  idTextSelected.text = sQuizName

  if (idWindow.oTakeQuiz !== undefined)
  {
    idWindow.oTakeQuiz.bExtraInfoVisible = false
    idWindow.oTakeQuiz.bAnswerVisible = false
  }
}



function newQuiz() {
  db.transaction(
        function (tx) {

          var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
          var nNr = 1
          if (rs.rows.length > 0) {
            nNr = rs.rows.item(0).newnr + 1
          }
          tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)', [nNr, idTextInputQuizName.displayText, "0/0", sLangLangSelected]);
          tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nNr, "-"]);
          glosModelIndex.append({ "number": nNr, "quizname": idTextInputQuizName.displayText.trim(), "state1": "0/0", "langpair": sLangLangSelected, "desc1": "-" });

          idQuizList.positionViewAtEnd();
          idQuizList.currentIndex = glosModelIndex.count - 1;

        }
        )
}


function loadFromServerList(nCount, oDD) {
  var nLastIndex = idServerListView.currentIndex
  idServerQModel.clear()
  idDownloadBtn.bProgVisible = false

  idImport.visible = true
  if (nCount === 0) {
    idDescText.text = ""
    idImport.sSelectedQ = "";
    return;
  }

  idDescText.text = oDD[1];
  idImport.sSelectedQ = oDD[0];

  for (var i = 0; i < nCount; i += 4) {

    var ocDesc = oDD[i + 1].split("###")
    var sDate = "-"

    var sDesc1 = ocDesc[0]

    if (ocDesc.length > 1)
      sDate = ocDesc[1]

    idServerQModel.append({ "qname": oDD[i], "desc1": sDesc1, "code": oDD[i + 2], "state1": oDD[i + 3], "date1":sDate });
  }
  idServerListView.currentIndex = nLastIndex
}


function quizDeleted(nResponce) {
  idDeleteQuiz.bProgVisible = false
  idDescText.text = ""

  if (nResponce >= 0) {
    idServerQModel.remove(nResponce);
    if (nResponce > 0) {
      idServerListView.currentIndex = nResponce - 1
      idDescText.text = idServerQModel.get(nResponce - 1).desc1;
      idImport.sSelectedQ = idServerQModel.get(nResponce - 1).qname;
      idImportMsg.text = ""
    }
  }
  else
    idImportMsg.text = "Not deleted"
}


function quizExported(nResponce) {
  idExportBtn.bProgVisible = false
  idUpdateBtn.bProgVisible = false

  if (nResponce === 0) {
    idExportError.text = "Network error";
    idExportError.visible = true;
  }
  else {
    if (nResponce === 206) {
      idExportError.text = "Quiz with name '" + sQuizName + "' Exists"
      idExportError.visible = true;
    }
    else if (nResponce === 207) {
      idExportError.text = "Can not update '" + sQuizName + "'"
      idExportError.visible = true;
    }
    else if (nResponce === 200) {
      idExport.visible = false;
    }
    else {
      idExportError.text = nResponce
      idExportError.visible = true;
    }
  }
}

function loadFromList(nCount, oDD, sLangLoaded) {


  if (nCount < 0) {
    idLoadQuiz.bProgVisible = false
    idImportMsg.text = "error importing"
    return
  }



  db.transaction(

        function (tx) {
          var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex');
          var nNr = 1
          if (rs.rows.length > 0) {
            nNr = rs.rows.item(0).newnr + 1
          }

          nDbNumber = nNr;

          tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nNr + '( number INT , quizword TEXT, answer TEXT, state INT )');

          var sState1 = nCount / 3 + "/" + nCount / 3
          tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nDbNumber, idDescText.text]);
          tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)', [nDbNumber, idTextInputQuizName.text, sState1, sLangLoaded]);

          glosModelIndex.append({ "number": nNr, "quizname": idTextInputQuizName.text, "state1": sState1, "langpair": sLangLoaded, "desc1": idDescText.text })

          // answer, question , state
          /*
              answer
              extra
              question
              */
          var nNumber = 0
          for (var i = 0; i < nCount; i += 3) {
            var sAnswString = oDD[i] + "###" + oDD[i + 1]
            nNumber = nNumber + 1
            tx.executeSql('INSERT INTO Glosa' + nNr + ' VALUES(?, ?, ?, ?)', [nNumber, oDD[i + 2], sAnswString, 0]);
          }
          idLoadQuiz.bProgVisible = false
          idImport.visible = false
          idQuizList.currentIndex = glosModelIndex.count -1

        }
        );

}


function reverseQuiz()
{
  bIsReverse =  !bIsReverse
  glosModelWorking.clear()
  var nC = glosModel.count
  if (nC === 0)
    return

  for ( var i = 0; i < nC;++i) {
    var nState = glosModel.get(i).state1;
    if (bIsReverse)
    {
      var squestion = glosModel.get(i).answer
      var sanswer = glosModel.get(i).question
    }
    else
    {
      squestion = glosModel.get(i).question
      sanswer = glosModel.get(i).answer
    }

    var sextra = glosModel.get(i).extra
    var nnC  = glosModel.get(i).number
    if (nState === 0 )
      glosModelWorking.append({  "answer": sanswer,"question": squestion , "number": nnC,"extra":sextra})
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
  assignQuizModel(nIndexOwNewWord)
}


function resetQuiz()
{
  var nC = glosModel.count
  bIsReverse = false

  if (nC===0)
    return
  db.transaction(
        function(tx) {
          tx.executeSql('UPDATE Glosa'+nDbNumber+' SET state=0');
        }
        )

  glosModelWorking.clear()

  sScoreText = nC + "/" + nC
  for ( var i = 0; i < nC;++i) {
    glosModel.get(i).state1=0;
    glosModelWorking.append({"answer": glosModel.get(i).answer,"question": glosModel.get(i).question, "number": glosModel.get(i).number,"extra": glosModel.get(i).extra  })
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);

  idWindow.oTakeQuiz.bAllok = false
  assignQuizModel(nIndexOwNewWord)
}




function updateQuiz()
{
  idEditDlg.visible = false
  var nNumber = glosModel.get(idGlosList.currentIndex).number
  var sQ =  idTextEdit1.text.trim()
  var sA =  idTextEdit2.text.trim()
  var sA_Org =  sA

  var sE =  idTextEdit3.text.trim()
  var nState = idGlosState.checked ? 1 :0

  if (nState === 0)
    idWindow.oTakeQuiz.bAllok = false

  db.transaction(
        function(tx) {
          if (idTextEdit3.text.length > 0)
          {
            sA = sA + "###" + idTextEdit3.text
          }

          tx.executeSql('UPDATE Glosa'+nDbNumber+' SET quizword=?, answer=?, state=? WHERE number = ?',[sQ,sA,nState,nNumber]);

          // Assign The updated values
          for ( var i = 0; i < 3;++i) {
            if (idQuizModel.get(i).number === nNumber)
            {
              idQuizModel.get(i).question = sQ;
              idQuizModel.get(i).answer = sA_Org;
              idQuizModel.get(i).extra = sE;
              idQuizModel.get(i).state1 = nState
            }
          }
        }
        )


  var i = MyDownloader.indexFromGlosNr(glosModelWorking, nNumber);

  if (i >= 0)
  {
    if (nState !== 0)
    {
      glosModelWorking.remove(i)
    }
    else
    {
      glosModelWorking.get(i).answer = sA_Org
      glosModelWorking.get(i).question = sQ
      glosModelWorking.get(i).number = nNumber
      glosModelWorking.get(i).extra = sE
    }
  }
  else
  {
    if (nState === 0)
    {
      glosModelWorking.append({ "number": nNumber, "question": sQ, "answer": sA_Org, "extra": sE})
    }
  }

  idWindow.oTakeQuiz.bAllok = glosModelWorking.count === 0

  if (glosModelWorking.count === 1) {
    for (var i = 0; i < 3; ++i) {
      idQuizModel.get(i).question = sQ;
      idQuizModel.get(i).answer = sA_Org;
      idQuizModel.get(i).number = nNumber;
      idQuizModel.get(i).extra = sE;
    }
  }

  sScoreText  = glosModelWorking.count + "/" + glosModel.count

  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).answer,sToLang)
  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).question,sFromLang)
  glosModel.get(idGlosList.currentIndex).question = sQ
  glosModel.get(idGlosList.currentIndex).answer = sA_Org
  glosModel.get(idGlosList.currentIndex).extra =  sE
  glosModel.get(idGlosList.currentIndex).state1 = nState
}

function deleteWordInQuiz()
{
  idEditDlg.visible = false
  var nNumber = glosModel.get(idGlosList.currentIndex).number
  db.transaction(
        function(tx) {
          tx.executeSql('DELETE FROM Glosa'+nDbNumber+' WHERE number = ?',[nNumber]);
        }
        )

  var sQuestion = glosModel.get(idGlosList.currentIndex).question
  var sAnswer = glosModel.get(idGlosList.currentIndex).answer

  glosModel.remove(idGlosList.currentIndex)
  MyDownloader.deleteWord(sAnswer,sToLang)
  MyDownloader.deleteWord(sAnswer,sFromLang)

  var nC = glosModelWorking.count;
  for ( var i = 0; i < nC;++i) {
    if (glosModelWorking.get(i).number === nNumber)
    {
      glosModelWorking.remove(i);
      break;
    }
  }

  if (idQuizModel.get(nQuizIndex).number === nNumber)
  {
    idWindow.oTakeQuiz.bExtraInfoVisible = false
    idWindow.oTakeQuiz.bAnswerVisible = false
  }

  if (glosModel.count > 0)
  {
    for (  i = 0; i < 3;++i) {
      if (idQuizModel.get(i).number === nNumber)
      {
        // The removed word is displayed in the Quiz tab
        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
        idQuizModel.get(i).question = glosModelWorking.get(nIndexOwNewWord).question;
        idQuizModel.get(i).answer = glosModelWorking.get(nIndexOwNewWord).answer;
        idQuizModel.get(i).number = glosModelWorking.get(nIndexOwNewWord).number;
        idQuizModel.get(i).extra = glosModelWorking.get(nIndexOwNewWord).extra;
      }
    }
  }
  else
  {
    for (  i = 0; i < 3;++i) {
      idQuizModel.get(i).question = "-";
      idQuizModel.get(i).answer = "-";
      idQuizModel.get(i).number = 0;
      idQuizModel.get(i).extra = "-";
    }
  }
  sScoreText = glosModelWorking.count + "/" + glosModel.count
}

function calcAndAssigNextQuizWord(currentIndex)
{

  var nI = (currentIndex+1) % 3
  var nLastIndex = idView.nLastIndex

  //nQuizIndex the index of the view with 3 items that swipes left or right

  nQuizIndex = nI

  if (glosModelWorking.count === 0 )
  {
    idWindow.oTakeQuiz.bAllok = true
    return;
  }

  var bDir = 0

  if (nLastIndex === 0 && nI === 1)
    bDir = 1
  if (nLastIndex === 0 && nI === 2)
    bDir = -1
  if (nLastIndex === 1 && nI === 0)
    bDir = -1
  if (nLastIndex === 1 && nI === 2)
    bDir = 1
  if (nLastIndex === 2 && nI === 0)
    bDir = 1
  if (nLastIndex === 2 && nI === 1)
    bDir = -1


  var nLastNumber = idQuizModel.get(nLastIndex).number

  idView.nLastIndex = nI

  if (bDir ===-1)
  {
    var i = MyDownloader.indexFromGlosNr(glosModelWorking, nLastNumber);

    glosModelWorking.remove(i);

    if (glosModelWorking.count ===0 )
    {
      idWindow.oTakeQuiz.bAllok = true
      for ( i = 0; i < 3 ;++i)
      {
        idQuizModel.get(i).question =  ""
        idQuizModel.get(i).answer =  ""
        idQuizModel.get(i).extra =  ""
      }
    }

    sScoreText  = glosModelWorking.count + "/" + glosModel.count

    i =  MyDownloader.indexFromGlosNr(glosModel, nLastNumber);

    if (i !== -1)
    {
      glosModel.get(i).state1 = 1;

      db.transaction(
            function(tx) {
              tx.executeSql("UPDATE Glosa"+nDbNumber+" SET state=1 WHERE number=?", nLastNumber);
            })

    }
  }

  if (glosModelWorking.count>0)
  {

    while (glosModelWorking.count > 1)
    {
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
      if (glosModelWorking.get(nIndexOwNewWord).number !== nLastNumber)
        break
    }

    if (glosModelWorking.count === 1)
      assignQuizModel(0,nQuizIndex)
    else
      assignQuizModel(nIndexOwNewWord,nQuizIndex)

  }

  idRectTakeQuiz.bExtraInfoVisible = false
  idRectTakeQuiz.bAnswerVisible = false
}
