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
extern string  tma_info                 = "=== TMA SETUP ===";
extern bool    useTma                   = false;
extern int     tma_period               = 50;
extern double  tma_threshold            = 0.4;
extern int     tma_atr_period           = 500;
extern double  tma_band_open_M1         = 4.5;
extern double  tma_band_close_M1        = 3;
extern double  tma_band_open_M5         = 4.0;
extern double  tma_band_close_M5        = 2.5;
extern double  tma_band_open_M15        = 3.5;
extern double  tma_band_close_M15       = 2;
extern double  tma_band_open_H1         = 2.5;
extern double  tma_band_close_H1        = 1.5;
extern double  tma_band_open_H4         = 2.5;
extern double  tma_band_close_H4        = 1.5;
extern double  tma_band_open_D1         = 2.5;
extern double  tma_band_close_D1        = 1.5;
extern double  tma_band_open_W1         = 2.5;
extern double  tma_band_close_W1        = 1.5;
extern bool    useTmaSlope              = true;
extern double  tma_slope_limit          = 0.35;
extern bool    useTmaSlopeRegressive    = true;
//+------------------------------------------------------------------+
class EATmaControl : public EAIndicator
{
  private:
  double tma_value[][TF_COUNT][2];
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
  : EAIndicator(_core, _timeframes, "TmaCtrl")
  {
     data_depth = 2;
     closeSignalType = AND;
     ArrayResize(tma_value, core.getSymbolCount());
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
     ArrayInitialize(tma_slope_value, 0);
     ArrayInitialize(tma_open_sell, 0);
     ArrayInitialize(tma_open_buy, 0);
     ArrayInitialize(tma_close_buy, 0);
     ArrayInitialize(tma_close_sell, 0);
     ArrayInitialize(tma_openSell_distance, 0);
     ArrayInitialize(tma_openBuy_distance, 0);
     ArrayInitialize(tma_closeSell_distance, 0);
     ArrayInitialize(tma_closeBuy_distance, 0);

     tmaBandOpenByTf[0] = tma_band_open_M1;
     tmaBandOpenByTf[1] = tma_band_open_M5;
     tmaBandOpenByTf[2] = tma_band_open_M15;
     tmaBandOpenByTf[3] = tma_band_open_H1;
     tmaBandOpenByTf[4] = tma_band_open_H4;
     tmaBandOpenByTf[5] = tma_band_open_D1;
     tmaBandOpenByTf[6] = tma_band_open_W1;

     tmaBandCloseByTf[0] = tma_band_close_M1;
     tmaBandCloseByTf[1] = tma_band_close_M5;
     tmaBandCloseByTf[2] = tma_band_close_M15;
     tmaBandCloseByTf[3] = tma_band_close_H1;
     tmaBandCloseByTf[4] = tma_band_close_H4;
     tmaBandCloseByTf[5] = tma_band_close_D1;
     tmaBandCloseByTf[6] = tma_band_close_W1;
  }
  //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
    string tmaSlopeInfo="", tmaOpenSellDistInfo="", tmaOpenBuyDistInfo="";
    string tmaCloseSellDistInfo="", tmaCloseBuyDistInfo="";
    int digits = (int) MarketInfo(core.getSymbol(iSym),MODE_DIGITS);
    
    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
        closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
        closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");
        tmaSlopeInfo += StringConcatenate(DoubleToString(tma_slope_value[iSym][iSet],2),",");
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
                             name,": OpenBuyDist(",tmaOpenBuyDistInfo,"),OpenSellDist(",tmaOpenSellDistInfo,"),Slope(",tmaSlopeInfo,")",NL,
                             name,": CloseBuyDist(",tmaCloseBuyDistInfo,"),CloseSellDist(",tmaCloseSellDistInfo,")");
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
     tma_value[iSym][iSet][0] = getTma(core.getSymbol(iSym), timeframes.Value(iSet), shift_begin);
     tma_value[iSym][iSet][1] = getTma(core.getSymbol(iSym), timeframes.Value(iSet), shift_begin+1);

     double atr = timeframes.getAtrSlow(iSym,iSet);
     if(atr == 0){ 
       Print(StringConcatenate("WARNING ATR == 0 EATmaControl::UpdateData"));
       return;
     }
     tma_slope_value[iSym][iSet] = ((tma_value[iSym][iSet][0] - tma_value[iSym][iSet][1]) / (timeframes.getAtrSlow(iSym,iSet) * 0.1)) ;

     tma_open_sell[iSym][iSet] = tma_value[iSym][iSet][0] + (timeframes.getAtrSlow(iSym,iSet) * tmaBandOpenByTf[iSet]);
     tma_open_buy[iSym][iSet] = tma_value[iSym][iSet][0] - (timeframes.getAtrSlow(iSym,iSet) * tmaBandOpenByTf[iSet]);

     tma_close_buy[iSym][iSet] = tma_value[iSym][iSet][0] + (timeframes.getAtrSlow(iSym,iSet) * tmaBandCloseByTf[iSet]);
     tma_close_sell[iSym][iSet] = tma_value[iSym][iSet][0] - (timeframes.getAtrSlow(iSym,iSet) * tmaBandCloseByTf[iSet]);

  }
  //+------------------------------------------------------------------+
  void UpdateSignalBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
       UpdateSignal(iSym, iSet);
    }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
       
    double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
    double point = MarketInfo(core.getSymbol(iSym),MODE_POINT);
     
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
      sellSignal[iSym][iSet] = sell;
    }
    if(tma_openBuy_distance[iSym][iSet] <= 0){
      bool buy = true;
      if(useTmaSlope && (iSet+1)< TF_COUNT){  
         if(tma_slope_value[iSym][iSet+1] < -tma_slope_limit){
            buy = false;
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
