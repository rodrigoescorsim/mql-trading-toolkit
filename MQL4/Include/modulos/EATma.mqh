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
extern string  tma1_info                = "===============================";
extern string  tma2_info                = "========== TMA SETUP ==========";
extern string  tma3_info                = "===============================";
extern bool    useTma                   = true;
extern int     tma_period               = 50;
extern double  tma_threshold            = 0.4;
//extern int     tma_atr_period           = 500;
extern double  tma_band_open_TF1         = 3.0;
extern double  tma_band_close_TF1        = 2;
extern double  tma_band_open_TF2         = 3.0;
extern double  tma_band_close_TF2        = 1.75;
extern double  tma_band_open_TF3         = 2.5;
extern double  tma_band_close_TF3        = 1.5;
extern double  tma_band_open_TF4         = 2.0;
extern double  tma_band_close_TF4        = 1.25;
extern double  tma_band_open_TF5         = 2.0;
extern double  tma_band_close_TF5        = 1.25;
extern double  tma_band_open_TF6         = 2.0;
extern double  tma_band_close_TF6        = 1.25;
extern double  tma_band_open_TF7         = 2.0;
extern double  tma_band_close_TF7        = 1.25;
extern bool    useTmaSlope              = false;
extern double  tma_slope_limit          = 0.05;
extern bool    useTmaMajorSetupLimit    = true;
extern int     useTmaMajorCountSetups   = 3;
extern double  tma_majorSetup_limit     = 1.0;
extern bool    useTmaMinorSetupLimit    = true;
extern double  tma_minorSetup_limit     = 1.5;
extern SIGNAL_TYPE tma_openSignalType   = AND;
extern SIGNAL_TYPE tma_closeSignalType  = AND;
//+------------------------------------------------------------------+
class EATmaControl : public EAIndicator
{
  private:
  double tma_value[][TF_COUNT][2];
  double tma_distance[][TF_COUNT];
  double tma_open_sell[][TF_COUNT], tma_open_buy[][TF_COUNT];
  double tma_close_buy[][TF_COUNT], tma_close_sell[][TF_COUNT];
  double tma_openSell_distance[][TF_COUNT], tma_openBuy_distance[][TF_COUNT];
  double tma_closeSell_distance[][TF_COUNT], tma_closeBuy_distance[][TF_COUNT];
  double tmaBandOpenByTf[TF_COUNT], tmaBandCloseByTf[TF_COUNT];
  public:
  double tma_slope_value[][TF_COUNT];
  //+------------------------------------------------------------------+
  public:
  EATmaControl(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "TMA")
  {
     data_depth = 2;
     openSignalType  = tma_openSignalType;
     closeSignalType = tma_closeSignalType;
     ArrayResize(tma_value, core.getSymbolCount());
     ArrayResize(tma_distance, core.getSymbolCount());
     ArrayResize(tma_slope_value, core.getSymbolCount());
     ArrayResize(tma_open_sell, core.getSymbolCount());
     ArrayResize(tma_open_buy, core.getSymbolCount());
     ArrayResize(tma_close_buy, core.getSymbolCount());
     ArrayResize(tma_close_sell, core.getSymbolCount());
     ArrayResize(tma_openSell_distance, core.getSymbolCount());
     ArrayResize(tma_openBuy_distance, core.getSymbolCount());
     ArrayResize(tma_closeSell_distance, core.getSymbolCount());
     ArrayResize(tma_closeBuy_distance, core.getSymbolCount());
     ArrayInitialize(tma_value, 0);
     ArrayInitialize(tma_distance, 0);
     ArrayInitialize(tma_slope_value, 0);
     ArrayInitialize(tma_open_sell, 0);
     ArrayInitialize(tma_open_buy, 0);
     ArrayInitialize(tma_close_buy, 0);
     ArrayInitialize(tma_close_sell, 0);
     ArrayInitialize(tma_openSell_distance, 0);
     ArrayInitialize(tma_openBuy_distance, 0);
     ArrayInitialize(tma_closeSell_distance, 0);
     ArrayInitialize(tma_closeBuy_distance, 0);

     tmaBandOpenByTf[0] = tma_band_open_TF1;
     tmaBandOpenByTf[1] = tma_band_open_TF2;
     tmaBandOpenByTf[2] = tma_band_open_TF3;
     tmaBandOpenByTf[3] = tma_band_open_TF4;
     tmaBandOpenByTf[4] = tma_band_open_TF5;
     tmaBandOpenByTf[5] = tma_band_open_TF6;
     tmaBandOpenByTf[6] = tma_band_open_TF7;

     tmaBandCloseByTf[0] = tma_band_close_TF1;
     tmaBandCloseByTf[1] = tma_band_close_TF2;
     tmaBandCloseByTf[2] = tma_band_close_TF3;
     tmaBandCloseByTf[3] = tma_band_close_TF4;
     tmaBandCloseByTf[4] = tma_band_close_TF5;
     tmaBandCloseByTf[5] = tma_band_close_TF6;
     tmaBandCloseByTf[6] = tma_band_close_TF7;
  }
  //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
    string tmaSlopeInfo="", tmaDistanceInfo="", tmaOpenSellDistInfo="", tmaOpenBuyDistInfo="";
    string tmaCloseSellDistInfo="", tmaCloseBuyDistInfo="";
    int digits = (int) MarketInfo(core.getSymbol(iSym),MODE_DIGITS);
    
    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
        closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
        closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");
        tmaSlopeInfo += StringConcatenate(DoubleToString(tma_slope_value[iSym][iSet],2),",");
        tmaDistanceInfo += StringConcatenate(DoubleToString(tma_distance[iSym][iSet],2),",");
        tmaOpenSellDistInfo += StringConcatenate(tma_openSell_distance[iSym][iSet],",");
        tmaOpenBuyDistInfo += StringConcatenate(tma_openBuy_distance[iSym][iSet],",");
        tmaCloseSellDistInfo += StringConcatenate(tma_closeSell_distance[iSym][iSet],",");
        tmaCloseBuyDistInfo += StringConcatenate(tma_closeBuy_distance[iSym][iSet],",");
      }
    }
    if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
    if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);
    if(StringLen(closeBuyInfo) > 0) closeBuyInfo = StringSubstr(closeBuyInfo,0,StringLen(closeBuyInfo)-1);
    if(StringLen(closeSellInfo) > 0) closeSellInfo = StringSubstr(closeSellInfo,0,StringLen(closeSellInfo)-1);

    return StringConcatenate(name,": Buy(",buyInfo,"),CloseBuy:(",closeBuyInfo,"),Sell(",sellInfo,"),CloseSell(",closeSellInfo,")",NL,
                             name,": Slope(",tmaSlopeInfo,"),OpenBuyDist(",tmaOpenBuyDistInfo,"),OpenSellDist(",tmaOpenSellDistInfo,")",NL,
                             name,": Distance(",tmaDistanceInfo, "),CloseBuyDist(",tmaCloseBuyDistInfo,"),CloseSellDist(",tmaCloseSellDistInfo,")");
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
     if(!timeframes.InUse(iSet)) return;

     tma_slope_value[iSym][iSet] = tma_open_sell[iSym][iSet] = tma_open_buy[iSym][iSet] = 0.0;
     tma_close_buy[iSym][iSet] = tma_close_sell[iSym][iSet] = 0.0;
     
     tma_value[iSym][iSet][0] = getTma(core.getSymbol(iSym), timeframes.Value(iSet), shift_begin);
     tma_value[iSym][iSet][1] = getTma(core.getSymbol(iSym), timeframes.Value(iSet), shift_begin+1);
     
     
     double _bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
     
     double minValue = _bid * 0.5;
     double maxValue = _bid * 1.5;
     
     if(tma_value[iSym][iSet][0] < minValue || tma_value[iSym][iSet][0] > maxValue || 
        tma_value[iSym][iSet][1] < minValue || tma_value[iSym][iSet][1] > maxValue) {
        Print(StringConcatenate("WARNING TMA RANGE INVALID  EATma::UpdateData - ",core.getSymbol(iSym)," - ",timeframes.PosToStr(iSet), 
                                " - BID: ", _bid, " - TMA[0]: ", tma_value[iSym][iSet][0], " - TMA[1]: ", tma_value[iSym][iSet][1]));                        
        return;
     }

     double atr = timeframes.getAtrSlow(iSym,iSet);
     if(atr == 0){ 
       Print(StringConcatenate("WARNING ATR == 0 EATma::UpdateData - ",core.getSymbol(iSym)," - ",timeframes.PosToStr(iSet)));
       return;
     }
     
     tma_distance[iSym][iSet] = (_bid - tma_value[iSym][iSet][0]) / atr;
     tma_slope_value[iSym][iSet] = ((tma_value[iSym][iSet][0] - tma_value[iSym][iSet][1]) / (atr * 0.1)) ;

     tma_open_sell[iSym][iSet] = tma_value[iSym][iSet][0] + (atr * tmaBandOpenByTf[iSet]);
     tma_open_buy[iSym][iSet] = tma_value[iSym][iSet][0] - (atr * tmaBandOpenByTf[iSet]);

     tma_close_buy[iSym][iSet] = tma_value[iSym][iSet][0] + (atr * tmaBandCloseByTf[iSet]);
     tma_close_sell[iSym][iSet] = tma_value[iSym][iSet][0] - (atr * tmaBandCloseByTf[iSet]);

  }
  //+------------------------------------------------------------------+
  void UpdateSignalBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        UpdateSignal(iSym, iSet);
      }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(!timeframes.InUse(iSet)) return;
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
   
       
    double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
    double point = MarketInfo(core.getSymbol(iSym),MODE_POINT);
    if(point == 0){ 
       Print(StringConcatenate("WARNING point == 0 EATma::UpdateSignal - " ,core.getSymbol(iSym)," - ",timeframes.PosToStr(iSet)));
       return;
    } 
    if(bid == 0){ 
       Print(StringConcatenate("WARNING bid == 0 EATma::UpdateSignal - " ,core.getSymbol(iSym)," - ",timeframes.PosToStr(iSet)));
       return;
    }   
    if(tma_open_sell[iSym][iSet] == 0.0 || tma_open_buy[iSym][iSet] == 0.0 || tma_close_buy[iSym][iSet] == 0.0 || tma_close_sell[iSym][iSet] == 0.0) {
      Print(StringConcatenate("WARNING Data Valus == 0 EATma::UpdateSignal - " ,core.getSymbol(iSym)," - ",timeframes.PosToStr(iSet)));
       return;
    }
     
    tma_openSell_distance[iSym][iSet] = (int)((tma_open_sell[iSym][iSet] - bid) / point);
    tma_openBuy_distance[iSym][iSet] = (int)((bid - tma_open_buy[iSym][iSet]) / point);
     
    tma_closeBuy_distance[iSym][iSet] = (int)((tma_close_buy[iSym][iSet] - bid) / point);
    tma_closeSell_distance[iSym][iSet] = (int)((bid - tma_close_sell[iSym][iSet]) / point);
     
    if(tma_openSell_distance[iSym][iSet] <= 0){
      bool sell = true;
      if(useTmaSlope && (iSet+1)< TF_COUNT){   
         if(tma_slope_value[iSym][iSet+1] > tma_slope_limit){
            sell = false;
         }
      }
      if(sell && useTmaMajorSetupLimit) {
         int iSetupMax = iSet + useTmaMajorCountSetups;
         iSetupMax = iSetupMax < TF_COUNT ? iSetupMax : (TF_COUNT-1);
         
         for(int i = iSet+1; i <= iSetupMax ; i++) {
            if(timeframes.InUse(i) && tma_distance[iSym][i] < -tma_majorSetup_limit) {
               sell = false;
            }
         
         }
      }
      if(sell && useTmaMinorSetupLimit) {
         for(int i = (iSet-1); i >= 0; i--) {
            if(timeframes.InUse(i) && tma_distance[iSym][i] < tma_minorSetup_limit) {
               sell = false;
               break;
            }
         } 
      }
      sellSignal[iSym][iSet] = sell;
    }
    if(tma_openBuy_distance[iSym][iSet] <= 0){
      bool buy = true;
      if(useTmaSlope && (iSet+1)< TF_COUNT){  
         if(tma_slope_value[iSym][iSet+1] < -tma_slope_limit){
            buy = false;
         }
      }
      if(buy && useTmaMajorSetupLimit) {
         int iSetupMax = iSet + useTmaMajorCountSetups;
         iSetupMax = iSetupMax < TF_COUNT ? iSetupMax : (TF_COUNT-1);
         
         for(int i = iSet+1; i <= iSetupMax ; i++) {
            if(timeframes.InUse(i) && tma_distance[iSym][i] > tma_majorSetup_limit) {
               buy = false;
            }
         }
      }
      
      if(buy && useTmaMinorSetupLimit) {
         for(int i = (iSet-1); i >= 0; i--) {
            if(timeframes.InUse(i) && tma_distance[iSym][i] > -tma_minorSetup_limit) {
               buy = false;
               break;
            }
         } 
      }
      buySignal[iSym][iSet] = buy;
    }
   
    if(tma_closeBuy_distance[iSym][iSet] <= 0){
      closeBuy[iSym][iSet] = true;
    }
    if(tma_closeSell_distance[iSym][iSet] <= 0){
      closeSell[iSym][iSet] = true;
    }   
  }
  //+------------------------------------------------------------------+
  double getTma(string _symbol, int timeFrame, int index)
  {
    double dblSum  = (tma_period+1)*iClose(_symbol, timeFrame,index);
    double dblSumw = (tma_period+1);
    int jnx, knx;

    for ( jnx = 1, knx = tma_period; jnx <= tma_period; jnx++, knx-- )
    {
      dblSum  += ( knx * iClose(_symbol, timeFrame,index+jnx) );
      dblSumw += knx;

      if ( jnx <= index )
      {
        dblSum  += ( knx * iClose(_symbol, timeFrame,index-jnx) );
        dblSumw += knx;
      }
    }

    return( dblSum / dblSumw );
  }

};
//+------------------------------------------------------------------+
