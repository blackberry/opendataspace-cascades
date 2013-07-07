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
import org.opendataspace.user 1.0
import bb.system 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

NavigationPane {
    id: usersNavigationPane
    attachedObjects: [
        AddUserPage {
            id: addUserPage
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        usersNavigationPane.pop();
                    }
                }
            }
        },
        ComponentDefinition {
            id: usersPageComponentDefinition
            //
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
    // the Root Page of this NavigationPane
    Page {
        id: usersPage
        titleBar: TitleBar {
            id: theBar
            title: qsTr("Users")
            visibility: ChromeVisibility.Visible
        }
        actions: [
            //TODO only for Admins
            ActionItem {
                title: qsTr("New User") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/new-user81.png"
                enabled: !odssettings.testdrive()
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    console.debug("now clear fields and pushing AddUserPage")
                    addUserPage.clearFields();
                    push(addUserPage)
                }
            },
            ActionItem {
                title: qsTr("Refresh") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/1-navigation-refresh81.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    odsdata.initUserModel()
                }
            }
        ]
        //
        content: Container {
            id: listContainer
            layout: DockLayout {
            }
            // attached objects
            attachedObjects: [
                GroupDataModel {
                    id: userGroupDataModel
                    objectName: "userGroupDataModel"
                    sortingKeys: [
                        "displayType",
                        "displayName"
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
                dataModel: userGroupDataModel
                property variant selectionColor: rootNavigationPane.selectionColor
                // its the root, only single selction makes sense
                // TODO selectionMode: SelectionMode.Single

                // define the appearance
                listItemComponents: [
                    ListItemComponent {
                        type: "usersItem"
                        UsersItem {
                            id: usersItem
                            backgroundVisible: usersItem.ListItem.view.hasBackgroundImage()
                            selectionColor: usersItem.ListItem.view.selectionColor
                            contextActions: [
                                ActionSet {
                                    title: ListItemData.displayName
                                    subtitle: "ODS User"
                                    ActionItem {
                                        title: qsTr("Info") + Retranslate.onLanguageChanged
                                        imageSource: "asset:///images/ics/2-action-about81.png"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: qsTr("MailTo") + Retranslate.onLanguageChanged
                                        imageSource: "asset:///images/ics/5-content-email81.png"
                                        onTriggered: {
                                            // TODO
                                        }
                                    }
                                    ActionItem {
                                        title: qsTr("Contact") + Retranslate.onLanguageChanged
                                        imageSource: "asset:///images/ics/6-social-person81.png"
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
                            backgroundVisible: adminItem.ListItem.view.hasBackgroundImage()
                            selectionColor: adminItem.ListItem.view.selectionColor
//                            contextActions: [
//                                ActionSet {
//                                    title: ListItemData.displayName
//                                    subtitle: "ODS Aministrator"
//                                    ActionItem {
//                                        title: qsTr("Add Room") + Retranslate.onLanguageChanged
//                                        imageSource: "asset:///images/new-folder81.png"
//                                        onTriggered: {
//                                            // TODO
//                                        }
//                                    }
//                                    ActionItem {
//                                        title: qsTr("Info") + Retranslate.onLanguageChanged
//                                        imageSource: "asset:///images/ics/2-action-about81.png"
//                                        onTriggered: {
//                                            // TODO
//                                        }
//                                    }
//                                    ActionItem {
//                                        title: qsTr("MailTo") + Retranslate.onLanguageChanged
//                                        imageSource: "asset:///images/ics/5-content-email81.png"
//                                        onTriggered: {
//                                            // TODO
//                                        }
//                                    }
//                                    ActionItem {
//                                        title: qsTr("Contact") + Retranslate.onLanguageChanged
//                                        imageSource: "asset:///images/ics/6-social-person81.png"
//                                        onTriggered: {
//                                            // TODO
//                                        }
//                                    }
//                                    DeleteActionItem {
//                                        title: qsTr("Delete") + Retranslate.onLanguageChanged
//                                        onTriggered: {
//                                            // TODO
//                                        }
//                                    }
//                                }
//                            ]
                        }
                    },
                    ListItemComponent {
                        type: "header"
                        UsersHeaderItem {
                            //
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
                function hasBackgroundImage() {
                    return Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright && odsdata.listBackgroundForBright()
                }
                onCreationCompleted: {
                }
            } // end ListView
        } // end Container
        function addUser(name, displayType) {
            console.debug("Now add new USER to LISTMODEL on UserNavPage")
            // TODO from SERVER
            workInProgress.show()
        }
        function getDisplayIcon(displayType) {
            if (displayType == "U") {
                return "../images/users-icon.png"
            } else {
                return "../images/admin-icon.png"
            }
        }
        
        // we need this and the entry in bar-descriptor to support all directions
        onCreationCompleted: {
            addUserPage.onUserAdded.connect(addUser)
            console.debug("CREATED UsersPage")
        }
    } // end page
    //
    onCreationCompleted: {
        // do NOT init the DataModel here - odsdata will not found the objects
        // do it from the calling page where this Page was initialized lazy !
        console.debug("CREATED USERS NavPane")
    }
}// end navigationpane
