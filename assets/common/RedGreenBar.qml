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
 * Two ImageViews horizontally layouted
 * as a small bar filling the complete width
 * using spacequota to get the width of each ImageView
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Container {
    id: redGreen
    attachedObjects: [
        // a red tile of 16x16 pixels
        ImagePaintDefinition {
            id: redTile
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/tiles/red16x16.png"
        },
        // a green tile of 16x16 pixels
        ImagePaintDefinition {
            id: greenTile
            repeatPattern: RepeatPattern.XY
            imageSource: "asset:///images/tiles/green16x16.png"
        }
    ]
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    ImageView {
        id: redBar
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        image: redTile.image
        minHeight: 20
        rightMargin: 0
    }
    ImageView {
        id: greenBar
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        image: greenTile.image
        minHeight: 20
        leftMargin: 0
    }
    // called from outside to set the values
    function setRedGreen(red, green) {
        redBar.layoutProperties.spaceQuota = red
        greenBar.layoutProperties.spaceQuota = green
        
    }
}
