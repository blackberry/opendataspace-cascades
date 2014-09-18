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
    id: subroomInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Subroom Info") + Retranslate.onLanguageChanged
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
                id: subroomInfoContainer
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
                    id: subroomId
                    labelText: qsTr("Subroom ID") + Retranslate.onLanguageChanged
                }
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
                    id: roomId
                    labelText: qsTr("Room ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: roomName
                    labelText: qsTr("Room Name") + Retranslate.onLanguageChanged
                }
                Divider {
                }
            } // end subroomInfoContainer
        } // end scroll view
    } // end main container
    // set the field values from ODSSubRoom* data
    function setValues(data, id) {
        if (data.id != id) {
            // if the id isn't equal the subroom was not found
            headerId.valueText = qsTr("Subroom not found") + Retranslate.onLanguageChanged
            return;
        }
        headerId.imageSource = data.displayIcon
        headerId.valueText = data.name
        subroomId.valueText = data.id
        containsFilesAndFolders.valueText = data.children + qsTr(" Files / Folders") + Retranslate.onLanguageChanged
        roomId.valueText = data.roomId
        roomName.valueText = odsdata.roomGroupName(data.roomId)
    }
    // the subroomId we got from context action of ListItem
    function refreshData(id) {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.subroomFromId(id), id)
    }
    // relayout if orientation changes
    function relayout(landscape) {
        if (landscape == true) {
            containsFilesAndFolders.landscape = true
            roomId.landscape = true
            roomName.landscape = true
            subroomId.landscape = true
        } else {
            containsFilesAndFolders.landscape = true
            roomId.landscape = false
            roomName.landscape = false
            subroomId.landscape = false
        }
    }
    onCreationCompleted: {
        // initialize positioning
        if (!ods.isPassport() && OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
        }
    }
}
