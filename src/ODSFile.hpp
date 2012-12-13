

#ifndef ODSFILE_HPP_
#define ODSFILE_HPP_

#include <QObject>
#include <qvariant.h>

class ODSFile: public QObject {
	Q_OBJECT

	Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
	Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(QString comment READ comment WRITE setComment NOTIFY commentChanged FINAL)
	Q_PROPERTY(QString createdBy READ createdBy WRITE setCreatedBy NOTIFY createdByChanged FINAL)
	Q_PROPERTY(QString createdAt READ createdAt WRITE setCreatedAt NOTIFY createdAtChanged FINAL)
	Q_PROPERTY(QString expires READ expires WRITE setExpires NOTIFY expiresChanged FINAL)
	Q_PROPERTY(QString classification READ classification WRITE setClassification NOTIFY classificationChanged FINAL)

	Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged FINAL)
	Q_PROPERTY(int level READ level WRITE setLevel NOTIFY levelChanged FINAL)
	Q_PROPERTY(int containerId READ containerId WRITE setContainerId NOTIFY containerIdChanged FINAL)
	Q_PROPERTY(int fileSize READ fileSize WRITE setFileSize NOTIFY fileSizeChanged FINAL)


	Q_PROPERTY(QString displayType READ displayType NOTIFY displayTypeChanged FINAL)
	Q_PROPERTY(QString displayIcon READ displayIcon NOTIFY displayIconChanged FINAL)
	Q_PROPERTY(QString displayTitle READ displayTitle NOTIFY displayTitleChanged FINAL)
	Q_PROPERTY(QString displaySubtitle READ displaySubtitle NOTIFY displaySubtitleChanged FINAL)
	Q_PROPERTY(QString displayFileSize READ displayFileSize NOTIFY displayFileSizeChanged FINAL)

public:
	ODSFile(QObject *parent = 0);
	virtual ~ODSFile();
	ODSFile(QVariantMap fileMap, QString path);

	QString name() const;
	QString path() const;
	QString displayType() const;
	QString displayIcon() const;
	QString displayTitle() const;
	QString displaySubtitle() const;
	QString displayFileSize() const;

	QString comment() const;
	QString createdBy() const;
	QString createdAt() const;
	QString expires() const;

	int id() const;
	int level() const;
	int containerId() const;
	int fileSize() const;
	QString classification() const;

	void setName(QString newName);
	void setPath(QString newPath);
	void setComment(QString newComment);
	void setCreatedBy(QString newCreatedBy);
	void setCreatedAt(QString newCreatedAt);
	void setExpires(QString newExpires);

	void setId(int id);
	void setLevel(int level);
	void setContainerId(int containerId);
	void setFileSize(int fileSize);
	void setClassification(QString classification);


Q_SIGNALS:

	void nameChanged(QString name);
	void pathChanged(QString path);
	void commentChanged(QString comment);
	void createdByChanged(QString createdBy);
	void createdAtChanged(QString createdAt);
	void expiresChanged(QString expires);

	void idChanged(int id);
	void levelChanged(int level);
	void containerIdChanged(int containerId);
	void fileSizeChanged(int fileSize);
	void classificationChanged(QString classification);

	void displayTypeChanged(QString displayType);
	void displayIconChanged(QString displayIcon);
	void displayTitleChanged(QString displayTitle);
	void displaySubtitleChanged(QString displaySubtitle);
	void displayFileSizeChanged(QString displayFileSize);

private:

	QVariantMap mFilesMap;
	QString mName;
	QString mPath;
	QString mComment;
	QString mCreatedBy;
	QString mCreatedAt;
	QString mExpires;

	int mId;
	int mLevel;
	int mContainerId;
	int mFileSize;
	QString mClassification;

	QString mDisplayType;
	QString mDisplayIcon;
	QString mDisplayTitle;
	QString mDisplaySubtitle;
	QString mDisplayFileSize;

Q_DISABLE_COPY(ODSFile)
};
Q_DECLARE_METATYPE(ODSFile*)

#endif /* ODSFILE_HPP_ */
