//+------------------------------------------------------------------+
//|                                                    EAInd_PVA.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
extern string  candles1_info              = "======================================";
extern string  candles2_info              = "=========== CANDLES SETUP ============";
extern string  candles3_info              = "======================================";
extern bool    useCandles                 = false;
extern int     candlesLevelToOpen         = 1;
extern int     candlesLevelToClose        = 1;
extern bool    candle_tickUpdate          = false;
extern SIGNAL_TYPE candles_openSignalType  = AND;
extern SIGNAL_TYPE candles_closeSignalType = NOT;
//+------------------------------------------------------------------+
class EACandles : public EAIndicator
{
  private:
  double candlesOpenHigh[][TF_COUNT];
  double candlesOpenLow[][TF_COUNT];
  double candlesCloseHigh[][TF_COUNT];
  double candlesCloseLow[][TF_COUNT];
  int lastCandleShift;
  //+------------------------------------------------------------------+
  public:
  EACandles(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "Candles")
  {
    openSignalType  = candles_openSignalType;
    closeSignalType = candles_closeSignalType;
    data_depth = 1;
    tickUpdate = candle_tickUpdate;
    if(candle_tickUpdate){
      lastCandleShift = 0;
      shift_begin = 1;
    }
    else{
      lastCandleShift = 1;
      shift_begin = 2;
    }

    ArrayResize(candlesOpenHigh, core.getSymbolCount());
    ArrayResize(candlesOpenLow, core.getSymbolCount());
    ArrayResize(candlesCloseHigh, core.getSymbolCount());
    ArrayResize(candlesCloseLow, core.getSymbolCount());
    ArrayInitialize(candlesOpenHigh, 0);
    ArrayInitialize(candlesOpenLow, 0);
    ArrayInitialize(candlesCloseHigh, 0);
    ArrayInitialize(candlesCloseLow, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
    
    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
        closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
        closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");    
      }
    }
    if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
    if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);
    if(StringLen(closeBuyInfo) > 0) closeBuyInfo = StringSubstr(closeBuyInfo,0,StringLen(closeBuyInfo)-1);
    if(StringLen(closeSellInfo) > 0) closeSellInfo = StringSubstr(closeSellInfo,0,StringLen(closeSellInfo)-1);

    return StringConcatenate(name,": Buy(",buyInfo,"),CloseBuy:(",closeBuyInfo,"),Sell(",sellInfo,"),CloseSell(",closeSellInfo,")");
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
  
     if(openSignalType != NOT)
     {
       if(candlesLevelToOpen == 1){
         candlesOpenHigh[iSym][iSet] = iHigh(core.getSymbol(iSym),timeframes.Value(iSet),shift_begin);
         candlesOpenLow[iSym][iSet] = iLow(core.getSymbol(iSym),timeframes.Value(iSet),shift_begin);
       }
       else{
         candlesOpenHigh[iSym][iSet] = iHighest(core.getSymbol(iSym),timeframes.Value(iSet),MODE_CLOSE,candlesLevelToOpen, shift_begin);
         candlesOpenLow[iSym][iSet] = iLowest(core.getSymbol(iSym),timeframes.Value(iSet),MODE_CLOSE,candlesLevelToOpen, shift_begin);
       } 
     }
     if(closeSignalType != NOT)
     {
      if(candlesLevelToClose == 1){
         candlesCloseHigh[iSym][iSet] = iHigh(core.getSymbol(iSym),timeframes.Value(iSet),shift_begin);
         candlesCloseLow[iSym][iSet] = iLow(core.getSymbol(iSym),timeframes.Value(iSet),shift_begin);
       }
       else{
         candlesCloseHigh[iSym][iSet] = iHighest(core.getSymbol(iSym),timeframes.Value(iSet),MODE_CLOSE,candlesLevelToClose, shift_begin);
         candlesCloseLow[iSym][iSet] = iLowest(core.getSymbol(iSym),timeframes.Value(iSet),MODE_CLOSE,candlesLevelToClose, shift_begin);
       }
     }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
     if(openSignalType != NOT)
     {
       buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
       
       if(iClose(core.getSymbol(iSym),timeframes.Value(iSet),lastCandleShift) > candlesOpenHigh[iSym][iSet]){
         buySignal[iSym][iSet]  = true;
       }
       
       if(iClose(core.getSymbol(iSym),timeframes.Value(iSet),lastCandleShift) < candlesOpenLow[iSym][iSet]){
         sellSignal[iSym][iSet] = true;
       }
     }

     if(closeSignalType != NOT)
     {
       closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
       
       if(iClose(core.getSymbol(iSym),timeframes.Value(iSet),lastCandleShift) > candlesCloseHigh[iSym][iSet]){
         closeSell[iSym][iSet]  = true;
       }
       
       if(iClose(core.getSymbol(iSym),timeframes.Value(iSet),lastCandleShift) < candlesCloseLow[iSym][iSet]){
         closeBuy[iSym][iSet] = true;
       }
     }
  }
};
//+------------------------------------------------------------------+
