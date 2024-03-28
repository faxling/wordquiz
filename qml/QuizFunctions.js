function initLangList() {

  // https://www.countryflags.com/
  idLangModel.append({
                       "lang": "Swedish",
                       "imgsource": "qrc:/sweden-flag-button-round-icon-128.png",
                       "code": "sv"
                     })

  idLangModel.append({
                       "lang": "Russian",
                       "imgsource": "qrc:/russia-flag-button-round-icon-128.png",
                       "code": "ru"
                     })

  idLangModel.append({
                       "lang": "French",
                       "imgsource": "qrc:/france-flag-button-round-icon-128.png",
                       "code": "fr"
                     })
  idLangModel.append({
                       "lang": "Italian",
                       "imgsource": "qrc:/italy-flag-button-round-icon-128.png",
                       "code": "it"
                     })

  idLangModel.append({
                       "lang": "English",
                       "imgsource": "qrc:/united-kingdom-flag-button-round-icon-128.png",
                       "code": "en"
                     })

  idLangModel.append({
                       "lang": "German",
                       "imgsource": "qrc:/germany-flag-button-round-icon-128.png",
                       "code": "de"
                     })
  idLangModel.append({
                       "lang": "Polish",
                       "imgsource": "qrc:/poland-flag-button-round-icon-128.png",
                       "code": "pl"
                     })

  idLangModel.append({
                       "lang": "Norvegian",
                       "imgsource": "qrc:/norway-flag-button-round-icon-128.png",
                       "code": "no"
                     })

  idLangModel.append({
                       "lang": "Spanish",
                       "imgsource": "qrc:/spain-flag-button-round-icon-128.png",
                       "code": "es"
                     })

  idLangModel.append({
                       "lang": "Hungarian",
                       "imgsource": "qrc:/hungary-flag-button-round-icon-128.png",
                       "code": "hu"
                     })

  idLangModel.append({
                       "lang": "Korean",
                       "imgsource": "qrc:/south-korea-flag-button-round-icon-128.png",
                       "code": "ko"
                     })
}

function hangUpdateImage() {
  var n = idLangModel.count
  var sL = bIsReverseHang ? sToLang : sFromLang

  var i = 0
  for (i = 0; i < n; ++i) {
    if (idLangModel.get(i).code === sL) {
      idFlagImg.source = idLangModel.get(i).imgsource
      break
    }
  }
}

function destroyChildren(idOc) {
  for (var childIndex in idOc.children) {
    idOc.children[childIndex].destroy()
  }
  idOc.children = null
}

function hangClearThings() {
  idHangBtn3.bAV = false
  idResultMsg.visible = false
  idResultMsgTimer.stop()

  destroyChildren(idOrdRow)
  destroyChildren(idOrdCol)
  destroyChildren(idOrdCol2)
  destroyChildren(idOrdCol3)

  idTTrans.visible = false
  idCharRect.text = ""
}

function hangNewQ() {
  bIsReverseHang = false
  hangClearThings()
  idDrawing.renderId(1)
  hangUpdateImage()
  idFlagImg.visible = true
}

function hangAddWord() {
  hangClearThings()
  var n = 0
  var i = 0
  var nIndexOfNewWord = 0
  for (i = 0; i < 10; ++i) {
    nIndexOfNewWord = Math.floor(MyDownloader.rand() * glosModel.count)

    if (bIsReverseHang) {
      sHangWord = glosModel.get(nIndexOfNewWord).answer
      idTTrans.text = glosModel.get(nIndexOfNewWord).question
    } else {
      sHangWord = glosModel.get(nIndexOfNewWord).question
      idTTrans.text = glosModel.get(nIndexOfNewWord).answer
    }

    sHangWord = sHangWord.toUpperCase()
    sHangWord = MyDownloader.removeDiacritics(sHangWord)
    n = sHangWord.length
    if (n < 14)
      break
  }

  if (i === 10) {
    idErrorDialogHangMan.text = "Create or Select a Word Quiz that contains short words!"
    idErrorDialogHangMan.visible = true
    return
  }

  sCurrentRow = []

  for (i = 0; i < n; ++i) {
    var ch = sHangWord[i]

    if (MyDownloader.isSpecial(ch)) {
      sCurrentRow.push((ch))
      idChar.createObject(idOrdRow, {
                            "text": ch,
                            "bIsSpecial": true
                          })
    } else {
      sCurrentRow.push(" ")
      idChar.createObject(idOrdRow)
    }
  }
  idWindow.nGlosaTakeQuizIndex = nIndexOfNewWord
}

function hangCheckCharInColumn(sChar, oColumn) {

  for (var i in oColumn.children) {
    if (MyDownloader.ignoreAccent(
          oColumn.children[i].text) === MyDownloader.ignoreAccent(sChar))
      return true
  }

  return false
}

