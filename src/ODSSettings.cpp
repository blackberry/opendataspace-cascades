
#include "ODSSettings.hpp"
#include <QSettings>



ODSSettings::ODSSettings() {
	// don't need to set Organization and Application
	// will be used from bar-descriptor.xml
	QString serverUrl;
	getValueFor("server/url", "");
	if (serverUrl.isNull() || serverUrl.isEmpty()) {
		saveValueFor("server/url", "https://bb.ods.io/mobile");
	}

}

QString ODSSettings::getValueFor(const QString &objectName,
		const QString &defaultValue) {
	QSettings settings;

	// If no value has been saved, return the default value.
	if (settings.value(objectName).isNull()) {
		return defaultValue;
	}

	// Otherwise, return the value stored in the settings object.
	return settings.value(objectName).toString();
}

bool ODSSettings::isTrueFor(const QString &objectName,
		const bool &defaultValue) {
	QSettings settings;

	// If no value has been saved, return the default value.
	if (settings.value(objectName).isNull()) {
		return defaultValue;
	}

	// Otherwise, return the value stored in the settings object.
	return settings.value(objectName).toBool();
}

void ODSSettings::saveValueFor(const QString &objectName,
		const QString &inputValue) {
	// A new value is saved to the application settings object.
	QSettings settings;
	settings.setValue(objectName, QVariant(inputValue));
}

void ODSSettings::setTrueFor(const QString &objectName,
		const bool &inputValue) {
	// A new value is saved to the application settings object.
	QSettings settings;
	settings.setValue(objectName, QVariant(inputValue));
}

QString ODSSettings::getUser() {
	return getValueFor(SETTINGS_KEY_LOGIN_USER, "");
}

QString ODSSettings::getPassword() {
	return getValueFor(SETTINGS_KEY_LOGIN_PASSWORD, "");
}

QString ODSSettings::getServerUrl() {
	return getValueFor(SETTINGS_KEY_SERVER_URL, "");
}

void ODSSettings::setUser(const QString &user) {
	saveValueFor(SETTINGS_KEY_LOGIN_USER, user);
}

void ODSSettings::setPassword(const QString &password) {
	saveValueFor(SETTINGS_KEY_LOGIN_PASSWORD, password);
}

void ODSSettings::setServerUrl(const QString &user) {
	saveValueFor(SETTINGS_KEY_SERVER_URL, user);
}

ODSSettings::~ODSSettings() {
	// TODO Auto-generated destructor stub
}

