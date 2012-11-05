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
    attachedObjects: [
        // application supports changing the Orientation
        OrientationHandler {
            onOrientationAboutToChange: {
                if (orientation == UIOrientation.Landscape) {
                    feedback.preferredHeight = 430
                } else {
                    feedback.preferredHeight = 940
                }
            }
        }
    ]
    // resizes to have space for the keyboard
    resizeBehavior: PageResizeBehavior.Resize
    titleBar: TitleBar {
        id: theBar
        title: qsTr("Feedback") + Retranslate.onLanguageChanged
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
    // the main container
    Container {
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        topPadding: 25
        leftPadding: 25
        rightPadding: 25
        id: mainContainer
        Label {
            id: fromLabel
            text: qsTr("from") + Retranslate.onLanguageChanged + ": " + "mustermann@me.com"
            leftMargin: 20
            textStyle {
                base: SystemDefaults.TextStyles.BodyText
            }
        }
        Label {
            id: toLabel
            text: qsTr("to") + Retranslate.onLanguageChanged + ": " + "support@opendataspace.org"
            leftMargin: 20
            textStyle {
                base: SystemDefaults.TextStyles.BodyText
            }
        }
        Divider {
            bottomMargin: 20
            topMargin: 20
        }
        TextArea {
            id: feedback
            bottomMargin: 80
            preferredHeight: 900
            layoutProperties: StackLayoutProperties {
            }
            verticalAlignment: VerticalAlignment.Fill
            hintText: qsTr("Your Feedback") + Retranslate.onLanguageChanged
        }
    }
    onCreationCompleted: {
        // initial setup for orientation
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            feedback.preferredHeight = 430
        } else {
            feedback.preferredHeight = 940
        }
    }
}
