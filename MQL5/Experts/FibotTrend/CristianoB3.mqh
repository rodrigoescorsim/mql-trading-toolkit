#include "BarController.mqh"

input string input_info_rsi = "=== CRISTIANO B3 ==="; //-
//input ENUM_TIMEFRAMES input_cb3_timeframe = PERIOD_M5; // CristianoB3 Timeframe 
input int input_cb3_risk = 1;         // param1 RISK
input int input_cb3_ssp = 8;          // param2 SSP
input int input_cb3_param3 = 1;       // param3
input bool input_cb3_param4 = true;   // param4
input int input_cb3_param5 = 2;       // param5
input bool input_cb3_param6 = false;  // param6
input bool input_cb3_param7 = false;  // param7
input string input_cb3_path = "cristianob3indicator"; // folder/nome_do_indicador na pasta Indicators
//+------------------------------------------------------------------+
class CristianoB3
{
    //+------------------------------------------------------------------+
public:
    BarController bar;
    int handle;
    double cb3_buy_values[];
    double cb3_sell_values[];
    double cb3_buy_value;
    double cb3_sell_value;
    
    //+------------------------------------------------------------------+
    CristianoB3() : bar(_Symbol, PERIOD_CURRENT)
    {

       handle = iCustom(_Symbol, PERIOD_CURRENT, input_cb3_path,
                      input_cb3_risk,
                      input_cb3_ssp,
                      input_cb3_param3,
                      input_cb3_param4,
                      input_cb3_param5,
                      input_cb3_param6,
                      input_cb3_param7);
        ArraySetAsSeries(cb3_buy_values,true);
        ArraySetAsSeries(cb3_sell_values,true);
        cb3_buy_value = 0;
        cb3_sell_value = 0;
    }
    //+------------------------------------------------------------------+
    bool update()
    {
        if(bar.update()) 
        {
            CopyBuffer(handle,0,0,2,cb3_sell_values);
            CopyBuffer(handle,1,0,2,cb3_buy_values);
            
            cb3_sell_value = cb3_sell_values[1];
            cb3_buy_value = cb3_buy_values[1];
            PrintFormat("New CB3 values - buy: %.5f - sell: %.5f", cb3_buy_value, cb3_sell_value);
            return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool cb3BuyAllowed()
    {  
        if(MathIsValidNumber(cb3_buy_value) && cb3_buy_value > 0) { 
          PrintFormat("CB3 BUY ALLOWED: %.5f", cb3_buy_value);
          return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool cb3SellAllowed()
    {
        if(MathIsValidNumber(cb3_sell_value) && cb3_sell_value > 0) { 
          PrintFormat("CB3 SELL ALLOWED: %.5f", cb3_sell_value);
          return true;
        }
        return false;
    }
};
//+------------------------------------------------------------------+
CristianoB3 cb3;
//+------------------------------------------------------------------+
