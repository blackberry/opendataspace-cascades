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
#include "app.hpp"

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
App::App()
{
	// we need a system menu:
	// TODO
	// HELP will open a website with Help Instructions from OpenDataSpace
	// FEEDBACK will send an email to OpenDataSpace
	// LOGOUT will do a LogOut and jump back to HomeScreen and open the LogIn Sheet
	// SETTINGS will open the User Settings
	Menu *menu = Menu::create()
	  .addAction(ActionItem::create().title("Feedback"))
	  .addAction(ActionItem::create().title("Logout"))
	  .help(HelpActionItem::create().title("Help"))
	  .settings(SettingsActionItem::create().title("Settings"));
	Application::setMenu(menu);

	// our main QML document: the HomeScreen with a custom Background Image
	QmlDocument *qml = QmlDocument::create("main.qml");
    //-- setContextProperty expose C++ object in QML as an variable
    //-- uncomment next line to introduce 'this' object to QML name space as an 'app' variable
    //qml->setContextProperty("app", this);
    
	// the ROOT Pane
    AbstractPane *root = qml->createRootNode<AbstractPane>();
    // Open the HomeScreen
    Application::setScene(root);
    // at StartUp the LoginSheet should be displayed immediately
    // so at first I tried it this way:
    // root->setProperty("sheetVisible", true);
    // but then the Sheet is so fast opened that the User doesn't notify what happened
    // so I decided to use  a delayed animation
}
