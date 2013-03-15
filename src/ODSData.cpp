#include "ODSData.hpp"
#include "ODSUser.hpp"
#include "ODSRoom.hpp"
#include "ODSSubRoom.hpp"
#include "ODSFolder.hpp"
#include "ODSFile.hpp"
#include "Singleton.hpp"
#include <QUrl>
#include <bb/cascades/Application>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/controls/dropdown.h>
#include <bb/cascades/controls/option.h>
#include <bb/system/SystemProgressDialog.hpp>
#include <bb/system/SystemUiButton.hpp>
#include <bb/system/SystemUiProgressState>
#include <bb/system/SystemUiResult>
#include "FileInfo.hpp"

#include <Usecase.hpp>

using namespace bb::cascades;
using namespace bb::data;
using namespace bb::system;

static QString dataPath(const QString& fileName) {
	return QDir::currentPath() + "/data/" + fileName;
}
static QString uploadPath(const QString& fileName) {
	return QDir::currentPath() + "/data/ods/upload/" + fileName;
}
static QString downloadPath(const QString& fileName) {
	return QDir::currentPath() + "/data/ods/download/" + fileName;
}
static QString thumbnailPath(const QString& fileName) {
	return QDir::currentPath() + "/data/ods/thumbnails/" + fileName;
}
static const QString isGroupValue = "is_group";
static const QString typeValue = "type";
static const QString nodesValue = "nodes";
static const QString fileIdValue = "fileID";
static const QString nameValue = "name";
static const QString groupsValue = "groups";
static const QString groupPkValue = "group_pk";
static const QString parentValue = "parent";

static const QString tokenValue = "token";
static const QString pathValue = "path";
static const QString pathNewValue = "new_path";
static const QString pathOldValue = "old_path";
static const QString contentValue = "content";
static const QString usernameValue = "username";
static const QString passwordValue = "password";
static const QString customerNumberValue = "customer_nr";
static const QString linkValue = "link";
static const QString linkLanguageValue = "link_language";
static const QString linkExpirationValue = "link_expiration";
static const QString linkPasswordValue = "link_password";
static const QString linkCodeValue = "link_code";
static const QString noticeDownloadValue = "noticeDownload";

static const int deleteNotEmpty = 1;

static const QChar jsonStart = '{';
static const QChar jsonEnd = '}';
static const QString quotationMark = "\"";
static const QChar colon = ':';
static const QChar comma = ',';

ODSData::ODSData() {
	// prepare all for the work with ODS Servers
	mDelayedInitDone = false;
	// Create a network access manager and connect a custom slot to its
	// finished signal
	mNetworkAccessManager = new QNetworkAccessManager(this);
	bool connectOK = connect(mNetworkAccessManager,
			SIGNAL(finished(QNetworkReply*)), this,
			SLOT(requestFinished(QNetworkReply*)));

	// access to the settings
	mOdsSettings = &Singleton<ODSSettings>::Instance(); // new ODSSettings();
	mCustomerNumber = -1;
	mFilesLevel = -1;
	mFolderLevel = -1;
	mRooms = new QVariantList;
	mCache = new QVariantList;
	mNodeNames = new QStringList;
	mRoomGroups = new QMap<int, QString>;

	mProgressDialog = new SystemProgressDialog(this);
	mDialog = new SystemDialog(this);
	mToast = new SystemToast(this);
	mPrompt = new SystemPrompt(this);

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
	exists = dir.exists(dataPath("ods/download"));
	if (!exists) {
		dir.mkpath(dataPath("ods/download"));
	}
	exists = dir.exists(dataPath("ods/thumbnails"));
	if (!exists) {
		dir.mkpath(dataPath("ods/thumbnails"));
	}
	Q_UNUSED(exists);
}

// login to the server:
void ODSData::loginToServer() {
	if (!mDelayedInitDone) {
		delayedInit();
	}
	mBaseUrl = mOdsSettings->getServerUrl();
	// mProgressDialog = new SystemProgressDialog(this);
	bool ok = connect(mProgressDialog,
			SIGNAL(finished(bb::system::SystemUiResult::Type)), this,
			SLOT(loginInterrupted()));
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Sync with OpenDataSpace"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("connect Server, authenticate user..."));
	mProgressDialog->show();

	mUser = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_USER, "");
	mPassword = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_PASSWORD,
			"");

	// auth-user-settings-files
	initiateRequest(-1);

}

void ODSData::resetUserFromLogout() {
	mCustomerNumber = -1;
	mUser = "";
	mPassword = "";
	mFilesLevel = -1;
	mFolderLevel = -1;
	mRooms = new QVariantList;
	mCache = new QVariantList;
	mNodeNames = new QStringList;
	mRoomGroups = new QMap<int, QString>;
	mToken = "";
}

bool ODSData::loginValid() {
	// TODO add check last login time
	// if from today: OK
	if (mCustomerNumber <= 0) {
		qDebug() << "customer number missing ";
		return false;
	}
	if (mUser.isNull() || mUser.isEmpty()) {
		qDebug() << "user missing ";
		return false;
	}
	if (mToken.isNull() || mToken.isEmpty()) {
		qDebug() << "token missing ";
		return false;
	}
	return true;
}

// private SLOT
/**
 * login finished or interrupted (cancel button)
 */
void ODSData::loginInterrupted() {
	switch (mProgressDialog->result()) {
	case SystemUiResult::CancelButtonSelection:
		qDebug() << "login   C A N C E L E D";
		if (mProgressDialog->state() == SystemUiProgressState::Inactive) {
			// nothing to do
			return;
		}
		mProgressDialog->setState(SystemUiProgressState::Error);
		// now we have to test if we can go on without valid Login
		if (mOdsSettings->isTrueFor(SETTINGS_KEY_FILES_AVAILABLE, false)) {
			// mDialog = new SystemDialog(this);
			mDialog->setTitle(tr("Login interrupted"));
			mDialog->setBody(
					tr("... using Data synchronized at: ")
							+ mOdsSettings->getValueFor(
									SETTINGS_KEY_FILES_LAST_SYNC, "?????"));
			mDialog->cancelButton()->setLabel(QString::null);
			mDialog->defaultButton()->setLabel(tr("OK"));
			mDialog->exec();
			emit loginFinished(true);
		} else {
			// sorry no login without data
			// login sheet will remain
			emit loginFinished(false);
		}
		break;
	case SystemUiResult::ConfirmButtonSelection:
		qDebug() << "login   C O N F I R M E D";
		// nothing to do here
		return;
	default:
		break;
	}
	bool ok = disconnect(mProgressDialog,
			SIGNAL(finished(bb::system::SystemUiResult::Type)), this,
			SLOT(loginInterrupted()));
	qDebug() << "disconnected from loginInterrupted: " << ok;
}

void ODSData::initPathes() {
	mUsecasePathes << "/users/testget" << "/users/testpost" << "/users/auth"
			<< "/users/user" << "/users/all" << "/users/insert" << "/files/all"
			<< "/files/upload" << "/files/copy" << "/files/copyAllFiles"
			<< "/files/rename" << "/files/move" << "/files/update"
			<< "/files/delete" << "/files/download"
			<< "/files/downloadThumbnail" << "/files/createfolder"
			<< "/files/createlink" << "/files/renamefolder"
			<< "/files/deletefolder" << "/files/movefolder"
			<< "/files/getMetadata" << "/files/setMetadata" << "/settings/user"
			<< "/settings/infoliste" << "/texte/all" << "/texte/language";
}

