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
    signal onFolderDeleted()
    property int targetRoomId: -1
    id: deleteFolderPage
    resizeBehavior: PageResizeBehavior.Resize
    attachedObjects: [
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
            id: deleteNowAction
            title: qsTr("Delete now") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            // only triggered if enabled if foldertext was entered
            onTriggered: {
                // delete the folder in the cloud
                odsdata.deleteFolder(targetRoomId, folderPath.valueText)
                // reset fields
                clearFields()
                // signal folder was added
                // causes navigation pane to pop()
                deleteFolderPage.onFolderDeleted()
            }
        }
    ]
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Delete Folder") + Retranslate.onLanguageChanged
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
                ImageAndLabel {
                    id: warning
                    imageSource: "../images/dialog-warning114.png"
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
        targetRoomId = -1
    }
    // set the field values from ODSFolder* data
    function setValues(data) {
        if (data.displayType == "F") {
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
            if (data.path.length > 0) {
                folderPath.valueText = data.path + "/" + data.name
            } else {
                folderPath.valueText = data.name
            }
            targetRoomId = data.containerId
            if (data.children > 0) {
                warning.valueText = qsTr("folder will be deleted with all content !") + Retranslate.onLanguageChanged      
            } else {
                warning.valueText = qsTr("empty folder will be deleted") + Retranslate.onLanguageChanged
            }
        } else {
            roomName.valueText = qsTr("File Type wrong, cannot show Folder to delete") + Retranslate.onLanguageChanged
            return;
        }
    }
    // the fileId we got from context action of ListItem
    function refreshData(name) {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.folderFromName(name))
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
