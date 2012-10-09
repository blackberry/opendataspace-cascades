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
import bb.multimedia 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    signal previewAudio(string path)
    id: audioRecordPage
    actions: [
        ActionItem {
            id: startId
            title: qsTr("Start") + Retranslate.onLanguageChanged
            enabled: true
            imageSource: "asset:///images/ics/9-av-play81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                console.debug("audioRecordPage START")
                recorder.record();
                startId.enabled = false
                stopId.enabled = true
            }
        },
        ActionItem {
            title: qsTr("Stop") + Retranslate.onLanguageChanged
            id: stopId
            enabled: false
            imageSource: "asset:///images/ics/9-av-stop81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                console.debug("audioRecordPage STOP")
                recorder.reset();
                startId.enabled = true
                stopId.enabled = false
            }
        }
    ]
    attachedObjects: [
        AudioRecorder {
            id: recorder
            outputUrl: "/tmp/recording2.m4a"
            
        }
    ]
    content: Container {
        layout: DockLayout {
        }
        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            Label {
                id: label
                text: qsTr("Recording")  + Retranslate.onLanguageChanged
            }
        }
    }
    function closeODSAudio() {
        console.debug("audioRecordPage closeODSAudio")
        recorder.reset();
        startId.enabled = true
        stopId.enabled = false
    }
    onCreationCompleted: {
        // the Image from Viewfinder should be shine through
        audioRecordPage.actionBarVisibility = ChromeVisibility.Overlay
        console.debug("AudioRecordPage INIT done")
    }
}
