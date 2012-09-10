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
            onUiOrientationChanged: {
                // in Landscape we extend the left and right padding
                // then it'sd easier to scrill with the thumbs without tapping into a field
                if (uiOrientation == UiOrientation.Landscape) {
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
            title: qsTr("Add User")
            imageSource: "asset:///images/ics/5-content-new81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                if (firstNameWithMarker.textFieldText != "" && lastNameWithMarker.textFieldText != "" && emailWithMarker.textFieldText != "") {
                    addUserPage.onUserAdded(firstNameWithMarker.textFieldText + " " + lastNameWithMarker.textFieldText, isAdmin.displayType)
                    // animation flying data away to the cloud
                    transport.animation.play()
                    transport.containerVisible = true
                    userDataContainer.visible = false
                    emailWithMarker.textFieldText = ""
                    firstNameWithMarker.textFieldText = ""
                    lastNameWithMarker.textFieldText = ""
                    userTitle.text = ""
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
        title: qsTr("User Data")
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: rootContainer
        
        // Error Assistant
        ErrorAssistant {
            id: dataError
        }
        // Animate the data transport
        TransportDataToCloud {
            id: transport
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
                    layoutProperties: DockLayoutProperties {
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                    }
                    layout: StackLayout {
                        topPadding: 25
                        leftPadding: 25
                        rightPadding: 25
                        layoutDirection: LayoutDirection.TopToBottom
                    }
                    TextFieldWithMarker {
                        id: emailWithMarker
                        redBarImage: redTile.image
                        textFieldHintText: qsTr("User email address")
                        textFieldInputMode: TextFieldInputMode.EmailAddress
                        textFieldText: ""
                    }
                    Container {
                        id: salutationContainer
                        layout: StackLayout {
                            layoutDirection: LayoutDirection.LeftToRight
                            leftPadding: 20
                        }
                        layoutProperties: StackLayoutProperties {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Center
                        }
                        Label {
                            id: salutationLabel
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 0.8
                            }
                            text: qsTr("Salutation")
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        DropDown {
                            id: saluation
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 1
                            }
                            Option {
                                text: "Mr."
                            }
                            Option {
                                text: "Mrs."
                            }
                            selectedIndex: 0
                        }
                    } // end salutationContainer
                    TextField {
                        id: userTitle
                        hintText: qsTr("Title")
                        inputMode: TextFieldInputMode.Text
                        textStyle {
                            base: SystemDefaults.TextStyles.BodyText
                        }
                    }
                    TextFieldWithMarker {
                        id: firstNameWithMarker
                        redBarImage: redTile.image
                        textFieldHintText: qsTr("First Name")
                        textFieldText: ""
                    }
                    TextFieldWithMarker {
                        id: lastNameWithMarker
                        redBarImage: redTile.image
                        textFieldHintText: qsTr("Last Name")
                        textFieldText: ""
                    }
                    Container {
                        id: contoTypeContainer
                        layout: StackLayout {
                            layoutDirection: LayoutDirection.LeftToRight
                            leftPadding: 20
                            bottomPadding: 20
                        }
                        layoutProperties: StackLayoutProperties {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Center
                        }
                        Label {
                            id: contoTypeLabel
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 0.8
                            }
                            text: qsTr("Administrator")
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        ToggleButton {
                            // custom property init value: U = User (isAdmin false)
                            property string displayType: "U"
                            id: isAdmin
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 0.5
                            }
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
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 0.5
                            }
                            imageSource: "asset:///images/users-icon.png"
                            scalingMethod: ScalingMethod.AspectFit
                        }
                    } // end contoTypeContainer
                    Container {
                        id: dataRoomContainer
                        layout: StackLayout {
                            layoutDirection: LayoutDirection.LeftToRight
                            leftPadding: 20
                        }
                        layoutProperties: StackLayoutProperties {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Center
                        }
                        Label {
                            id: dataRoomLabel
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 0.8
                            }
                            text: qsTr("DataRoom")
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                            }
                        }
                        DropDown {
                            id: dataRoom
                            layoutProperties: StackLayoutProperties {
                                verticalAlignment: VerticalAlignment.Center
                                spaceQuota: 1
                            }
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
    function doTransportAnimationEnd(){
        userDataContainer.visible = true
    }
    onCreationCompleted: {
        // initialize positioning
        if (OrientationSupport.uiOrientation == UiOrientation.Landscape) {
            userDataContainer.layout.rightPadding = 140
            userDataContainer.layout.leftPadding = 140
        } else {
            userDataContainer.layout.rightPadding = 25
            userDataContainer.layout.leftPadding = 25
        }
        clearFields();
        // connect transport animation end SIGNAL
        transport.animation.onTransportAnimationEnd.connect(doTransportAnimationEnd)
        console.debug("AddUserPage INIT done")
    }
}
