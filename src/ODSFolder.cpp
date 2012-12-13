

#include "ODSFolder.hpp"
#include <QDebug>

//static const QString isGroupValue = "is_group";
//static const QString fileSizeValue = "file_size";
static const QString nodesValue = "nodes";
static const QString nameValue = "name";
//static const QString isAssignedValue = "is_assigned";
static const QString parentValue = "parent";
//static const QString typeValue = "type";
static const QString groupPkValue = "group_pk";

ODSFolder::ODSFolder(QObject *parent) {}

ODSFolder::ODSFolder(QVariantMap folderMap, QString path) :
				QObject(), mFoldersMap(folderMap), mPath(path) {
	mName = mFoldersMap.value(nameValue, "").toString();
	mContainerId = mFoldersMap.value(groupPkValue, 0).toInt();
	mRoomId = mFoldersMap.value(parentValue, 0).toInt();
	mDisplayType = "F";
	mDisplayIcon = "../images/folders-icon.png";
	mNodes = mFoldersMap.value(nodesValue).toList();
	mChildren = mNodes.size();
	mDisplayTitle = mName;
	if (mChildren > 0) {
		mDisplaySubtitle = tr("contains ") + QString::number(mChildren) + tr(" Files / Folders");
	} else {
		mDisplaySubtitle = tr("empty Folder");
	}
}

QString ODSFolder::name() const {
	return mName;
}
void ODSFolder::setName(QString newName) {
	if (newName != mName) {
		mName = newName;
		emit nameChanged(newName);
	}
}

QString ODSFolder::path() const {
	return mPath;
}
void ODSFolder::setPath(QString newPath) {
	if (newPath != mPath) {
		mPath = newPath;
		emit pathChanged(newPath);
	}
}

int ODSFolder::containerId() const {
	return mContainerId;
}
void ODSFolder::setContainerId(int containerId) {
	if (containerId != mContainerId) {
		mContainerId = containerId;
		emit containerIdChanged(containerId);
	}
}

int ODSFolder::level() const {
	return mLevel;
}
void ODSFolder::setLevel(int level) {
	if (level != mLevel) {
		mLevel = level;
		emit levelChanged(level);
	}
}

int ODSFolder::roomId() const {
	return mRoomId;
}
void ODSFolder::setRoomId(int roomId) {
	if (roomId != mRoomId) {
		mRoomId = roomId;
		emit roomIdChanged(roomId);
	}
}

int ODSFolder::children() const {
	return mChildren;
}

QString ODSFolder::displayType() const {
	return mDisplayType;
}

QString ODSFolder::displayIcon() const {
	return mDisplayIcon;
}

QString ODSFolder::displayTitle() const {
	return mDisplayTitle;
}

QString ODSFolder::displaySubtitle() const {
	return mDisplaySubtitle;
}

QVariantList ODSFolder::nodes() const {
	return mNodes;
}


ODSFolder::~ODSFolder() {
	// TODO Auto-generated destructor stub
}

