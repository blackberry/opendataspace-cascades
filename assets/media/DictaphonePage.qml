/* Copyright (c) 2012 Research In Motion Limited.
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
 * 
 * Initial Contribution from RIM: Dictaphone (Cascades Samples)
 * Integrated, changed and enhanced for OpenDataSpace by:
 * Copyright (c) 2012 SSP Europe GmbH, Munich
 * Author: Ekkehard Gentz (ekke) @ekkescorner http://ekkes-corner.org
 */

import bb.cascades 1.0
import bb.multimedia 1.0
import org.opendataspace.trackmanager 1.0
import bb.cascades.pickers 1.0

/**
 *    added support for orientation Landscape / Portrait
 *    Ekkehard Gentz (ekke) @ekkescorner http://ekkes-corner.org
 * 
 *    did some changes and enhancements to integrate Dictaphone functionality into this app
 */

Page {
    signal addAudiofile(string path)
    id: dictaphonePage
    actionBarVisibility: ChromeVisibility.Overlay
    Container {
        layout: DockLayout {
        }

        // The background image
        ImageView {
            id: imageBackground
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            imageSource: "asset:///images/dictaphone/background.png"
        }

        // The led object
        Led {
            id: led
            horizontalAlignment: HorizontalAlignment.Left
            verticalAlignment: VerticalAlignment.Top
            translationX: 40
            translationY: 500
            state: (recorder.mediaState == MediaState.Started ? "rec" : recorder.mediaState == MediaState.Paused ? "pause" : "off")
        }

        // The tape object
        Tape {
            id: tape
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
            translationY: 570
            running: (recorder.mediaState == MediaState.Started)
        }

        // The 'dictaphone' label
        ImageView {
            id: label
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Top
            translationY: -205
            imageSource: "asset:///images/dictaphone/dictaphone_label.png"
        }

        // The background image of the button container
        ImageView {
            id: buttonBackground
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            imageSource: "asset:///images/dictaphone/buttons_background.png"
        }

        // The button container
        Container {
            id: buttonContainer
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Bottom
            preferredWidth: 670
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }

            // The 'Record' button
            ImageToggleButton {
                rightMargin: 2
                imageSourceDefault: "asset:///images/dictaphone/rec_button.png"
                imageSourcePressedUnchecked: "asset:///images/dictaphone/rec_button.png"
                imageSourceChecked: "asset:///images/dictaphone/rec_button_pressed.png"
                imageSourcePressedChecked: "asset:///images/dictaphone/rec_button_pressed.png"
                imageSourceDisabledChecked: "asset:///images/dictaphone/rec_button_pressed.png"
                enabled: (recorder.mediaState != MediaState.Paused)
                onCheckedChanged: {
                    if (recorder.mediaState == MediaState.Started) {
                        // Stop the recorder
                        recorder.reset()

                        // Update the internal track list
                        trackmanager.update()

                        // Play the finished sound
                        recordStopSound.play()
                    } else {
                        // Update the internal track list
                        trackmanager.update()

                        // Configure the recorder to use a new URL
                        saver.open()
                        // TODO recorder.outputUrl = saver.selectedFile   // trackmanager.nextTrackUrl()
                        //

                        // Play the start sound
                        // TODO recordStartSound.play()

                        // Start the recorder
                        // TODO recorder.record()
                    }
                }
            }

            // The 'Pause' button
            ImageToggleButton {
                leftMargin: 2
                rightMargin: 2
                imageSourceDefault: "asset:///images/dictaphone/pause_button.png"
                imageSourceDisabledUnchecked: "asset:///images/dictaphone/pause_button.png"
                imageSourcePressedUnchecked: "asset:///images/dictaphone/pause_button.png"
                imageSourceChecked: "asset:///images/dictaphone/pause_button_pressed.png"
                imageSourcePressedChecked: "asset:///images/dictaphone/pause_button_pressed.png"
                enabled: (recorder.mediaState == MediaState.Started || recorder.mediaState == MediaState.Paused)
                onCheckedChanged: {
                    if (recorder.mediaState == MediaState.Started) recorder.pause(); else recorder.record()
                }
            }

            // The 'Play' button
            ImageButton {
                leftMargin: 2
                defaultImageSource: "asset:///images/dictaphone/play_button.png"
                pressedImageSource: "asset:///images/dictaphone/play_button_pressed.png"
                disabledImageSource: "asset:///images/dictaphone/play_button.png"
                enabled: (trackmanager.hasRecordedTracks 
                    && recorder.mediaState != MediaState.Started 
                    && recorder.mediaState != MediaState.Paused)
                onClicked: {
                    console.debug("PLAY clicked")
                    navigationPane.pushPlayerListPage(trackmanager.model)
                }
            }
        }
    }
    attachedObjects: [
        // the recorder
        AudioRecorder {
            id: recorder
        },
        // some sounds
        SystemSound {
            id: recordStartSound
            sound: SystemSound.RecordingStartEvent
        },
        SystemSound {
            id: recordStopSound
            sound: SystemSound.RecordingStopEvent
        },
        TrackManager {
            id: trackmanager
        },
        FilePicker {
            id: saver
            property string selectedFile
            title: qsTr("Save Voice as...")
            mode: FilePickerMode.Saver // pickerMode.selectedValue
            type: FileType.Other // pickerType.selectedValue
            viewMode: ViewMode.Default // pickerViewMode.selectedValue
            sortBy: FilePickerSortFlag.Default // pickerSortBy.selectedValue
            sortOrder: FilePickerSortOrder.Default // pickerSortOrder.selectedValue
            directories : ["/accounts/1000/shared/voice"]
            onFileSelected: {
                selectedFile = selectedFiles[0]
                recorder.outputUrl = selectedFile
                recordStartSound.play()
                recorder.record()
            }
        },
        // application supports changing the Orientation
        OrientationHandler {
            // onOrientationChanged: { should be this from docs, but onOrientationAboutToChange runs smoother
            onOrientationAboutToChange: {
                console.debug("onOrientationAboutToChange")
                dictaphonePage.reLayout(orientation);
            }
        }
    ]
    // change positions of UI controls for Portrait/Landscape
    function reLayout(orientation) {
        if (orientation == UIOrientation.Landscape) {
            console.debug("reLayout to LANDSCAPE")
            imageBackground.imageSource = "asset:///images/dictaphone/background_landscape.png"
            led.translationY = 40
            tape.translationY = 35 // 120
            tape.translationX = -30
            tape.horizontalAlignment = HorizontalAlignment.Right
            label.verticalAlignment = VerticalAlignment.Top
            label.translationY = 50
            label.translationX = -360 // 260
            buttonBackground.horizontalAlignment = HorizontalAlignment.Right
            buttonBackground.translationX = -40
            buttonBackground.translationY = -100
            buttonContainer.horizontalAlignment = HorizontalAlignment.Right
            buttonContainer.translationX = -40
            buttonContainer.translationY = -100
            console.debug("reLayout to LANDSCAPE DONE")
        } else {
            console.debug("reLayout to PORTRAIT")
            imageBackground.imageSource = "asset:///images/dictaphone/background.png"
            led.translationY = 40
            tape.translationY = 530
            tape.translationX = 0
            tape.horizontalAlignment = HorizontalAlignment.Center
            label.verticalAlignment = VerticalAlignment.Bottom
            label.translationY = -20 //-205
            label.translationX = 20
            buttonBackground.horizontalAlignment = HorizontalAlignment.Center
            buttonBackground.translationX = 0
            buttonBackground.translationY = -140
            buttonContainer.horizontalAlignment = HorizontalAlignment.Center
            buttonContainer.translationX = 0
            buttonContainer.translationY = -140
            console.debug("reLayout to PORTRAIT DONE")
        }
    }
    onCreationCompleted: {
        // first layouting
        reLayout(OrientationSupport.orientation);
    }
}
