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

Page {
    id: fileInfoPage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("File Info") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }

        //
        Container {
            id: folderNameContainer
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
            }
            leftPadding: 40
            rightPadding: 40
            TextField {
                id: fileName
                text: ""
            }
        } // end Container
    } // end main container
    // set the field values from ODSFile* data
    function setValues(data, id) {
        if (data.id != id) {
            // if the id isn't equal the file was not found
            fileName.text = qsTr("File not found") + Retranslate.onLanguageChanged
            return;
        }
        fileName.text = data.name
    }
    // the fileId we got from context action of ListItem
    function refreshData(id) {
        fileName.text = "File: " + id
        // we get the ODSFile data from current node (from cache)
        // result is an empty ODSFile* or the correct one
        setValues(odsdata.fileFromId(id), id)
    }
    onCreationCompleted: {
    }
}
