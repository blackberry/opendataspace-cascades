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
import "rooms"
import "users"
import "upload"
import "webpages"

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

// our Root is a Tabbed Pane, where all Tabs are on ActionBar at HomePage

// all following Pages hide the TAB Navigation in the Sidebar to give the ActionBar space to ActionItems

// unfortunately I cannot hide or add/delete Tabs from QML, so the Uploads Tab is disabled instead invisible

TabbedPane {
    id: rootNavigationPane
    showTabsOnActionBar: true
    // allow setting these Sheets to visible from C++ (SystemMenu)
    property alias loginSheetVisible: loginSheet.visible
    property alias helpSheetVisible: helpSheet.visible
    // these objects have to be available on all tabs
    attachedObjects: [
        // SHEETS to be used by SYSTEM MENU
        Sheet {
            id: loginSheet
            //-- sheet GUI appearence component is defined in external LoginSheet.qml file
            content: LoginSheet {
                id: loginContent
            }
        },
        Sheet {
            id: helpSheet
            //-- sheet GUI appearence component is defined in external HelpSheet.qml file
            content: WebPageHelpSheet {
                id: helpContent
                // theURL is a custom property to allow setting the URL fro  outside or inside the QML file
                theURL: "http://www.ssp-europe.eu/en/products/secure-data-space.html"
            }
        }
    ]

    // first Tab: HomePage with custom Image as Background
    Tab {
        id: homeTab
        objectName: "homeTab"
        title: qsTr("Home")
        HomePage {
            id: homePage
        }
    } 
    // Tab: Rooms with List of Rooms (DataSpace)
    Tab {
        id: roomsTab
        title: qsTr("Rooms")
        RoomsNavPane {
            id: roomsPane
        }
    }
    // Tab: Users with List of Users
    // TODO only enabled if Admin
    Tab {
        id: usersTab
        title: qsTr("Users")
        UsersNavPane {
            id: usersPane
        }
    }
    // Tab: Uploads with List of Files prepared for Upload
    // disabled at startup if nothing to upload
    Tab {
        id: uploadTab
        title: qsTr("Upload")
        enabled: false
        UsersNavPane {
            id: uploadPane
        }
    }
	
    // FUNCTIONS for the complete TabbedPane called from the Sheets attached to TabbedPane
    // the handler SLOT if LogIn was done
    // SIGNALed from LoginSheet
    function saveEdits(ok) {
        if (ok) {
            //-- when sheet is closed with success, login was OK
            // TODO
        } else {
            // TODO bring back the LogIn and perhaps a Dialog
        }
        rootNavigationPane.activeTab = homeTab
        loginSheet.visible = false
    }
    // the handler  SLOT HELP done
    // SIGNALed from HelpSheet
    function closeHelp(ok) {
        helpSheet.visible = false
    }
    
    // the TabbedPane is initialized, lets do some work at startup
    onCreationCompleted: {
        // first tab (homePage) is the active Tab
        rootNavigationPane.activeTab = homeTab
        // support all orientations
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //-- connect the sheet done SIGNAL to the handler SLOT
        loginContent.done.connect(saveEdits)
        //-- connect the help sheet close SIGNAL to the handler SLOT
        helpContent.helpDone.connect(closeHelp)
        // at startup no Sheets should be visible
        helpSheet.visible = false
        loginSheet.visible = false
        // but we have to do LogIn at Startup
        // dont want to display the Shee immediately, so using a delayed animation
        // start the animation to open LoginSheet after 1 s
        homePage.loginDelayed()
    }

    // special things to be happened if user changes the Tab
    onActiveTabChanged: {
        if (rootNavigationPane.activeTab == homeTab) {
            // on on HomeTab all tabs should be visible in ActionBar
            // so the user knows what's there
            rootNavigationPane.showTabsOnActionBar = true
        } else {
            // all other Tabs give the space of ActionBar to Actionitems and hide the Tabs in Sidebar
            rootNavigationPane.showTabsOnActionBar = false
        }
    }
}
