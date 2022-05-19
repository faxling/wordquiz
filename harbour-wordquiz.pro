# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-wordquiz

QT += qml quick multimedia core svg xml


CONFIG += sailfishapp

SOURCES += src/harbour-wordquiz.cpp \
src/filehelpers.cpp \
src/speechdownloader.cpp \
src/svgdrawing.cpp \
src/crosswordq.cpp \
../Crossword/crossword.cpp


HEADERS += \
    src/speechdownloader.h \
    src/filehelpers.h \
    src/svgdrawing.h \
    src/crosswordq.h
    ../Crossword/crossword.h



DISTFILES += qml/harbour-wordquiz.qml \
    qml/cover/CoverPage.qml \
    qml/pages/DownLoad.qml \
    qml/pages/FirstPage.qml \
    qml/pages/ButtonQuiz.qml \
    qml/pages/CreateNewQuiz.qml \
    qml/pages/EditQuiz.qml \
    qml/pages/HangMan.qml \
    qml/pages/InputTextQuiz.qml \
    qml/pages/InputTextQuizSilica.qml \
    qml/pages/RectRounded.qml \
    qml/pages/TakeQuiz.qml \
    qml/pages/TextList.qml \
    qml/pages/CrossWord.qml \
    qml/QuizFunctions.js \
    qml/CrossWordFunctions.js \
    harbour-wordquiz.desktop \
    rpm/harbour-wordquiz.changes.in \
    rpm/harbour-wordquiz.changes.run.in \
    rpm/harbour-wordquiz.spec \
    rpm/harbour-wordquiz.yaml


SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n

RESOURCES += \
    qml.qrc


