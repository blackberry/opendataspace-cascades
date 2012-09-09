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

#include <QImage>
#include <QImageReader>

#include <bb/system/InvokeManager.hpp>
#include <bb/system/InvokeRequest.hpp>

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/TabbedPane>
#include <bb/cascades/Menu>
#include <bb/cascades/ActionItem>
#include <bb/cascades/HelpActionItem>
#include <bb/cascades/SettingsActionItem>
#include <bb/cascades/multimedia/Camera>

#include <bps/soundplayer.h>
#include <bps/virtualkeyboard.h>

using namespace bb::cascades;
using namespace bb::cascades::multimedia;
using namespace bb::system;

/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
OpenDataSpaceApp::OpenDataSpaceApp() :
		m_app(NULL), m_currentLocale("en"), m_translator(
				NULL)

{

	// we need a system menu:
	Menu* menu = createSystemMenu();

	Application::setMenu(menu);

	// We need to register the QML types in the multimedia-library,
	// otherwise we will get an error from the QML.
	Camera::registerQmlTypes();

	// our main QML document: the HomeScreen with a custom Background Image
	QmlDocument *qml = QmlDocument::create("main.qml");
	//-- setContextProperty expose C++ object in QML as an variable
	//-- uncomment next line to introduce 'this' object to QML name space as an 'app' variable
	qml->setContextProperty("ods", this);

	// the ROOT Pane
	root = qml->createRootNode<TabbedPane>();

	// Open the HomeScreen
	Application::setScene(root);
	// at StartUp the LoginSheet should be displayed immediately
	// so at first I tried it this way:
	// root->setProperty("sheetVisible", true);
	// but then the Sheet is so fast opened that the User doesn't notify what happened
	// so I decided to use  a delayed animation

	// initialize the camera
	Camera *camera = root->findChild<Camera*>("odsCamera");
	if (camera) {
		qDebug() << "odsCamera child found";

		QObject::connect(camera, SIGNAL(shutterFired()), this,
				SLOT(onShutterFired()));
	} else {
		// TODO give some feedback to user
		qDebug() << "odsCamera child N O T  found";
	}
	// initialize the videocamera
	Camera *videocamera = root->findChild<Camera*>("odsVideo");
	if (videocamera) {
		qDebug() << "odsVideo child found";

		QObject::connect(videocamera, SIGNAL(shutterFired()), this,
				SLOT(onShutterFired()));
	} else {
		// TODO give some feedback to user
		qDebug() << "odsVideo child N O T found";
	}
	// TODO collect problems in a healthyStatus list to be displayed from PreferencesPage

}

// INTERNATIONALIZATION
/**
 * void App::setApplication(bb::cascades::Application* app, QTranslator* translator, QString currentLocale)
 *
 * This method allows to change translation engine basing on the given locale
 * at runtime.
 *
 */
void OpenDataSpaceApp::setApplication(bb::cascades::Application* app,
		QTranslator* translator, QString currentLocale) {
	m_app = app;
	m_translator = translator;
	m_currentLocale = currentLocale;
	updateLocale(currentLocale);

	//update certain controls to reflect the correct state
	// not yet needed
}

/**
 * App::updateLocale(QString locale)
 *
 * Update view content basing on the given locale.
 *
 */
void OpenDataSpaceApp::updateLocale(QString locale) {
	qDebug() << "updateLocale: " << locale;
	if (!m_app) {
		qDebug() << "updateLocale: app pointer not valid";
		return;
	}

	if (!m_translator) {
		qDebug() << "updateLocale: translator pointer not valid";
		return;
	}

	// if locale is empty - refresh current. otherwise change the local
	if (!locale.trimmed().isEmpty() && m_currentLocale != locale) {
		m_currentLocale = locale;

		qDebug() << "updating UI to language: " << m_currentLocale;
		QString filename = QString("Internationalization_%1").arg(
				m_currentLocale);
		if (m_translator->load(filename, "app/native/qm")) {
			// multiple translators can be installed but for this
			// app we only use one translator instance for brevity
			m_app->removeTranslator(m_translator);
			m_app->installTranslator(m_translator);
		}
	}

	// re-translate controls.
	// not yet done

}

/**
 * App::getCurrentLanguage()
 *
 * Retrieve the language name corresponding to the current locale.
 */