function hangCheckChar(sChar) {
  if (hangCheckCharInColumn(sChar, idOrdCol))
    return true

  if (hangCheckCharInColumn(sChar, idOrdCol2))
    return true

  if (hangCheckCharInColumn(sChar, idOrdCol3))
    return true

  return false
}

function hangEnterChar() {
  idFlagImg.visible = false
  Qt.inputMethod.hide()
  if (idCharRect.text === " " || idCharRect.text === "")
    return

  var n = sHangWord.length
  var nValidCount = 0
  var nOKCount = 0
  var nC = 0
  var i = 0
  for (i = 0; i < n; ++i) {
    if (idOrdRow.children[i].bIsSpecial)
      continue

    ++nValidCount

    if (idOrdRow.children[i].text !== "")
      nOKCount += 1
  }

  if (nOKCount === nValidCount) {
    return
  }

  nOKCount = 0
  nValidCount = 0
  for (i = 0; i < n; ++i) {
    if (idOrdRow.children[i].bIsSpecial)
      continue

    ++nValidCount

    if (MyDownloader.ignoreAccent(sHangWord[i]) === MyDownloader.ignoreAccent(
          idCharRect.text[0])) {
      nC += 1
      idOrdRow.children[i].text = sHangWord[i]
      sCurrentRow[i] = sHangWord[i]
    }

    if (idOrdRow.children[i].text !== "")
      nOKCount += 1
  }

  if (nOKCount === nValidCount) {
    idResultMsg.visible = true
    idResultMsg.text = idDrawing.getRating()
    idDrawing.renderId(0)
    return
  }

  if (nC === 0) {
    n = idOrdCol.children.length
    var hRet = hangCheckChar(idCharRect.text)
    if (hRet)
      return
    if (n === 1) {
      nUsedCharColLen = idHangMan.height / (idOrdCol.children[0].width * 1.8)
    }

    if (n < nUsedCharColLen)
      idChar.createObject(idOrdCol, {
                            "text": idCharRect.text
                          })
    else if (n < nUsedCharColLen * 2)
      idChar.createObject(idOrdCol2, {
                            "text": idCharRect.text
                          })
    else
      idChar.createObject(idOrdCol3, {
                            "text": idCharRect.text
                          })

    var bRet = idDrawing.renderId(2)

    if (!bRet) {
      idResultMsg.visible = true
      idResultMsg.text = "Game Over!"
      idResultMsgTimer.start()
    }
  }
}

function hangShowAnswer(bAV) {
  if (bAV) {
    for (var j in idOrdRow.children) {
      idOrdRow.children[j].text = sHangWord[j]
    }
  } else {
    for (var i in idOrdRow.children) {
      if (sCurrentRow[i] !== " ")
        idOrdRow.children[i].text = sCurrentRow[i]
      else
        idOrdRow.children[i].text = ""
    }
  }
}

function connectMyDownloader() {
  MyDownloader.exportedSignal.connect(QuizLib.quizExported)
  MyDownloader.quizDownloadedSignal.connect(QuizLib.loadFromList)
  MyDownloader.quizListDownloadedSignal.connect(QuizLib.loadFromServerList)
  MyDownloader.deletedSignal.connect(QuizLib.quizDeleted)
  idWindow.quizListView = idQuizList
}

String.prototype.equalIgnoreCase = function (str) {
  return this.toUpperCase() === str.toUpperCase()
}

Array.prototype.indexOfObject = function arrayObjectIndexOf(property, value) {

  for (var i in this) {
    if (this[i][property] === value)
      return i
  }

  return -1
}

// Sorts the questions and answer in the selected quiz
function sortQuestionModel(nSortRoleIn, nOrder) {

  if (nSortRoleIn === nQuizSortRole)
    nOrder.bSortAsc = !nOrder.bSortAsc
  else
    nQuizSortRole = nSortRoleIn

  bDESC = nOrder.bSortAsc

  db.readTransaction(function (tx) {
    QuizLib.loadFromDb(tx, 1)
  })
}

// Sorts the list of aviable quizes
// Sort role 0 Name 1 lang
function sortQuizModel(nSortRoleIn, nOrder) {
  if (idTextAvailable.nSortRole === nSortRoleIn)
    nOrder.bSortAsc = !nOrder.bSortAsc
  else
    idTextAvailable.nSortRole = nSortRoleIn

  if (idQuizList.currentItem !== null)
    var j = idQuizList.currentItem.nNumber

  idQuizList.currentIndex = -1
  MyDownloader.sortQuizModel(idTextAvailable.nSortRole, nOrder.bSortAsc)

  if (j !== undefined)
    idQuizList.currentIndex = MyDownloader.indexFromGlosNr(glosModelIndex, j)
}

function setAnswerVisible() {
  var i = nQuizIndex1_3
  idQuizModel.get(i).answerVisible = true
}

function toggleAnswerVisible() {
  var i = nQuizIndex1_3
  idQuizModel.get(i).answerVisible = !idQuizModel.get(i).answerVisible
}

