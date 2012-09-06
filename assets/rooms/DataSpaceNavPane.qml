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
import "../media"

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

NavigationPane {
    id: navigationPane
    attachedObjects: [
        RoomsListPage {
            id: roomsListPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        CameraCapturePage {
            id: cameraCapturePage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        }
    ]
    Page {
        id: dataspacePage
        actions: [
            //TODO only for Admins
            ActionItem {
                title: qsTr("New Room")
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO push NewRoom Sheet
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
                objectName: "dataspaceList"
                // The data model is defined in the attached object list below.
                // TODO get from Server
                dataModel: mockupModel
                // its the root, only single selction makes sense
                selectionMode: SelectionMode.Single
                
                // define the appearance
                listItemComponents: [
                    ListItemComponent {
                        type: "roomsItem"
                        RoomsItem {
                            id: roomsItem
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
                    if (data.displayType == "R") {
                        return "roomsItem";
                    } else {
                        return "header";
                    }
                }
                onTriggered: {
                    // TODO set the datamodel depending on path
                    if (selected) {
                        navigationPane.push(roomsListPage)
                    }
                }

                // MOCKUP DATA
                // After the list is created, add some mockup items
                onCreationCompleted: {
                    mockupModel.insert({
                            "name": "Department Italy",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department Spain",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department Canada",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department Germany",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department Austria",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department Denmark",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                    mockupModel.insert({
                            "name": "Department France",
                            "displayType": "R",
                            "lastEditedBy": "",
                            "fileSize": "",
                            "fileType": "",
                            "timestamp": "",
                            "icon": "../images/rooms-icon.png"
                        });
                }
            } // end ListView
        } // end Container
        // SLOT
        function openCameraPage() {
            console.debug("got signal to open camera")
            navigationPane.push(cameraCapturePage)
            console.debug("openCamera")
             ods.openCamera()
        }
    
        // we need this and the entry in bar-descriptor to support all directions
        onCreationCompleted: {
            OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
            //-- connect the RoomsList openCamera SIGNAL to the handler SLOT
            roomsListPage.openCamera.connect(openCameraPage)
            
        }
    } // end page
}// end navigationpane
