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

#ifndef FILEINFO_HPP_
#define FILEINFO_HPP_

#include <QFileInfo>
#include <QDateTime>
#include <QLocale>
/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
class FileInfo: public QObject {
Q_OBJECT

public:
	FileInfo();

	/*
	 * FileBrowseDialog gives us a path to the file
	 * with a full qualified FileName
	 *
	 * getShortName() extracts the Filename itself
	 * so from QML we can use this name in ListItems etc.
	 *
	 *
	 */
	Q_INVOKABLE
	QString getShortName(QString filePath) const;

	/*
	 *
	 * get the timestamp of last modification
	 *
	 */
	Q_INVOKABLE
	QDateTime getLastModified(QString filePath) const;

	/*
	 *
	 * get the timestamp of last modification
	 * as String localized as short format
	 *
	 */
	Q_INVOKABLE
	QString getLastModifiedAsShortString(QString locale,
			QString filePath) const;

	/*
	 *
	 * get the timestamp of last modification
	 * as String localized as long format
	 *
	 */
	Q_INVOKABLE
	QString getLastModifiedAsLongString(QString locale, QString filePath) const;

	/*
	 *
	 * get the timestamp of creation
	 *
	 */
	Q_INVOKABLE
	QDateTime getCreated(QString filePath) const;

	/*
	 *
	 * get the timestamp of creation
	 * as String localized as short format
	 *
	 */
	Q_INVOKABLE
	QString getCreatedAsShortString(QString locale, QString filePath) const;

	/*
	 *
	 * get the timestamp of creation
	 * as String localized as long format
	 *
	 */
	Q_INVOKABLE
	QString getCreatedAsLongString(QString locale, QString filePath) const;

	/*
	 *
	 * get the suffix from filename
	 *
	 */
	Q_INVOKABLE
	QString getSuffix(QString filePath) const;

	/*
	 *
	 * tests the suffix from filename
	 * if it is an image
	 *
	 */
	Q_INVOKABLE
	bool isImage(QString filePath) const;

	/*
	 *
	 * tests the suffix from filename
	 * if it is a Video
	 *
	 */
	Q_INVOKABLE
	bool isVideo(QString filePath) const;

	/*
	 *
	 * tests the suffix from filename
	 * if it is a document
	 *
	 */
	Q_INVOKABLE
	bool isDocument(QString filePath) const;

	/*
	 *
	 * get the size from filename
	 *
	 */
	Q_INVOKABLE
	int getSize(QString filePath) const;

	/*
	 *
	 * get the size in Bytes from filename
	 * as localized string
	 *
	 */
	Q_INVOKABLE
	QString getSizeAsString(QString locale, QString filePath) const;

	/*
	 *
	 * get detailed info of file
	 * as multiline localized string
	 *
	 */
	Q_INVOKABLE
	QString getDetailedInfo(QString locale, QString filePath) const;

};

#endif /* FILEINFO_HPP_ */
