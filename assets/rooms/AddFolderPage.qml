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
            title: qsTr("Add Folder")
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (folderName.text != "") {
                    addFolderPage.onFolderAdded(folderName.text)
                    // animation flying data away to the cloud
                    transport.animation.play()
                    transport.containerVisible = true
                    folderNameContainer.visible = false
                    folderName.text = ""
                    folderName.hintText = qsTr("add next Foldername")
                } else {
                    // TODO add red bar
                }
            }
        }
    ]
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Folder Name")
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        // Animate the data transport
        TransportDataToCloud {
            id: transport
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
            TextField {
                id: folderName
                hintText: qsTr("Name of the new Folder")
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
