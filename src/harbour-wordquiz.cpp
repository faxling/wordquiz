#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickView>
#include <sailfishapp.h>

#include <src/speechdownloader.h>


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-wordquiz.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).


    auto app = SailfishApp::application(argc, argv);
    QQuickView* view =  SailfishApp::createView();

    QQmlContext *pContext = view->rootContext();
    pContext->setContextProperty("MyDownloader", new Speechdownloader( view->engine()->offlineStoragePath(),app));
    view->setSource(SailfishApp::pathTo("qml/harbour-wordquiz.qml"));

    view->showFullScreen();
    app->exec();
}
