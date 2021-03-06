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
import "../common"
import bb.system 1.0

Page {
    // SIGNAL if user was added
    signal onUserAdded(string name, string displayType)
    property int salutationIndex: 0
    property int dataRoomSelectedValue: -1
    id: addUserPage
    resizeBehavior: PageResizeBehavior.Resize
    //
    attachedObjects: [
        // a red tile of 16x16 pixels
        ImagePaintDefinition {
            id: redTile
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/tiles/red16x16.png"
        },
        // recalculate positions
        OrientationHandler {
            onOrientationAboutToChange: {
                if(ods.isPassport()){
                    return 
                }
                // in Landscape we extend the left and right padding
                // then it'sd easier to scrill with the thumbs without tapping into a field
                if (orientation == UIOrientation.Landscape) {
                    userDataContainer.rightPadding = 140
                    userDataContainer.leftPadding = 140
                } else {
                    userDataContainer.rightPadding = 25
                    userDataContainer.leftPadding = 25
                }
            }
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Create User now") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (firstNameWithMarker.textFieldText != "" && lastNameWithMarker.textFieldText != "" && emailWithMarker.textFieldText != "") {
                    addUserPage.onUserAdded(firstNameWithMarker.textFieldText + " " + lastNameWithMarker.textFieldText, isAdmin.displayType)
                    dataError.containerVisible = false
                    addUserToCloud()
                } else {
                    // animation to demonstrate that there are errors
                    dataError.animation.play()
                    dataError.containerVisible = true
                }
            }
        }
    ]
    titleBar: TitleBar {
        id: addBar
        title: qsTr("User Data") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: rootContainer

        // Error Assistant
        ErrorAssistant {
            id: dataError
        }
        ProgressIndicator {
            id: transport
            topMargin: 25
            visible: false
        }

        // using a ScrollView to manage the fields in Landscape
        ScrollView {
            id: scroll
            // Hint: set to Vertical - if nothing (== both)
            // 10.0.06 has a bug and clears fields esp. w keyboard
            scrollViewProperties {
                scrollMode: ScrollMode.Vertical
            }
            Container {
                id: mainContainer
                layout: DockLayout {
                }
                Container {
                    id: userDataContainer
                    // Animate the data transport
                    animations: [
                        SequentialAnimation {
                            onStarted: {
                                userDataContainer.enabled = false
                            }
                            id: dummi
                            FadeTransition {
                                duration: 1000
                                fromOpacity: 1.0
                                toOpacity: 0.3
                                onEnded: {
                                    transport.value = 40
                                }
                            }
                            FadeTransition {
                                duration: 1000
                                fromOpacity: 0.3
                                toOpacity: 1.0
                            }
                            onEnded: {
                                transport.value = 10
                                transport.visible = false
                                clearFields()
                                userDataContainer.enabled = true
                            }
                        }
                    ]
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    layout: StackLayout {
                        orientation: LayoutOrientation.TopToBottom
                    }
                    topPadding: 25
                    leftPadding: 25
                    rightPadding: 25
                    TextFieldWithMarker {
                        id: emailWithMarker
                        redBarImage: redTile.image
                        textFieldHintText: qsTr("User email address") + Retranslate.onLanguageChanged
                        textFieldInputMode: TextFieldInputMode.EmailAddress
                        textFieldText: ""
                    }
                    Container {
                        id: salutationContainer
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        leftPadding: 20
                        layoutProperties: StackLayoutProperties {
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        Label {
                            id: salutationLabel
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 0.8
                            }
                            verticalAlignment: VerticalAlignment.Center
                            text: qsTr("Salutation") + Retranslate.onLanguageChanged
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        DropDown {
                            id: saluation
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            verticalAlignment: VerticalAlignment.Center
                            Option {
                                text: qsTr("Mr.") + Retranslate.onLanguageChanged
                            }
                            Option {
                                text: qsTr("Mrs.") + Retranslate.onLanguageChanged
                            }
                            selectedIndex: 0
                            onSelectedIndexChanged: {
                                salutationIndex = selectedIndex
                            }
                        }
                    } // end salutationContainer
                    TextField {
                        id: userTitle
                        hintText: qsTr("Title") + Retranslate.onLanguageChanged
                        inputMode: TextFieldInputMode.Text
                        textStyle {
                            base: SystemDefaults.TextStyles.BodyText
                        }
                    }
                    TextFieldWithMarker {
                        id: firstNameWithMarker
                        redBarImage: redTile.image
                        textFieldHintText: qsTr("First Name") + Retranslate.onLanguageChanged
                        textFieldText: ""
                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        topPadding: 20
                        TextFieldWithMarker {
                            id: lastNameWithMarker
                            redBarImage: redTile.image
                            textFieldHintText: qsTr("Last Name") + Retranslate.onLanguageChanged
                            textFieldText: ""
                        }
                    }
                    Container {
                        id: contoTypeContainer
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        topPadding: 20
                        leftPadding: 20
                        layoutProperties: StackLayoutProperties {
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        Label {
                            id: contoTypeLabel
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 0.8
                            }
                            verticalAlignment: VerticalAlignment.Center
                            text: qsTr("Administrator") + Retranslate.onLanguageChanged
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        ToggleButton {
                            // custom property init value: U = User (isAdmin false)
                            property string displayType: "U"
                            id: isAdmin
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 0.6
                            }
                            verticalAlignment: VerticalAlignment.Center
                            checked: false
                            onCheckedChanged: {
                                // set the custom property
                                if (checked) {
                                    displayType = "A"
                                    contoTypeImage.imageSource = "asset:///images/admin-icon.png"
                                } else {
                                    displayType = "U"
                                    contoTypeImage.imageSource = "asset:///images/users-icon.png"
                                }
                            }
                        }
                        ImageView {
                            id: contoTypeImage
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 0.4
                            }
                            verticalAlignment: VerticalAlignment.Center
                            imageSource: "asset:///images/users-icon.png"
                            scalingMethod: ScalingMethod.AspectFill
                        }
                    } // end contoTypeContainer
                    Container {
                        id: dataRoomContainer
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        leftPadding: 20
                        topPadding: 20
                        layoutProperties: StackLayoutProperties {
                        }
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Center
                        Label {
                            id: dataRoomLabel
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 0.8
                            }
                            verticalAlignment: VerticalAlignment.Center
                            text: qsTr("DataRoom") + Retranslate.onLanguageChanged
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        DropDown {
                            id: dataRoom
                            objectName: "roomsDropDown"
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            verticalAlignment: VerticalAlignment.Center
                            Option {
                                text: "n/a"
                            }
                            onSelectedValueChanged: {
                                dataRoomSelectedValue = selectedValue
                            }
                        }
                    } // end dataRoomContainer

                    // todo rights usermanagement
                } // end Container
            } // end main container
        } // end ScrollView
    } // end rootContainer
    function clearFields() {
        emailWithMarker.textFieldText = ""
        firstNameWithMarker.textFieldText = ""
        lastNameWithMarker.textFieldText = ""
        userTitle.text = ""
        salutationIndex = 0
        dataRoomSelectedValue = -1
        odsdata.createRoomsDropDown()
    }
    function addUserToCloud() {
        
        odsdata.addUser([
                emailWithMarker.textFieldText,
                salutationIndex,
                userTitle.text,
                firstNameWithMarker.textFieldText,
                lastNameWithMarker.textFieldText,
                isAdmin.checked,
                dataRoomSelectedValue
            ])
        usersNavigationPane.pop()
    }
    onCreationCompleted: {
        // initialize positioning
        if (!ods.isPassport() && OrientationSupport.orientation == UIOrientation.Landscape) {
            userDataContainer.rightPadding = 140
            userDataContainer.leftPadding = 140
        } else {
            userDataContainer.rightPadding = 25
            userDataContainer.leftPadding = 25
        }
        console.debug("AddUserPage INIT done")
    }
}
