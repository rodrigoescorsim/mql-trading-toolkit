#include "BarController.mqh"

input string input_info_cb3 = "=== FILTRO RSI ==="; //-
input bool input_useRSIFilter = false;  // Ativar filtro RSI
input ENUM_TIMEFRAMES input_rsi_timeframe = PERIOD_M1; // RSI Timeframe 
input int input_rsi_period = 9;       // RSI Period
input int input_rsi_shift = 0;       // RSI Shift
input double input_rsi_upperLimit = 70;  // RSI limite superior
input double input_rsi_lowerLimit = 30;  // RSI limite inferior
//+------------------------------------------------------------------+
class RSI
{
    //+------------------------------------------------------------------+
public:
    BarController bar;
    int handle;
    double rsi_values[];
    double rsi_value;
    
    //+------------------------------------------------------------------+
    RSI() : bar(_Symbol, input_rsi_timeframe)
    {
        if (!input_useRSIFilter) return;
        
        handle = iRSI( _Symbol, input_rsi_timeframe, input_rsi_period, PRICE_CLOSE);
        ArraySetAsSeries(rsi_values,true);
        rsi_value = 0;
    }
    //+------------------------------------------------------------------+
    void update()
    {
        if (!input_useRSIFilter)
            return;
            
        if(bar.update() || input_rsi_shift == 0) {
            CopyBuffer(handle,0,0,2,rsi_values);
            
            rsi_value = rsi_values[input_rsi_shift];
            //PrintFormat("New RSI values: %.2f", rsi_value);
        }
    }
    //+------------------------------------------------------------------+
    bool rsiBuyAllowed()
    { 
        if(!input_useRSIFilter) return true;
        
        if(rsi_value <= input_rsi_lowerLimit) { 
          PrintFormat("RSI BUY ALLOWED: %.2f", rsi_value);
          return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool rsiSellAllowed()
    {
        if(!input_useRSIFilter) return true;
        
        if(rsi_value >= input_rsi_upperLimit) { 
          PrintFormat("RSI SELL ALLOWED: %.2f", rsi_value);
          return true;
        }
        return false;
    }
};
//+------------------------------------------------------------------+
RSI rsi;
//+------------------------------------------------------------------+
