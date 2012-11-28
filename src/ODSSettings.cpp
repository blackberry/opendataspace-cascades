
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

void ODSSettings::saveValueFor(const QString &objectName,
		const QString &inputValue) {
	// A new value is saved to the application settings object.
	QSettings settings;
	settings.setValue(objectName, QVariant(inputValue));
}

ODSSettings::~ODSSettings() {
	// TODO Auto-generated destructor stub
}

