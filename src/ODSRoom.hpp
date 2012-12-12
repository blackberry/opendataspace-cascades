#ifndef ODSROOM_HPP_
#define ODSROOM_HPP_

#include <QObject>
#include <qvariant.h>

class ODSRoom: public QObject {
Q_OBJECT

Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)

Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)
Q_PROPERTY(int children READ children NOTIFY childrenChanged FINAL)

Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)
Q_PROPERTY(QString displayTitle READ displayTitle NOTIFY displayTitleChanged FINAL)
Q_PROPERTY(QString displaySubtitle READ displaySubtitle NOTIFY displaySubtitleChanged FINAL)

Q_PROPERTY(QVariantList nodes READ nodes NOTIFY nodesChanged FINAL)

public:
	ODSRoom(QObject *parent = 0);
	virtual ~ODSRoom();
	ODSRoom(QVariantMap roomMap);
	QVariantList nodes() const;

	QString name() const;
	QString displayType() const;
	QString displayIcon() const;
	QString displayTitle() const;
	QString displaySubtitle() const;

	int id() const;
	int level() const;
	int children() const;

	void setName(QString newName);

	void setId(int id);
	void setLevel(int level);

Q_SIGNALS:

	void nameChanged(QString name);

	void idChanged(int id);
	void levelChanged(int level);
	void childrenChanged(int children);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);
	void displayTitleChanged(QString displayTitle);
	void displaySubtitleChanged(QString displaySubtitle);

	void nodesChanged(QVariantList nodes);

private:

	QVariantMap mRoomsMap;
	QVariantList mNodes;
	QString mName;

	int mId;
	int mLevel;
	int mChildren;

	QString mDisplayType;
	QString mDisplayIcon;
	QString mDisplayTitle;
	QString mDisplaySubtitle;

	Q_DISABLE_COPY(ODSRoom)
};
Q_DECLARE_METATYPE(ODSRoom*)

#endif /* ODSROOM_HPP_ */