void ODSData::initErrors() {
	mResponseErrorTexts
			<< tr(
					"Code 0: Unknown User, are you registered ? You can try out using Testdrive")
			<< tr("Code 1 JSON Error: Server was unable to parse the request.")
			<< tr(
					"Code 2 Invalid Credentials: Invalid user or password specified during login.")
			<< tr("Code 3: Account has expired.")
			<< tr("Code 4: Account locked due to lost mobile device.")
			<< tr("Code 5: Mobile access locked for this account.")
			<< tr("Code 6: Account locked by admin.")
			<< tr(
					"Code 7 Token expired: Session ID has expired. Login has to be invoked again.")
			<< tr("Code 8: User already exists.")
			<< tr("Code 9: Customer not found during AllFilesRequest.")
			<< tr("Code 10: Invalid path.") << tr("Code 11: File write error.")
			<< tr(
					"Code 12 Invalid File: Attempted a file operation using an invalid ID.")
			<< tr(
					"Code 13 File exists: Attempt to copy or move to an existing file.")
			<< tr(
					"Code 14 Folder not empty: Attempted to delete a non-emty folder.")
			<< tr("Code 15: Failed to create a download link.")
			<< tr("Code 16: Maximum number of users reached.")
			<< tr("Code 17: Disk quota was reached.")
			<< tr("Code 18: DeleteAll could not delete all files.")
			<< tr("Code 19: MoveAll could not move all files.")
			<< tr("Code 20: CopyAll could not copy all files.");
}

//  M O D E L     F O R    L I S T V I E W S
void ODSData::initUserModel() {

	// this bug is fixed, to be safe I continue to use findChildren()
	// TODO remove later
	//mUsersDataModel = Application::instance()->scene()->findChild<GroupDataModel*>("userGroupDataModel");
	mUser = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_USER, "");
	mPassword = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_PASSWORD,
			"");

	mUsersDataModel = Application::instance()->scene()->findChildren<
			GroupDataModel*>("userGroupDataModel").last();
	qDebug() << "DataModel children: "
			<< Application::instance()->scene()->findChildren<GroupDataModel*>(
					"userGroupDataModel").size();

	// get all users
	// TODO initiate all users and wait for response

	qDebug() << "initUserModel: ";
	if (mUsersDataModel) {
		mUsersDataModel->clear();
		QVariantMap dataMap;
		QVariantList dataList;

		// get my own users data
		dataMap = readDataFromJson(Usecase::UsersUser);
		if (!dataMap.isEmpty()) {
			mUsersDataModel->insert(new ODSUser(dataMap));
		}

		// all the other users
		dataMap = readDataFromJson(Usecase::UsersAll);
		if (!dataMap.isEmpty()) {
			dataList = dataMap.value("users", "").toList();
			if (!dataList.isEmpty()) {
				for (int i = 0; i < dataList.size(); ++i) {
					QVariantMap map = dataList.at(i).toMap();
					mUsersDataModel->insert(new ODSUser(map));
				}
			}
		}

		// some debug logs
		// map of sort values: 'displayName' and 'displaytype'
		QList<QVariantMap> mylist = mUsersDataModel->toListOfMaps();
		for (int i = 0; i < mylist.size(); ++i) {
			QMap<QString, QVariant> myMap = mylist[i];
			QMapIterator<QString, QVariant> j(myMap);
			while (j.hasNext()) {
				j.next();
				qDebug() << "myIndex: " << i << " Key: " << j.key()
						<< " Value: " << j.value();
			}
		}
		// the ODSUser data check the users: get ODSUser out
		// find an object exactly, take a look at the indexPathes
		// and again find now using the index path and update item
		QList<QObject*> myuli = mUsersDataModel->toListOfObjects();
		for (int i = 0; i < myuli.size(); ++i) {
			if (qobject_cast<ODSUser*>(myuli.at(i))) {
				ODSUser *u = (ODSUser*) myuli.at(i);
				qDebug() << "found user: " << u->userName() << u->displayType();
				QVariantList indexPath = mUsersDataModel->find(u);
				for (int ip = 0; ip < indexPath.size(); ++ip) {
					qDebug() << "path level:" << indexPath.at(ip).toInt();
				}
				// try to modify the name
				// u->setLastName(u->lastName()+" *");
				// mUsersDataModel->updateItem(indexPath, u);
			} else {
				qDebug() << "cast says: no ODSUser :(";
			}

		}
	} else {
		qDebug() << "NOT found GroupDataModel :(";
		// TODO Dialog Error
	}

}

// TODO syncUsermodelWithServer

void ODSData::initRoomsModel() {
	createRoomsModel();
	resetLevel();
}

void ODSData::createRoomsModel() {
	mUser = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_USER, "");
	mPassword = mOdsSettings->getValueFor(SETTINGS_KEY_SERVER_CURRENT_PASSWORD,
			"");
	// TODO use findChild() - the bug where not all components were destroyed seems to be fixed
	mRoomsDataModel = Application::instance()->scene()->findChildren<
			GroupDataModel*>("roomGroupDataModel").last();
	if (mRoomsDataModel) {
		mRoomsDataModel->clear();
		QVariantMap dataMap;
		mRooms->clear();
		// all rooms
		dataMap = readDataFromJson(Usecase::FilesAll);
		if (!dataMap.isEmpty()) {
			// first level are always Rooms
			// next levels will be get thru showNext / showPrevious Level
			// from UI tapping on Room, SubRoom, Folder
			mRooms->append(dataMap.value(nodesValue, "").toList());
			if (!mRooms->isEmpty()) {
				for (int i = 0; i < mRooms->size(); ++i) {
					QVariantMap map = mRooms->at(i).toMap();
					mRoomsDataModel->insert(new ODSRoom(map));
				}
			}
			// group informations stored to get the name of thew rooms easy
			// later on subrooms and folders will reference to the group they belong to
			mRoomGroups->clear();
			QVariantList dataList;
			dataList = dataMap.value(groupsValue, "").toList();
			if (!dataList.isEmpty()) {
				for (int i = 0; i < dataList.size(); ++i) {
					QVariantMap map = dataList.at(i).toMap();
					mRoomGroups->insert(map.value(groupPkValue, 0).toInt(),
							map.value(nameValue, "").toString());
				}
			}
			qDebug() << "got asome roomGroups:" << mRoomGroups->size();
		}

	}
}

/**
 * looks for DropDowns named roomsDropDown
 * clears and inserts the names of Rooms
 */
void ODSData::createRoomsDropDown() {
	DropDown* roomsDropDown = Application::instance()->scene()->findChildren<
			DropDown*>("roomsDropDown").last();
	// dropDown->add(Option::create().text("Option 1"));
	if (roomsDropDown) {
		qDebug() << "roomsDropDown F O U N D";
		roomsDropDown->removeAll();
		int loop = 0;
		QList<int> keylist = mRoomGroups->keys();
		for (loop = 0; loop < keylist.size(); ++loop) {
			roomsDropDown->add(
					Option::create().text(mRoomGroups->value(keylist.at(loop))).value(
							keylist.at(loop)));
		}
	} else {
		qDebug() << "roomsDropDown: no children found";
	}

}

void ODSData::showFilesFromNode(QVariantList nodes, bool isBackNavigation) {
	mFilesDataModel = Application::instance()->scene()->findChildren<
			GroupDataModel*>("fileGroupDataModel").last();
	if (mFilesDataModel) {
		mFilesDataModel->clear();
		// all files, folders, subrooms of these nodes
		if (isBackNavigation) {
			if (mFolderLevel >= 0) {
				mFolderLevel--;
			}
		}
		qDebug() << "FolderPath for this node: "
				<< folderPath(isBackNavigation);
		bool hasFolder = false;
		if (!nodes.isEmpty()) {
			for (int i = 0; i < nodes.size(); ++i) {
				QVariantMap map = nodes.at(i).toMap();
				if (map.value(isGroupValue, 42).toInt() == 1) {
					mFilesDataModel->insert(new ODSSubRoom(map));
					continue;
				}
				if (map.value(isGroupValue, 42).toInt() == 0) {
					hasFolder = true;
					mFilesDataModel->insert(
							new ODSFolder(map, folderPath(isBackNavigation)));
					continue;
				}
				if (map.value(typeValue, 42).toInt() == 2) {
					mFilesDataModel->insert(
							new ODSFile(map, folderPath(isBackNavigation)));
					continue;
				}
				qDebug() << "unknown ItemType from nodes list";
			}
		} else {
			qDebug() << "empty nodes list ?";
		}
		if (!isBackNavigation) {
			if (hasFolder || mFolderLevel >= 0) {
				mFolderLevel++;
			}
		}
		qDebug() << "Node processed, now Folder Level: " << mFolderLevel
				<< " Files Level: " << mFilesLevel;
	}
}

/**
 * returns true if level can be increased
 * if already at root level - return false
 */
