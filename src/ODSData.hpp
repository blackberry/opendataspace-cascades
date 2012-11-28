#ifndef ODSDATA_HPP_
#define ODSDATA_HPP_

#include <qobject.h>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/controls/listview.h>

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

private slots:
    /*!
     * Handles the network reply.
     */
    void requestFinished(QNetworkReply* reply);


private:
	QNetworkAccessManager *mNetworkAccessManager;
    QStringList mResponseErrorTexts;
    QStringList mUsecasePathes;

	GroupDataModel* m_UsersDataModel;
	ListView* m_usersList;

	bool mDelayedInitDone;

	void initPathes();
	void initErrors();

	/**
	 * some parts of initialization will be done delayed
	 * when user did the Login
	 */
	void delayedInit();
};

#endif /* ODSDATA_HPP_ */
