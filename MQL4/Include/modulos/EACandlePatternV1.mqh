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
enum CANDLE_PATTERN_TYPE{ CP_NONE, CP_OPEN, CP_CLOSE, CP_OPEN_AND_CLOSE };
//+------------------------------------------------------------------+
extern string  candlePattern1_info            = "==========================================";
extern string  candlePattern2_info            = "========== CANDLE PATTERN SETUP ==========";
extern string  candlePattern3_info            = "==========================================";
extern bool    useCandlePattern               = false;
extern CANDLE_PATTERN_TYPE engulfPatternType  = CP_OPEN_AND_CLOSE;
extern double  engulfMinFill                  = 0.9;
extern double  engulfMaxFill                  = 1.5;
extern double  engulfAtrMin                   = 1.0;
extern double  engulfAtrMax                   = 2.5;
extern CANDLE_PATTERN_TYPE pinbarPatternType  = CP_OPEN_AND_CLOSE;
extern double  pinbarMinShadow                = 2; // pinbar tem que ser X maior que o corpo e que a sombra oposta
extern double  pinbarAtrMin                   = 1.0;
extern double  pinbarAtrMax                   = 2.5;
extern double  candlePatternRequired          = 0.0;
extern SIGNAL_TYPE candle_openSignalType      = AND;
extern SIGNAL_TYPE candle_closeSignalType     = OR;
//+------------------------------------------------------------------+
class EACandlePattern : public EAIndicator
{
  private:
  bool engulfBuyPattern[][TF_COUNT][3];
  bool engulfSellPattern[][TF_COUNT][3];
  bool pinbarBuyPattern[][TF_COUNT][3];
  bool pinbarSellPattern[][TF_COUNT][3];
  bool buyPattern[][TF_COUNT][3];
  bool sellPattern[][TF_COUNT][3];
  bool useEngulf, usePinbar, useOpen, useClose;
  //+------------------------------------------------------------------+
  public:
  EACandlePattern(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "CPattern")
  {
    openSignalType  = candle_openSignalType;
    closeSignalType = candle_closeSignalType;
    data_depth = 3;
    ArrayResize(engulfBuyPattern, core.getSymbolCount());
    ArrayResize(engulfSellPattern, core.getSymbolCount());
    ArrayResize(pinbarBuyPattern, core.getSymbolCount());
    ArrayResize(pinbarSellPattern, core.getSymbolCount());
    ArrayResize(buyPattern, core.getSymbolCount());
    ArrayResize(sellPattern, core.getSymbolCount());
    ArrayInitialize(engulfBuyPattern, false);
    ArrayInitialize(engulfSellPattern, false);
    ArrayInitialize(pinbarBuyPattern, false);
    ArrayInitialize(pinbarSellPattern, false);
    ArrayInitialize(buyPattern, false);
    ArrayInitialize(sellPattern, false);

    useEngulf = (engulfPatternType != CP_NONE) ? true : false;
    usePinbar = (pinbarPatternType != CP_NONE) ? true : false;
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  bool IsPatternOpen(CANDLE_PATTERN_TYPE type){
    if(type == CP_OPEN || type == CP_OPEN_AND_CLOSE)
      return true;
    return false;
  }
  //+------------------------------------------------------------------+
  bool IsPatternClose(CANDLE_PATTERN_TYPE type){
    if(type == CP_CLOSE || type == CP_OPEN_AND_CLOSE)
      return true;
    return false;
  }
  //+------------------------------------------------------------------+
  bool IsOpen(){
    return IsPatternOpen(engulfPatternType) || IsPatternOpen(pinbarPatternType);
  }
  //+------------------------------------------------------------------+
  bool IsClose(){
    return IsPatternClose(engulfPatternType) || IsPatternClose(pinbarPatternType);
  }
  //+------------------------------------------------------------------+
  // string GetInfoBySymbol(int iSym)
  // {
  //   return "";
  // }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
    int shift = shift_begin;
    if(firstUpdate){
      for(int i=0; i<data_depth; i++)
      {
        UpdateDataByPos(iSym, iSet, i);
      }
      firstUpdate = false;
    }
    else{
      for(int i=0; i<data_depth; i++, shift++)
      {
        if(shift_begin == shift)
          continue;
        engulfBuyPattern[iSym][iSet][i] = engulfBuyPattern[iSym][iSet][i-1];
        engulfSellPattern[iSym][iSet][i] = engulfSellPattern[iSym][iSet][i-1];
        pinbarBuyPattern[iSym][iSet][i] = pinbarBuyPattern[iSym][iSet][i-1];
        pinbarSellPattern[iSym][iSet][i] = pinbarSellPattern[iSym][iSet][i-1];
      }
      UpdateDataByPos(iSym, iSet, shift_begin);
    }
  }