bool ODSData::showPreviousNode() {
	if (mFilesLevel > 0) {
		mCache->removeAt(mFilesLevel);
		mNodeNames->removeAt(mFilesLevel);
		mFilesLevel--;
		showFilesFromNode(mCache->at(mFilesLevel).toList(), true);
		qDebug() << "showPreviousNode caches: " << mFilesLevel;
		return true;
	}
	qDebug() << "showPreviousNode caches: " << mFilesLevel;
	return false;
}

void ODSData::showNextNode(QVariantList nodes, QString name) {
	mFilesLevel++;
	mCache->insert(mFilesLevel, nodes);
	mNodeNames->insert(mFilesLevel, name);
	showFilesFromNode(nodes, false);
	qDebug() << "showNextNode caches: " << mFilesLevel;
}

QObject* ODSData::fileFromId(int fileId) {
	QVariantList nodes = mCache->at(mFilesLevel).toList();
	if (!nodes.isEmpty()) {
		for (int i = 0; i < nodes.size(); ++i) {
			QVariantMap map = nodes.at(i).toMap();
			if (map.value(typeValue, 42).toInt() == 2
					&& map.value(fileIdValue, 0).toInt() == fileId) {
				return new ODSFile(map, folderPath(true));
			}
		}
	} else {
		qDebug() << "file id not found: " << fileId;
		// TODO DIalog Warning
	}
	return new ODSFile();
}

QObject* ODSData::folderFromName(QString folderName) {
	QVariantList nodes = mCache->at(mFilesLevel).toList();
	if (!nodes.isEmpty()) {
		for (int i = 0; i < nodes.size(); ++i) {
			QVariantMap map = nodes.at(i).toMap();
			if (map.value(nameValue, "").toString() == folderName) {
				return new ODSFolder(map, folderPath(true));
			}
		}
	} else {
		qDebug() << "folder id not found: " << folderName;
		// TODO DIalog Warning
	}
	return new ODSFolder();
}

QObject* ODSData::subroomFromId(int subroomId) {
	QVariantList nodes = mCache->at(mFilesLevel).toList();
	if (!nodes.isEmpty()) {
		for (int i = 0; i < nodes.size(); ++i) {
			QVariantMap map = nodes.at(i).toMap();
			if (map.value(typeValue, 42).toInt() == 1
					&& map.value(parentValue, 0).toInt() > 0
					&& map.value(groupPkValue, 0).toInt() == subroomId) {
				return new ODSSubRoom(map);
			}
		}
	} else {
		qDebug() << "subroom id not found: " << subroomId;
		// TODO DIalog Warning
	}
	return new ODSSubRoom();
}

QObject* ODSData::roomFromId(int roomId) {
	qDebug() << "Room from ID: " << roomId;
	if (!mRooms->isEmpty()) {
		qDebug() << "Rooms List with # Rooms: " << mRooms->size();
		for (int i = 0; i < mRooms->size(); ++i) {
			QVariantMap map = mRooms->at(i).toMap();
			if (map.value(typeValue, 42).toInt() == 1
					&& map.value(parentValue, 0).toInt() == 0
					&& map.value(groupPkValue, 0).toInt() == roomId) {
				return new ODSRoom(map);
			}
		}
	} else {
		qDebug() << "room id not found: " << roomId;
		// TODO DIalog Warning
	}
	return new ODSRoom();
}

QObject* ODSData::parentData() {
	qDebug() << "cache: " << mCache->size() << "level: " << mFilesLevel;
	if (mFilesLevel == 0) {
		// root level - we're inside a data room
		if (!mRooms->isEmpty() && !mNodeNames->isEmpty()) {
			for (int i = 0; i < mRooms->size(); ++i) {
				QVariantMap map = mRooms->at(i).toMap();
				if (map.value(nameValue, "").toString() == mNodeNames->at(0)) {
					return new ODSRoom(map);
				}
			}
			qDebug() << "rooms not found for: " << mNodeNames->at(0);
		} else {
			qDebug() << "rooms or nodenames empty";
		}
		return new ODSRoom();
	} else {
		// deeper level: parent can be Room, SubRoom, Folder
		if (!mCache->isEmpty() && !mNodeNames->isEmpty()
				&& mNodeNames->size() > mFilesLevel
				&& mCache->size() >= mFilesLevel) {
			QVariantList dataList = mCache->at(mFilesLevel - 1).toList();
			for (int i = 0; i < dataList.size(); ++i) {
				QVariantMap map = dataList.at(i).toMap();
				qDebug() << "getting name: "
						<< map.value(nameValue, "").toString();
				if (map.value(nameValue, "").toString()
						== mNodeNames->at(mFilesLevel)) {
					if (map.value(isGroupValue, 42).toInt() == 1) {
						return new ODSSubRoom(map);
					}
					if (map.value(isGroupValue, 42).toInt() == 0) {
						return new ODSFolder(map, folderPath(false));
					}
				}
			}
			qDebug() << "subroom or folder not found for: "
					<< mNodeNames->at(mFilesLevel);
		} else {
			qDebug() << "cache or nodenames empty";
		}
	}
	return new QObject();
}

void ODSData::resetLevel() {
	mFilesLevel = -1;
	mFolderLevel = -1;
	mCache->clear();
	mNodeNames->clear();
	qDebug() << "resetLevel done";
}

QString ODSData::nodeTitleName() {
	qDebug() << mNodeNames->at(mFilesLevel) << " at Level: " << mFilesLevel;
	return mNodeNames->at(mFilesLevel);
}

QString ODSData::nodePath() {
	qDebug() << mNodeNames->join("/");
	return mNodeNames->join("/");
}

QString ODSData::roomGroupName(int groupId) {
	qDebug() << "group name for id: " << groupId << mRoomGroups->value(groupId);
	return mRoomGroups->value(groupId);
}

QString ODSData::folderPath(bool isBackNavigation) {
	QString path;
	int start = mFilesLevel - mFolderLevel;
	if (isBackNavigation) {
		start++;
	}

	if (mFolderLevel >= 0) {
		for (int floop = start; floop < mNodeNames->size(); ++floop) {
			// if its at first level test for subroom and ignore
			if (!mRoomGroups->values().contains(mNodeNames->at(floop))) {
				// add '/' if its not the leading value
				if (!path.isEmpty()) {
					path += "/";
				}
				// concatenate the path
				path += mNodeNames->at(floop);
			}

		}
	}
	qDebug() << "Folder Path: " << path;
	return path;
}

QVariantMap ODSData::readDataFromJson(int usecase) {
	// all data is in JSON format
	JsonDataAccess jda;
	QVariantMap rootObject;
	// we process data from body part
	QVariantMap bodyMap;
	QString filename;
	// read from users/user file
	filename = "ods/json";
	filename += mUsecasePathes.at(usecase);
	filename += ".json";
	QFile file(dataPath(filename));
	bool ok = file.open(QIODevice::ReadOnly);
	if (ok) {
		rootObject = jda.loadFromBuffer(file.readAll()).toMap();
		file.close();
	} else {
		qDebug() << "cannot open file to write: " << filename;
		// TODO SystemDialog
	}
	// get my own users data
	if (rootObject.contains("body")) {
		bodyMap = rootObject.value("body").toMap();
	}
	return bodyMap;
}

void ODSData::syncWithServer() {
	mDialog->setTitle(tr("Sync with Server"));
	mDialog->setBody(tr("Synchronizing can take some time.\nStart Sync now ?"));
	mDialog->cancelButton()->setLabel(tr("No"));
	mDialog->defaultButton()->setLabel(tr("Synchronize"));
	int result = mDialog->exec();
	switch (result) {
	case SystemUiResult::CancelButtonSelection:
		return;
	default:
		break;
	}
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Sync with Server"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("get new file structure from server..."));
	mProgressDialog->show();
	initiateRequest(Usecase::FilesAll);
}

/**
 * refresh caches
 * called from successfully executed commands
 * followed by a reload of all files to get the new structure from server
 */
