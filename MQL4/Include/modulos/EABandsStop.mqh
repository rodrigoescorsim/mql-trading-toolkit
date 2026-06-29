//+------------------------------------------------------------------+
//|                                                    EAInd_PVA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
extern string  bandsStop1_info         = "======================================";
extern string  bandsStop2_info         = "========== BANDS STOP SETUP ==========";
extern string  bandsStop3_info         = "======================================";
extern bool    useBandsStop            = false;
extern int     bandsStopPeriod         = 20;  
extern int     bandsStopDeviation      = 2;  
extern double  bandsStopRiskFactor     = 1.00;
extern string  bandsStopPath           = "close/BBands_Stop_v2";
extern SIGNAL_TYPE bstop_openSignalType  = AND;
extern SIGNAL_TYPE bstop_closeSignalType = OR;
//+------------------------------------------------------------------+
class EABandsStop : public EAIndicator
{
  private:
   double bandsUpperData[][TF_COUNT][2];
   double bandsLowerData[][TF_COUNT][2];
  //+----------------------------------w--------------------------------+
  public:
  EABandsStop(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "BandsStop")
  {
     openSignalType  = bstop_openSignalType;
     closeSignalType = bstop_closeSignalType;
     data_depth = 2;
     ArrayResize(bandsUpperData, core.getSymbolCount());
     ArrayResize(bandsLowerData, core.getSymbolCount());
     ArrayInitialize(bandsUpperData, 0);
     ArrayInitialize(bandsLowerData, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){
   if(bandsUpperData[iSym][iSet][0] > 0){
      DrawChannel("bandsStopHigh_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), bandsUpperData[iSym][iSet][0], clrCyan);
   }
   if(bandsLowerData[iSym][iSet][0] > 0){
      DrawChannel("bandsStopLow_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), bandsLowerData[iSym][iSet][0], clrCyan);
   }
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
      if(firstUpdate){
        bandsLowerData[iSym][iSet][1] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),bandsStopPath, bandsStopPeriod, bandsStopDeviation, bandsStopRiskFactor, 0, shift_begin+1);
        bandsUpperData[iSym][iSet][1] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),bandsStopPath, bandsStopPeriod, bandsStopDeviation, bandsStopRiskFactor, 1, shift_begin+1);
         firstUpdate = false;
      }
      else{
        bandsLowerData[iSym][iSet][1] = bandsLowerData[iSym][iSet][0];
        bandsUpperData[iSym][iSet][1] = bandsUpperData[iSym][iSet][0];
      }
      
      bandsLowerData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),bandsStopPath, bandsStopPeriod, bandsStopDeviation, bandsStopRiskFactor, 0, shift_begin);
      bandsUpperData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),bandsStopPath, bandsStopPeriod, bandsStopDeviation, bandsStopRiskFactor, 1, shift_begin);
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(bandsLowerData[iSym][iSet][0] > 0.00001){
      buySignal[iSym][iSet] = true; 
      closeSell[iSym][iSet] = false; 
      sellSignal[iSym][iSet] = false;
      closeBuy[iSym][iSet] = false;
    }
    else if(bandsUpperData[iSym][iSet][0] > 0.00001){
      buySignal[iSym][iSet] = false; 
      closeSell[iSym][iSet] = false; 
      sellSignal[iSym][iSet] = true;
      closeBuy[iSym][iSet] = false;
    }
  }
};
//+------------------------------------------------------------------+
