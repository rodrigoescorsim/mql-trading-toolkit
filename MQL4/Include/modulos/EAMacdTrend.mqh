//+------------------------------------------------------------------+
//|                                                    EAMacd.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
extern string  macd_trend_info1        = "======================================";
extern string  macd_trend_info2        = "============= MACD SETUP =============";
extern string  macd_trend_info3        = "======================================";
extern bool    useMACDTrend            = true;
extern int     macd_sma_period         = 9;
extern int     macd_fast_period        = 12;
extern int     macd_slow_period        = 26;
extern int     macd_shift              = 1;
extern SIGNAL_TYPE macd_openSignalType  = AND;
extern SIGNAL_TYPE macd_closeSignalType = OR;
//+------------------------------------------------------------------+
class EAMacdTrend : public EAIndicator
{
  private:
   double macd_value[][TF_COUNT][2];
   double macd_signal[][TF_COUNT][2];
  //+------------------------------------------------------------------+
  public:
  EAMacdTrend(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "EAMacdTrend")
  {
     openSignalType  = macd_openSignalType;
     closeSignalType = macd_closeSignalType;
     data_depth = 2;
     shift_begin = macd_shift;
     ArrayResize(macd_value, core.getSymbolCount());
     ArrayResize(macd_signal, core.getSymbolCount());
     ArrayInitialize(macd_value, 0);
     ArrayInitialize(macd_signal, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
      string _symbol = core.getSymbol(iSym); 
      int _tf = timeframes.Value(iSet);
      if(firstUpdate){
        macd_value[iSym][iSet][1] = iMACD(_symbol, _tf, macd_fast_period, macd_slow_period, macd_sma_period, PRICE_CLOSE, MODE_MAIN, shift_begin+1);
        firstUpdate = false;
      }
      else{
        macd_value[iSym][iSet][1] = macd_value[iSym][iSet][0];
      }
      macd_value[iSym][iSet][0] = iMACD(_symbol, _tf, macd_fast_period, macd_slow_period, macd_sma_period, PRICE_CLOSE, MODE_MAIN, shift_begin);
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(macd_value[iSym][iSet][0] > 0) {
       buySignal[iSym][iSet] = true;
       closeBuy[iSym][iSet] = false;
       
       sellSignal[iSym][iSet] = false;
       closeSell[iSym][iSet] = true;
    }
    else if(macd_value[iSym][iSet][0] < 0) {
       buySignal[iSym][iSet] = false;
       closeBuy[iSym][iSet] = true;
    
       sellSignal[iSym][iSet] = true;
       closeSell[iSym][iSet] = false; 
    }
  }
     //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      info += "MACD: ";
      
      for(int iSet=0; iSet < TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(timeframes.PosToStr(iSet), "(",macd_value[iSym][iSet][0],") ");
         }
      }
      info += NL + "MACD: BUY(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(buySignal[iSym][iSet], " ");
         }
      }
      info += ") SELL(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(sellSignal[iSym][iSet], " ");
         }
      }
      info += ") CloseBuy(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(closeBuy[iSym][iSet], " ");
         }
      }
      info += ") CloseSell(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(closeSell[iSym][iSet], " ");
         }
      }
      info += ")";
      return info;
   }
};
//+------------------------------------------------------------------+
