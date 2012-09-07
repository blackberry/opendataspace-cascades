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

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    id: page
    signal send(bool ok)
    // seems not to work
    resizeBehavior: PageResizeBehavior.Resize
    titleBar: TitleBar {
        id: theBar
        title: qsTr("Feedback")
        visibility: ChromeVisibility.Visible
        dismissAction: ActionItem {
            title: qsTr("Cancel")
            onTriggered: {
                page.send(false);
            }
        }
        acceptAction: ActionItem {
            title: qsTr("Send")
            onTriggered: {
                page.send(true);
            }
        }
    } 
    // the first Container to hold the Background
    Container {
        id: backgroundContainer
        layout: DockLayout {
        }

        // the main container to do the Login
        Container {
            layout: StackLayout {
                topPadding: 25
                leftPadding: 25
                rightPadding: 25
            }
            id: mainContainer
            // would prefer to use background: Color.Transparent
            // but doenst work to get the background from screen below
            Container {
                layout: StackLayout {
                    layoutDirection: LayoutDirection.TopToBottom
                    
                }
                Label {
                    id: fromLabel
                    text: qsTr("from")+": "+"mustermann@me.com"
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }

                Label {
                    id: toLabel
                    text: qsTr("to")+": "+"support@opendataspace.org"
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Divider {
                    bottomMargin: 40
                    topMargin: 40
                }
                TextArea {
                    id: feedback
                    bottomMargin: 80
                    preferredHeight: 600
                    layoutProperties: StackLayoutProperties {
                        verticalAlignment: VerticalAlignment.Fill
                    }
                    hintText: qsTr("Please enter your Feedback")
                }
            }
        }
    }
}
