#include "ODSData.hpp"
#include "ODSUser.hpp"
#include "ODSRoom.hpp"
#include "ODSSubRoom.hpp"
#include "ODSFolder.hpp"
#include "ODSFile.hpp"
#include <QUrl>
#include <bb/cascades/Application>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/AbstractPane>
#include <bb/system/SystemProgressDialog.hpp>
#include <bb/system/SystemUiButton.hpp>
#include <bb/system/SystemUiProgressState>

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
static const QString isGroupValue = "is_group";
static const QString typeValue = "type";
static const QString nodesValue = "nodes";
static const QString fileIdValue = "fileID";
static const QString nameValue = "name";
static const QString groupsValue = "groups";
static const QString groupPkValue = "group_pk";
static const QString parentValue = "parent";

ODSData::ODSData() {
	// prepare all for the work with ODS Servers
	mDelayedInitDone = false;
	// Create a network access manager and connect a custom slot to its
	// finished signal
	mNetworkAccessManager = new QNetworkAccessManager(this);

	mProgressDialog = new SystemProgressDialog(this);

	bool connectOK = connect(mNetworkAccessManager,
			SIGNAL(finished(QNetworkReply*)), this,
			SLOT(requestFinished(QNetworkReply*)));

	// access to the settings
	mOdsSettings = new ODSSettings();
	mCustomerNumber = -1;
	mFilesLevel = -1;
	mFolderLevel = -1;
	mRooms = new QVariantList;
	mCache = new QVariantList;
	mNodeNames = new QStringList;
	mRoomGroups = new QMap<int, QString>;

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
	Q_UNUSED(exists);
}

