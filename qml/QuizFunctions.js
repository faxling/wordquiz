function hangUpdateImage()
{
  const n = idLangModel.count
  let sL = bIsReverseHang ? sToLang : sFromLang
  for (let i = 0 ; i < n ; ++i)
  {
    if (idLangModel.get(i).code === sL)
    {
      idFlagImg.source = idLangModel.get(i).imgsource
      break;
    }
  }
}

function hangClearThings()
{
  idHangBtn3.bAV = false
  idGameOver.visible = false
  idGameOverTimer.stop()
  idOrdRow.children = []
  idOrdCol.children = []
  idOrdCol2.children = []
  idOrdCol3.children = []
  idTTrans.visible = false
  idCharRect.text = ""
}

function hangNewQ()
{
  bIsReverseHang = false
  hangClearThings()
  idDrawing.renderId(1)
  hangUpdateImage()
  idHangBtn.visible = true
}

function hangAddWord()
{
  hangClearThings()
  let n = 0
  let i = 0
  let nIndexOfNewWord = 0
  for ( i = 0 ; i < 10; ++i)
  {
    nIndexOfNewWord = Math.floor(MyDownloader.rand() * glosModel.count)

    if (bIsReverseHang)
    {
      sHangWord = glosModel.get(nIndexOfNewWord).answer
      idTTrans.text = glosModel.get(nIndexOfNewWord).question
    }
    else
    {
      sHangWord = glosModel.get(nIndexOfNewWord).question
      idTTrans.text = glosModel.get(nIndexOfNewWord).answer
    }

    sHangWord = sHangWord.toUpperCase()
    n = sHangWord.length
    if (n < 14)
      break
  }

  if (i === 10)
  {
    idErrorDialogHangMan.text = "Create or Select a Word Quiz that contains short words!"
    idErrorDialogHangMan.visible = true
    return;
  }

  sCurrentRow = []

  for (i = 0; i < n; ++i)
  {
    const ch = sHangWord[i]

    if (MyDownloader.isSpecial(ch))
    {
      sCurrentRow.push((ch))
      idChar.createObject(idOrdRow, {text : ch , bIsSpecial:true })
    }
    else
    {
      sCurrentRow.push(" ")
      idChar.createObject(idOrdRow)
    }
  }
  idWindow.nGlosaTakeQuizIndex = nIndexOfNewWord;

}

function hangCheckCharInColumn(sChar, oColumn)
{
  let n = oColumn.children.length
  let i
  for ( i = 0; i < n; ++i)
  {
    if (MyDownloader.ignoreAccent(oColumn.children[i].text) === MyDownloader.ignoreAccent(sChar))
      return true
  }
  return false
}

function hangCheckChar(sChar)
{
  if (hangCheckCharInColumn(sChar, idOrdCol))
    return true

  if (hangCheckCharInColumn(sChar, idOrdCol2))
    return true

  if (hangCheckCharInColumn(sChar, idOrdCol3))
    return true

  return false
}

function hangEnterChar()
{
  Qt.inputMethod.hide()
  let n = sHangWord.length
  let nValidCount = 0
  let nOKCount = 0
  let nC = 0
  var i = 0
  for (i = 0; i < n; ++i)
  {
    if (idOrdRow.children[i].bIsSpecial)
      continue

    ++nValidCount

    if (MyDownloader.ignoreAccent(sHangWord[i]) === MyDownloader.ignoreAccent(idCharRect.text[0]))
    {
      nC+=1
      idOrdRow.children[i].text = sHangWord[i]
      sCurrentRow[i] = sHangWord[i]
    }

    if (idOrdRow.children[i].text !== "")
      nOKCount += 1
  }

  if (nOKCount === nValidCount)
  {
    idDrawing.renderId(0)
    return
  }

  if (nC === 0)
  {
    let n = idOrdCol.children.length
    let hRet = hangCheckChar(idCharRect.text)
    if (hRet)
      return
    if (n === 1)
    {
      nUsedCharColLen = idHangMan.height / (idOrdCol.children[0].width * 1.8)
    }

    if (n < nUsedCharColLen)
      idChar.createObject(idOrdCol, {text: idCharRect.text})
    else if (n < nUsedCharColLen*2)
      idChar.createObject(idOrdCol2, {text: idCharRect.text})
    else
      idChar.createObject(idOrdCol3, {text: idCharRect.text})

    let bRet = idDrawing.renderId(2)

    if (!bRet)
    {
      idGameOver.visible = true
      idGameOverTimer.start()
    }
  }
}

