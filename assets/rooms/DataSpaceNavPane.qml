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
                        if (odsdata.showPreviousNode()) {
                            roomsListPage.headerTitle = odsdata.nodeTitleName()
                        } else {
                            navigationPane.pop();
                        }
                    }
                }
            }
        },
        DictaphonePage {
            id: audioRecordPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        // audioRecordPage.closeODSAudio();
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
        VoicePreviewPage {
            id: recordedVoicePreviewPage
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
        HtmlPreviewPage {
            id: htmlPreviewPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        BooksPreviewPage {
            id: booksPreviewPage
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
        },
        // FileInfo
        FileInfoPage {
            id: fileInfoPage
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
            ActionItem {
                title: qsTr("Sync with Server") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/1-navigation-refresh81.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    // TODO call server
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
                GroupDataModel {
                    id: roomGroupDataModel
                    objectName: "roomGroupDataModel"
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
                dataModel: roomGroupDataModel
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
                    if (selected) {
                        roomsListPage.headerTitle = roomGroupDataModel.data(indexPath).name
                        // fill the model with the nodes
                        odsdata.resetLevel();
                        odsdata.showNextNode(roomGroupDataModel.data(indexPath).nodes, roomGroupDataModel.data(indexPath).name)
                        navigationPane.push(roomsListPage)
                    }
                }

                // MOCKUP DATA
                // After the list is created, add some mockup items
                onCreationCompleted: {
                }
            } // end ListView
        } // end Container
    } // end page
    // SLOTS
    function openRecordAudioPage() {
        console.debug("got signal to open Audiorecorder")
        console.debug("push Audiorecorder")
        navigationPane.push(audioRecordPage)
        console.debug("opened Audiorecorder")
    }
    function previewImage(path) {
        console.debug("got signal to preview image: " + path)
        imagePreviewPage.previewPath = path;
        imagePreviewPage.recalculateValues(path);
        navigationPane.push(imagePreviewPage)
    }
    function previewVideo(path) {
        console.debug("got signal to preview video: " + path)
        videoPreviewPage.previewPath = path;
        videoPreviewPage.recalculateValues(path);
        navigationPane.push(videoPreviewPage)
    }
    function previewRecordedVoice(path) {
        console.debug("got signal to preview recordedVoice: " + path)
        recordedVoicePreviewPage.previewPath = path;
        recordedVoicePreviewPage.recalculateValues(path);
        navigationPane.push(recordedVoicePreviewPage)
    }
    function previewDocuments(path) {
        console.debug("got signal to preview documents: " + path)
        documentsPreviewPage.previewPath = path;
        documentsPreviewPage.recalculateValues(path);
        navigationPane.push(documentsPreviewPage)
    }
    function previewHtml(path) {
        console.debug("got signal to preview HTML: " + path)
        htmlPreviewPage.previewPath = path;
        htmlPreviewPage.recalculateValues(path);
        navigationPane.push(htmlPreviewPage)
    }
    function previewBooks(path) {
        console.debug("got signal to preview books: " + path)
        booksPreviewPage.previewPath = path;
        booksPreviewPage.recalculateValues(path);
        navigationPane.push(booksPreviewPage)
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
    function openFileInfoPage(id) {
            console.debug("got signal to open FileInfoPage")
            fileInfoPage.refreshData(id)
            navigationPane.push(fileInfoPage)
        }
    onTopChanged: {
        if (navigationPane.top == dataspacePage) {
            odsdata.resetLevel();
        }
    }
    onCreationCompleted: {
        //-- connect the RoomsList openCamera SIGNAL to the handler SLOT
        // same for Roomslist
        //cameraCapturePage.previewImage.connect(previewImage)
        roomsListPage.previewImage.connect(previewImage)
        // same for Rooms List
        //videoCapturePage.previewVideo.connect(previewVideo)
        roomsListPage.previewVideo.connect(previewVideo)
        // some more previews:
        roomsListPage.previewDocuments.connect(previewDocuments)
        roomsListPage.previewHtml.connect(previewHtml)
        roomsListPage.previewBooks.connect(previewBooks)
        roomsListPage.previewPdf.connect(previewPdf)
        roomsListPage.previewZip.connect(previewZip)
        roomsListPage.previewUnknown.connect(previewUnknown)
        //-- connect the RoomsList onOpenAddFolder SIGNAL to the handler SLOT
        roomsListPage.openAddFolder.connect(onOpenAddFolder)
        //
        roomsListPage.openFileInfoPage.connect(openFileInfoPage)
        //-- connect the onFolderAdded SIGNAL from AddFolderPage with SLOT folderAdded
        addFolderPage.onFolderAdded.connect(folderAdded)
        //-- connect the RoomsList recordAudio SIGNAL to the handler SLOT
        roomsListPage.recordAudio.connect(openRecordAudioPage)
        console.debug("NavigationPane DtaSpaces created ")
    }
}// end navigationpane
