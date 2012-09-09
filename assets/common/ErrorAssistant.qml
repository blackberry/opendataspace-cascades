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
 * can be used if errors at data entry
 * gives the user a visual hint that something went wrong
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Container {
    property alias animation: animateError
    property alias containerVisible: errorContainer.visible
    id: errorContainer
    attachedObjects: [
        ImageTracker {
            id: errorHelper
            imageSource: "asset:///images/chat.png"
        }
    ]
    layout: StackLayout {
        leftPadding: 100
    }
    visible: false
    // the error image
    ImageView {
        id: errorImage
        image: errorHelper.image
        scalingMethod: ScalingMethod.AspectFit
        layoutProperties: StackLayoutProperties {
            horizontalAlignment: HorizontalAlignment.Fill
        }
    }
    // error text
    Label {
        id: errorText
        text: qsTr("sorry: some Errors")
        textStyle {
            base: SystemDefaults.TextStyles.BigText
            color: Color.Red
        }
    }
    animations: [
        SequentialAnimation {
            id: animateError
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
                RotateTransition {
                    id: rotateAnimation
                    fromAngleZ: 180
                    toAngleZ: 0
                    duration: 2000
                }
            }
            ParallelAnimation {
                delay: 2000
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
            // at the end make container invisible
            onEnded: errorContainer.visible = false
        }
    ]
}
