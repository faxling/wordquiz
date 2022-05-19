import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow {
  id: idAppWnd
  property string sAppTitle
  property int nPageBottomY
  initialPage: Component {
    // @disable-check M301
    FirstPage {}
  }
  cover: Component {
    CoverPage {}
  }
  allowedOrientations: defaultAllowedOrientations
}
