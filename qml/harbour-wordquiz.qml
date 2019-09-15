import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow
{
    id: idAppWnd
    property string sAppTitle
    property int nPageBottomY
    initialPage: Component { FirstPage { } }
    cover:  Component {CoverPage {} }
    allowedOrientations: defaultAllowedOrientations
}
