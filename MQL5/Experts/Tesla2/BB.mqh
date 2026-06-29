#include "BarController.mqh"

#ifndef ESCONDER_BANDS input #endif 
string input_info_bb = "=== FILTRO BANDAS DE BOLLINGER ==="; //-
#ifndef ESCONDER_BANDS input #endif  
bool input_useBBFilter = true;  // Ativar filtro Bandas de Bollinger
#ifndef ESCONDER_BANDS input #endif 
ENUM_TIMEFRAMES input_bb_timeframe = PERIOD_M1; // BB Timeframe 
#ifndef ESCONDER_BANDS input #endif 
int input_bb_period = 20;       // BB Period
#ifndef ESCONDER_BANDS input #endif 
double input_bb_deviation = 2.5;       // BB Period
#ifndef ESCONDER_BANDS input #endif 
int input_bb_shift = 0;       // BB Shift

//+------------------------------------------------------------------+
class BB
{
    //+------------------------------------------------------------------+
public:
    BarController bar;
    int handle;
    double base_values[];
    double upper_values[];
    double lower_values[];
    double base_value;
    double upper_value;
    double lower_value;
    
    //+------------------------------------------------------------------+
    BB() : bar(_Symbol, input_bb_timeframe)
    {
        if (!input_useBBFilter)
            return;
        handle = iBands( _Symbol, input_bb_timeframe, input_bb_period, input_bb_shift, input_bb_deviation, PRICE_CLOSE);
        ArraySetAsSeries(base_values,true);
        ArraySetAsSeries(upper_values,true);
        ArraySetAsSeries(lower_values,true);
        base_value = upper_value = lower_value = 0;
    }
    //+------------------------------------------------------------------+
    void update()
    {
        if (!input_useBBFilter)
            return;
            
        if(bar.update()) {
            //CopyBuffer((handle,0,0,1,base_values);
            CopyBuffer(handle,1,0,1,upper_values);
            CopyBuffer(handle,2,0,1,lower_values);
            
            //base_value = base_values[0];
            upper_value = upper_values[0];
            lower_value = lower_values[0];
            //PrintFormat("New BB values - Upper: %.2f Lower: %.2f", upper_value, lower_value);
        }
    }
    //+------------------------------------------------------------------+
    bool bbBuyAllowed(double price)
    {
        if(price <= lower_value) PrintFormat("BB BUY ALLOWED - Lower: %.2f - Price: %.2f", lower_value, price);
        return !input_useBBFilter || (price <= lower_value);
    }
    //+------------------------------------------------------------------+
    bool bbSellAllowed(double price)
    {
        if(price >= upper_value) PrintFormat("BB SELL ALLOWED - Upper: %.2f - Price: %.2f", upper_value, price);
        return !input_useBBFilter || (price >= upper_value);
    }
};
//+------------------------------------------------------------------+
BB bb;
//+------------------------------------------------------------------+