function resetTakeQuizTab() {
  if (idWindow.oTakeQuiz !== undefined) {
    idWindow.oTakeQuiz.bExtraInfoVisible = false

    var nC = idQuizModel.count
    for (var i = 0; i < nC; ++i) {
      idQuizModel.get(i).answerVisible = false
    }
  }
}

function getTextFromInput(oTextInput) {
  var oInText = capitalizeStr(oTextInput.displayText)
  if (oInText.length < 1) {
    idErrorText.visible = true
    idErrorText.text = "No input to lookup in dictionary"
    return ""
  }
  return oInText
}

function reqTranslation(oBtnIn, bIsSecond) {
  var oInText
  var sUrl
  if (bIsSecond) {
    nLastSearch = 1
    oInText = getTextFromInput(idTextInput2)
    sUrl = sReqUrlRev + oInText
  } else {
    nLastSearch = 0
    oInText = getTextFromInput(idTextInput)
    sUrl = sReqUrl + oInText
  }

  if (oInText === "")
    return

  oBtnIn.bProgVisible = true

  if (bIsSecond) {
    MyDownloader.translateWord(oInText, idWindow.sToLang,
                               idWindow.sFromLang, oBtnIn)
    if (bHasDictFrom)
      downloadDictOnWord(sReqDictUrlRev, oInText)
  } else {
    MyDownloader.translateWord(oInText, idWindow.sFromLang,
                               idWindow.sToLang, oBtnIn)
    if (bHasDictTo)
      downloadDictOnWord(sReqDictUrl, oInText)
  }
}

function openWwwPage(sUrl, sTitle) {
  if (typeof pageStack === "undefined") {
    MyDownloader.openUrl(sUrl)
  } else
    pageStack.push("pages/WikiView.qml", {
                     "url": sUrl,
                     "sTitle": sTitle
                   })
}

function openManPage() {
  pageStack.push("pages/HelpView.qml")
}

function lookUppInWiki() {
  var oInText

  var sLang
  sLang = bDoLookUppText1 ? sFromLang : sToLang

  if (bDoLookUppText1)
    oInText = getTextFromInput(idTextInput)
  else
    oInText = getTextFromInput(idTextInput2)

  if (oInText === "")
    return

  var sUrl = "http://" + sLang + ".wiktionary.org/w/index.php?title=" + oInText.toLowerCase()

  openWwwPage(sUrl, sLang + " Wiktionary on \"" + oInText + "\"")
}

