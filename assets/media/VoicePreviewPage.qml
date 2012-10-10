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
import org.opendataspace.fileinfo 1.0
import bb.multimedia 1.0
/*
 * Video Preview
 * can share the video, do nothing (go back) or upload the video
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

Page {
    property string previewPath
    id: previewPage
    titleBar: TitleBar {
        id: titleBarId
        title: qsTr("Preview") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    attachedObjects: [
        // FileInfo
        FileInfo {
            id: fileInfo
        },
        MediaPlayer {
            id: player
            onPlaybackCompleted: {
                stopIt()
            }
            onStop: {
                stopIt()
            }
        },
        // application supports changing the Orientation
        OrientationHandler {
            onOrientationAboutToChange: {
                console.debug("VideoPreview: onOrientationAboutToChange")
                previewPage.reLayout(orientation);
            }
        }
    ]
    actions: [
        ActionItem {
            title: qsTr("Hear in...") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/2-action-search81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // Calls a function that play thru Invokation Framework
                ods.invokeBoundMediaPlayer(previewPage.previewPath);
                console.debug("just called function to View from IF");
            }
        },
        ActionItem {
            title: qsTr("Upload") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/9-av-upload81.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                // TODO  SIGNAL fileToUpload(path)
            }
        },
        ActionItem {
            title: qsTr("Play Audio") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/10-device-access-volume-on81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                playIt()
            }
        },
        ActionItem {
            id: stopAction
            title: qsTr("Stop Audio") + Retranslate.onLanguageChanged
            imageSource: "asset:///images/ics/9-av-stop81.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            enabled: false
            onTriggered: {
                stopIt()
            }
        }
    ]
    ScrollView {
        Container {
            layout: DockLayout {
            }
            leftPadding: 25
            topPadding: 25
            bottomPadding: 25
            Container {
                id: imageAndTextContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.TopToBottom
                }
                horizontalAlignment: HorizontalAlignment.Left
                ImageView {
                    id: previewRecordedVoice
                    objectName: "previewRecordedVoice"
                    layoutProperties: StackLayoutProperties {
                    }
                    verticalAlignment: VerticalAlignment.Center
                    imageSource: "asset:///images/nuvola/krec_fileplay.png"
                    minWidth: 128
                    minHeight: 128
                    scalingMethod: ScalingMethod.AspectFit
                }
                Container {
                    layout: StackLayout {
                        orientation: LayoutOrientation.TopToBottom
                    }
                    topPadding: 25
                    rightPadding: 25
                    Label {
                        id: titleLabel
                        visible: false
                        bottomMargin: 25
                        textStyle {
                            base: SystemDefaults.TextStyles.TitleText
                            color: Color.Black
                        }
                    }
                    TextArea {
                        id: filenameInfo
                        layoutProperties: StackLayoutProperties {
                        }
                        verticalAlignment: VerticalAlignment.Fill
                        text: ""
                        enabled: false
                        backgroundVisible: false
                        textStyle {
                            base: SystemDefaults.TextStyles.SmallText
                            color: Color.Black
                        }
                    }
                }
            }
        } // end maincontainer
    } // end scrollview
    function recalculateValues(name) {
        titleBar.title = fileInfo.getShortName(name);
        titleLabel.text = titleBar.title;
        filenameInfo.enabled = true;
        filenameInfo.text = fileInfo.getDetailedInfo(ods.getCurrentLocale(), name);
        filenameInfo.enabled = false;
    }
    // redesign if orientation changed
    function reLayout(orientation) {
        if (orientation == UIOrientation.Landscape) {
            console.debug("previewRecordedVoice: reLayout to LANDSCAPE")
            titleBar.visibility = ChromeVisibility.Hidden
            titleLabel.visible = true
            imageAndTextContainer.layout.orientation = LayoutOrientation.LeftToRight
            previewRecordedVoice.horizontalAlignment = HorizontalAlignment.Left
            console.debug("previewRecordedVoice: reLayout to LANDSCAPE DONE")
        } else {
            console.debug("previewRecordedVoice: reLayout to PORTRAIT")
            titleBar.visibility = ChromeVisibility.Visible
            titleLabel.visible = false
            imageAndTextContainer.layout.orientation = LayoutOrientation.TopToBottom
            previewRecordedVoice.horizontalAlignment = HorizontalAlignment.Center
            console.debug("previewRecordedVoice: reLayout to PORTRAIT DONE")
        }
    }
    // play recorded voice
    function playIt() {
        // Reset URL of player
        player.sourceUrl = ""
        // Set the currently selected track as player source URL
        player.sourceUrl = previewPath
        // Start playback
        player.play()
        //
        stopAction.enabled = true
    }
    // stop oplaying audio
    function stopIt() {
        if (player.mediaState == MediaState.Started) {
            player.stop()
        }
        stopAction.enabled = false
    }
    // TODO Landscape hide Actionbar if no activity
    // in landscape we change the stack layout direction and hide the titlebar
    onCreationCompleted: {
        // initial setup for orientation
        reLayout(OrientationSupport.orientation);
    }
}
