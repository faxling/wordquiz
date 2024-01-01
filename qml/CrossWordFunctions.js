// Holds the type of the lastpopup
var g_eLastSquareType
var g_nLastSquareIndex

// idInputBox
// idCrossWordGrid
function handleCharInput(text) {

  // 0 Horizontal 1 = Verical
  var eDirection = 0

  if (g_eLastSquareType === idCrossWordItem.cQuestionV)
    eDirection = 1
  var nNI = idInputBox.nIndex

  if (g_eLastSquareType === idCrossWordItem.cQuestion
      && (nNI >= (g_nLastSquareIndex + CrossWordQ.nW)))
    eDirection = 1

  text = text.replace(/ /g, "").toUpperCase()
  var nInTextLen = text.length
  var oCursorSq

  if (nInTextLen === 0) {
    oCursorSq = idCrossWordGrid.children[nNI]
    oCursorSq.text = ""
    oCursorSq.eSquareType = idCrossWordItem.cChar
    idInputBox.visible = false
    return
  }

  for (var i = 0; i < nInTextLen; ++i) {
    // If First init direction
    if (i === 0) {
      // Last question was a vertical check that we can go this way
      if (eDirection === 1) {
        var oDownSq = idCrossWordGrid.children[nNI + CrossWordQ.nW]
        if (!isChar(oDownSq))
          eDirection = 0
      }

      var oRightSq = idCrossWordGrid.children[nNI + 1]
      // Check if on right bound
      if ((nNI % CrossWordQ.nW) === (CrossWordQ.nW - 1))
        eDirection = 1
      else if (!isChar(oRightSq))
        eDirection = 1
    }

    oCursorSq = idCrossWordGrid.children[nNI]
    var chIn = text.charAt(i)

    if (MyDownloader.ignoreAccent(chIn) === MyDownloader.ignoreAccent(
          oCursorSq.textA)) {
      oCursorSq.text = oCursorSq.textA
      oCursorSq.eSquareType = idCrossWordItem.cDone
    } else {
      oCursorSq.text = chIn
      oCursorSq.eSquareType = idCrossWordItem.cChar
    }

    if (eDirection === 0) {
      nNI++
      if ((nNI % CrossWordQ.nW) === 0)
        break
    } else {
      nNI += CrossWordQ.nW
      if (nNI >= (CrossWordQ.nW * (CrossWordQ.nH - 1)))
        break
    }

    oCursorSq = idCrossWordGrid.children[nNI]

    while (oCursorSq.eSquareType === idCrossWordItem.cSpace) {
      if (eDirection === 0)
        nNI++
      else
        nNI = nNI + CrossWordQ.nW

      oCursorSq = idCrossWordGrid.children[nNI]
    }

    if (!isChar(oCursorSq))
      break
  }

  idInputBox.visible = false

  // Check if the crossword is completed show success message if so
  var bDone = true
  for (var j in idCrossWordGrid.children) {
    if (idCrossWordGrid.children[j].eSquareType === idCrossWordItem.cChar) {
      bDone = false
      break
    }
  }
  if (bDone)
    idCrossResultMsg.visible = true
}

function isChar(oCh) {
  if (oCh === undefined)
    return false

  if (oCh.eSquareType === idCrossWordItem.cChar
      || oCh.eSquareType === idCrossWordItem.cDone)
    return true
  return false
}

function isQ(eSquareType) {
  return (eSquareType === idCrossWordItem.cQuestion
          || eSquareType === idCrossWordItem.cQuestionH
          || eSquareType === idCrossWordItem.cQuestionV)
}

// idInfoBox
function popupOnPressJolla(charRect, textBox) {
  if (isQ(charRect.eSquareType)) {
    idInputBox.visible = false
    var oP = idCrossWordGrid.mapToItem(idCrossWord, charRect.x, charRect.y)
    idInfoBox.visible = true
    idInfoBox.y = oP.y - charRect.height
    idInfoBox.x = oP.x + charRect.width
    var sLine
    var ocQuestions = textBox.text.split("\n\n")
    g_eLastSquareType = charRect.eSquareType
    g_nLastSquareIndex = idInputBox.nIndex
    var nLineCount = 1
    if (ocQuestions.length > 1) {
      nLineCount = 3
      if (ocQuestions[0].length > ocQuestions[1].length)
        sLine = ocQuestions[0]
      else
        sLine = ocQuestions[1]
    } else
      sLine = ocQuestions[0]

    var oBR = fontMetrics.boundingRect(sLine + "X")
    idInfoBox.height = oBR.height * nLineCount
    idInfoBox.width = oBR.width
    idInfoBox.t.text = textBox.text
  } else if (CWLib.isChar(charRect)) {
    idInfoBox.visible = false
    idInputBox.t.text = charRect.text
    oP = idCrossWordGrid.mapToItem(idCrossWord, charRect.x, charRect.y)
    idInputBox.y = oP.y
    idInputBox.x = oP.x
    idInputBox.nIndex = charRect.nIndex
    idInputBox.visible = true
    idInputBox.t.forceActiveFocus()
    Qt.inputMethod.show()
  } else {
    idInputBox.visible = false
    idInfoBox.visible = false
    Qt.inputMethod.hide()
  }
}

