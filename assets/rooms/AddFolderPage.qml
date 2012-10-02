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
import "../common"

Page {
    // SIGNAL if folder was added
    signal onFolderAdded(string name)
    id: addFolderPage
    attachedObjects: [
        // a red tile of 16x16 pixels
        ImagePaintDefinition {
            id: redTile
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/tiles/red16x16.png"
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Add Folder") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (folderName.textFieldText != "") {
                    addFolderPage.onFolderAdded(folderName.textFieldText)
                    dataError.containerVisible = false
                    transport.value = 80
                    transport.visible = true
                    dummi.play()
                } else {
                    // animation to demonstrate that there are errors
                    dataError.animation.play()
                    dataError.containerVisible = true
                }
            }
        }
    ]
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Folder Name") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }

        //
        Container {
            id: folderNameContainer
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
            }
            leftPadding: 40
            rightPadding: 40
            // Animate the data transport
            // TODO animate while transmitting
            animations: [
                SequentialAnimation {
                    onStarted: {
                        folderName.enabled = false
                    }
                    id: dummi
                    FadeTransition {
                        duration: 1000
                        fromOpacity: 1.0
                        toOpacity: 0.4
                        onEnded: {
                            transport.value = 40
                        }
                    }
                    FadeTransition {
                        duration: 1000
                        fromOpacity: 0.4
                        toOpacity: 1.0
                    }
                    onEnded: {
                        transport.value = 10
                        transport.visible = false
                        folderName.textFieldText = ""
                        folderName.textFieldHintText = qsTr("another Foldername") + Retranslate.onLanguageChanged
                        folderName.enabled = true
                    }
                }
            ]
            // Error Assistant
            ErrorAssistant {
                id: dataError
            }
            ProgressIndicator {
                id: transport
                topMargin: 25
                fromValue: 100
                toValue: 0
                value: 80
                visible: false
            }
            TextFieldWithMarker {
                id: folderName
                redBarImage: redTile.image
                textFieldHintText: qsTr("Name of the new Folder") + Retranslate.onLanguageChanged
                textFieldInputMode: TextFieldInputMode.Text
                textFieldText: ""
            }
        } // end Container
    } // end main container
    function clearFields() {
        folderName.textFieldText = ""
    }
    onCreationCompleted: {
        clearFields();
    }
}
