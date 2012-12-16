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
    property string currentPath: ""
    property int targetRoomId: -1
    property bool isRootFolder: true
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
            // dynamically changed if enabled onRedBarVisible
            enabled: ! folderName.redBarVisible
            imageSource: "asset:///images/upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            // only triggered if enabled if foldertext was entered
            onTriggered: {
                // create the folder in the cloud
                if (isRootFolder) {
                    odsdata.createFolder(targetRoomId, folderName.textFieldText)
                } else {
                    odsdata.createFolder(targetRoomId, currentPath+"/"+folderName.textFieldText)
                }
                // reset fields
                clearFields()
                // signal folder was added
                // causes navigation pane to pop()
                addFolderPage.onFolderAdded()
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
                        folderPath.valueText = currentPath + "/" + folderName.textFieldText
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
        roomName.valueText = ""
        subroomName.valueText = ""
        folderPath.valueText = ""
        folderName.textFieldText = ""
        targetRoomId = -1
        currentPath = ""
    }
    // set the field values from ODSFolder* data
    function setValues(data) {
        if (data.displayType == "R") {
            // Folder directly inside a DataRoom
            roomName.valueText = data.name
            roomId.valueText = data.id
            subroomName.valueText = ""
            subroomId.valueText = -1
            subroomName.visible = false
            subroomId.visible = false
            currentPath = ""
            folderPath.valueText = currentPath + "/"
            targetRoomId = data.id
            isRootFolder = true
        } else if (data.displayType == "S") {
            subroomName.visible = true
            subroomId.visible = true
            subroomName.valueText = data.name
            subroomId.valueText = data.id
            roomName.valueText = odsdata.roomGroupName(data.roomId)
            roomId.valueText = data.roomId
            currentPath = ""
            folderPath.valueText = currentPath + "/"
            targetRoomId = data.id
            isRootFolder = true
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
            currentPath = data.path
            folderPath.valueText = currentPath + "/"
            targetRoomId = data.containerId
            isRootFolder = false
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
    // relayout if orientation changes
    function relayout(landscape) {
        if (landscape == true) {
            roomId.landscape = true
            roomName.landscape = true
            subroomId.landscape = true
            subroomName.landscape = true
            folderPath.landscape = true
        } else {
            roomId.landscape = false
            roomName.landscape = false
            subroomId.landscape = false
            subroomName.landscape = false
            folderPath.landscape = false
        }
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
        }
        clearFields();
    }
}
