
#include "ODSData.hpp"
#include "ODSUser.hpp"
 #include <QUrl>
#include <bb/cascades/Application>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/AbstractPane>
#include <bb/system/SystemProgressDialog.hpp>
#include <bb/system/SystemUiButton.hpp>

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
	mOdsSettings = new ODSSettings();

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
	mBaseUrl = mOdsSettings->getValueFor("server/url","");

	mProgressDialog = new SystemProgressDialog();
	mProgressDialog->setEmoticonsEnabled(true);
	mProgressDialog->setTitle("Sync with OpenDataSpace");
	mProgressDialog->setStatusMessage(mBaseUrl);
	mProgressDialog->setIcon(QUrl("asset:///images/download-icon.png"));
	mProgressDialog->cancelButton()->setLabel("connect later");
	mProgressDialog->confirmButton()->setLabel(QString::null);
	mProgressDialog->setProgress(1);
	mProgressDialog->setBody("connect Server, authenticate user...");
	mProgressDialog->show();

	mUser = mOdsSettings->getValueFor("server/current/user","");
	mPassword = mOdsSettings->getValueFor("server/current/password","");

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





//  M O D E L     F O R    L I S T V I E W S
void ODSData::initUserModel() {

	// seems that ListView and GroupDataModel will be found after Component was destroyed
	// so we access the last one
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
		qDebug() << "found GroupDataModel: " << mUsersDataModel->size();
		qDebug() << "and from all users: " << mListAllUser.size();
		mUsersDataModel->clear();
		if (!mMyUserMap.isEmpty()) {
			mUsersDataModel->insert(new ODSUser(mMyUserMap));
		}
		for (int i = 0; i < mListAllUser.size(); ++i) {
			QVariantMap map = mListAllUser.at(i).toMap();
			mUsersDataModel->insert(new ODSUser(map));
		}
	} else {
		qDebug() << "NOT found GroupDataModel :(";
	}

}

