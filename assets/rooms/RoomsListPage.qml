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
    actions: [
        //TODO only for Admins
        ActionItem {
            title: qsTr("New Folder")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO push NewRoom Sheet
            }
        },
        ActionItem {
            title: qsTr("Refresh Data Rooms")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Document")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Image")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Select Video")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Open Camera")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // TODO call server
            }
        },
        ActionItem {
            title: qsTr("Record Audio")
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
                
            // define the appearance
            listItemComponents: [
                ListItemComponent {
                    type: "subroomsItem"
                    RoomsItem {
                        id: subroomsItem
                    }
                },
                ListItemComponent {
                    type: "foldersItem"
                    RoomsItem {
                        id: foldersItem
                    }
                },
                ListItemComponent {
                    type: "filesItem"
                    RoomsItem {
                        id: filesItem
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
                        "displayType": "S"
                    });
                mockupModel.insert({
                        "name": "Schwabing",
                        "displayType": "F"
                    });
                mockupModel.insert({
                        "name": "Orders",
                        "displayType": "L"
                    });
                mockupModel.insert({
                        "name": "Offers",
                        "displayType": "L"
                    });
            }
        } // end ListView
    } // end Container
    
    // we need this and the entry in bar-descriptor to support all directions
    onCreationCompleted: {
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
    }
}// end page
