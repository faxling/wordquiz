function sortModel() {
  db.transaction(function (tx) {
    QuizLib.loadFromDb(tx)
  })
}

function resetTakeQuizTab() {
  if (idWindow.oTakeQuiz !== undefined) {
    idWindow.oTakeQuiz.bExtraInfoVisible = false
    idWindow.oTakeQuiz.bAnswerVisible = false
    idWindow.oTakeQuiz.bTextAnswerOk = false
  }
}

function getTextFromInput(oTextInput) {
  var oInText = oTextInput.displayText.trim()
  if (oInText.length < 1) {
    idErrorText.visible = true
    idErrorText.text = "No input to lookup in dictionary"
    return ""
  }
  return oInText
}

function updateDesc1(sDesc) {

  var nDbId = glosModelIndex.get(idQuizList.currentIndex).number

  glosModelIndex.get(idQuizList.currentIndex).desc1 = sDesc
  idDescTextOnPage.text = sDesc

  db.transaction(function (tx) {
    var rs = tx.executeSql("SELECT dbnumber FROM GlosaDbDesc WHERE dbnumber=?",
                           [nDbId])
    if (rs.rows.length > 0) {
      tx.executeSql("UPDATE GlosaDbDesc SET desc1=? WHERE dbnumber=?",
                    [sDesc, nDbId])
    } else {
      tx.executeSql("INSERT INTO GlosaDbDesc (desc1 , dbnumber) VALUES(?,?)",
                    [sDesc, nDbId])
    }
  })
}

function downloadDictOnWord(sUrl, sWord) {
  var doc = new XMLHttpRequest()
  doc.open("GET", sUrl + sWord)

  doc.onreadystatechange = function () {

    if (doc.readyState === XMLHttpRequest.DONE) {
      if (doc.status === 200) {
        idErrorText.visible = false
        idTrSynModel.xml = doc.responseText
        idTrTextModel.xml = doc.responseText
        idTrMeanModel.xml = doc.responseText
      } else {
        idErrorText.text = "-"
        idErrorText.visible = true
      }
    }
  }
  doc.send()
}

function getTextInputAndAdd() {
  // Find a new Id
  var nC = 0

  var sNewWordFrom = QuizLib.getTextFromInput(idTextInput)
  var sNewWordTo = QuizLib.getTextFromInput(idTextInput2)

  var i
  for (i = 0; i < glosModel.count; i++) {
    if (glosModel.get(i).question === sNewWordFrom && glosModel.get(
          i).answer === sNewWordTo) {
      idErrorText2.visible = true
      idErrorText2.text = idTextInput.text + " Already in quiz!"
      return
    }

    if (glosModel.get(i).number > nC)
      nC = glosModel.get(i).number
  }

  nC += 1

  if (bHasSpeech)
    MyDownloader.downloadWord(sNewWordTo, sToLang)
  if (bHasSpeechFrom)
    MyDownloader.downloadWord(sNewWordFrom, sFromLang)

  QuizLib.insertGlosa(nDbNumber, nC, sNewWordFrom, sNewWordTo)
}

