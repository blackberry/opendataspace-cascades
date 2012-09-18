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
 * Video Preview
 * can share the video, do nothing (go back) or upload the video
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    property string previewPath
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
            onUiOrientationChanged: {
                if (uiOrientation == UiOrientation.Landscape) {
                    titleBarId.visibility = ChromeVisibility.Hidden
                    titleLabel.visible = true
                    imageAndTextContainer.layout.layoutDirection = LayoutDirection.LeftToRight
                } else {
                    imageAndTextContainer.layout.layoutDirection = LayoutDirection.TopToBottom
                    titleBarId.visibility = ChromeVisibility.Visible
                    titleLabel.visible = false
                }
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
                //ods.showInVideosApp(previewPage.previewPath);
                console.debug("Calling function to launchvideosapp");
            }
        },
        ActionItem {
            title: qsTr("Upload") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/9-av-upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO  SIGNAL fileToUpload(path)
            }
        }
    ]
    Container {
        layout: DockLayout {
            leftPadding: 25
            topPadding: 25
        }
        Container {
            id: imageAndTextContainer
            layout: StackLayout {
                layoutDirection: LayoutDirection.TopToBottom
            }
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Left
            }
            ImageView {
                id: previewImage
                layoutProperties: StackLayoutProperties {
                    verticalAlignment: VerticalAlignment.Center
                }
                imageSource: "asset:///images/nuvola/tar.png"
                objectName: "previewZip"
                minWidth: 128
                minHeight: 128
                //scalingMethod: ScalingMethod.AspectFit
            }
            Container {
                layout: StackLayout {
                    layoutDirection: LayoutDirection.TopToBottom
                    topPadding: 25
                }
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
                        verticalAlignment: VerticalAlignment.Fill
                    }
                    text: ""
                    enabled: false
                    backgroundVisible: false
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                        color: Color.Black
                    }
                }
            }
        }
    }
    function recalculateValues(name) {
        titleBarId.title = fileInfo.getShortName(name);
        titleLabel.text = titleBarId.title;
        filenameInfo.enabled = true;
        filenameInfo.text = fileInfo.getDetailedInfo(ods.getCurrentLocale(), name) + "\n"; //workaround bug in landscape: last line not visible
        filenameInfo.enabled = false;
    }
    // TODO Landscape hide Actionbar if no activity
    // in landscape we change the stack layout direction and hide the titlebar
    onCreationCompleted: {
        // initial setup for orientation
        if (OrientationSupport.uiOrientation == UiOrientation.Landscape) {
            titleBarId.visibility = ChromeVisibility.Hidden
            titleLabel.visible = true
            imageAndTextContainer.layout.layoutDirection = LayoutDirection.LeftToRight
        } else {
            imageAndTextContainer.layout.layoutDirection = LayoutDirection.TopToBottom
            titleBarId.visibility = ChromeVisibility.Visible
            titleLabel.visible = false
        }
    }
}
