#include <Arrays\List.mqh>

//+------------------------------------------------------------------+
class ObjName: public CObject
{
public:
    string name;
    ObjName(string _name) : name(_name) {}
    ~ObjName()
    {
        ObjectDelete(0, name);
    }
};
//+------------------------------------------------------------------+
class Drawer
{
    CList list;

public:
    Drawer() : list()
    {
        list.FreeMode(true);
        list.Add(new ObjName("teste"));
    }
    //+------------------------------------------------------------------+
    ~Drawer() {
       for(int i=list.Total()-1; i >= 0; i--) {
         list.Delete(i);
       }
       list.Clear();
    }
    //+------------------------------------------------------------------+
    void ClearObjects()
    {
       for(int i=list.Total()-1; i >= 0; i--) {
         list.Delete(i);
       }
       list.Clear();
    }
    //+------------------------------------------------------------------+
    void DrawChannel(string prefix, double pr1, color clr, int width, ENUM_LINE_STYLE style)
    {
        string obj_name = prefix + TimeToString(iTime(NULL, 0, 0));
        string obj_name_prev = prefix + TimeToString(iTime(NULL, 0, 1));

        if (ObjectFind(0, obj_name) < 0) {
            double pr2 = pr1;
            if (ObjectFind(0, obj_name_prev) == 0) {
                pr2 = ObjectGetDouble(0, obj_name_prev, OBJPROP_PRICE, 1);
            }
            ObjectCreate(0, obj_name, OBJ_TREND, 0, iTime(NULL, 0, 1), pr2, iTime(NULL, 0, 0), pr1);
            ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, width);
            ObjectSetInteger(0, obj_name, OBJPROP_LEVELSTYLE, style);
            ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
            list.Add(new ObjName(obj_name));
        }
    }
};
//+------------------------------------------------------------------+