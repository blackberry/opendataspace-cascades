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
#include "applicationui.hpp"

#include "FileInfo.hpp"
#include "DateUtil.hpp"
#include "ODSData.hpp"
#include "ODSUser.hpp"
#include "ODSSettings.hpp"
#include "Singleton.hpp"

#include <bb/system/SystemCredentialsPrompt>
#include <bb/system/SystemDialog>
#include <bb/system/SystemPrompt>
#include <bb/system/SystemToast>
#include <bb/system/SystemUiButton>
#include <bb/system/SystemUiError>
#include <bb/system/SystemUiInputField>
#include <bb/system/SystemUiInputMode>
#include <bb/system/SystemUiPosition>
#include <bb/system/SystemUiResult>
#include <bb/system/InvokeManager.hpp>
#include <bb/system/InvokeRequest.hpp>

#include <bb/device/DisplayInfo.hpp>

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>

#include <bb/cascades/controls/navigationpane.h>
#include <bb/cascades/controls/tabbedpane.h>
#include <bb/cascades/LocaleHandler>
#include <bb/cascades/Menu>
#include <bb/cascades/ActionItem>
#include <bb/cascades/HelpActionItem>
#include <bb/cascades/SettingsActionItem>
#include <bb/cascades/Sheet>

#include <bb/cascades/pickers/FilePicker>
#include <bb/cascades/pickers/FilePickerMode>
#include <bb/cascades/pickers/FilePickerSortFlag>
#include <bb/cascades/pickers/FilePickerSortOrder>
#include <bb/cascades/pickers/FileType>
#include <bb/cascades/pickers/FilePickerViewMode>

#include <bps/virtualkeyboard.h>

using namespace bb::cascades;
using namespace bb::system;

