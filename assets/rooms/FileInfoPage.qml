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
    id: fileInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("File Info") + Retranslate.onLanguageChanged
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
            title: qsTr("View") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/2-action-search81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-copy81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Move") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-import-export81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Rename") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-edit81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Download") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/download81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO
            }
        },
        ActionItem {
            title: qsTr("Link") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-labels81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        },
        DeleteActionItem {
            title: qsTr("Delete") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.InOverflow
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
                id: fileInfoContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                }
                leftPadding: 40
                rightPadding: 40
                // header
                ImageAndLabel {
                    id: headerId
                }
                // body
                LabelAndLabel {
                    id: fileId
                    labelText: qsTr("Id") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: fileSize
                    labelText: qsTr("Size") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: createdBy
                    labelText: qsTr("Created by user") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: classification
                    labelText: qsTr("Classification") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: createdAt
                    labelText: qsTr("Date created") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: expires
                    labelText: qsTr("Expiration date") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: comment
                    labelText: qsTr("Comment") + Retranslate.onLanguageChanged
                }
            } // end fileInfoContainer
        } // end scroll view
    } // end main container
    // set the field values from ODSFile* data
    function setValues(data, id) {
        if (data.id != id) {
            // if the id isn't equal the file was not found
            headerId.valueText = qsTr("File not found") + Retranslate.onLanguageChanged
            return;
        }
        headerId.imageSource = data.displayIcon
        headerId.valueText = data.name
        fileId.valueText = data.id
        fileSize.valueText = data.fileSize + " Bytes"
        createdBy.valueText = data.createdBy
        classification.valueText = data.classification
        createdAt.valueText = data.createdAt
        expires.valueText = data.expires
        comment.valueText = data.comment
    }
    // the fileId we got from context action of ListItem
    function refreshData(id) {
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.fileFromId(id), id)
    }
    // relayout if orientation changes
    function relayout(landscape) {
        if (landscape == true) {
            fileId.landscape = true
            fileSize.landscape = true
            createdBy.landscape = true
            classification.landscape = true
            createdAt.landscape = true
            expires.landscape = true
            comment.landscape = true
        } else {
            fileId.landscape = false
            fileSize.landscape = false
            createdBy.landscape = false
            classification.landscape = false
            createdAt.landscape = false
            expires.landscape = false
            comment.landscape = false
        }
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
        }
    }
}
