#ifndef ODSDATA_HPP_
#define ODSDATA_HPP_

#include <qobject.h>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/controls/listview.h>
#include "ODSSettings.hpp"
#include <bb/system/SystemProgressDialog.hpp>

using namespace bb::cascades;
using namespace bb::system;

class ODSData: public QObject {
Q_OBJECT
public:
	ODSData();
	virtual ~ODSData();

	void loginToServer();

	Q_INVOKABLE
	bool loginValid();

	Q_INVOKABLE
	void resetLevel();

	/*!
	 * Initiates the network request.
	 */
	Q_INVOKABLE
	void initiateRequest(int usecase);

	Q_INVOKABLE
	void initUserModel();

	Q_INVOKABLE
	void initRoomsModel();

	Q_INVOKABLE
	void showNextNode(QVariantList nodes, QString name);

	Q_INVOKABLE
	bool showPreviousNode();

	Q_INVOKABLE
	QString nodeTitleName();

	Q_INVOKABLE
	QString nodePath();

	Q_INVOKABLE
	QString roomGroupName(int groupId);

	Q_INVOKABLE
	QObject* fileFromId(int fileId);

	Q_INVOKABLE
	QObject* folderFromName(QString folderName);

	Q_INVOKABLE
	QObject* subroomFromId(int subroomId);

	Q_INVOKABLE
	QObject* roomFromId(int roomId);

	Q_INVOKABLE
	QObject* parentData();

	Q_INVOKABLE
	void createFolder(int roomId, QString path);

Q_SIGNALS:
	void loginFinished(bool success);

private slots:
	/*!
	 * Handles the network reply.
	 */
	void requestFinished(QNetworkReply* reply);

private:
	ODSSettings* mOdsSettings;

	SystemProgressDialog* mProgressDialog;

	QNetworkAccessManager *mNetworkAccessManager;
	QStringList mResponseErrorTexts;
	QStringList mUsecasePathes;

	QString mToken;
	QString mUser;
	QString mPassword;
	QString mBaseUrl;
	QString mFileName;
	QByteArray mRequestJson;
	QHttpMultiPart *mRequestMultipart;
	QFile *mFileToUpload;
	int mCustomerNumber;
	int mLanguageNumber;
	int mFileId;
	qint64 mFileLength;
	qint64 mGroupPk;
	QString mParentPath;
	QString mComment;

	GroupDataModel* mUsersDataModel;
	GroupDataModel* mRoomsDataModel;
	GroupDataModel* mFilesDataModel;
	ListView* mRoomsListView;
	int mFilesLevel;
	QVariantList* mRooms;
	QVariantList* mCache;
	QStringList* mNodeNames;
	int mFolderLevel;
	QMap<int, QString>* mRoomGroups;

	bool mDelayedInitDone;

	void initPathes();
	void initErrors();
	void setRequestheader(QNetworkRequest &request, int usecase);
	bool processResponse(QByteArray &replyBytes, int usecase);
	bool writeReplyToFile(QByteArray &replyBytes, QString &filename);
	QVariantMap readDataFromJson(int usecase);

	void showFilesFromNode(QVariantList nodes, bool isBackNavigation);
	QString folderPath(bool isBackNavigation);

	void refreshCaches();

	/**
	 * some parts of initialization will be done delayed
	 * when user did the Login
	 */
	void delayedInit();

	/**
	 * starts the Activity Indicator
	 * can be a progress indicator or dialog window
	 */
	void startActivityIndicator();
	/**
	 * stops the Activity Indicator
	 */
	void stopActivityIndicator();
	/**
	 * progress of the Activity 1-100
	 */
	void progressActivityIndicator(int value);

	void reportError(QString &errorText);

};

#endif /* ODSDATA_HPP_ */