ApplicationUI::ApplicationUI(bb::cascades::Application *app)
: QObject(app), mInvokeManager(new InvokeManager(this))
{
	// BUG in SDK: IDE reports error with bb::system::, but compiles and runs
	// removing bb::system:: compiles also well but running says "signal not found"
	// ODS is a Invocation Target
	bool ok = connect(mInvokeManager,
			SIGNAL(invoked(const bb::system::InvokeRequest&)), this,
			SLOT(handleInvoke(const bb::system::InvokeRequest&)));
	if (!ok) {
		qDebug() << "connect handleInvoke failed";
	}
	ok = connect(mInvokeManager,
			SIGNAL(cardResizeRequested(const bb::system::CardResizeMessage&)),
			this, SLOT(handleCardResize(const bb::system::CardResizeMessage&)));
	if (!ok) {
		qDebug() << "connect handleCardResize failed";
	}
	ok = connect(mInvokeManager,
			SIGNAL(cardPooled(const bb::system::CardDoneMessage&)), this,
			SLOT(handleCardPooled(const bb::system::CardDoneMessage&)));
	if (!ok) {
		qDebug() << "connect handleCardPooled failed";
	}

	// register the MyListModel C++ type to be visible in QML

	// Register some classes for Filepicker for QML
	qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1,
			0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>(
			"bb.cascades.pickers", 1, 0, "FilePickerMode", "");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerSortFlag>(
			"bb.cascades.pickers", 1, 0, "FilePickerSortFlag", "");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerSortOrder>(
			"bb.cascades.pickers", 1, 0, "FilePickerSortOrder", "");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>(
			"bb.cascades.pickers", 1, 0, "FileType", "");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerViewMode>(
			"bb.cascades.pickers", 1, 0, "FilePickerViewMode", "");

	// Register the FileInfo, so QML knows about
	qmlRegisterType<FileInfo>("org.opendataspace.fileinfo", 1, 0, "FileInfo");

	// Register the DateUtil, so QML knows about
	qmlRegisterType<DateUtil>("org.opendataspace.dateutil", 1, 0, "DateUtil");

	// register system dialogs
	qmlRegisterType<SystemUiButton>("bb.system", 1, 0, "SystemUiButton");
	qmlRegisterType<SystemUiInputField>("bb.system", 1, 0,
			"SystemUiInputField");
	qmlRegisterType<SystemToast>("bb.system", 1, 0, "SystemToast");
	qmlRegisterType<SystemPrompt>("bb.system", 1, 0, "SystemPrompt");
	qmlRegisterType<SystemCredentialsPrompt>("bb.system", 1, 0,
			"SystemCredentialsPrompt");
	qmlRegisterType<SystemDialog>("bb.system", 1, 0, "SystemDialog");
	qmlRegisterUncreatableType<SystemUiError>("bb.system", 1, 0,
			"SystemUiError", "");
	qmlRegisterUncreatableType<SystemUiResult>("bb.system", 1, 0,
			"SystemUiResult", "");
	qmlRegisterUncreatableType<SystemUiPosition>("bb.system", 1, 0,
			"SystemUiPosition", "");
	qmlRegisterUncreatableType<SystemUiInputMode>("bb.system", 1, 0,
			"SystemUiInputMode", "");
	qmlRegisterUncreatableType<SystemUiModality>("bb.system", 1, 0,
			"SystemUiModality", "");
	qRegisterMetaType<SystemUiResult::Type>("bb::system::SystemUiResult::Type");

	// now the data models and classes
	// Register the FileInfo, so QML knows about
	qmlRegisterType<ODSUser>("org.opendataspace.user", 1, 0, "ODSUser");

	qDebug() << "registered types for QML";

	// we have different root objects
	QString qmlDocument;
	switch (mInvokeManager->startupMode()) {
	case ApplicationStartupMode::LaunchApplication:
		// the normal Launch
		// our main QML document: the HomeScreen with a custom Background Image
		mIsLaunchedEmbedded = false;
		mIsCard = false;
		qmlDocument = "asset:///main.qml";
		qDebug() << "ApplicationStartupMode: LAUNCHED from homescreen";
		break;
	case ApplicationStartupMode::InvokeApplication:
		// Invocation. Someone Opened the App thru Invocation
		// our main QML document: the HomeScreen with a custom Background Image
		mIsLaunchedEmbedded = false;
		mIsCard = false;
		qmlDocument = "asset:///main.qml";
		qDebug() << "ApplicationStartupMode: LAUNCHED from Invocation";
		break;
	case ApplicationStartupMode::InvokeCard:
		// Card Opened by another App
		// the APP is now running embedded and invisible for the user
		// we only need a small part of the functionality,
		// so we use a different root object
		mIsLaunchedEmbedded = true;
		mIsCard = true;
		qmlDocument = "asset:///UploadCard.qml";
		qDebug() << "ApplicationStartupMode: LAUNCHED as CARD";
		break;
	default:
		// our main QML document: the HomeScreen with a custom Background Image
		mIsLaunchedEmbedded = false;
		mIsCard = false;
		qmlDocument = "asset:///main.qml";
		break;
	}

	QmlDocument *qml = QmlDocument::create(qmlDocument).parent(this);
	qDebug() << "created QML Document";

	//-- setContextProperty expose C++ object in QML as an variable
	// doesn't matter which root object - we always refer as 'ods' to this
	qml->setContextProperty("ods", this);
	// access to the settings
	//mOdsSettings = new ODSSettings();
	mOdsSettings = &Singleton<ODSSettings>::Instance();
	qml->setContextProperty("odssettings", mOdsSettings);
	// we need also access to the data
	mOdsData = new ODSData();
	qml->setContextProperty("odsdata", mOdsData);

	ok = connect(mOdsData, SIGNAL(shareLinkWithBBM(const QString&)), this,
			SLOT(shareTextWithBBM(const QString&)));
	if (!ok) {
		qDebug() << "connect shareTextWithBBM failed";
	}

	ok = connect(mOdsData, SIGNAL(shareLinkWithMail(const QString&)), this,
			SLOT(shareTextWithMail(const QString&)));
	if (!ok) {
		qDebug() << "connect shareTextWithMail failed";
	}

	// create root object for the UI
	// all our root objects are a NavigationPane or a TabbedPane
	AbstractPane *root = qml->createRootObject<AbstractPane>();
	qDebug() << "created root object";

	Application::instance()->setScene(root);
	qDebug() << "set the scene";

	if (!mIsLaunchedEmbedded) {
		initTheApplication();
	} else {
		qDebug() << "we are running EMBEDDED";
	}
	qDebug() << "INIT done";
}

