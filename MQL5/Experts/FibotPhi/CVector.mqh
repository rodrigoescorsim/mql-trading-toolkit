#include <Arrays\ArrayObj.mqh>

//+------------------------------------------------------------------+
template<typename T>
class CVector: public CArrayObj
{
public:
    CVector() {
        FreeMode(true);
    }
    T operator[](const int index) const
    {
        return At(index);
    }
};
//+------------------------------------------------------------------+