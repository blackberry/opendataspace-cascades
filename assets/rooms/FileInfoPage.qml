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
import bb.system 1.0

Page {
    id: fileInfoPage
    property string downloadPath: ""
    property int downloadSize: 0
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
        },
        SystemToast {
            id: workInProgress
            body: qsTr("work-in-progress please stay tuned")
            icon: "asset:///images/dialog-info114.png"
            position: SystemUiPosition.BottomCenter
            onFinished: {
                //
            }
        }
    ]
    actions: [
        ActionItem {
            id: viewAction
            title: qsTr("View") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/2-action-search81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // Calls a function that show's the image in a View from InvocationFramework
                ods.showInView(downloadPath);
            }
        },
        ActionItem {
            title: qsTr("Share Link (BBM)") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-labels81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                navigationPane.openCreateLinkPage(cloudFileId.valueText, headerId.valueText)
            }
        },
        ActionItem {
            title: qsTr("Start Chat (BBM)") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/bbm.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                ods.shareTextWithBBM(qsTr("I want to chat about: ") + Retranslate.onLanguageChanged + headerId.valueText)
            }
        },
        ActionItem {
            id: downloadAction
            title: qsTr("Download") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/download81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                odsdata.downloadFile(cloudFileId.valueText, headerId.valueText, fileInfoPage.downloadSize)
            }
        },
        ActionItem {
            title: qsTr("Rename") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-edit81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                odsdata.renameFile(cloudFileId.valueText, headerId.valueText)
                navigationPane.pop();
            }
        },
        ActionItem {
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-copy81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
                workInProgress.show()
            }
        },
        ActionItem {
            title: qsTr("Move") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-import-export81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
                workInProgress.show()
            }
        },
        DeleteActionItem {
            title: qsTr("Delete") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                odsdata.deleteFile(cloudFileId.valueText, headerId.valueText)
                navigationPane.pop();
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
                Divider {
                }
                ImageAndLabel {
                    id: headerId
                }
                Divider {
                }
                // body
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
                Divider {
                }
                CloudInfoHeader {
                }
                Divider {
                }
                LabelAndLabel {
                    id: cloudFileId
                    labelText: qsTr("File ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: cloudPath
                    labelText: qsTr("Node") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: groupId
                    labelText: qsTr("Room ID") + Retranslate.onLanguageChanged
                }
                LabelAndLabel {
                    id: groupName
                    labelText: qsTr("Room Name") + Retranslate.onLanguageChanged
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
    function setValues(data, id) {
        if (data.id != id) {
            // if the id isn't equal the file was not found
            headerId.valueText = qsTr("File not found") + Retranslate.onLanguageChanged
            return;
        }
        //if (odsdata.thumbnail(id).length > 0) {
        //    headerId.imageSource = odsdata.thumbnail(id)
        //} else {
        //    headerId.imageSource = data.displayIcon
        //}
        headerId.imageSource = data.displayIcon
        headerId.valueText = data.name
        fileSize.valueText = data.displayFileSize
        createdBy.valueText = data.createdBy
        classification.valueText = data.classification
        createdAt.valueText = data.createdAt
        expires.valueText = data.expires
        comment.valueText = data.comment
        cloudPath.valueText = odsdata.nodePath
        cloudFileId.valueText = data.id
        groupId.valueText = data.containerId
        groupName.valueText = odsdata.roomGroupName(data.containerId)
        folderPath.valueText = data.path
        viewAction.enabled = data.downloaded
        downloadPath = data.downloadPath;
        downloadSize = data.fileSize;
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
            cloudPath.landscape = true
            cloudFileId.landscape = true
            groupId.landscape = true
            groupName.landscape = true
            folderPath.landscape = true
        } else {
            fileId.landscape = false
            fileSize.landscape = false
            createdBy.landscape = false
            classification.landscape = false
            createdAt.landscape = false
            expires.landscape = false
            comment.landscape = false
            cloudPath.landscape = false
            cloudFileId.landscape = false
            groupId.landscape = false
            groupName.landscape = false
            folderPath.landscape = false
        }
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            relayout(true)
            startChat()
        }
    }
}
