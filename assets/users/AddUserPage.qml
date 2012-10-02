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

Page {
    // SIGNAL if user was added
    signal onUserAdded(string name, string displayType)
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
                // in Landscape we extend the left and right padding
                // then it'sd easier to scrill with the thumbs without tapping into a field
                if (orientation == UIOrientation.Landscape) {
                    userDataContainer.layout.rightPadding = 140
                    userDataContainer.layout.leftPadding = 140
                } else {
                    userDataContainer.layout.rightPadding = 25
                    userDataContainer.layout.leftPadding = 25
                }
            }
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Add User") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (firstNameWithMarker.textFieldText != "" && lastNameWithMarker.textFieldText != "" && emailWithMarker.textFieldText != "") {
                    addUserPage.onUserAdded(firstNameWithMarker.textFieldText + " " + lastNameWithMarker.textFieldText, isAdmin.displayType)
                    dataError.containerVisible = false
                    //TODO call CPP to send to the cloud
                    transport.value = 80
                    transport.visible = true
                    dummi.play()
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
                                emailWithMarker.textFieldText = ""
                                firstNameWithMarker.textFieldText = ""
                                lastNameWithMarker.textFieldText = ""
                                userTitle.text = ""
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
                            layoutProperties: StackLayoutProperties {
                                spaceQuota: 1
                            }
                            verticalAlignment: VerticalAlignment.Center
                            Option {
                                text: "Berlin"
                            }
                            Option {
                                text: "Offers"
                            }
                            Option {
                                text: "Orders"
                            }
                            selectedIndex: 0
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
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            userDataContainer.layout.rightPadding = 140
            userDataContainer.layout.leftPadding = 140
        } else {
            userDataContainer.layout.rightPadding = 25
            userDataContainer.layout.leftPadding = 25
        }
        clearFields();
        console.debug("AddUserPage INIT done")
    }
}