void ODSData::refreshCaches() {
	mProgressDialog->setProgress(70);
	mProgressDialog->setBody(tr("got new structure, now refresh cache..."));
	mProgressDialog->setStatusMessage(tr("refresh Data Rooms"));
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->show();
	// recreate rooms
	createRoomsModel();
	mProgressDialog->setProgress(75);
	mProgressDialog->setStatusMessage(tr("refresh Nodes"));
	mProgressDialog->show();
	// recreate nodes
	QVariantList nodes;
	// root level (get selected Data Room)
	if (mNodeNames->size() > 0) {
		for (int r = 0; r < mRooms->size(); ++r) {
			QVariantMap dataMap = mRooms->at(r).toMap();
			if (dataMap.value(nameValue, "") == mNodeNames->at(0)) {
				// we found the Data Room
				qDebug() << "refresh caches found the Data Room"
						<< mNodeNames->at(0);
				nodes = dataMap.value(nodesValue).toList();
				mCache->replace(0, nodes);
				break;
			}
		}
		// deeper levels (SubRooms, Folders)
		if (!nodes.isEmpty()) {
			for (int loop = 1; loop < mNodeNames->size(); ++loop) {
				for (int n = 0; n < nodes.size(); ++n) {
					QVariantMap dataMap = nodes.at(n).toMap();
					if (dataMap.value(nameValue, "") == mNodeNames->at(loop)) {
						// we found the Node
						qDebug() << "refresh caches found the Node:"
								<< mNodeNames->at(loop);
						nodes = dataMap.value(nodesValue).toList();
						mCache->replace(loop, nodes);
						break;
					}
				}
			}
		}
		// show actual node in ListView
		mFilesDataModel->clear();
		if (!nodes.isEmpty()) {
			for (int i = 0; i < nodes.size(); ++i) {
				QVariantMap map = nodes.at(i).toMap();
				if (map.value(isGroupValue, 42).toInt() == 1) {
					mFilesDataModel->insert(new ODSSubRoom(map));
					continue;
				}
				if (map.value(isGroupValue, 42).toInt() == 0) {
					mFilesDataModel->insert(
							new ODSFolder(map, folderPath(false)));
					continue;
				}
				if (map.value(typeValue, 42).toInt() == 2) {
					mFilesDataModel->insert(
							new ODSFile(map, folderPath(false)));
					continue;
				}
				qDebug() << "unknown ItemType from nodes list";
			}
		}
	}
	// finished
	mProgressDialog->setProgress(100);
	mProgressDialog->setState(SystemUiProgressState::Inactive);
	mProgressDialog->cancel();
	// display toast instead
	mToast->setPosition(SystemUiPosition::BottomCenter);
	mToast->setBody(tr("Cache refreshed :)"));
	mToast->setIcon(QUrl("asset:///images/online-icon.png"));
	mToast->show();
}

void ODSData::createLink(int fileId, QString fileName, bool expires,
		QDate expiration, QString password, QString code, bool notice,
		bool shareViaMail) {
	qDebug() << "CREATE LINK for file: " << fileId << "and code: " << code;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Create a new link"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mFileId = fileId;
	mFileName = fileName;
	if (expires) {
		mExpiration = expiration.toString(Qt::ISODate);
	} else {
		mExpiration = "";
	}
	mLinkPassword = password.trimmed();
	mComment = code.trimmed();
	if (notice) {
		mNotice = "on";
	} else {
		mNotice = "";
	}
	mShareViaMail = shareViaMail;
	initiateRequest(Usecase::FilesCreateLink);
	// if request went well: reloadFiles is called
}

void ODSData::shareLink() {
	qDebug() << "shareLink found";
	// finished // TODO
	mProgressDialog->setProgress(95);
	mProgressDialog->setState(SystemUiProgressState::Inactive);
	mProgressDialog->setBody(tr("got Link to share with BBM)"));
	mProgressDialog->setIcon(QUrl("asset:///images/online-icon.png"));
	mProgressDialog->confirmButton()->setLabel(tr("OK"));
	mProgressDialog->cancelButton()->setLabel(QString::null);
	// wait for USER
	mProgressDialog->show();
	QString message;
	QVariantMap bodyMap;
	message = tr(
			"Please download this file from secure OpenDataSpace Server: ");
	bodyMap = readDataFromJson(Usecase::FilesCreateLink);
	if (!bodyMap.isEmpty()) {
		message += bodyMap.value(linkValue, "").toString();
		message += bodyMap.value(linkCodeValue, "").toString();
		mProgressDialog->cancel();
		emit shareLinkWithBBM(message);
	} else {
		message = tr("sorry - we got no Link to share");
		reportError(message);
	}
}

void ODSData::mailLink() {
	qDebug() << "mailLink found";
	// finished // TODO
	mProgressDialog->setProgress(95);
	mProgressDialog->setState(SystemUiProgressState::Inactive);
	mProgressDialog->setBody(tr("got Link to share with Mail)"));
	mProgressDialog->setIcon(QUrl("asset:///images/online-icon.png"));
	mProgressDialog->confirmButton()->setLabel(tr("OK"));
	mProgressDialog->cancelButton()->setLabel(QString::null);
	// wait for USER
	mProgressDialog->show();
	QString message;
	QVariantMap bodyMap;
	message = tr(
			"Please download this file from secure OpenDataSpace Server: ");
	bodyMap = readDataFromJson(Usecase::FilesCreateLink);
	if (!bodyMap.isEmpty()) {
		message += bodyMap.value(linkValue, "").toString();
		message += bodyMap.value(linkCodeValue, "").toString();
		mProgressDialog->cancel();
		emit shareLinkWithMail(message);
	} else {
		message = tr("sorry - we got no Link to share");
		reportError(message);
	}
}

/**
 * create a new Folder inside a Room or SubRoom:
 * path == name of the folder
 *
 * create inside another Folder:
 * path == anotherFolder/newNameOfFolder
 */
void ODSData::createFolder(int roomId, QString path) {
	qDebug() << "CREATE FOLDER for groupPk: " << roomId << "and folderpath: "
			<< path;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Create a new folder"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mGroupPk = roomId;
	mPath = path.trimmed();
	initiateRequest(Usecase::FilesCreateFolder);
	// if request went well: reloadFiles is called
}

/**
 * simple interface to be filled from QML with data
 * sending Array of strings or int or bool from QML
 * 	0	 emailWithMarker.textFieldText,
 *  1    salutation.selectedIndex,
 *  2    userTitle.text,
 *  3    firstNameWithMarker.textFieldText,
 *  4    lastNameWithMarker.textFieldText,
 *  5    isAdmin.checked,
 *  6    dataRoom.selectecOption.value
 */
void ODSData::addUser(QVariantList userData) {
	qDebug() << "ADD User: " << userData.size() << " 1:"
			<< userData.at(0).toString() << " 3:" << userData.at(3).toString()
			<< " 5:" << userData.at(5).toBool();
	// TODO send to server
}

/**
 * deletes a Folder
 * UI shows content of folders
 * so user is responsible that folder with content can be deleted
 */
void ODSData::deleteFolder(int roomId, QString path) {
	mDialog->setTitle(tr("Delete Folder"));
	mDialog->setBody(path);
	mDialog->cancelButton()->setLabel(tr("No"));
	mDialog->defaultButton()->setLabel(tr("Yes: Delete"));
	switch (mDialog->exec()) {
	case SystemUiResult::CancelButtonSelection:
		return;
	default:
		break;
	}
	qDebug() << "DELETE FOLDER for groupPk: " << roomId << "and folderpath: "
			<< path;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Delete a folder"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mGroupPk = roomId;
	mPath = path.trimmed();
	initiateRequest(Usecase::FilesDeleteFolder);
	// if request went well: reloadFiles is called
}

void ODSData::deleteFile(int fileId, QString fileName) {
	mDialog->setTitle(tr("Delete File"));
	mDialog->setBody(fileName);
	mDialog->cancelButton()->setLabel(tr("No"));
	mDialog->defaultButton()->setLabel(tr("Yes: Delete"));
	int result = mDialog->exec();
	switch (result) {
	case SystemUiResult::CancelButtonSelection:
		return;
	default:
		break;
	}
	qDebug() << "DELETE File: " << fileId;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Delete a file"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mFileId = fileId;
	initiateRequest(Usecase::FilesDelete);
	// if request went well: reloadFiles is called
}

