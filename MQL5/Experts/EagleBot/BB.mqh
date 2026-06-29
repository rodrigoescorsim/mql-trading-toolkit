#include "BarController.mqh"

input string input_info_bb = "=== BANDAS DE BOLLINGER ==="; //-
input ENUM_TIMEFRAMES input_bb_timeframe = PERIOD_M2; // Bands Timeframe 
input int input_bb_period = 20;         // Bands Period
input double input_bb_deviation = 2.0;  // Bands Deviation

//+------------------------------------------------------------------+
class BB
{
    //+------------------------------------------------------------------+
public:
    int handle;
    double base_values[];
    double upper_values[];
    double lower_values[];
    double base_value;
    double upper_value;
    double lower_value;
    bool buy_enable, sell_enable;
    double buy_stop, sell_stop;
    double buy_open, sell_open;
    
    //+------------------------------------------------------------------+
    BB()
    {
        handle = iBands( _Symbol, input_bb_timeframe, input_bb_period, 1, input_bb_deviation, PRICE_CLOSE);
        ArraySetAsSeries(base_values,true);
        ArraySetAsSeries(upper_values,true);
        ArraySetAsSeries(lower_values,true);
        base_value = upper_value = lower_value = 0;
        buy_enable = sell_enable = false;
        buy_stop = sell_stop = 0.0;
        buy_open = sell_open = 0.0;
    }
    //+------------------------------------------------------------------+
    void update()
    { 
        CopyBuffer(handle,0,0,2,base_values);
        CopyBuffer(handle,1,0,2,upper_values);
        CopyBuffer(handle,2,0,2,lower_values);
        
        base_value = base_values[0];
        upper_value = upper_values[0];
        lower_value = lower_values[0];
        PrintFormat("New BB values [0]- Base: %.2f - Upper: %.2f - Lower: %.2f", base_values[0], upper_values[0], lower_values[0]);
        PrintFormat("New BB values [1]- Base: %.2f - Upper: %.2f - Lower: %.2f", base_values[1], upper_values[1], lower_values[1]);
        
        double close_s1 = iClose(_Symbol, input_bb_timeframe, 1);
        double close_s2 = iClose(_Symbol, input_bb_timeframe, 2);
        if(!buy_enable && (close_s1 <= lower_values[0] || close_s2 <= lower_values[1])) {
            buy_enable = true;
            bb.buy_open = 0;
        }
        if(!sell_enable && (close_s1 >= upper_values[0] || close_s2 >= upper_values[1])) {
            sell_enable = true;
            bb.sell_open = 0;
        }
        
        if(buy_enable) {
            double high_s1 = iHigh(_Symbol, input_bb_timeframe, 1);
            double high_s2 = iHigh(_Symbol, input_bb_timeframe, 2);
            double high = MathMin(high_s1, high_s2) + input_open_gap_points;
            if(buy_open == 0 || high < buy_open) {
               buy_open = high; 
            }
        }
        if(sell_enable) {
            double low_s1 = iLow(_Symbol, input_bb_timeframe, 1);
            double low_s2 = iLow(_Symbol, input_bb_timeframe, 2);
            double low = MathMax(low_s1, low_s2) - input_open_gap_points;
            if(sell_open == 0 || low > sell_open) {
               sell_open = low; 
            }
        }
        
    }
    //+------------------------------------------------------------------+
 /*   bool bbBuyAllowed(double price)
    {
        double close_s1 = iClose(_Symbol, input_bb_timeframe, input_bb_shift);
        double close_s2 = iClose(_Symbol, input_bb_timeframe, input_bb_shift+1);
        if(close_s2 <= lower_values[1] && close_s1 >= lower_values[0]) {
            return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool bbSellAllowed(double price)
    {
        double close_s1 = iClose(_Symbol, input_bb_timeframe, input_bb_shift);
        double close_s2 = iClose(_Symbol, input_bb_timeframe, input_bb_shift+1);
        if(close_s2 >= upper_values[1] && close_s1 <= upper_values[0]) {
            return true;
        }
        return false;
    }*/
};
//+------------------------------------------------------------------+
BB bb;
//+------------------------------------------------------------------+
