

#include "ODSSubRoom.hpp"
#include <QDebug>

ODSSubRoom::ODSSubRoom(QObject *parent) {}

ODSSubRoom::ODSSubRoom(QVariantMap subRoomMap) :
				QObject() {

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



ODSSubRoom::~ODSSubRoom() {
	// TODO Auto-generated destructor stub
}

