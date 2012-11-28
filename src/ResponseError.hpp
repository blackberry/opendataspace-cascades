#ifndef RESPONSEERROR_HPP_
#define RESPONSEERROR_HPP_

#include <QObject>

class ResponseError: public QObject {
Q_ENUMS(ResponseError)

public:
ResponseError();
	virtual ~ResponseError() {
	}

	enum ResponseErrorEnum {
			NoError, JSONError, InvalidCredentials, AccountExpired, MobileLost, LockedForMobile, LockedByAdmin,
			TokenExpired, UserExists, CustomerNotFound, ParentPathError, WriteFileError, InvalidFile, FileExists,
			FolderNotEmpty, CreateLinkFailed, UserLimitReached, CustomerSizeReached, FilesDeleteFailed,
			MoveFilesFailed, CopyFilesFailed, AuthenticationFailed
		};

};


#endif /* RESPONSEERROR_HPP_ */
