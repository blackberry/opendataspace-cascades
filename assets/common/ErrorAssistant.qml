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
            imageSource: "asset:///images/rain.png"
        }
    ]
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    leftPadding: 25
    topPadding: 25
    minHeight: 120
    visible: false
    // the error image
    ImageView {
        id: errorImage
        image: errorHelper.image
        scalingMethod: ScalingMethod.AspectFit
        layoutProperties: StackLayoutProperties {
        }
    }
    // error text
    Label {
        id: errorText
        text: qsTr("please check entry") + Retranslate.onLanguageChanged
        textStyle {
            base: SystemDefaults.TextStyles.TitleText
        }
    }
    animations: [
        FadeTransition {
            id: animateError
            duration: 2000
            fromOpacity: 0.1
            toOpacity: 1.0
        }
    ]
    onTouch: {
        errorContainer.visible = false
    }
}
