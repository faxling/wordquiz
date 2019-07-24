import QtQuick 2.0
import Sailfish.Silica 1.0
Rectangle
{
  property alias displayText : idTextInput.displayText
  property alias text : idTextInput.text
  color:"grey"
  width: parent.width
  height: Theme.fontSizeLarge
  TextInput
  {
    cursorDelegate : Rectangle
    {
      visible: idTextInput.focus
      height : parent.height
      width: 6
      color: Theme.highlightColor
    }

    anchors.topMargin: 2
    font.pixelSize: Theme.fontSizeMedium
    anchors.fill: parent
    id:idTextInput
  }
}
