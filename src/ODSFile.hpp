

#ifndef ODSFILE_HPP_
#define ODSFILE_HPP_

#include <QObject>
#include <qvariant.h>

class ODSFile: public QObject {
	Q_OBJECT

public:
	ODSFile(QObject *parent = 0);
	virtual ~ODSFile();
	ODSFile(QVariantMap fileMap);

Q_SIGNALS:

private:

Q_DISABLE_COPY(ODSFile)
};
Q_DECLARE_METATYPE(ODSFile*)

#endif /* ODSFILE_HPP_ */
