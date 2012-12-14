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

Container {
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    topPadding: 6
    bottomPadding: 6
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    ImageView {
        id: imageId
        imageSource: "../images/rooms-icon.png"
        preferredWidth: 114
        preferredHeight: 114
        minWidth: 114
    }
    Label {
        id: valueId
        text: qsTr("ODS Cloud Info") + Retranslate.onLanguageChanged
        multiline: true
        textStyle {
            base: SystemDefaults.TextStyles.TitleText
        }
        verticalAlignment: VerticalAlignment.Center
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
}