function getAndInitDb() {

  if (idWindow.db !== undefined)
    return idWindow.db

  console.log("init Word Quiz")

  MyDownloader.initUrls(idWindow)

  db = Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0",
                                         "Glos Databas!", 1000000)

  Sql.LocalStorage.openDatabaseSync()

  db.transaction(function (tx) {

    // tx.executeSql('DROP TABLE GlosaDbIndex');
    var nGlosaDbLastIndex = 0
    tx.executeSql('CREATE TABLE IF NOT EXISTS GlosaDbLastIndex( dbindex INT )')
    var rs = tx.executeSql('SELECT * FROM GlosaDbLastIndex')
    if (rs.rows.length === 0) {
      tx.executeSql('INSERT INTO GlosaDbLastIndex VALUES(0)')
    } else {
      nGlosaDbLastIndex = rs.rows.item(0).dbindex
    }

    tx.executeSql(
          'CREATE TABLE IF NOT EXISTS GlosaDbDesc( dbnumber INT , desc1 TEXT)')
    tx.executeSql(
          'CREATE TABLE IF NOT EXISTS GlosaDbIndex( dbnumber INT , quizname TEXT, state1 TEXT, langpair TEXT )')
    rs = tx.executeSql('SELECT * FROM GlosaDbDesc')
    var oc = []

    for (var i = 0; i < rs.rows.length; i++) {
      var oDescription = {
        "dbnumber": rs.rows.item(i).dbnumber,
        "desc1": rs.rows.item(i).desc1
      }
      oc.push(oDescription)
    }

    rs = tx.executeSql('SELECT * FROM GlosaDbIndex')

    Array.prototype.indexOfObject = function arrayObjectIndexOf(property, value) {
      for (var i = 0, len = this.length; i < len; i++) {
        if (this[i][property] === value)
          return i
      }
      return -1
    }

    var nRowLen = rs.rows.length

    for (i = 0; i < nRowLen; i++) {
      var nDbnumber = rs.rows.item(i).dbnumber
      var nN = oc.indexOfObject("dbnumber", nDbnumber)
      var sDesc = "-"
      if (nN >= 0) {
        sDesc = oc[nN].desc1
      }

      console.debug("quizname - " + rs.rows.item(i).quizname)

      glosModelIndex.append({
                              "number": nDbnumber,
                              "quizname": capitalizeStr(rs.rows.item(
                                                          i).quizname),
                              "state1": rs.rows.item(i).state1,
                              "langpair": rs.rows.item(i).langpair,
                              "desc1": sDesc
                            })
    }

    var bDoChanged = (idWindow.quizListView.currentIndex === -1
                      && nGlosaDbLastIndex === 0)
    idWindow.quizListView.currentIndex = nGlosaDbLastIndex
    if (bDoChanged) {
      idWindow.quizListView.currentIndexChanged()
    }
  })
  return db
}


/*
ocL.append(oJJ["qname"].toString());
ocL.append(oJJ["desc1"].toString());
ocL.append(oJJ["slang"].toString());
ocL.append(oJJ["qcount"].toString());
*/
function assignTextInputField(text) {
  if (nLastSearch !== 1)
    idTextInput2.text = text
  else
    idTextInput.text = text
}

function setAllok(bval) {
  idWindow.bAllok = bval
  idQuizModel.get(0).allok = bval
  idQuizModel.get(1).allok = bval
  idQuizModel.get(2).allok = bval
}

function insertGlosa(dbnumber, nC, question, answer) {
  var sQ = capitalizeStr(question)
  var sA = capitalizeStr(answer)

  db.transaction(function (tx) {
    tx.executeSql('INSERT INTO Glosa' + dbnumber + ' VALUES(?, ?, ?, ?)',
                  [nC, sQ, sA, 0])
  })

  glosModel.append({
                     "answer": sA,
                     "extra": "",
                     "number": nC,
                     "question": sQ,
                     "state1": 0
                   })

  glosModelWorking.append({
                            "answer": sA,
                            "question": sQ,
                            "number": nC,
                            "extra": ""
                          })

  idWindow.glosListView.positionViewAtEnd()
  idWindow.glosListView.currentIndex = glosModel.count - 1
  sScoreText = glosModelWorking.count + "/" + glosModel.count

  setAllok(false)

  if (glosModelWorking.count === 1) {
    idQuizModel.question = sQ
    idQuizModel.answer = sA
    idQuizModel.number = nC
    idQuizModel.extra = ""
  }
}

function assignQuizModel(nIndexOfNewWord) {
  var sNumberNewWord = glosModelWorking.get(nIndexOfNewWord).number
  idQuizModel.question = glosModelWorking.get(nIndexOfNewWord).question
  idQuizModel.answer = glosModelWorking.get(nIndexOfNewWord).answer
  idQuizModel.number = sNumberNewWord
  idQuizModel.extra = glosModelWorking.get(nIndexOfNewWord).extra
  idWindow.nGlosaTakeQuizIndex = MyDownloader.indexFromGlosNr(glosModel,
                                                              sNumberNewWord)

  if (glosModelWorking.count === 1) {
    idQuizModel.get(0).question = idQuizModel.question
    idQuizModel.get(1).question = idQuizModel.question
    idQuizModel.get(2).question = idQuizModel.question
  }

  // idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(glosModel, sNumberNewWord)
}

