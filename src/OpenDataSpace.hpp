#ifndef OPENDATASPACE_H
#define OPENDATASPACE_H

#include <QObject>
#include <bb/cascades/Menu>
#include <bb/cascades/multimedia/Camera>
#include <bb/cascades/Application>
#include <bb/cascades/LocaleHandler>

namespace bb {
namespace cascades {
class Application;
}
}

using namespace bb::cascades;
using namespace bb::cascades::multimedia;

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

	Q_INVOKABLE
	// Function that uses the invoke framework to launch the picture in the pictures app.
	void showInPicturesApp(QString fileName);

	Q_INVOKABLE
	// Function that uses the invoke framework to launch the video in the Videos app.
	void showInVideosApp(QString fileName);

	Q_INVOKABLE
	// Function that uses the invoke framework to launch the file in another app
	void showInOtherApp(QString fileName);

public slots:
	void logoutTriggered();
	void feedbackTriggered();
	void helpTriggered();
	void settingsTriggered();
	// locale changed by user from device settings
	void localeChanged();

private:
	Camera *camera;
	Camera *videocamera;

	Menu* createApplicationMenu();
	HelpActionItem* m_helpItem;
	ActionItem* m_feedbackItem;
	SettingsActionItem* m_settingsItem;
	ActionItem* m_logoutItem;

	QString m_currentLocale;
	LocaleHandler* m_LocaleHandler;
	QTranslator* m_translator;

	void translateMenuItems();

private slots:

	// When we get a ShutterFired event from the system, we play a shutter-sound.
	void onShutterFired();

};

#endif // ifndef OPENDATASPACE_H
