//+------------------------------------------------------------------+
//|                                                  EATradeTime.mqh |
//|                                                 Rodrigo Escorsim |
//|                                 https://www.rodrigo.escorsim.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Escorsim"
#property link      "https://www.rodrigo.escorsim.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
#include <modulos/MyFxBookLoader.mqh>
//+------------------------------------------------------------------+
//| Externs
//+------------------------------------------------------------------+
extern string  SentimentScale1_Info               = "===========================================";
extern string  SentimentScale2_Info               = "========== SENTIMENT SCALE SETUP ==========";
extern string  SentimentScale3_Info               = "===========================================";
extern bool    useSentimentScale                  = false;
extern int     sscale_timeframe              = 1; 
extern double  sscale_closeTolerance         = 2;
extern double  sscale_sellLevel1             = 60;
extern double  sscale_sellLevel2             = 70;
extern double  sscale_sellLevel3             = 80;
extern double  sscale_sellLevel4             = 90;
extern double  sscale_buyLevel1              = 40;
extern double  sscale_buyLevel2              = 30;
extern double  sscale_buyLevel3              = 20;
extern double  sscale_buyLevel4              = 10;
extern SIGNAL_TYPE sscale_openSignalType     = AND;
extern SIGNAL_TYPE sscale_closeSignalType    = OR;
extern bool sscale_test = false;


//+------------------------------------------------------------------+
//| Class EASentiment
//+------------------------------------------------------------------+
class EASentimentScale : public EAIndicator
{
//+------------------------------------------------------------------+
private:
  bool update_sentiment;
  datetime iTime_Sentiment, period_check_sentiment; 
      
