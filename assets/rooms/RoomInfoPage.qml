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
    id: roomInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Data Room Info") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    attachedObjects: [
        // recalculate positions
        OrientationHandler {
            onOrientationAboutToChange: {
                if(ods.isPassport()){
                    return 
                }
                if (orientation == UIOrientation.Landscape) {
                    relayout(true)
                } else {
                    relayout(false)
                }
            }
        }
    ]
    actions: [
    ]
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        ScrollView {
            //
            Container {
                id: roomInfoContainer
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
                    id: roomId
                    labelText: qsTr("Room ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: containsFilesAndFolders
                    labelText: qsTr("contains") + Retranslate.onLanguageChanged
                }
                Divider {
                }
            } // end roomInfoContainer
        } // end scroll view
    } // end main container
    // set the field values from ODSRoom* data
    function setValues(data, id) {
        console.debug("RoomInfoPage setValues for id: " + id)
        if (data.id != id) {
            // if the id isn't equal the room was not found
            headerId.valueText = qsTr("Room not found") + Retranslate.onLanguageChanged
            return;
        }
        headerId.imageSource = data.displayIcon
        headerId.valueText = data.name
        roomId.valueText = data.id
        containsFilesAndFolders.valueText = data.children + qsTr(" Files / Folders") + Retranslate.onLanguageChanged
    }
    // the roomId we got from context action of ListItem
    function refreshData(id) {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        console.debug("RoomInfoPage refreshData for id: " + id)
        setValues(odsdata.roomFromId(id), id)
    }
    // relayout if orientation changes
    function relayout(landscape) {
        if (landscape == true) {
            containsFilesAndFolders.landscape = true
            roomId.landscape = true
        } else {
            containsFilesAndFolders.landscape = true
            roomId.landscape = false
        }
    }
    onCreationCompleted: {
        // initialize positioning
        if (!ods.isPassport() && OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
        }
    }
}
