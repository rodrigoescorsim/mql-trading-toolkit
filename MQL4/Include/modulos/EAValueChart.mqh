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
extern string  valuechart1_info         = "======================================";
extern string  valuechart2_info         = "========== VALUECHART SETUP ==========";
extern string  valuechart3_info         = "======================================";
extern bool    useValueChart            = false;
extern int     valuechart_numbars       = 5;
extern int     valuechart_shift         = 0;
extern double  valuechart_limit         = 10;
extern SIGNAL_TYPE vc_openSignalType    = AND;
extern SIGNAL_TYPE vc_closeSignalType   = OR;

//+------------------------------------------------------------------+
class EAValueChart : public EAIndicator
{
  private:
  double valuechart_value[][TF_COUNT];

  //+------------------------------------------------------------------+
  public:
  EAValueChart(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "ValueChart")
  {
     data_depth = 1;
     tickUpdate = true;
     shift_begin = valuechart_shift;
     openSignalType = vc_openSignalType;
     closeSignalType = vc_closeSignalType;
     ArrayResize(valuechart_value, core.getSymbolCount());
     ArrayInitialize(valuechart_value, 0);
  }
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", valueInfo="";
    //int digits = (int) MarketInfo(core.getSymbol(iSym),MODE_DIGITS);
    
    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        valueInfo += StringConcatenate((int)valuechart_value[iSym][iSet],",");
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
      }
    }
    if(StringLen(valueInfo) > 0) valueInfo = StringSubstr(valueInfo,0,StringLen(valueInfo)-1);
    if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
    if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);

    return StringConcatenate(name,": CloseSell(",valueInfo,"),Buy(",buyInfo,"),Sell(",sellInfo,")");
  }
  //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
    double mva = getMVA(core.getSymbol(iSym), timeframes.Value(iSet), valuechart_numbars, shift_begin);
    double atr = getATR(core.getSymbol(iSym), timeframes.Value(iSet), valuechart_numbars, shift_begin);
    double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
    valuechart_value[iSym][iSet] = (bid - mva) / atr;
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
    
    if(valuechart_value[iSym][iSet] >= valuechart_limit){
      sellSignal[iSym][iSet] = closeBuy[iSym][iSet] = true;
    }
    if(valuechart_value[iSym][iSet] <= -valuechart_limit){
      buySignal[iSym][iSet] = closeSell[iSym][iSet] = true;
    }  
  }
  //+------------------------------------------------------------------+
// Market Value Added function
double getMVA(string _sym, int _tf, int NumBars1,int CBar)
  {
   double sum = 0.0,floatingAxis;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=((iHigh(_sym, _tf, k)+iLow(_sym, _tf, k))/2.0);
     }
   floatingAxis=(sum/NumBars1);
   return(floatingAxis);
  }
// Average True Range Function
double getATR(string _sym, int _tf, int NumBars1,int CBar)
  {
   double sum = 0.0,volitilityUnit;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=(iHigh(_sym, _tf, k)-iLow(_sym, _tf, k));
     }
   volitilityUnit=(0.2 *(sum/NumBars1));
   if(volitilityUnit==0 || volitilityUnit==0.0)
     {
      volitilityUnit=0.00000001;
     }
   return(volitilityUnit);
  }

};
//+------------------------------------------------------------------+