function loadQuiz() {
  glosModelWorking.clear()
  setAllok(false)

  if (glosModel.count < 1) {
    idQuizModel.question = "-"
    idQuizModel.answer = "-"
    idQuizModel.number = 0
    idQuizModel.extra = "-"
    return
  }

  var nC = glosModel.count

  bIsReverse = false

  var i
  for (i = 0; i < nC; ++i) {
    if (glosModel.get(i).state1 === 0) {

      //glosModelWorking.append(glosModel.get(i))
      glosModelWorking.append({
                                "answer": glosModel.get(i).answer,
                                "question": glosModel.get(i).question,
                                "number": glosModel.get(i).number,
                                "extra": glosModel.get(i).extra
                              })
    }
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)

  // sScoreText =  glosModelWorking.count + "/" + nC
  if (glosModelWorking.count === 0) {
    setAllok(true)
  } else {
    console.log("loadQuiz " + sQuizName)
    assignQuizModel(nIndexOwNewWord)
  }
}

function capitalizeStr(inStr) {
  if (inStr === null)
    return
  if (inStr.length === 0)
    return
  var sA = inStr.trim()
  sA =  sA.charAt(0).toUpperCase() + inStr.slice(1)
  return sA
}

function loadFromDb(tx) {

  // To select the right highlighted word at quiz load time
  var nCurrentNumber = -1
  var oGlosaItem = glosModel.get(idWindow.glosListView.currentIndex)
  if (oGlosaItem !== undefined) {
    nCurrentNumber = oGlosaItem.number
  }

  console.log("nCurrentNumber " + nCurrentNumber)

  glosModel.clear()

  var rs = tx.executeSql(
        "SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort)

  var hasNonInt = false
  for (var i = 0; i < rs.rows.length; i++) {

    var sA
    var sE = ""
    var ocA = rs.rows.item(i).answer.split("###")
    sA = capitalizeStr(ocA[0])

    if (ocA.length > 1)
      sE = ocA[1]

    var sQ = rs.rows.item(i).quizword
    sQ = capitalizeStr(sQ)
    var nNr = rs.rows.item(i).number
    if (nNr !== Math.floor(nNr)) {
      hasNonInt = true
    }

    glosModel.append({
                       "answer": sA,
                       "extra": sE,
                       "number": nNr,
                       "question": sQ,
                       "state1": rs.rows.item(i).state
                     })
  }

  if (hasNonInt) {
    console.log("QUIZ NO " + nDbNumber + " bad numbering")


    /*
    tx.executeSql("DELETE FROM Glosa" + nDbNumber);
    for( i = 0; i < rs.rows.length; i++)
    {
      tx.executeSql('INSERT INTO Glosa' + nDbNumber + ' VALUES(?, ?, ?, ?)', [i+1, rs.rows.item(i).quizword, rs.rows.item(i).answer, rs.rows.item(i).state]);
    }
    */
  }

  // Select hilight after eg sort
  if (nCurrentNumber > 0) {
    idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(
          glosModel, nCurrentNumber)
    idWindow.nGlosaTakeQuizIndex = idWindow.glosListView.currentIndex
    idWindow.glosListView.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                              ListView.Center)
  }
}

function loadFromQuizList() {

  db = getAndInitDb()

  db.transaction(function (tx) {
    tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',
                  [idQuizList.currentIndex])
  })

  if (glosModelIndex.count === 0)
    return

  sQuizName = glosModelIndex.get(idQuizList.currentIndex).quizname
  sLangLang = glosModelIndex.get(idQuizList.currentIndex).langpair
  nDbNumber = glosModelIndex.get(idQuizList.currentIndex).number
  sScoreText = glosModelIndex.get(idQuizList.currentIndex).state1
  idDescTextOnPage.text = glosModelIndex.get(idQuizList.currentIndex).desc1
  idTextInputQuizDesc.text = idDescTextOnPage.text

  var res = sLangLang.split("-")
  sLangLangRev = res[1] + "-" + res[0]
  sToLang = res[1]
  sFromLang = res[0]
  sLangLangEn = "en" + "-" + res[1]
  sReqDictUrl = sReqDictUrlBase + sLangLang + "&text="
  sReqDictUrlRev = sReqDictUrlBase + sLangLangRev + "&text="
  sReqDictUrlEn = sReqDictUrlBase + sLangLangEn + "&text="

  sReqUrl = sReqUrlBase + sLangLang + "&text="
  sReqUrlRev = sReqUrlBase + sLangLangRev + "&text="
  sReqUrlEn = sReqUrlBase + sLangLangEn + "&text="

  db.transaction(function (tx) {

    // tx.executeSql('DROP TABLE Glosa');
    tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber
                  + '( number INT , quizword TEXT, answer TEXT, state INT)')

    loadFromDb(tx)
    loadQuiz()
  })

  idTextSelected.text = sQuizName

  resetTakeQuizTab()
}

