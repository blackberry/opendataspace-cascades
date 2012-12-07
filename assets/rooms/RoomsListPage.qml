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
import org.opendataspace.fileinfo 1.0
import org.opendataspace.dateutil 1.0
import bb.cascades.pickers 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    id: roomsListPage
    signal recordAudio()
    signal openAddFolder()
    signal previewImage(string filePath)
    signal previewVideo(string path)
    signal previewDocuments(string path)
    signal previewHtml(string path)
    signal previewBooks(string path)
    signal previewPdf(string path)
    signal previewUnknown(string path)
    signal previewZip(string path)
    property alias headerTitle: theBar.title
    attachedObjects: [
        // Cascades FilePicker
        FilePicker {
            id: picker
            property string selectedFile
            title: qsTr("File Picker")
            mode: FilePickerMode.Picker // pickerMode.selectedValue
            type: FileType.Other // pickerType.selectedValue
            // TODO got reference error
            // viewMode: ViewMode.Default // pickerViewMode.selectedValue
            sortBy: FilePickerSortFlag.Default // pickerSortBy.selectedValue
            sortOrder: FilePickerSortOrder.Default // pickerSortOrder.selectedValue
            onFileSelected: {
                selectedFile = selectedFiles[0]
                // is there a preview ?
                // isImage ?
                if (fileInfo.isImage(picker.selectedFile)) {
                    console.debug("roomsListPage: an image was picked")
                    roomsListPage.previewImage(picker.selectedFile);
                    return;
                }
                // isVideo ?
                if (fileInfo.isVideo(picker.selectedFile)) {
                    roomsListPage.previewVideo(picker.selectedFile);
                    return;
                }
                // isAudio ?
                if (fileInfo.isAudio(picker.selectedFile)) {
                    navigationPane.previewRecordedVoice(picker.selectedFile)
                    return;
                }
                // isPDF ?
                if (fileInfo.getSuffix(picker.selectedFile) == "pdf") {
                    roomsListPage.previewPdf(picker.selectedFile);
                    return;
                }
                // isHtml ?
                if (fileInfo.isHtml(picker.selectedFile)) {
                    roomsListPage.previewHtml(picker.selectedFile);
                    return;
                }
                // isZIP ?
                if (fileInfo.isCompressed(picker.selectedFile)) {
                    roomsListPage.previewZip(picker.selectedFile);
                    return;
                }
                // isDocument ?
                if (fileInfo.isDocument(picker.selectedFile)) {
                    roomsListPage.previewDocuments(picker.selectedFile);
                    return;
                }
                // isBook ?
                if (fileInfo.isBook(picker.selectedFile)) {
                    // TODO previewBookPage
                    roomsListPage.previewBooks(picker.selectedFile);
                    return;
                }
                // else is unknown filytype
                roomsListPage.previewUnknown(picker.selectedFile);
                // OLD addFile(filebrowseDialog.filepaths[0]);
                // else filebrowseDialogLabel.text = qsTr("no file selected") + Retranslate.onLanguageChanged;
            }
        },
        // FileInfo
        FileInfo {
            id: fileInfo
        },
        // DateUtil
        DateUtil {
            id: dateUtil
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("New Folder") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-collection_newlabel81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                roomsListPage.openAddFolder()
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
                picker.title = qsTr("Select Document")
                picker.type = FileType.Document
                picker.directories = [
                ]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Select | Capture Image") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-picture81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select Image")
                picker.type = FileType.Picture
                picker.directories = [
                ]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Select | Capture Video") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-video81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select Video")
                picker.type = FileType.Video
                picker.directories = [
                ]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Select Voice") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-volume-on81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select Recorded Voice")
                picker.type = FileType.Other
                picker.directories = [
                    "/accounts/1000/shared/voice",
                    "/accounts/1000/shared/downloads"
                ]
                // picker.filter = ["*.m4a"]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Dictaphone") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-mic81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // SIGNAL
                console.debug("clicked Dictaphone action")
                roomsListPage.recordAudio()
            }
        },
        ActionItem {
            title: qsTr("Select Music") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/9-av-play81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select Music")
                picker.type = FileType.Music
                picker.directories = [
                ]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Select Book") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-view-as-list81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select Book")
                picker.type = FileType.Other
                picker.directories = [
                    "/accounts/1000/shared/books"
                ]
                picker.open();
            }
        },
        ActionItem {
            title: qsTr("Select Other File") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/4-collections-view-as-list81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                picker.title = qsTr("Select File")
                picker.type = FileType.Other
                picker.directories = [
                ]
                picker.open();
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
                id: fileGroupDataModel
                objectName: "fileGroupDataModel"
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
            id: roomsList
            objectName: "roomsList"
            dataModel: fileGroupDataModel
            // its the root, only single selction makes sense
            //selectionMode: SelectionMode.Single
            leadingVisual: {
                // TODO waiting for bugfix
            }
            onTriggered: {
                if (selected) {
                    if (fileGroupDataModel.data(indexPath).displayType != "L") {
                        roomsListPage.headerTitle = fileGroupDataModel.data(indexPath).name
                        // fill the model with the nodes
                        odsdata.initFilesModel(fileGroupDataModel.data(indexPath).nodes)
                        // navigationPane.push(roomsListPage)
                    }
                }
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
                                        console.debug("FOLDER: name to be renamed: " + ListItemData.name)
                                        // TODO
                                        ListItemData.name = "renamed"
                                    }
                                }
                                DeleteActionItem {
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
                                DeleteActionItem {
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

            onCreationCompleted: {}
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
    // TODO localization: loop thru datamodel and localize datetime strings
}// end page
