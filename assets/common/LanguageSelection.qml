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
        id: titleBar
        title: qsTr("Your Language") + Retranslate.onLanguageChanged
        visibility: ChromeVisibility.Visible
    }
    // need a scrollview to be able to select all in landscape
ScrollView {
    Container {
        id: mainContainer
        layout: DockLayout {
        }
        Container {
            id: languageContainer
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: StackLayout {
            }
            leftPadding: 100
            rightPadding: 100
            // The Radio Group to select the Language
            // text is readbale for users
            // value is locale used to translate
            RadioGroup {
                id: languageOptions
                dividersVisible: false
                Option {
                    id: languageDe
                    text: qsTr("German") + Retranslate.onLanguageChanged
                    value: "de"
                }
                Option {
                    id: languageEn
                    text: qsTr("English") + Retranslate.onLanguageChanged
                    value: "en"
                }
                Option {
                    id: languageEs
                    text: qsTr("Spanish") + Retranslate.onLanguageChanged
                    value: "es"
                }
                Option {
                    id: languageFr
                    text: qsTr("French") + Retranslate.onLanguageChanged
                    value: "fr"
                }
                Option {
                    id: languageIt
                    text: qsTr("Italian") + Retranslate.onLanguageChanged
                    value: "it"
                }
                Option {
                    id: languageRu
                    text: qsTr("Russian") + Retranslate.onLanguageChanged
                    value: "ru"
                }
                onSelectedIndexChanged: {
                    console.debug("New language selected: " + languageOptions.selectedValue);
                    // SIGNAL
                    languagePage.languageChanged(languageOptions.selectedValue);
                    // trigger update locale
                    ods.updateLocale(languageOptions.selectedValue)
                }
            }
        } // end Container
    } // end main container
  } // end scroll view
    // this function will be used to set the initial value of the locale
    function setLanguage(locale) {
        console.debug("initial value of language set: " + locale)
        if (locale == "de" || locale == "de_DE") {
            languageOptions.selectedIndex = 0
        } else if (locale == "es") {
            languageOptions.selectedIndex = 2
        } else if (locale == "fr") {
            languageOptions.selectedIndex = 3
        } else if (locale == "it") {
            languageOptions.selectedIndex = 4
        } else if (locale == "ru") {
            languageOptions.selectedIndex = 5
        } else {
            languageOptions.selectedIndex = 1
        }
    }
    
}
