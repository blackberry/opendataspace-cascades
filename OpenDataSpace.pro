APP_NAME = OpenDataSpace

CONFIG += qt warn_on cascades10

LIBS += -lcamapi -lscreen -lbbsystem -lbbsystemlocale -lbbplatform -lbbpim -lbbdata -lbbmultimedia -lbbcascadespickers -lbbplatformbbm -lbbdevice

include(config.pri)

lupdate_inclusion {
    SOURCES += ../assets/*.qml
    SOURCES += ../assets/rooms/*.qml
    SOURCES += ../assets/upload/*.qml
    SOURCES += ../assets/users/*.qml
    SOURCES += ../assets/common/*.qml
    SOURCES += ../assets/media/*.qml
    SOURCES += ../assets/documents/*.qml
    SOURCES += ../assets/appmenu/*.qml
}

device {
    CONFIG(debug, debug|release) {
        # Device-Debug custom configuration
    }

    CONFIG(release, debug|release) {
        # Device-Release custom configuration
    }
}

simulator {
    CONFIG(debug, debug|release) {
        # Simulator-Debug custom configuration
    }
}
