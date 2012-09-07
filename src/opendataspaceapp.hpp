#ifndef OPENDATASPACEAPP_H
#define OPENDATASPACEAPP_H

#include <QObject>
#include <QtCore/QMetaType>
#include <bb/cascades/TabbedPane>
#include <bb/cascades/Menu>
#include <bb/cascades/multimedia/Camera>

using namespace bb::cascades;
using namespace bb::cascades::multimedia;

/*!
 * @brief Application GUI object
 */
class OpenDataSpaceApp: public QObject {
Q_OBJECT
public:
	OpenDataSpaceApp();

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
	TabbedPane *root;

	Camera *camera;
	Camera *videocamera;

	Menu* createSystemMenu();

private slots:

	// When we get a ShutterFired event from the system, we play a shutter-sound.
	void onShutterFired();

};

#endif // ifndef OPENDATASPACEAPP_H
