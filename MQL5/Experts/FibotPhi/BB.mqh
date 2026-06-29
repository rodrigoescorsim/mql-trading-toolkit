#include "BarController.mqh"

#ifndef ESCONDER_BANDS input #endif string input_info_bb = "=== FILTRO BANDAS DE BOLLINGER ==="; //-
#ifndef ESCONDER_BANDS input #endif bool input_useBBFilter = true;  // Ativar filtro Bandas de Bollinger
#ifndef ESCONDER_BANDS input #endif ENUM_TIMEFRAMES input_bb_timeframe = PERIOD_M1; // BB Timeframe 
#ifndef ESCONDER_BANDS input #endif int input_bb_period = 20;       // BB Period
#ifndef ESCONDER_BANDS input #endif double input_bb_deviation = 2.0;       // BB Period
#ifndef ESCONDER_BANDS input #endif int input_bb_shift = 0;       // BB Shift
#ifndef ESCONDER_BANDS input #endif bool input_useRompimento = true;  // Operar rompimento
/*#ifndef ESCONDER_BANDS input #endif*/ bool input_useClosing = false;  // operar fechamento de banda
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
            CopyBuffer(handle,1,0,3,upper_values);
            CopyBuffer(handle,2,0,3,lower_values);
            
            //base_value = base_values[0];
            upper_value = upper_values[0];
            lower_value = lower_values[0];
            //PrintFormat("New BB values - Upper: %.2f Lower: %.2f", upper_value, lower_value);
        }
    }
    //+------------------------------------------------------------------+
    bool checkBuyClosing() {
        if(input_useClosing) {
            PrintFormat("BB CLOSING values - [0]: %.2f [1]: %.2f", (upper_values[0]-lower_values[0]), (upper_values[1]-lower_values[1]));
            return (upper_values[1]-lower_values[1]) <= (upper_values[2]-lower_values[2]);
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool checkSellClosing() {
        if(input_useClosing) {
            PrintFormat("BB CLOSING values - [0]: %.2f [1]: %.2f", (upper_values[0]-lower_values[0]), (upper_values[1]-lower_values[1]));
            return (upper_values[1]-lower_values[1]) <= (upper_values[2]-lower_values[2]);
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool checkBuyRompimento(double price) {
        if(input_useRompimento)
            return (price <= lower_value);
        return false;
    }
    //+------------------------------------------------------------------+
    bool checkSellRompimento(double price) {
        if(input_useRompimento)
            return (price >= upper_value);
        return false;
    }
    //+------------------------------------------------------------------+
    bool bbBuyAllowed(double price)
    {
        if(price <= lower_value) PrintFormat("BB BUY ALLOWED - Lower: %.2f - Price: %.2f", lower_value, price);
        
        return !input_useBBFilter || (checkBuyRompimento(price) || checkBuyClosing());
    }
    //+------------------------------------------------------------------+
    bool bbSellAllowed(double price)
    {
        if(price >= upper_value) PrintFormat("BB SELL ALLOWED - Upper: %.2f - Price: %.2f", upper_value, price);
        return !input_useBBFilter || (checkSellRompimento(price) || checkSellClosing());
    }
};
//+------------------------------------------------------------------+
BB bb;
//+------------------------------------------------------------------+
