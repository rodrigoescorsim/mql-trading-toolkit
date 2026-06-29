//+------------------------------------------------------------------+
//|                                                    EABands.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
extern string  bands1_info                 = "===========================================";
extern string  bands2_info                 = "========== Bollinger Bands SETUP ==========";
extern string  bands3_info                 = "===========================================";
extern bool    useBands                    = false;
extern int     bands_period                = 20;
extern int     bands_deviation             = 2;
extern int     bands_shift                 = 0;
extern ENUM_APPLIED_PRICE  bands_applied_price = PRICE_CLOSE;
extern bool    bands_open_break_bands      = true;
extern double  bands_break_max_size        = 2.5;
extern int     bands_break_candles         = 40;
extern bool    bands_close_center          = true;
extern bool    bands_close_size_slope      = false;
extern bool    bands_use_slope             = false;
extern bool    use_filter_by_slope         = false;
extern SIGNAL_TYPE bands_openSignalType    = AND;
extern SIGNAL_TYPE bands_closeSignalType   = NOT;
//+------------------------------------------------------------------+

class EABands : public EAIndicator
{
  public:
   double high[][TF_COUNT][2];
   double low[][TF_COUNT][2];
   double center[][TF_COUNT][2];
   double highDistance[][TF_COUNT];
   double lowDistance[][TF_COUNT];
   double centerDistance[][TF_COUNT];
   double highSlope[][TF_COUNT];
   double lowSlope[][TF_COUNT];
   double centerSlope[][TF_COUNT];
   double bandsSize[][TF_COUNT][2], bandsSizeSlope[][TF_COUNT];
  private:
  //+------------------------------------------------------------------+
  public:
  EABands(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "EABands")
  {
     data_depth = 2;
     openSignalType = bands_openSignalType;
     closeSignalType = bands_closeSignalType;
     ArrayResize(high, core.getSymbolCount()); ArrayInitialize(high, 0);
     ArrayResize(low, core.getSymbolCount()); ArrayInitialize(low, 0);
     ArrayResize(center, core.getSymbolCount()); ArrayInitialize(center, 0);
     ArrayResize(highDistance, core.getSymbolCount()); ArrayInitialize(highDistance, 0);
     ArrayResize(lowDistance, core.getSymbolCount()); ArrayInitialize(lowDistance, 0);
     ArrayResize(centerDistance, core.getSymbolCount()); ArrayInitialize(centerDistance, 0);
     ArrayResize(highSlope, core.getSymbolCount()); ArrayInitialize(highSlope, 0);
     ArrayResize(lowSlope, core.getSymbolCount()); ArrayInitialize(lowSlope, 0);
     ArrayResize(centerSlope, core.getSymbolCount()); ArrayInitialize(centerSlope, 0);
     ArrayResize(bandsSize, core.getSymbolCount()); ArrayInitialize(bandsSize, 0);
     ArrayResize(bandsSizeSlope, core.getSymbolCount()); ArrayInitialize(bandsSizeSlope, 0);
  }
     //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet) override{
      DrawChannel("bandsCenter_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), center[iSym][iSet][0], clrGold);
      DrawChannel("bandsHigh_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), high[iSym][iSet][0], clrYellow);
      DrawChannel("bandsLow_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), low[iSym][iSet][0], clrYellow);
   }
  //+------------------------------------------------------------------
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
    string centerDistanceInfo="", lowDistanceInfo="", highDistanceInfo="";
    string centerSlopeInfo="", lowSlopeInfo="", highSlopeInfo="";
    string bandsSizeInfo="", sizeSlopeInfo="";
    int digits = (int) MarketInfo(core.getSymbol(iSym),MODE_DIGITS);
    
    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
        closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
        closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");
       
        centerDistanceInfo += StringConcatenate(DoubleToString(centerDistance[iSym][iSet],2),",");
        highDistanceInfo += StringConcatenate(DoubleToString(highDistance[iSym][iSet],2),",");
        lowDistanceInfo += StringConcatenate(DoubleToString(lowDistance[iSym][iSet],2),",");
        
        centerSlopeInfo += StringConcatenate(DoubleToString(centerSlope[iSym][iSet],2),",");
        highSlopeInfo += StringConcatenate(DoubleToString(highSlope[iSym][iSet],2),",");
        lowSlopeInfo += StringConcatenate(DoubleToString(lowSlope[iSym][iSet],2),",");
        
        bandsSizeInfo += StringConcatenate(bandsSize[iSym][iSet][0],",");
        sizeSlopeInfo += StringConcatenate(bandsSizeSlope[iSym][iSet],",");
      }
    }
    if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
    if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);
    if(StringLen(closeBuyInfo) > 0) closeBuyInfo = StringSubstr(closeBuyInfo,0,StringLen(closeBuyInfo)-1);
    if(StringLen(closeSellInfo) > 0) closeSellInfo = StringSubstr(closeSellInfo,0,StringLen(closeSellInfo)-1);
    if(StringLen(centerDistanceInfo) > 0) centerDistanceInfo = StringSubstr(centerDistanceInfo,0,StringLen(centerDistanceInfo)-1);
    if(StringLen(highDistanceInfo) > 0) highDistanceInfo = StringSubstr(highDistanceInfo,0,StringLen(highDistanceInfo)-1);
    if(StringLen(lowDistanceInfo) > 0) lowDistanceInfo = StringSubstr(lowDistanceInfo,0,StringLen(lowDistanceInfo)-1);
    if(StringLen(centerSlopeInfo) > 0) centerSlopeInfo = StringSubstr(centerSlopeInfo,0,StringLen(centerSlopeInfo)-1);
    if(StringLen(highSlopeInfo) > 0) highSlopeInfo = StringSubstr(highSlopeInfo,0,StringLen(highSlopeInfo)-1);
    if(StringLen(lowSlopeInfo) > 0) lowSlopeInfo = StringSubstr(lowSlopeInfo,0,StringLen(lowSlopeInfo)-1);
    if(StringLen(bandsSizeInfo) > 0) bandsSizeInfo = StringSubstr(bandsSizeInfo,0,StringLen(bandsSizeInfo)-1);
    if(StringLen(sizeSlopeInfo) > 0) sizeSlopeInfo = StringSubstr(sizeSlopeInfo,0,StringLen(sizeSlopeInfo)-1);

    return StringConcatenate(name,": Buy(",buyInfo,"),CloseBuy:(",closeBuyInfo,"),Sell(",sellInfo,"),CloseSell(",closeSellInfo,")",NL,
                             name,": LowDist(",lowDistanceInfo,"),centerDist(",centerDistanceInfo,"), highDist(",highDistanceInfo,")", NL,
                             name,": LowSlope(",lowSlopeInfo,"),centerSlope(",centerSlopeInfo,"), highSlope(",highSlopeInfo,")", NL,
                             name,": BandsSize(",bandsSizeInfo,"), SizeSlope(",sizeSlopeInfo,")");
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
     string symbol = core.getSymbol(iSym);
     int setup = timeframes.Value(iSet);
     
     double atr = timeframes.getAtrSlow(iSym,iSet);
     double atr_slope = atr * 0.1;
     if(atr == 0){ 
       Print( StringConcatenate("WARNING ATR == 0 EABBands::UpdateData - ",symbol," ",timeframes.PosToStr(iSet)) );
       return;
     }
     double close = iClose(symbol, setup, 1);
     double point = MarketInfo(symbol, MODE_POINT);
     if(point == 0){ 
       Print(StringConcatenate("WARNING point == 0 EACoG::UpdateSignal - " ,symbol,timeframes.ValueToStr(iSet)));
       return;
     }
    
     if(firstUpdate){
        high[iSym][iSet][1] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_UPPER, shift_begin+1);
        low[iSym][iSet][1] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_LOWER, shift_begin+1);
        center[iSym][iSet][1] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_MAIN, shift_begin+1);
        bandsSize[iSym][iSet][1] = (high[iSym][iSet][1] - low[iSym][iSet][1]) / timeframes.getAtrSlow(iSym,iSet);
        firstUpdate = false;
      }
      else{
        high[iSym][iSet][1] = high[iSym][iSet][0];
        low[iSym][iSet][1] = low[iSym][iSet][0];
        center[iSym][iSet][1] = center[iSym][iSet][0];
        bandsSize[iSym][iSet][1] = bandsSize[iSym][iSet][0];
      }
      
      high[iSym][iSet][0] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_UPPER, shift_begin);
      low[iSym][iSet][0] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_LOWER, shift_begin);
      center[iSym][iSet][0] = iBands(symbol, setup,bands_period, bands_deviation, bands_shift, bands_applied_price, MODE_MAIN, shift_begin);
      bandsSize[iSym][iSet][0] = (high[iSym][iSet][0] - low[iSym][iSet][0]) / timeframes.getAtrSlow(iSym,iSet);
      
      centerDistance[iSym][iSet] = (int)((close - center[iSym][iSet][0]) / point);
      highDistance[iSym][iSet] = (int)((high[iSym][iSet][0] - close) / point);
      lowDistance[iSym][iSet] = (int)((close - low[iSym][iSet][0]) / point);
     
      highSlope[iSym][iSet] = (high[iSym][iSet][0] - high[iSym][iSet][1]) / atr_slope;
      lowSlope[iSym][iSet] = (low[iSym][iSet][0] - low[iSym][iSet][1]) / atr_slope;;
      centerSlope[iSym][iSet] = (center[iSym][iSet][0] - center[iSym][iSet][1]) / atr_slope;;
      bandsSizeSlope[iSym][iSet] = (bandsSize[iSym][iSet][0] - bandsSize[iSym][iSet][1]) / (atr*10);
  }
  //+------------------------------------------------------------------+
  /*void UpdateSignalBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        UpdateSignal(iSym, iSet);
      }
    }
  }*/
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
    
    string symbol = core.getSymbol(iSym);
    int setup = timeframes.Value(iSet);
    double close = iClose(symbol, setup, 1);
    
    if(bands_open_break_bands){
      if(bandsSizeSlope[iSym][iSet] > 0 && bandsSize[iSym][iSet][1] <= bands_break_max_size){
         if(close > high[iSym][iSet][1]){
            if(bands_break_candles > 0){
               int high_pos = iHighest(symbol, setup, MODE_CLOSE, bands_break_candles, shift_begin+1);
               if(close > iClose(symbol, setup, high_pos)) {
                  buySignal[iSym][iSet] = true;
               }
            }
            else{
               buySignal[iSym][iSet] = true;
            }
         }
         else if(close < low[iSym][iSet][1]){
            if(bands_break_candles > 0){
               int low_pos = iLowest(symbol, setup, MODE_CLOSE, bands_break_candles, shift_begin+1);
               if(close < iClose(symbol, setup, low_pos)) {
                  sellSignal[iSym][iSet] = true;
               }
            }
            else{
               sellSignal[iSym][iSet] = true;
            }
         }
      }
    }
    if(bands_close_center){
      double open = iOpen(symbol, setup, 1);
      if(open <= center[iSym][iSet][0] && close > center[iSym][iSet][0]){
         closeSell[iSym][iSet] = true;
      }
      else if(open >= center[iSym][iSet][0] && close < center[iSym][iSet][0]){
         closeBuy[iSym][iSet] = true;
      }
    }
    if(bands_close_size_slope && bandsSizeSlope[iSym][iSet] < 0){
      closeBuy[iSym][iSet] = closeSell[iSym][iSet] = true;
    }
    if(use_filter_by_slope && bandsSizeSlope[iSym][iSet] > 0){
      buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    }
    else{
      buySignal[iSym][iSet] = sellSignal[iSym][iSet] = true;
    }
     
  }
  //+------------------------------------------------------------------+
   double B(double x_, double y_, double x0_, double y0_){ //encontra e retorna o coeficiente linear (o valor de 
   	return ((y_-y0_)*((-x0_/(x_-x0_))))+y0_;
   }
  //+------------------------------------------------------------------+
   double A(double x_, double y_, double x0_, double y0_){ //encontra e retorna o coeficiente angular (o valor de A)
   	return (y_-y0_)/(x_-x0_);
   }
  //+------------------------------------------------------------------+
};