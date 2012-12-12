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

Page {
    id: fileInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("File Info") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        ScrollView {
            //
            Container {
                id: fileInfoContainer
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                layout: StackLayout {
                }
                leftPadding: 40
                rightPadding: 40
                Container {
                    id: headerContainer
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    leftPadding: 6
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    ImageView {
                        id: fileImage
                        preferredWidth: 114
                        preferredHeight: 114
                        minWidth: 114
                    }
                    Label {
                    id: fileName
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.PrimaryText
                    }
                }
                } // end headerContainer
                
                Label {
                    text: qsTr("Id") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: fileId
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Size") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: fileSize
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Created by user") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: createdBy
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Classification") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: classification
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Date created") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: createdAt
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Expiration date") + Retranslate.onLanguageChanged
                }
                Label {
                    id: expires
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    text: qsTr("Comment") + Retranslate.onLanguageChanged
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                    }
                }
                Label {
                    id: comment
                    multiline: true
                    text: ""
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
            } // end Container
        } // end scroll view
    } // end main container
    // set the field values from ODSFile* data
    function setValues(data, id) {
        if (data.id != id) {
            // if the id isn't equal the file was not found
            fileName.text = qsTr("File not found") + Retranslate.onLanguageChanged
            return;
        }
        fileImage.imageSource = data.displayIcon
        fileName.text = data.name
        fileId.text = data.id
        fileSize.text = data.fileSize + "Bytes"
        createdBy.text = data.createdBy
        classification.text = data.classification
        createdAt.text = data.createdAt
        expires.text = data.expires
        comment.text = data.comment
    }
    // the fileId we got from context action of ListItem
    function refreshData(id) {
        fileName.text = "File: " + id
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.fileFromId(id), id)
    }
    onCreationCompleted: {
    }
}
