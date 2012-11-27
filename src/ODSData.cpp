

#include "ODSData.hpp"
#include <bb/cascades/Application>
#include <bb/data/JsonDataAccess>
#include <bb/cascades/GroupDataModel>
#include <bb/cascades/AbstractPane>


using namespace bb::cascades;
using namespace bb::data;

ODSData::ODSData() {
	// TODO Auto-generated constructor stub

}

void ODSData::initUserModel() {

		// seems that ListView and GroupDataModel will be found after Component was destroyed
		// so we access the last one
		// TODO Cascades BUG ???

		//m_UsersDataModel = Application::instance()->scene()->findChild<GroupDataModel*>("userGroupDataModel");
		//m_usersList = Application::instance()->scene()->findChild<ListView*>("usersList");

		m_UsersDataModel = Application::instance()->scene()->findChildren<GroupDataModel*>("userGroupDataModel").last();
		m_usersList = Application::instance()->scene()->findChildren<ListView*>("usersList").last();

		qDebug() << "Listview children: " << Application::instance()->scene()->findChildren<ListView*>("usersList").size();
		qDebug() << "DataModel children: " << Application::instance()->scene()->findChildren<GroupDataModel*>("userGroupDataModel").size();




	qDebug() << "initUserModel: ";
	if (m_UsersDataModel) {
		qDebug() << "found GroupDataModel: " << m_UsersDataModel->size();
		QVariantMap map;
		map["name"] = "ekke"; map["displayType"] = "A"; map["icon"] = "../images/admin-icon.png";
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

ODSData::~ODSData() {
	// TODO Auto-generated destructor stub
}