/**
 * Q10 support - also working on 10.0
 */
bool ApplicationUI::isSquare() {
	bb::device::DisplayInfo display;
	if (display.pixelSize().width() == 720
			&& display.pixelSize().height() == 720) {
		qDebug() << "Q 1 0";
		return true;
	} else {
		qDebug() << "Z 1 0";
		return false;
	}
}

/**
 * some stuff we only need if Opened from HomeScreen
 * or Invoked as Application from another app thru Invocation Framework
 */
void ApplicationUI::initTheApplication() {
	qDebug() << "we are NOT running EMBEDDED, so do some APPLICATION stuff";
	// ApplicationMenu
	// Hint: first set the scene - then set the menu
	Menu* menu = createApplicationMenu();
	qDebug() << "created ApplicationMenu";

	Application::instance()->setMenu(menu);
	qDebug() << "set ApplicationMenu";

	// first translation
	translateMenuItems();
	qDebug() << "did first translations";

	//
	Application *app = Application::instance();
	bool ok = connect(app, SIGNAL(thumbnail()), this, SLOT(onThumbnail()));
	if (!ok) {
		qDebug() << "connect thumbnail failed";
	}
}

// INTERNATIONALIZATION (i18n)
/**
 *
 * This method initializes translation engine based on current locale
 * at runtime.
 *
 */
void ApplicationUI::initLocalization(QTranslator* translator) {
	// remember current locale set
	mCurrentLocale = QLocale().name();
	qDebug() << "init with locale: " << mCurrentLocale;
	mTranslator = translator;

	// watch if user changes locale from device settings
	mLocaleHandler = new LocaleHandler(this);
	// connect the handler
	connect(mLocaleHandler, SIGNAL(systemLanguageChanged()), this,
			SLOT(localeChanged()));
	qDebug() << "connected systemLanguageChanged";

}

/**
 * App::updateLocale(QString locale)
 *
 * Update view content basing on the given locale.
 *
 */
void ApplicationUI::updateLocale(QString locale) {
	qDebug() << "updateLocale: " << locale;

	// if locale is empty - refresh current. otherwise change the local
	if (!locale.trimmed().isEmpty() && mCurrentLocale != locale) {
		mCurrentLocale = locale;

		qDebug() << "updating UI to language: " << mCurrentLocale;
		QString filename = QString("OpenDataSpace_%1").arg(mCurrentLocale);
		if (mTranslator->load(filename, "app/native/qm")) {
			// multiple translators can be installed but for this
			// app we only use one translator instance for brevity
			Application::instance()->removeTranslator(mTranslator);
			Application::instance()->installTranslator(mTranslator);
			// retranslate System menu items
			translateMenuItems();
		}

	}
}

/**
 * (re)translates the titles of System menus
 *
 */
void ApplicationUI::translateMenuItems() {
	if (mHelpItem) {
		mHelpItem->setTitle(tr("Help"));
	}
	if (mFeedbackItem) {
		mFeedbackItem->setTitle(tr("Feedback"));
	}
//	if (mLogoutItem) {
//		mLogoutItem->setTitle(tr("Logout"));
//	}
	if (mSettingsItem) {
		mSettingsItem->setTitle(tr("Settings"));
	}
}

/**
 * App::getCurrentLanguage()
 *
 * Retrieve the language name corresponding to the current locale.
 */
