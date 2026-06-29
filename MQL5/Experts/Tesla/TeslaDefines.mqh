#include "BarController.mqh"
#include "EconomicCalendar.mqh"



namespace tesla {
namespace cfg {
const int FF_SIZE = 7;
string time_open_market = "09:00";
string time_close_market = "18:30";
}


BarController barD1(Symbol(), PERIOD_D1);
BarController barM15(Symbol(), PERIOD_M15);
BarController barM1(Symbol(), PERIOD_M1);
}
