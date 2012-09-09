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
 * Container to select the language
 * used from a NavigationPane
 * if selection changes a SIGNAL will be sent
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    // SIGNAL if language selection changed
    signal languageChanged(string locale)
    id: languagePage
    titleBar: TitleBar {
        id: addBar
        title: qsTr("Your Language")
        visibility: ChromeVisibility.Visible
    }
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        Container {
            id: languageContainer
            layoutProperties: DockLayoutProperties {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
            }
            layout: StackLayout {
                leftPadding: 100
                rightPadding: 100
            }
            // The Radio Group to select the Language
            // text is readbale for users
            // value is locale used to translate
            RadioGroup {
                id: languageOptions
                dividersVisible: false
                Option {
                    id: languageDe
                    text: qsTr("German")
                    value: "de"
                }
                Option {
                    id: languageEn
                    text: qsTr("English")
                    value: "en"
                }
                onSelectedIndexChanged: {
                    console.debug("New language selected: " + languageOptions.selectedValue());
                    // SIGNAL
                    languagePage.languageChanged(languageOptions.selectedValue());
                    ods.updateLocale(languageOptions.selectedValue())
                }
            }
        } // end Container
    } // end main container
    // this function will be used to set the initial value of the locale
    function setLanguage(locale) {
        console.debug("initial value of language set: "+locale)
        if (locale == "de") {
            languageOptions.selectedIndex = 0
        } else {
            languageOptions.selectedIndex = 1
        }
    }
}
