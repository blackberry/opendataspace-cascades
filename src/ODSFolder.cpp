

#include "ODSFolder.hpp"
#include <QDebug>

ODSFolder::ODSFolder(QObject *parent) {}

ODSFolder::ODSFolder(QVariantMap folderMap) :
				QObject() {

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





ODSFolder::~ODSFolder() {
	// TODO Auto-generated destructor stub
}

