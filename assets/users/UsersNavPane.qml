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

NavigationPane {
    id: navigationPane
    Page {
        id: usersPage
        actions: [
            //TODO only for Admins
            ActionItem {
                title: qsTr("New User")
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO push NewUser Sheet
                }
            },
            ActionItem {
                title: qsTr("Refresh Users")
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
                    id: mockupUserModel
                    sortingKeys: ["name"]
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
                id: usersList
                objectName: "usersList"
                // The data model is defined in the attached object list below.
                // TODO get from Server
                dataModel: mockupUserModel
                // its the root, only single selction makes sense
                selectionMode: SelectionMode.Single
                
                // define the appearance
                listItemComponents: [
                    ListItemComponent {
                        type: "usersItem"
                        UsersItem {
                            id: usersItem
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
                    return "usersItem";
                }
                                    
                // MOCKUP DATA
                // After the list is created, add some mockup items
                // A Admin U USer
                onCreationCompleted: {
                    mockupUserModel.insert({
                            "name": "Max Mustermann",
                            "displayType": "U"
                        });
                    mockupUserModel.insert({
                            "name": "Johnny Controletti",
                            "displayType": "A"
                        });
                    mockupUserModel.insert({
                            "name": "Jane Doe",
                            "displayType": "U"
                        });
                    mockupUserModel.insert({
                            "name": "Homer Simpson",
                            "displayType": "U"
                        });
                    mockupUserModel.insert({
                            "name": "Big Lebowsky",
                            "displayType": "A"
                        });
                }
            } // end ListView
        } // end Container
    
        // we need this and the entry in bar-descriptor to support all directions
        onCreationCompleted: {
            OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        }
    } // end page
}// end navigationpane
