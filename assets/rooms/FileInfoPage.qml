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
    actions: [
            ActionItem {
                title: qsTr("View") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/2-action-search81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            },
            ActionItem {
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/5-content-copy81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            },
            ActionItem {
                title: qsTr("Move") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/5-content-import-export81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            },
            ActionItem {
                title: qsTr("Rename") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/5-content-edit81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            },
            ActionItem {
                title: qsTr("Download") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/download81.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    // TODO
                }
            },
            ActionItem {
                title: qsTr("Link") + Retranslate.onLanguageChanged
                imageSource: "asset:///images/ics/4-collections-labels81.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            },
            DeleteActionItem {
                title: qsTr("Delete") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    // TODO
                }
            }
        ]
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
                            topPadding: 14
                            bottomPadding: 14
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
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                            }
                        } // end headerContainer
                        Container {
                            id: idContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Id") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: fileId
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end idContainer
                        Container {
                            id: sizeContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Size") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: fileSize
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end size container
                        Container {
                            id: createdByContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Created by user") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: createdBy
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end createdByContainer
                        Container {
                            id: classificationContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Classification") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: classification
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end classificationContainer
                        Container {
                            id: dateCreatedContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Date created") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: createdAt
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end dateCreatedContainer
                        Container {
                            id: expirationContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Expiration date") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: expires
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // end expirationContainer
                        Container {
                            id: commentContainer
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            topPadding: 14
                            bottomPadding: 14
                            Label {
                                multiline: true
                                text: qsTr("Comment") + Retranslate.onLanguageChanged
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                            Label {
                                id: comment
                                multiline: true
                                text: ""
                                textStyle {
                                    base: SystemDefaults.TextStyles.TitleText
                                    color: Color.Gray
                                }
                                verticalAlignment: VerticalAlignment.Center
                                layoutProperties: StackLayoutProperties {
                                    spaceQuota: 1
                                }
                            }
                        } // endCommentContainer
                    } // end fileInfoContainer
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
    