QString OpenDataSpaceApp::getCurrentLanguage() {
	qDebug() << "getCurrentLanguage: " << m_currentLocale;
	if (m_currentLocale == "de" || m_currentLocale == "de_DE" || m_currentLocale == "de_AT" || m_currentLocale == "de_CH") {
		return tr("German");
	} else {
		return tr("English");
	}
}

/**
 * App::suppressKeyboard()
 *
 * A helper function to force the keyboard to hide
 */
void OpenDataSpaceApp::suppressKeyboard() {
	virtualkeyboard_request_events(0);
	virtualkeyboard_hide();
}

// M E N U
// SystemMenu is available on all Screens
Menu* OpenDataSpaceApp::createSystemMenu() {
	// HELP will open a website with Help Instructions from OpenDataSpace
	HelpActionItem* helpItem = new HelpActionItem();
	helpItem->setTitle(tr("Help"));
	// FEEDBACK will send an email to OpenDataSpace
	ActionItem* feedbackItem = new ActionItem();
	feedbackItem->setTitle(tr("Feedback"));
	feedbackItem->setImageSource(
			QString("asset:///images/ics/5-content-email81.png"));
	// LOGOUT will do a LogOut and jump back to HomeScreen and open the LogIn Sheet
	ActionItem* logoutItem = new ActionItem();
	logoutItem->setTitle(tr("Logout"));
	logoutItem->setImageSource(
			QString("asset:///images/ics/10-device-access-accounts81.png"));
	// SETTINGS will open the User Settings
	SettingsActionItem* settingsItem = new SettingsActionItem();
	settingsItem->setTitle(tr("Settings"));
	// plug it all together
	Menu* menu =
			Menu::create().addAction(feedbackItem).addAction(logoutItem).help(
					helpItem).settings(settingsItem);
	// Connect SIGNALS and SLOTS
	QObject::connect(logoutItem, SIGNAL(triggered()), this,
			SLOT(logoutTriggered()));
	QObject::connect(feedbackItem, SIGNAL(triggered()), this,
			SLOT(feedbackTriggered()));
	QObject::connect(helpItem, SIGNAL(triggered()), this,
			SLOT(helpTriggered()));
	QObject::connect(settingsItem, SIGNAL(triggered()), this,
			SLOT(settingsTriggered()));
	return menu;
}

// S L O T S
// handles SLOT from logoutItem
void OpenDataSpaceApp::logoutTriggered() {
	root->setProperty("loginSheetVisible", true);
}

// handles SLOT from feedbackItem
void OpenDataSpaceApp::feedbackTriggered() {
	root->setProperty("feedbackSheetVisible", true);
}

// handles SLOT from helpItem
void OpenDataSpaceApp::helpTriggered() {
	// en: http://www.ssp-europe.eu/en/products/secure-data-space.html
	// de: http://www.ssp-europe.eu/produkte/secure-data-space.html
	root->setProperty("helpSheetVisible", true);
}

// handles SLOT from settingsItem
void OpenDataSpaceApp::settingsTriggered() {
	root->setProperty("preferencesSheetVisible", true);
}

void OpenDataSpaceApp::onShutterFired() {
	// A cool trick here to play a sound. There is legal requirements in many countries to have a shutter-sound when
	// taking pictures and we need this is needed if you are planning to submit you're app to app world.
	soundplayer_play_sound("event_camera_shutter");
}

void OpenDataSpaceApp::showInPicturesApp(QString fileName) {
	// Here we create a invoke request to the pictures app.
	// we could also ask the system what other applications can
	// receive something of our mimeType.
	// the pictures app will come pre-installed so it's a safe bet.
	qDebug() << "ShowInPicturesApp called";
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.OPEN");
	invokeRequest.setTarget("sys.pictures.app");
	invokeRequest.setMimeType("images/jpeg");
	invokeRequest.setUri(
			QString("%1%2").arg("photos:").arg(fileName.remove(0, 7)));

	InvokeManager invokeManager;
	invokeManager.invoke(invokeRequest);
}

void OpenDataSpaceApp::showInVideosApp(QString fileName) {
	// TODO only guessing yet
	qDebug() << "showInVideoApp called: " + fileName;
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.OPEN");
	invokeRequest.setTarget("sys.videos.app");
	invokeRequest.setMimeType("images/mp4");
	invokeRequest.setUri(
			QString("%1%2").arg("videos:").arg(fileName.remove(0, 7)));

	InvokeManager invokeManager;
	invokeManager.invoke(invokeRequest);
}

