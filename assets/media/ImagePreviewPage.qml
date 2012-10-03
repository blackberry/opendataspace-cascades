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
import FileInfo 1.0
/*
 * Image Overview
 * can share the image, do nothing (go back) or upload the image
 * Image occupies as much space as possible as long as aspect ratio fits
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    signal fileToQueueForUpload(string filePath)
    property alias previewPath: previewImage.imageSource
    id: previewPage
    titleBar: TitleBar {
        id: titleBarId
        title: qsTr("Preview") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    attachedObjects: [
        // FileInfo
        FileInfo {
            id: fileInfo
        },
        // application supports changing the Orientation
        OrientationHandler {
            onOrientationAboutToChange: {
                console.debug("ImagePreview: onOrientationAboutToChange")
                previewPage.reLayout(orientation);
            }
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Share") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/6-social-share81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // Calls a function that show's the image in the pictures app.
                ods.showInPicturesApp(previewPage.previewPath);
                console.debug("Calling function to launchpicturesapp");
            }
        },
        ActionItem {
            title: qsTr("Upload") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/9-av-upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                previewPage.fileToQueueForUpload(previewPage.previewPath);
            }
        }
    ]
    ScrollView {
        Container {
            layout: DockLayout {
            }
            leftPadding: 25
            topPadding: 25
            bottomPadding: 25
            Container {
                id: imageAndTextContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                horizontalAlignment: HorizontalAlignment.Left
                ImageView {
                    id: previewImage
                    objectName: "previewImage"
                    layoutProperties: StackLayoutProperties {
                    }
                    verticalAlignment: VerticalAlignment.Center
                    // without this the image would be as large as possible
                    minHeight: 620
                    maxHeight: 620
                    scalingMethod: ScalingMethod.AspectFit
                    onImageSourceChanged: {
                        console.debug("IMAGESOURCE Changed:" + imageSource)
                        recalculateValues(imageSource, previewPage.currentFolder)
                    }
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.TopToBottom
                    }
                    topPadding: 25
                    rightPadding: 25
                    Label {
                        id: titleLabel
                        visible: false
                        bottomMargin: 25
                        textStyle {
                            base: SystemDefaults.TextStyles.TitleText
                            color: Color.Black
                        }
                    }
                    TextArea {
                        id: filenameInfo
                        layoutProperties: StackLayoutProperties {
                        }
                        verticalAlignment: VerticalAlignment.Fill
                        text: ""
                        enabled: false
                        backgroundVisible: false
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Black
                        }
                    }
                }
            }
        } // end main container
    } // end ScrollView
    function recalculateValues(name, folder) {
        console.debug("ImagePreviewPage recalculate for " + name)
        titleBar.title = fileInfo.getShortName(name)
        titleLabel.text = titleBar.title;
        filenameInfo.enabled = true;
        filenameInfo.text = fileInfo.getDetailedInfo(ods.getCurrentLocale(), name); 
        filenameInfo.enabled = false;
    }
    // redesign if orientation changed
    function reLayout(orientation) {
        if (orientation == UIOrientation.Landscape) {
            console.debug("ImagePreview: reLayout to LANDSCAPE")
            titleBar.visibility = ChromeVisibility.Hidden
            titleLabel.visible = true
            imageAndTextContainer.layout.orientation = LayoutOrientation.LeftToRight
            previewImage.horizontalAlignment = HorizontalAlignment.Left
            previewImage.minHeight = 580
            previewImage.maxHeight = 580
            previewImage.maxWidth = 640
            console.debug("ImagePreview: reLayout to LANDSCAPE DONE")
        } else {
            console.debug("ImagePreview: reLayout to PORTRAIT")
            titleBar.visibility = ChromeVisibility.Visible
            titleLabel.visible = false
            imageAndTextContainer.layout.orientation = LayoutOrientation.TopToBottom
            previewImage.horizontalAlignment = HorizontalAlignment.Center
            previewImage.minHeight = 620
            previewImage.maxHeight = 620
            previewImage.maxWidth = 720
            console.debug("ImagePreview: reLayout to PORTRAIT DONE")
        }
    }
    // TODO Landscape hide Actionbar if no activity
    // in landscape we change the stack layout direction and hide the titlebar
    onCreationCompleted: {
        // initial setup for orientation
        reLayout(OrientationSupport.orientation);
    }
}