  void UpdateDataByPos(int iSym, int iSet, int pos)
  {
     int shift = shift_begin + pos;
     string symbol = core.getSymbol(iSym);
     int timeframe = timeframes.Value(iSet);
     double atr = timeframes.getAtrSlow(iSym,iSet);
     if(atr == 0){
      Print("EACandlePattern::UpdateDataByPos atr == 0");
      return;
     }
     buyPattern[iSym][iSet][pos] = false;
     sellPattern[iSym][iSet][pos] = false;
     double value;

     double c2 = iClose(symbol, timeframe, shift+1);
     double o2 = iOpen(symbol, timeframe, shift+1);
     double c1 = iClose(symbol, timeframe, shift);
     double o1 = iOpen(symbol, timeframe, shift);
     double l1 = iLow(symbol, timeframe, shift);
     double h1 = iHigh(symbol, timeframe, shift);

     double body_s1 = c1 - o1;
     double body_s2 = c2 - o2;

     /********* Calculating PINBAR *********/
     if(usePinbar)
     {
       pinbarSellPattern[iSym][iSet][pos] = pinbarBuyPattern[iSym][iSet][pos] = false;
       double pinbarUpperShadow = 0, pinbarLowerShadow = 0, pinbarRelativeUpperShadow = 0, pinbarRelativeLowerShadow = 0;
       double pinbarBullAtrRange = 0, pinbarBearAtrRange = 0;

       if(body_s1 > 0){
          pinbarUpperShadow = h1 - c1;
          pinbarLowerShadow = o1 - l1;
          pinbarBullAtrRange = (pinbarLowerShadow + body_s1) / atr;
          pinbarBearAtrRange = pinbarUpperShadow / atr;
       }
       else if(body_s1 < 0){
          pinbarUpperShadow = h1 - o1;
          pinbarLowerShadow = c1 - l1;
          pinbarBullAtrRange = pinbarLowerShadow / atr;
          pinbarBearAtrRange = (pinbarUpperShadow + MathAbs(body_s1)) / atr;
       }
       if( ( body_s1 == 0 || (pinbarUpperShadow/MathAbs(body_s1)) >= pinbarMinShadow) &&
           ( pinbarLowerShadow == 0 || (pinbarUpperShadow/pinbarLowerShadow) >= pinbarMinShadow))
       {
          if(pinbarBearAtrRange >= pinbarAtrMin && pinbarBearAtrRange <= pinbarAtrMax ){
            pinbarSellPattern[iSym][iSet][pos] = true;
          }
       }
       if( (body_s1 == 0 || (pinbarLowerShadow/MathAbs(body_s1)) >= pinbarMinShadow) &&
           (pinbarUpperShadow == 0 || (pinbarLowerShadow/pinbarUpperShadow) >= pinbarMinShadow))
       { 
          if(pinbarBullAtrRange >= pinbarAtrMin && pinbarBullAtrRange <= pinbarAtrMax ){
            pinbarBuyPattern[iSym][iSet][pos] = true;
          }
       }
     }
     /********* Calculating ENGULF *********/
     if(useEngulf)
     {
       engulfBuyPattern[iSym][iSet][pos] = engulfSellPattern[iSym][iSet][pos] = false;

       double engulfFill;
       double candleAtr_s2 = body_s2 / atr;
       double candleAtr_s1 = body_s1 / atr;
       engulfFill = candleAtr_s2 != 0 ? MathAbs(candleAtr_s1) / MathAbs(candleAtr_s2) : 0;
       if( engulfFill >= engulfMinFill && engulfFill <= engulfMaxFill)
       {
         if(body_s1 > 0 && body_s2 < 0)
         {
           value = MathAbs(candleAtr_s1) * engulfFill;
           if(value >= engulfAtrMin && value <= engulfAtrMax ){
             engulfBuyPattern[iSym][iSet][pos] = true;
           }
         }
         else if(body_s1 < 0 && body_s2 > 0)
         {
           value = MathAbs(candleAtr_s1) * engulfFill;
           if(value >= engulfAtrMin && value <= engulfAtrMax ){
             engulfSellPattern[iSym][iSet][pos] = true;
           }
         }
       }
     }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(IsOpen()){
      bool buy = pinbarBuyPattern[iSym][iSet][shift_begin] || engulfBuyPattern[iSym][iSet][shift_begin];
      bool sell = pinbarSellPattern[iSym][iSet][shift_begin] || engulfSellPattern[iSym][iSet][shift_begin];

      if(buy)
      {
        for(int auxSet = iSet; auxSet < TF_COUNT && buy; auxSet++)
        {
          if(timeframes.InUse(auxSet)){
            int shift = shift_begin;
            for(int i=0; i<(data_depth-1) && buy; i++, shift++)
            {
              buy = buy && !pinbarSellPattern[iSym][auxSet][shift] && !engulfSellPattern[iSym][auxSet][shift];
            }
          }
        }
      }
      buySignal[iSym][iSet] = buy;

      if(sell)
      {
        for(int auxSet = iSet; auxSet < TF_COUNT && sell; auxSet++)
        {
          if(timeframes.InUse(auxSet)){
            int shift = shift_begin;
            for(int i=0; i<(data_depth-1) && buy; i++, shift++)
            {
              sell = sell && !pinbarBuyPattern[iSym][auxSet][shift] && !engulfBuyPattern[iSym][auxSet][shift];
            }
          }
        }
      }
      sellSignal[iSym][iSet] = sell;
    }
    if(IsClose()){
      closeBuy[iSym][iSet] = sellPattern[iSym][iSet][shift_begin];
      closeSell[iSym][iSet] = buyPattern[iSym][iSet][shift_begin];
    }
  }
};
//+------------------------------------------------------------------+
