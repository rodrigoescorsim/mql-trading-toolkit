//+------------------------------------------------------------------+
//|                                                  EADistances.mqh |
//|                                                 Rodrigo Escorsim |
//|                                 https://www.rodrigo.escorsim.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Escorsim"
#property link      "https://www.rodrigo.escorsim.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
//| externs                                                          |
//+------------------------------------------------------------------+
extern string  open_distance_info          = "=== OPEN DISTANCES ===";
extern bool    useOpenDistance                  = true;
extern int     candleOpenDistanceBySetup        = 0;
extern int     candleOpendistanceBySymbol       = 0;
extern double  atrOpenDistanceBySetup           = 6.0;
extern double  atrOpenDistanceBySymbol          = 6.0;
extern SIGNAL_TYPE dist_openSignalType          = AND;
extern string  close_distance_info          = "=== CLOSE DISTANCES ===";
extern bool    useCloseDistance                 = true;
extern double  atrCloseDistanceBySetup          = 0.01;
extern double  atrCloseDistanceBySymbol         = 0.01;
extern SIGNAL_TYPE dist_closeSignalType         = NOT;
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
class EADistances : public EAIndicator
{
  private:
   int countCandleOpenBuyBySetup[][TF_COUNT];
   int countCandleOpenSellBySetup[][TF_COUNT];
   int countCandleOpenBuyBySymbol[];
   int countCandleOpenSellBySymbol[];
   
   double priceLastOpenBuyBySetup[][TF_COUNT];
   double priceLastOpenSellBySetup[][TF_COUNT];
   double priceLastOpenBuyBySymbol[];
   double priceLastOpenSellBySymbol[];
   
   double priceLastCloseBuyBySetup[][TF_COUNT];
   double priceLastCloseSellBySetup[][TF_COUNT];
   double priceLastCloseBuyBySymbol[];
   double priceLastCloseSellBySymbol[];
   
