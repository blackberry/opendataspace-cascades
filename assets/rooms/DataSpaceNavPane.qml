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
import "../documents"

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
        AudioRecordPage {
            id: audioRecordPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        audioRecordPage.closeODSAudio();
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
        },
        DocumentsPreviewPage {
            id: documentsPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        PdfPreviewPage {
            id: pdfPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        ZipPreviewPage {
            id: zipPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        UnknownPreviewPage {
            id: unknownPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        AddFolderPage {
            id: addFolderPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        }
    ]
    // the ROOT Page of this NavigationPane
    Page {
        id: dataspacePage
        actions: [
            //TODO only for Admins
            ActionItem {
                title: qsTr("New Room") + Retranslate.onLanguageChanged
                enabled: false
                imageSource: "asset:///images/ics/4-collections-cloud_newLabel81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO push NewRoom Sheet
                }
            },
            ActionItem {
                title: qsTr("Refresh") + Retranslate.onLanguageChanged
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
                // TODO selectionMode: SelectionMode.Single

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
                        roomsListPage.headerTitle = mockupModel.data(indexPath).name
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
        function openRecordAudioPage() {
            console.debug("got signal to open Audiorecorder")
            console.debug("push Audiorecorder")
            navigationPane.push(audioRecordPage)
            console.debug("opened Audiorecorder")
        }
        function previewImage(path) {
            console.debug("got signal to preview image: " + path)
            imagePreviewPage.previewPath = path;
            navigationPane.push(imagePreviewPage)
        }
        function previewVideo(path) {
            console.debug("got signal to preview video: " + path)
            videoPreviewPage.previewPath = path;
            videoPreviewPage.recalculateValues(path);
            navigationPane.push(videoPreviewPage)
        }
        function previewDocuments(path) {
            console.debug("got signal to preview documents: " + path)
            documentsPreviewPage.previewPath = path;
            documentsPreviewPage.recalculateValues(path);
            navigationPane.push(documentsPreviewPage)
        }
        function previewPdf(path) {
            console.debug("got signal to preview PDF: " + path)
            pdfPreviewPage.previewPath = path;
            pdfPreviewPage.recalculateValues(path);
            navigationPane.push(pdfPreviewPage)
        }
        function previewZip(path) {
            console.debug("got signal to preview video: " + path)
            zipPreviewPage.previewPath = path;
            zipPreviewPage.recalculateValues(path);
            navigationPane.push(zipPreviewPage)
        }
        function previewUnknown(path) {
            console.debug("got signal to preview video: " + path)
            unknownPreviewPage.previewPath = path;
            unknownPreviewPage.recalculateValues(path);
            navigationPane.push(unknownPreviewPage)
        }
        function onOpenAddFolder() {
            console.debug("got signal to open AddFolderPage")
            navigationPane.push(addFolderPage)
        }
        function folderAdded(name) {
            console.debug("got signal to add a new folder: " + name)
            roomsListPage.addFolder(name)
        }

        // we need this and the entry in bar-descriptor to support all directions
        onCreationCompleted: {
            // OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
            //-- connect the RoomsList openCamera SIGNAL to the handler SLOT
            roomsListPage.openCamera.connect(openCameraPage)
            //-- connect the CameraCapturePage previewImage SIGNAL to the handler SLOT
            // same for Roomslist
            cameraCapturePage.previewImage.connect(previewImage)
            roomsListPage.previewImage.connect(previewImage)
            //-- connect the RoomsList openVideo SIGNAL to the handler SLOT
            roomsListPage.openVideo.connect(openVideoCameraPage)
            //-- connect the VideoCameraCapturePage previewVideo SIGNAL to the handler SLOT
            // same for Rooms List
            videoCapturePage.previewVideo.connect(previewVideo)
            roomsListPage.previewVideo.connect(previewVideo)
            // some more previews:
            roomsListPage.previewDocuments.connect(previewDocuments)
            roomsListPage.previewPdf.connect(previewPdf)
            roomsListPage.previewZip.connect(previewZip)
            roomsListPage.previewUnknown.connect(previewUnknown)
            //-- connect the RoomsList onOpenAddFolder SIGNAL to the handler SLOT
            roomsListPage.openAddFolder.connect(onOpenAddFolder)
            //-- connect the onFolderAdded SIGNAL from AddFolderPage with SLOT folderAdded
            addFolderPage.onFolderAdded.connect(folderAdded)
            //-- connect the RoomsList recordAudio SIGNAL to the handler SLOT
            roomsListPage.recordAudio.connect(openRecordAudioPage)
        }
    } // end page
}// end navigationpane
