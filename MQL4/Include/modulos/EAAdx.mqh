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
extern string  adx_info1               = "======================================";
extern string  adx_info2               = "============= ADX SETUP =============";
extern string  adx_info3               = "======================================";
extern bool    useADX                  = true;
extern int     adx_period              = 14;
extern int     adx_trend_limit         = 25;
extern int     adx_shift               = 1;
extern SIGNAL_TYPE adx_openSignalType  = AND;
extern SIGNAL_TYPE adx_closeSignalType = NOT;
//+------------------------------------------------------------------+
class EAAdx : public EAIndicator
{
  private:
   double adx_value[][TF_COUNT][2];
   double diplus_value[][TF_COUNT][2];
   double diminus_value[][TF_COUNT][2];
  //+------------------------------------------------------------------+
  public:
  EAAdx(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "EAAdx")
  {
     openSignalType  = adx_openSignalType;
     closeSignalType = adx_closeSignalType;
     data_depth = 2;
     shift_begin = adx_shift;
     ArrayResize(adx_value, core.getSymbolCount());
     ArrayResize(diplus_value, core.getSymbolCount());
     ArrayResize(diminus_value, core.getSymbolCount());
     ArrayInitialize(adx_value, 0);
     ArrayInitialize(diplus_value, 0);
     ArrayInitialize(diminus_value, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
      string _symbol = core.getSymbol(iSym); 
      int _tf = timeframes.Value(iSet);
      if(firstUpdate){
        adx_value[iSym][iSet][1] = iADX(_symbol, _tf, adx_period, PRICE_CLOSE, 0, shift_begin+1);
        firstUpdate = false;
      }
      else{
        adx_value[iSym][iSet][1] = adx_value[iSym][iSet][0];
      }
      adx_value[iSym][iSet][0] =  iADX(_symbol, _tf, adx_period, PRICE_CLOSE, 0, shift_begin);
      diplus_value[iSym][iSet][0] =  iADX(_symbol, _tf, adx_period, PRICE_CLOSE, 1, shift_begin);
      diminus_value[iSym][iSet][0] =  iADX(_symbol, _tf, adx_period, PRICE_CLOSE, 2, shift_begin);
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {

     closeBuy[iSym][iSet] = false;
     closeSell[iSym][iSet] = false;
     buySignal[iSym][iSet] = false;
     sellSignal[iSym][iSet] = false;
    
     /*if(adx_value[iSym][iSet][0] < adx_trend_limit) {
        closeBuy[iSym][iSet] = true;
        closeSell[iSym][iSet] = true;
     }
     else if(diplus_value[iSym][iSet][0] > diminus_value[iSym][iSet][0]) {
        closeSell[iSym][iSet] = true;
     }
     else if(diplus_value[iSym][iSet][0] < diminus_value[iSym][iSet][0]) {
        closeBuy[iSym][iSet] = true;
     }*/
    
   
    if(adx_value[iSym][iSet][0] >= adx_trend_limit && adx_value[iSym][iSet][0] > adx_value[iSym][iSet][1]) {
       if(diplus_value[iSym][iSet][0] > diminus_value[iSym][iSet][0]) {    
          buySignal[iSym][iSet] = true;
       }
       else if(diplus_value[iSym][iSet][0] < diminus_value[iSym][iSet][0]) {
          sellSignal[iSym][iSet] = true;
       }
     }
  }
     //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      info += "ADX: ";
      
      for(int iSet=0; iSet < TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(timeframes.PosToStr(iSet), "(",adx_value[iSym][iSet][1],",+/",diplus_value[iSym][iSet][0],",-/",diplus_value[iSym][iSet][0],") ");
         }
      }
      info += NL + "ADX: BUY(" ;
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
