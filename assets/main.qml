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
import "appmenu"

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 * 
 */

// our Root is a Tabbed Pane, where all Tabs are on ActionBar at HomePage

// all following Pages hide the TAB Navigation in the Sidebar to give the ActionBar space to ActionItems

// unfortunately I cannot hide or add/delete Tabs from QML, so the Uploads Tab is disabled instead invisible

TabbedPane {
    property bool asyncLoadingDone: false
    // login property triggered from C++ when login to server done
    property int login: -1
    // property needed to destroy it later
    property UsersNavPane createdUsersNavPane
    property variant selectionColor
    id: rootNavigationPane
    showTabsOnActionBar: true
    // these objects have to be available on all tabs
    attachedObjects: [
        // SHEETS to be used by SYSTEM MENU
        Sheet {
            id: loginSheet
            objectName: "loginSheet"
            //-- sheet GUI appearence component is defined in external LoginSheet.qml file
            content: LoginSheet {
                id: loginContent
            }
        },
        Sheet {
            id: helpSheet
            objectName: "helpSheet"
            //-- sheet GUI appearence component is defined in external HelpSheet.qml file
            content: WebPageHelpSheet {
                id: helpContent
            }
            onOpened: {
                helpContent.theURL = odsdata.helpsiteUrl()
                helpContent.developerApplication = odsdata.isDeveloperApplication()
            }
        },
        Sheet {
            id: aboutSheet
            objectName: "aboutSheet"
            content: WebPageAboutSheet {
                id: aboutContent
            }
            onOpened: {
                aboutContent.theURL = odsdata.aboutsiteUrl()
            }
        },
        Sheet {
            id: faqSheet
            objectName: "faqSheet"
            content: WebPageFAQSheet {
                id: faqContent
            }
            onOpened: {
                faqContent.theURL = odsdata.faqsiteUrl()
            }
        },
        Sheet {
            id: preferencesSheet
            objectName: "preferencesSheet"
            //-- sheet GUI appearence component is defined in external PreferencesSheet.qml file
            content: PreferencesSheet {
                id: preferencesContent
            }
            onOpened: {
                preferencesContent.testDrive = odssettings.testdrive()
            }
        },
        Sheet {
            id: feedbackSheet
            objectName: "feedbackSheet"
            //-- sheet GUI appearence component is defined in external PreferencesSheet.qml file
            content: FeedbackSheet {
                id: feedbackContent
            }
        },
        ComponentDefinition {
            id: lazyComponentDataSpaceNavPane
            DataSpaceNavPane {
                id: dataspacePane
            }
        },
        ComponentDefinition {
            id: lazyComponentUploadNavPane
            UploadNavPane {
                id: uploadPane
            }
        },
        ComponentDefinition {
            id: onDemandComponentUsersNavPane
            UsersNavPane {
                id: usersPane
            }
        },
        ComponentDefinition {
            id: appCover
            source: "AppCover.qml"
        }
    ]

    // first Tab: HomePage with custom Image as Background
    Tab {
        id: homeTab
        imageSource: "asset:///images/home81.png"
        objectName: "homeTab"
        title: qsTr("Home") + Retranslate.onLanguageChanged
        HomePage {
            id: homePage
        }
        onTriggered: {
            destroyUserTabComponent()
        }
    }
    // Tab: DataSpace with List of Rooms (DataSpace)
    // SubRooms and Folders are in Pages
    Tab {
        id: dataspaceTab
        imageSource: "asset:///images/dataspaces81.png"
        title: qsTr("Data Space") + Retranslate.onLanguageChanged
        // NO CONTENT .... will be lazy loaded after LogIn done
        onTriggered: {
            destroyUserTabComponent()
        }
    }
    // Tab: Users with List of Users
    Tab {
        id: usersTab
        title: qsTr("Users") + Retranslate.onLanguageChanged
        imageSource: "asset:///images/users81.png"
        enabled: true // TODO onlyIfCurrentUserIsAdministrator()
        // NO CONTENT
        // Users Pane only needed to manage Users
        // so we load it only on demand
        onTriggered: {
            createUserTabComponent()
        }
    }
    // Tab: Uploads with List of Files prepared for Upload
    // disabled at startup if nothing to upload
    Tab {
        id: uploadTab
        title: qsTr("Upload") + Retranslate.onLanguageChanged
        imageSource: "asset:///images/upload81.png"
        enabled: true
        // NO CONTENT .... will be lazy loaded after LogIn done
        onTriggered: {
            destroyUserTabComponent()
        }
    }
    function openPreferences() {
        preferencesSheet.open()
    }

    // FUNCTIONS for the complete TabbedPane called from the Sheets attached to TabbedPane
    // the handler SLOT if LogIn was done
    // SIGNALed from LoginSheet or called from Application
    // Card Pages also get success false to jump back to host
    function onLoginDone(success) {
        if (success) {
            rootNavigationPane.activeTab = homeTab
            loginSheet.close()
            if (! asyncLoadingDone) {
                createLazyComponents()
            }
        }
    }
    // the handler SLOT if Prefs were saved
    // SIGNALed from PrefrencesSheet
    function onSavePreferences(ok) {
        if (ok) {
            //-- when sheet is closed with success, changes should be saved
            // TODO
        }
        preferencesSheet.close()
    }
    // the handler SLOT if Prefs were saved
    // SIGNALed from PrefrencesSheet
    function onSendFeedback(ok) {
        if (ok) {
            //-- when sheet is closed with success, feedback should be sent
            // TODO
        }
        feedbackSheet.close()
    }

    // the handler  SLOT HELP done
    // SIGNALed from HelpSheet
    function closeHelp(ok) {
        helpSheet.close()
    }
    // the handler  SLOT ABOUT done
    // SIGNALed from AboutSheet
    function closeAbout(ok) {
        aboutSheet.close()
    }
    // the handler  SLOT FAQ done
    // SIGNALed from FAQSheet
    function closeFaq(ok) {
        faqSheet.close()
    }
    // these components will be created async to speed up startup time
    function createLazyComponents() {
        console.debug("create LAZY components")
        // to speedup loadtime
        //  after first Login done the dataspace Navigation Pane was instatiated
        dataspaceTab.content = lazyComponentDataSpaceNavPane.createObject()
        // Now the component is cvreated and we can do some stuff from C++
        // Now the objects will be found from findChild()
        odsdata.initRoomsModel()
        // same for Upload NavPane
        uploadTab.content = lazyComponentUploadNavPane.createObject()
        // we're done
        asyncLoadingDone = true
    }
    function createUserTabComponent() {
        console.debug("createUserTabComponent")
        createdUsersNavPane = onDemandComponentUsersNavPane.createObject()
        usersTab.content = createdUsersNavPane
        // Now the component is cvreated and we can do some stuff from C++
        // Now the objects will be found from findChild()
        odsdata.initUserModel()
    }
    function destroyUserTabComponent() {
        if (usersTab.content) {
            console.debug("destroyUserTabComponent")
            // two steps to destroy:
            // 1st step: reset the content of the Tab
            usersTab.resetContent();
            // 2nd step: destroy the created NavPane with all their childs
            createdUsersNavPane.destroy()
        }
    }
    function addUpload(name) {
        // TODO ask queue or immediately
        odsdata.simpleUpload(name)
//        uploadTab.enabled = true
//        uploadTab.newContentAvailable = true
//        uploadTab.unreadContentCount = uploadTab.unreadContentCount + 1
    }
    
    function isDark(){
        // 
        return Application.themeSupport.theme.colorTheme.style == VisualStyle.Dark
    }

    // the TabbedPane is initialized, lets do some work at startup
    onCreationCompleted: {
        // first tab (homePage) is the active Tab
        rootNavigationPane.activeTab = homeTab
        // support all orientations
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
        //-- connect the sheet done SIGNAL to the handler SLOT
        loginContent.loginDone.connect(onLoginDone)
        //-- connect the help sheet close SIGNAL to the handler SLOT
        helpContent.helpDone.connect(closeHelp)
        //-- connect the about sheet close SIGNAL to the handler SLOT
        aboutContent.aboutDone.connect(closeAbout)
        //-- connect the FAQ sheet close SIGNAL to the handler SLOT
        faqContent.faqDone.connect(closeFaq)
        //-- connect the preferences save SIGNAL to the handler SLOT
        preferencesContent.done.connect(onSavePreferences)
        //-- connect the preferences save SIGNAL to the handler SLOT
        feedbackContent.send.connect(onSendFeedback)
        // connect server-login
        odsdata.loginFinished.connect(onLoginDone)
        // minimied app cover
        Application.cover = appCover.createObject();
        // but we have to do LogIn at Startup
        // dont want to display the Shee immediately, so using a delayed animation
        // start the animation to open LoginSheet after 1 s
        homePage.loginDelayed()
        //
        if(isDark()){
            rootNavigationPane.selectionColor = Color.create(odsdata.listHighlightColorForDark())
        }else {
            rootNavigationPane.selectionColor = Color.create(odsdata.listHighlightColorForBright())
        }
        
        // 
        console.debug("DARK ? "+isDark())
    }
    // triggered from C++
    onLoginChanged: {
        console.debug("login changed: " + login);
        if (login == 1) {
            onLoginDone(true)
        } else if (login == 0) {
            onLoginDone(false)
        }
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
