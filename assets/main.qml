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
 */import bb.cascades 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    id: homePage
    property alias loginSheetVisible: loginSheet.visible
    property alias helpSheetVisible: helpSheet.visible
    //
    attachedObjects: [
        //-- sheet is not visible still, prepare it and append to the attachedObjects
        //-- attachedObjects property is a storage for objects which are not supposed to be visible on scene
        Sheet {
            id: loginSheet
            //-- sheet GUI appearence component is defined in external LoginSheet.qml file
            content: LoginSheet {
                id: loginContent
            }
        },
        Sheet {
            id: helpSheet
            //-- sheet GUI appearence component is defined in external HelpSheet.qml file
            content: HelpSheet {
                id: helpContent
            }
        },
        // we need this image as background for the HomeScreen
        // because we toggle often we use an ImageTracker
        // TODO: different background images for different sizes of smartphone or tablet
        ImageTracker {
            id: backgroundLandscape
            imageSource: "asset:///images/login-ods-1280x768-o.png"
        }, 
        // the BackgroundImage
        ImageTracker {
            id: backgroundPortrait
            imageSource: "asset:///images/login-ods-768x1280-o.png"
        },
        // application supports changing the Orientation
        OrientationHandler {
            onUiOrientationChanging: {
                // perhaps an animation later
            }
            onUiOrientationChanged: {
                if (uiOrientation == UiOrientation.Landscape) {
                    backgroundImage.image = backgroundLandscape.image
                } else {
                    backgroundImage.image = backgroundPortrait.image
                }
            }
        }
    ]
    // Actions
    actions: [
        ActionItem {
            title: qsTr ("DataRooms")
            ActionBar.placement: ActionBarPlacement.OnBar
        }, 
        ActionItem {
            title: qsTr ("Users")
            ActionBar.placement: ActionBarPlacement.OnBar
        }
    ]
    
    // the content of the HomeScreen
    content:
    
    // at first we need a Container with the Background Image
 // we use AbsoluteLayout because then its easy to place the main container at 0,0
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
        // the main Container (starting at 0,0)
        Container {
            id: mainContainer
            layoutProperties: AbsoluteLayoutProperties {
                positionX: 0
                positionY: 0
            }
            // place recently used Room here
            
        }
        // a delayed-for-1000 ms Animation to open LoginSheet first time
        animations: [
            TranslateTransition {
                id: startupDelayToOpenSheetFirstTime
                delay: 2000
                onEnded: {
                    loginSheet.visible = true
                }
            }
        ]
    }
    
    // the handler SLOT if LogIn was done
    function saveEdits(ok) {
        if (ok) {
            //-- when sheet is closed with success, login was OK
            // TODO
        } else {
            // TODO bring back the LogIn and perhaps a Dialog
        }
        loginSheet.visible = false
    }
    // the handler  SLOT HELP done
    function closeHelp(ok) {
        helpSheet.visible = false
    }

    // the HomeScreen is initialized
    onCreationCompleted: {
        // Overlay ActionBar
        homePage.actionBarVisibility = ChromeVisibility.Overlay
        // support all orientations
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        // test current Orientation and set the Background Image
        if (OrientationSupport.uiOrientation == UiOrientation.Landscape) {
            backgroundImage.image = backgroundLandscape.image
        } else {
            backgroundImage.image = backgroundPortrait.image
        }
        //-- connect the sheet done SIGNAL to the handler SLOT
        loginContent.done.connect(saveEdits)
        //
        helpContent.helpDone.connect(closeHelp)
        helpSheet.visible = false
        loginSheet.visible = false
        // start the animation to open LoginSheet after 1 s
        startupDelayToOpenSheetFirstTime.play();
    }
}
