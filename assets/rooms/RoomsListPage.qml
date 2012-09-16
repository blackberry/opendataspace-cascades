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
import Dialog.FileBrowse 1.0
import FileInfo 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    id: roomsListPage
    signal openCamera()
    signal openVideo()
    signal onOpenAddFolder()
    property alias headerTitle : theBar.title
    attachedObjects: [
        // native FileBrowsing Dialog
        FileBrowseDialog {
            id: filebrowseDialog
            multiselect: false
            // filters set from ActionItem
            onSelectionCompleted: {
                // TODO need more infos from file (size, timestamp, ...)
                if (filebrowseDialog.filepaths.length > 0) addFile(filebrowseDialog.filepaths[0]); 
                // else filebrowseDialogLabel.text = qsTr("no file selected") + Retranslate.onLanguageChanged;
            }
            onSelectionCancelled: {
                // filebrowseDialogLabel.text = qsTr("browsing files cancelled") + Retranslate.onLanguageChanged;
            }
        },
        // FileInfo
        FileInfo {
            id: fileInfo
        }
    ]
    actions: [
        //TODO only for Admins
        ActionItem {
            title: qsTr("New SubRoom") + Retranslate.onLanguageChanged
            enabled: false
            imageSource: "asset:///images/ics/4-collections-cloud_newLabel81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO push NewSubRoom Sheet
            }
        },
        ActionItem {
            title: qsTr("New Folder") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-collection_newlabel81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                roomsListPage.onOpenAddFolder()
            }
        },
        ActionItem {
            id: refreshAction
            title: qsTr("Refresh") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/1-navigation-refresh81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Document") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-view-as-list81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // native FileDialog from c++
                filebrowseDialog.filters = [
                    "*.doc",
                    "*.ppt",
                    "*.txt",
                    "*.ptx"
                ]
                filebrowseDialog.show();
            }
        },
        ActionItem {
            title: qsTr("Select Image") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-picture81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // native FileDialog from c++
                filebrowseDialog.filters = [
                    "*.jpg",
                    "*.jpeg",
                    "*.png"
                ]
                filebrowseDialog.show();
            }
        },
        ActionItem {
            title: qsTr("Select Video") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-video81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // native FileDialog from c++
                filebrowseDialog.filters = [
                    "*.mp4",
                    "*.mov"
                ]
                filebrowseDialog.show();
            }
        },
        ActionItem {
            title: qsTr("Open Camera") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-camera81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // SIGNAL
                console.debug("clicked open camera action")
                roomsListPage.openCamera()
            }
        },
        ActionItem {
            title: qsTr("Record Video") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-video81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // SIGNAL
                console.debug("clicked record Video action")
                roomsListPage.openVideo()
            }
        },
        ActionItem {
            title: qsTr("Record Audio") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-mic81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO
            }
        }
    ]
    titleBar: TitleBar {
        id: theBar
        title: qsTr("DataRoom")
        visibility: ChromeVisibility.Visible
    }
    content: Container {
        id: listContainer
        layout: DockLayout {
        }
        // attached objects
        attachedObjects: [
            // M O D E L
            // Mockup Datamodel
            // TODO from Server / JSON / MySQL
            GroupDataModel {
                id: mockupModel
                sortingKeys: [
                    "name"
                ]
                onItemAdded: {
                }
                onItemRemoved: {
                }
                onItemUpdated: {
                }
            }
        ]
        
        // V I E W
        ListView {
            id: dataspaceList
            objectName: "roomsList"
            // The data model is defined in the attached object list below.
            // TODO get from Server
            dataModel: mockupModel
            // its the root, only single selction makes sense
            selectionMode: SelectionMode.Single
            leadingVisual: {
                // TODO waiting for bugfix
            }
            
            // define the appearance
            listItemComponents: [
                ListItemComponent {
                    type: "subroomsItem"
                    SubRoomsItem {
                        id: subroomsItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS Subroom") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                            }
                        ]
                    }
                },
                ListItemComponent {
                    type: "foldersItem"
                    FoldersItem {
                        id: foldersItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS Folder") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-copy81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Move") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Rename") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                deleteAction: DeleteActionItem {
                                    title: qsTr("Delete") + Retranslate.onLanguageChanged
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                            }
                        ]
                    }
                },
                ListItemComponent {
                    type: "filesItem"
                    FilesItem {
                        id: filesItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS File") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: qsTr("View") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-search81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-copy81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Move") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Rename") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Download") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/9-av-download81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Link") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/4-collections-labels81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                deleteAction: DeleteActionItem {
                                    title: qsTr("Delete") + Retranslate.onLanguageChanged
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                            }
                        ]
                    }
                },
                ListItemComponent {
                    type: "header"
                    Container {
                        // nothing yet
                    }
                }
            ]
            function itemType(data, indexPath) {
                if (data.displayType == "S") {
                    return "subroomsItem";
                }
                if (data.displayType == "F") {
                    return "foldersItem";
                }
                if (data.displayType == "L") {
                    return "filesItem";
                }
                return "header";
            }
                                    
            // MOCKUP DATA
            // After the list is created, add some mockup items
            onCreationCompleted: {
                mockupModel.insert({
                        "name": "Berlin",
                        "displayType": "S",
                        "numberOfFiles": 3,
                        "lastEditedBy": "",
                        "fileSize": "2.320.412",
                        "fileType": "",
                        "timestamp": "",
                        "icon": "../images/subrooms-icon.png"
                    });
                mockupModel.insert({
                        "name": "Schwabing",
                        "displayType": "F",
                        "numberOfFiles": 1,
                        "lastEditedBy": "",
                        "fileSize": "11.350.200",
                        "fileType": "",
                        "timestamp": "",
                        "icon": "../images/folders-icon.png"
                    });
                mockupModel.insert({
                        "name": "Orders",
                        "displayType": "L",
                        "lastEditedBy": "Max Mustermann",
                        "fileSize": "12.234.000",
                        "fileType": "zip",
                        "timestamp": "2012-07-25 12:11:13",
                        "icon": "../images/files-icon.png"
                    });
                mockupModel.insert({
                        "name": "Offers",
                        "displayType": "L",
                        "lastEditedBy": "Jane Doe",
                        "fileSize": "1.650.000",
                        "fileType": "pdf",
                        "timestamp": "2012-08-13 10:01:00",
                        "icon": "../images/files-icon.png"
                    });
            }
        } // end ListView
    } // end Container
    function addFolder(name) {
        console.debug("Now add new FOLDER to LISTMODEL on RoomsListPage")
        mockupModel.insert({
                "name": name,
                "displayType": "F",
                "numberOfFiles": 0,
                "lastEditedBy": "",
                "fileSize": "0",
                "fileType": "",
                "timestamp": "",
                "icon": "../images/folders-icon.png"
            })
    }
    // TODO must go to UPLOAD
    function addFile(name) {
        console.debug("Now add new FILE to LISTMODEL on RoomsListPage")
        mockupModel.insert({
                "name": fileInfo.getShortName(name),
                "displayType": "L",
                "lastEditedBy": "BlackBerry",
                "fileSize": fileInfo.getSizeAsString(ods.getCurrentLocale(), name),
                "fileType": fileInfo.getSuffix(name),
                "timestamp": fileInfo.getLastModifiedAsShortString(ods.getCurrentLocale(), name),
                "icon": "../images/files-icon.png"
            })
    }

    // we need this and the entry in bar-descriptor to support all directions
    onCreationCompleted: {
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
    }
}// end page