void ODSData::downloadFile(int fileId, QString fileName, qint64 fileSizeBytes) {
	qDebug() << "start download File #" << fileId << " " << fileName;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Download a file"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mFileId = fileId;
	mFileName = fileName;
	// TODO    S I Z E
	mRequestedFileSize = fileSizeBytes;
	initiateRequest(Usecase::FilesDownload);
}

void ODSData::renameFile(int fileId, QString fileNameOld) {
	// mPrompt = new SystemPrompt(this);
	mPrompt->setTitle(tr("Rename File"));
	mPrompt->setBody(tr("Old File: ") + fileNameOld);
	mPrompt->cancelButton()->setLabel(tr("No"));
	mPrompt->defaultButton()->setLabel(tr("Rename"));
	mPrompt->inputField()->setEmptyText(tr("the new Filename"));
	int result = mPrompt->exec();
	switch (result) {
	case SystemUiResult::CancelButtonSelection:
		return;
	default:
		break;
	}
	if (mPrompt->inputFieldTextEntry().isEmpty()) {
		qDebug() << "now new name - so no rename";
		return;
	} else {
		mFileName = mPrompt->inputFieldTextEntry().trimmed();
	}
	qDebug() << "RENAME File: " << fileId << " to " << mFileName;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Rename a file"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mFileId = fileId;
	initiateRequest(Usecase::FilesRename);
	// if request went well: reloadFiles is called
}

void ODSData::renameFolder(int roomId, QString pathOld, QString folderNameOld) {
	mPath = pathOld;
	mFileName = folderNameOld;
	// mPrompt = new SystemPrompt(this);
	mPrompt->setTitle(tr("Rename Folder"));
	if (pathOld.isEmpty()) {
		mPrompt->setBody(tr("Old Folder: ") + folderNameOld);
	} else {
		mPrompt->setBody(tr("Old Folder: ") + pathOld + "/" + folderNameOld);
	}
	mPrompt->cancelButton()->setLabel(tr("No"));
	mPrompt->defaultButton()->setLabel(tr("Rename"));
	mPrompt->inputField()->setEmptyText(tr("the new Foldername"));
	int result = mPrompt->exec();
	switch (result) {
	case SystemUiResult::CancelButtonSelection:
		return;
	default:
		break;
	}
	if (mPrompt->inputFieldTextEntry().isEmpty()) {
		qDebug() << "now new name - so no rename";
		return;
	} else {
		if (mPath.isEmpty()) {
			mPathNew = mPrompt->inputFieldTextEntry().trimmed();
			mPath = mFileName;
		} else {
			mPathNew = mPath + "/" + mPrompt->inputFieldTextEntry().trimmed();
			mPath = mPath + "/" + mFileName;
		}
	}
	qDebug() << "RENAME Folder: " << mPath << " to " << mPathNew;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Rename a folder"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mGroupPk = roomId;
	initiateRequest(Usecase::FilesRenameFolder);
	// if request went well: reloadFiles is called
}

/**
 * get the path of a thumbnail created by the server
 */
QString ODSData::thumbnail(int fileId) {
	// TODO: only if isImage
	// TODO if response == error: dont store json in thumbnail folder
	QString name = thumbnailPath(QString::number(fileId) + "_thumb.png");
	if (QFile::exists(name)) {
		qDebug() << "thumbnail exists: " << name;
		return name;
	} else {
		mFileId = fileId;
		initiateRequest(Usecase::FilesDownloadThumbnail);
		// TODO no progress and if downloaded signal to top page of NavigationPane if fileId still the same
	}
	return "";
}

/**
 * true if the file was downloaded
 */
bool ODSData::fileDownloaded(int fileId, QString fileName) {
	// TODO map fileid to downloaded file
	// TODO add check of timestamp - if file downloaded was older then from cloud
	return QFile::exists(downloadPath(fileName));
}

void ODSData::simpleUpload(QString sourceFileName) {
	QObject* container = parentData();
	if (qobject_cast<ODSRoom*>(container)) {
		ODSRoom* room = (ODSRoom*) container;
		qDebug() << "upload into Room";
		uploadFile(room->id(), sourceFileName, "", "BB10");
	} else {
		if (qobject_cast<ODSSubRoom*>(container)) {
			ODSSubRoom* subroom = (ODSSubRoom*) container;
			qDebug() << "upload into SubRoom";
			uploadFile(subroom->id(), sourceFileName, "", "BB10");
		} else {
			if (qobject_cast<ODSFolder*>(container)) {
				ODSFolder* folder = (ODSFolder*) container;
				qDebug() << "upload into Folder name " << folder->name()
						<< " path: " << folder->path();
				QString uploadPath = folder->path();
//				if (!uploadPath.isEmpty()) {
//					uploadPath += "/";
//				}
//				uploadPath += folder->name();
				// TODO check parent code for path - name is included yet
				uploadFile(folder->containerId(), sourceFileName, uploadPath,
						"BB10");
			}
		}
	}
	// TODO error dialog
}

void ODSData::uploadFile(int roomId, QString sourceFileName, QString path,
		QString comment) {
	qDebug() << "start upload File: " << sourceFileName << " path: " << path
			<< "into Room: " << roomId;
	// start progress
	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Upload a file"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/upload-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Please Wait"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(-1); // 15
	mProgressDialog->setBody(tr("send file to server..."));
	mProgressDialog->show();
	//
	mGroupPk = roomId;
	mSourceFileName = sourceFileName;
	FileInfo* fi = new FileInfo();
	mFileName = fi->getShortName(sourceFileName);
	mPath = path;
	mComment = comment;
	initiateRequest(Usecase::FilesUpload);
}

