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
 */
import bb.cascades 1.0
/*
 * Image Oreview
 * can share the image, do nothing (go back) or upload the image
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
        title: previewImage.imageSource
        visibility: ChromeVisibility.Overlay
    }
    actions: [
        ActionItem {
            title: qsTr("Share")
            imageSource: "asset:///images/ics/6-social-share81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // Calls a function that show's the image in the pictures app.
                ods.showInPicturesApp(previewPage.previewPath);
                console.debug("Calling function to launchpicturesapp");
            }
        },
        ActionItem {
            title: qsTr("Upload")
            imageSource: "asset:///images/ics/9-av-upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO  SIGNAL fileToUpload(path)
            }
        }
    ]
    Container {
        layout: DockLayout {
        }
        Container {
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
            ImageView {
                id: previewImage
                objectName: "previewImage"
                scalingMethod: ScalingMethod.AspectFit
            }
        }
    }
}