QString ApplicationUI::getCurrentLanguage() {
	// TODO get language name from QLocale - we have now more languages
	qDebug() << "OpenDataSpaceApp getCurrentLanguage: " << mCurrentLocale;
	QLocale *loc = new QLocale(mCurrentLocale);
	return loc->languageToString(loc->language());
}

/**
 * App::getCurrentLocale()
 *
 * Retrieve the current locale.
 */
QString ApplicationUI::getCurrentLocale() {
	qDebug() << "getCurrentLocale: " << mCurrentLocale;
	return mCurrentLocale;
}

/**
 * App::suppressKeyboard()
 *
 * A helper function to force the keyboard to hide
 */
void ApplicationUI::suppressKeyboard() {
	virtualkeyboard_request_events(0);
	virtualkeyboard_hide();
}

// M E N U
// ApplicationMenu is available on all Screens
// opens using swipe-down
Menu* ApplicationUI::createApplicationMenu() {
	// HELP will open a website with Help Instructions from OpenDataSpace
	mHelpItem = new HelpActionItem();
	// FEEDBACK will send an email to OpenDataSpace
	mFeedbackItem = new ActionItem();
	mFeedbackItem->setImageSource(
			QString("asset:///images/ics/5-content-email81.png"));
	// LOGOUT will do a LogOut and jump back to HomeScreen and open the LogIn Sheet
//	mLogoutItem = new ActionItem();
//	mLogoutItem->setImageSource(
//			QString("asset:///images/ics/10-device-access-accounts81.png"));
	// SETTINGS will open the User Settings
	mSettingsItem = new SettingsActionItem();
	// set the translated Titles
	translateMenuItems();
	// plug it all together
	// TODO .addAction(mLogoutItem) need some more logic for testdrive
	Menu* menu =
			Menu::create().addAction(mFeedbackItem).help(mHelpItem).settings(
					mSettingsItem);
	// Connect SIGNALS and SLOTS
//	QObject::connect(mLogoutItem, SIGNAL(triggered()), this,
//			SLOT(logoutTriggered()));
	QObject::connect(mFeedbackItem, SIGNAL(triggered()), this,
			SLOT(feedbackTriggered()));
	QObject::connect(mHelpItem, SIGNAL(triggered()), this,
			SLOT(helpTriggered()));
	QObject::connect(mSettingsItem, SIGNAL(triggered()), this,
			SLOT(settingsTriggered()));
	return menu;
}

// S L O T S

// handles SLOT from Locale Chaned by user at Device
void ApplicationUI::localeChanged() {
	updateLocale(QLocale().name());
}

// handles SLOT from logoutItem
void ApplicationUI::logoutTriggered() {
	mOdsSettings->setTestdrive(false);
	mOdsData->resetUserFromLogout();
	Sheet *s = Application::instance()->scene()->findChild<Sheet*>(
			"loginSheet");
	if (s) {
		qDebug() << "logout triggered and loginSheet found";
		s->open();
	} else {
		qDebug() << "logout triggered, but no loginSheet found";
	}
}

/*
 * executes login from Credentials Dialog
 */
void ApplicationUI::login(const QString user, const QString pw) {
	if (!user.isEmpty() && !pw.isEmpty()) {
		// save values ?
		mOdsSettings->saveValueFor(SETTINGS_KEY_SERVER_CURRENT_USER, user);
		mOdsSettings->saveValueFor(SETTINGS_KEY_SERVER_CURRENT_PASSWORD, pw);
		// do server stuff for logging into dataspace
		mOdsData->loginToServer();
	} else {
		qDebug() << "login FAILED: no user / pw";
	}
}

// handles SLOT from feedbackItem
void ApplicationUI::feedbackTriggered() {
//	Sheet *s = Application::instance()->scene()->findChild<Sheet*>(
//			"feedbackSheet");
//	if (s) {
//		qDebug() << "feedback triggered and Feedback Sheet found";
//		s->open();
//	} else {
//		qDebug() << "feedback triggered, but no Feedback Sheet found";
//	}
	//
	qDebug() << "invoke sendFeedback";
	InvokeRequest request;
	request.setAction("bb.action.SENDEMAIL");
	request.setTarget("sys.pim.uib.email.hybridcomposer");
	request.setMimeType("settings/view");
	request.setUri("mailto:support@opendataspace.org?subject=Feedback%20OpenDataSpace");
	mInvokeManager->invoke(request);
}

