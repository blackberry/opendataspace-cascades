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
    actions: [
        ActionItem {
            title: qsTr("Add Folder") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (folderName.text != "") {
                    addFolderPage.onFolderAdded(folderName.text)
                    transport.value = 80
                    transport.visible = true
                    dummi.play()
                } else {
                    // TODO add red bar
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
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
            layout: StackLayout {
                leftPadding: 40
                rightPadding: 40
            }
            
            // Animate the data transport
            // TODO animate while transmitting
            animations: [
                SequentialAnimation {
                    onStarted: {
                        folderName.enabled = false
                    }
                    id: dummi
                    FadeTransition {
                        duration: 1500
                        fromOpacity: 1.0
                        toOpacity: 0.1
                        onEnded: {
                            transport.value = 40
                        }
                    }
                    FadeTransition {
                        duration: 500
                        fromOpacity: 0.1
                        toOpacity: 1.0
                    }
                    onEnded: {
                        transport.value = 10
                        transport.visible = false
                        folderName.enabled = true
                        folderName.text = ""
                        folderName.hintText = qsTr("another Foldername") + Retranslate.onLanguageChanged
                    }
                }
            ]
            ProgressIndicator {
                id: transport
                fromValue: 100
                toValue: 0
                value: 80
                visible: false
            }
            TextField {
                id: folderName
                hintText: qsTr("Name of the new Folder") + Retranslate.onLanguageChanged
                inputMode: TextFieldInputMode.Text
                textStyle {
                    base: SystemDefaults.TextStyles.TitleText
                }
            }
        } // end Container
    } // end main container
    function doTransportAnimationEnd() {
        folderNameContainer.visible = true
    }
    onCreationCompleted: {
        // connect transport animation end SIGNAL
        transport.animation.onTransportAnimationEnd.connect(doTransportAnimationEnd)
    }
}
