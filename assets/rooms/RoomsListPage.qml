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

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/


Page {
    id: roomsListPage
    signal openCamera()
    actions: [
        //TODO only for Admins
        ActionItem {
            title: qsTr("New Folder")
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO push NewRoom Sheet
                
            }
        },
        ActionItem {
            id: refreshAction
            title: qsTr("Refresh")
            imageSource: "asset:///images/ics/1-navigation-refresh81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO call server
                
            }
        },
        ActionItem {
            title: qsTr("Select Document")
            imageSource: "asset:///images/ics/4-collections-view-as-list81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Image")
            imageSource: "asset:///images/ics/5-content-picture81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Video")
            imageSource: "asset:///images/ics/10-device-access-video81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Open Camera")
            imageSource: "asset:///images/ics/10-device-access-camera81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // SIGNAL
                console.debug("clicked open camera action")
                roomsListPage.openCamera()
            }
        },
        ActionItem {
            title: qsTr("Record Audio")
            imageSource: "asset:///images/ics/10-device-access-mic81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        }
    ]
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
            leadingVisual:{
                    // TODO waiting for bugfix
                }
            
            // define the appearance
            listItemComponents: [
                ListItemComponent {
                    type: "subroomsItem"
                    RoomsItem {
                        id: subroomsItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: "ODS Subroom"
                                ActionItem {
                                    title: "Info"
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
                    RoomsItem {
                        id: foldersItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: "ODS Folder"
                                ActionItem {
                                    title: "Info"
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Copy"
                                    imageSource: "asset:///images/ics/5-content-copy81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Move"
                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Rename"
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                deleteAction: DeleteActionItem {
                                    title: "Delete"
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
                    RoomsItem {
                        id: filesItem
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: "ODS File"
                                ActionItem {
                                    title: "View"
                                    imageSource: "asset:///images/ics/2-action-search81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Info"
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Copy"
                                    imageSource: "asset:///images/ics/5-content-copy81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Move"
                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Rename"
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Download"
                                    imageSource: "asset:///images/ics/9-av-download81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                ActionItem {
                                    title: "Link"
                                    imageSource: "asset:///images/ics/4-collections-labels81.png"
                                    onTriggered: {
                                        // TODO
                                    }
                                }
                                deleteAction: DeleteActionItem {
                                    title: "Delete"
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
                        "lastEditedBy": "",
                        "fileSize": "",
                        "fileType": "",
                        "timestamp": "",
                        "icon": "../images/subrooms-icon.png"
                    });
                mockupModel.insert({
                        "name": "Schwabing",
                        "displayType": "F",
                        "lastEditedBy": "",
                        "fileSize": "",
                        "fileType": "",
                        "timestamp": "",
                        "icon": "../images/folders-icon.png"
                    });
                mockupModel.insert({
                        "name": "Orders",
                        "displayType": "L",
                        "lastEditedBy": "Max Mustermann",
                        "fileSize": "12.234 MB",
                        "fileType": "zip",
                        "timestamp": "2012-07-25 12:11:13",
                        "icon": "../images/files-icon.png"
                    });
                mockupModel.insert({
                        "name": "Offers",
                        "displayType": "L",
                        "lastEditedBy": "Jane Doe",
                        "fileSize": "1.650 MB",
                        "fileType": ".pdf",
                        "timestamp": "2012-08-13 10:01:00",
                        "icon": "../images/files-icon.png"
                    });
            }
        } // end ListView
    } // end Container


    // we need this and the entry in bar-descriptor to support all directions
    onCreationCompleted: {
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
    }
}// end page
