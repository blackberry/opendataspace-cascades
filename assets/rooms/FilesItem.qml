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
    layout: DockLayout {
    }
    Container {
        layout: DockLayout {
        }
        layoutProperties: DockLayoutProperties {
            horizontalAlignment: HorizontalAlignment.Center
        }
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
            imageSource: "asset:///images/white_photo.png"
            preferredWidth: 768
            preferredHeight: 173
        }
        Container {
            id: highlightContainer
            background: Color.create("#75b5d3")
            opacity: 0.0
            preferredWidth: 760
            preferredHeight: 168
            horizontalAlignment: HorizontalAlignment.Center
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
                preferredWidth: 150
                preferredHeight: 150
                minWidth: 150
                // datamodel knows the icon source
                imageSource: ListItemData.icon
                layoutProperties: StackLayoutProperties {
                }
                verticalAlignment: VerticalAlignment.Center
            }
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                layoutProperties: StackLayoutProperties {
                }
                verticalAlignment: VerticalAlignment.Center
                leftMargin: 30
                // TITLE
                Label {
                    // name, fileType are properties from data model
                    text: ListItemData.name + " (" + ListItemData.fileType + ") "
                    textStyle {
                        base: SystemDefaults.TextStyles.TitleText
                        color: Color.Black
                    }
                }
                // SUBTITLE
                Label {
                    // lastEditedBy, timestamp, fileSize are properties from data model
                    text: ListItemData.timestamp + " (" + ListItemData.fileSize + " Bytes)"
                    textStyle {
                        base: SystemDefaults.TextStyles.SubtitleText
                        color: Color.Black
                    }
                }
            }
        }
    }
    function setHighlight(highlighted) {
        if (highlighted) {
            highlightContainer.opacity = 0.9;
        } else {
            highlightContainer.opacity = 0.0;
        }
    }
    ListItem.onActivationChanged: {
        setHighlight(ListItem.active);
    }
    ListItem.onSelectionChanged: {
        setHighlight(ListItem.selected);
    }
    // init
    onCreationCompleted: {
        // set to Landscape if aklready in landscape while staring up
        if (OrientationSupport.orientation == UIOrientation.Landscape) {
            itemBackground.preferredWidth = 1280
        }
    }
}