  double symbolLong[]; 
  double symbolShort[];
  int symbolLevel[];

public:
//+------------------------------------------------------------------+
public:
   EASentimentScale(EACore* _core, EATimeframes* _timeframes)
      : EAIndicator(_core, _timeframes, "EASentiment")
   {
      if(useSentimentScale)
      {
        openSignalType  = sscale_openSignalType;
        closeSignalType = sscale_closeSignalType;
        tickUpdate = true;
        
        ArrayResize(symbolLong, core.getSymbolCount()); ArrayInitialize(symbolLong, -1);
        ArrayResize(symbolShort, core.getSymbolCount()); ArrayInitialize(symbolShort, -1);
        ArrayResize(symbolLevel, core.getSymbolCount()); ArrayInitialize(symbolLevel, 0);
        
        string currencies[];
        core.getCurrencyArray(currencies);
    
        initSentimentMyFxBookData(currencies);

      }
      if(sscale_test)
         updateSentiment();

   }
   //+------------------------------------------------------------------+
   ~EASentimentScale()
   {

   }
   //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
   //+------------------------------------------------------------------+
   virtual void UpdateAllData()
   {
     if(!sscale_test)
       updateSentiment();
   }
   //+------------------------------------------------------------------+
   void UpdateData(int iSym, int iSet)
   {
   
   }
   //+------------------------------------------------------------------+
   void UpdateSignal(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   virtual void UpdateSignalBySymbol(int iSym){
   
     if(update_sentiment){
       for(int iSet=0; iSet < TF_COUNT; iSet++){
         if(!timeframes.InUse(iSet)) continue;
         buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
         closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;
       }
     
       string currency1, currency2;
       string symbol = core.getRawSymbol(iSym);
       
       if(StringLen(symbol) == 6) {
         currency1 = StringSubstr(symbol, 0,3);
         currency2 = StringSubstr(symbol, 3,3);
       }
       else{
         Print(StringConcatenate("Invalid Symbol(",symbol,") in EASentiment"));
         return;
       }
       //SentimentSymbolClass *sentimentSymbol;
       SentimentCurrencyClass *sentimentCurrency1;
       SentimentCurrencyClass *sentimentCurrency2;
        
       /*if(!hashSentimentSymbols.contains(symbol)){
         Print(StringConcatenate("EASentiment::UpdateSignal - Symbol (",symbol,") not found!"));
         return;
       }*/
       /*if( !hashSentimentCurrencies.contains(currency1)){
         Print(StringConcatenate("EASentiment::UpdateSignal - Currency1 (",currency1,") not found!!"));
         return;
       }
       if( !hashSentimentCurrencies.contains(currency2)){
         Print(StringConcatenate("EASentiment::UpdateSignal - Currency2 (",currency2,") not found!!"));
         return;
       }*/
      //sentimentSymbol = hashSentimentSymbols[symbol];
      //sentimentCurrency1 = hashSentimentCurrencies[currency1];
      //sentimentCurrency2 = hashSentimentCurrencies[currency2];
      
      double currency1long = sentimentCurrency1.longVolumePercent;
      double currency1short = sentimentCurrency1.shortVolumePercent;
      double currency2long = sentimentCurrency2.longVolumePercent;
      double currency2short = sentimentCurrency2.shortVolumePercent;
      
      symbolLong[iSym] = (currency1long + currency2short) / 2; 
      symbolShort[iSym] = (currency1short + currency2long) / 2; 
         
      //+------------------------------------------------------------------+
      if(sscale_sellLevel4 > 0 && symbolLong[iSym] > sscale_sellLevel4 && symbolLevel[iSym] > -4) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            sellSignal[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel3 > 0 && symbolLong[iSym] > sscale_sellLevel3 && symbolLevel[iSym] > -3) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            sellSignal[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel2 > 0 && symbolLong[iSym] > sscale_sellLevel2 && symbolLevel[iSym] > -2) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            sellSignal[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel1 > 0 && symbolLong[iSym] > sscale_sellLevel1 && symbolLevel[iSym] > -1) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            sellSignal[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel4 > 0 && symbolLong[iSym] < sscale_buyLevel4 && symbolLevel[iSym] < 4) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = true;
         }
      } 
      else if(sscale_buyLevel3 > 0 && symbolLong[iSym] < sscale_buyLevel3 && symbolLevel[iSym] < 3) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel2 > 0 && symbolLong[iSym] < sscale_buyLevel2 && symbolLevel[iSym] < 2) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel1 > 0 && symbolLong[iSym] < sscale_buyLevel1 && symbolLevel[iSym] < 1) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = true;
         }
      }
      //+------------------------------------------------------------------+
      if(sscale_sellLevel4 > 0 && symbolLong[iSym] < (sscale_sellLevel4-sscale_closeTolerance) && symbolLevel[iSym] < -3) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel3 > 0 && symbolLong[iSym] < (sscale_sellLevel3-sscale_closeTolerance) && symbolLevel[iSym] < -2) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel2 > 0 && symbolLong[iSym] < (sscale_sellLevel2-sscale_closeTolerance) && symbolLevel[iSym] < -1) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel1 > 0 && symbolLong[iSym] < (sscale_sellLevel1-sscale_closeTolerance) && symbolLevel[iSym] < 0) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
         }
      }
      else if(sscale_sellLevel1 > 0 && symbolLong[iSym] < (sscale_sellLevel1-sscale_closeTolerance) && symbolLevel[iSym] < 0) {
         symbolLevel[iSym]++;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel4 > 0 && symbolLong[iSym] > (sscale_buyLevel4+sscale_closeTolerance) && symbolLevel[iSym] > 3) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeBuy[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel3 > 0 && symbolLong[iSym] > (sscale_buyLevel3+sscale_closeTolerance) && symbolLevel[iSym] > 2) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeBuy[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel2 > 0 && symbolLong[iSym] > (sscale_buyLevel2+sscale_closeTolerance) && symbolLevel[iSym] > 1) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeBuy[iSym][iSet] = true;
         }
      }
      else if(sscale_buyLevel1 > 0 && symbolLong[iSym] > (sscale_buyLevel1+sscale_closeTolerance) && symbolLevel[iSym] > 0) {
         symbolLevel[iSym]--;
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeBuy[iSym][iSet] = true;
         }
      }
    
       
     }
   }
   //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      string buy;
      for(int iSet=0; iSet < TF_COUNT; iSet++){ buy = buy + IntegerToString(buySignal[iSym][iSet]); }
      string sell;
      for(int iSet=0; iSet < TF_COUNT; iSet++){ sell = sell + IntegerToString(sellSignal[iSym][iSet]); }
      string cbuy;
      for(int iSet=0; iSet < TF_COUNT; iSet++){ cbuy = cbuy + IntegerToString(closeBuy[iSym][iSet]); }
      string csell;
      for(int iSet=0; iSet < TF_COUNT; iSet++){ csell = csell + IntegerToString(closeSell[iSym][iSet]); }
      
      info += StringConcatenate("Sentiment ",core.getSymbol(iSym),", Long: ",DoubleToStr(symbolLong[iSym],1),", Short: ",DoubleToStr(symbolShort[iSym],1));
      info += StringConcatenate("Buy(",buy,") Sell(",sell,") CloseBuy(",cbuy,") CloseSell(",csell,") Level(",IntegerToString(symbolLevel[iSym]),")" );
      return info;
   }
   //+------------------------------------------------------------------+
  void updateSentiment(){
     update_sentiment = false;
  
     iTime_Sentiment = iTime(NULL,sscale_timeframe,0); 
     if(period_check_sentiment != iTime_Sentiment){
        update_sentiment = true;
        updateSentimentMyFxBook();
        period_check_sentiment = iTime_Sentiment;
     }
  
  }
  //+------------------------------------------------------------------+ 
};
//+------------------------------------------------------------------+
