#ifndef OPENDATASPACE_H
#define OPENDATASPACE_H

#include <QObject>
#include <bb/cascades/Menu>
#include <bb/cascades/Application>
#include <bb/cascades/LocaleHandler>
#include <bb/system/CardDoneMessage.hpp>
#include <bb/system/InvokeManager.hpp>
#include <bb/system/InvokeRequest.hpp>
#include "ODSData.hpp"

namespace bb {
namespace cascades {
class Application;
}
}

using namespace bb::cascades;

/*!
 * @brief Application GUI object
 */
class OpenDataSpace: public QObject {
Q_OBJECT

public:
	OpenDataSpace(QObject *parent = 0);
	virtual ~OpenDataSpace() {
	}

	Q_INVOKABLE
	void initLocalization(QTranslator* translator);

	/*
	 * Refreshes the UI with the specified locale
	 *
	 * @param locale - the locale to change to
	 */
	Q_INVOKABLE
	void updateLocale(QString locale);

	/*
	 * Allows the current language to be retrieved from QML
	 *
	 * @return the current language (translated)
	 */
	Q_INVOKABLE
	QString getCurrentLanguage();

	/*
	 * Allows the current locale to be retrieved from QML
	 *
	 * @return the current locale
	 */
	Q_INVOKABLE
	QString getCurrentLocale();

	/*
	 * Workaround to force keyboard to hide when readonly text area is touched
	 */
	Q_INVOKABLE
	void suppressKeyboard();

	/**
	 * uses Invokation Framework to invoke unbound from URI
	 *
	 */
	Q_INVOKABLE
	void invokeUnbound(QString uri);

	/**
	 * uses Invokation Framework to Invoke bound to MediaPlayer from URI
	 *
	 */
	Q_INVOKABLE
	void invokeBoundMediaPlayer(QString uri);

	/**
	 * uses Invokation Framework to View the file from URI
	 *
	 */
	Q_INVOKABLE
	void showInView(QString uri);

	/**
	 * uses Invokation Framework to View the file from URI
	 * for a specific MimeType
	 *
	 */
	Q_INVOKABLE
	void showInViewForMimeType(QString uri, QString mimeType);

	/**
	 * uses Invokation Framework to View the file from URI
	 * for a specific target like "sys.pictures.app"
	 *
	 */
	Q_INVOKABLE
	void showInTarget(QString uri, QString target);

	/**
	 * uses Invokation Framework to View the file from URI
	 * for a specific MimeType
	 * and for a specific target like "sys.pictures.app"
	 *
	 */
	Q_INVOKABLE
	void showInTargetForMimeType(QString uri, QString mimeType, QString target);

	/**
	 * test if Login is already done and valid
	 */
	Q_INVOKABLE
	bool loginDone();

	/*
	 * login with username and password
	 * true if login credentials are ok
	 */
	Q_INVOKABLE
	bool login(QString user, QString pw);

	/**
	 * test if this application
	 * is embedded into client as a Card
	 * from Invocation Framework
	 */
	Q_INVOKABLE
	bool isCard();

	/**
	 * test if this application is running embedded
	 * as a Card, a Viewer or a Service
	 */
	Q_INVOKABLE
	bool isEmbedded();

public Q_SLOTS:
	// Invoaction
	// This method is invoked to notify the invocation system that the action has been done successfully
	void cardDone();
	// This method is invoked to notify the invocation system that the action has been done without success
	// per ex. Login failed
	void cardCanceled(QString reason);
	// slots from AppMenu Sheets:
	void logoutTriggered();
	void feedbackTriggered();
	void helpTriggered();
	void settingsTriggered();
	// locale changed by user from device settings
	void localeChanged();
	void onThumbnail();

Q_SIGNALS:
	// The change notification signal of card status change
	void cardStatusChanged();

private Q_SLOTS:
	// ods as target for Invocation Queries
	void handleInvoke(const bb::system::InvokeRequest& request);
	void handleCardResize(const bb::system::CardResizeMessage&);
	void handleCardPooled(const bb::system::CardDoneMessage&);

private:
	Menu* createApplicationMenu();
	HelpActionItem* m_helpItem;
	ActionItem* m_feedbackItem;
	SettingsActionItem* m_settingsItem;
	ActionItem* m_logoutItem;
	bool m_login_ok;

	QString m_currentLocale;
	LocaleHandler* m_LocaleHandler;
	QTranslator* m_translator;

	ODSData* m_odsData;

	QString m_cardStatus;
	QString m_invokationTarget;
	QString m_invokationSource;
	bool m_isCard;
	bool m_isLaunchedEmbedded;
	bb::system::InvokeManager *m_invokeManager;

	void translateMenuItems();
	void initTheApplication();
};

#endif // ifndef OPENDATASPACE_H
