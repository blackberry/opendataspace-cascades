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

	Q_INVOKABLE
	void deleteFolder(int roomId, QString path);

	Q_INVOKABLE
	void downloadFile(int fileId, QString fileName);

	Q_INVOKABLE
	QString thumbnail(int fileId);

	Q_INVOKABLE
	void uploadFile(int roomId, QString fileName, QString path, QString comment);

	Q_INVOKABLE
	void simpleUpload(QString fileName);

	Q_INVOKABLE
	void syncWithServer();

Q_SIGNALS:
	void loginFinished(bool success);

private slots:
	/*!
	 * Handles the network reply.
	 */
	void requestFinished(QNetworkReply* reply);

private:
	bool mDelayedInitDone;

	ODSSettings* mOdsSettings;

	SystemProgressDialog* mProgressDialog;

	// network access
	QNetworkAccessManager *mNetworkAccessManager;
	QByteArray mRequestJson;
	QHttpMultiPart *mRequestMultipart;

	// maps ODS server parameters and error codes
	QStringList mResponseErrorTexts;
	QStringList mUsecasePathes;

	//
	QString mUser;
	QString mPassword;
	QString mBaseUrl;

	// some vars used for ods server calls
	QString mToken;
	int mCustomerNumber;
	int mLanguageNumber;
	QFile *mFileToUpload;
	QString mFileName;
	QString mSourceFileName;
	int mFileId;
	int mFileLength;
	int mGroupPk;
	QString mPath;
	QString mComment;

	// models and caches
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


	void initPathes();
	void initErrors();
	void setRequestheader(QNetworkRequest &request, int usecase);
	bool processResponse(QByteArray &replyBytes, int usecase);
	bool writeReplyToFile(QByteArray &replyBytes, QString &filename);
	QVariantMap readDataFromJson(int usecase);

	void showFilesFromNode(QVariantList nodes, bool isBackNavigation);
	QString folderPath(bool isBackNavigation);

	void refreshCaches();
	void reloadFiles();
	void createRoomsModel();

	/**
	 * some parts of initialization will be done delayed
	 * when user did the Login
	 */
	void delayedInit();

	void reportError(QString &errorText);

};

#endif /* ODSDATA_HPP_ */
