
//+------------------------------------------------------------------+
class Sombra: public CObject
{
public:
    string name;
    Sombra(string _name) : name(_name) {}
    ~Sombra()
    {
        ObjectDelete(0, name);
    }
};
//+------------------------------------------------------------------+