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
/*
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
 */
class FileInfo : public QObject {
	Q_OBJECT

public:
	FileInfo();

	/*
	 * @return the filename extracted from full qualified FilePath
	 */
	Q_INVOKABLE
	QString getShortName(QString filePath) const;
};

/*
 * @return the filename extracted from full qualified FilePath
 */
Q_INVOKABLE
QString getShortName(QString filePath);

#endif /* FILEINFO_HPP_ */
