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
    property alias previewPath: previewImage.imageSource
    id: previewPage
    titleBar: TitleBar {
        id: titleBarId
        // TODO only the filename
        title: "Preview"
        visibility: ChromeVisibility.Visible
    }
    attachedObjects: [
        // FileInfo
        FileInfo {
            id: fileInfo
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
            layout: StackLayout {
                layoutDirection: LayoutDirection.TopToBottom
            }
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top
            }
            ImageView {
                id: previewImage
                // without this the image would be as large as possible
                minHeight: 600
                maxHeight: 600
                objectName: "previewImage"
                scalingMethod: ScalingMethod.AspectFit
                onImageSourceChanged: {
                    console.debug("IMAGESOURCE Changed:" + imageSource)
                    recalculateValues(imageSource)
                }
            }
            TextArea {
                id: filenameInfo
                text: ""
                topMargin: 25
                enabled: false
                backgroundVisible: false
                textStyle {
                    base: SystemDefaults.TextStyles.BodyText
                    color: Color.Black
                }
            }
        }
    }
    function recalculateValues(name){
        titleBarId.title = fileInfo.getShortName(name);
        filenameInfo.enabled = true;
        filenameInfo.text = fileInfo.getDetailedInfo(ods.getCurrentLocale(), name);
        filenameInfo.enabled = false;
    }
}
