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
 * based on ekkescorner WebPageWithProgressIndicator
 * added signal helpDone and action to close 
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Page {
    // this webpage is used as a sheet
    // this SIGNAL can be watched to know that the site should be closed (== Sheet invisible)
    signal helpDone(bool ok)
    id: webPage
    // this is the Home URL for this WebView
    property string theURL: "http://devblog.blackberry.com/"
    // Actions
    actions: [
        ActionItem {
            id: backItem
            title: qsTr("Back")+ Retranslate.onLanguageChanged
            enabled: false
            ActionBar.placement: ActionBarPlacement.OnBar
            // we reset the URL
            onTriggered: {
                // todo use internal goBack() and canGoBack() functions from C++
                webView.url = webPage.theURL
            }
        },
        ActionItem {
            title: qsTr("Close")+ Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.Default
            onTriggered: {
                helpDone(true)
            }
        }
    ]  
     
    // ScrollView to support long sites
    ScrollView {
        Container {
            layout: StackLayout {
            }
            background: Color.Black
            id: mainContainer
            // we're using an Activity Indicator on top of the Screen
            // we could also use a ActivityIndicator
            // ProgressIndicator is invisible per default
            ProgressIndicator {
                id: myIndicator
                visible: false
            }
            // the WebView displaying the Website
            WebView {
                id: webView
                url: webPage.theURL
                // if the URL was changed, we enable the ActionItem to go back
                onUrlChanged: {
                    myIndicator.visible = true
                    if (url == webPage.theURL) {
                        backItem.enabled = false
                    } else {
                        backItem.enabled = true
                    }
                }
                onLoadProgressChanged: {
                    // we show the progress
                    myIndicator.value = loadProgress / 100.0
                }
                onLoadingChanged: {
                    // just started to load
                    if (loadRequest.status == WebView.LoadStartedStatus) {
                        // Show the ProgressBar when loading started.
                        myIndicator.visible = true
                    } else if (loadRequest.status == WebView.LoadSucceededStatus) {
                        myIndicator.visible = false
                        // uuuups we failed  - give the user a notice
                    } else if (loadRequest.status == WebView.LoadFailedStatus) {
                        // If loading failed fallback to inline HTML, by setting the HTML property.                     
                        html = "<html><head><title>Fallback HTML on Loading Failed</title><style>* { margin: 0px; padding 0px; }body { font-size: 48px; font-family: monospace; border: 1px solid #444; padding: 4px; }</style> </head> <body>Oh ooh, loading failed. Perhaps you are not connected to the Internet?.</body></html>"
                        myIndicator.visible = false
                    }
                }
            } // end WebView
        }
    }
    onCreationCompleted: {
        // Overlay ActionBar
        webPage.actionBarVisibility = ChromeVisibility.Overlay
    }
}
