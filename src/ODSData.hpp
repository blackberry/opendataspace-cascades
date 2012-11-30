#ifndef ODSDATA_HPP_
#define ODSDATA_HPP_

#include <qobject.h>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/controls/listview.h>
#include "ODSSettings.hpp"

using namespace bb::cascades;

class ODSData: public QObject {
Q_OBJECT
public:
	ODSData();
	virtual ~ODSData();

	void loginToServer();

	/*!
	 * Initiates the network request.
	 */
	Q_INVOKABLE
	void initiateRequest(int usecase);

	Q_INVOKABLE
	void initUserModel();

	Q_SIGNALS:
		void loginFinished(bool success);

private slots:
    /*!
     * Handles the network reply.
     */
    void requestFinished(QNetworkReply* reply);


private:
    ODSSettings* mOdsSettings;

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
	// temp
	QVariantList mListAllUser;
	QVariantMap mMyUserMap;

	bool mDelayedInitDone;

	void initPathes();
	void initErrors();
	void setRequestheader(QNetworkRequest &request, int usecase);
	void processResponse(QByteArray &replyBytes, int usecase);
	void writeReplyToFile(QByteArray &replyBytes, QString &filename);

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

};

#endif /* ODSDATA_HPP_ */