function newQuiz() {
  db.transaction(function (tx) {
    glosModel.clear()
    var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex')
    var nNr = 1
    if (rs.rows.length > 0) {
      nNr = rs.rows.item(0).newnr + 1
    }
    sQuizName = idTextInputQuizName.displayText.trim()
    tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',
                  [nNr, sQuizName, "0/0", sLangLangSelected])
    tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nNr, "-"])
    glosModelIndex.append({
                            "number": nNr,
                            "quizname": sQuizName,
                            "state1": "0/0",
                            "langpair": sLangLangSelected,
                            "desc1": "-"
                          })

    idQuizList.positionViewAtEnd()
    idQuizList.currentIndex = glosModelIndex.count - 1
  })
}

function loadFromServerList(nCount, oDD) {
  var nLastIndex = idServerListView.currentIndex
  idServerQModel.clear()
  idDownloadBtn.bProgVisible = false

  idImport.visible = true
  if (nCount === 0) {
    idDescText.text = ""
    idImport.sSelectedQ = ""
    return
  }

  idDescText.text = ""
  idImport.sSelectedQ = ""

  var nIndex = 0

  for (var i = 0; i < nCount; i += 4) {

    var ocDesc = oDD[i + 1].split("###")
    var sDate = "-"

    var sDesc1 = ocDesc[0]

    if (ocDesc.length > 1)
      sDate = ocDesc[1]

    if (nIndex === nLastIndex) {
      idDescDate.text = sDate
      idDescText.text = sDesc1
      idImport.sSelectedQ = oDD[i]
    }

    nIndex++

    idServerQModel.append({
                            "qname": oDD[i],
                            "desc1": sDesc1,
                            "code": oDD[i + 2],
                            "state1": oDD[i + 3],
                            "date1": sDate
                          })
  }
  idServerListView.currentIndex = nLastIndex
}

function quizDeleted(nResponce) {
  idDeleteQuiz.bProgVisible = false
  idDescText.text = ""

  if (nResponce >= 0) {
    idServerQModel.remove(nResponce)
    if (nResponce > 0) {
      idServerListView.currentIndex = nResponce - 1
      idDescText.text = idServerQModel.get(nResponce - 1).desc1
      idImport.sSelectedQ = idServerQModel.get(nResponce - 1).qname
      idImportMsg.text = ""
    }
  } else
    idImportMsg.text = "Not deleted"
}

function quizExported(nResponce) {
  idExportBtn.bProgVisible = false
  idUpdateBtn.bProgVisible = false

  if (nResponce === 0) {
    idExportError.text = "Network error"
    idExportError.visible = true
  } else {
    if (nResponce === 206) {
      idExportError.text = "Quiz with name '" + sQuizName + "' Exists"
      idExportError.visible = true
    } else if (nResponce === 207) {
      idExportError.text = "Can not update '" + sQuizName + "'"
      idExportError.visible = true
    } else if (nResponce === 200) {
      idExport.visible = false
    } else {
      idExportError.text = nResponce
      idExportError.visible = true
    }
  }
}

function loadFromList(nCount, oDD, sLangLoaded) {

  if (nCount < 0) {
    idLoadQuiz.bProgVisible = false
    idImportMsg.text = "error importing"
    return
  }

  db.transaction(function (tx) {
    var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex')
    var nNr = 1
    if (rs.rows.length > 0) {
      nNr = rs.rows.item(0).newnr + 1
    }

    nDbNumber = nNr

    tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nNr
                  + '( number INT , quizword TEXT, answer TEXT, state INT )')

    var sState1 = nCount / 3 + "/" + nCount / 3
    tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)',
                  [nDbNumber, idDescText.text])
    tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',
                  [nDbNumber, sQuizName, sState1, sLangLoaded])

    glosModelIndex.append({
                            "number": nNr,
                            "quizname": sQuizName,
                            "state1": sState1,
                            "langpair": sLangLoaded,
                            "desc1": idDescText.text
                          })

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
      tx.executeSql('INSERT INTO Glosa' + nNr + ' VALUES(?, ?, ?, ?)',
                    [nNumber, oDD[i + 2], sAnswString, 0])
    }
    idLoadQuiz.bProgVisible = false
    idImport.visible = false
    idQuizList.currentIndex = glosModelIndex.count - 1
    if (idQuizList.currentIndex === 0)
      idWindow.quizListView.currentIndexChanged()
  })
}

