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
 * Container with 2 Label:
 * first Label as Label, 2nd as Value
 * both multiline
 * spacequota 1:1 in portrait and 1:2 in landscape
 * useful for info pages with read-only content
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Container {
    property alias labelText: labelId.text
    property alias valueText: valueId.text
    property bool landscape: false
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    topPadding: 14
    bottomPadding: 14
    Label {
        id: labelId
        multiline: true
        textStyle {
            base: SystemDefaults.TextStyles.TitleText
        }
        verticalAlignment: VerticalAlignment.Center
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    Label {
        id: valueId
        multiline: true
        textStyle {
            base: SystemDefaults.TextStyles.TitleText
            color: Color.Gray
        }
        verticalAlignment: VerticalAlignment.Center
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    onLandscapeChanged: {
        if (landscape == true) {
            valueId.layoutProperties.spaceQuota = 2.0
        } else {
            valueId.layoutProperties.spaceQuota = 1.0
        }
    }
}
