import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
  id:idRectTakeQuiz
  width:400
  height:400
  // May be the filler is calculated (PathLen - NoElem*sizeElem) /  (NoElem )
  Component
  {
    id:idQuestionComponent

    Rectangle
    {
      property alias answerVisible: idTextAnswer.visible
      radius:10
      width:idView.width
      height:idView.height
      color:"mediumspringgreen"
      Column
      {
        height:200
        spacing: 20
        anchors.centerIn: parent
        Text
        {
          color:Theme.highlightColor
          font.pointSize: Theme.fontSizeLarge
          font.bold: true
          anchors.horizontalCenter: parent.horizontalCenter
          id:idTextQuestion
          text : question
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
        Item
        {
          height:50
          width:parent.width
          //   color:"yellow"
          Text
          {
            id:idTextAnswer
            visible:visible1
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Theme.fontSizeMedium
            text : answer
          }
        }
        ButtonQuizImg
        {
          anchors.horizontalCenter: parent.horizontalCenter
          visible:bHasSpeech && visible1
          source:"qrc:qml/pages/horn.png"
          onClicked: MyDownloader.playWord(answer,sToLang)
        }

        Image {
          visible:allok
          source: "qrc:qml/pages/thumb.png"
        }
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
    onCurrentIndexChanged:
    {

      var nI = (currentIndex+1) % 3

      nQuizIndex = nI

      if (glosModelWorking.count<1)
      {
        for (var j = 0; j < 3 ;++j)
        {
          idQuizModel.get(j).question =  "-"
          idQuizModel.get(j).answer =  "-"
          idQuizModel.get(j).number =  -1
          idQuizModel.get(j).visible1 = false
          idQuizModel.get(j).allok = false
        }

        return;
      }



      var bDir = 0

      if (nLastIndex == 0 && nI === 1)
        bDir = 1
      if (nLastIndex == 0 && nI === 2)
        bDir = -1
      if (nLastIndex == 1 && nI === 0)
        bDir = -1
      if (nLastIndex == 1 && nI === 2)
        bDir = 1
      if (nLastIndex == 2 && nI === 0)
        bDir = 1
      if (nLastIndex == 2 && nI === 1)
        bDir = -1


      var nLastNumber = idQuizModel.get(nLastIndex).number

      nLastIndex = nI


      if (bDir ===-1)
      {
        var nC = glosModelWorking.count
        for ( var i = 0; i < nC;++i) {
          if (glosModelWorking.get(i).number === nLastNumber)
          {
            glosModelWorking.remove(i);

            if (glosModelWorking.count ===0 )
            {
              for ( i = 0; i < 3 ;++i)
              {
                idQuizModel.get(i).question =  ""
                idQuizModel.get(i).allok = true
              }
            }

            sScoreText  = glosModelWorking.count + "/" + glosModel.count
            nC = glosModel.count
            for (  i = 0; i < nC;++i) {
              if (glosModel.get(i).number === nLastNumber)
              {
                glosModel.get(i).state1 = 1;

                db.transaction(
                      function(tx) {
                        tx.executeSql("UPDATE Glosa"+nDbNumber+" SET state=1 WHERE number=?", nLastNumber);
                      })

                break;
              }
            }
            break;
          }
        }
      }

      if (glosModelWorking.count>0)
      {
        var nIndexOwNewWord = Math.floor(Math.random() * glosModelWorking.count);
        idQuizModel.get(nI).question = glosModelWorking.get(nIndexOwNewWord).question
        idQuizModel.get(nI).answer = glosModelWorking.get(nIndexOwNewWord).answer
        idQuizModel.get(nI).number = glosModelWorking.get(nIndexOwNewWord).number
        idQuizModel.get(nI).visible1 = false
        idQuizModel.get(nI).allok = false
      }

    }


    y:100
    clip:true
    width:idRectTakeQuiz.width
    height:idRectTakeQuiz.height
    model : idQuizModel
    delegate:idQuestionComponent
    snapMode: ListView.SnapOneItem
    path: Path {
      startX: -(idView.width / 2 + 100); startY: idView.height / 2
      PathLine  { relativeX:  idView.width*3 + 300; relativeY: 0}
    }
  }



}