function hangShowAnswer(bAV)
{
  let n = idOrdRow.children.length
  if (bAV)
  {
    for (let j = 0; j < n; ++j)
    {
      idOrdRow.children[j].text = sHangWord[j]
    }
  }
  else
  {
    for (let i = 0; i < n; ++i)
    {
      if (sCurrentRow[i] !== " ")
        idOrdRow.children[i].text =  sCurrentRow[i]
      else
        idOrdRow.children[i].text = ""
    }

  }
}


function connectMyDownloader()
{
  MyDownloader.exportedSignal.connect(QuizLib.quizExported)
  MyDownloader.quizDownloadedSignal.connect(QuizLib.loadFromList)
  MyDownloader.quizListDownloadedSignal.connect(
        QuizLib.loadFromServerList)
  MyDownloader.deletedSignal.connect(QuizLib.quizDeleted)
  idWindow.quizListView = idQuizList
}

String.prototype.equalIgnoreCase = function(str) {
  return this.toUpperCase() === str.toUpperCase();
}

Array.prototype.indexOfObject = function arrayObjectIndexOf(property, value) {
  for (var i = 0, len = this.length; i < len; i++) {
    if (this[i][property] === value)
      return i
  }
  return -1
}

function sortModel() {
  db.readTransaction(function (tx) {
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
  var oInText =  capitalizeStr(oTextInput.displayText)
  if (oInText.length < 1) {
    idErrorText.visible = true
    idErrorText.text = "No input to lookup in dictionary"
    return ""
  }
  return oInText
}


function reqTranslation(oBtnIn, bIsSecond)
{
  var oInText
  var sUrl
  if (bIsSecond)
  {
    nLastSearch = 1
    oInText = getTextFromInput(idTextInput2)
    sUrl =  sReqUrlRev + oInText
  }
  else
  {
    nLastSearch = 0
    oInText = getTextFromInput(idTextInput)
    sUrl =  sReqUrl + oInText
  }

  if (oInText === "")
    return

  oBtnIn.bProgVisible = true

  if (bIsSecond)
  {
    MyDownloader.translateWord(oInText,idWindow.sToLang,idWindow.sFromLang, oBtnIn)
    if (bHasDictFrom)
      downloadDictOnWord(sReqDictUrlRev, oInText)
  }
  else
  {
    MyDownloader.translateWord(oInText,idWindow.sFromLang,idWindow.sToLang, oBtnIn)
    if (bHasDictTo)
      downloadDictOnWord(sReqDictUrl, oInText)
  }
}

function lookUppInWiki()
{
  var oInText

  var sLang = bDoLookUppText1 ? sFromLang : sToLang

  if (bDoLookUppText1)
    oInText = getTextFromInput(idTextInput)
  else
    oInText = getTextFromInput(idTextInput2)

  if (oInText === "")
    return

  Qt.openUrlExternally("http://"+sLang+ ".wiktionary.org/w/index.php?title=" +oInText.toLowerCase() )

}

function updateDesc1(sDesc) {

  var nCurIndexInQList = idWindow.quizListView.currentIndex

  var nDbId = glosModelIndex.get(nCurIndexInQList).number

  glosModelIndex.get(nCurIndexInQList).desc1 = sDesc

  idWindow.sQuizDesc = sDesc

  var sDateStr = MyDownloader.dateStr()
  var sDescAndDate = sDesc + "###" +sDateStr
  glosModelIndex.get(nCurIndexInQList).descdate = sDateStr
  idWindow.sQuizDate = glosModelIndex.get(nCurIndexInQList).descdate

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
    if (sNewWordFrom.equalIgnoreCase(glosModel.get(i).question) && sNewWordTo.equalIgnoreCase(glosModel.get(
                                                                                                i).answer) ){
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
    var ocRet = new Array(nRowLen);
    MyDownloader.sortRowset(rs.rows.item, rs.rows, nRowLen, ocRet)

    for (var j = 0; j < nRowLen; j++) {
      i = ocRet[j]
      var nDbnumber = rs.rows.item(i).dbnumber
      var nN = oc.indexOfObject("dbnumber", nDbnumber)
      var vDescDate

      if (nN >= 0) {
        vDescDate = oc[nN].desc1
      }

      glosModelIndex.append({
                              "number": nDbnumber,
                              "quizname": capitalizeStr(rs.rows.item(
                                                          i).quizname),
                              "state1": rs.rows.item(i).state1,
                              "langpair": rs.rows.item(i).langpair,
                              "desc1": getDesc(vDescDate),
                              "descdate":getDate(vDescDate)
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
  text = text.trim()
  if (nLastSearch !== 1)
    idTextInput2.text = text + " "
  else
    idTextInput.text = text + " "
}

function setAllok(bval) {
  idWindow.bAllok = bval
}


// Updates the description of the Quiz
function insertGlosa(dbnumber, nC, question, answer) {
  var sQ = capitalizeStr(question)
  var sA = capitalizeStr(answer)

  db.transaction(function (tx) {
    tx.executeSql('INSERT INTO Glosa' + dbnumber + ' VALUES(?, ?, ?, ?)',
                  [nC, sQ, sA, 0])
  })

  glosModel.insert(0,{
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

  // idWindow.glosListView.positionViewAtBeginning()
  idWindow.glosListView.currentIndex = 0
  sScoreText = glosModelWorking.count + "/" + glosModel.count

  setAllok(false)

  if (glosModelWorking.count === 1) {
    idQuizModel.question = sQ
    idQuizModel.answer = sA
    idQuizModel.number = nC
    idQuizModel.extra = ""
  }

  updateDesc1(idWindow.sQuizDesc)

}

function assignQuizModel(nIndexOfNewWord) {
  var sNumberNewWord = glosModelWorking.get(nIndexOfNewWord).number
  idQuizModel.question = glosModelWorking.get(nIndexOfNewWord).question
  idQuizModel.answer = glosModelWorking.get(nIndexOfNewWord).answer
  idQuizModel.number = sNumberNewWord
  idQuizModel.extra = glosModelWorking.get(nIndexOfNewWord).extra
  idWindow.nGlosaTakeQuizIndex = MyDownloader.indexFromGlosNr(glosModel,
                                                              sNumberNewWord)

  // idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(glosModel, sNumberNewWord)
}

function loadQuiz() {
  glosModelWorking.clear()
  setAllok(false)
  bIsReverse = false

  if (glosModel.count < 1) {
    idQuizModel.question = "-"
    idQuizModel.answer = "-"
    idQuizModel.number = 0
    idQuizModel.extra = "-"
    return
  }

  var nC = glosModel.count

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
    assignQuizModel(nIndexOwNewWord)
  }
}

function capitalizeStr(inStr) {
  if (inStr === null)
    return ""
  if (inStr.length === 0)
    return ""
  var sA = inStr.trim().toLowerCase()
  sA =  sA.charAt(0).toUpperCase() + sA.slice(1)
  return sA
}

function loadFromDb(tx) {

  // To select the right highlighted word at quiz load time
  var nCurrentNumber = -1
  var oGlosaItem = glosModel.get(idWindow.glosListView.currentIndex)
  if (oGlosaItem !== undefined) {
    nCurrentNumber = oGlosaItem.number
  }

  glosModel.clear()

  var rs = tx.executeSql(
        "SELECT * FROM Glosa" + nDbNumber + " ORDER BY " + sQSort)

  var hasNonInt = false
  for (var i = 0; i < rs.rows.length; i++) {

    var sWordAndExtra  = rs.rows.item(i).answer
    var sA  = capitalizeStr(getWord(sWordAndExtra))
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

  // Select hilight after eg sort
  if (nCurrentNumber > 0) {
    idWindow.glosListView.currentIndex = MyDownloader.indexFromGlosNr(
          glosModel, nCurrentNumber)
    idWindow.nGlosaTakeQuizIndex = idWindow.glosListView.currentIndex
    idWindow.glosListView.positionViewAtIndex(idWindow.nGlosaTakeQuizIndex,
                                              ListView.Center)
  }
}


function renameQuiz(sQuizName)
{

  sQuizName = capitalizeStr(sQuizName)

  if (sQuizName.length < 4)
  {
    idErrorDialog.text = "'" +idTextInputQuizName.displayText + "'" + " To short Quiz name"
    idErrorDialog.visible = true
    return;
  }

  idWindow.sQuizName = sQuizName

  glosModelIndex.setProperty(idQuizList.currentIndex,"quizname",sQuizName)

  db.transaction(
        function(tx) {
          var nId = glosModelIndex.get(idQuizList.currentIndex).number;
          tx.executeSql('UPDATE GlosaDbIndex SET quizname=? WHERE dbnumber=?',[sQuizName, nId]);
          idTextSelected.text = sQuizName
        }
        )


}

function loadFromQuizList() {

  db = getAndInitDb()

  db.transaction(function (tx) {
    tx.executeSql('UPDATE GlosaDbLastIndex SET dbindex=?',
                  [idQuizList.currentIndex])
  })

  if (glosModelIndex.count === 0)
  {
    return
  }

  sQuizName = glosModelIndex.get(idQuizList.currentIndex).quizname
  sLangLang = glosModelIndex.get(idQuizList.currentIndex).langpair
  nDbNumber = glosModelIndex.get(idQuizList.currentIndex).number
  sScoreText = glosModelIndex.get(idQuizList.currentIndex).state1
  idWindow.sQuizDesc = glosModelIndex.get(idQuizList.currentIndex).desc1
  idWindow.sQuizDate = glosModelIndex.get(idQuizList.currentIndex).descdate
  idTextInputQuizDesc.text = idWindow.sQuizDesc
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

  if (idLangModel.get(idLangList1.currentIndex).code === idLangModel.get(idLangList2.currentIndex).code)
  {
    idErrorDialog.text = "A WordQuiz should be of different languages e.g en-ru"
    idErrorDialog.visible = true
    return;
  }

  db.transaction(function (tx) {
    glosModel.clear()
    var rs = tx.executeSql('SELECT MAX(dbnumber) as newnr FROM GlosaDbIndex')
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

    glosModelIndex.append( {
                            "number": nNr,
                            "quizname": sQuizName,
                            "state1": "0/0",
                            "langpair": sLangLangSelected,
                            "desc1": "-",
                            "descdate":MyDownloader.dateStr()
                          })

    idQuizList.positionViewAtEnd()
    idQuizList.currentIndex = glosModelIndex.count - 1
    if (idQuizList.currentIndex === 0)
      idWindow.quizListView.currentIndexChanged()
  })
}

function getExtra(sWordAndExtra)
{
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


function getWord(sWordAndExtra)
{
  if (sWordAndExtra === undefined)
    return ""
  if (sWordAndExtra === null)
    return ""

  var ocWord = sWordAndExtra.split("###")

  return ocWord[0]
}


function getDesc(sDescAndDate)
{
  if (sDescAndDate === undefined)
    return "-"

  var ocDesc = sDescAndDate.split("###")

  return ocDesc[0]
}


function getDate(sDescAndDate)
{
  if (sDescAndDate === undefined)
    return "-"

  var ocDesc = sDescAndDate.split("###")

  if (ocDesc.length > 1)
    return ocDesc[1]
  else
    return "-"
}

function loadFromServerList(nCount, oDD) {
  var nLastSelected = -1
  var sLastSelectedQ =  idImport.sSelectedQ
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

  for (var i = 0; i < nCount; i += 4) {
    var sDescAndDate = oDD[i + 1]

    if (sLastSelectedQ === oDD[i]) {
      idImport.sDescDate = getDate(sDescAndDate)
      idImport.sDesc1 = getDesc(sDescAndDate)
      idImport.sSelectedQ = oDD[i]
      nLastSelected = nIndex
    }

    nIndex++

    idServerQModel.append({
                            "qname": oDD[i],
                            "desc1": getDesc(sDescAndDate),
                            "code": oDD[i + 2],
                            "state1": oDD[i + 3],
                            "date1": getDate(sDescAndDate)
                          })
  }

  if (nLastSelected >= 0)
  {
    idImport.currentIndex = nLastSelected
    idImport.positionViewAtIndex(nLastSelected)
  }
  else
  {
    idImport.currentIndex = -1
    idImport.sDescDate = "-"
    idImport.sDesc1 = "-"
    idImport.sSelectedQ = "-"
  }


}

function quizDeleted(nResponce) {
  idImport.bIsDeleting = false

  if (nResponce >= 0) {
    idImport.sDesc1 = ""
    idImport.sDescDate = ""
    idServerQModel.remove(nResponce)
    if (nResponce > 0) {
      idImport.currentIndex = nResponce - 1
      idImport.sDesc1 = idServerQModel.get(nResponce - 1).desc1
      idImport.sSelectedQ = idServerQModel.get(nResponce - 1).qname
      idImport.sImportMsg = ""
    }
  } else
  {
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
    }
    else if (nResponce === 208) {
      idExportError.text = "Error in Quizdb"
      idExportError.visible = true
    }
    else if (nResponce === 200) {
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
                  [nDbNumber, idImport.sDesc1 +"###" + idImport.sDescDate])

    tx.executeSql('INSERT INTO GlosaDbIndex VALUES(?,?,?,?)',
                  [nDbNumber, sQuizName, sState1, sLangLoaded])

    glosModelIndex.append({
                            "number": nNr,
                            "quizname": sQuizName,
                            "state1": sState1,
                            "langpair": sLangLoaded,
                            "desc1": idImport.sDesc1,
                            "descdate":idImport.sDescDate
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

    idImport.bIsDownloading = false
    idImport.state = ""

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
      sA = sA + "###" + sE
    }

    tx.executeSql(
          'UPDATE Glosa' + nDbNumber + ' SET quizword=?, answer=?, state=? WHERE number = ?',
          [sQ, sA, nState, nNumber])

    // Assign The updated values
    if (idQuizModel.number === nNumber) {
      idQuizModel.extra = sE
      if ( bIsReverse )
      {
        idQuizModel.question = sA_Org
        idQuizModel.answer = sQ
      }
      else
      {
        idQuizModel.question = sQ
        idQuizModel.answer = sA_Org
      }
    }
  })

  var i = MyDownloader.indexFromGlosNr(glosModelWorking, nNumber)

  if (i >= 0) {
    if (nState !== 0) {
      glosModelWorking.remove(i)
      if ( glosModelWorking.count === 0)
        setAllok(true)
    }
    else
    {
      if ( bIsReverse )
      {
        glosModelWorking.get(i).answer = sQ
        glosModelWorking.get(i).question = sA_Org
      }
      else
      {
        glosModelWorking.get(i).answer = sA_Org
        glosModelWorking.get(i).question = sQ
      }
      glosModelWorking.get(i).number = nNumber
      glosModelWorking.get(i).extra = sE
    }
  }
  else
  {
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

  if (glosModel.get(idGlosList.currentIndex).question !== sQ
      || glosModel.get(idGlosList.currentIndex).answer !== sA_Org
      || glosModel.get(idGlosList.currentIndex).extra !== sE)
  {
    glosModel.get(idGlosList.currentIndex).question = sQ
    glosModel.get(idGlosList.currentIndex).answer = sA_Org
    glosModel.get(idGlosList.currentIndex).extra = sE
    updateDesc1(idWindow.sQuizDesc)
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

function getFunctionU(nLastNumber, oTimer)
{

  return function updateDbWithWordState() {

    db.transaction(function (tx) {
      tx.executeSql("UPDATE Glosa" + nDbNumber + " SET state=1 WHERE number=?",
                    nLastNumber)
    })

    oTimer.stop();
    oTimer.destroy();

  }
}

function Timer() {
  return Qt.createQmlObject("import QtQuick 2.0; Timer {}", idWindow)
}

function calcAndAssigNextQuizWord(currentIndex) {
  var nI = (currentIndex + 1) % 3
  var nLastIndex = idView.nLastIndex

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

  var nLastNumber = idQuizModel.number

  idView.nLastIndex = nI

  if (bDir === -1) {
    var i = MyDownloader.indexFromGlosNr(glosModelWorking, nLastNumber)

    glosModelWorking.remove(i)

    if (glosModelWorking.count === 0) {
      setAllok(true)
      idQuizModel.answer = ""
      idQuizModel.extra = ""
    }

    sScoreText = glosModelWorking.count + "/" + glosModel.count

    i = MyDownloader.indexFromGlosNr(glosModel, nLastNumber)

    if (i !== -1) {
      glosModel.get(i).state1 = 1
      var oTimer = new Timer()
      oTimer.interval = 1000
      oTimer.repeat = false
      oTimer.triggered.connect(getFunctionU(nLastNumber, oTimer))
      oTimer.start()
    }
  }

  MyDownloader.storeCurrentIndex(nI)

  if (glosModelWorking.count > 0) {

    while (glosModelWorking.count > 1) {
      var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count)
      if (glosModelWorking.get(nIndexOwNewWord).number !== nLastNumber)
        break
    }

    if (glosModelWorking.count === 1) {
      assignQuizModel(0, nQuizIndex)
    } else
      assignQuizModel(nIndexOwNewWord, nQuizIndex)
  }

  resetTakeQuizTab()
}
