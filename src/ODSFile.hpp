

#ifndef ODSFILE_HPP_
#define ODSFILE_HPP_

#include <QObject>
#include <qvariant.h>

class ODSFile: public QObject {
	Q_OBJECT

	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
	Q_PROPERTY(QString comment READ comment WRITE setComment NOTIFY commentChanged FINAL)
	Q_PROPERTY(QString createdBy READ createdBy WRITE setCreatedBy NOTIFY createdByChanged FINAL)
	Q_PROPERTY(QString createdAt READ createdAt WRITE setCreatedAt NOTIFY createdAtChanged FINAL)
	Q_PROPERTY(QString expires READ expires WRITE setExpires NOTIFY expiresChanged FINAL)

	Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
	Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)
	Q_PROPERTY(int containerId READ containerId WRITE setContainerId NOTIFY containerIdChanged FINAL)
	Q_PROPERTY(int fileSize READ fileSize WRITE setFileSize NOTIFY fileSizeChanged FINAL)
	Q_PROPERTY(int classification READ classification WRITE setClassification NOTIFY classificationChanged FINAL)

	Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
	Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)

public:
	ODSFile(QObject *parent = 0);
	virtual ~ODSFile();
	ODSFile(QVariantMap fileMap);

	QString name() const;
	QString displayType() const;
	QString displayIcon() const;
	QString comment() const;
	QString createdBy() const;
	QString createdAt() const;
	QString expires() const;

	int id() const;
	int level() const;
	int containerId() const;
	int fileSize() const;
	int classification() const;

	void setName(QString newName);
	void setComment(QString newComment);
	void setCreatedBy(QString newCreatedBy);
	void setCreatedAt(QString newCreatedAt);
	void setExpires(QString newExpires);

	void setId(int id);
	void setLevel(int level);
	void setContainerId(int containerId);
	void setFileSize(int fileSize);
	void setClassification(int classification);


Q_SIGNALS:

	void nameChanged(QString name);
	void commentChanged(QString comment);
	void createdByChanged(QString createdBy);
	void createdAtChanged(QString createdAt);
	void expiresChanged(QString expires);

	void idChanged(int id);
	void levelChanged(int level);
	void containerIdChanged(int containerId);
	void fileSizeChanged(int fileSize);
	void classificationChanged(int classification);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);

private:

	QVariantMap mFilesMap;
	QString mName;
	QString mComment;
	QString mCreatedBy;
	QString mCreatedAt;
	QString mExpires;

	int mId;
	int mLevel;
	int mContainerId;
	int mFileSize;
	int mClassification;

	QString mDisplayType;
	QString mDisplayIcon;

Q_DISABLE_COPY(ODSFile)
};
Q_DECLARE_METATYPE(ODSFile*)

#endif /* ODSFILE_HPP_ */