void ODSData::initiateRequest(int usecase) {
	// Start the activity indicator
	// if not in login-sequence
	startActivityIndicator();

	bool isJsonContent;
	bool isInitialization;
	bool ok;

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
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::UsersTestGet)));
		// GET Request
		mNetworkAccessManager->get(request);
		return;
		// only for tests
	case Usecase::UsersTestPost:
		isJsonContent = true;
		mRequestJson.clear();
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::UsersTestPost)));
		break;
		// always at first
	case Usecase::UsersAuth:
		isJsonContent = true;
		mRequestJson =
				"{\"username\":\""
				+ mUser.toUtf8()
				+ "\",\"password\":\""
				+ mPassword.toUtf8()
				+"\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::UsersAuth)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(Usecase::UsersUser));
		}
		break;
		// do UsersAuth, then get Users data to know what is allowed, get customer_no etc
	case Usecase::UsersUser:
		isJsonContent = true;
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::UsersUser)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(Usecase::SettingsUser));
		}
		break;
	case Usecase::UsersAll:
		isJsonContent = true;
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::UsersAll)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(-9999));
		}
		break;
	case Usecase::FilesAll:
		isJsonContent = true;
		// need customernumber
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\",\"customer_nr\":"
				+ QByteArray::number(mCustomerNumber)
				+ "}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::FilesAll)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(Usecase::UsersAll));
			qDebug() << "last step of initialization: filesAll";
		}
		break;
	case Usecase::FilesDownload:
		isJsonContent = true;
		// need fileId
		mFileId = 67;
		mFileName = "ekke.png";
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\",\"fileID\":"
				+ QByteArray::number(mFileId)
				+ "}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::FilesDownload)));
		break;
	case Usecase::FilesDownloadThumbnail:
		isJsonContent = true;
		// need fileId
		mFileId = 67;
		mFileName = "ekkeThumb.png";
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\",\"fileID\":"
				+ QByteArray::number(mFileId)
				+ "}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::FilesDownloadThumbnail)));
		break;
	case Usecase::FilesUpload:
		isJsonContent = false;
		mFileName = "bb-ods-io.png";
		mFileToUpload = new QFile(uploadPath(mFileName));
		ok = mFileToUpload->open(QIODevice::ReadOnly);
		if (!ok) {
			// TODO notify UI
			qDebug() << "cannot open file to upload: " << mFileName;
			stopActivityIndicator();
			return;
		}
		mFileLength = mFileToUpload->size();
		qDebug() << "uploading file " << mFileName << " size: " << mFileLength << "\npath: " << mFileToUpload->fileName();
		mGroupPk = 19;
		mParentPath= "";
		mComment="ekkes test from QHttpMultiPart";

		mRequestMultipart = new QHttpMultiPart(QHttpMultiPart::FormDataType, this);
		fileLengthPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file_length\""));
		fileLengthPart.setBody(QString::number(mFileLength).toUtf8());
		mRequestMultipart->append(fileLengthPart);
		groupPkPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"group_pk\""));
		groupPkPart.setBody(QString::number(mGroupPk).toUtf8());
		mRequestMultipart->append(groupPkPart);
		parentPathPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"parent_path\""));
		parentPathPart.setBody(mParentPath.toUtf8());
		mRequestMultipart->append(parentPathPart);
		commentPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"comment\""));
		commentPart.setBody(mComment.toUtf8());
		mRequestMultipart->append(commentPart);
		logUcPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"log_uc\""));
		logUcPart.setBody(mUser.toUtf8());
		mRequestMultipart->append(logUcPart);
		expirationDatePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"expiration_date\""));
		expirationDatePart.setBody("");
		mRequestMultipart->append(expirationDatePart);
		tokenPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"token\""));
		tokenPart.setBody(mToken.toUtf8());
		mRequestMultipart->append(tokenPart);
		overWritePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"overwrite\""));
		overWritePart.setBody(QString::number(0).toUtf8());
		mRequestMultipart->append(overWritePart);

		fileAttachementPart.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
		fileAttachementPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file_attachment\"; filename=\""+mFileName+"\""));
		fileAttachementPart.setBodyDevice(mFileToUpload);
		mRequestMultipart->append(fileAttachementPart);

		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::FilesUpload)));
		break;
	case Usecase::TexteAll:
		isJsonContent = true;
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::TexteAll)));
		break;
	case Usecase::SettingsUser:
		isJsonContent = true;
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::SettingsUser)));
		if (isInitialization) {
			// add a special header
			request.setRawHeader("nextUsecase", QByteArray::number(Usecase::FilesAll));
		}
		break;
	case Usecase::SettingsInfoListe:
		isJsonContent = true;
		mRequestJson =
				"{\"token\":\""
				+ mToken.toUtf8()
				+ "\"}";
		request.setUrl(QUrl(mBaseUrl+mUsecasePathes.at(Usecase::SettingsInfoListe)));
		break;
	default:
		// TODO mResultText->setText("unknown: " + usecase);
		// TODO mActivityIndicator->stop();
		// TODO mActivityIndicator->setVisible(false);
		return;
		break;
	}
	// POST Request
	if (isJsonContent) {
		qDebug() << "POST JSON";
		if (!mRequestJson.isEmpty()) {
			postDataSize = QByteArray::number(mRequestJson.size());
			request.setHeader(QNetworkRequest::ContentLengthHeader, postDataSize);
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
			request.setHeader(QNetworkRequest::ContentTypeHeader, "multipart/form-data");

			break;
		case Usecase::FilesDownload:
			request.setRawHeader("Accept", "application/octet-stream");
			request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
			// responses are coming in async, so I need to know the filename
			// perhaps also store the destination path - in this case we have a default downloads folder
			request.setRawHeader("FileName2Download", mFileName.toUtf8());
			break;
		case Usecase::FilesDownloadThumbnail:
			request.setRawHeader("Accept", "application/octet-stream");
			request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
			// responses are coming in async, so I need to know the filename
			// perhaps also store the destination path - in this case we have a default downloads folder
			request.setRawHeader("FileName2Download", mFileName.toUtf8());
			break;
		default:
			request.setRawHeader("Accept", "application/json");
			request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
			break;
	}
	request.setRawHeader("charset", "utf-8");
}

