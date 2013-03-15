#ifndef ODSDATA_HPP_
#define ODSDATA_HPP_

#include <qobject.h>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/controls/listview.h>
#include "ODSSettings.hpp"
#include <bb/system/SystemProgressDialog.hpp>
#include <bb/system/SystemDialog>
#include <bb/system/SystemPrompt.hpp>
#include <bb/system/SystemToast.hpp>

using namespace bb::cascades;
using namespace bb::system;

class ODSData: public QObject {
Q_OBJECT
public:
	ODSData();
	virtual ~ODSData();

	void loginToServer();
	void resetUserFromLogout();

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
	void addUser(QVariantList userdata);

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
	void createLink(int fileId, QString fileName, bool expires, QDate expiration, QString password, QString code, bool notice, bool shareViaMail);

	Q_INVOKABLE
	void deleteFolder(int roomId, QString path);

	Q_INVOKABLE
	void deleteFile(int fileId, QString fileName);

	Q_INVOKABLE
	void renameFolder(int roomId, QString pathOld, QString folderNameOld);

	Q_INVOKABLE
	void renameFile(int fileId, QString fileNameOld);

	Q_INVOKABLE
	void downloadFile(int fileId, QString fileName, qint64 fileSizeBytes);

	Q_INVOKABLE
	bool fileDownloaded(int fileId, QString fileName);

	Q_INVOKABLE
	QString thumbnail(int fileId);

	Q_INVOKABLE
	void uploadFile(int roomId, QString fileName, QString path, QString comment);

	Q_INVOKABLE
	void simpleUpload(QString fileName);

	Q_INVOKABLE
	void syncWithServer();

	Q_INVOKABLE
	void createRoomsDropDown();

Q_SIGNALS:
	void loginFinished(bool success);
	void shareLinkWithBBM(const QString& textToShare);
	void shareLinkWithMail(const QString& textToShare);

private slots:
	/*!
	 * Handles the network reply.
	 */
	void requestFinished(QNetworkReply* reply);

	/**
	 * handles interrupted login
	 */
	void loginInterrupted();

	/**
	 * bytesTotal can be -1 if size not known
	 * ignore if both are 0 == no download (one time emitted)
	 * The download is finished when bytesReceived is equal to bytesTotal.
	 * At that time, bytesTotal will not be -1
	 */
	void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);

	/**
	 * bytesTotal can be -1 if size not known
	 * no signal emitted if no upload
	 * The upload is finished when bytesSent is equal to bytesTotal.
	 * At that time, bytesTotal will not be -1
	 */
	void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

private:
	bool mDelayedInitDone;

	ODSSettings* mOdsSettings;

	SystemProgressDialog* mProgressDialog;
	SystemDialog* mDialog;
	SystemPrompt* mPrompt;
	SystemToast* mToast;

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
	qint64 mRequestedFileSize;
	QString mSourceFileName;
	int mFileId;
	int mFileLength;
	int mGroupPk;
	QString mPath;
	QString mPathNew;
	QString mComment;
	QString mExpiration;
	QString mLinkPassword;
	QString mNotice;
	bool mShareViaMail;

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
	void shareLink();
	void mailLink();


	/**
	 * some parts of initialization will be done delayed
	 * when user did the Login
	 */
	void delayedInit();

	void reportError(QString &errorText);

};

#endif /* ODSDATA_HPP_ */