void ODSData::initiateRequest(int usecase) {
	bool isJsonContent;
	bool isInitialization;
	bool ok;
	QString errorString;

	QNetworkRequest request = QNetworkRequest();
	QByteArray postDataSize;
	//
	QHttpPart fileLengthPart;
	QHttpPart groupPkPart;
	QHttpPart parentPathPart;
	QHttpPart commentPart;
	QHttpPart logUcPart;
	QHttpPart expirationDatePart;
	QHttpPart tokenPart;
	QHttpPart overWritePart;
	QHttpPart fileAttachementPart;
	//QString formdata;
	// test if initialization
	switch (usecase) {
	case -1:
		isInitialization = true;
		usecase = Usecase::UsersAuth;
		break;
	case -2:
		isInitialization = true;
		usecase = Usecase::UsersUser;
		break;
	case -3:
		isInitialization = true;
		usecase = Usecase::SettingsUser;
		break;
	case -4:
		isInitialization = true;
		usecase = Usecase::FilesAll;
		break;
	case -5:
		isInitialization = true;
		usecase = Usecase::UsersAll;
		break;
	default:
		isInitialization = false;
		break;
	}
	switch (usecase) {
	// only for tests
	case Usecase::UsersTestGet:
		isJsonContent = true;
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersTestGet)));
		// GET Request
		mNetworkAccessManager->get(request);
		return;
		// only for tests
	case Usecase::UsersTestPost:
		isJsonContent = true;
		mRequestJson.clear();
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersTestPost)));
		break;
		// always at first
	case Usecase::UsersAuth:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// USERNAME
		mRequestJson.append(quotationMark);
		mRequestJson.append(usernameValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mUser.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// PASSWORD
		mRequestJson.append(quotationMark);
		mRequestJson.append(passwordValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mPassword.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersAuth)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase",
					QByteArray::number(Usecase::UsersUser));
		}
		break;
		// do UsersAuth, then get Users data to know what is allowed, get customer_no etc
	case Usecase::UsersUser:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersUser)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase",
					QByteArray::number(Usecase::SettingsUser));
		}
		break;
	case Usecase::UsersAll:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersAll)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(-9999));
		}
		break;
	case Usecase::FilesCreateFolder:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// GROUP_PK
		mRequestJson.append(quotationMark);
		mRequestJson.append(groupPkValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mGroupPk));
		mRequestJson.append(comma);
		// PATH
		mRequestJson.append(quotationMark);
		mRequestJson.append(pathValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mPath.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesCreateFolder)));
		if (!isInitialization) {
			// add a special header to reload all files as next step
			request.setRawHeader("reload",
					QByteArray::number(Usecase::FilesAll));
		}
		break;
	case Usecase::FilesCreateLink:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// FILE ID
		mRequestJson.append(quotationMark);
		mRequestJson.append(fileIdValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mFileId));
		mRequestJson.append(comma);
		// EXPIRATION
		mRequestJson.append(quotationMark);
		mRequestJson.append(linkExpirationValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mExpiration.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// EXPIRATION
		mRequestJson.append(quotationMark);
		mRequestJson.append(linkPasswordValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mLinkPassword.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// CODE
		mRequestJson.append(quotationMark);
		mRequestJson.append(linkCodeValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mComment.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// LANGUAGE
		mRequestJson.append(quotationMark);
		mRequestJson.append(linkLanguageValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mLanguageNumber));
		mRequestJson.append(comma);
		// NOTICE DOWNLOAD
		mRequestJson.append(quotationMark);
		mRequestJson.append(noticeDownloadValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mNotice.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesCreateLink)));
		if (!isInitialization) {
			// add a special header to reload all files as next step
			request.setRawHeader("shareLink", "true");
			if (mShareViaMail) {
				request.setRawHeader("shareViaMail", "true");
			}
		}
		break;
	case Usecase::FilesDelete:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// FILE ID
		mRequestJson.append(quotationMark);
		mRequestJson.append(fileIdValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mFileId));
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesDelete)));
		// add a special header to reload all files as next step
		request.setRawHeader("reload", QByteArray::number(Usecase::FilesAll));
		break;
	case Usecase::FilesDeleteFolder:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// GROUP_PK
		mRequestJson.append(quotationMark);
		mRequestJson.append(groupPkValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mGroupPk));
		mRequestJson.append(comma);
		// PATH
		mRequestJson.append(quotationMark);
		mRequestJson.append(pathValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mPath.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// CONTENT
		mRequestJson.append(quotationMark);
		mRequestJson.append(contentValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(deleteNotEmpty));
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesDeleteFolder)));
		if (!isInitialization) {
			// add a special header to reload all files as next step
			request.setRawHeader("reload",
					QByteArray::number(Usecase::FilesAll));
		}
		break;
	case Usecase::FilesAll:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// CUSTOMER NR
		mRequestJson.append(quotationMark);
		mRequestJson.append(customerNumberValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mCustomerNumber));
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesAll)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase",
					QByteArray::number(Usecase::UsersAll));
			qDebug() << "last step of initialization: filesAll";
		}
		break;
	case Usecase::FilesDownload:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// FILE ID
		mRequestJson.append(quotationMark);
		mRequestJson.append(fileIdValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mFileId));
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesDownload)));
		// TODO reload
		break;
	case Usecase::FilesDownloadThumbnail:
		isJsonContent = true;
		mFileName = QString::number(mFileId) + "_thumb.png";
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// FILE ID
		mRequestJson.append(quotationMark);
		mRequestJson.append(fileIdValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mFileId));
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(
						mBaseUrl
								+ mUsecasePathes.at(
										Usecase::FilesDownloadThumbnail)));
		break;
	case Usecase::FilesRename:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// FILE ID
		mRequestJson.append(quotationMark);
		mRequestJson.append(fileIdValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mFileId));
		mRequestJson.append(comma);
		// NAME
		mRequestJson.append(quotationMark);
		mRequestJson.append(nameValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mFileName.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesRename)));
		// add a special header to reload all files as next step
		request.setRawHeader("reload", QByteArray::number(Usecase::FilesAll));
		break;
	case Usecase::FilesRenameFolder:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// GROUP_PK
		mRequestJson.append(quotationMark);
		mRequestJson.append(groupPkValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(QByteArray::number(mGroupPk));
		mRequestJson.append(comma);
		// PATH OLD
		mRequestJson.append(quotationMark);
		mRequestJson.append(pathOldValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mPath.toUtf8());
		mRequestJson.append(quotationMark);
		mRequestJson.append(comma);
		// CONTENT
		mRequestJson.append(quotationMark);
		mRequestJson.append(pathNewValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mPathNew.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesRenameFolder)));
		if (!isInitialization) {
			// add a special header to reload all files as next step
			request.setRawHeader("reload",
					QByteArray::number(Usecase::FilesAll));
		}
		break;
	case Usecase::FilesUpload:
		isJsonContent = false;
		mFileToUpload = new QFile(mSourceFileName);
		ok = mFileToUpload->open(QIODevice::ReadOnly);
		if (!ok) {
			qDebug() << "cannot open file to upload: " << mSourceFileName;
			errorString = tr("Cannot read file to upload: ");
			errorString += mSourceFileName;
			reportError(errorString);
			// S T O P   I T
			return;
		}
		mFileLength = mFileToUpload->size();
		qDebug() << "create multipart to upload file " << mSourceFileName
				<< " as " << mFileName << " size: " << mFileLength << "\npath: "
				<< mPath;
		mRequestMultipart = new QHttpMultiPart(QHttpMultiPart::FormDataType,
				this);
		fileLengthPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"file_length\""));
		fileLengthPart.setBody(QString::number(mFileLength).toUtf8());
		mRequestMultipart->append(fileLengthPart);
		groupPkPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"group_pk\""));
		groupPkPart.setBody(QString::number(mGroupPk).toUtf8());
		mRequestMultipart->append(groupPkPart);
		parentPathPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"parent_path\""));
		parentPathPart.setBody(mPath.toUtf8());
		mRequestMultipart->append(parentPathPart);
		commentPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"comment\""));
		commentPart.setBody(mComment.toUtf8());
		mRequestMultipart->append(commentPart);
		logUcPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"log_uc\""));
		logUcPart.setBody(mUser.toUtf8());
		mRequestMultipart->append(logUcPart);
		expirationDatePart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"expiration_date\""));
		expirationDatePart.setBody("");
		mRequestMultipart->append(expirationDatePart);
		tokenPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"token\""));
		tokenPart.setBody(mToken.toUtf8());
		mRequestMultipart->append(tokenPart);
		overWritePart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant("form-data; name=\"overwrite\""));
		overWritePart.setBody(QString::number(0).toUtf8());
		mRequestMultipart->append(overWritePart);

		fileAttachementPart.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/octet-stream");
		fileAttachementPart.setHeader(QNetworkRequest::ContentDispositionHeader,
				QVariant(
						"form-data; name=\"file_attachment\"; filename=\""
								+ mFileName + "\""));
		fileAttachementPart.setBodyDevice(mFileToUpload);
		mRequestMultipart->append(fileAttachementPart);

		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesUpload)));
		// add a special header to reload all files as next step
		request.setRawHeader("reload", QByteArray::number(Usecase::FilesAll));
		break;
	case Usecase::TexteAll:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::TexteAll)));
		break;
	case Usecase::SettingsUser:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::SettingsUser)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase",
					QByteArray::number(Usecase::FilesAll));
		}
		break;
	case Usecase::SettingsInfoListe:
		isJsonContent = true;
		mRequestJson.clear();
		// START
		mRequestJson.append(jsonStart);
		// TOKEN
		mRequestJson.append(quotationMark);
		mRequestJson.append(tokenValue);
		mRequestJson.append(quotationMark);
		mRequestJson.append(colon);
		mRequestJson.append(quotationMark);
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append(quotationMark);
		// END
		mRequestJson.append(jsonEnd);
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::SettingsInfoListe)));
		break;
	default:
		errorString = tr("unknown Usecase: ");
		errorString += QString::number(usecase);
		reportError(errorString);
		// S T O P   I T
		return;
		break;
	}
	// POST Request
	if (isJsonContent) {
		qDebug() << "POST JSON";
		if (!mRequestJson.isEmpty()) {
			postDataSize = QByteArray::number(mRequestJson.size());
			request.setHeader(QNetworkRequest::ContentLengthHeader,
					postDataSize);
		} else {
			request.setHeader(QNetworkRequest::ContentLengthHeader, 0);
		}
		setRequestheader(request, usecase);
		QNetworkReply *reply = mNetworkAccessManager->post(request,
				mRequestJson);
		connect(reply, SIGNAL(downloadProgress(qint64, qint64)), this,
				SLOT(downloadProgress(qint64, qint64)));
	} else {
		qDebug() << "POST MultiPart (we are UPLOADING...)";
		setRequestheader(request, usecase);
		QNetworkReply *reply = mNetworkAccessManager->post(request,
				mRequestMultipart);
		connect(reply, SIGNAL(uploadProgress(qint64, qint64)), this,
				SLOT(uploadProgress(qint64, qint64)));
	}
	// don't stop the Activity Indicator ! Response will be async
	// response processed in SLOT requestFinished
}

