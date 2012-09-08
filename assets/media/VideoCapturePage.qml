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
// WORK IN PROGRESS --- NOT WORKING YET

Page {
    signal previewVideo(string path)
    id: videocameraCapturePage
    actions: [
        ActionItem {
            id: startId
            title: qsTr("Start")
            enabled: true
            imageSource: "asset:///images/ics/9-av-play81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                videocamera.startVideoCapture();
                videocamera.startId.enabled = false
                videocamera.stopId.enabled = true
            }
        },
        ActionItem {
            title: qsTr("Stop")
            id: stopId
            enabled: false
            imageSource: "asset:///images/ics/9-av-stop81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                videocamera.stopVideoCapture();
                videocamera.startId.enabled = true
                videocamera.stopId.enabled = false
            }
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
                id: videocamera
                objectName: "odsVideo"
                onTouch: {
                    if (event.isDown()) {
                        startVideoCapture();
                        startId.enabled = false
                        stopId.enabled = true
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
                    // we do a preview             
                    videocameraCapturePage.previewVideo(fileName)
                }
            }
        }
    }
    // Open the Camera and start the Viewfinder
    function openODSVideo() {
        console.debug("VideoCapturePage openODSVideo called")
        // seems that REAR doesn't work and displays black sites in Preview
        videocamera.open(CameraUnit.Front);
        videocamera.startViewfinder();
    }
    // Stop the Viewfinder and close the Camera
    // TODO dont know if I must do this
    function closeODSVideo() {
        console.debug("VideoCapturePage closeODSVideo called")
        videocamera.stopVideoCapture;
        videocamera.stopViewfinder();
        videocamera.close();
    }
    onCreationCompleted: {
        // the Image from Viewfinder should be shine through
        videocameraCapturePage.actionBarVisibility = ChromeVisibility.Overlay
        console.debug("VideoCapturePage INIT done")
    }
}
