#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
string sp;

class Panel;
Panel *panel;

//+------------------------------------------------------------------+
class ObjPanel: public CObject
{
public:
    string name;
    ObjPanel(string _name) : name(_name) {}
    ~ObjPanel()
    {
        ObjectDelete(0, name);
    }
};
//+------------------------------------------------------------------+
class Panel
{
    string name;
    int X;
    int Y;
    color clr_back;
    color clr_text;
    int x_offset;
    int y_offset;
    int y_current;
    int font_size;
    CList list;
    int gmt_offset;
    int gmt_brazil;

public:
    Panel(string _name, int _X, int _Y, color _clr_back, color _clr_text)
        : name(_name), X(_X), Y(_Y), clr_back(_clr_back), clr_text(_clr_text)
    {
        list.FreeMode(true);
        Create();
        Reset();
        gmt_offset = 3;
        gmt_brazil = -3;
        StringInit(sp, 300, '-');
    }
    //+------------------------------------------------------------------+
    ~Panel()
    {
        Remove();
        list.Clear();
    }
    //+------------------------------------------------------------------+
    void Reset()
    {
        x_offset = 5;
        y_offset = 20;
        y_current = 20;
        font_size = 9;
        list.Clear();
    }
    //+------------------------------------------------------------------+
    void define_gmt(int _gmt_offset, int _gmt_brazil)
    {
        gmt_offset = _gmt_offset;
        gmt_brazil = _gmt_brazil;
    }
    //+------------------------------------------------------------------+
    void Create()
    {
        ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 1);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 15);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, X);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, Y);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr_back);
        ObjectSetString(0, name, OBJPROP_TEXT, "Cache");
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0);
        ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);
        ChartSetInteger(0, CHART_FOREGROUND, 0, false);
    }
    //+------------------------------------------------------------------+
    void Remove()
    {
        ObjectDelete(0, name);
    }
    //+------------------------------------------------------------------+
    void AddText(string id, string text)
    {
        ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0);
        ObjectSetString(0, id, OBJPROP_TEXT, text);
        ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
        ObjectSetInteger(0, id, OBJPROP_COLOR, clr_text);
        ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x_offset);
        ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y_current);
        ObjectSetInteger(0, id, OBJPROP_XSIZE, X);
        y_current += y_offset;
        list.Add(new ObjPanel(id));
    }
    //+------------------------------------------------------------------+
    //void newInfo(string value) { info = value; }
    //void addInfo(string value) { info += value; }
    //void clearInfo() { info = ""; }
    //void Display() { Comment(info); }
    //+------------------------------------------------------------------+
    string getInfoDateTime()
    {
        string info = "";
        datetime timeCurrent = TimeCurrent();
        datetime timeGmt = timeCurrent + (gmt_offset * 3600);
        datetime timeBrazil = timeGmt + (gmt_brazil * 3600);
        //info += "Time Server: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + " / ";
        info += "Time GMT: " + TimeToString(timeGmt, TIME_DATE | TIME_SECONDS) + " / ";
        info += "Brazil: " + TimeToString(timeBrazil, TIME_DATE | TIME_SECONDS);
        return info;
    }
    //+------------------------------------------------------------------+
    string getInfoAccount()
    {
        string info = "";
        info += "Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + " / ";
        info += "Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + " / ";
        info += "FreeMargin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2);
        //info += "Profit: " + DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY);
        return info;
    }
    //+------------------------------------------------------------------+
    void AddHeader()
    {
        AddText("ea_header_name", StringFormat("---=== %s ===---", name));
        AddText("ea_header_date", getInfoDateTime());
        AddText("ea_header_account", getInfoAccount());
        AddText("ea_header_end", sp);
    }
    //+------------------------------------------------------------------+
};