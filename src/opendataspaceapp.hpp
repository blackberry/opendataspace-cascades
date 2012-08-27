#ifndef OPENDATASPACEAPP_H
#define OPENDATASPACEAPP_H

#include <QObject>
#include <bb/cascades/Page>
#include <bb/cascades/Menu>

using namespace bb::cascades;

/*!
 * @brief Application GUI object
 */
class OpenDataSpaceApp : public QObject
{
    Q_OBJECT
public:
    OpenDataSpaceApp();

public slots:
    void logoutTriggered();
    void feedbackTriggered();
    void helpTriggered();
    void settingsTriggered();

private:
    Page *root;

    Menu* createSystemMenu();

};



#endif // ifndef OPENDATASPACEAPP_H
