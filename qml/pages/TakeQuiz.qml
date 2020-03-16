import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id:idRectTakeQuiz
  property bool bExtraInfoVisible : false
  property bool bAnswerVisible : false
  property bool bAllok : false
  property bool bTextMode : false
  property bool bTextAnswerOk : false
  Component.onCompleted:
  {
    if (glosModelWorking.count === 0)
      bAllok = true

    idWindow.oTakeQuiz = idRectTakeQuiz
  }

  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {

      property alias  textEdit : idTextEditYourAnswer.text
      radius:10
      width:idView.width
      height:idRectTakeQuiz.height - 200
      color:Theme.darkSecondaryColor

      ButtonQuizImg
      {
        id:idInfoBtn
        anchors.left:  parent.left
        anchors.leftMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"image://theme/icon-m-about"
        visible :extra.length > 0
        onClicked: bExtraInfoVisible = !bExtraInfoVisible
      }
      ButtonQuizImg
      {
        id:idTextBtn
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"image://theme/icon-m-keyboard"
        onClicked: bTextMode = !bTextMode
      }

      ButtonQuizImg
      {
        id:idSoundBtn
        visible : bTextAnswerOk && bTextMode
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        source:"image://theme/icon-m-speaker"
        onClicked: MyDownloader.playWord(answer,bIsReverse ? sFromLang : sToLang)
      }

      Text
      {
        id:idTextExtra
        anchors.left: idInfoBtn.right
        anchors.leftMargin:  20
        anchors.verticalCenter: idInfoBtn.verticalCenter
        color:Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        visible:bExtraInfoVisible
        text: extra
      }

      Image {
        y:100
        x:10
        visible : bTextAnswerOk && bTextMode
        source: "image://theme/icon-m-like"
      }

      TextField
      {
        id:idTextEditYourAnswer
        y:50
        anchors.horizontalCenter: parent.horizontalCenter
        visible:bTextMode
        width:parent.width  - 150
        labelVisible : false
        placeholderText : "your answer"
        onTextChanged:
        {
          bTextAnswerOk =  QuizLib.isAnswerOk(text, answer)
        }
      }

      Column
      {
        spacing: 20
        width:parent.width
        y:parent.height / 3
        visible: !bAllok
        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible:(bIsReverse ? bHasSpeech : bHasSpeechFrom)
          source:"qrc:qml/pages/hornbig.png"
          onClicked: MyDownloader.playWord(question,bIsReverse ? sToLang : sFromLang )
        }

        Text
        {
          id:idTextQuestion
          color:Theme.highlightColor
          font.pixelSize: Theme.fontSizeExtraLarge
          font.bold: true
          anchors.horizontalCenter: parent.horizontalCenter
          text : question
          onTextChanged: idTextEditYourAnswer.text = ""
        }

        ButtonQuiz
        {
          id:idBtnAnswer
          anchors.horizontalCenter: parent.horizontalCenter
          text:"Show Answer"
          onClicked:
          {
            bAnswerVisible = !bAnswerVisible
          }
        }

        Text
        {
          id:idTextAnswer
          color:Theme.highlightColor
          font.pixelSize: Theme.fontSizeExtraLarge
          font.bold: true
          visible:bAnswerVisible
          anchors.horizontalCenter: parent.horizontalCenter
          horizontalAlignment: Text.AlignHCenter
          text : answer
        }

        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible: (bIsReverse ? bHasSpeechFrom : bHasSpeech) && bAnswerVisible
          source:"qrc:qml/pages/hornbig.png"
          onClicked: MyDownloader.playWord(answer,bIsReverse ? sFromLang : sToLang )
        }
      }

      Image {
        visible:bAllok
        anchors.centerIn:  parent
        source: "qrc:qml/pages/thumb.png"
      }

      Image
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.rightMargin: 20
        source:"qrc:qml/pages/r.png"
      }
      Image
      {
        anchors.bottomMargin: 20
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin: 20
        source:"qrc:qml/pages/left.png"
      }
    }
  }

  PathView
  {
    id:idView
    property int nLastIndex : 1
    clip:true
    interactive: bTextAnswerOk || !bTextMode || bAnswerVisible || moving
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height

    onCurrentIndexChanged:
    {
      bTextAnswerOk = false
      QuizLib.calcAndAssigNextQuizWord(currentIndex)
    }

    model : idQuizModel
    delegate:idQuestionComponent
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -(idView.width / 2 + 100); startY: idView.height / 2
      PathLine  { relativeX:  idView.width*3 + 300; relativeY: 0}
    }
  }

}

