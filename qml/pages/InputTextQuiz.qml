import QtQuick 2.0
import Sailfish.Silica 1.0
Rectangle
{
  property alias text : idTextInput.text
  color:"grey"
  width: parent.width
  height: Theme.fontSizeLarge
  TextInput
  {
    font.pointSize: Theme.fontSizeMedium
    anchors.fill: parent
    id:idTextInput
  }
}
