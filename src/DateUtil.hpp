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

#ifndef DATEUTIL_HPP_
#define DATEUTIL_HPP_

#include <QDateTime>
#include <QLocale>
/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
class DateUtil: public QObject {
	Q_OBJECT


public:
	DateUtil();

	/*
	 *
	 * get a timestamp (DateTime)
	 * as String localized as short format
	 *
	 */
	Q_INVOKABLE
	QString getDateTimeStringLocalizedAsShortString(QString locale,
			QString datetime) const;

	/*
	 *
	 * get a timestamp (DateTime)
	 * as String localized as long format
	 *
	 */
	Q_INVOKABLE
	QString getDateTimeStringLocalizedAsLongString(QString locale, QString datetime) const;
};

#endif /* DATEUTIL_HPP_ */
