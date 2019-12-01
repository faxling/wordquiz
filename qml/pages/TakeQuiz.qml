import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id:idRectTakeQuiz

  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {
      property alias answerVisible: idTextAnswer.visible
      radius:10
      width:idView.width
      height:idRectTakeQuiz.height - 200
      color:Theme.darkSecondaryColor
      Column
      {
        spacing: 20
        width:parent.width
        y:parent.height / 3
        visible: !allok
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
        }
        Text
        {
          id:idTextExtra
          color:Theme.primaryColor
          font.pixelSize: Theme.fontSizeExtraSmall
          anchors.horizontalCenter: parent.horizontalCenter
          text :  extra
        }
        ButtonQuiz
        {
          id:idBtnAnswer
          anchors.horizontalCenter: parent.horizontalCenter
          text:"Show Answer"
          onClicked:
          {
            idQuizModel.setProperty(index,"visible1",true)
          }
        }

        Text
        {
          id:idTextAnswer
          color:Theme.highlightColor
          font.pixelSize: Theme.fontSizeExtraLarge
          font.bold: true
          visible:visible1
          anchors.horizontalCenter: parent.horizontalCenter
          horizontalAlignment: Text.AlignHCenter
          text : answer
        }

        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible: (bIsReverse ? bHasSpeechFrom : bHasSpeech) && visible1
          source:"qrc:qml/pages/hornbig.png"
          onClicked: MyDownloader.playWord(answer,bIsReverse ? sFromLang : sToLang )
        }
      }

      Image {
        visible:allok
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
    clip:true
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height
    property int nLastIndex : 1
    onCurrentIndexChanged:
    {
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