// login to the server:
void ODSData::loginToServer() {
	if (!mDelayedInitDone) {
		delayedInit();
	}
	mBaseUrl = mOdsSettings->getValueFor("server/url", "");

	mProgressDialog->setState(SystemUiProgressState::Active);
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle(tr("Sync with OpenDataSpace"));
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->cancelButton()->setLabel(tr("Stop synchronization"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("connect Server, authenticate user..."));
	mProgressDialog->show();

	mUser = mOdsSettings->getValueFor("server/current/user", "");
	mPassword = mOdsSettings->getValueFor("server/current/password", "");

	// auth-user-settings-files
	initiateRequest(-1);

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
	mResponseErrorTexts << tr("Code 0: No Error")
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

	// TODO Cascades BUG ???
	//mUsersDataModel = Application::instance()->scene()->findChild<GroupDataModel*>("userGroupDataModel");
	//mUsersList = Application::instance()->scene()->findChild<ListView*>("usersList");

	mUsersDataModel = Application::instance()->scene()->findChildren<
			GroupDataModel*>("userGroupDataModel").last();
	//mUsersList = Application::instance()->scene()->findChildren<ListView*>(
	//		"usersList").last();

	//qDebug() << "Listview children: "
	//		<< Application::instance()->scene()->findChildren<ListView*>(
	//				"usersList").size();
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

void ODSData::initRoomsModel() {
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
		resetLevel();
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

/**
 * sync all files, persist JSON, refresh caches
 * called from successfully executed commands
 */
void ODSData::refreshCaches() {

	mProgressDialog->setProgress(50);
	mProgressDialog->setBody(tr("work on server done, now sync..."));
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->show();
	// TODO get all files

	// finished
	mProgressDialog->setProgress(100);
	mProgressDialog->setState(SystemUiProgressState::Inactive);
	mProgressDialog->setBody(tr("Cache refreshed :)"));
	mProgressDialog->setIcon(QUrl("asset:///images/online-icon.png"));
	mProgressDialog->confirmButton()->setLabel(
				tr("OK"));
	mProgressDialog->cancelButton()->setLabel(QString::null);
	mProgressDialog->show();
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
	mProgressDialog->cancelButton()->setLabel(tr("Stop upload"));
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(15);
	mProgressDialog->setBody(tr("send request to server..."));
	mProgressDialog->show();
	//
	mGroupPk = roomId;
	mPath = path;
	initiateRequest(Usecase::FilesCreateFolder);
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
		mRequestJson = "{\"username\":\"" + mUser.toUtf8()
				+ "\",\"password\":\"" + mPassword.toUtf8() + "\"}";
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
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\"}";
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersUser)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase",
					QByteArray::number(Usecase::SettingsUser));
		}
		break;
	case Usecase::UsersAll:
		isJsonContent = true;
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\"}";
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::UsersAll)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(-9999));
		}
		break;
	case Usecase::FilesCreateFolder:
		isJsonContent = true;
		mRequestJson.clear();
		mRequestJson.append("{");

		mRequestJson.append("\"");
		mRequestJson.append("token");
		mRequestJson.append("\"");
		mRequestJson.append(":");
		mRequestJson.append("\"");
		mRequestJson.append(mToken.toUtf8());
		mRequestJson.append("\"");

		mRequestJson.append(",");

		mRequestJson.append("\"");
		mRequestJson.append("group_pk");
		mRequestJson.append("\"");
		mRequestJson.append(":");
		mRequestJson.append(QByteArray::number(mGroupPk));

		mRequestJson.append(",");

		mRequestJson.append("\"");
		mRequestJson.append("path");
		mRequestJson.append("\"");
		mRequestJson.append(":");
		mRequestJson.append("\"");
		mRequestJson.append(mPath.toUtf8());
		mRequestJson.append("\"");

		mRequestJson.append("}");
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesCreateFolder)));
		qDebug() << "JSON for CreateFolder: " << mRequestJson;
		break;
	case Usecase::FilesAll:
		isJsonContent = true;
		// need customernumber
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\",\"customer_nr\":"
				+ QByteArray::number(mCustomerNumber) + "}";
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
		// need fileId
		mFileId = 67;
		mFileName = "ekke.png";
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\",\"fileID\":"
				+ QByteArray::number(mFileId) + "}";
		request.setUrl(
				QUrl(mBaseUrl + mUsecasePathes.at(Usecase::FilesDownload)));
		break;
	case Usecase::FilesDownloadThumbnail:
		isJsonContent = true;
		// need fileId
		mFileId = 67;
		mFileName = "ekkeThumb.png";
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\",\"fileID\":"
				+ QByteArray::number(mFileId) + "}";
		request.setUrl(
				QUrl(
						mBaseUrl
								+ mUsecasePathes.at(
										Usecase::FilesDownloadThumbnail)));
		break;
	case Usecase::FilesUpload:
		isJsonContent = false;
		mFileName = "bb-ods-io.png";
		mFileToUpload = new QFile(uploadPath(mFileName));
		ok = mFileToUpload->open(QIODevice::ReadOnly);
		if (!ok) {
			qDebug() << "cannot open file to upload: " << mFileName;
			errorString = tr("Cannot read file to upload: ");
			errorString += mFileName;
			reportError(errorString);
			// S T O P   I T
			return;
		}
		mFileLength = mFileToUpload->size();
		qDebug() << "uploading file " << mFileName << " size: " << mFileLength
				<< "\npath: " << mFileToUpload->fileName();
		mGroupPk = 19;
		mPath = "";
		mComment = "ekkes test from QHttpMultiPart";

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
		break;
	case Usecase::TexteAll:
		isJsonContent = true;
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\"}";
		request.setUrl(QUrl(mBaseUrl + mUsecasePathes.at(Usecase::TexteAll)));
		break;
	case Usecase::SettingsUser:
		isJsonContent = true;
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\"}";
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
		mRequestJson = "{\"token\":\"" + mToken.toUtf8() + "\"}";
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
		mNetworkAccessManager->post(request, mRequestJson);
	} else {
		qDebug() << "POST MultiPart ";
		setRequestheader(request, usecase);
		mNetworkAccessManager->post(request, mRequestMultipart);
	}
	// don't stop the Activity Indicator ! Response will be async
	// response processed in SLOT requestFinished
}

/*
 * Header accepts and requests JSON, Charset is UTF-8
 */