function showUpploadDlg() {
  idExport.visible = true
  idTextInputQuizDesc.text = idWindow.sQuizDesc
  idExportError.visible = false
}
function updateDesc1(sDesc) {

  // var nCurIndexInQList = idWindow.quizListView.currentIndex
  var o = quizFromCurrentItem()
  var nDbId = o.number

  if (sDesc !== undefined) {
    sDesc = sDesc.trim()
    sQuizDesc = sDesc
    idTextInputQuizDesc.text = sDesc
    o.desc1 = sDesc
  }
  var sDateStr = MyDownloader.dateStr()
  var sDescAndDate = sQuizDesc + "###" + sDateStr

  o.descdate = sDateStr
  idWindow.sQuizDate = sDateStr

  db.transaction(function (tx) {
    var rs = tx.executeSql("SELECT dbnumber FROM GlosaDbDesc WHERE dbnumber=?",
                           [nDbId])

    if (rs.rows.length > 0) {
      tx.executeSql("UPDATE GlosaDbDesc SET desc1=? WHERE dbnumber=?",
                    [sDescAndDate, nDbId])
    } else {
      tx.executeSql("INSERT INTO GlosaDbDesc (desc1 , dbnumber) VALUES(?,?)",
                    [sDescAndDate, nDbId])
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
  if (sNewWordFrom === "")
    return
  var sNewWordTo = QuizLib.getTextFromInput(idTextInput2)
  if (sNewWordTo === "")
    return
  var i
  for (i = 0; i < glosModel.count; i++) {
    if (sNewWordFrom.equalIgnoreCase(glosModel.get(i).question)
        && sNewWordTo.equalIgnoreCase(glosModel.get(i).answer)) {
      idErrorText2.visible = true
      idErrorText2.text = idTextInput.text + " Already in quiz!"
      return
    }

    if (glosModel.get(i).number > nC)
      nC = glosModel.get(i).number
  }

  nC += 1

  MyDownloader.downloadWord(sNewWordTo, sToLang)
  MyDownloader.downloadWord(sNewWordFrom, sFromLang)

  QuizLib.insertGlosa(nDbNumber, nC, sNewWordFrom, sNewWordTo)

  if (glosModelWorking.count === 3)
    assignThreeWorkingItem()
  else if (glosModelWorking.count === 2)
    assignTwoWorkingItems()
  else if (glosModelWorking.count === 1)
    assignOneWorkingItem()
}

function getAndInitDb() {

  if (idWindow.db !== undefined)
    return idWindow.db

  console.log("init Word Quiz")

  MyDownloader.initUrls(idWindow)

  db = Sql.LocalStorage.openDatabaseSync("GlosDB", "1.0",
                                         "Glos Databas!", 1000000)

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

    var nRowLen = rs.rows.length

    for (var j = 0; j < nRowLen; j++) {
      var nDbnumber = rs.rows.item(j).dbnumber
      var nN = oc.indexOfObject("dbnumber", nDbnumber)
      var vDescDate

      if (nN >= 0) {
        vDescDate = oc[nN].desc1
      }

      idGlosModelIndex.append({
                                "number": nDbnumber,
                                "quizname": capitalizeStr(rs.rows.item(
                                                            j).quizname),
                                "state1": rs.rows.item(j).state1,
                                "langpair": rs.rows.item(j).langpair,
                                "desc1": getDesc(vDescDate),
                                "descdate": getDate(vDescDate)
                              })
    }

    if (idGlosModelIndex.count === 0) {
      idGlosModelIndex.append({
                                "number": 1,
                                "quizname": "-",
                                "state1": "-",
                                "langpair": "-",
                                "desc1": "-",
                                "descdate": ""
                              })

      glosModelIndex = MyDownloader.setOLFilterProxy(idGlosModelIndex)
      idGlosModelIndex.remove(0)
    } else {
      glosModelIndex = MyDownloader.setOLFilterProxy(idGlosModelIndex)
    }


    /*
    enum SortOrder {
        AscendingOrder,
        DescendingOrder
   };
   */
    // Role 0 = Name 1 = Lang
    MyDownloader.sortQuizModel(0, 0)

    // Set to last assigned Quiz
    if (idWindow.quizListView !== undefined) {
      var nC = idWindow.quizListView.currentIndex
      idWindow.quizListView.currentIndex = MyDownloader.indexFromGlosNr(
            glosModelIndex, nGlosaDbLastIndex)

      if (nC === idWindow.quizListView.currentIndex) {
        idWindow.quizListView.currentItemChanged()
      }
    }
  })
  return db
}

function assignTextInputField(text) {
  text = text.trim()
  if (nLastSearch !== 1)
    idTextInput2.text = text + " "
  else
    idTextInput.text = text + " "
}

function setAllok(bval) {
  var nC = idQuizModel.count
  for (var i = 0; i < nC; ++i) {
    idQuizModel.get(i).allOk1_3 = bval
  }
}

// Updates the description of the Quiz with new date
function insertGlosa(dbnumber, nC, question, answer) {
  var sQ = capitalizeStr(question)
  var sA = capitalizeStr(answer)

  db.transaction(function (tx) {
    tx.executeSql('INSERT INTO Glosa' + dbnumber + ' VALUES(?, ?, ?, ?)',
                  [nC, sQ, sA, 0])
  })

  glosModel.insert(0, {
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

  idWindow.glosListView.currentIndex = 0
  sScoreText = glosModelWorking.count + "/" + glosModel.count

  setAllok(false)

  updateDesc1()
}

function assignQuizModel(nIndexNewWordInModelWorking, nIndexInQuizModel) {
  var i = nIndexInQuizModel
  var j = nIndexNewWordInModelWorking
  var sQ = glosModelWorking.get(j).question
  idQuizModel.get(i).question = sQ
  idQuizModel.get(i).answer = glosModelWorking.get(j).answer
  idQuizModel.get(i).extra = glosModelWorking.get(j).extra
  var nNumberDbNewWord = glosModelWorking.get(j).number
  idQuizModel.get(i).numberDb = nNumberDbNewWord
  idQuizModel.get(i).imgUrl = String(MyDownloader.imageSrc(
                                       sQ, sLangLang))
}

// Return false if already existing in the three item model
function assignQuizModelUnique(nIndexNewWordInModelWorking, nNumberInQuizModel) {
  var i = nNumberInQuizModel
  var j = nIndexNewWordInModelWorking
  var nNumberDbNewWord = glosModelWorking.get(j).number
  for (var k = 0; k < 3; ++k) {
    if (idQuizModel.get(k).numberDb === nNumberDbNewWord) {
      return false
    }
  }
  var sQ = glosModelWorking.get(j).question
  idQuizModel.get(i).question = sQ
  idQuizModel.get(i).answer = glosModelWorking.get(j).answer
  idQuizModel.get(i).extra = glosModelWorking.get(j).extra

  idQuizModel.get(i).numberDb = nNumberDbNewWord
  idQuizModel.get(i).imgUrl = String(MyDownloader.imageSrc(
                                       sQ, sLangLang))
  return true
}

function assignQuizModelAll() {
  if (glosModelWorking.count === 0) {
    setAllok(true)
    return
  }
  setAllok(false)

  if (glosModelWorking.count > 3) {
    var i = 0
    while (i < 3) {
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)
      if (assignQuizModelUnique(nIndexOwNewWord, i))
        ++i
    }
  } else if (glosModelWorking.count === 3) {
    assignQuizModel(0, 0)
    assignQuizModel(1, 1)
    assignQuizModel(2, 2)
  } else if (glosModelWorking.count === 2) {
    assignQuizModel(0, 0)
    assignQuizModel(1, 1)
    assignQuizModel(1, 2)
  } else if (glosModelWorking.count === 1) {
    assignOneWorkingItem()
  }
}

function loadQuiz() {
  glosModelWorking.clear()

  bIsReverse = false

  if (glosModel.count < 1) {
    var nC = idQuizModel.count
    for (var i = 0; i < nC; ++i) {
      idQuizModel.get(i).imgUrl = sDEFAULT_IMG
      idQuizModel.get(i).answerVisible = false
      idQuizModel.get(i).question = "-"
      idQuizModel.get(i).answer = "-"
      idQuizModel.get(i).number = 0
      idQuizModel.get(i).extra = ""
    }
    return
  }

  nC = glosModel.count

  for (i = 0; i < nC; ++i) {
    if (glosModel.get(i).state1 === 0) {
      glosModelWorking.append({
                                "answer": glosModel.get(i).answer,
                                "question": glosModel.get(i).question,
                                "number": glosModel.get(i).number,
                                "extra": glosModel.get(i).extra
                              })
    }
  }
  assignQuizModelAll()
}

function capitalizeStr(inStr) {
  if (inStr === null)
    return ""
  if (inStr.length === 0)
    return ""
  var sA = inStr.trim().toLowerCase()
  sA = sA.charAt(0).toUpperCase() + sA.slice(1)
  return sA
}

function loadFromDb(tx, nSelectFromCurrentIndex) {

  // To select the right highlighted word at quiz load time when sorting nSelectFromCurrentIndex == 1 in that case
  var nCurrentNumber = -1
  if (nSelectFromCurrentIndex > 0) {
    var oGlosaItem = glosModel.get(idWindow.glosListView.currentIndex)
    if (oGlosaItem !== undefined) {
      nCurrentNumber = oGlosaItem.number
    }
  }

  glosModel.clear()

  var rs = tx.executeSql(
        "SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort + sDESCASC)

  var hasNonInt = false
  for (var i = 0; i < rs.rows.length; i++) {

    var sWordAndExtra = rs.rows.item(i).answer
    var sA = capitalizeStr(getWord(sWordAndExtra))
    var sE = getExtra(sWordAndExtra)
    var sQ = capitalizeStr(rs.rows.item(i).quizword)
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

  // Select highlight after  sort
  if (nCurrentNumber > 0) {
    idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(
          glosModel, nCurrentNumber)
    idWindow.nGlosaTakeQuizIndex = idWindow.glosListView.currentIndex
    idWindow.glosListView.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                              ListView.Center)
  } else {
    idWindow.nGlosaTakeQuizIndex = -1
    idWindow.glosListView.currentIndex = -1
  }
}

function renameQuiz(sQuizName) {

  sQuizName = capitalizeStr(sQuizName)

  if (sQuizName.length < 4) {
    idErrorDialog.text = "'" + idTextInputQuizName.displayText + "'" + " To short Quiz name"
    idErrorDialog.visible = true
    return
  }

  idWindow.sQuizName = sQuizName

  db.transaction(function (tx) {
    var o = quizFromCurrentItem()
    o.quizname = sQuizName
    var nId = o.number
    tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',
                  [sQuizName, nId])
    idTextSelected.text = sQuizName
    idQuizList.currentIndex = MyDownloader.indexFromGlosNr(glosModelIndex, nId)
  })
}

function indexQuizFromCurrentItem() {
  return MyDownloader.indexFromGlosNr(idGlosModelIndex,
                                      idQuizList.currentItem.nNumber)
}

function quizFromCurrentItem() {

  if (idWindow.quizListView.currentItem === null)
    return
  var j = MyDownloader.indexFromGlosNr(
        idGlosModelIndex, idWindow.quizListView.currentItem.nNumber)
  return idGlosModelIndex.get(j)
}

function loadFromQuizList() {

  db = getAndInitDb()
  var o = quizFromCurrentItem()
  if (o === undefined)
    return

  if (glosModelIndex.count === 0) {
    return
  }

  db.transaction(function (tx) {
    tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?', [o.number])
  })

  sQuizName = o.quizname
  sLangLang = o.langpair
  nDbNumber = o.number
  sScoreText = o.state1
  sQuizDesc = o.desc1
  sQuizDate = o.descdate
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

    tx.executeSql('CREATE TABLE IF NOT EXISTS Glosa' + nDbNumber
                  + '( number INT , quizword TEXT, answer TEXT, state INT)')

    loadFromDb(tx, 0)
    loadQuiz()
  })

  idTextSelected.text = sQuizName
  idWindow.oTakeQuiz.bImageMode = false
  resetTakeQuizTab()
}