function isAnswerOk(sAnswerToCheck, sAnswerInDb) {
  sAnswerInDb = MyDownloader.ignoreAccent(sAnswerInDb)
  sAnswerToCheck = MyDownloader.ignoreAccent(sAnswerToCheck)

  if (sAnswerToCheck === "")
    return false

  if (sAnswerInDb === sAnswerToCheck)
    return true

  return false
}

function reverseQuiz() {
  bIsReverse = !bIsReverse
  glosModelWorking.clear()
  resetTakeQuizTab()
  var nC = glosModel.count
  if (nC === 0)
    return

  for (var i = 0; i < nC; ++i) {
    var nState = glosModel.get(i).state1
    if (bIsReverse) {
      var squestion = glosModel.get(i).answer
      var sanswer = glosModel.get(i).question
    } else {
      squestion = glosModel.get(i).question
      sanswer = glosModel.get(i).answer
    }

    var sextra = glosModel.get(i).extra
    var nnC = glosModel.get(i).number
    if (nState === 0)
      glosModelWorking.append({
                                "answer": sanswer,
                                "question": squestion,
                                "number": nnC,
                                "extra": sextra
                              })
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)
  assignQuizModel(nIndexOwNewWord)
}

function resetQuiz() {
  var nC = glosModel.count
  bIsReverse = false
  resetTakeQuizTab()
  if (nC === 0)
    return

  db.transaction(function (tx) {
    tx.executeSql('UPDATE Glosa' + nDbNumber + ' SET state=0')
  })

  glosModelWorking.clear()

  sScoreText = nC + "/" + nC
  for (var i = 0; i < nC; ++i) {
    glosModel.get(i).state1 = 0
    glosModelWorking.append({
                              "answer": glosModel.get(i).answer,
                              "question": glosModel.get(i).question,
                              "number": glosModel.get(i).number,
                              "extra": glosModel.get(i).extra
                            })
  }

  var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)

  assignQuizModel(nIndexOwNewWord)
  setAllok(glosModelWorking.count === 0)
}

function updateQuiz() {
  idEditDlg.visible = false
  var nNumber = glosModel.get(idGlosList.currentIndex).number
  var sQ = capitalizeStr(idTextEdit1.displayText)
  var sA = capitalizeStr(idTextEdit2.displayText)
  var sA_Org = sA

  var sE = idTextEdit3.displayText.trim()
  var nState = idGlosState.checked ? 1 : 0

  db.transaction(function (tx) {
    if (idTextEdit3.displayText.length > 0) {
      sA = sA + "###" + idTextEdit3.displayText
    }

    tx.executeSql(
          'UPDATE Glosa' + nDbNumber + ' SET quizword=?, answer=?, state=? WHERE number = ?',
          [sQ, sA, nState, nNumber])

    // Assign The updated values
    if (idQuizModel.number === nNumber) {
      idQuizModel.question = sQ
      idQuizModel.answer = sA_Org
      idQuizModel.extra = sE
    }
  })

  var i = MyDownloader.indexFromGlosNr(glosModelWorking, nNumber)

  if (i >= 0) {
    if (nState !== 0) {
      glosModelWorking.remove(i)
    } else {
      glosModelWorking.get(i).answer = sA_Org
      glosModelWorking.get(i).question = sQ
      glosModelWorking.get(i).number = nNumber
      glosModelWorking.get(i).extra = sE
    }
  } else {
    if (nState === 0) {
      glosModelWorking.append({
                                "number": nNumber,
                                "question": sQ,
                                "answer": sA_Org,
                                "extra": sE
                              })

      // We change the quize state  from Allok (Thumbs upp) to not allok
      if (glosModelWorking.count === 1) {
        resetTakeQuizTab()
        setAllok(false)
      }
    }
  }

  if (glosModelWorking.count === 1) {
    idQuizModel.question = sQ
    idQuizModel.answer = sA_Org
    idQuizModel.number = nNumber
    idQuizModel.extra = sE
  }

  sScoreText = glosModelWorking.count + "/" + glosModel.count

  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).answer,
                          sToLang)
  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).question,
                          sFromLang)
  glosModel.get(idGlosList.currentIndex).question = sQ
  glosModel.get(idGlosList.currentIndex).answer = sA_Org
  glosModel.get(idGlosList.currentIndex).extra = sE
  glosModel.get(idGlosList.currentIndex).state1 = nState
}

