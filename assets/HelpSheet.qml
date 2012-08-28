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
Page { 
    signal helpDone(bool ok)
    
    id: helpPage
    // Actions
        actions: [
        ActionItem {
            title: qsTr ("Close")
            ActionBar.placement: ActionBarPlacement.Default
            onTriggered: {
                helpDone(true)
            }
        }
    ]
    
    ScrollView {
	    // the main container to go to website for Help
	    Container {
	        layout: StackLayout {
	        }
	        id: mainContainer
	        WebView {
               id: webView
               url: "http://www.ssp-europe.eu/en/products/secure-data-space.html"       
           }
	    }
	}
	
	onCreationCompleted: {
        // Overlay ActionBar
        helpPage.actionBarVisibility = ChromeVisibility.Overlay
    }
}
