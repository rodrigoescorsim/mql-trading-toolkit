//+------------------------------------------------------------------+
//|                                                  EATradeTime.mqh |
//|                                                 Rodrigo Escorsim |
//|                                 https://www.rodrigo.escorsim.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Escorsim"
#property link      "https://www.rodrigo.escorsim.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
#include <mql4-lib/Collection/HashMap.mqh>
//+------------------------------------------------------------------+
//| Externs
//+------------------------------------------------------------------+
extern string  ForexPower1_Info           = "=======================================";
extern string  ForexPower2_Info           = "========+++== FOREX POWER ====+++======";
extern string  ForexPower3_Info           = "=======================================";
extern   bool  useForexPower              = false;
extern string  power_buy_limit           = "4.0,4.0,4.0,4.0,4.0,4.0,4.0";
extern string  power_sell_limit          = "6.0,6.0,6.0,6.0,6.0,6.0,6.0";
extern string  power_closeBuy_limit      = "3.0,3.0,3.0,3.0,3.0,3.0,3.0";
extern string  power_closeSell_limit     = "7.0,7.0,7.0,7.0,7.0,7.0,7.0";
extern SIGNAL_TYPE power_openSignalType  = AND;
extern SIGNAL_TYPE power_closeSignalType = OR;

string power_currencies[] = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD"};
string power_symbols[] = {"USDCHF", "GBPUSD", "EURUSD", "USDJPY", "USDCAD", "NZDUSD", "AUDUSD", "AUDNZD", "AUDCAD", "AUDCHF", "AUDJPY", "CHFJPY", "EURGBP", "EURAUD", "EURCHF", "EURJPY", "EURNZD", "EURCAD", "EURNZD", "EURCAD", "GBPCHF", "GBPAUD", "GBPCAD", "GBPJPY", "CADJPY", "NZDJPY", "GBPNZD", "CADCHF"};
   
   
//+------------------------------------------------------------------+
//| Class EAPower
//+------------------------------------------------------------------+
class EAPower : public EAIndicator
{
//+------------------------------------------------------------------+
private:
   //double power[8];
   HashMap<string, double> power;
   double buy_limit[];
   double sell_limit[];
   double closeBuy_limit[];
   double closeSell_limit[];
   string info_buyLimit, info_sellLimit, info_closeBuyLimit, info_closeSellLimit;
public:
//+------------------------------------------------------------------+
public:
   EAPower(EACore* _core, EATimeframes* _timeframes)
      : EAIndicator(_core, _timeframes, "TradeTime")
   {
      if(useForexPower)
      {
         openSignalType  = power_openSignalType;
         closeSignalType = power_closeSignalType;
         
         info_buyLimit = info_sellLimit = info_closeBuyLimit = info_closeSellLimit = "";
         int count;
         
         string buy_str[];
         count =  StringSplit(power_buy_limit,StringGetCharacter(",",0),buy_str);
         ArrayResize(buy_limit, count);
         info_buyLimit = "Buy(";
         for(int i=0; i < count; i++){
            buy_limit[i] = StringToDouble(buy_str[i]);
            info_buyLimit += DoubleToString(buy_limit[i], 2) + ",";
         }
         info_buyLimit += ") ";
         
         string sell_str[];
         count =  StringSplit(power_sell_limit,StringGetCharacter(",",0),sell_str);
         ArrayResize(sell_limit, count);
         info_sellLimit = "Sell(";
         for(int i=0; i < count; i++){
            sell_limit[i] = StringToDouble(sell_str[i]);
            info_sellLimit += DoubleToString(sell_limit[i], 2) + ",";
         }
         info_sellLimit += ") ";
         
         string closeBuy_str[];
         count =  StringSplit(power_closeBuy_limit,StringGetCharacter(",",0),closeBuy_str);
         ArrayResize(closeBuy_limit, count);
         info_closeBuyLimit = "CloseBuy(";
         for(int i=0; i < count; i++){
            closeBuy_limit[i] = StringToDouble(closeBuy_str[i]);
            info_closeBuyLimit += DoubleToString(closeBuy_limit[i], 2) + ",";
         }
         info_closeBuyLimit += ") ";
         
         string closeSell_str[];
         count =  StringSplit(power_closeSell_limit,StringGetCharacter(",",0),closeSell_str);
         ArrayResize(closeSell_limit, count);
         info_closeSellLimit = "CloseSell(";
         for(int i=0; i < count; i++){
            closeSell_limit[i] = StringToDouble(closeSell_str[i]);
            info_closeSellLimit += DoubleToString(closeSell_limit[i], 2) + ",";
         }
         info_closeSellLimit += ") ";
         
         power.set(power_currencies[0], 0.0);
         power.set(power_currencies[1], 0.0);
         power.set(power_currencies[2], 0.0);
         power.set(power_currencies[3], 0.0);
         power.set(power_currencies[4], 0.0);
         power.set(power_currencies[5], 0.0);
         power.set(power_currencies[6], 0.0);
         power.set(power_currencies[7], 0.0);
      }

   }
   //+------------------------------------------------------------------+
   ~EAPower()
   {
   }
   //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
   //+------------------------------------------------------------------+
   virtual void UpdateAllData()
   {
     if(!timeframes.IsUpdatedCurrentTF()) return;
     
      power.setIfExist(power_currencies[0], currency_strength(power_currencies[0]));
      power.setIfExist(power_currencies[1], currency_strength(power_currencies[1]));
      power.setIfExist(power_currencies[2], currency_strength(power_currencies[2]));
      power.setIfExist(power_currencies[3], currency_strength(power_currencies[3]));
      power.setIfExist(power_currencies[4], currency_strength(power_currencies[4]));
      power.setIfExist(power_currencies[5], currency_strength(power_currencies[5]));
      power.setIfExist(power_currencies[6], currency_strength(power_currencies[6]));
      power.setIfExist(power_currencies[7], currency_strength(power_currencies[7]));

   }
   //+------------------------------------------------------------------+
   void UpdateData(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   void UpdateSignalBySymbol(int iSym){
      if(!timeframes.IsUpdatedCurrentTF()) return;
      
      string rawSymbol = core.getRawSymbol(iSym);
      string currency1 = StringSubstr(rawSymbol, 0,3);
      string currency2 = StringSubstr(rawSymbol, 3,3);
      
      if(power.contains(currency1) && power.contains(currency2)) {
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            
            if(power[currency1] >= buy_limit[iSet] && power[currency2] < sell_limit[iSet]) buySignal[iSym][iSet] = true;
            else buySignal[iSym][iSet] = false;
            
            if(power[currency2] >= buy_limit[iSet] && power[currency1] < sell_limit[iSet]) sellSignal[iSym][iSet] = true;
            else sellSignal[iSym][iSet] = false;
            
            if(power[currency1] < closeBuy_limit[iSet] || power[currency2] > closeSell_limit[iSet]) closeBuy[iSym][iSet] = true;
            else closeBuy[iSym][iSet] = false;
            
            if(power[currency2] < closeSell_limit[iSet] || power[currency1] > closeSell_limit[iSet]) closeSell[iSym][iSet] = true;
            else closeSell[iSym][iSet] = false;

         }
      }
      else {
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = false;
            sellSignal[iSym][iSet] = false;
            closeBuy[iSym][iSet] = true;
            closeSell[iSym][iSet] = true;
         }
      }
   }
   //+------------------------------------------------------------------+
   void UpdateSignal(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      info += "POWER: ";
      foreachm(string,_currency,double,_value,power){
         info += _currency + ":" + DoubleToString(_value,2) + " ";
      }
      info += NL + "POWER Open Limit: " + info_buyLimit + info_sellLimit;
      info += NL + "POWER Close Limit: " + info_closeBuyLimit + info_closeSellLimit;
      return info;
   }
   //+------------------------------------------------------------------+
   double currency_strength(string currency) {
      int _power_10;
      string _symbol, _rawSymbol;
      double diff_hilo;
      double _power_100;
      double _power_acumulated = 0;
      int l_count_44 = 0;
      for (int l_index_48 = 0; l_index_48 < ArraySize(power_symbols); l_index_48++) {
         _power_10 = 0;
         _rawSymbol = power_symbols[l_index_48];
         _symbol = symbol_prefix + _rawSymbol + symbol_suffix;
         if (currency == StringSubstr(_rawSymbol, 0, 3) || currency == StringSubstr(_rawSymbol, 3, 3)) {
            _symbol = _symbol;
            diff_hilo = (MarketInfo(_symbol, MODE_HIGH) - MarketInfo(_symbol, MODE_LOW)) * MarketInfo(_symbol, MODE_POINT);
            if (diff_hilo != 0.0) {
               _power_100 = 100.0 * ((MarketInfo(_symbol, MODE_BID) - MarketInfo(_symbol, MODE_LOW)) / diff_hilo * MarketInfo(_symbol, MODE_POINT));
               if (_power_100 > 3.0) _power_10 = 1;
               if (_power_100 > 10.0) _power_10 = 2;
               if (_power_100 > 25.0) _power_10 = 3;
               if (_power_100 > 40.0) _power_10 = 4;
               if (_power_100 > 50.0) _power_10 = 5;
               if (_power_100 > 60.0) _power_10 = 6;
               if (_power_100 > 75.0) _power_10 = 7;
               if (_power_100 > 90.0) _power_10 = 8;
               if (_power_100 > 97.0) _power_10 = 9;
               l_count_44++;
               if (currency == StringSubstr(_rawSymbol, 3, 3)) _power_10 = 9 - _power_10;
               _power_acumulated += _power_10;
            }
         }
      }
      _power_acumulated /= l_count_44;
      return (_power_acumulated);
   }
};
//+------------------------------------------------------------------+
