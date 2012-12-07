

#include "ODSSubRoom.hpp"
#include <QDebug>

//static const QString isGroupValue = "is_group";
//static const QString fileSizeValue = "file_size";
static const QString nodesValue = "nodes";
static const QString nameValue = "name";
//static const QString isAssignedValue = "is_assigned";
static const QString parentValue = "parent";
//static const QString typeValue = "type";
static const QString groupPkValue = "group_pk";

ODSSubRoom::ODSSubRoom(QObject *parent) {}

ODSSubRoom::ODSSubRoom(QVariantMap subRoomMap) :
				QObject(), mSubRoomsMap(subRoomMap) {
	mName = mSubRoomsMap.value(nameValue, "").toString();
	mId = mSubRoomsMap.value(groupPkValue, 0).toInt();
	mRoomId = mSubRoomsMap.value(parentValue, 0).toInt();
	mDisplayType = "S";
	mDisplayIcon = "../images/subrooms-icon.png";
	mNodes = mSubRoomsMap.value(nodesValue).toList();
}

QString ODSSubRoom::name() const {
	return mName;
}
void ODSSubRoom::setName(QString newName) {
	if (newName != mName) {
		mName = newName;
		emit nameChanged(newName);
	}
}

int ODSSubRoom::id() const {
	return mId;
}
void ODSSubRoom::setId(int id) {
	if (id != mId) {
		mId = id;
		emit idChanged(id);
	}
}

int ODSSubRoom::level() const {
	return mLevel;
}
void ODSSubRoom::setLevel(int level) {
	if (level != mLevel) {
		mLevel = level;
		emit levelChanged(level);
	}
}

int ODSSubRoom::roomId() const {
	return mRoomId;
}
void ODSSubRoom::setRoomId(int roomId) {
	if (roomId != mRoomId) {
		mRoomId = roomId;
		emit roomIdChanged(roomId);
	}
}

QString ODSSubRoom::displayType() const {
	return mDisplayType;
}

QString ODSSubRoom::displayIcon() const {
	return mDisplayIcon;
}

QVariantList ODSSubRoom::nodes() const {
	return mNodes;
}


ODSSubRoom::~ODSSubRoom() {
	// TODO Auto-generated destructor stub
}

