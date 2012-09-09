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
 * Animation to visualize that data was sent to the cloud
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Container {
    property alias animation: transportData
    property alias containerVisible: transportContainer.visible
    id: transportContainer
    attachedObjects: [
        ImageTracker {
            id: cloudData
            imageSource: "asset:///images/rooms-icon.png"
        }
    ]
    layout: DockLayout {
        topPadding: 100
        leftPadding: 100
    }
    layoutProperties: StackLayoutProperties {
        horizontalAlignment: HorizontalAlignment.Fill
    }
    // should fit into all screen sizes
    minHeight: 500
    visible: false
    // the cloud image
    ImageView {
        id: cloudImage
        image: cloudData.image
        scalingMethod: ScalingMethod.AspectFit
        layoutProperties: DockLayoutProperties {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
        }
    }
    // transmission text
    Label {
        id: errorText
        text: qsTr("Data to the Cloud...")
        layoutProperties: DockLayoutProperties {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }
        textStyle {
            base: SystemDefaults.TextStyles.BigText
            color: Color.Blue
        }
    }
    // animation
    animations: [
        SequentialAnimation {
            signal onTransportAnimationEnd()
            id: transportData
            ParallelAnimation {
                TranslateTransition {
                    duration: 2000
                    fromX: -180
                    toX: 0
                    fromY: -180
                    toY: 0
                }
                FadeTransition {
                    duration: 2000
                    fromOpacity: 0
                    toOpacity: 1.0
                }
            }
            ScaleTransition {
                easingCurve: StockCurve.BounceOut
                duration: 1000
                toX: 2
                toY: 2
            }
            ScaleTransition {
                easingCurve: StockCurve.BounceIn
                duration: 1000
                toX: 1
                toY: 1
            }
            ScaleTransition {
                easingCurve: StockCurve.BounceOut
                duration: 1000
                toX: 2
                toY: 2
            }
            ScaleTransition {
                easingCurve: StockCurve.BounceIn
                duration: 1000
                toX: 1
                toY: 1
            }
            ParallelAnimation {
                TranslateTransition {
                    duration: 2000
                    fromX: 0
                    toX: -256
                    fromY: 0
                    toY: -256
                }
                FadeTransition {
                    duration: 2000
                    fromOpacity: 1.0
                    toOpacity: 0
                }
            }
            onEnded: {
                // hide the container
                transportContainer.visible = false
                // send the SIGNAL hat animation is ended
                onTransportAnimationEnd()
            }
        }
    ]
}
