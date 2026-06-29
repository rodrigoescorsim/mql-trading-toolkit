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
extern string  avgVolume1_info         = "======================================";
extern string  avgVolume2_info         = "========== AVG VOLUME SETUP ==========";
extern string  avgVolume3_info         = "======================================";
extern bool    useAvgVolumeFilter      = false;
extern int     avgVolumePeriodFast     = 27;
extern int     avgVolumePeriodSlow     = 500;
extern double  avgVolumeRequiredAbove  = 0.8;
extern double  avgVolumeRequiredBelow  = 0.0;
extern string  avgVolumePath           = "Vertex/volumeMA";
extern SIGNAL_TYPE avg_openSignalType  = AND;
extern SIGNAL_TYPE avg_closeSignalType = NOT;
//+------------------------------------------------------------------+
class EAAvgVol : public EAIndicator
{
  private:
   double avgVolumeFastData[][TF_COUNT][2];
   double avgVolumeSlowData[][TF_COUNT][2];
   double avgVolumeValue[][TF_COUNT][2];
  //+------------------------------------------------------------------+
  public:
  EAAvgVol(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "AvgVol")
  {
     openSignalType  = avg_openSignalType;
     closeSignalType = avg_closeSignalType;
     data_depth = 2;
     ArrayResize(avgVolumeFastData, core.getSymbolCount());
     ArrayResize(avgVolumeSlowData, core.getSymbolCount());
     ArrayResize(avgVolumeValue, core.getSymbolCount());
     ArrayInitialize(avgVolumeFastData, 0);
     ArrayInitialize(avgVolumeSlowData, 0);
     ArrayInitialize(avgVolumeValue, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
      if(firstUpdate){
        avgVolumeFastData[iSym][iSet][1] =
          iCustom(core.getSymbol(iSym),timeframes.Value(iSet),avgVolumePath, avgVolumePeriodFast, 1,  2, shift_begin+1);
         firstUpdate = false;
      }
      else{
        avgVolumeFastData[iSym][iSet][1] = avgVolumeFastData[iSym][iSet][0];
      }
      avgVolumeFastData[iSym][iSet][0] =
        iCustom(core.getSymbol(iSym),timeframes.Value(iSet),avgVolumePath, avgVolumePeriodFast, 1,  2, shift_begin);
      avgVolumeSlowData[iSym][iSet][0] =
        iCustom(core.getSymbol(iSym),timeframes.Value(iSet),avgVolumePath, avgVolumePeriodSlow, 0,  2, shift_begin);

      avgVolumeValue[iSym][iSet][1] = avgVolumeValue[iSym][iSet][0];
      if(avgVolumeSlowData[iSym][iSet][0] > 0){
        avgVolumeValue[iSym][iSet][0] = avgVolumeFastData[iSym][iSet][0] / avgVolumeSlowData[iSym][iSet][0];
      }
      else{
        avgVolumeValue[iSym][iSet][0] = 1;
        Print(StringConcatenate("Error - avgVolumeSlowData <= 0 - Symbol: ",core.getSymbol(iSym),", Setup: ",iSet));
      }

  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if((avgVolumeRequiredAbove == 0 || avgVolumeValue[iSym][iSet][0] >= avgVolumeRequiredAbove) &&
       (avgVolumeRequiredBelow == 0 || avgVolumeValue[iSym][iSet][0] <= avgVolumeRequiredBelow))
    {
      buySignal[iSym][iSet] = sellSignal[iSym][iSet] = true;
    }
    else{
      buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    }
  }
};
//+------------------------------------------------------------------+
