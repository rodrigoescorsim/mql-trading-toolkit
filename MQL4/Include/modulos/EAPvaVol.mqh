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
extern string  pvaVolume1_info         = "======================================";
extern string  pvaVolume2_info         = "========== PVA VOLUME SETUP ==========";
extern string  pvaVolume3_info         = "======================================";
extern bool    usePvaVolume            = false;
extern bool    usePvaRisingClose       = true;
extern bool    usePvaClimaxClose       = true;
extern bool    usePvaRisingOpen        = false;
extern bool    usePvaClimaxOpen        = false;
extern string  pvaVolumePath           = "Vertex/PVA_Volumes_ModVertex";
extern SIGNAL_TYPE pva_openSignalType  = AND;
extern SIGNAL_TYPE pva_closeSignalType = NOT;
//+------------------------------------------------------------------+
class EAPvaVol : public EAIndicator
{
  private:
  double pvaRisingBullData[][TF_COUNT][3];
  double pvaRisingBearData[][TF_COUNT][3];
  double pvaClimaxBullData[][TF_COUNT][3];
  double pvaClimaxBearData[][TF_COUNT][3];
  bool useOpen, useClose, useRising, useClimax;
  //+------------------------------------------------------------------+
  public:
  EAPvaVol(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "PvaVol")
  {
    openSignalType  = pva_openSignalType;
    closeSignalType = pva_closeSignalType;
    data_depth = 3;
    useOpen = usePvaRisingOpen || usePvaClimaxOpen;
    useClose = usePvaRisingClose || usePvaClimaxClose;
    useRising = usePvaRisingOpen || usePvaRisingClose;
    useClimax = usePvaClimaxOpen || usePvaClimaxClose;
    ArrayResize(pvaRisingBullData, core.getSymbolCount());
    ArrayResize(pvaRisingBearData, core.getSymbolCount());
    ArrayResize(pvaClimaxBullData, core.getSymbolCount());
    ArrayResize(pvaClimaxBearData, core.getSymbolCount());
    ArrayInitialize(pvaRisingBullData, 0);
    ArrayInitialize(pvaRisingBearData, 0);
    ArrayInitialize(pvaClimaxBullData, 0);
    ArrayInitialize(pvaClimaxBearData, 0);
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  //string GetInfoBySymbol(int iSym)
  //{
  //  return "";
  //}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
    int shift = shift_begin;
    if(firstUpdate){
      for(int i=0; i<data_depth; i++, shift++)
      {
        if(useRising) pvaRisingBullData[iSym][iSet][i] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 2, shift);
        if(useRising) pvaRisingBearData[iSym][iSet][i] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 3, shift);
        if(useClimax) pvaClimaxBullData[iSym][iSet][i] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 4, shift);
        if(useClimax) pvaClimaxBearData[iSym][iSet][i] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 5, shift);
      }
      firstUpdate = false;
    }
    else{
      for(int i=0; i<data_depth; i++, shift++)
      {
        if(shift_begin == shift)
          continue;
        if(useRising) pvaRisingBullData[iSym][iSet][i] = pvaRisingBullData[iSym][iSet][i-1];
        if(useRising) pvaRisingBearData[iSym][iSet][i] = pvaRisingBearData[iSym][iSet][i-1];
        if(useClimax) pvaClimaxBullData[iSym][iSet][i] = pvaClimaxBullData[iSym][iSet][i-1];
        if(useClimax) pvaClimaxBearData[iSym][iSet][i] = pvaClimaxBearData[iSym][iSet][i-1];
      }
      if(useRising) pvaRisingBullData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 2, shift_begin);
      if(useRising) pvaRisingBearData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 3, shift_begin);
      if(useClimax) pvaClimaxBullData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 4, shift_begin);
      if(useClimax) pvaClimaxBearData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 5, shift_begin);
    }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(useOpen)
    {
        bool buy = false, sell = false;
        if(useRising && pvaRisingBullData[iSym][iSet][shift_begin]) buy = true;
        else if(useClimax && pvaClimaxBullData[iSym][iSet][shift_begin]) buy = true;
        if(useRising && pvaRisingBearData[iSym][iSet][shift_begin]) sell = true;
        else if(useClimax && pvaClimaxBearData[iSym][iSet][shift_begin]) sell = true;

        if(buy || sell) {
          int shift = shift_begin;
          for(int i=0; i<data_depth; i++, shift++)
          {
            if(shift_begin == shift)
              continue;
            if(useRising && sell) sell = sell && !pvaRisingBullData[iSym][iSet][i];
            if(useRising && buy) buy = buy && !pvaRisingBearData[iSym][iSet][i];
            if(useClimax && sell) sell = sell && !pvaClimaxBullData[iSym][iSet][i];
            if(useClimax && buy) buy = buy && !pvaClimaxBearData[iSym][iSet][i];
          }
        }
        buySignal[iSym][iSet] = buy;
        sellSignal[iSym][iSet] = sell;
    }
    if(useClose)
    {
        bool close_buy = false, close_sell = false;
        if(useRising && pvaRisingBearData[iSym][iSet][shift_begin]) close_buy = true;
        else if(useClimax && pvaClimaxBearData[iSym][iSet][shift_begin]) close_buy = true;
        if(useRising && pvaRisingBullData[iSym][iSet][shift_begin]) close_sell = true;
        else if(useClimax && pvaClimaxBullData[iSym][iSet][shift_begin]) close_sell = true;
        closeBuy[iSym][iSet] = close_buy;
        closeSell[iSym][iSet] = close_sell;
    }
  }
};
//+------------------------------------------------------------------+
