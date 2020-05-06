import QtQuick 2.0
import Sailfish.Silica 1.0
import "../QuizFunctions.js" as QuizLib

Item {
  id:idRectTakeQuiz
  property bool bExtraInfoVisible : false
  property bool bAnswerVisible : false
  property bool bTextMode : false
  property bool bImageMode : false
  property bool bVoiceMode : false
  property bool bTextAnswerOk : false
  Component.onCompleted:
  {
    idWindow.oTakeQuiz = idRectTakeQuiz
  }

  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {
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
        visible :idQuizModel.extra.length > 0
        onClicked: bExtraInfoVisible = !bExtraInfoVisible
      }


      ButtonQuizImg
      {
        id:idTextBtn
        visible: !allok
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  parent.top
        anchors.topMargin:  20
        source:"image://theme/icon-m-keyboard?"+ (bTextMode
                                                  ? Theme.highlightColor
                                                  : Theme.primaryColor)
        onClicked: bTextMode = !bTextMode
      }

      ButtonQuizImg
      {
        id:idVoiceModeBtn
        visible: !allok
        anchors.left:  parent.left
        anchors.leftMargin:  20
        anchors.top:  idInfoBtn.bottom
        anchors.topMargin:  20
        source: "image://theme/icon-m-headphone?"+ (bVoiceMode
                                                    ? Theme.highlightColor
                                                    : Theme.primaryColor)
        onClicked: bVoiceMode = !bVoiceMode
      }

      ButtonQuizImg
      {
        id:idImgBtn
        visible: !allok && !idSoundBtn.visible
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        source:"image://theme/icon-m-image?" + (bImageMode
                                                ? Theme.highlightColor
                                                : Theme.primaryColor)
        onClicked: bImageMode = !bImageMode
      }

      ButtonQuizImg
      {
        id:idSoundBtn
        visible : bTextAnswerOk && bTextMode &&  !allok
        anchors.right:  parent.right
        anchors.rightMargin:  20
        anchors.top:  idTextBtn.bottom
        anchors.topMargin:  20
        source:"image://theme/icon-m-speaker"
        onClicked: MyDownloader.playWord(idQuizModel.answer,sAnswerLang)
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
        text: idQuizModel.extra
      }

      Image {
        id:idTextAnswerOkImage
        anchors.left: idVoiceModeBtn.left
        anchors.top: idVoiceModeBtn.bottom
        anchors.topMargin:  20
        visible : bTextAnswerOk && bTextMode
        source: "image://theme/icon-m-like"
      }

      TextField
      {
        id:idTextEditYourAnswer
        Component.onCompleted:
        {
          MyDownloader.storeTextInputField(idTextEditYourAnswer)
        }
        y:50
        anchors.horizontalCenter: parent.horizontalCenter
        visible:bTextMode && (!allok)
        width:parent.width  - 150
        labelVisible : false
        placeholderText : "your answer"
        onTextChanged:
        {
          bTextAnswerOk =  QuizLib.isAnswerOk(text, idQuizModel.answer)
        }
      }
      ButtonQuizImg
      {
        visible:!allok && (bIsReverse ? bHasSpeech : bHasSpeechFrom)
        anchors.right: parent.right
        anchors.rightMargin: 20
        y : idBtnAnswer.y + idQuizColumn.y - 20
        source:"qrc:qml/pages/hornbig.png"
        onClicked: MyDownloader.playWord(question,bIsReverse ? sToLang : sFromLang )
      }
      Column
      {
        id:idQuizColumn
        spacing: 20
        anchors.horizontalCenter:  parent.horizontalCenter
        y : parent.height / 4.5
        visible:!allok
        // && (idWindow.nQuizIndex === index)
        Image
        {
          id:idWordImage
          //         cache:false
          height:350
          width:500
          fillMode: Image.PreserveAspectFit
          anchors.horizontalCenter: parent.horizontalCenter
          visible : bImageMode && MyDownloader.hasImg
          source : MyDownloader.urlImg
        }

        Text
        {
          id:idTextQuestion
          opacity: bVoiceMode ? 0 : 1
          color:Theme.highlightColor
          font.pixelSize: Theme.fontSizeExtraLarge
          font.bold: true
          anchors.horizontalCenter: parent.horizontalCenter
          text : question
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
          text : idQuizModel.answer
        }

        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible: (bIsReverse ? bHasSpeechFrom : bHasSpeech) && bAnswerVisible
          source:"qrc:qml/pages/hornbig.png"
          onClicked: MyDownloader.playWord(idQuizModel.answer,sAnswerLang )
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
    property int nLastIndex : 1
    clip:true

    highlightMoveDuration:800

    // Making it lock if bTextMode and not correct answer
    interactive: bTextAnswerOk || !bTextMode || bAnswerVisible || moving
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height

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

