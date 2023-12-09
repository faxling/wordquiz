#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QStandardPaths>
#include <sailfishapp.h>
#include "filehelpers.h"
#include "svgdrawing.h"

#include <src/speechdownloader.h>
#include <src/crosswordq.h>

// c:\Users\fraxl\Documents\qt\sfosicons\
// ssh-keygen -t ed25519 -C faxling11@gmail.com


//  eval "$(ssh-agent -s)"
// git remote add origin git@github.com:faxling/tripometer.git

int main(int argc, char *argv[])
{

    auto app = SailfishApp::application(argc, argv);
    QQuickView* view =  SailfishApp::createView();
    QQmlContext *pContext = view->rootContext();

    pContext->setContextProperty("MyDownloader", new Speechdownloader( view->engine()->offlineStoragePath(),nullptr));
    pContext->setContextProperty("CrossWordQ",  new CrossWordQ);


    qmlRegisterType<SvgDrawing>("SvgDrawing",1,0,"SvgDrawing");
    view->setSource(SailfishApp::pathTo("qml/harbour-wordquiz.qml"));

    view->showFullScreen();
    app->exec();
}
