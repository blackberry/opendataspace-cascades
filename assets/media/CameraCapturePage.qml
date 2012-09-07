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
*/import bb.cascades 1.0
import bb.cascades.multimedia 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    signal previewImage(string path)
    id: cameraCapturePage
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
                    cameraCapturePage.previewImage(fileName)
                }
            }
        }
    }
    // Open the Camera and start the Viewfinder
    function openODSCamera() {
        // seems that REAR doesn't work and displays black sites in Preview
        camera.open(CameraUnit.Front);
        camera.startViewfinder();
    }
    // Stop the Viewfinder and close the Camera
    // TODO dont know if I must do this
    function closeODSCamera() {
        camera.stopViewfinder();
        camera.close();
        
    }
    onCreationCompleted: {
        // the Image from Viewfinder should be visible
        cameraCapturePage.actionBarVisibility = ChromeVisibility.Overlay
    }
}
