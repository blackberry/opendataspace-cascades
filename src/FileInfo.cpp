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

/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
FileInfo::FileInfo() {
	// TODO Auto-generated constructor stub

}

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
	QFileInfo *info = new QFileInfo(filePath);
	return info->fileName();
}

/*
 *
 * get the timestamp of last modification
 *
 */
QDateTime FileInfo::getLastModified(QString filePath) const {
	QFileInfo *info = new QFileInfo(filePath);
	return info->lastModified();
}

/*
 *
 * get the suffix from filename
 *
 */
QString FileInfo::getSuffix(QString filePath) const {
	QFileInfo *info = new QFileInfo(filePath);
	return info->suffix();
}

/*
 *
 * get the size in Bytes from filename
 *
 */
int FileInfo::getSize(QString filePath) const {
	QFileInfo *info = new QFileInfo(filePath);
	return info->size();
}

