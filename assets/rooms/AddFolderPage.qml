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
    signal onFolderAdded()
    property string currentPath : ""
    id: addFolderPage
    resizeBehavior: PageResizeBehavior.Resize
    attachedObjects: [
        // a red tile of 16x16 pixels
        ImagePaintDefinition {
            id: redTile
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/tiles/red16x16.png"
        },
        // recalculate positions
        OrientationHandler {
            onOrientationAboutToChange: {
                if (orientation == UIOrientation.Landscape) {
                    relayout(true)
                } else {
                    relayout(false)
                }
            }
        }
    ]
    actions: [
        ActionItem {
            id: createNowAction
            title: qsTr("Create now") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (folderName.textFieldText != "") {
                    odsdata.createFolder(roomId, folderPath)
                    clearFields()
                    addFolderPage.onFolderAdded()
                } else {
                    // TODO dialog
                }
            }
        }
    ]
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Create Folder") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        ScrollView {
            //
            //
            Container {
                id: folderNameContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
                layout: StackLayout {
                }
                leftPadding: 40
                rightPadding: 40
                Divider {
                }
                ImageAndLabel {
                    id: roomName
                    imageSource: "../images/rooms-icon.png"
                }
                ImageAndLabel {
                    id: subroomName
                    imageSource: "../images/subrooms-icon.png"
                }
                ImageAndLabel {
                    id: folderPath
                    imageSource: "../images/folders-icon.png"
                }
                TextFieldWithMarker {
                    id: folderName
                    topPadding: 20
                    bottomPadding: 20
                    redBarImage: redTile.image
                    textFieldHintText: qsTr("Name of the new Folder") + Retranslate.onLanguageChanged
                    textFieldInputMode: TextFieldInputMode.Text
                    textFieldText: ""
                    onRedBarVisibleChanged: {
                        createNowAction.enabled = ! folderName.redBarVisible
                    }
                    onTextFieldTextChanged: {
                        folderPath.valueText = currentPath+folderName.textFieldText
                    }
                }
                LabelAndLabel {
                    id: roomId
                    labelText: qsTr("Room ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: subroomId
                    labelText: qsTr("Subroom ID") + Retranslate.onLanguageChanged
                }
                Divider {
                }
            } // end Container
        } // end scroll view
    } // end main container
    function clearFields() {
        roomName.valueText = parentType
        subroomName.valueText = "subby"
        folderPath.valueText = "folder/"
        folderName.textFieldText = ""
    }
    // set the field values from ODSFolder* data
    function setValues(data) {
        if (data.displayType == "R") {
            roomName.valueText = data.name
            roomId.valueText = data.id
            subroomName.visible = false
            subroomId.visible = false
            currentPath = "/"
            folderPath.valueText = currentPath
        } else if (data.displayType == "S") {
            subroomName.visible = true
            subroomId.visible = true
            subroomName.valueText = data.name
            subroomId.valueText = data.id
            currentPath = "/"
            folderPath.valueText = currentPath
        } else if (data.displayType == "F") {
            if (data.roomId == 0) {
                // no subroom - directly into the Room
                roomId.valueText = data.containerId
                roomName.valueText = odsdata.roomGroupName(data.containerId)
                subroomId.visible = false
                subroomName.visible = false
            } else {
                subroomId.valueText = data.containerId
                subroomName.valueText = odsdata.roomGroupName(data.containerId)
                subroomId.visible = true
                subroomName.visible = true
                roomId.valueText = data.roomId
                roomName.valueText = odsdata.roomGroupName(data.roomId)
            }
            currentPath = data.path +  "/"
            folderPath.valueText = currentPath
        } else {
            roomName.valueText = qsTr("File Type wrong, cannot create Folder") + Retranslate.onLanguageChanged
            return;
        }
    }
    function refreshData() {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.parentData())
    }
    // TODO refresh fromRoom with id
    // TODO refresh fromSubRoom with Id
    // relayout if orientation changes
    function relayout(landscape) {
        // TODO
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
        }
        clearFields();
    }
}
