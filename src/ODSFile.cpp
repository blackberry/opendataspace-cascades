

#include "ODSFile.hpp"
#include "FileInfo.hpp"
#include <QDebug>
#include <qdir.h>
#include <qlocale.h>

static const QString nameValue = "name";
//static const QString typeValue = "type";
static const QString groupPkValue = "group_pk";
static const QString fileSizeValue = "file_size";
static const QString fileIdValue = "fileID";
static const QString expirationDateValue = "expiration_date";
static const QString classificationValue = "classification";
static const QString logMeValue = "log_me";
static const QString commentValue = "comment";
static const QString logDeValue = "log_de";

static QString downloadFilePath(const QString& fileName) {
	return QDir::currentPath() + "/data/ods/download/" + fileName;
}

ODSFile::ODSFile(QObject *parent) {}

ODSFile::ODSFile(QVariantMap fileMap, QString path) :
				QObject(), mFilesMap(fileMap), mPath(path) {
	mName = mFilesMap.value(nameValue, "").toString();
	mId = mFilesMap.value(fileIdValue, 0).toInt();
	mComment = mFilesMap.value(commentValue, "").toString();
	mContainerId = mFilesMap.value(groupPkValue, 0).toInt();
	mFileSize = mFilesMap.value(fileSizeValue, 0).toInt();
	mDownloaded = QFile::exists(downloadFilePath(mName));
	if (mDownloaded) {
		mDownloadPath = "file://"+downloadFilePath(mName);
	} else {
		mDownloadPath = "";
	}
	int classification = mFilesMap.value(classificationValue, -1).toInt();
	switch (classification) {
		case 1:
			mClassification = tr("public");
			break;
		case 2:
			mClassification = tr("for internal usage only");
			break;
		case 3:
			mClassification = tr("confidentiaL");
			break;
		case 4:
			mClassification = tr("strictly confidential");
			break;
		default:
			mClassification = tr("unknown");
			break;
	}
	mExpires = mFilesMap.value(expirationDateValue, "").toString();
	mCreatedBy = mFilesMap.value(logMeValue, "").toString();
	mCreatedAt = mFilesMap.value(logDeValue, "").toString();
	mDisplayType = "L";
	FileInfo fi;
	if (fi.isImage(mName)) {
		mDisplayIcon = "../images/image114.png";
	} else if (fi.isVideo(mName)) {
		mDisplayIcon = "../images/video114.png";
	} else if (fi.isAudio(mName)) {
		mDisplayIcon = "../images/audio114.png";
	} else if (fi.getSuffix(mName) == "pdf") {
		mDisplayIcon = "../images/pdf114.png";
	} else if (fi.isCompressed(mName)) {
		mDisplayIcon = "../images/zip114.png";
	} else if (fi.isDocument(mName)) {
		mDisplayIcon = "../images/files-icon.png";
	} else if (fi.isBook(mName)) {
		mDisplayIcon = "../images/ebook114.png";
	} else {
		mDisplayIcon = "../images/other114.png";
	}
	mDisplayTitle = mName;
	if (mFileSize > 1000000000) {
		mDisplayFileSize = QLocale().system().toString(mFileSize/1000000000.0, 'f',3) + " GB";
	} else if (mFileSize > 1000000) {
		mDisplayFileSize = QLocale().system().toString(mFileSize/1000000.0, 'f',3) + " MB";
	} else if (mFileSize > 1000) {
		mDisplayFileSize = QLocale().system().toString(mFileSize/1000.0, 'f',3) + " KB";
	} else {
		mDisplayFileSize = QString::number(mFileSize) + " Bytes";
	}
	mDisplaySubtitle = mCreatedAt +" ("+ mDisplayFileSize + ") id: "+ QString::number(mId);

}

QString ODSFile::name() const {
	return mName;
}
void ODSFile::setName(QString newName) {
	if (newName != mName) {
		mName = newName;
		emit nameChanged(newName);
	}
}

QString ODSFile::path() const {
	return mPath;
}
void ODSFile::setPath(QString newPath) {
	if (newPath != mPath) {
		mPath = newPath;
		emit pathChanged(newPath);
	}
}

QString ODSFile::downloadPath() const {
	return mDownloadPath;
}
void ODSFile::setDownloadPath(QString newDownloadPath) {
	if (newDownloadPath != mDownloadPath) {
		mDownloadPath = newDownloadPath;
		emit downloadPathChanged(newDownloadPath);
	}
}

QString ODSFile::expires() const {
	return mExpires;
}
void ODSFile::setExpires(QString newExpires) {
	if (newExpires != mExpires) {
		mExpires = newExpires;
		emit expiresChanged(newExpires);
	}
}

QString ODSFile::comment() const {
	return mComment;
}
void ODSFile::setComment(QString newComment) {
	if (newComment != mComment) {
		mComment = newComment;
		emit commentChanged(newComment);
	}
}

QString ODSFile::createdBy() const {
	return mCreatedBy;
}
void ODSFile::setCreatedBy(QString newCreatedBy) {
	if (newCreatedBy != mCreatedBy) {
		mCreatedBy = newCreatedBy;
		emit createdByChanged(newCreatedBy);
	}
}

QString ODSFile::createdAt() const {
	return mCreatedAt;
}
void ODSFile::setCreatedAt(QString newCreatedAt) {
	if (newCreatedAt != mCreatedAt) {
		mCreatedAt = newCreatedAt;
		emit createdByChanged(newCreatedAt);
	}
}

int ODSFile::id() const {
	return mId;
}
void ODSFile::setId(int id) {
	if (id != mId) {
		mId = id;
		emit idChanged(id);
	}
}

int ODSFile::level() const {
	return mLevel;
}
void ODSFile::setLevel(int level) {
	if (level != mLevel) {
		mLevel = level;
		emit levelChanged(level);
	}
}

int ODSFile::containerId() const {
	return mContainerId;
}
void ODSFile::setContainerId(int containerId) {
	if (containerId != mContainerId) {
		mContainerId = containerId;
		emit containerIdChanged(containerId);
	}
}

int ODSFile::fileSize() const {
	return mFileSize;
}
void ODSFile::setFileSize(int fileSize) {
	if (fileSize != mFileSize) {
		mFileSize = fileSize;
		emit fileSizeChanged(fileSize);
	}
}

bool ODSFile::downloaded() const {
	return mDownloaded;
}
void ODSFile::setDownloaded(bool downloaded) {
	if (downloaded != mDownloaded) {
		mDownloaded = downloaded;
		emit downloadedChanged(downloaded);
	}
}

QString ODSFile::classification() const {
	return mClassification;
}
void ODSFile::setClassification(QString classification) {
	if (classification != mClassification) {
		mClassification = classification;
		emit classificationChanged(classification);
	}
}

QString ODSFile::displayType() const {
	return mDisplayType;
}

QString ODSFile::displayIcon() const {
	return mDisplayIcon;
}

QString ODSFile::displayTitle() const {
	return mDisplayTitle;
}

QString ODSFile::displaySubtitle() const {
	return mDisplaySubtitle;
}

QString ODSFile::displayFileSize() const {
	return mDisplayFileSize;
}


ODSFile::~ODSFile() {
	//
}