// idInfoBox
function popupOnPress(charRect, textBox, fontMetrics) {
  if (isQ(charRect.eSquareType)) {
    if (idInfoBox.visible === true && idInfoBox.parent === charRect) {
      idInfoBox.visible = false
      return
    }

    idInfoBox.parent = charRect
    idInfoBox.show(textBox.text)

    var ocQuestions = textBox.text.split("\n\n")
    g_eLastSquareType = charRect.eSquareType
    g_nLastSquareIndex = idInputBox.nIndex
    if (ocQuestions.length > 1) {
      if (ocQuestions[0].length > ocQuestions[1].length)
        fontMetrics.text = ocQuestions[0]
      else
        fontMetrics.text = ocQuestions[1]
    } else
      fontMetrics.text = textBox.text

    fontMetrics.text += "X"

    idInfoBox.width = fontMetrics.width
  } else if (CWLib.isChar(charRect)) {
    idInfoBox.hide()
    idInputBox.t.text = charRect.text
    idInputBox.nIndex = charRect.nIndex
    idInputBox.visible = true
    idInputBox.parent = charRect
    idInputBox.t.forceActiveFocus()
  } else {
    Qt.inputMethod.hide()
  }
}

// Callback function used for passing the a result crossword question
// idCrossWordGrid
function addQ(nIndex, nHorizontal, nVertical) {
  var o = idCrossWordGrid.children[nIndex]

  var nQTypeNum = 0

  if (nHorizontal !== -1)
    nQTypeNum += 1
  if (nVertical !== -1)
    nQTypeNum += 2

  switch (nQTypeNum) {
  case 1:
    o.text = glosModel.get(nHorizontal).question
    o.eSquareType = idCrossWordItem.cQuestionH
    break
  case 2:
    o.text = glosModel.get(nVertical).question
    o.eSquareType = idCrossWordItem.cQuestionV
    break
  case 3:
    o.text = glosModel.get(nHorizontal).question + "\n\n"
    o.text += glosModel.get(nVertical).question
    o.eSquareType = idCrossWordItem.cQuestion
    var oDoubleQuestion = idDline.createObject(o)
    oDoubleQuestion.textV = glosModel.get(nVertical).question
    oDoubleQuestion.textH = glosModel.get(nHorizontal).question
  }
}

function isNotLetter(c) {
  return c.toLowerCase() === c.toUpperCase()
}

// Callback function used for passing the a result crossword char
function addCh(nIndex, vVal) {
  var o = idCrossWordGrid.children[nIndex]
  if (isNotLetter(vVal)) {
    o.eSquareType = idCrossWordItem.cSpace
    o.text = vVal
  } else {
    o.eSquareType = idCrossWordItem.cChar
    o.textA = vVal
  }
}

// idCWCharComponent
function createGrid() {

  QuizLib.destroyChildren(idCrossWordGrid)

  idCrossWordGrid.columns = CrossWordQ.nW

  // Last low must contain just *
  var nCount = CrossWordQ.nW * (CrossWordQ.nH - 1)

  for (var i = 0; i < nCount; ++i) {
    var o = idCWCharComponent.createObject(idCrossWordGrid)
    o.nIndex = i
  }
}

// idErrMsg
// idWindow
function isPreReqOk() {
  if (idWindow.bCWBusy)
    return false
  if (glosModel.count <= 6) {
    idErrMsg.visible = true
    return false
  }
  idErrMsg.visible = false
  idWindow.bCWBusy = true
  return true
}

// idWindow
// idTab5
// idCrossResultMsg
function loadCW() {
  if (idWindow.nDbNumber === idTab5.nLastCrossDbId)
    return

  idTab5.nLastCrossDbId = idWindow.nDbNumber
  if (!isPreReqOk())
    return

  idCrossResultMsg.visible = false

  CrossWordQ.createCrossWordFromList(glosModel)
  CrossWordQ.sluggOneWord()

  createGrid()

  CrossWordQ.assignQuestionSquares(addQ)
  CrossWordQ.assignCharSquares(addCh)

  idWindow.bCWBusy = false
}

// idCrossResultMsg
// idWindow
function sluggCW() {
  if (!isPreReqOk())
    return

  idCrossResultMsg.visible = false

  CrossWordQ.createCrossWordFromList(glosModel)

  for (; ; ) {
    if (!CrossWordQ.sluggOneWord())
      break
    createGrid()
    CrossWordQ.assignQuestionSquares(addQ)
    CrossWordQ.assignCharSquares(addCh)
  }
  idWindow.bCWBusy = false
}
