//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
class BarController
{
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    bool updated;
    datetime current_datetime;
    datetime last_datetime;

public:
    BarController(string sym, ENUM_TIMEFRAMES tf)
        : symbol(sym), timeframe(tf), updated(false), current_datetime(iTime(symbol, timeframe, 1)),
          last_datetime(iTime(symbol, timeframe, 2))
    {}
    bool update()
    {
        updated = false;
        datetime now_datetime = iTime(symbol, timeframe, 0);
        if (now_datetime != current_datetime) {
            updated = true;
            current_datetime = now_datetime;
            last_datetime = iTime(symbol, timeframe, 1);
        }
        return updated;
    }
    bool isUpdated()
    {
        return updated;
    }
    string getCurrentDateStr()
    {
        return TimeToString(current_datetime, TIME_DATE);
    }
    string getLastDateStr()
    {
        return TimeToString(last_datetime, TIME_DATE);
    }
};
//+------------------------------------------------------------------+