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
                title: qsTr("Refresh")
                ActionBar.placement: ActionBarPlacement.OnBar
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
                    sortingKeys: [
                        "displayType",
                        "name"
                    ]
                    grouping: ItemGrouping.ByFullValue
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
                            contextActions: [
                                ActionSet {
                                    title: ListItemData.name
                                    subtitle: "ODS User"
                                    ActionItem {
                                        title: "Info"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: "MailTo"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: "Contact"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                }
                            ]
                        }
                    },
                    ListItemComponent {
                        type: "adminItem"
                        UsersItem {
                            id: adminItem
                            contextActions: [
                                ActionSet {
                                    title: ListItemData.name
                                    subtitle: "ODS Aministrator"
                                    ActionItem {
                                        title: "Add Room"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: "Info"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: "MailTo"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: "Contact"
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
                            layout: StackLayout {
                                layoutDirection: LayoutDirection.LeftToRight
                                leftPadding: 25
                                bottomPadding: 20
                                topPadding: 20
                            }
                            Label {
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                text: {
                                    if (ListItemData.title) {
                                        ListItemData.title
                                    } else {
                                        // If it is loaded from JSON and set in a GroupDataModel the header info in ListItemData
                                        if (ListItemData == "A") {
                                            "Administrator"
                                        } else {
                                            "User"
                                        }
                                    }
                                }
                            }
                        }
                    }
                ]
                function itemType(data, indexPath) {
                    if (data.displayType == "U") {
                        return "usersItem";
                    }
                    if (data.displayType == "A") {
                        return "adminItem";
                    }
                    return "header";
                }
                                    
                // MOCKUP DATA
                // After the list is created, add some mockup items
                // A Admin U USer
                onCreationCompleted: {
                    mockupUserModel.insert({
                            "name": "Max Mustermann",
                            "displayType": "U",
                            "icon": "../images/users-icon.png"
                        });
                    mockupUserModel.insert({
                            "name": "Johnny Controletti",
                            "displayType": "A",
                            "icon": "../images/admin-icon.png"
                        });
                    mockupUserModel.insert({
                            "name": "Jane Doe",
                            "displayType": "U",
                            "icon": "../images/users-icon.png"
                        });
                    mockupUserModel.insert({
                            "name": "Homer Simpson",
                            "displayType": "U",
                            "icon": "../images/users-icon.png"
                        });
                    mockupUserModel.insert({
                            "name": "Big Lebowsky",
                            "displayType": "A",
                            "icon": "../images/admin-icon.png"
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
