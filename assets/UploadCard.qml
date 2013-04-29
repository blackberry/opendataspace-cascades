import bb.cascades 1.0
import bb.system 1.0
import org.opendataspace.fileinfo 1.0
import org.opendataspace.dateutil 1.0
import "appmenu"
import "../media"
import "../documents"

NavigationPane {
    // login property triggered from C++ when login to server done
    property int login: -1
    id: cardNavPaneId
    objectName: "cardNavPaneId"
    property alias newCard: pageId.newCard
    property alias filePath: pageId.filePath
    attachedObjects: [
        // we need this image as background for the HomeScreen
        // because we toggle often we use an ImageTracker
        // TODO: different background images for different sizes of smartphone or tablet
        ImageTracker {
            id: backgroundLandscape
            imageSource: ods.isSquare() ? "asset:///images/login-ods-720x720-o.png" : "asset:///images/login-ods-1280x768-o.png"
        },
        // the BackgroundImage
        ImageTracker {
            id: backgroundPortrait
            imageSource: "asset:///images/login-ods-768x1280-o.png"
        },
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
        VideoPreviewPage {
            id: videoPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        VoicePreviewPage {
            id: recordedVoicePreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        DocumentsPreviewPage {
            id: documentsPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        HtmlPreviewPage {
            id: htmlPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        BooksPreviewPage {
            id: booksPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        PdfPreviewPage {
            id: pdfPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        ZipPreviewPage {
            id: zipPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        onBackFromPreviewTriggered()
                    }
                }
            }
        },
        SystemToast {
            id: backFromPreviewToast
            body: qsTr("Hitting BACK: File was not uploaded !") + Retranslate.onLanguageChanged
            icon: "asset:///images/upload-icon.png"
            position: SystemUiPosition.BottomCenter
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
            position: SystemUiPosition.BottomCenter
            onFinished: {
                // we have to do this here - otherwise the user won't get it
                // because the card is closed so fast
                ods.cardCanceled("wrong FilePath: " + filePath)
            }
        },
        SystemToast {
            id: queuedForUploadToast
            body: qsTr("Queued for Upload to ODS Cloud")
            icon: "asset:///images/ics/4-collections-cloud-av-upload81.png"
            position: SystemUiPosition.BottomCenter
            onFinished: {
                //
                ods.cardDone()
            }
        },
        // application supports changing the Orientation
        OrientationHandler {
            onOrientationAboutToChange: {
                if (orientation == UIOrientation.Landscape) {
                    backgroundImage.image = backgroundLandscape.image
                } else {
                    backgroundImage.image = backgroundPortrait.image
                }
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
            id: backgroundContainer
            layout: AbsoluteLayout {
            }
            // the background Image
            ImageView {
                id: backgroundImage
                // image will be set:
                // a: onCreationCompleted
                // b: onUiOrientationChanged
            }
        }
        onCreationCompleted: {
            // Overlay ActionBar
            pageId.actionBarVisibility = ChromeVisibility.Overlay
            // support all orientations
            //OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
            // test current Orientation and set the Background Image
            if (ods.isSquare() || OrientationSupport.orientation == UIOrientation.Landscape) {
                backgroundImage.image = backgroundLandscape.image
            } else {
                backgroundImage.image = backgroundPortrait.image
            }
            console.debug("CardPage created");
        }
        onNewCardChanged: {
            if (newCard == true) {
                newCard = false;
                if (odsdata.loginValid()) {
                    console.debug("Login valid");
                    // now we can prepare the content
                    prepareContent();
                    
                } else {
                    console.debug("UPLOAD-CARD: Login not valid");
                    // in this case we connect to server signal
                    connectToLoginFinished()
                    // ... and push login page
                    push(loginPage)
                    // if login done successfully content can be prepared
                }
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
        // isVideo ?
        if (fileInfo.isVideo(filePath)) {
            console.debug("got signal to preview Video: " + filePath)
            videoPreviewPage.previewPath = filePath;
            videoPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(videoPreviewPage)
            return;
        }
        // isAudio ?
        if (fileInfo.isAudio(filePath)) {
            console.debug("got signal to preview audio: " + filePath)
            recordedVoicePreviewPage.previewPath = filePath;
            recordedVoicePreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(recordedVoicePreviewPage)
            return;
        }
        // isPDF ?
        if (fileInfo.getSuffix(filePath) == "pdf") {
            console.debug("got signal to preview pdf: " + filePath)
            pdfPreviewPage.previewPath = filePath;
            pdfPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(pdfPreviewPage)
            return;
        }
        // isHtml ?
        if (fileInfo.isHtml(filePath)) {
            console.debug("got signal to preview HTML: " + filePath)
            htmlPreviewPage.previewPath = filePath;
            htmlPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(htmlPreviewPage)
            return;
        }
        // isZIP ?
        if (fileInfo.isCompressed(filePath)) {
            console.debug("got signal to preview ZIP: " + filePath)
            zipPreviewPage.previewPath = filePath;
            zipPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(zipPreviewPage)
            return;
        }
        // isDocument ?
        if (fileInfo.isDocument(filePath)) {
            console.debug("got signal to preview doc: " + filePath)
            documentsPreviewPage.previewPath = filePath;
            documentsPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(documentsPreviewPage)
            return;
        }
        // isBook ?
        if (fileInfo.isBook(filePath)) {
            // TODO previewBookPage
            console.debug("got signal to preview book: " + filePath)
            booksPreviewPage.previewPath = filePath;
            booksPreviewPage.recalculateValues(filePath);
            cardNavPaneId.push(booksPreviewPage)
            return;
        }
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
        if (cardNavPaneId.top != pageId) {
            cardNavPaneId.pop();
        }
        // if login failed we have to cancel the Card
        if (success) {
            // login was OK, the User can do the expected Card stuff
            console.debug("coming back from Login: Login true");
            prepareContent();
        } else {
            // cancel the CARD
            console.debug("Login failed - CANCEL the CARD");
            ods.cardCanceled("Login failed")
        }
    }
    // function called if user navigates back from preview without uploading
    function onBackFromPreviewTriggered() {
        if (cardNavPaneId.top != pageId) {
            cardNavPaneId.pop();
        }
        backFromPreviewToast.show()
        // this will be done from toast onFinished():
        // ods.cardCanceled("Back")
    }
    // called if the user decided to upload the file to ODS
    function onUpload(name) {
        // select the destination room and upload
        odsdata.simpleUploadFromCard(name)
        
        if (cardNavPaneId.top != pageId) {
            cardNavPaneId.pop();
        }
    }
    function uploadDone(){
        ods.cardDone();
    }
    // triggered from C++
    onLoginChanged: {
        console.debug("login changed: " + login);
        if (login == 1) {
            onLoginDone(true)
        } else if (login == 0) {
            onLoginDone(false)
        }
    }
    function connectToLoginFinished() {
        console.debug("UPLOAD CARD connect with loginFinished");
        odsdata.loginFinished.connect(onLoginDone)
    }
    onCreationCompleted: {
        // controlled  by host application !
        // OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //-- connect the LoginPage done SIGNAL to the handler SLOT
        loginPage.loginDone.connect(onLoginDone)
        // connect server-login
        // odsdata.loginFinished.connect(onLoginDone)
        // connect the preview pages
        imagePreviewPage.uploadFromCard.connect(onUpload)
        videoPreviewPage.uploadFromCard.connect(onUpload)
        recordedVoicePreviewPage.uploadFromCard.connect(onUpload)
        pdfPreviewPage.uploadFromCard.connect(onUpload)
        htmlPreviewPage.uploadFromCard.connect(onUpload)
        zipPreviewPage.uploadFromCard.connect(onUpload)
        documentsPreviewPage.uploadFromCard.connect(onUpload)
        booksPreviewPage.uploadFromCard.connect(onUpload)
        //
        odsdata.fileUploaded.connect(uploadDone)
        console.debug("UPLOAD CARD NavigationPane created");
    }
}
