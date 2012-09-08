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
                        cameraCapturePage.closeODSCamera();
                        navigationPane.pop();
                    }
                }
            }
        },
        VideoCapturePage {
            id: videoCapturePage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        videoCapturePage.closeODSVideo();
                        navigationPane.pop();
                    }
                }
            }
        },
        ImagePreviewPage {
            id: imagePreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        VideoPreviewPage {
            id: videoPreviewPage
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
                imageSource: "asset:///images/ics/5-content-new81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO push NewRoom Sheet
                }
            },
            ActionItem {
                title: qsTr("Refresh")
                imageSource: "asset:///images/ics/1-navigation-refresh81.png"
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
        // SLOTS
        function openCameraPage() {
            console.debug("got signal to open camera")
            cameraCapturePage.openODSCamera()
            console.debug("push CameraCapturePage")
            navigationPane.push(cameraCapturePage)
            console.debug("openedCamera")
        }
        function openVideoCameraPage() {
            console.debug("got signal to open VIDEOcamera")
            videoCapturePage.openODSVideo()
            console.debug("push VideoCapturePage")
            navigationPane.push(videoCapturePage)
            console.debug("openedVIDEOCamera")
        }
        function previewImage(path) {
            console.debug("got signal to preview image: " + path)
            imagePreviewPage.previewPath = path;
            navigationPane.push(imagePreviewPage)
        }
        function previewVideo(path) {
            console.debug("got signal to preview video: " + path)
            videoPreviewPage.previewPath = path;
            navigationPane.push(videoPreviewPage)
        }
    
        // we need this and the entry in bar-descriptor to support all directions
        onCreationCompleted: {
            OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
            //-- connect the RoomsList openCamera SIGNAL to the handler SLOT
            roomsListPage.openCamera.connect(openCameraPage)
            //-- connect the CameraCapturePage previewImage SIGNAL to the handler SLOT
            cameraCapturePage.previewImage.connect(previewImage)
            console.debug("CameraCapturePage CONNECTED")
            //-- connect the RoomsList openVideo SIGNAL to the handler SLOT
            roomsListPage.openVideo.connect(openVideoCameraPage)
            //-- connect the VideoCameraCapturePage previewVideo SIGNAL to the handler SLOT
            videoCapturePage.previewVideo.connect(previewVideo)
            console.debug("VideoCapturePage CONNECTED")
        }
    } // end page
}// end navigationpane
