import bb.cascades 1.0
import bb.system 1.0

NavigationPane {
    id: cardNavPaneId
    objectName: "cardNavPaneId"
    property alias invokationMode: invocationModeLabelId.text
    property alias counter: pageId.counter
    property alias newCard: pageId.newCard
    attachedObjects: [
        LoginSheet {
            id: loginPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    // hitting back button means: no login done
                    onTriggered: {
                        onLoginDone(false)
                    }
                }
            }
        },
        SystemToast {
            id: loginFailedToast
            body: qsTr("SORRY: Login failed - you cannot upload the file") + Retranslate.onLanguageChanged
            icon: "asset:///images/upload-icon.png"
            onFinished: {
                // we have to do this here - otherwise the user won't get it
                // because the card is closed so fast
                ods.cardCanceled("Login failed")
            }
        }
    ]
    Page {
        property int counter: 0
        property bool newCard: false
        id: pageId
        objectName: "pageId"
        Container {
            id: containerId
            layout: StackLayout {
            }
            Label {
                id: invocationModeLabelId
                text: "Invoked"
            }
            Label {
                id: labelId
                text: "--"
            }
            Button {
                text: "Press Me to count"
                onClicked: {
                    pageId.calculateLabeltext()
                    if (counter > 3) {
                        ods.cardDone()
                    }
                }
            }
        }
        function calculateLabeltext() {
            pageId.counter ++
            labelId.text = "Pressed " + pageId.counter + " times"
        }
        onCreationCompleted: {
            calculateLabeltext();
            console.debug("CardPage created");
        }
        onNewCardChanged: {
            if (newCard == true) {
                newCard = false;
                if (ods.loginDone() == false) {
                    console.debug("Login false");
                    push(loginPage)
                } else {
                    console.debug("Login true");
                }
            }
        }
    }
    function onLoginDone(success) {
        // we always pop the root page of this NavigationPane
        cardNavPaneId.pop();
        // if login failed we have to cancel the Card
        if (!success || ods.loginDone() == false) {
            console.debug("coming back from Login: Login false");
            loginFailedToast.show()
            // this will be done from tast onFinished():
            // ods.cardCanceled("Login failed")
        } else {
            // login was OK, the User can do the expected Card stuff
            console.debug("coming back from Login: Login true");
        }
    }
    onCreationCompleted: {
        // controlled  by host application !
        // OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //-- connect the LoginPage done SIGNAL to the handler SLOT
        loginPage.loginDone.connect(onLoginDone)
        console.debug("NavigationPane created");
    }
}
