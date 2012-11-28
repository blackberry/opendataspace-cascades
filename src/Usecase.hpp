#ifndef USECASE_HPP_
#define USECASE_HPP_

#include <QObject>

class Usecase: public QObject {

	Q_PROPERTY(UsecaseEnum usecase READ usecase NOTIFY usecaseChanged)

public:
	Usecase();
	virtual ~Usecase() {
	}

	enum UsecaseEnum {
		UsersTestGet, UsersTestPost, UsersAuth, UsersUser, UsersAll, UsersInsert,
		FilesAll, FilesUpload, FilesCopy, FilesCopyAllFiles, FilesRename, FilesMove, FilesUpdate,
		FilesDelete, FilesDownload, FilesDownloadThumbnail, FilesCreateFolder, FilesCreateLink, FilesRenameFolder, FilesDeleteFolder,
		FilesMoveFolder, FilesGetMetadata, FilesSetMetadata, SettingsUser, SettingsInfoListe, TexteAll, TexteLanguage

	};
	Q_ENUMS(UsecaseEnum)

	Usecase(QObject *parent = 0);

};

#endif /* USECASE_HPP_ */