// S L O T
// async getting info that request was finished
void ODSData::requestFinished(QNetworkReply* reply) {
	// Check the network reply for errors
	if (reply->error() == QNetworkReply::NoError) {
		qDebug() << "NO error from QNetworkReply";

		QString replyUrl(reply->url().toString(QUrl::None));
		qDebug() << "reply URL" << replyUrl;

		QByteArray replyBytes = reply->readAll();

		qDebug() << "reply Content" << reply->header(QNetworkRequest::ContentTypeHeader).toString();
		bool isJsonContent;
		bool isStreamContent;
		if (reply->header(QNetworkRequest::ContentTypeHeader).toString() == "application/json") {
			isJsonContent = true;
			isStreamContent = false;
		} else if (reply->header(QNetworkRequest::ContentTypeHeader).toString() == "application/octet-stream") {
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
			int r = replyUrl.length()-mBaseUrl.length();
			if (r > 0) {
				replyPath = replyUrl.right(r);
				filename += replyPath;
			}
			filename += ".json";
		}

		if (isStreamContent) {
			qDebug() << "we got a STREAM content for file: " << reply->request().rawHeader("FileName2Download");
			// using a downloads folder inside the app sandbox, so files are secure stored
			filename += "/download/";
			filename += reply->request().rawHeader("FileName2Download");
		}

		if (isJsonContent || isStreamContent) {
			qDebug() << "filename: " << filename;
			// to make tests easy we not only write files we downloaded
			// but also write the JSON content to a file in app data directory
			// in a real app you won't do this
			writeReplyToFile(replyBytes, filename);
			// display the reply in the UI
			// TODO mResultText->setText(replyBytes);
		} else {
			qDebug() << "wrong content: " << reply->header(QNetworkRequest::ContentTypeHeader).toString();
			// TODO mResultError->setText("wrong content: " + reply->header(QNetworkRequest::ContentTypeHeader).toString());
		}

		if (isJsonContent) {
			// process the JSON usecases
			bool validUsecase = false;
			for (int i = 0; i < mUsecasePathes.size(); ++i) {
				if (mUsecasePathes.at(i) == replyPath) {
					processResponse(replyBytes,  i);
					validUsecase = true;
					break;
				}
			}
			if (!validUsecase) {
				qDebug()  << "couldn't process response path: " << replyPath;
				// TODO mResultError->setText("unknown Path from reply URL" + replyPath);
			}
		}

		// initialization - steps ?
		// test for specific header
		int usecase = reply->request().rawHeader("nextUsecase").toInt();
		switch (usecase) {
			// usersAuth done - go on with users user
			case Usecase::UsersUser:
				mProgressDialog->setProgress(20);
				mProgressDialog->setBody("Authentication done, getting User...");
				mProgressDialog->show();
				initiateRequest(-2);
				break;
			// auth and users user done, go on with users settings
			case Usecase::SettingsUser:
				mProgressDialog->setProgress(40);
				mProgressDialog->setBody("User received, getting Settings...");
				mProgressDialog->show();
				initiateRequest(-3);
				break;
			// auth, users user, settings user done, go on with all files
			case Usecase::FilesAll:
				mProgressDialog->setProgress(60);
				mProgressDialog->setBody("Settings received, getting Files...");
				mProgressDialog->show();
				initiateRequest(-4);
				break;
			case Usecase::UsersAll:
				mProgressDialog->setProgress(80);
				mProgressDialog->setBody("Files received, getting Userlist...");
				mProgressDialog->show();
				initiateRequest(-5);
				break;
			case -9999:
				mProgressDialog->setProgress(100);
				mProgressDialog->setBody("Synchronization with Server done :)");
				mProgressDialog->confirmButton()->setLabel("OK");
				mProgressDialog->cancelButton()->setLabel(QString::null);
				mProgressDialog->show();
				// TODO wait for OK before signal
				// signal
				emit loginFinished(true);
				break;
			// no init steps
			default:
				break;
		}


	} else {
		// uuuups - there was a network error
		qDebug() << "Problem with the network:" << reply->errorString();
		// TODO mResultText->setText(reply->errorString());
		// TODO mResultBody->setText("Network Problem");
		// TODO mResultError->setText(reply->url().toString(QUrl::None));
	}
	stopActivityIndicator();
	reply->deleteLater();
}

void ODSData::writeReplyToFile(QByteArray &replyBytes, QString &filename) {
	QFile file(dataPath(filename));
	bool ok = file.open(QIODevice::WriteOnly);
	if (ok) {
		file.write(replyBytes);
		file.flush();
		file.close();
	} else {
		qDebug()  << "cannot open file";
	}
}


void ODSData::processResponse(QByteArray &replyBytes, int usecase) {

	JsonDataAccess jda;
	// we load a JSON with root is Object
	const QVariantMap rootObject(jda.loadFromBuffer(replyBytes).toMap());
	// exists root object body ?
	QVariantMap bodyMap;
	if (rootObject.contains("body")) {
		bodyMap = rootObject.value("body").toMap();
		QStringList keyList;
		keyList = bodyMap.keys();
		// TODO mResultBody->setText(keyList.join(", "));

		// more
	} else {
		// TODO mResultBody->setText("no body object in JSON");
		qDebug() << "no body";
	}
	if (rootObject.contains("error")) {
		QString errorString = rootObject.value("error", "").toString();
		if (errorString.isEmpty()) {
			// TODO mResultError->setText("no error text");
			qDebug() << "no error text";
		} else {
			qDebug() << "error:" << errorString;
			// TODO mResultError->setText(errorString);
		}
	} else {
		qDebug() << "no error";
		// TODO mResultError->setText("no error object in JSON");
	}
	// number of users (created by me - without me)
	int users;
	QVariantList list;
	QVariantMap map;
	switch (usecase) {
		// only for tests
		case Usecase::UsersTestGet:
			return;
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
			mMyUserMap = bodyMap;
			qDebug() << "cust no:" << mCustomerNumber;
			break;
		case Usecase::UsersAll:
			// TODO TEMP
			mListAllUser = bodyMap.value("users", "").toList();
			users = bodyMap.value("users", "").toList().size();
			qDebug() << "Users: " << users;

			break;
		case Usecase::FilesAll:
			// need customernumber
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
				mLanguageNumber = bodyMap.value("languages", "").toList().at(0).toMap().value("lnr", "").toInt();
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
			// TODO mResultText->setText("unknown response: " + usecase);

			return;
		}
}

void ODSData::startActivityIndicator(){
	// TODO
	qDebug() << "START ActivityIndicator";
}

void ODSData::stopActivityIndicator(){
	// TODO
	qDebug() << "STOP ActivityIndicator";
}

void ODSData::progressActivityIndicator(int value) {
	// TODO
	qDebug() << "Progress ActivityIndicator 1...100: " << value;
}

ODSData::~ODSData() {
	// TODO Auto-generated destructor stub
}

