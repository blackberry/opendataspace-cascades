/*
 * Copyright (c) 2012 SSP Europe GmbH, Munich
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import bb.cascades 1.0
import bb.system 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    signal done()
    resizeBehavior: PageResizeBehavior.Resize
    //
    attachedObjects: [
        // we need this image as background for the LoginScreen
        // because we toggle often we use an ImageTracker
        // TODO: different background images for different sizes of smartphone or tablet
        ImageTracker {
            id: backgroundLandscape
            imageSource: "asset:///images/login-ods-1280x768.png"
        },
        // the BackgroundImage
        ImageTracker {
            id: backgroundPortrait
            imageSource: "asset:///images/login-ods-768x1280.png"
        },
        SystemCredentialsPrompt {
            id: credentialsPrompt
            modality: SystemUiModality.Application
            title: qsTr("ODS LogIn")
            body: qsTr("Enter Username and Password to log into your OpenDataSpace Cloud Account") + Retranslate.onLanguageChanged
            includeShowPassword: true
            includeRememberMe: true
            confirmButton.label: qsTr("Login now") + Retranslate.onLanguageChanged
            confirmButton.enabled: true
            cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
            cancelButton.enabled: true
            onFinished: {
                // ods.suppressKeyboard()
                if (result == SystemUiResult.ConfirmButtonSelection) {
                    console.debug("ConfirmButtonSelection done from SystemCredentialsPrompt");
                    // TODO call C++ function to test if Login was OK
                    ods.login(usernameEntry(), passwordEntry())
                    if (OrientationSupport.orientation == UIOrientation.Landscape) {
                        loginToast.position = SystemUiPosition.MiddleCenter
                    } else {
                        loginToast.position = SystemUiPosition.BottomCenter
                    }
                    loginToast.show()
                    done()
                } else if (result == SystemUiResult.CancelButtonSelection) {
                    console.debug("cancel");
                }
            }
        },
        SystemToast {
            id: loginToast
            body: qsTr("ODS Login successfull") + Retranslate.onLanguageChanged
            icon: "asset:///images/rooms-icon.png"
            onFinished: {
                //
            }
        },
        // recalculate positions
        OrientationHandler {
            onOrientationAboutToChange: {
                reLayout(orientation)
            }
        }
    ]
    // the first Container to hold the Background
    Container {
        id: backgroundContainer
        layout: AbsoluteLayout {
        }
        ImageView {
            id: backgroundImage
            // image will be set from main.qml thru alias property sheetBackground
        }
        // the main container to do the Login
        Container {
            layout: StackLayout {
            }
            layoutProperties: AbsoluteLayoutProperties {
                positionX: 50
            }
            id: mainContainer
            // would prefer to use background: Color.Transparent
            // but doenst work to get the background from screen below
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                Button {
                    text: qsTr("Login") + Retranslate.onLanguageChanged
                    preferredWidth: 400.0
                    onClicked: {
                        credentialsPrompt.show()
                    }
                }
                Button {
                    text: qsTr("Preferences") + Retranslate.onLanguageChanged
                    preferredWidth: 400.0
                    onClicked: {
                        rootNavigationPane.openPreferences()
                    }
                }
            }
        }
    }
    function reLayout(orientation) {
        if (orientation == UIOrientation.Landscape) {
            backgroundImage.image = backgroundLandscape.image
            mainContainer.layoutProperties.positionY = 460
        } else {
            backgroundImage.image = backgroundPortrait.image
            mainContainer.layoutProperties.positionY = 900
        }
    }
    // watch the Orientation and reposition the controls
    onCreationCompleted: {
        // initialize positioning
        reLayout(OrientationSupport.orientation)
    }
}
