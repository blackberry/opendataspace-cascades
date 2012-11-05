import bb.cascades 1.0
import bb.system 1.0
import org.opendataspace.fileinfo 1.0
import org.opendataspace.dateutil 1.0
import "appmenu"
import "../media"
import "../documents"

NavigationPane {
    id: cardNavPaneId
    objectName: "cardNavPaneId"
    property alias newCard: pageId.newCard
    property alias filePath: pageId.filePath
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
        ImagePreviewPage {
            id: imagePreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        UnknownPreviewPage {
            id: unknownPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
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
        },
        SystemToast {
            id: backFromPreviewToast
            body: qsTr("Hitting BACK: File was not uploaded !") + Retranslate.onLanguageChanged
            icon: "asset:///images/upload-icon.png"
            onFinished: {
                // we have to do this here - otherwise the user won't get it
                // because the card is closed so fast
                ods.cardCanceled("Back")
            }
        },
        SystemToast {
            id: filePathFailedToast
            body: "??"
            icon: "asset:///images/upload-icon.png"
            onFinished: {
                // we have to do this here - otherwise the user won't get it
                // because the card is closed so fast
                ods.cardCanceled("wrong FilePath: " + filePath)
            }
        },
        // FileInfo
        FileInfo {
            id: fileInfo
        },
        // DateUtil
        DateUtil {
            id: dateUtil
        }
    ]
    Page {
        property bool newCard: false
        property string filePath
        id: pageId
        objectName: "pageId"
        Container {
            id: containerId
            layout: StackLayout {
            }
            Label {
                id: filePathLabel
                text: "Path"
            }
        }
        onCreationCompleted: {
            console.debug("CardPage created");
        }
        onNewCardChanged: {
            if (newCard == true) {
                newCard = false;
                if (ods.loginDone() == false) {
                    console.debug("Login not valid");
                    // in this case we push the login page
                    push(loginPage)
                    // if login done successfully content can be prepared
                } else {
                    console.debug("Login valid");
                    // now we can prepare the content
                    prepareContent();
                }
                filePathLabel.text = filePath
            }
        }
    }
    // if login was done with success
    // or no login needed
    // we can prepare the content of this page
    function prepareContent() {
        // check if filePath was sent
        if (filePath.length == 0) {
            filePathFailedToast.body = qsTr("SORRY: no FilePath - you cannot upload the file") + Retranslate.onLanguageChanged
            filePathFailedToast.show()
            // this will be done from toast onFinished():
            // ods.cardCanceled("wrong FilePath: " + filePath)
            return
        }
        // isImage ?
        if (fileInfo.isImage(filePath)) {
            console.debug("got signal to preview image: " + filePath)
            imagePreviewPage.previewPath = filePath;
            cardNavPaneId.push(imagePreviewPage)
            return;
        }
        // TODO
        // else is unknown filytype
        console.debug("got signal to preview video: " + filePath)
        unknownPreviewPage.previewPath = filePath;
        unknownPreviewPage.recalculateValues(filePath);
        cardNavPaneId.push(unknownPreviewPage)
    }
    // function called if login had to be done
    // if login failed, Card will be closed (cancel)
    // if login ok, prepare content
    function onLoginDone(success) {
        // we always pop the root page of this NavigationPane
        cardNavPaneId.pop();
        // if login failed we have to cancel the Card
        if (! success || ods.loginDone() == false) {
            console.debug("coming back from Login: Login false");
            loginFailedToast.show()
            // this will be done from toast onFinished():
            // ods.cardCanceled("Login failed")
        } else {
            // login was OK, the User can do the expected Card stuff
            console.debug("coming back from Login: Login true");
            prepareContent();
        }
    }
    // function called if user navigates back from preview without uploading
    function onBackFromPreviewTriggered() {
        // we always pop the root page of this NavigationPane
        cardNavPaneId.pop();
        backFromPreviewToast.show()
        // this will be done from toast onFinished():
        // ods.cardCanceled("Back")
    }
    onCreationCompleted: {
        // controlled  by host application !
        // OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //-- connect the LoginPage done SIGNAL to the handler SLOT
        loginPage.loginDone.connect(onLoginDone)
        console.debug("NavigationPane created");
    }
}