function newQuiz() {

  if (idLangModel.get(idLangList1.currentIndex).code === idLangModel.get(
        idLangList2.currentIndex).code) {
    idErrorDialog.text = "WordQuiz with same language " + idLangModel.get(
          idLangList2.currentIndex).lang + "!"
    idErrorDialog.visible = true
  }

  db.transaction(function (tx) {
    glosModel.clear()
    var rs = tx.executeSql('SELECT MAX(dbnumber) AS newnr FROM GlosaDbIndex')
    var nNr = 1
    if (rs.rows.length > 0) {
      nNr = rs.rows.item(0).newnr + 1
    }

    sQuizName = capitalizeStr(idTextInputQuizName.displayText)

    if (sQuizName.length < 3)
      sQuizName = "New Quiz " + sLangLangSelected

    tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',
                  [nNr, sQuizName, "0/0", sLangLangSelected])
    tx.executeSql('INSERT INTO GlosaDbDesc VALUES(?,?)', [nNr, "-"])

    idGlosModelIndex.append({
                              "number": nNr,
                              "quizname": sQuizName,
                              "state1": "0/0",
                              "langpair": sLangLangSelected,
                              "desc1": "-",
                              "descdate": MyDownloader.dateStr()
                            })

    idQuizList.positionViewAtEnd()

    idQuizList.currentIndex = MyDownloader.indexFromGlosNr(
          idWindow.glosModelIndex, nNr)
  })
}

