
#include "ODSData.hpp"
#include <bb/cascades/Application>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/AbstractPane>

using namespace bb::cascades;
using namespace bb::data;

static QString dataPath(const QString& fileName) {
	return QDir::currentPath() + "/data/" + fileName;
}
static QString uploadPath(const QString& fileName) {
	return QDir::currentPath() + "/data/ods/upload/" + fileName;
}

ODSData::ODSData() {
	// prepare all for the work with ODS Servers
	mDelayedInitDone = false;
	// Create a network access manager and connect a custom slot to its
	// finished signal
	mNetworkAccessManager = new QNetworkAccessManager(this);

	bool connectOK = connect(mNetworkAccessManager,
			SIGNAL(finished(QNetworkReply*)), this,
			SLOT(requestFinished(QNetworkReply*)));

	// Displays a warning message if there's an issue connecting the signal
	// and slot. This is a good practice with signals and slots as it can
	// be easier to mistype a slot or signal definition
	Q_ASSERT(connectOK);
	Q_UNUSED(connectOK);
}

// to speed up startup time we delay some parts of initialization
void ODSData::delayedInit() {
	if (mDelayedInitDone) {
		return;
	}
	// init StringLists for Pathes and Errors
	initPathes();
	initErrors();
	// check if all directories are there
	// if not create them
	QDir dir;
	bool exists;
	exists = dir.exists(dataPath("ods"));
	if (!exists) {
		dir.mkpath(dataPath("ods"));
	}
	exists = dir.exists(dataPath("ods/json"));
	if (!exists) {
		dir.mkpath(dataPath("ods/json"));
	}
	exists = dir.exists(dataPath("ods/json/users"));
	if (!exists) {
		dir.mkpath(dataPath("ods/json/users"));
	}
	exists = dir.exists(dataPath("ods/json/files"));
	if (!exists) {
		dir.mkpath(dataPath("ods/json/files"));
	}
	exists = dir.exists(dataPath("ods/json/settings"));
	if (!exists) {
		dir.mkpath(dataPath("ods/json/settings"));
	}
	exists = dir.exists(dataPath("ods/json/texte"));
	if (!exists) {
		dir.mkpath(dataPath("ods/json/texte"));
	}
	exists = dir.exists(dataPath("ods/upload"));
	if (!exists) {
		dir.mkpath(dataPath("ods/upload"));
	}
	Q_UNUSED(exists);
}

// login to the server:
// auth-user-settings-files
void ODSData::loginToServer() {
	if (!mDelayedInitDone) {
		delayedInit();
	}
}

void ODSData::initPathes() {
	mUsecasePathes << "/users/testget" << "/users/testpost" << "/users/auth" << "/users/user"
				<< "/users/all" << "/users/insert" << "/files/all" << "/files/upload" << "/files/copy" << "/files/copyAllFiles"
				<< "/files/rename" << "/files/move" << "/files/update" << "/files/delete" << "/files/download" << "/files/downloadThumbnail"
				<< "/files/createfolder" << "/files/createlink" << "/files/renamefolder" << "/files/deletefolder" << "/files/movefolder"
				<< "/files/getMetadata" << "/files/setMetadata" << "/settings/user" << "/settings/infoliste"
				<< "/texte/all" << "/texte/language";
}

void ODSData::initErrors() {
	mResponseErrorTexts
				<< tr("Code 0: No Error")
				<< tr("Code 1 JSON Error: Server was unable to parse the request.")
				<< tr("Code 2 Invalid Credentials: Invalid user or password specified during login.")
				<< tr("Code 3: Account has expired.")
				<< tr("Code 4: Account locked due to lost mobile device.")
				<< tr("Code 5: Mobile access locked for this account.")
				<< tr("Code 6: Account locked by admin.")
				<< tr("Code 7 Token expired: Session ID has expired. Login has to be invoked again.")
				<< tr("Code 8: User already exists.")
				<< tr("Code 9: Customer not found during AllFilesRequest.")
				<< tr("Code 10: Invalid path.")
				<< tr("Code 11: File write error.")
				<< tr("Code 12 Invalid File: Attempted a file operation using an invalid ID.")
				<< tr("Code 13 File exists: Attempt to copy or move to an existing file.")
				<< tr("Code 14 Folder not empty: Attempted to delete a non-emty folder.")
				<< tr("Code 15: Failed to create a download link.")
				<< tr("Code 16: Maximum number of users reached.")
				<< tr("Code 17: Disk quota was reached.")
				<< tr("Code 18: DeleteAll could not delete all files.")
				<< tr("Code 19: MoveAll could not move all files.")
				<< tr("Code 20: CopyAll could not copy all files.")
				;
}

void ODSData::initUserModel() {

	// seems that ListView and GroupDataModel will be found after Component was destroyed
	// so we access the last one
	// TODO Cascades BUG ???

	//m_UsersDataModel = Application::instance()->scene()->findChild<GroupDataModel*>("userGroupDataModel");
	//m_usersList = Application::instance()->scene()->findChild<ListView*>("usersList");

	m_UsersDataModel = Application::instance()->scene()->findChildren<
			GroupDataModel*>("userGroupDataModel").last();
	m_usersList = Application::instance()->scene()->findChildren<ListView*>(
			"usersList").last();

	qDebug() << "Listview children: "
			<< Application::instance()->scene()->findChildren<ListView*>(
					"usersList").size();
	qDebug() << "DataModel children: "
			<< Application::instance()->scene()->findChildren<GroupDataModel*>(
					"userGroupDataModel").size();

	qDebug() << "initUserModel: ";
	if (m_UsersDataModel) {
		qDebug() << "found GroupDataModel: " << m_UsersDataModel->size();
		QVariantMap map;
		map["name"] = "ekke";
		map["displayType"] = "A";
		map["icon"] = "../images/admin-icon.png";
		m_UsersDataModel->insert(map);
		//m_usersList->resetDataModel();
		//m_usersList->setDataModel(m_UsersDataModel);

	} else {
		qDebug() << "NOT found GroupDataModel :(";
	}
	if (m_usersList) {
		qDebug() << "found ListView";
	} else {
		qDebug() << "NOT found ListView :(";
	}

}

void ODSData::initiateRequest(int usecase) {

}

// S L O T
// async getting info that request was finished
void ODSData::requestFinished(QNetworkReply* reply) {

}

ODSData::~ODSData() {
	// TODO Auto-generated destructor stub
}

