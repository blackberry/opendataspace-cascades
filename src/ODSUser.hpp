

#ifndef ODSUSER_HPP_
#define ODSUSER_HPP_

#include <qobject.h>
#include <qvariant.h>

class ODSUser: public QObject {
	Q_OBJECT

	 Q_PROPERTY(QString firstName READ firstName WRITE setFirstName NOTIFY firstNameChanged FINAL)
	 Q_PROPERTY(QString lastName READ lastName WRITE setLastName NOTIFY lastNameChanged FINAL)
	 Q_PROPERTY(QString globalRights READ globalRights WRITE setGlobalRights NOTIFY globalRightsChanged FINAL)
	 Q_PROPERTY(QString salutation READ salutation WRITE setSalutation NOTIFY salutationChanged FINAL)
	 Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged FINAL)
	 Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged FINAL)

	 Q_PROPERTY(bool mobileLost READ mobileLost WRITE setMobileLost NOTIFY mobileLostChanged FINAL)
	 Q_PROPERTY(bool lockedForMobile READ lockedForMobile WRITE setLockedForMobile NOTIFY lockedForMobileChanged FINAL)
	 Q_PROPERTY(bool lockedByAdmin READ lockedByAdmin WRITE setLockedByAdmin NOTIFY lockedByAdminChanged FINAL)

	 Q_PROPERTY(int lastCustomer READ lastCustomer WRITE setLastCustomer NOTIFY lastCustomerChanged FINAL)
	 Q_PROPERTY(int userNumber READ userNumber WRITE setUserNumber NOTIFY userNumberChanged FINAL)
	 Q_PROPERTY(int accountType READ accountType WRITE setAccountType NOTIFY accountTypeChanged FINAL)

	 Q_PROPERTY(QString displayName READ displayName FINAL)
	 Q_PROPERTY(QString displayType READ displayType FINAL)
	 Q_PROPERTY(QString displayIcon READ displayIcon FINAL)

public:
	ODSUser(QObject *parent = 0);
	virtual ~ODSUser();
	ODSUser(QVariantMap userMap);

	QString firstName() const;
	QString lastName() const;
	QString globalRights() const;
	QString salutation() const;
	QString title() const;
	QString userName() const;

	bool mobileLost() const;
	bool lockedForMobile() const;
	bool lockedByAdmin() const;

	int lastCustomer() const;
	int userNumber() const;
	int accountType() const;

	QString displayName() const;
	QString displayType() const;
	QString displayIcon() const;

	void setFirstName(QString newFirstName);
	void setLastName(QString newLastName);
	void setGlobalRights(QString newGlobalRights);
	void setSalutation(QString newSalutation);
	void setTitle(QString newTitle);
	void setUserName(QString newUserName);

	void setMobileLost(bool isMobileLost);
	void setLockedForMobile(bool isLockedForMobile);
	void setLockedByAdmin(bool isLockedByAdmin);

	void setLastCustomer(int lastCustomer);
	void setUserNumber(int userNumber);
	void setAccountType(int accountType);

Q_SIGNALS:
	void firstNameChanged(QString firstName);
	void lastNameChanged(QString lastName);
	void globalRightsChanged(QString globalRights);
	void salutationChanged(QString salutation);
	void titleChanged(QString title);
	void userNameChanged(QString userName);

	void mobileLostChanged(bool isMobileLost);
	void lockedForMobileChanged(bool isLockedForMobile);
	void lockedByAdminChanged(bool isLockedByAdmin);

	void lastCustomerChanged(int lastCustomer);
	void userNumberChanged(int userNumber);
	void accountTypeChanged(int accountType);

private:
	// TODO QMap UserGroups
	QVariantMap mUserMap;
    QString mFirstName;
    QString mLastName;
    QString mGlobalRights;
    QString mSalutation;
    QString mTitle;
    QString mUserName;

    bool mIsMobileLost;
    bool mIsLockedForMobile;
    bool mIsLockedByAdmin;

    int mLastCustomer;
    int mUserNumber;
    int mAccountType;

    QString mDisplayName;
    QString mDisplayType;
    QString mDisplayIcon;



Q_DISABLE_COPY(ODSUser)

};

#endif /* ODSUSER_HPP_ */