function getExtra(sWordAndExtra) {
  if (sWordAndExtra === undefined)
    return ""
  if (sWordAndExtra === null)
    return ""

  var ocWord = sWordAndExtra.split("###")

  if (ocWord.length > 1)
    return ocWord[1]
  else
    return ""
}

function getWord(sWordAndExtra) {
  if (sWordAndExtra === undefined)
    return ""
  if (sWordAndExtra === null)
    return ""

  var ocWord = sWordAndExtra.split("###")

  return ocWord[0]
}

function getDesc(sDescAndDate) {
  if (sDescAndDate === undefined)
    return "-"

  var ocDesc = sDescAndDate.split("###")

  return ocDesc[0]
}

function getDate(sDescAndDate) {
  if (sDescAndDate === undefined)
    return "-"

  var ocDesc = sDescAndDate.split("###")

  if (ocDesc.length > 1)
    return ocDesc[1]
  else
    return "-"
}

function loadFromServerList(nCount, oDD) {
  var nLastSelected = idImport.nSelectedQ
  // var sLastSelectedQ = idImport.sSelectedQ
  idServerQModel.clear()
  idDownloadBtn.bProgVisible = false
  idImport.bIsDownloadingList = false
  idImport.state = "Back"

  if (nCount <= 0) {

    if (nCount === -1)
      idImport.nError = 1
    else
      idImport.nError = 2

    idImport.sDescDate = ""
    idImport.sDesc1 = ""
    idImport.sSelectedQ = ""
    return
  }

  idImport.nError = 0
  var nIndex = 0

  for (var i = 0; i < nCount; i += 5) {
    var sDescAndDate = oDD[i + 1]

    if (nLastSelected === oDD[i + 4]) {
      idImport.sDescDate = getDate(sDescAndDate)
      idImport.sDesc1 = getDesc(sDescAndDate)
      idImport.sSelectedQ = oDD[i]
    }

    nIndex++

    idServerQModel.append({
                            "qname": oDD[i],
                            "desc1": getDesc(sDescAndDate),
                            "code": oDD[i + 2],
                            "state1": oDD[i + 3],
                            "date1": getDate(sDescAndDate),
                            "number": parseInt(oDD[i + 4])
                          })
  }

  if (nLastSelected >= 0) {
    idImport.currentIndex = MyDownloader.indexFromGlosNr(oFilteredQListModel,
                                                         nLastSelected)
    idImport.positionViewAtIndex(idImport.currentIndex)
  } else {
    idImport.currentIndex = -1
    idImport.sDescDate = "-"
    idImport.sDesc1 = "-"
    idImport.sSelectedQ = "-"
  }
}