function deleteWordInQuiz() {
  idEditDlg.visible = false
  var nNumber = glosModel.get(idGlosList.currentIndex).number
  db.transaction(function (tx) {
    tx.executeSql('DELETE FROM Glosa' + nDbNumber + ' WHERE number = ?',
                  [nNumber])
  })

  var sQuestion = glosModel.get(idGlosList.currentIndex).question
  var sAnswer = glosModel.get(idGlosList.currentIndex).answer

  glosModel.remove(idGlosList.currentIndex)
  MyDownloader.deleteWord(sAnswer, sToLang)
  MyDownloader.deleteWord(sAnswer, sFromLang)

  var nC = glosModelWorking.count
  for (var i = 0; i < nC; ++i) {
    if (glosModelWorking.get(i).number === nNumber) {
      glosModelWorking.remove(i)
      break
    }
  }

  if (idQuizModel.number === nNumber) {
    resetTakeQuizTab()
  }

  if (glosModel.count > 0) {
    if (idQuizModel.number === nNumber) {
      // The removed word is displayed in the Quiz tab
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)
      idQuizModel.question = glosModelWorking.get(nIndexOwNewWord).question
      idQuizModel.answer = glosModelWorking.get(nIndexOwNewWord).answer
      idQuizModel.number = glosModelWorking.get(nIndexOwNewWord).number
      idQuizModel.extra = glosModelWorking.get(nIndexOwNewWord).extra
    }
  } else {
    idQuizModel.question = "-"
    idQuizModel.answer = "-"
    idQuizModel.number = 0
    idQuizModel.extra = "-"
  }
  sScoreText = glosModelWorking.count + "/" + glosModel.count
}

// To smoth the pathview
var g_oTimer
var g_nLastNumber

function updateDbWithWordState() {
  if (idWindow.bAllok === true) {
    setAllok(true)
  }

  db.transaction(function (tx) {
    tx.executeSql("UPDATE Glosa" + nDbNumber + " SET state=1 WHERE number=?",
                  g_nLastNumber)
  })
}

function Timer() {
  return Qt.createQmlObject("import QtQuick 2.0; Timer {}", idWindow)
}

function calcAndAssigNextQuizWord(currentIndex) {
  var nI = (currentIndex + 1) % 3
  var nLastIndex = idView.nLastIndex

  MyDownloader.storeCurrentIndex(nI)


  //nQuizIndex the index of the view with 3 items that swipes left or right
  nQuizIndex = nI

  if (glosModelWorking.count === 0) {
    return
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

  g_nLastNumber = idQuizModel.number

  idView.nLastIndex = nI

  if (bDir === -1) {
    var i = MyDownloader.indexFromGlosNr(glosModelWorking, g_nLastNumber)

    glosModelWorking.remove(i)

    if (glosModelWorking.count === 0) {
      idWindow.bAllok = true
      idQuizModel.get(nI).allok = true
      idQuizModel.question = ""
      idQuizModel.answer = ""
      idQuizModel.extra = ""
    }

    sScoreText = glosModelWorking.count + "/" + glosModel.count

    i = MyDownloader.indexFromGlosNr(glosModel, g_nLastNumber)

    if (i !== -1) {
      glosModel.get(i).state1 = 1
      if (g_oTimer === undefined) {
        g_oTimer = new Timer()
        g_oTimer.interval = 1000
        g_oTimer.repeat = false
        g_oTimer.triggered.connect(updateDbWithWordState)
      }
      g_oTimer.start()
    }
  }

  if (glosModelWorking.count > 0) {

    while (glosModelWorking.count > 1) {
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)
      if (glosModelWorking.get(nIndexOwNewWord).number !== g_nLastNumber)
        break
    }

    if (glosModelWorking.count === 1) {
      assignQuizModel(0, nQuizIndex)
    } else
      assignQuizModel(nIndexOwNewWord, nQuizIndex)
  }

  resetTakeQuizTab()
}