// handles SLOT from helpItem
void ApplicationUI::helpTriggered() {
	Sheet *s = Application::instance()->scene()->findChild<Sheet*>("helpSheet");
	if (s) {
		qDebug() << "help triggered and helpSheet found";
		s->open();
	} else {
		qDebug() << "help triggered, but no helpSheet found";
	}
}

// handles SLOT from settingsItem
void ApplicationUI::settingsTriggered() {
	Sheet *s = Application::instance()->scene()->findChild<Sheet*>(
			"preferencesSheet");
	if (s) {
		qDebug() << "preferences triggered and preferencesSheet found";
		s->open();

	} else {
		qDebug() << "preferences triggered, but no FpreferencesSheet found";
	}
}

// unbound Invokation
void ApplicationUI::invokeUnbound(QString uri) {
	if (uri.endsWith(".svg")) {
		invokeBrowser(uri);
		return;
	}
	InvokeRequest cardRequest;
	cardRequest.setUri(uri);
	mInvokeManager->invoke(cardRequest);
}

// invoke MediaPlayer
void ApplicationUI::invokeBoundMediaPlayer(const QString& uri) {
	qDebug() << "invoke bound mediaplayer" << uri;
	InvokeRequest cardRequest;
	// MediaPlayer needs file:// or http:// etc as prefix
	// FilePicker uses /account....... etc
	if (uri.startsWith('/')) {
		cardRequest.setUri("file://" + uri);
	} else {
		cardRequest.setUri(uri);
	}
	cardRequest.setTarget("sys.mediaplayer.previewer");
	mInvokeManager->invoke(cardRequest);
}

void ApplicationUI::invokeBrowser(QString uri) {
	InvokeRequest cardRequest;
	cardRequest.setUri(uri);
	cardRequest.setTarget("sys.browser");
	mInvokeManager->invoke(cardRequest);
}

void ApplicationUI::shareTextWithBBM(const QString& text) {
	InvokeRequest bbmRequest;
	bbmRequest.setTarget("sys.bbm.sharehandler");
	bbmRequest.setAction("bb.action.SHARE");
	bbmRequest.setData(text.toUtf8());
	qDebug() << "share with BBM: " << text;
	mInvokeManager->invoke(bbmRequest);
	// TODO listen to InvokeTargetReply *reply to see if invocation was successfull
	// https://developer.blackberry.com/cascades/documentation/device_platform/invocation/sending_invocation.html
}

void ApplicationUI::shareTextWithMail(const QString& text) {
	InvokeRequest mailRequest;
	mailRequest.setTarget("sys.pim.uib.email.hybridcomposer");
	mailRequest.setAction("bb.action.SENDEMAIL");
	mailRequest.setMimeType("settings/view");
	mailRequest.setUri(
			"mailto:?subject="+text);
	qDebug() << "share with Mail: " << text;
	mInvokeManager->invoke(mailRequest);
}

void ApplicationUI::startChat(const QString& text) {
	InvokeRequest bbmRequest;
	bbmRequest.setTarget("sys.bbm.chathandler");
	bbmRequest.setAction("bb.action.BBMCHAT");
	bbmRequest.setData(text.toUtf8());
	qDebug() << "start chat with BBM: " << text;
	mInvokeManager->invoke(bbmRequest);
}

void ApplicationUI::inviteBBM() {
	InvokeRequest bbmRequest;
	bbmRequest.setTarget("sys.bbm.invitehandler");
	bbmRequest.setAction("bb.action.INVITEBBM");
	qDebug() << "invite to BBM";
	mInvokeManager->invoke(bbmRequest);
}