// private SLOT
/**
 * bytesTotal can be -1 if size not known
 * ODS Cloud sends no size info, but we can get the info from from datamodel
 * ignore if both are 0 == no download  (one time emitted)
 * The download is finished when bytesReceived is equal to bytesTotal.
 * At that time, bytesTotal will not be -1
 */
void ODSData::downloadProgress(qint64 bytesReceived, qint64 bytesTotal) {
	if (bytesReceived == 0 && bytesTotal == 0) {
		// ignore
		return;
	}
	qint64 total = bytesTotal;
	if (bytesTotal == -1) {
		// size unknown
		// lets test if we know the size from request raw header
		QNetworkReply *reply = (QNetworkReply*) sender();
		if (reply) {
			total = reply->request().rawHeader("downloadBytes").toInt();
		}
	}
	// TODO - not working well yet test with newer OS again
	if (total <= 0) {
		// do nothing yet - no progress was visible
		// so better ignore
		return;
	}
	// only trying to show progress on downloading files with known size
	QString b = tr("downloading...");
	if (total <= 0) {
		// size unknown
		// ignored yet - see above TODO
		b += QString::number(bytesReceived);
		b += tr(" Bytes ");
		b += tr(" (Total Size unknown)");
		mProgressDialog->setProgress(-1);
	} else {
		// progress in %
		int progressValue = bytesReceived * 100 / total;
		b += QString::number(progressValue);
		b += tr("% of total:");
		b += QString::number(total);
		b += tr(" Bytes ");
		mProgressDialog->setProgress(progressValue);
	}
	mProgressDialog->setBody(b);
	mProgressDialog->show();
	// qDebug() << b;
}

// private SLOT
/**
 * bytesTotal can be -1 if size not known
 * no signal emitted if no upload
 * The upload is finished when bytesSent is equal to bytesTotal.
 * At that time, bytesTotal will not be -1
 */
void ODSData::uploadProgress(qint64 bytesSent, qint64 bytesTotal) {
	QString b = tr("uploading...");
	if (bytesTotal == -1) {
		// size unknown
		b += QString::number(bytesSent);
		b += tr(" Bytes ");
		b += tr(" (Total Size unknown)");
		mProgressDialog->setProgress(-1);
	} else {
		// progress in %
		int progressValue = bytesSent * 100 / bytesTotal;
		b += QString::number(progressValue);
		b += tr("% of total:");
		b += QString::number(bytesTotal);
		b += tr(" Bytes ");
		mProgressDialog->setProgress(progressValue);
	}
	mProgressDialog->setBody(b);
	mProgressDialog->show();
	qDebug() << b;
}

/*
 * Header accepts and requests JSON, Charset is UTF-8
 */
void ODSData::setRequestheader(QNetworkRequest &request, int usecase) {
	switch (usecase) {
	case Usecase::FilesUpload:
		request.setRawHeader("Accept", "application/json");
		//request.setHeader(QNetworkRequest::ContentTypeHeader,
		//		"multipart/form-data");
		break;
	case Usecase::FilesDownload:
		request.setRawHeader("Accept", "application/octet-stream");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/json");
		// responses are coming in async, so I need to know the filename
		// perhaps also store the destination path - in this case we have a default downloads folder
		request.setRawHeader("FileName2Download", mFileName.toUtf8());
		request.setRawHeader("downloadBytes",
				QByteArray::number(mRequestedFileSize));
		break;
	case Usecase::FilesDownloadThumbnail:
		request.setRawHeader("Accept", "application/octet-stream");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/json");
		// responses are coming in async, so I need to know the filename
		// perhaps also store the destination path - in this case we have a default downloads folder
		request.setRawHeader("Thumbnail2Download", mFileName.toUtf8());
		break;
	default:
		request.setRawHeader("Accept", "application/json");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/json");
		break;
	}
	request.setRawHeader("charset", "utf-8");
}

// S L O T
// async getting info that request was finished
void ODSData::requestFinished(QNetworkReply* reply) {
	// Check the network reply for errors
	QString errorString;
	if (reply->error() == QNetworkReply::NoError) {
		QString replyUrl(reply->url().toString(QUrl::None));
		qDebug() << "reply URL" << replyUrl;
		QByteArray replyBytes = reply->readAll();
		qDebug() << "reply Content"
				<< reply->header(QNetworkRequest::ContentTypeHeader).toString();
		bool isJsonContent;
		bool isStreamContent;
		if (reply->header(QNetworkRequest::ContentTypeHeader).toString()
				== "application/json") {
			isJsonContent = true;
			isStreamContent = false;
		} else if (reply->header(QNetworkRequest::ContentTypeHeader).toString()
				== "application/octet-stream") {
			isJsonContent = false;
			isStreamContent = true;
		} else {
			isJsonContent = false;
			isStreamContent = false;
		}
		QString replyPath;
		QString filename;
		filename = "ods";
		if (isJsonContent) {
			filename += "/json";
			qDebug() << "we got a JSON content";
			int r = replyUrl.length() - mBaseUrl.length();
			if (r > 0) {
				replyPath = replyUrl.right(r);
				filename += replyPath;
			}
			filename += ".json";
		}
		if (isStreamContent) {
			if (reply->request().hasRawHeader("Thumbnail2Download")) {
				qDebug() << "we got a STREAM content for FileName2Download: "
						<< reply->request().rawHeader("Thumbnail2Download");
				// using a thumbnails folder inside the app sandbox, so files are secure stored
				filename += "/thumbnails/";
				filename += reply->request().rawHeader("Thumbnail2Download");
			} else {
				qDebug() << "we got a STREAM content for FileName2Download: "
						<< reply->request().rawHeader("FileName2Download");
				// using a downloads folder inside the app sandbox, so files are secure stored
				filename += "/download/";
				filename += reply->request().rawHeader("FileName2Download");
			}
		}
		if (isJsonContent || isStreamContent) {
			qDebug() << "filename: " << filename;
			// write the JSON content to a file in app data directory
			// so we can use it for data models
			bool success = writeReplyToFile(replyBytes, filename);
			if (!success) {
				errorString = tr("Error: could not write to file: ");
				errorString += filename;
				reportError(errorString);
				// S T O P   I T
				return;
			}
		} else {
			qDebug() << "wrong content: "
					<< reply->header(QNetworkRequest::ContentTypeHeader).toString();
			errorString = tr("wrong content ");
			errorString +=
					reply->header(QNetworkRequest::ContentTypeHeader).toString();
			reportError(errorString);
			// S T O P   I T
			return;
		}
		if (isJsonContent) {
			// process the JSON usecases
			bool responseOk = false;
			for (int i = 0; i < mUsecasePathes.size(); ++i) {
				if (mUsecasePathes.at(i) == replyPath) {
					responseOk = processResponse(replyBytes, i);
					break;
				}
			}
			if (!responseOk) {
				qDebug() << "couldn't process response path: " << replyPath;
				// S T O P   I T
				return;
			}
		}
		// initialization - steps ?
		// test for specific header
		int usecase = reply->request().rawHeader("nextUsecase").toInt();
		switch (usecase) {
		// usersAuth done - go on with users user
		case Usecase::UsersUser:
			if (mProgressDialog->state() == SystemUiProgressState::Error) {
				// login sequence was interrupted nothing more to do
				break;
			}
			mProgressDialog->setProgress(30);
			mProgressDialog->setBody(
					tr("Authentication done, getting User..."));
			mProgressDialog->show();
			initiateRequest(-2);
			break;
			// auth and users user done, go on with users settings
		case Usecase::SettingsUser:
			if (mProgressDialog->state() == SystemUiProgressState::Error) {
				// login sequence was interrupted nothing more to do
				break;
			}
			mProgressDialog->setProgress(45);
			mProgressDialog->setBody(tr("User received, getting Settings..."));
			mProgressDialog->show();
			initiateRequest(-3);
			break;
			// auth, users user, settings user done, go on with all files
		case Usecase::FilesAll:
			if (mProgressDialog->state() == SystemUiProgressState::Error) {
				// login sequence was interrupted nothing more to do
				break;
			}
			mProgressDialog->setProgress(60);
			mProgressDialog->setBody(tr("Settings received, getting Files..."));
			mProgressDialog->show();
			initiateRequest(-4);
			break;
		case Usecase::UsersAll:
			if (mProgressDialog->state() == SystemUiProgressState::Error) {
				// login sequence was interrupted nothing more to do
				break;
			}
			mProgressDialog->setProgress(90);
			mProgressDialog->setBody(tr("Files received, getting Userlist..."));
			mProgressDialog->show();
			initiateRequest(-5);
			break;
		case -9999:
			if (mProgressDialog->state() == SystemUiProgressState::Error) {
				// login sequence was interrupted nothing more to do
				break;
			}
			mProgressDialog->setProgress(100);
			mProgressDialog->setState(SystemUiProgressState::Inactive);
			disconnect(mProgressDialog,
					SIGNAL(finished(bb::system::SystemUiResult::Type)), this,
					SLOT(loginInterrupted()));
			mProgressDialog->cancel();
			// display toast instead
			// mToast = new SystemToast(this);
			mToast->setPosition(SystemUiPosition::BottomCenter);
			mToast->setBody(tr("Synchronization with Server done :)"));
			mToast->setIcon(QUrl("asset:///images/online-icon.png"));
			mToast->show();
			// OK OK OK OK     I N I T   D O N E
			emit loginFinished(true);
			break;
		default:
			// now test if we have to do a reload
			int reloadUsecase = reply->request().rawHeader("reload").toInt();
			switch (reloadUsecase) {
			case Usecase::FilesAll:
				mProgressDialog->setProgress(60);
				mProgressDialog->setBody(
						tr("Work done, sync Filestructure..."));
				mProgressDialog->show();
				initiateRequest(Usecase::FilesAll);
				break;
			default:
				if (reply->request().rawHeaderList().contains("shareLink")) {
					if (reply->request().rawHeaderList().contains("shareViaMail")) {
						mailLink();
					} else {
						shareLink();
					}
					break;
				}
				if (reply->request().rawHeaderList().contains("no_refresh")) {
					qDebug() << "no refresh";
					// finished
					mProgressDialog->setProgress(100);
					mProgressDialog->setState(SystemUiProgressState::Inactive);
					mProgressDialog->cancel();
					// display toast instead
					// mToast = new SystemToast(this);
					mToast->setPosition(SystemUiPosition::BottomCenter);
					mToast->setBody(tr("Server request finished :)"));
					mToast->setIcon(QUrl("asset:///images/online-icon.png"));
					mToast->show();
					break;
				}
				// nothing else to do - then refresh cache
				refreshCaches();
				break;
			}

			break;
		}
	} else {
		// uuuups - there was a network error
		qDebug() << "Problem with the network:" << reply->errorString();
		errorString = reply->errorString();
		reportError(errorString);
	}
	reply->deleteLater();
}

