// Holds the type of the lastpopup
var g_eLastSquareType


// idInputBox
// idCrossWordGrid
function handleCharInput(text) {

  // 0 Horizontal 1 = Verical
  let eDirection = 0

  if (g_eLastSquareType === CrossWord.SquareType.QuestionV)
    eDirection = 1

  text = text.replace(/ /g, "").toUpperCase()
  const nInTextLen = text.length

  let nNI = idInputBox.parent.nIndex
  if (nInTextLen === 0) {
    let oCursorSq = idCrossWordGrid.children[nNI]
    oCursorSq.text = ""
    idInputBox.visible = false
    return
  }

  for (var i = 0; i < nInTextLen; ++i) {
    // If First init direction
    if (i === 0) {
      // Last question was a vertical check that we can go this way
      if (eDirection === 1) {
        let oDownSq = idCrossWordGrid.children[nNI + CrossWordQ.nW]
        if (!isChar(oDownSq))
          eDirection = 0
      }

      let oRightSq = idCrossWordGrid.children[nNI + 1]
      // Check if on right bound
      if ((nNI % CrossWordQ.nW) === (CrossWordQ.nW - 1))
        eDirection = 1
      else if (!isChar(oRightSq))
        eDirection = 1
    }

    let oCursorSq = idCrossWordGrid.children[nNI]
    let chIn = text.charAt(i)

    if (MyDownloader.ignoreAccent(chIn) === MyDownloader.ignoreAccent(
          oCursorSq.textA)) {
      oCursorSq.text = oCursorSq.textA
      oCursorSq.eSquareType = CrossWord.SquareType.Done
    } else {
      oCursorSq.text = chIn
      oCursorSq.eSquareType = CrossWord.SquareType.Char
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

    if (oCursorSq.eSquareType === CrossWord.SquareType.Space) {
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
  let bDone = true
  for (const j in idCrossWordGrid.children) {
    if (idCrossWordGrid.children[j].eSquareType === CrossWord.SquareType.Char) {
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

  if (oCh.eSquareType === CrossWord.SquareType.Char
      || oCh.eSquareType === CrossWord.SquareType.Done)
    return true
  return false
}

function isQ(eSquareType) {
  return (eSquareType === CrossWord.SquareType.Question
          || eSquareType === CrossWord.SquareType.QuestionH
          || eSquareType === CrossWord.SquareType.QuestionV)
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

    const ocQuestions = textBox.text.split("\n\n")
    g_eLastSquareType = charRect.eSquareType
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
    idInputBox.parent = charRect
    idInputBox.visible = true
    idInputBox.t.forceActiveFocus()
  } else {
    Qt.inputMethod.hide()
  }
}

// Callback function used for passing the a result crossword question
// idCrossWordGrid
function addQ(nIndex, nHorizontal, nVertical) {
  const o = idCrossWordGrid.children[nIndex]

  let nQTypeNum = 0

  if (nHorizontal !== -1)
    nQTypeNum += 1
  if (nVertical !== -1)
    nQTypeNum += 2

  switch (nQTypeNum) {
  case 1:
    o.text = glosModel.get(nHorizontal).question
    o.eSquareType = CrossWord.SquareType.QuestionH
    break
  case 2:
    o.text = glosModel.get(nVertical).question
    o.eSquareType = CrossWord.SquareType.QuestionV
    break
  case 3:
    o.text = glosModel.get(nHorizontal).question + "\n\n"
    o.text += glosModel.get(nVertical).question
    o.eSquareType = CrossWord.SquareType.Question
    let oDoubleQuestion = idDline.createObject(o)
    oDoubleQuestion.textV = glosModel.get(nVertical).question
    oDoubleQuestion.textH = glosModel.get(nHorizontal).question
  }
}

function isNotLetter(c) {
  return c.toLowerCase() === c.toUpperCase()
}

// Callback function used for passing the a result crossword char
function addCh(nIndex, vVal) {
  const o = idCrossWordGrid.children[nIndex]
  if (isNotLetter(vVal)) {
    o.eSquareType = CrossWord.SquareType.Space
    o.text = vVal
  } else {
    o.eSquareType = CrossWord.SquareType.Char
    o.textA = vVal
  }
}

// idCWCharComponent
function createGrid() {

  QuizLib.destroyChildren(idCrossWordGrid)

  idCrossWordGrid.columns = CrossWordQ.nW

  // Last low must contain just *
  let nCount = CrossWordQ.nW * (CrossWordQ.nH - 1)

  for (var i = 0; i < nCount; ++i) {
    let o = idCWCharComponent.createObject(idCrossWordGrid)
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
