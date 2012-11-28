

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

	Q_INVOKABLE
	void initUserModel();

private:
	GroupDataModel* m_UsersDataModel;
	ListView* m_usersList;
};


#endif /* ODSDATA_HPP_ */
