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
extern string  Sentiment1_Info               = "=====================================";
extern string  Sentiment2_Info               = "========== SENTIMENT SETUP ==========";
extern string  Sentiment3_Info               = "=====================================";
extern bool    useSentiment                  = false;
extern int     sentiment_timeframe           = 1; 
extern double  sentiment_openBuyAbove        = 95;
extern double  sentiment_openBuyBelow        = 55;
extern double  sentiment_openSellAbove       = 45;
extern double  sentiment_openSellBelow       = 05;
extern double  sentiment_closeBuyAbove       = 60;
extern double  sentiment_closeBuyBelow       = 05;
extern double  sentiment_closeSellAbove      = 95;
extern double  sentiment_closeSellBelow      = 40;
extern SIGNAL_TYPE sentiment_openSignalType  = AND;
extern SIGNAL_TYPE sentiment_closeSignalType = OR;
extern bool sentiment_test = false;


//+------------------------------------------------------------------+
//| Class EASentiment
//+------------------------------------------------------------------+
class EASentiment : public EAIndicator
{
//+------------------------------------------------------------------+
private:
  bool update_sentiment;
  datetime iTime_Sentiment, period_check_sentiment; 
      
  double symbolLong[]; 
  double symbolShort[];

public:
//+------------------------------------------------------------------+
public:
   EASentiment(EACore* _core, EATimeframes* _timeframes)
      : EAIndicator(_core, _timeframes, "EASentiment")
   {
      if(useSentiment)
      {
        openSignalType  = sentiment_openSignalType;
        closeSignalType = sentiment_closeSignalType;
        tickUpdate = true;
        
        ArrayResize(symbolLong, core.getSymbolCount()); ArrayInitialize(symbolLong, -1);
        ArrayResize(symbolShort, core.getSymbolCount()); ArrayInitialize(symbolShort, -1);
        
        string currencies[];
        core.getCurrencyArray(currencies);
    
        initSentimentMyFxBookData(currencies);

      }
      if(sentiment_test)
         updateSentiment();

   }
   //+------------------------------------------------------------------+
   ~EASentiment()
   {

   }
   //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
   //+------------------------------------------------------------------+
   virtual void UpdateAllData()
   {
     if(!sentiment_test)
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
       if( !hashSentimentCurrencies.hContainsKey(currency1)){
         Print(StringConcatenate("EASentiment::UpdateSignal - Currency1 (",currency1,") not found!!"));
         return;
       }
       if( !hashSentimentCurrencies.hContainsKey(currency2)){
         Print(StringConcatenate("EASentiment::UpdateSignal - Currency2 (",currency2,") not found!!"));
         return;
       }
      //sentimentSymbol = hashSentimentSymbols[symbol];
      //sentimentCurrency1 = hashSentimentCurrencies.hGet(currency1);
      //sentimentCurrency2 = hashSentimentCurrencies.hGet(currency2);
      
      double currency1long = sentimentCurrency1.longVolumePercent;
      double currency1short = sentimentCurrency1.shortVolumePercent;
      double currency2long = sentimentCurrency2.longVolumePercent;
      double currency2short = sentimentCurrency2.shortVolumePercent;
      
      symbolLong[iSym] = (currency1long + currency2short) / 2; 
      symbolShort[iSym] = (currency1short + currency2long) / 2; 

      if(symbolLong[iSym] > sentiment_openBuyAbove || symbolLong[iSym] < sentiment_openBuyBelow){
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            buySignal[iSym][iSet] = true;
         }
      }
      if(symbolLong[iSym] > sentiment_openSellAbove || symbolLong[iSym] < sentiment_openSellBelow){
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            sellSignal[iSym][iSet] = true;
         }
      }

      if(symbolLong[iSym] > sentiment_closeBuyAbove || symbolLong[iSym] < sentiment_closeBuyBelow){
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeBuy[iSym][iSet] = true;
         }
      }
      if(symbolLong[iSym] > sentiment_closeSellAbove || symbolLong[iSym] < sentiment_closeSellBelow){
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(!timeframes.InUse(iSet)) continue;
            closeSell[iSym][iSet] = true;
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
      info += StringConcatenate("Buy(",buy,") Sell(",sell,") CloseBuy(",cbuy,") CloseSell(",csell,")" );
      return info;
   }
   //+------------------------------------------------------------------+
  void updateSentiment(){
     update_sentiment = false;
  
     iTime_Sentiment = iTime(NULL,sentiment_timeframe,0); 
     if(period_check_sentiment != iTime_Sentiment){
        update_sentiment = true;
        updateSentimentMyFxBook();
        period_check_sentiment = iTime_Sentiment;
     }
  
  }
  //+------------------------------------------------------------------+ 
};
//+------------------------------------------------------------------+
