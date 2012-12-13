#ifndef ODSFOLDER_HPP_
#define ODSFOLDER_HPP_

#include <QObject>
#include <qvariant.h>

class ODSFolder: public QObject {
Q_OBJECT

Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)

Q_PROPERTY(int containerId READ containerId WRITE setContainerId NOTIFY containerIdChanged FINAL)
Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)
Q_PROPERTY(int roomId READ roomId WRITE setRoomId NOTIFY roomIdChanged FINAL)
Q_PROPERTY(int children READ children NOTIFY childrenChanged FINAL)

Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)
Q_PROPERTY(QString displayTitle READ displayTitle NOTIFY displayTitleChanged FINAL)
Q_PROPERTY(QString displaySubtitle READ displaySubtitle NOTIFY displaySubtitleChanged FINAL)

Q_PROPERTY(QVariantList nodes READ nodes NOTIFY nodesChanged FINAL)

public:
	ODSFolder(QObject *parent = 0);
	virtual ~ODSFolder();
	ODSFolder(QVariantMap folderMap, QString path);
	QVariantList nodes() const;

	QString name() const;
	QString displayType() const;
	QString displayIcon() const;
	QString path() const;

	int containerId() const;
	int level() const;
	int roomId() const;
	int children() const;
	QString displayTitle() const;
	QString displaySubtitle() const;

	void setName(QString newName);
	void setPath(QString newPath);

	void setContainerId(int containerId);
	void setLevel(int level);
	void setRoomId(int roomId);

Q_SIGNALS:

	void nameChanged(QString name);
	void pathChanged(QString path);

	void containerIdChanged(int containerId);
	void levelChanged(int level);
	void roomIdChanged(int roomId);
	void childrenChanged(int children);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);
	void displayTitleChanged(QString displayTitle);
	void displaySubtitleChanged(QString displaySubtitle);

	void nodesChanged(QVariantList nodes);

private:

	QVariantMap mFoldersMap;
	QVariantList mNodes;
	QString mName;
	QString mPath;

	int mContainerId;
	int mLevel;
	int mRoomId;
	int mChildren;

	QString mDisplayType;
	QString mDisplayIcon;
	QString mDisplayTitle;
	QString mDisplaySubtitle;

	Q_DISABLE_COPY(ODSFolder)
};
Q_DECLARE_METATYPE(ODSFolder*)

#endif /* ODSFOLDER_HPP_ */
