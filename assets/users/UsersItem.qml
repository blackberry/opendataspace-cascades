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
 * Idea based on Cascades Sample CookBook
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Container {
    id: rootNode
    property bool backgroundVisible : true
    property variant selectionColor
    layout: DockLayout {
    }
    preferredWidth: Infinity
    background: ListItem.selected || ListItem.active ? selectionColor : Color.Transparent
    Container {
        layout: DockLayout {
        }
        minHeight: 137
        horizontalAlignment: HorizontalAlignment.Left
        attachedObjects: [
            // application supports changing the Orientation
            OrientationHandler {
                onOrientationAboutToChange: {
                    if (orientation == UIOrientation.Landscape) {
                        itemBackground.preferredWidth = 1280
                    } else {
                        itemBackground.preferredWidth = 768
                    }
                }
            }
        ]
        // Item background image.
        ImageView {
            id: itemBackground
            visible: backgroundVisible && !(rootNode.ListItem.selected || rootNode.ListItem.active)
            imageSource: "asset:///images/white_photo.png"
            preferredWidth: 768
            preferredHeight: 137
        }
        // The Item content an image and a text.
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            leftPadding: 6
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            ImageView {
                id: itemIcon
                preferredWidth: 114
                preferredHeight: 114
                // datamodel knows the icon source
                imageSource: ListItemData.displayIcon 
                layoutProperties: StackLayoutProperties {
                }
                verticalAlignment: VerticalAlignment.Center
            }
            Label {
                // displayName is a property from data model
                text: ListItemData.displayName
                leftMargin: 30
                textStyle {
                    base: SystemDefaults.TextStyles.TitleText
                    // color: Color.Black
                }
                layoutProperties: StackLayoutProperties {
                }
                verticalAlignment: VerticalAlignment.Center
            }
        }
        Container {
            verticalAlignment: VerticalAlignment.Bottom
            visible: ! backgroundVisible
            Divider {
            }
        }
    }
    onCreationCompleted: {
        // set to Landscape if aklready in landscape while staring up
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            itemBackground.preferredWidth = 1280
        }
    }
}
