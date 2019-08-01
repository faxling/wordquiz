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

    auto app = SailfishApp::application(argc, argv);
    QQuickView* view =  SailfishApp::createView();

    QQmlContext *pContext = view->rootContext();
    pContext->setContextProperty("MyDownloader", new Speechdownloader( view->engine()->offlineStoragePath(),nullptr));
    view->setSource(SailfishApp::pathTo("qml/harbour-wordquiz.qml"));

    view->showFullScreen();
    app->exec();
}
