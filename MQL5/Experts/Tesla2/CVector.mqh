#include <Arrays\ArrayObj.mqh>

//+------------------------------------------------------------------+
template<typename T>
class CVector: public CArrayObj
{
public:
    T operator[](const int index) const
    {
        return At(index);
    }
};
//+------------------------------------------------------------------+