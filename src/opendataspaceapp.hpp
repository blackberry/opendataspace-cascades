#ifndef OPENDATASPACEAPP_H
#define OPENDATASPACEAPP_H

#include <QObject>
#include <QtCore/QMetaType>
#include <bb/cascades/TabbedPane>
#include <bb/cascades/Menu>
#include <bb/cascades/multimedia/Camera>
#include <bb/cascades/Application>

using namespace bb::cascades;
using namespace bb::cascades::multimedia;

/*!
 * @brief Application GUI object
 */
class OpenDataSpaceApp: public QObject {
Q_OBJECT
public:
	OpenDataSpaceApp();

	/*
	 * Sets the cascades::Application pointer to allow translation to be
	 * changed at runtime from the App class.
	 *
	 * @param app - the pointer to bb::cascades::Application
	 * @param translator - pointer to the current translator
	 * @param locale - the locale the application was launched with
	 */
	void setApplication(bb::cascades::Application* app, QTranslator* translator,
			QString currentLocale);

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
	 * Workaround to force keyboard to hide when readonly text area is touched
	 */
	Q_INVOKABLE
	void suppressKeyboard();

	Q_INVOKABLE
	// Function that uses the invoke framework to launch the picture in the pictures app.
	void showInPicturesApp(QString fileName);

	Q_INVOKABLE
	// Function that uses the invoke framework to launch the picture in the pictures app.
	void showInVideosApp(QString fileName);

public slots:
	void logoutTriggered();
	void feedbackTriggered();
	void helpTriggered();
	void settingsTriggered();

private:
	Application* m_app;

	TabbedPane *root;

	Camera *camera;
	Camera *videocamera;

	Menu* createSystemMenu();
	HelpActionItem* m_helpItem;
	ActionItem* m_feedbackItem;
	SettingsActionItem* m_settingsItem;
	ActionItem* m_logoutItem;

	QString m_currentLocale;

	QTranslator* m_translator;

	void translateMenuItems();

private slots:

	// When we get a ShutterFired event from the system, we play a shutter-sound.
	void onShutterFired();

};

#endif // ifndef OPENDATASPACEAPP_H