function quizDeleted(nResponce) {
  idImport.bIsDeleting = false

  if (nResponce >= 0) {
    var nCI = MyDownloader.indexFromGlosNr(idServerQModel, nResponce)
    idServerQModel.remove(nCI)
    idImport.nSelectedQ = -1
    idImport.sDesc1 = ""
    idImport.sDescDate = ""
    idImport.sSelectedQ = ""
    idImport.sImportMsg = ""
    idImport.currentIndex = -1
  } else {
    if (nResponce === -1)
      idImport.sImportMsg = "Wrong password"
    else
      idImport.sImportMsg = "Network Error deleting"
  }
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
    } else if (nResponce === 208) {
      idExportError.text = "Error in Quizdb"
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
    idImport.bIsDownloading = false
    idImport.sImportMsg = "error importing"
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
                  [nDbNumber, idImport.sDesc1 + "###" + idImport.sDescDate])

    tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',
                  [nDbNumber, sQuizName, sState1, sLangLoaded])

    idGlosModelIndex.append({
                              "number": nNr,
                              "quizname": sQuizName,
                              "state1": sState1,
                              "langpair": sLangLoaded,
                              "desc1": idImport.sDesc1,
                              "descdate": idImport.sDescDate
                            })


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

    idImport.bIsDownloading = false
    idImport.state = ""

    idQuizList.currentIndex = MyDownloader.indexFromGlosNr(glosModelIndex, nNr)
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

  assignQuizModelAll()
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

  assignQuizModelAll()
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
      sA = sA + "###" + sE
    }

    tx.executeSql(
          'UPDATE Glosa' + nDbNumber + ' SET quizword=?, answer=?, state=? WHERE number = ?',
          [sQ, sA, nState, nNumber])

    // Assign The updated values


    /*
    var nC = idQuizModel.count
    for (var i = 0; i < nC; ++i) {
      if (idQuizModel.get(i).numberDb === nNumber) {
        idQuizModel.get(i).extra = sE
        var sImgUrl = String(MyDownloader.imageSrc(sQ, sLangLang))
        console.log("update in 1_3 quiz nNumber " + nNumber)
        console.log(sImgUrl)
        console.log(idQuizModel.get(i).imgUrl)
        // Emmit changed
        //  if (sImgUrl !== sDEFAULT_IMG && idQuizModel.get(i).imgUrl === sImgUrl)
        idQuizModel.get(i).imgUrl = sDEFAULT_IMG

        // idQuizModel.get(i).imgUrl = sImgUrl
        if (bIsReverse) {
          idQuizModel.get(i).question = sA_Org
          idQuizModel.get(i).answer = sQ
        } else {
          idQuizModel.get(i).question = sQ
          idQuizModel.get(i).answer = sA_Org
        }
      }
    }
    */
  })

  var i = MyDownloader.indexFromGlosNr(glosModelWorking, nNumber)

  if (i >= 0) {

    if (nState !== 0) {
      // Done
      glosModelWorking.remove(i)
      if (glosModelWorking.count === 0)
        setAllok(true)
    } else {
      if (bIsReverse) {
        glosModelWorking.get(i).answer = sQ
        glosModelWorking.get(i).question = sA_Org
      } else {
        glosModelWorking.get(i).answer = sA_Org
        glosModelWorking.get(i).question = sQ
      }
      glosModelWorking.get(i).number = nNumber
      glosModelWorking.get(i).extra = sE

      checkAndReplace(nNumber, i)
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
        assignOneWorkingItem()
      } else if (glosModelWorking.count === 2) {
        assignTwoWorkingItems()
      }
      if (glosModelWorking.count === 3) {
        assignThreeUpdatedWorkingItem()
      }
    }
  }

  sScoreText = glosModelWorking.count + "/" + glosModel.count

  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).answer,
                          sToLang)
  MyDownloader.deleteWord(glosModel.get(idGlosList.currentIndex).question,
                          sFromLang)

  if (glosModel.get(idGlosList.currentIndex).question !== sQ || glosModel.get(
        idGlosList.currentIndex).answer !== sA_Org || glosModel.get(
        idGlosList.currentIndex).extra !== sE) {
    glosModel.get(idGlosList.currentIndex).question = sQ
    glosModel.get(idGlosList.currentIndex).answer = sA_Org
    glosModel.get(idGlosList.currentIndex).extra = sE
    updateDesc1()
  }

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

  assignQuizModelAll()

  sScoreText = glosModelWorking.count + "/" + glosModel.count
}

function updateDbWithWordState(nLastNumber) {

  db.transaction(function (tx) {
    tx.executeSql("UPDATE Glosa" + nDbNumber + " SET state=1 WHERE number=?",
                  nLastNumber)
  })
}

function checkAndReplace(nNumberDb, nReplaceWidthIndexInWorking) {
  for (var i = 0; i < 3; ++i) {
    if (idQuizModel.get(i).numberDb === nNumberDb) {
      assignQuizModel(nReplaceWidthIndexInWorking, i)
    }
  }
}

function assignOneWorkingItem() {
  for (var i = 0; i < 3; ++i) {
    idQuizModel.get(i).allOk1_3 = false
    assignQuizModel(0, i)
  }
  var nLeftItem = nQuizIndex1_3 - 1
  if (nLeftItem < 0)
    nLeftItem = 2

  idQuizModel.get(nLeftItem).allOk1_3 = true
}

