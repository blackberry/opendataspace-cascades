#ifndef SINGLETON_HPP_
#define SINGLETON_HPP_

#include <QObject>

// http://www.qtcentre.org/wiki/index.php?title=Singleton_pattern
template <class T>
class Singleton
{
public:
    static T& Instance()
    {
        static T _instance; // create static instance of our class
        return _instance;   // return it
    }

private:
    Singleton();	// hide constructor
    ~Singleton();	// hide destructor
    Singleton(const Singleton &); // hide copy constructor
    Singleton& operator=(const Singleton &); // hide assign op
};


#endif /* SINGLETON_HPP_ */
