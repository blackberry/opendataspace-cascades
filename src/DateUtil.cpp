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

#include "DateUtil.hpp"
#include <QDateTime>
#include <QLocale>
#include <QDebug>

/*
 * Utility Class for Dates, Time and DateTime (Timestamp)
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
DateUtil::DateUtil() {
	// TODO Auto-generated constructor stub

}

/*
 *
 * get the timestamp of last modification
 * as String localized as short format
 *
 */
QString DateUtil::getDateTimeStringLocalizedAsShortString(QString locale,
		QString datetime) const {
	qDebug() << "DATEUTIL getDateTimeStringLocalizedAsShortString: " << datetime;
	QLocale loc(locale);
	QDateTime dt = QDateTime::fromString(datetime,"YYYY-MM-dd hh:mm:ss");
	QString ld = loc.toString(dt, QLocale::ShortFormat);
	return ld;
}

/*
 *
 * get the timestamp of last modification
 * as String localized as long format
 *
 */
QString DateUtil::getDateTimeStringLocalizedAsLongString(QString locale,
		QString datetime) const {
	qDebug() << "DATEUTIL getDateTimeStringLocalizedAsLongString: " << datetime;
	QLocale loc(locale);
	QDateTime dt = QDateTime::fromString(datetime,"YYYY-MM-dd hh:mm:ss");
	QString ld = loc.toString(dt, QLocale::LongFormat);
	return ld;
}
