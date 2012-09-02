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
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

NavigationPane {
    id: paneId
    Page {
        id: tab1
        actions: [
            //-- define the actions for first tab here
            ActionItem {
                title: qsTr("Placeholder")
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    //imgTab1.rotationZ = imgTab1.rotationZ + 90;
                }
            }
        ]
        Container {
            //-- define tab content here
            layout: StackLayout {
            }
            Label {
                layoutProperties: StackLayoutProperties {
                    horizontalAlignment: HorizontalAlignment.Center
                }
                text: qsTr("Uploads")
                textStyle {
                    base: SystemDefaults.TextStyles.TitleText
                }
            }
            ImageView {
                id: imgTab1
                imageSource: "asset:///images/app-ods-150x150.png"
                layoutProperties: StackLayoutProperties {
                    horizontalAlignment: HorizontalAlignment.Center
                    spaceQuota: 1.0
                    verticalAlignment: VerticalAlignment.Center
                }
                scalingMethod: ScalingMethod.AspectFit
            }
        }
    }
    
    // we need this and the entry in bar-descriptor to support all directions
    onCreationCompleted: {
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //label5.text = "5555"
        //t6.text = "sechs"
    }
}