function assignTwoWorkingItems() {
  var nNumber = idQuizModel.get(nQuizIndex1_3).numberDb
  // Get index in working set for the glosa not shown in QuizView (PathView)
  // assign that to all hidden items ( 2 items )
  // This shoul avoid user visible updates
  var ii = (MyDownloader.indexFromGlosNr(glosModelWorking, nNumber) + 1) % 2
  for (var i = 0; i < 3; ++i) {
    idQuizModel.get(i).allOk1_3 = false
    if (nQuizIndex1_3 === i)
      continue
    assignQuizModel(ii, i)
  }
}

function isInQuizModel(jIndexWorking) {
  var nNumber = glosModelWorking.get(jIndexWorking).number
  for (var i = 0; i < 3; ++i) {
    if (idQuizModel.get(i).numberDb === nNumber)
      return true
  }
  return false
}

function assignThreeUpdatedWorkingItem() {
  for (var i = 0; i < 3; ++i) {
    if (!isInQuizModel(i)) {
      for (var j = 0; j < 3; ++j)
        if (assignQuizModelUnique(i, j))
          break
    }
  }
}

function assignThreeWorkingItem() {
  if (idQuizModel.bDir > 0)
    return
  for (var i = 0; i < 3; ++i) {
    if (!isInQuizModel(i)) {
      assignQuizModel(i, nLastQuizIndex1_3)
      break
    }
  }
}

function assigNextQuizWord() {

  if (glosModelWorking.count === 0)
    return

  var nLastNumber = idQuizModel.get(nLastQuizIndex1_3).numberDb

  if (idQuizModel.bDir === -1) {
    var i = nLastQuizIndex1_3
    var ii = MyDownloader.indexFromGlosNr(glosModelWorking, nLastNumber)
    if (ii >= 0) {
      glosModelWorking.remove(ii)
    } else {
      console.log("not found in working model " + nLastNumber + " "
                  + glosModelWorking.count + " " + idQuizModel.get(i).question)
    }

    if (glosModelWorking.count === 0) {
      setAllok(true)
      idQuizModel.get(i).imgUrl = idWindow.sDEFAULT_IMG
      idQuizModel.get(i).answerVisible = false
      idQuizModel.get(i).answer = ""
      idQuizModel.get(i).question = ""
      idQuizModel.get(i).extra = ""
      idQuizModel.get(i).numberDb = -1
    }

    sScoreText = glosModelWorking.count + "/" + glosModel.count
    i = MyDownloader.indexFromGlosNr(glosModel, nLastNumber)
    if (i !== -1) {
      glosModel.get(i).state1 = 1
      updateDbWithWordState(nLastNumber)
    }
  }

  if (glosModelWorking.count === 0) {
    setAllok(true)
    resetTakeQuizTab()
    return
  }

  if (glosModelWorking.count > 3) {
    for (; ; ) {
      var nIndexNewWordInModelWorking = Math.floor(Math.random(
                                                     ) * glosModelWorking.count)
      var nNumberOfNewWord = glosModelWorking.get(
            nIndexNewWordInModelWorking).number
      var Found = 0

      for (i = 0; i < 3; ++i) {
        if (idQuizModel.get(i).numberDb === nNumberOfNewWord) {
          Found = 1
          break
        }
      }
      if (Found === 0)
        break
    }
    assignQuizModel(nIndexNewWordInModelWorking, nLastQuizIndex1_3)
  } else if (glosModelWorking.count === 3)
    assignThreeWorkingItem()
  else if (glosModelWorking.count === 2)
    assignTwoWorkingItems()
  else
    assignOneWorkingItem()

  idWindow.nGlosaTakeQuizIndex = MyDownloader.indexFromGlosNr(
        glosModel, idQuizModel.get(nQuizIndex1_3).numberDb)

  if (bTextMode)
    MyDownloader.focusOnQuizText(nQuizIndex1_3)

  resetTakeQuizTab()
}

function calcSwipeDirection(currentIndex) {
  var nI = (currentIndex + 1) % 3

  idQuizModel.get(nI).answerVisible = false
  //nQuizIndex the index of the view with 3 items that swipes left or right
  nLastQuizIndex1_3 = nQuizIndex1_3
  nQuizIndex1_3 = nI

  if (glosModelWorking.count === 0) {
    return
  }

  var nLastIndex = nLastQuizIndex1_3
  if (nLastIndex === 0 && nI === 1)
    idQuizModel.bDir = 1
  if (nLastIndex === 0 && nI === 2)
    idQuizModel.bDir = -1
  if (nLastIndex === 1 && nI === 0)
    idQuizModel.bDir = -1
  if (nLastIndex === 1 && nI === 2)
    idQuizModel.bDir = 1
  if (nLastIndex === 2 && nI === 0)
    idQuizModel.bDir = 1
  if (nLastIndex === 2 && nI === 1)
    idQuizModel.bDir = -1
}