  //+------------------------------------------------------------------+
  public:
  EADistances(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "EaDistances")
  {
     data_depth = 1;
     openSignalType = dist_openSignalType;
     closeSignalType = dist_closeSignalType;
     tickUpdate = true;
     ArrayResize(countCandleOpenBuyBySetup, core.getSymbolCount()); ArrayInitialize(countCandleOpenBuyBySetup, 0);
     ArrayResize(countCandleOpenSellBySetup, core.getSymbolCount()); ArrayInitialize(countCandleOpenSellBySetup, 0);
     ArrayResize(countCandleOpenBuyBySymbol, core.getSymbolCount()); ArrayInitialize(countCandleOpenBuyBySymbol, 0);
     ArrayResize(countCandleOpenSellBySymbol, core.getSymbolCount()); ArrayInitialize(countCandleOpenSellBySymbol, 0); 
     
     ArrayResize(priceLastOpenBuyBySetup, core.getSymbolCount()); ArrayInitialize(priceLastOpenBuyBySetup, 0);
     ArrayResize(priceLastOpenSellBySetup, core.getSymbolCount()); ArrayInitialize(priceLastOpenSellBySetup, 0);
     ArrayResize(priceLastOpenBuyBySymbol, core.getSymbolCount()); ArrayInitialize(priceLastOpenBuyBySymbol, 0);
     ArrayResize(priceLastOpenSellBySymbol, core.getSymbolCount()); ArrayInitialize(priceLastOpenSellBySymbol, 0);
     

     ArrayResize(priceLastCloseBuyBySetup, core.getSymbolCount()); 
     ArrayResize(priceLastCloseSellBySetup, core.getSymbolCount());
     ArrayResize(priceLastCloseBuyBySymbol, core.getSymbolCount()); 
     ArrayResize(priceLastCloseSellBySymbol, core.getSymbolCount()); 
     
     for(int iSym =0; iSym < core.getSymbolCount(); iSym++){
      double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
      for(int iSet=0; iSet < TF_COUNT; iSet++){
        priceLastCloseBuyBySetup[iSym][iSet] = bid;
        priceLastCloseSellBySetup[iSym][iSet] = bid;
        priceLastCloseBuyBySymbol[iSym] = bid;
        priceLastCloseSellBySymbol[iSym] = bid;
      }
     }
     
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateCloseBuy(int iSym, int iSet, double price){
     if(useOpenDistance)
       priceLastOpenBuyBySetup[iSym][iSet] = priceLastOpenBuyBySymbol[iSym] = 0;
    if(useCloseDistance){
      priceLastCloseBuyBySetup[iSym][iSet] = priceLastCloseBuyBySymbol[iSym] = price;
      
      if(price > priceLastCloseSellBySetup[iSym][iSet])
         priceLastCloseSellBySetup[iSym][iSet] = price;
      if(price > priceLastCloseSellBySymbol[iSym])
         priceLastCloseSellBySymbol[iSym] = price;

      for(int i=0; i < TF_COUNT; i++){
        closeBuy[iSym][i] = false; closeSell[iSym][i] = false;
      }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateCloseSell(int iSym, int iSet, double price){
    if(useOpenDistance)
       priceLastOpenSellBySetup[iSym][iSet] = priceLastOpenSellBySymbol[iSym] = 0;
    if(useCloseDistance){
      priceLastCloseSellBySetup[iSym][iSet] = priceLastCloseSellBySymbol[iSym] = price;
      
      if(price < priceLastCloseBuyBySetup[iSym][iSet])
         priceLastCloseBuyBySetup[iSym][iSet] = price;
      if(price < priceLastCloseBuyBySymbol[iSym])
         priceLastCloseBuyBySymbol[iSym] = price;

      for(int i=0; i < TF_COUNT; i++){
        closeBuy[iSym][i] = false; closeSell[iSym][i] = false;
      }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateOpenBuy(int iSym, int iSet, double price){
     if(useCloseDistance)
       priceLastCloseBuyBySetup[iSym][iSet] = 0;
     if(useOpenDistance){
       priceLastOpenBuyBySetup[iSym][iSet] = priceLastOpenBuyBySymbol[iSym] = price;
       countCandleOpenBuyBySetup[iSym][iSet] = countCandleOpenBuyBySymbol[iSym] = 0;
       if(price < priceLastOpenSellBySetup[iSym][iSet])
         priceLastOpenSellBySetup[iSym][iSet] = price;
       if(price < priceLastOpenSellBySymbol[iSym])
         priceLastOpenSellBySymbol[iSym] = price;
       UpdateCloseSell( iSym, iSet, price);
       
       //if(price < priceLastCloseBuyBySetup[iSym][iSet])
       //  priceLastCloseBuyBySetup[iSym][iSet] = price;
       //if(price < priceLastCloseBuyBySymbol[iSym])
       //  priceLastCloseBuyBySymbol[iSym] = price;
     
       for(int i=0; i < TF_COUNT; i++){
         buySignal[iSym][i] = false; sellSignal[iSym][i] = false;
       }
     }
  }
  //+------------------------------------------------------------------+
  void UpdateOpenSell(int iSym, int iSet, double price){
     if(useCloseDistance)
       priceLastCloseSellBySetup[iSym][iSet] = 0;
     if(useOpenDistance){
       priceLastOpenSellBySetup[iSym][iSet] = priceLastOpenSellBySymbol[iSym] = price;
       countCandleOpenSellBySetup[iSym][iSet] = countCandleOpenSellBySymbol[iSym] = 0;
       
       if(price > priceLastOpenBuyBySetup[iSym][iSet])
         priceLastOpenBuyBySetup[iSym][iSet] = price;
       if(price < priceLastOpenBuyBySymbol[iSym])
         priceLastOpenBuyBySymbol[iSym] = price;
       UpdateCloseBuy( iSym, iSet, price);
     
      // if(price > priceLastCloseSellBySetup[iSym][iSet])     
      //   priceLastCloseSellBySetup[iSym][iSet] = price;
      // if(price > priceLastCloseSellBySymbol[iSym]) 
      //   priceLastCloseSellBySymbol[iSym] = price;
       for(int i=0; i < TF_COUNT; i++){
         buySignal[iSym][i] = false; sellSignal[iSym][i] = false;
       }
     }
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
   if(!timeframes.InUse(iSet)) return;
    if(useOpenDistance){
       countCandleOpenBuyBySetup[iSym][iSet]++;
       countCandleOpenSellBySetup[iSym][iSet]++;
       if(timeframes.DefaultPosition() == iSet){
         countCandleOpenBuyBySymbol[iSym]++;
         countCandleOpenSellBySymbol[iSym]++;
       }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    if(!timeframes.InUse(iSet)) return;
    
    double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
    double ask = MarketInfo(core.getSymbol(iSym),MODE_ASK);
    
    //Print(StringConcatenate("));
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
    double atr = timeframes.getAtrSlow(iSym,iSet);
    double atr_default = timeframes.getAtrSlow(iSym,timeframes.DefaultPosition());
    if(atr == 0 || atr_default == 0){ 
       Print(StringConcatenate("WARNING ATR == 0 EADistances::UpdateSignal - ",core.getSymbol(iSym),timeframes.ValueToStr(iSet) ));
       return;
    }
    
    if(useOpenDistance)
    {
      if((atrOpenDistanceBySetup == 0 || (priceLastOpenBuyBySetup[iSym][iSet] == 0 || (((priceLastOpenBuyBySetup[iSym][iSet] - bid)/atr) >= atrOpenDistanceBySetup))) &&
         (atrOpenDistanceBySymbol == 0 || (priceLastOpenBuyBySymbol[iSym] == 0 || (((priceLastOpenBuyBySymbol[iSym] - bid)/atr_default) >= atrOpenDistanceBySymbol))) &&
         (countCandleOpenBuyBySetup[iSym][iSet] >= candleOpenDistanceBySetup &&  countCandleOpenBuyBySymbol[iSym] >= candleOpendistanceBySymbol) 
      ){
        buySignal[iSym][iSet] = true;
      } 
      
      if((atrOpenDistanceBySetup == 0 || (priceLastOpenSellBySetup[iSym][iSet] == 0 || (((bid - priceLastOpenSellBySetup[iSym][iSet])/atr) >= atrOpenDistanceBySetup))) &&
         (atrOpenDistanceBySymbol == 0 || (priceLastOpenSellBySymbol[iSym] == 0 || (((bid - priceLastOpenSellBySymbol[iSym])/atr_default) >= atrOpenDistanceBySymbol))) &&
         (countCandleOpenSellBySetup[iSym][iSet] >= candleOpenDistanceBySetup && countCandleOpenSellBySymbol[iSym] >= candleOpendistanceBySymbol)
       ){
         sellSignal[iSym][iSet] = true;
      }
      
    }
    if(useCloseDistance)
    {
    
      if(//countCandleCloseBuyBySetup[iSym][iSet] >= candleCloseDistanceBySetup || 
         //countCandleCloseBuyBySymbol[iSym] >= candleClosedistanceBySymbol ||
         (priceLastCloseBuyBySetup[iSym][iSet] == 0 || (((bid - priceLastCloseBuyBySetup[iSym][iSet])/atr) >= atrCloseDistanceBySetup)) //&&
         //(priceLastCloseBuyBySymbol[iSym] == 0 || (((bid - priceLastCloseBuyBySymbol[iSym])/atr_default) >= atrCloseDistanceBySymbol))
         ){
        closeBuy[iSym][iSet] = true;
      }
      if(//countCandleCloseSellBySetup[iSym][iSet] >= candleCloseDistanceBySetup ||
         //countCandleCloseSellBySymbol[iSym] >= candleClosedistanceBySymbol || 
         (atrCloseDistanceBySetup == 0 || (priceLastCloseSellBySetup[iSym][iSet] == 0 || (((priceLastCloseSellBySetup[iSym][iSet] - bid)/atr) >= atrCloseDistanceBySetup))) //&&
         //(atrCloseDistanceBySymbol == 0 || (priceLastCloseSellBySymbol[iSym] == 0 || (((priceLastCloseSellBySymbol[iSym] - bid)/atr_default) >= atrCloseDistanceBySymbol)))
         ){
         closeSell[iSym][iSet] = true;
      }
    }
  }
};
//+------------------------------------------------------------------+