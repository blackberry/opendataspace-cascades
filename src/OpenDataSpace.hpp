#ifndef OPENDATASPACE_H
#define OPENDATASPACE_H

#include <QObject>
#include <bb/cascades/Menu>
#include <bb/cascades/Application>
#include <bb/cascades/LocaleHandler>

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
	OpenDataSpace();
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

public slots:
	void logoutTriggered();
	void feedbackTriggered();
	void helpTriggered();
	void settingsTriggered();
	// locale changed by user from device settings
	void localeChanged();
	void onThumbnail();

private:
	Menu* createApplicationMenu();
	HelpActionItem* m_helpItem;
	ActionItem* m_feedbackItem;
	SettingsActionItem* m_settingsItem;
	ActionItem* m_logoutItem;

	QString m_currentLocale;
	LocaleHandler* m_LocaleHandler;
	QTranslator* m_translator;

	void translateMenuItems();

};

#endif // ifndef OPENDATASPACE_H
