#ifndef ODSROOM_HPP_
#define ODSROOM_HPP_

#include <QObject>
#include <qvariant.h>

class ODSRoom: public QObject {
Q_OBJECT

Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)

Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)

Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)

public:
	ODSRoom(QObject *parent = 0);
	virtual ~ODSRoom();
	ODSRoom(QVariantMap roomMap);

	QString name() const;
	QString displayType() const;
	QString displayIcon() const;

	int id() const;
	int level() const;

	void setName(QString newName);

	void setId(int id);
	void setLevel(int level);

Q_SIGNALS:

	void nameChanged(QString name);

	void idChanged(int id);
	void levelChanged(int level);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);

private:

	QVariantMap mRoomsMap;
	QString mName;

	int mId;
	int mLevel;

	QString mDisplayType;
	QString mDisplayIcon;

	Q_DISABLE_COPY(ODSRoom)
};
Q_DECLARE_METATYPE(ODSRoom*)

#endif /* ODSROOM_HPP_ */
