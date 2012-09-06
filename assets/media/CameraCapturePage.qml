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

/* ideas got from sample PhotoBomber
* 
* We use the Camera control from cascades multimedia, it needs to be initiated from C++  
* code before we can use it though.
*/

import bb.cascades 1.0
import bb.cascades.multimedia 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/
Page {
    id: cameraCapturePage
    
    attachedObjects: [
            ImagePreviewSheet {
                id: imagePreviewSheet
            }
        ]
        
    content: Container {
        layout: DockLayout {
        }
        Container {
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
            // This is the camera control that is defined in the cascades multimedia library
            Camera {
                id: camera
                objectName: "odsCamera"
                onTouch: {
                    if (event.isDown()) {
                        
                        capturePhoto();
                        setting.visible = true;
                      
                    }
                } 
        		             
                // There are loads of messages we could listen to here
                //onPhotoSaved and onShutterFired are taken care of in the C code
                onCameraOpenFailed: {
                    console.log("onCameraOpenFailed signal received with error " + error);
                }
                onViewfinderStartFailed: {
                    console.log("viewfinderStartFailed signal received with error " + error);
                }
                onViewfinderStopFailed: {
                    console.log("viewfinderStopFailed signal received with error " + error);
                }
                onPhotoCaptureFailed: {
                    console.log("photoCaptureFailed signal received with error " + error);
                }
                onPhotoSaveFailed: {
                    console.log("photoSaveFailed signal received with error " + error);
                }
                onPhotoSaved: {
                    // we do a o preview             
                    imagePreviewSheet.visible = true;
                    imagePreviewSheet.previewPath = fileName;
                }
            }
        }
        Container {
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Bottom
            }
            layout: DockLayout {
            }
            ImageButton {
                id: setting
                visible: false
                defaultImageSource: "asset:///images/settings_unpressed.png"
                pressedImageSource: "asset:///images/settings_pressed.png"
                onClicked: {
                    imagePreviewSheet.visible = true;
                }
                layoutProperties: DockLayoutProperties {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Bottom
                }
            }
        }
    }
    
}
