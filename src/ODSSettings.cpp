
#include "ODSSettings.hpp"
#include <QSettings>

ODSSettings::ODSSettings() {
	// Set the application organization and name, which is used by QSettings
	// when saving values to the persistent store.
	QCoreApplication::setOrganizationName("SSPE Europe");
	QCoreApplication::setApplicationName("OpenDataSpace Developer Preview");
	QString serverUrl;
	getValueFor("server/url", "");
	if (serverUrl.isNull() || serverUrl.isEmpty()) {
		saveValueFor("server/url", "https://bb.ods.io");
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

void ODSSettings::saveValueFor(const QString &objectName,
		const QString &inputValue) {
	// A new value is saved to the application settings object.
	QSettings settings;
	settings.setValue(objectName, QVariant(inputValue));
}

ODSSettings::~ODSSettings() {
	// TODO Auto-generated destructor stub
}

