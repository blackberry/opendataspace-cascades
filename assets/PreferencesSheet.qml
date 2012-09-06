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
import "common"

/*
 * Preferences and Options set by the user
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

// we're using a NavigationPane to be able to push/pop Pages with special editors like language selection

NavigationPane {
    // SIGNAL
    signal done(bool ok)
    // the current locale - can be set from outside
    property string currentLanguage: "de"
    // the current customer - can be set from outside
    property string currentCustomer: "Musterfirma GmbH"
    id: navigationPane
    attachedObjects: [
        // special editor to select the Language
        LanguageSelection {
            id: languageSelection
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        },
        // special editor to select the Customer
        CustomerSelection {
            id: customerSelection
            paneProperties: NavigationPaneProperties {
                backButton: ActionItem {
                    onTriggered: {
                        navigationPane.pop();
                    }
                }
            }
        }
    ]
    Page {
        
        // seems not to work
        resizeBehavior: PageResizeBehavior.Resize
        titleBar: TitleBar {
            id: theBar
            title: qsTr("Preferences")
            visibility: ChromeVisibility.Visible
            dismissAction: ActionItem {
                title: qsTr("Cancel")
                onTriggered: {
                    navigationPane.done(false);
                }
            }
            acceptAction: ActionItem {
                title: qsTr("Save")
                onTriggered: {
                    navigationPane.done(true);
                }
            }
        }
        // 
        Container {
            layout: DockLayout {
            }
            id: mainContainer
            //ScrollView {
            Container {
                id: fieldsContainer
                layout: StackLayout {
                    topPadding: 25
                    leftPadding: 25
                    rightPadding: 25
                    layoutDirection: LayoutDirection.TopToBottom
                }
                TextField {
                    id: email
                    hintText: qsTr("Please enter your email address")
                    inputMode: TextFieldInputMode.EmailAddress
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                // Label displays the current selected customer
                Label {
                    id: customerLabel
                    text: qsTr("Musterfiirma GmbH")
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                    // open the language editor
                    onTouch: {
                        customerSelection.setCustomer(navigationPane.currentCustomer)
                        navigationPane.push(customerSelection)
                    }
                }
                
                // Label displays the current Locale
                Label {
                    id: languageLabel
                    text: qsTr("German")
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                    // open the language editor
                    onTouch: {
                        languageSelection.setLanguage(navigationPane.currentLanguage)
                        navigationPane.push(languageSelection)
                    }
                }
                TextField {
                    id: server
                    hintText: qsTr("Please enter your Server URL")
                    inputMode: TextFieldInputMode.URL
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                Label {
                    id: uploadLabel
                    text: "1.6 MB " + qsTr("Files to upload")
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                // TODO red-green bar to indicat the usage
                Label {
                    id: memoryUsedLabel
                    text: "257.0 MB " + qsTr("of") + " 10.0 GB " + qsTr("Memory used")
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.BodyText
                    }
                }
                // TODO red-green bar to indicat the usage
                Label {
                    id: versionLabel
                    text: qsTr("Version") + " 1.3.2"
                    leftMargin: 20
                    textStyle {
                        base: SystemDefaults.TextStyles.SmallText
                    }
                }
            }
            //} // ScrollView
        }
    }
    // SLOTS
    function newLanguage(locale) {
        console.debug("new locale: " + locale)
        navigationPane.currentLanguage = locale
        if (locale == "de") {
            languageLabel.text = qsTr("German")
        } else {
            languageLabel.text = qsTr("English")
        }
    }
    function newCustomer(name) {
        console.debug("new customer: " + name)
        navigationPane.currentCustomer = name
        customerLabel.text = name
    }
    onCreationCompleted: {
        //-- connect the preferences save SIGNAL to the handler SLOT
        languageSelection.languageChanged.connect(navigationPane.newLanguage)
        customerSelection.customerChanged.connect(navigationPane.newCustomer)
    }
}
