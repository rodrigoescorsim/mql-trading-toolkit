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
extern string  pvaVolume_info          = "=== PVA VOLUME SETUP ===";
extern bool    usePvaVolume            = false;
extern bool    usePvaRisingFilter      = true;
extern bool    usePvaClimaxFilter      = true;
extern bool    usePvaRisingOpen        = false;
extern bool    usePvaClimaxOpen        = false;
extern string  pvaVolumePath           = "Vertex/PVA_Volumes_ModVertex";
//+------------------------------------------------------------------+
class EAInd_PVA : public EAIndicator
{
  private:
  double pvaRisingBullData[][TF_COUNT][2];
  double pvaRisingBearData[][TF_COUNT][2];
  double pvaClimaxBullData[][TF_COUNT][2];
  double pvaClimaxBearData[][TF_COUNT][2];

  public:
  EAInd_PVA(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes)
  {
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

  bool UpdateData( )
  {
    bool updated = false;
    if(!usePvaVolume) return updated;

    for(int iSym=0; iSym < core.getSymbolCount(); iSym++)
    {
      for(int iSet=0; iSet < TF_COUNT; iSet++)
      {
        if(timeframes.Updated(iSym,iSet))
        {
           pvaRisingBullData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 2, 1);
           pvaRisingBearData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 3, 1);
           pvaClimaxBullData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 4, 1);
           pvaClimaxBearData[iSym][iSet][0] = iCustom(core.getSymbol(iSym),timeframes.Value(iSet),pvaVolumePath, 5, 1);
           updated = true;
        }
      }
    }
    return updated;
  }
  
  void UpdateAllSignal()
  {

   /* 
          int pva_count_setup = iSet;
          int pva_setup_pos = iSet+1;
          if(usePvaFilterHigherTF) pva_count_setup = TF_COUNT;
          if(usePvaFilterCurrentTF) pva_setup_pos = iSet;

          for(; pva_setup_pos < pva_count_setup; pva_setup_pos++)
          {
            int pos = 0;
            if(pva_setup_pos > iSet) pos = 1;
            if( pvaRisingBullData[iSym][pva_setup_pos] > 0 ) pvaVolumeValue[iSym][pva_setup_pos][pos] += 1;
            if( pvaClimaxBullData[iSym][pva_setup_pos] > 0 ) pvaVolumeValue[iSym][pva_setup_pos][pos] += 2;
            if( pvaRisingBullData[iSym][pva_setup_pos] > 0 ) pvaVolumeValue[iSym][pva_setup_pos][pos] -= 1;
            if( pvaClimaxBullData[iSym][pva_setup_pos] > 0 ) pvaVolumeValue[iSym][pva_setup_pos][pos] -= 2;
          }
          pvaVolumeValue[iSym][iSet][2] = pvaVolumeValue[iSym][iSet][0] + pvaVolumeValue[iSym][iSet][1];

          if(usePvaFilterCurrentTF)
          {
            if( (usePvaRisingFilter && pvaVolumeValue[iSym][iSet][0] > 0 ) ||
            (usePvaClimaxFilter && pvaVolumeValue[iSym][iSet][0] > 1 )){
              pvaShortFilter[iSym][iSet] = true;
            }
            if( (usePvaRisingFilter && pvaVolumeValue[iSym][iSet][0] < 0 ) ||
            (usePvaClimaxFilter && pvaVolumeValue[iSym][iSet][0] < -1 )){
              pvaLongFilter[iSym][iSet] = true;
            }
          }
          if(usePvaFilterHigherTF)
          {
            if( (usePvaRisingFilter && pvaVolumeValue[iSym][iSet][1] > 0 ) ||
            (usePvaClimaxFilter && pvaVolumeValue[iSym][iSet][1] > 1 )){
              pvaShortFilter[iSym][iSet] = true;
            }
            if( (usePvaRisingFilter && pvaVolumeValue[iSym][iSet][1] < 0 ) ||
            (usePvaClimaxFilter && pvaVolumeValue[iSym][iSet][1] < -1 )){
              pvaLongFilter[iSym][iSet] = true;
            }
          }
          if(usePvaOpen)
          {
            if( (usePvaRisingOpen && pvaVolumeValue[iSym][iSet][0] > 0 ) ||
            (usePvaClimaxOpen && pvaVolumeValue[iSym][iSet][0] > 1 )){
              buySignalByPva[iSym][iSet] = true;
            }
            if( (usePvaRisingOpen && pvaVolumeValue[iSym][iSet][0] < 0 ) ||
            (usePvaClimaxOpen && pvaVolumeValue[iSym][iSet][0] < -1 )){
              sellSignalByPva[iSym][iSet] = true;
            }
          }
        }
      }
    }*/
  }
};
//+------------------------------------------------------------------+
