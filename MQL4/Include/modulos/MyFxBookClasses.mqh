//+------------------------------------------------------------------+
//|                                              MyFxBookClasses.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict

#include <modulos/HashMap2.mqh>

HashMap2 *hashSentimentCurrencies = NULL;
HashMap2 *hashSentimentSymbols = NULL;

class SentimentCurrencyClass{
 public:
   string currency;
   double longVolumePercent, shortVolumePercent, netVolumePercent;
   double longLotsSize, shortLotsSize, netLotsSize, netLotsSizePercent;
   double netVolume, longVolume, shortVolume;
   int netPositions, longPositions, shortPositions;
   int longPipsDistance, shortPipsDistance;
   int symbolsCount;
   SentimentCurrencyClass(string _currency){ currency = _currency; };
   void reset(){
      netVolumePercent = longVolumePercent = shortVolumePercent = longLotsSize = shortLotsSize = 0.0;
      netVolume = longVolume = shortVolume = 0.0;
      netPositions = longPositions = shortPositions = 0;
      longPipsDistance = shortPipsDistance = symbolsCount = 0;
   }
   void PrintSentimentCurrency(){
      Print(StringConcatenate("Sentiment Data:",currency," c:",symbolsCount," PERCENT(Vol:",DoubleToStr(netVolumePercent,1),", LotsSize:",DoubleToStr(netLotsSizePercent,1),")",
      " NET(Vol:",DoubleToStr(netVolume,2),", Pos:",netPositions,", LotsSize:",netLotsSize,")",
      " LONG:",DoubleToStr(longVolumePercent,2),"(Vol:",longVolume,", Pos:",longPositions,")(pips:",longPipsDistance,", lotsAvg:", DoubleToString(longLotsSize,2),")",
      " SHORT:",DoubleToStr(shortVolumePercent,2),"(Vol:",shortVolume,", Pos:",shortPositions,")(pips:,",shortPipsDistance,", lotsAvg:", DoubleToString(shortLotsSize,2),")" ));
   }
   double getTotalVolume(){ return longVolume+shortVolume; }
   int getTotalPositions(){ return longPositions+shortPositions; }
};

class SentimentSymbolClass{
 public:
   string symbol, currencyLong, currencyShort;
   int longVolumePercent, shortVolumePercent;
   int longPositions, shortPositions;
   double longVolume, shortVolume;
   double tradersPercent;
   double shortAvgPrice, longAvgPrice, price;
   int shortPipsDistance, longPipsDistance;
   bool validData;
   SentimentSymbolClass(){
      symbol = currencyLong = currencyShort = "";
      longVolumePercent = shortVolumePercent = longPositions = shortPositions = shortPipsDistance = longPipsDistance = 0;
      longVolume = shortVolume = tradersPercent = shortAvgPrice = longAvgPrice = price = 0; validData = true;
   }
   double getTotalVolume(){ return longVolume+shortVolume; }
   int getTotalPositions(){ return longPositions+shortPositions; }
   void PrintSentimentSymbol(){
      Print(StringConcatenate("Sentiment Symbol Data:",symbol,"(",currencyLong,",",currencyShort,"), Price:",price,
      ", Long:",longVolumePercent,"(",longVolume,",",longPositions,")(",longAvgPrice,",",longPipsDistance,")"
      ", Short:",shortVolumePercent,"(",shortVolume,",",shortPositions,")(",shortAvgPrice,",",shortPipsDistance,")" ));
   }
   bool checkSentimentData(){
      validData = true;
      if(longVolumePercent < 0 || longVolumePercent > 100){return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,") longVolumePercent: ", longVolumePercent)); validData = false; }
      if(shortVolumePercent < 0 || shortVolumePercent > 100){return false;  Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), shortVolumePercent: ", shortVolumePercent)); validData = false; }
      if(longVolume <= 0.0){ return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), longVolume: ", longVolume)); validData = false; }
      if(shortVolume <= 0.0){ return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), shortVolume: ", shortVolume)); validData = false; }
      if(longPositions <= 0){ return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), longPositions: ", longPositions)); validData = false; }
      if(shortPositions <= 0){ return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), shortPositions: ", shortPositions)); validData = false; }
      if(tradersPercent < 0.0 || tradersPercent > 100.0){return false;  Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), tradersPercent: ", tradersPercent)); validData = false; }
      if(longAvgPrice <= 0){return false;  Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), longAvgPrice: ", longAvgPrice)); validData = false; }
      if(shortAvgPrice <= 0){return false;  Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), shortAvgPrice: ", shortAvgPrice)); validData = false; }
      if(price <= 0){return false;  Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), price: ", price)); validData = false; }
      if( (longVolumePercent+shortVolumePercent) > 100 || (longVolumePercent+shortVolumePercent) < 99) {
         return false; Print(StringConcatenate("ERROR in MyFxBook Sentiment Data, Symbol(",symbol,"), longVolumePercent+shortVolumePercent: ", longVolumePercent,",",shortVolumePercent)); validData = false; }
      return validData;
   }
};
/// Convenience class for storing objects as hash values.
class HashSentimentSymbol : public HashValue {
    private:
        SentimentSymbolClass *val;
    public:
        HashSentimentSymbol(SentimentSymbolClass *v) { val=v;}
        ~HashSentimentSymbol(){ if(val != NULL) delete(val); }
        SentimentSymbolClass* getVal() { return val; }
};
class HashSentimentCurrency : public HashValue {
    private:
        SentimentCurrencyClass *val;
    public:
        HashSentimentCurrency(SentimentCurrencyClass *v) { val=v;}
        ~HashSentimentCurrency(){ if(val != NULL) delete(val); }
        SentimentCurrencyClass* getVal() { return val; }
};
