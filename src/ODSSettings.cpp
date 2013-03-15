
#include "ODSSettings.hpp"
#include <QSettings>



ODSSettings::ODSSettings() {
	// don't need to set Organization and Application
	// will be used from bar-descriptor.xml
	QString serverUrl;
	serverUrl = getValueFor("server/url", "");
	if (serverUrl.isNull() || serverUrl.isEmpty()) {
		saveValueFor("server/url", "https://bb.ods.io/mobile");
	}
	setTestdrive(false);
	mTestdriving = false;
	qDebug() << "testdriving false";
}

QString ODSSettings::getValueFor(const QString &objectName,
		const QString &defaultValue) {
	// QSettings settings;

	if (mTestdriving && (objectName == SETTINGS_KEY_SERVER_CURRENT_USER || objectName == SETTINGS_KEY_LOGIN_USER)) {
		qDebug() << "return testdrive user";
		return "test-drive@ods.io";
	}
	if (mTestdriving && (objectName == SETTINGS_KEY_SERVER_CURRENT_PASSWORD || objectName == SETTINGS_KEY_LOGIN_PASSWORD)) {
		qDebug() << "return testdrive pw";
		return "MDUb4eWq";
	}

	// If no value has been saved, return the default value.
	if (mSettings.value(objectName).isNull()) {
		return defaultValue;
	}

	// Otherwise, return the value stored in the settings object.
	return mSettings.value(objectName).toString();
}

bool ODSSettings::isTrueFor(const QString &objectName,
		const bool &defaultValue) {
	// QSettings settings;

	// If no value has been saved, return the default value.
	if (mSettings.value(objectName).isNull()) {
		return defaultValue;
	}

	// Otherwise, return the value stored in the settings object.
	return mSettings.value(objectName).toBool();
}

void ODSSettings::setTestdrive(const bool testdrive){
	mTestdriving = testdrive;
	qDebug() << "set testdrive to " << testdrive;
	setTrueFor(SETTINGS_KEY_TESTDRIVE, testdrive);
}

bool ODSSettings::testdrive(){
	bool td = isTrueFor(SETTINGS_KEY_TESTDRIVE, false);
	qDebug() << "get testdrive():" << td;
	return td;
}

void ODSSettings::saveValueFor(const QString &objectName,
		const QString &inputValue) {
	if (mTestdriving && objectName == SETTINGS_KEY_SERVER_CURRENT_USER) {
		qDebug() << "dont save current user";
		return;
	}
	if (mTestdriving && objectName == SETTINGS_KEY_SERVER_CURRENT_PASSWORD) {
		qDebug() << "don't save current pw";
		return;
	}
	// A new value is saved to the application settings object.
	// QSettings settings;
	mSettings.setValue(objectName, QVariant(inputValue));
}

void ODSSettings::setTrueFor(const QString &objectName,
		const bool &inputValue) {
	// A new value is saved to the application settings object.
	// QSettings settings;
	mSettings.setValue(objectName, QVariant(inputValue));
}

QString ODSSettings::getUser() {
	qDebug() << "get user - testdrive ?" << mTestdriving;
	if (mTestdriving) {
		return "test-drive@ods.io";
	} else {
		return getValueFor(SETTINGS_KEY_LOGIN_USER, "");
	}
}

QString ODSSettings::getPassword() {
	qDebug() << "get pw - testdrive ?" << mTestdriving;
	if (mTestdriving) {
		return "MDUb4eWq";
	} else {
		return getValueFor(SETTINGS_KEY_LOGIN_PASSWORD, "");
	}
}

QString ODSSettings::getServerUrl() {
	return getValueFor(SETTINGS_KEY_SERVER_URL, "");
}

void ODSSettings::setUser(const QString &user) {
	qDebug() << "set user testdrive?" << mTestdriving;
	if (mTestdriving) {
		return;
	}
	saveValueFor(SETTINGS_KEY_LOGIN_USER, user);
}

void ODSSettings::setPassword(const QString &password) {
	qDebug() << "set pw - testdriving ?" << mTestdriving;
	if (mTestdriving) {
		return;
	}
	saveValueFor(SETTINGS_KEY_LOGIN_PASSWORD, password);
}

void ODSSettings::setServerUrl(const QString &user) {
	saveValueFor(SETTINGS_KEY_SERVER_URL, user);
}

ODSSettings::~ODSSettings() {
	// TODO Auto-generated destructor stub
}