bool ODSData::writeReplyToFile(QByteArray &replyBytes, QString &filename) {
	QFile file(dataPath(filename));
	bool ok = file.open(QIODevice::WriteOnly);
	if (ok) {
		file.write(replyBytes);
		file.flush();
		file.close();
	} else {
		qDebug() << "cannot open file to write: " << filename;
	}
	return ok;
}

bool ODSData::processResponse(QByteArray &replyBytes, int usecase) {

	JsonDataAccess jda;
	// we load a JSON with root is Object
	const QVariantMap rootObject(jda.loadFromBuffer(replyBytes).toMap());
	// exists root object body ?
	QVariantMap bodyMap;
	QString errorString;
	if (rootObject.contains("body")) {
		bodyMap = rootObject.value("body").toMap();
		// QStringList keyList;
		// keyList = bodyMap.keys();
		// TODO mResultBody->setText(keyList.join(", "));
		// more
	} else {
		// TODO mResultBody->setText("no body object in JSON");
		qDebug() << "no body";
		errorString = tr("Response without Body-part");
		reportError(errorString);
		// S T O P
		return false;
	}
	if (rootObject.contains("error")) {
		errorString = rootObject.value("error", "").toString();
		if (errorString.isEmpty()) {
			qDebug() << "this is OK: no text in error part";
		} else {
			qDebug() << "STOP Process response. we got an error:"
					<< errorString;
			int i = errorString.toInt();
			if (i < mResponseErrorTexts.size()) {
				errorString = mResponseErrorTexts.at(i);
			}
			reportError(errorString);
			// S T O P
			return false;
		}
	} else {
		qDebug() << "no error part - we ignore this";
	}
	// number of users (created by me - without me)
	int users;
	QVariantList list;
	QVariantMap map;
	switch (usecase) {
	// only for tests
	case Usecase::UsersTestGet:
		return true;
		// only for tests
	case Usecase::UsersTestPost:
		break;
		// always at first
	case Usecase::UsersAuth:
		mToken = bodyMap.value("token", "").toString();
		qDebug() << "token:" << mToken;
		break;
		// do UsersAuth, then get Users data to know what is allowed, get customer_no etc
	case Usecase::UsersUser:
		mCustomerNumber = bodyMap.value("last_customer", "").toInt();
		qDebug() << "cust no:" << mCustomerNumber;
		break;
	case Usecase::UsersAll:
		users = bodyMap.value("users", "").toList().size();
		qDebug() << "Users: " << users;
		break;
	case Usecase::FilesAll:
		qDebug() << "got ALL FILES";
		// settings: YES we have files, so we survive offline-mode
		mOdsSettings->setTrueFor(SETTINGS_KEY_FILES_AVAILABLE, true);
		// last files from Date and Time
		mOdsSettings->saveValueFor(SETTINGS_KEY_FILES_LAST_SYNC,
				QDateTime::currentDateTime().toString(Qt::ISODate));
		break;
	case Usecase::FilesCreateFolder:
		qDebug() << "Folder successfully Created !";
		break;
	case Usecase::FilesCreateLink:
		qDebug() << "got Link !";
		break;
	case Usecase::FilesDelete:
		qDebug() << "File successfully Deleted !";
		break;
	case Usecase::FilesDeleteFolder:
		qDebug() << "Folder successfully Deleted !";
		break;
	case Usecase::FilesRename:
		qDebug() << "File successfully renamed !";
		break;
	case Usecase::FilesRenameFolder:
		qDebug() << "Folder successfully renamed !";
		break;
	case Usecase::FilesDownload:
		qDebug() << "File successfully done !";
		break;
	case Usecase::FilesDownloadThumbnail:
		qDebug() << "got Thumbnail with successfully !";
		break;
	case Usecase::FilesUpload:
		// returns 200 if OK
		break;
	case Usecase::SettingsUser:
		if (bodyMap.value("languages", "").toList().size() > 0) {
			mLanguageNumber =
					bodyMap.value("languages", "").toList().at(0).toMap().value(
							"lnr", "").toInt();
		} else {
			mLanguageNumber = 0;
		}
		qDebug() << "Language Number: " << mLanguageNumber;
		break;
	case Usecase::SettingsInfoListe:
		//
		break;
	case Usecase::TexteAll:
		//
		break;
	default:
		errorString = tr("Unknown Response Usecase");
		reportError(errorString);
		// S T O P
		return false;
	}
	return true;
}

void ODSData::reportError(QString& errorText) {

	mProgressDialog->setBody(errorText);
	mProgressDialog->setState(SystemUiProgressState::Error);
	mProgressDialog->cancel();
	// progress canceled
	// use SystemDialog to inform user
	// works more stable then progress dialog with exec()
	mDialog->setTitle(tr("Error"));
	mDialog->setBody(errorText);
	mDialog->cancelButton()->setLabel(QString::null);
	mDialog->defaultButton()->setLabel(tr("OK"));
	mDialog->exec();

}

ODSData::~ODSData() {
	// TODO Auto-generated destructor stub
}

