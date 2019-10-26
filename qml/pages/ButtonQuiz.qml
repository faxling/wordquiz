import QtQuick 2.0
import Sailfish.Silica 1.0

Button
{
  property alias bProgVisible : idProgres.running

  BusyIndicator
  {
    id:idProgres
    size: BusyIndicatorSize.Medium
    anchors.centerIn: parent
  }
}