void ODSData::setRequestheader(QNetworkRequest &request, int usecase) {
	switch (usecase) {
	case Usecase::FilesUpload:
		request.setRawHeader("Accept", "application/json");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"multipart/form-data");
		break;
	case Usecase::FilesDownload:
		request.setRawHeader("Accept", "application/octet-stream");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/json");
		// responses are coming in async, so I need to know the filename
		// perhaps also store the destination path - in this case we have a default downloads folder
		request.setRawHeader("FileName2Download", mFileName.toUtf8());
		break;
	case Usecase::FilesDownloadThumbnail:
		request.setRawHeader("Accept", "application/octet-stream");
		request.setHeader(QNetworkRequest::ContentTypeHeader,
				"application/json");
		// responses are coming in async, so I need to know the filename
		// perhaps also store the destination path - in this case we have a default downloads folder
		request.setRawHeader("FileName2Download", mFileName.toUtf8());
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
			qDebug() << "we got a STREAM content for file: "
					<< reply->request().rawHeader("FileName2Download");
			// using a downloads folder inside the app sandbox, so files are secure stored
			filename += "/download/";
			filename += reply->request().rawHeader("FileName2Download");
		}
		if (isJsonContent || isStreamContent) {
			qDebug() << "filename: " << filename;
			// write the JSON content to a file in app data directory
			// so wen use it for data models
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
			mProgressDialog->setProgress(30);
			mProgressDialog->setBody(
					tr("Authentication done, getting User..."));
			mProgressDialog->show();
			initiateRequest(-2);
			break;
			// auth and users user done, go on with users settings
		case Usecase::SettingsUser:
			mProgressDialog->setProgress(45);
			mProgressDialog->setBody(tr("User received, getting Settings..."));
			mProgressDialog->show();
			initiateRequest(-3);
			break;
			// auth, users user, settings user done, go on with all files
		case Usecase::FilesAll:
			mProgressDialog->setProgress(60);
			mProgressDialog->setBody(tr("Settings received, getting Files..."));
			mProgressDialog->show();
			initiateRequest(-4);
			break;
		case Usecase::UsersAll:
			mProgressDialog->setProgress(90);
			mProgressDialog->setBody(tr("Files received, getting Userlist..."));
			mProgressDialog->show();
			initiateRequest(-5);
			break;
		case -9999:
			mProgressDialog->setProgress(100);
			mProgressDialog->setState(SystemUiProgressState::Inactive);
			mProgressDialog->setBody(tr("Synchronization with Server done :)"));
			mProgressDialog->setIcon(QUrl("asset:///images/online-icon.png"));
			mProgressDialog->confirmButton()->setLabel(
					tr("Synchronization done"));
			mProgressDialog->cancelButton()->setLabel(QString::null);
			mProgressDialog->show();
			// TODO wait for OK before signal
			// signal   O K
			emit loginFinished(true);
			break;
		default:
			// no init steps
			refreshCaches();
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
			if (errorString.toInt()) {
				int i = errorString.toInt();
				if (i < mResponseErrorTexts.size()) {
					errorString = mResponseErrorTexts.at(i);
				}
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
		// mMyUserMap = bodyMap;
		qDebug() << "cust no:" << mCustomerNumber;
		break;
	case Usecase::UsersAll:
		users = bodyMap.value("users", "").toList().size();
		qDebug() << "Users: " << users;

		break;
	case Usecase::FilesAll:
		// need customernumber
		break;
	case Usecase::FilesCreateFolder:
		qDebug() << "Y E P  Folder Created !";
		break;
	case Usecase::FilesDownload:
		// need fileID
		break;
	case Usecase::FilesDownloadThumbnail:
		// need fileID
		break;
	case Usecase::FilesUpload:
		// returns 200 if OK
		break;
	case Usecase::SettingsUser:
		//
		//list = bodyMap.value("languages", "").toList();
		//mLanguageNumber = list.at(0).toMap().value("lnr", "").toInt();
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
	if (mProgressDialog->progress() > 0 && mProgressDialog->progress() < 100) {
		// we have a running dialog
		mProgressDialog->setBody(errorText + " :(");
		mProgressDialog->setState(SystemUiProgressState::Error);
		// switch button
		mProgressDialog->confirmButton()->setLabel(
				tr("No valid result from Server"));
		mProgressDialog->cancelButton()->setLabel(QString::null);
		mProgressDialog->setIcon(QUrl("asset:///images/offline-icon.png"));
		mProgressDialog->show();
	}
}

ODSData::~ODSData() {
	// TODO Auto-generated destructor stub
}

