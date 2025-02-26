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

// c:\Users\fraxl\Documents\qt\sfosicons
// ssh-keygen -t ed25519 -C faxling11@gmail.com

// for reverso impersonate proxy to avoid
//  CloudFlare, and attempts to scrape the site will be faced with a JavaScript challenge, a form of CAPTCHA.
// https://github.com/lwthiker/curl-impersonate/

// Interfacing reversos
// https://github.com/s0ftik3/reverso-api
// npm i reverso-api
// service config
// /etc/systemd/system/reverso-node-app.service
//
// systemctl start reverso-node-app.service
//
// nginx /etc/nginx/sites-enabled

//

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