void ApplicationUI::inviteODS() {
	shareTextWithBBM(
			tr(
					"Please download OpenDataSpace Application from BlackBerry World for FREE: ")
					+ "http://appworld.blackberry.com/webstore/content/134203");
	qDebug() << "invite to BBM";
}

void ApplicationUI::leaveReview() {
	InvokeRequest bbmRequest;
	bbmRequest.setAction("bb.action.OPEN");
	bbmRequest.setMimeType("application/x-bb-appworld");
	bbmRequest.setUri("appworld://content/134203");
	qDebug() << "leave review";
	mInvokeManager->invoke(bbmRequest);
}

/**
 * uses Invokation Framework to View the file from URI
 *
 */
void ApplicationUI::showInView(QString uri) {
	qDebug() << "showInView called: " << uri;
	if (uri.endsWith(".ogg")) {
		invokeBoundMediaPlayer(uri);
		return;
	}
	if (uri.endsWith(".svg")) {
		invokeBrowser(uri);
		return;
	}
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.VIEW");
	invokeRequest.setUri(uri);
	qDebug() << "showInView URI: " << invokeRequest.uri();
	mInvokeManager->invoke(invokeRequest);
}

/**
 * uses Invokation Framework to View the file from URI
 * for a specific MimeType
 *
 */
void ApplicationUI::showInViewForMimeType(QString uri, QString mimeType) {
	qDebug() << "showInViewForMimeType called: " << uri;
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.VIEW");
	invokeRequest.setUri(uri);
	invokeRequest.setMimeType(mimeType);
	qDebug() << "showInViewForMimeType URI: " << invokeRequest.uri() << " Mime:"
			<< mimeType;
	mInvokeManager->invoke(invokeRequest);
}

/**
 * uses Invokation Framework to View the file from URI
 * for a specific target like "sys.pictures.app"
 *
 */
void ApplicationUI::showInTarget(QString uri, QString target) {
	qDebug() << "showInTarget called: " << uri;
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.VIEW");
	invokeRequest.setUri(uri);
	invokeRequest.setTarget(target);
	qDebug() << "showInTarget URI: " << invokeRequest.uri();
	mInvokeManager->invoke(invokeRequest);
}

/**
 * uses Invokation Framework to View the file from URI
 * for a specific MimeType
 * and for a specific target like "sys.pictures.app"
 *
 */
void ApplicationUI::showInTargetForMimeType(QString uri, QString mimeType,
		QString target) {
	qDebug() << "showInTargetForMimeType called: " << uri;
	InvokeRequest invokeRequest;
	invokeRequest.setAction("bb.action.VIEW");
	invokeRequest.setUri(uri);
	invokeRequest.setTarget(target);
	invokeRequest.setMimeType(mimeType);
	qDebug() << "showInTargetForMimeType URI: " << invokeRequest.uri()
			<< " MimeType:" << mimeType;
	mInvokeManager->invoke(invokeRequest);
}

// triggered if Application was sent to back
void ApplicationUI::onThumbnail() {
	// TODO set Cover()
	qDebug() << "Application shrinks to thumbnail";
	// AbstractCover *cover;
	// Application::instance()->setCover(cover);
}

