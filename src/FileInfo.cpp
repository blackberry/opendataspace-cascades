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

#include "FileInfo.hpp"
#include <QFileInfo>
#include <QDateTime>
#include <QLocale>
#include <QDebug>

/*
 * Utility Class to get Informations from File
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
FileInfo::FileInfo() {
	// TODO Auto-generated constructor stub
}

// HINT: we replace file:// - per ex. imageSource contains it

/*
 * FileBrowseDialog gives us a path to the file
 * with a full qualified FileName
 *
 * getShortName() extracts the Filename itself
 * so from QML we can use this name in ListItems etc.
 *
 *
 */
QString FileInfo::getShortName(QString filePath) const {
	qDebug() << "FILEINFO getShortName: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	return info.fileName();
}

/*
 *
 * get the timestamp of last modification
 *
 */
QDateTime FileInfo::getLastModified(QString filePath) const {
	qDebug() << "FILEINFO getLastModified: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	return info.lastModified();
}

/*
 *
 * get the timestamp of last modification
 * as String localized as short format
 *
 */
QString FileInfo::getLastModifiedAsShortString(QString locale,
		QString filePath) const {
	qDebug() << "FILEINFO getLastModifiedAsShortString: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = loc.toString(info.lastModified(), QLocale::ShortFormat);
	return ld;
}

/*
 *
 * get the timestamp of last modification
 * as String localized as long format
 *
 */
QString FileInfo::getLastModifiedAsLongString(QString locale,
		QString filePath) const {
	qDebug() << "FILEINFO getLastModifiedAsLongString: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = loc.toString(info.lastModified(), QLocale::LongFormat);
	return ld;
}

/*
 *
 * get the timestamp of creation
 *
 */
QDateTime FileInfo::getCreated(QString filePath) const {
	qDebug() << "FILEINFO getCreated: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	return info.created();
}

/*
 *
 * get the timestamp of creation
 * as String localized as short format
 *
 */
QString FileInfo::getCreatedAsShortString(QString locale,
		QString filePath) const {
	qDebug() << "FILEINFO getCreatedAsShortString: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = loc.toString(info.created(), QLocale::ShortFormat);
	return ld;
}

/*
 *
 * get the timestamp of creation
 * as String localized as long format
 *
 */
QString FileInfo::getCreatedAsLongString(QString locale,
		QString filePath) const {
	qDebug() << "FILEINFO getCreatedAsLongString: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = loc.toString(info.created(), QLocale::LongFormat);
	return ld;
}

/*
 *
 * get the suffix from filename
 *
 */
QString FileInfo::getSuffix(QString filePath) const {
	qDebug() << "FILEINFO getSuffix: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	return info.suffix();
}

// TODO refactor filetypes - enum ?
// wait for BBJam to see how to invoke apps for specific file types
/*
 *
 * tests the suffix from filename
 * if it is an image
 *
 */
bool FileInfo::isImage(QString filePath) const {
	QString s = getSuffix(filePath);
	if (s == "png" || s == "jpg" || s == "jpeg" || s == "gif") {
		return true;
	}
	return false;
}

/*
 *
 * tests the suffix from filename
 * if it is a video
 *
 */
bool FileInfo::isVideo(QString filePath) const {
	QString s = getSuffix(filePath);
	if (s == "mp4" || s == "mov") {
		return true;
	}
	return false;
}

/*
 *
 * tests the suffix from filename
 * if it is a document
 *
 */
bool FileInfo::isDocument(QString filePath) const {
	QString s = getSuffix(filePath);
	if (s == "doc" || s == "odt" || s == "ppt"
			|| s == "txt" || s == "rtf" || s == "ptx"
			|| s == "pdf" || s == "zip" || s == "tar"
			|| s == "rar" || s == "gz" || s == "html") {
		return true;
	}
	return false;
}

/*
 *
 * tests the suffix from filename
 * if it is a compressed document
 *
 */
bool FileInfo::isCompressed(QString filePath) const {
	QString s = getSuffix(filePath);
	if (s == "tar" || s == "rar" || s == "gz" || s == "zip") {
		return true;
	}
	return false;
}

/*
 *
 * get the size in Bytes from filename
 *
 */
int FileInfo::getSize(QString filePath) const {
	qDebug() << "FILEINFO getSize: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	return info.size();
}

/*
 *
 * get the size in Bytes from filename
 * as localized String
 *
 */
QString FileInfo::getSizeAsString(QString locale, QString filePath) const {
	qDebug() << "FILEINFO getSizeAsString: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = loc.toString(info.size());
	return ld;
}

/*
 *
 * get detailed Info from filename
 * as localized multiline String
 *
 */
QString FileInfo::getDetailedInfo(QString locale, QString filePath) const {
	qDebug() << "FILEINFO getDetailedInfo: " << filePath;
	QFileInfo info(filePath.replace("file://", ""));
	QLocale loc(locale);
	QString ld = filePath + "\n" + "\n" + (loc.toString(info.size()))
			+ " Bytes\n" + tr("created") + ": "
			+ (loc.toString(info.created(), QLocale::ShortFormat)) + "\n"
			+ tr("modified") + ": "
			+ (loc.toString(info.lastModified(), QLocale::ShortFormat));
	return ld;
}

