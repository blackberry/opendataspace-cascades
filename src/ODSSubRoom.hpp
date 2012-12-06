#ifndef ODSSUBROOM_HPP_
#define ODSSUBROOM_HPP_

#include <QObject>
#include <qvariant.h>

class ODSSubRoom: public QObject {
Q_OBJECT

Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)

Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)
Q_PROPERTY(int roomId READ roomId WRITE setRoomId NOTIFY roomIdChanged FINAL)

Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)

public:
	ODSSubRoom(QObject *parent = 0);
	virtual ~ODSSubRoom();
	ODSSubRoom(QVariantMap subRoomMap);

	QString name() const;
	QString displayType() const;
	QString displayIcon() const;

	int id() const;
	int level() const;
	int roomId() const;

	void setName(QString newName);

	void setId(int id);
	void setLevel(int level);
	void setRoomId(int roomId);

Q_SIGNALS:

	void nameChanged(QString name);

	void idChanged(int id);
	void levelChanged(int level);
	void roomIdChanged(int roomId);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);

private:

	QVariantMap mSubRoomsMap;
	QString mName;

	int mId;
	int mLevel;
	int mRoomId;

	QString mDisplayType;
	QString mDisplayIcon;

	Q_DISABLE_COPY(ODSSubRoom)
};
Q_DECLARE_METATYPE(ODSSubRoom*)

#endif /* ODSSUBROOM_HPP_ */
