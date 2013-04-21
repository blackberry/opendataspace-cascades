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
        Container {
            //-- define tab content here
            layout: DockLayout {
            }
            Label {
                id: infoLabel
                layoutProperties: StackLayoutProperties {
                }
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                multiline: true
                textStyle {
                    base: SystemDefaults.TextStyles.BodyText
                }
            }

        }
    }
    function createInfoText(){
        var s;
        s = qsTr("HowTo Upload Files to OpenDataSpace")
        s += "\n"
        s += "\n"
        s += qsTr("1. GoTo Tab DataSpace to see your Data Rooms")
        s += "\n"
        s += qsTr("2. Open a Data Room to see Files and Folders of this Room")
        s += "\n"
        s += qsTr("3. GoTo the place where you want to upload a File")
        s += "\n"
        s += qsTr("4. Open Overflow Menu (3 dots)")
        s += "\n"
        s += qsTr("5. Select or Create an Image, Document, ...")
        s += "\n"
        s += qsTr("6. Verify and click Upload")
        s += "\n"
        s += qsTr("You're done")
        infoLabel.text = s;
    }
    // SLOTS
    function onQueueFileForUpload(path) {
        console.debug("ADD TO QUEUE: " + path);
    }

    onCreationCompleted: {
        createInfoText()
    }
}
