TEMPLATE = app
TARGET = OpenDataSpace

CONFIG += qt warn_on debug_and_release cascades
LIBS += -lcamapi -lscreen  -lbbcascadesmultimedia -lbbsystem -lbbsystemlocale

INCLUDEPATH += ../src
SOURCES += ../src/*.cpp
HEADERS += ../src/*.hpp ../src/*.h

lupdate_inclusion {
    SOURCES += ../assets/*.qml
    SOURCES += ../assets/rooms/*.qml
    SOURCES += ../assets/upload/*.qml
    SOURCES += ../assets/users/*.qml
    SOURCES += ../assets/common/*.qml
    SOURCES += ../assets/media/*.qml
    SOURCES += ../assets/webpages/*.qml
}

device {
	CONFIG(release, debug|release) {
		DESTDIR = o.le-v7
	}
	CONFIG(debug, debug|release) {
		DESTDIR = o.le-v7-g
	}
}

simulator {
	CONFIG(release, debug|release) {
		DESTDIR = o
	}
	CONFIG(debug, debug|release) {
		DESTDIR = o-g
	}
}

OBJECTS_DIR = $${DESTDIR}/.obj
MOC_DIR = $${DESTDIR}/.moc
RCC_DIR = $${DESTDIR}/.rcc
UI_DIR = $${DESTDIR}/.ui

suredelete.target = sureclean
suredelete.commands = $(DEL_FILE) $${MOC_DIR}/*; $(DEL_FILE) $${RCC_DIR}/*; $(DEL_FILE) $${UI_DIR}/*
suredelete.depends = distclean

QMAKE_EXTRA_TARGETS += suredelete

TRANSLATIONS = \
    $${TARGET}_fr.ts \
    $${TARGET}_it.ts \    
    $${TARGET}_de.ts \
    $${TARGET}_en.ts \
    $${TARGET}_es.ts \
    $${TARGET}_ru.ts \
    $${TARGET}.ts