// triggered if Application was invoked by a client
void ApplicationUI::handleInvoke(const InvokeRequest& request) {
	// TODO
	qDebug() << "Invoke Request";
	qDebug() << "Invoke Request Action:" << request.action();
	qDebug() << "Invoke Request Mime:" << request.mimeType();
	qDebug() << "Invoke Request URI:" << request.uri();
	qDebug() << "Invoke Request Data:" << request.data();
	mInvokationTarget = request.target();
	mInvokationSource = QString::fromLatin1("%1 (%2)").arg(
			request.source().installId()).arg(request.source().groupId());
	qDebug() << "Invoke Target ID: " << mInvokationTarget << " from Source: "
			<< mInvokationSource;
	// Metadata ? not used yet
	// QVariantMap meta = request.metadata();
	// Invoked as Application
	if (mInvokationTarget == "io.ods.bb10.invoke") {
		mIsCard = false;
		qDebug() << "Invoked";
	}
	// invoked as embedded Card (Previewer) from OPEN
	else if (mInvokationTarget == "io.ods.bb10.card.upload") {
		mIsCard = true;
		qDebug() << "Invoked for UploadCard as Previewer";
	}
	// invoked as embedded Card (Previewer) from OPEN or SHARE
	else if (mInvokationTarget == "io.ods.bb10.upload.and.share") {
		mIsCard = true;
		qDebug() << "Invoked for UploadCard as Previewer AND share via BBM";
	}
	// do some preparing-stuff for a invoked Card
	// reset values (can come from pool)
	// set some infos
	// tell the Card that its a new invocation
	if (mIsCard) {
		AbstractPane *p = Application::instance()->scene();
		bool ok = false;
		// if there's a URI we take the URI
		// else we take the data (bpund invokation can use data)
		if (request.uri().isEmpty()) {
			ok = p->setProperty("filePath", request.data());
		} else {
			ok = p->setProperty("filePath", request.uri());
		}
		if (!ok) {
			qDebug() << "Cannot set filePath";
		}
		// start a new Card Game ;-)
		// setting newCard true causes testing if LogIn was needed before upload files
		ok = p->setProperty("newCard", true);
		if (ok) {
			qDebug() << "set newCard to true";
		} else {
			qDebug() << "cannot set newCard";
		}
	} else {
		// do what needed if Invoked, per ex. switch to Upload TAB
		// TODO test for URI and upload the file
		qDebug() << "invoked as APPLICATION URI:" << request.uri() << " data: "
				<< request.data();
	}
}

/**
 * true if this Application was embedded as a Card
 * from Invocation Framework
 */
bool ApplicationUI::isCard() {
	return mIsCard;
}

/**
 * true if this Application is running embedded
 * can be a Card, a Viewer or a Service
 */
bool ApplicationUI::isEmbedded() {
	return mIsLaunchedEmbedded;
}

void ApplicationUI::handleCardResize(
		const bb::system::CardResizeMessage& resizeMessage) {
	mCardStatus = tr("Resized");
	// width available to the card
	// resizeMessage.width();
	// height available to the card
	// resizeMessage.height();
	// which edge of the device is pointing up
	// resizeMessage.upEdge();
	// Orientation of the device (portrait or landscape)
	// resizeMessage.orientation();
	emit cardStatusChanged();
}

void ApplicationUI::handleCardPooled(
		const bb::system::CardDoneMessage& message) {
	// reason can be: "closed" or "Success"
	qDebug() << "handleCardPooled data: " << message.data() << " reason: "
			<< message.reason();
	// TODO do we need this ?
	mCardStatus = tr("Pooled");
	emit cardStatusChanged();
}

/**
 * the Card was processed with success
 */
void ApplicationUI::cardDone() {
	qDebug() << "cardDone: assemble message";
	// Assemble message
	CardDoneMessage message;
	message.setData(tr(":)"));
	message.setDataType("text/plain");
	message.setReason(tr("save"));
	// Send message
	qDebug() << "cardDone: sending message via IvokeManager data: "
			<< message.data() << " reason: " << message.reason();
	mInvokeManager->sendCardDone(message);

}

/**
 * the Card couldn't be processed successfully
 * so we're sending with reason cancel
 * and add data to describe why
 */
void ApplicationUI::cardCanceled(const QString data) {
	qDebug() << "cardDone: assemble message";
	// Assemble message
	CardDoneMessage message;
	message.setData(data);
	message.setDataType("text/plain");
	message.setReason("cancel");
	// Send message
	qDebug() << "cardDone: sending message via IvokeManager data: "
			<< message.data() << " reason: " << message.reason();
	mInvokeManager->sendCardDone(message);

}


