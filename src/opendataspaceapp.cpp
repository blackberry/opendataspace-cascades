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
#include "opendataspaceapp.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/Menu>
#include <bb/cascades/ActionItem>
#include <bb/cascades/HelpActionItem>
#include <bb/cascades/SettingsActionItem>

using namespace bb::cascades;



/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/
OpenDataSpaceApp::OpenDataSpaceApp()
{

	// we need a system menu:
	Menu* menu = createSystemMenu();

	Application::setMenu(menu);

	// our main QML document: the HomeScreen with a custom Background Image
	QmlDocument *qml = QmlDocument::create("main.qml");
    //-- setContextProperty expose C++ object in QML as an variable
    //-- uncomment next line to introduce 'this' object to QML name space as an 'app' variable
    //qml->setContextProperty("app", this);
    
	// the ROOT Pane
	root = qml->createRootNode<Page>();

    // Open the HomeScreen
    Application::setScene(root);
    // at StartUp the LoginSheet should be displayed immediately
    // so at first I tried it this way:
    // root->setProperty("sheetVisible", true);
    // but then the Sheet is so fast opened that the User doesn't notify what happened
    // so I decided to use  a delayed animation
}

// SystemMenu is available on all Screens
Menu* OpenDataSpaceApp::createSystemMenu() {
	// HELP will open a website with Help Instructions from OpenDataSpace
	HelpActionItem* helpItem = new HelpActionItem();
	helpItem->setTitle("Help");
	// TODO Image
	// FEEDBACK will send an email to OpenDataSpace
	ActionItem* feedbackItem = new ActionItem();
	feedbackItem->setTitle("Feedback");
	// TODO Image
	// LOGOUT will do a LogOut and jump back to HomeScreen and open the LogIn Sheet
	ActionItem* logoutItem = new ActionItem();
	logoutItem->setTitle("Logout");
	// TODO IMAGE
	// SETTINGS will open the User Settings
	SettingsActionItem* settingsItem = new SettingsActionItem();
	settingsItem->setTitle("Help");
	// TODO Image
	// plug it all together
	Menu* menu = Menu::create()
			.addAction(feedbackItem)
			.addAction(logoutItem)
			.help(helpItem)
			.settings(settingsItem);
	// Connect SIGNALS and SLOTS
	QObject::connect(logoutItem, SIGNAL(triggered()), this, SLOT(logoutTriggered()));
	QObject::connect(feedbackItem, SIGNAL(triggered()), this, SLOT(feedbackTriggered()));
	QObject::connect(helpItem, SIGNAL(triggered()), this, SLOT(helpTriggered()));
	QObject::connect(settingsItem, SIGNAL(triggered()), this, SLOT(settingsTriggered()));
	return menu;
}

// handles SLOT from logoutItem
void OpenDataSpaceApp::logoutTriggered(){
	root->setProperty("sheetVisible", true);
}

// handles SLOT from feedbackItem
void OpenDataSpaceApp::feedbackTriggered(){
	// TODO root->setProperty("sheetVisible", true);
}

// handles SLOT from helpItem
void OpenDataSpaceApp::helpTriggered(){
	// TODO root->setProperty("sheetVisible", true);
	// en: http://www.ssp-europe.eu/en/products/secure-data-space.html
	// de: http://www.ssp-europe.eu/produkte/secure-data-space.html

}

// handles SLOT from settingsItem
void OpenDataSpaceApp::settingsTriggered(){
	// TODO root->setProperty("sheetVisible", true);
}
