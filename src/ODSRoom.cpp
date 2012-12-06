

#include "ODSRoom.hpp"
#include <QDebug>

ODSRoom::ODSRoom(QObject *parent) {}

ODSRoom::ODSRoom(QVariantMap roomMap) :
				QObject(), mRoomsMap(roomMap) {

}

QString ODSRoom::name() const {
	return mName;
}
void ODSRoom::setName(QString newName) {
	if (newName != mName) {
		mName = newName;
		emit nameChanged(newName);
	}
}

int ODSRoom::id() const {
	return mId;
}
void ODSRoom::setId(int id) {
	if (id != mId) {
		mId = id;
		emit idChanged(id);
	}
}

int ODSRoom::level() const {
	return mLevel;
}
void ODSRoom::setLevel(int level) {
	if (level != mLevel) {
		mLevel = level;
		emit levelChanged(level);
	}
}




ODSRoom::~ODSRoom() {
	// TODO Auto-generated destructor stub
}

