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
import bb.system 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    id: roomsListPage
    signal recordAudio()
    signal openAddFolder()
    signal openFileInfoPage(int fileId)
    signal openFolderInfoPage(string name)
    signal openSubRoomInfoPage(int subroomId)
    signal openCreateLinkPage(int id, string name)
    signal openCreateMailLinkPage(int id, string name)
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
        },
        SystemToast {
            id: workInProgress
            body: qsTr("work-in-progress please stay tuned")
            icon: "asset:///images/dialog-info114.png"
            position: SystemUiPosition.BottomCenter
            onFinished: {
                //
            }
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Create Folder") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/new-folder81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                roomsListPage.openAddFolder()
            }
        },
        ActionItem {
            id: refreshAction
            title: qsTr("Sync with Server") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/1-navigation-refresh81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                odsdata.syncWithServer()
            }
        },
        ActionItem {
            title: qsTr("Select Document") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/file81.png"
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
            imageSource: "asset:///images/image81.png"
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
            imageSource: "asset:///images/video81.png"
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
            imageSource: "asset:///images/audio81.png"
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
            imageSource: "asset:///images/recording81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                // SIGNAL
                console.debug("clicked Dictaphone action")
                roomsListPage.recordAudio()
            }
        },
        ActionItem {
            title: qsTr("Select Music") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/musicplayer81.png"
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
            imageSource: "asset:///images/ebook81.png"
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
            imageSource: "asset:///images/file81.png"
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
                    console.debug("Item removed from Roomslist")
                }
                onItemUpdated: {
                }
            }
        ]

        // V I E W
        ListView {
            id: roomsList
            objectName: "roomsList"
            property variant selectionColor: rootNavigationPane.selectionColor
            dataModel: fileGroupDataModel
            // its the root, only single selction makes sense
            //selectionMode: SelectionMode.Single
            leadingVisual: {
                // TODO waiting for bugfix
            }
            onTriggered: {
                if (selected) {
                    roomsList.clearSelection()
                    if (fileGroupDataModel.data(indexPath).displayType != "L") {
                        // name of current Room, SubRoom, Folder
                        roomsListPage.headerTitle = fileGroupDataModel.data(indexPath).name
                        // fill the model with the nodes
                        odsdata.showNextNode(fileGroupDataModel.data(indexPath).nodes, fileGroupDataModel.data(indexPath).name)
                        // navigationPane.push(roomsListPage)
                    } else {
                        // we're only transmitting the id to avoid complex data
                        // (ODSFile* in this case)
                        // to be transported between sgnals, slots, pages, c++
                        // current level of files tree is cached at c++ so we get fast access
                        pushFileInfoPage(fileGroupDataModel.data(indexPath).id)
                    }
                    roomsList.select(indexPath,true);
                }
            }
            // define the appearance
            listItemComponents: [
                ListItemComponent {
                    type: "subroomsItem"
                    SubRoomsItem {
                        id: subroomsItem
                        backgroundVisible: ! subroomsItem.ListItem.view.isSquare()
                        selectionColor: subroomsItem.ListItem.view.selectionColor
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS Subroom") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: "RepairListItem"
                                    onTriggered: {
                                        // TODO
                                        // workaround
                                        subroomsItem.workaround()
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        subroomsItem.ListItem.view.pushSubRoomInfoPage(ListItemData.id)
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
                        backgroundVisible: ! foldersItem.ListItem.view.isSquare()
                        selectionColor: foldersItem.ListItem.view.selectionColor
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS Folder") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: "RepairListItem"
                                    onTriggered: {
                                        // TODO
                                        // workaround
                                        foldersItem.workaround()
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        foldersItem.ListItem.view.pushFolderInfoPage(ListItemData.name)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Rename") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        foldersItem.ListItem.view.renameFolder(ListItemData.containerId, ListItemData.path, ListItemData.name)
                                    }
                                }
//                                ActionItem {
//                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
//                                    imageSource: "asset:///images/ics/5-content-copy81.png"
//                                    onTriggered: {
//                                        // TODO
//                                        foldersItem.ListItem.view.wip()
//                                    }
//                                }
//                                ActionItem {
//                                    title: qsTr("Move") + Retranslate.onLanguageChanged
//                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
//                                    onTriggered: {
//                                        // TODO
//                                        foldersItem.ListItem.view.wip()
//                                    }
//                                }
                                DeleteActionItem {
                                    title: qsTr("Delete") + Retranslate.onLanguageChanged
                                    onTriggered: {
                                        if (ListItemData.path.length > 0) {
                                            foldersItem.ListItem.view.deleteFolder(ListItemData.containerId, ListItemData.path + "/" + ListItemData.name)
                                        } else {
                                            foldersItem.ListItem.view.deleteFolder(ListItemData.containerId, ListItemData.name)
                                        }
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
                        backgroundVisible: ! filesItem.ListItem.view.isSquare()
                        selectionColor: filesItem.ListItem.view.selectionColor
                        contextActions: [
                            ActionSet {
                                title: ListItemData.name
                                subtitle: qsTr("ODS File") + Retranslate.onLanguageChanged
                                ActionItem {
                                    title: "RepairListItem"
                                    onTriggered: {
                                        // TODO
                                        // workaround
                                        filesItem.workaround()
                                    }
                                }
                                ActionItem {
                                    title: qsTr("View") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-search81.png"
                                    enabled: ListItemData.downloaded
                                    onTriggered: {
                                        // TODO
                                        filesItem.ListItem.view.viewFile(ListItemData.downloadPath)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Info") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/2-action-about81.png"
                                    onTriggered: {
                                        // we're only transmitting the id to avoid complex data
                                        // (ODSFile* in this case)
                                        // to be transported between sgnals, slots, pages, c++
                                        // current level of files tree is cached at c++ so we get fast access
                                        filesItem.ListItem.view.pushFileInfoPage(ListItemData.id)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Share Link (BBM)") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/4-collections-labels81.png"
                                    onTriggered: {
                                        filesItem.ListItem.view.createLink(ListItemData.id, ListItemData.name)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Share Link (Mail)") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-email81.png"
                                    onTriggered: {
                                        filesItem.ListItem.view.createMailLink(ListItemData.id, ListItemData.name)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Download") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/download81.png"
                                    onTriggered: {
                                        filesItem.ListItem.view.downloadFile(ListItemData.id, ListItemData.name, ListItemData.fileSize)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Rename") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-edit81.png"
                                    onTriggered: {
                                        filesItem.ListItem.view.renameFile(ListItemData.id, ListItemData.name)
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-copy81.png"
                                    onTriggered: {
                                        // TODO
                                        filesItem.ListItem.view.wip()
                                    }
                                }
                                ActionItem {
                                    title: qsTr("Move") + Retranslate.onLanguageChanged
                                    imageSource: "asset:///images/ics/5-content-import-export81.png"
                                    onTriggered: {
                                        // TODO
                                        filesItem.ListItem.view.wip()
                                    }
                                }
                                DeleteActionItem {
                                    title: qsTr("Delete") + Retranslate.onLanguageChanged
                                    onTriggered: {
                                        filesItem.ListItem.view.deleteFile(ListItemData.id, ListItemData.name)
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
            onCreationCompleted: {
            }
            // ListView functions
            function pushFileInfoPage(id) {
                openFileInfoPage(id)
            }
            function pushFolderInfoPage(name) {
                openFolderInfoPage(name)
            }
            function pushSubRoomInfoPage(id) {
                openSubRoomInfoPage(id)
            }
            function downloadFile(id, name, size) {
                odsdata.downloadFile(id, name, size)
            }
            function deleteFile(id, name) {
                odsdata.deleteFile(id, name)
            }
            function deleteFolder(roomId, path) {
                odsdata.deleteFolder(roomId, path)
            }
            function renameFolder(roomId, path, name) {
                odsdata.renameFolder(roomId, path, name)
            }
            function renameFile(id, name) {
                odsdata.renameFile(id, name)
            }
            function createLink(id, name) {
                openCreateLinkPage(id, name)
            }
            function createMailLink(id, name) {
                openCreateMailLinkPage(id, name)
            }
            function wip() {
                workInProgress.show()
            }
            function viewFile(downloadPath) {
                ods.showInView(downloadPath);
            }
            function isSquare() {
                return ods.isSquare()
            }
        } // end ListView
    } // end Container
    // TODO localization: loop thru datamodel and localize datetime strings
    function deselectAll(){
        roomsList.clearSelection();
    }
}// end page
