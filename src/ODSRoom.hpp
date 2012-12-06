#ifndef ODSROOM_HPP_
#define ODSROOM_HPP_

#include <QObject>
#include <qvariant.h>

class ODSRoom: public QObject {
Q_OBJECT

Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)

Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)

public:
	ODSRoom(QObject *parent = 0);
	virtual ~ODSRoom();
	ODSRoom(QVariantMap roomMap);

	QString name() const;

	int id() const;
	int level() const;

	void setName(QString newName);

	void setId(int id);
	void setLevel(int level);

Q_SIGNALS:

	void nameChanged(QString name);

	void idChanged(int id);
	void levelChanged(int level);

private:

	QVariantMap mRoomsMap;
	QString mName;

	int mId;
	int mLevel;

	Q_DISABLE_COPY(ODSRoom)
};
Q_DECLARE_METATYPE(ODSRoom*)

#endif /* ODSROOM_HPP_ */
