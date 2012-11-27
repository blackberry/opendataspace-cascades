
#include "ODSUser.hpp"

static const QString firstNameValue = "firstname";
static const QString lastNameValue = "surname";
static const QString globalRightsValue = "global_rights";
static const QString salutationValue = "salutation";
static const QString titleValue = "title";
static const QString userNameValue = "username";
static const QString mobileLostValue = "mobile_lost";
static const QString lockedByAdminValue = "locked_by_admin";
static const QString lockedForMobileValue = "locked_for_mobile";
static const QString lastCustomerValue = "last_customer";
static const QString userNumberValue = "usernr";
static const QString accountTypeValue = "account_type";
// expiration_date
// groups

ODSUser::ODSUser(QObject *parent) {}

ODSUser::ODSUser(QVariantMap userMap) :
		QObject(), mUserMap(userMap) {

	mFirstName = mUserMap.value(firstNameValue, "").toString();
	mLastName = mUserMap.value(lastNameValue, "").toString();
	mGlobalRights = mUserMap.value(globalRightsValue, "").toString();
	mSalutation = mUserMap.value(salutationValue, "Mr.").toString();
	mTitle = mUserMap.value(titleValue, "").toString();
	mUserName = mUserMap.value(userNameValue, "").toString();
	mIsMobileLost = mUserMap.value(mobileLostValue, false).toBool();
	mIsLockedByAdmin = mUserMap.value(lockedByAdminValue, false).toBool();
	mIsLockedForMobile = mUserMap.value(lockedForMobileValue, false).toBool();
	mLastCustomer = mUserMap.value(lastCustomerValue, 0).toInt();
	mUserNumber = mUserMap.value(userNumberValue, 0).toInt();
	mAccountType = mUserMap.value(accountTypeValue, 0).toInt();
	// calculate some derivated values
	mDisplayName = mFirstName + " " + mLastName;
	switch (mAccountType) {
		case 2:
			mDisplayType = "A";
			mDisplayIcon = "../images/admin-icon.png";
			break;
		default:
			mDisplayType = "U";
			mDisplayIcon = "../images/users-icon.png";
			break;
	}
}

QString ODSUser::firstName() const {
	return mFirstName;
}

QString ODSUser::lastName() const {
	return mLastName;
}

QString ODSUser::globalRights() const {
	return mGlobalRights;
}

QString ODSUser::salutation() const {
	return mSalutation;
}

QString ODSUser::title() const {
	return mTitle;
}

QString ODSUser::userName() const {
	return mUserName;
}

bool ODSUser::mobileLost() const {
	return mIsMobileLost;
}

bool ODSUser::lockedByAdmin() const {
	return mIsLockedByAdmin;
}

bool ODSUser::lockedForMobile() const {
	return mIsLockedForMobile;
}

int ODSUser::lastCustomer() const {
	return mLastCustomer;
}

int ODSUser::userNumber() const {
	return mUserNumber;
}

int ODSUser::accountType() const {
	return mAccountType;
}

QString ODSUser::displayName() const {
	return mDisplayName;
}

QString ODSUser::displayType() const {
	return mDisplayType;
}

QString ODSUser::displayIcon() const {
	return mDisplayIcon;
}

void ODSUser::setFirstName(QString newFirstName) {
	if (newFirstName != mFirstName) {
		mFirstName = newFirstName;
		emit firstNameChanged(newFirstName);
	}
}

void ODSUser::setLastName(QString newLastName) {
	if (newLastName != mLastName) {
		mLastName = newLastName;
		emit lastNameChanged(newLastName);
	}
}

void ODSUser::setGlobalRights(QString newGlobalRights) {
	if (newGlobalRights != mGlobalRights) {
		mGlobalRights = newGlobalRights;
		emit globalRightsChanged (newGlobalRights);
	}
}

void ODSUser::setSalutation(QString newSalutation) {
	if (newSalutation != mSalutation) {
		mSalutation = newSalutation;
		emit salutationChanged (newSalutation);
	}
}

void ODSUser::setTitle(QString newTtile) {
	if (newTtile != mTitle) {
		mTitle = newTtile;
		emit titleChanged (newTtile);
	}
}

void ODSUser::setUserName(QString newUserName) {
	if (newUserName != mUserName) {
		mUserName = newUserName;
		emit userNameChanged (newUserName);
	}
}

void ODSUser::setMobileLost(bool isMobileLost) {
	if (isMobileLost != mIsMobileLost) {
		mIsMobileLost = isMobileLost;
		emit mobileLostChanged (isMobileLost);
	}
}

void ODSUser::setLockedByAdmin(bool isLockedByAdmin) {
	if (isLockedByAdmin != mIsLockedByAdmin) {
		mIsLockedByAdmin = isLockedByAdmin;
		emit lockedByAdminChanged (isLockedByAdmin);
	}
}

void ODSUser::setLockedForMobile(bool isLockedForMobile) {
	if (isLockedForMobile != mIsLockedForMobile) {
		mIsLockedForMobile = isLockedForMobile;
		emit lockedForMobileChanged (isLockedForMobile);
	}
}

void ODSUser::setLastCustomer(int lastCustomer) {
	if (lastCustomer != mLastCustomer) {
		mLastCustomer = lastCustomer;
		emit lastCustomerChanged (lastCustomer);
	}
}

void ODSUser::setUserNumber(int userNumber) {
	if (userNumber != mUserNumber) {
		mUserNumber = userNumber;
		emit userNumberChanged (userNumber);
	}
}

void ODSUser::setAccountType(int accountType) {
	if (accountType != mAccountType) {
		mAccountType = accountType;
		emit accountTypeChanged (accountType);
	}
}

ODSUser::~ODSUser() {
	//
}

