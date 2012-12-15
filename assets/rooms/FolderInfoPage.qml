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
    id: folderInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Folder Info") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
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
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-copy81.png"
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Move") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-import-export81.png"
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Rename") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-edit81.png"
            onTriggered: {
                // TODO
                console.debug("FOLDER: name to be renamed: " + ListItemData.name)
                // TODO
                ListItemData.name = "renamed"
            }
        },
        DeleteActionItem {
            title: qsTr("Delete") + Retranslate.onLanguageChanged
            onTriggered: {
                // TODO
            }
        }
    ]
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        ScrollView {
            //
            Container {
                id: folderInfoContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                }
                leftPadding: 40
                rightPadding: 40
                // header
                Divider {
                }
                ImageAndLabel {
                    id: headerId
                }
                Divider {
                }
                // body
                LabelAndLabel {
                    id: containsFilesAndFolders
                    labelText: qsTr("contains") + Retranslate.onLanguageChanged
                }
                Divider {
                }
                CloudInfoHeader {
                }
                Divider {
                }
                LabelAndLabel {
                    id: cloudPath
                    labelText: qsTr("Node") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: roomId
                    labelText: qsTr("Room ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: roomName
                    labelText: qsTr("Room Name") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: subroomId
                    labelText: qsTr("Subroom ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: subroomName
                    labelText: qsTr("Subroom Name") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: folderPath
                    labelText: qsTr("In Folder") + Retranslate.onLanguageChanged
                }
                Divider {
                }
            } // end fileInfoContainer
        } // end scroll view
    } // end main container
    // set the field values from ODSFile* data
    function setValues(data, name) {
        if (data.name != name) {
            // if the name isn't equal the folder was not found
            headerId.valueText = qsTr("Folder not found") + Retranslate.onLanguageChanged
            return;
        }
        headerId.imageSource = data.displayIcon
        headerId.valueText = data.name
        containsFilesAndFolders.valueText = data.children + qsTr(" Files / Folders") + Retranslate.onLanguageChanged
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
        folderPath.valueText = data.path
        cloudPath.valueText = odsdata.nodePath
    }
    // the fileId we got from context action of ListItem
    function refreshData(name) {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.folderFromName(name), name)
    }
    // relayout if orientation changes
    function relayout(landscape) {
        if (landscape == true) {
            containsFilesAndFolders.landscape = true
            cloudPath.landscape = true
            roomId.landscape = true
            roomName.landscape = true
            subroomId.landscape = true
            subroomName.landscape = true
            folderPath.landscape = true
        } else {
            containsFilesAndFolders.landscape = true
            cloudPath.landscape = false
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
    }
}
