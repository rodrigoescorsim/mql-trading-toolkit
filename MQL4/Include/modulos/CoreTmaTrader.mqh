//+------------------------------------------------------------------+
//|                                                    CoreFenix.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict

#include <modulos/MyFxBookLoader.mqh>
#include <modulos/OrdersControl2.mqh>
#include <modulos/Utils.mqh>

#include <modulos/EACore.mqh>
#include <modulos/EAPvaVol.mqh>
#include <modulos/EAZigZagFiboPattern.mqh>


extern string  general_trend_info          = "=== GENERAL TREND SETUP ===";
extern double  trendLimitStopSymbol       = 0;
extern double  trendLimitCloseSymbol      = 0;

extern string  slope_trend_info           = "=== SLOPE TREND SETUP ===";

extern string  sentiment_trend_info       = "=== SENTIMENT TREND SETUP ===";
extern bool    useSentimentMyFxBook       = false;
extern string  myfxbook_dataFile          = "outlook_data.txt";
extern string  myfxbook_fileLock         = "LockFile";
extern int     timeframeSentiment         = 5;
extern int     maxOutdatedSentimentTime   = 60;
extern double  sentimentBalanceBegin      = 10;
extern double  sentimentBalanceStep       = 10;
extern double  sentimentBalanceEnd        = 50;
extern double  sentimentLimitStopSymbol   = 10;
extern double  sentimentLimitCloseSymbol  = 20;
extern string  atr_info                 = "=== ATR SETUP ===";
extern int     atrFastPeriod            = 50;
extern int     atrSlowPeriod            = 500;
extern string  tma_info                 = "=== TMA SETUP ===";
extern bool    useTma                   = true;
extern int     tma_period               = 50;
extern double  tma_threshold            = 0.4;
extern int     tma_atr_period           = 500;
extern double  tma_band_size_M1         = 4.5;
extern double  tma_band_size_M5         = 4.0;
extern double  tma_band_size_M15        = 3.5;
extern double  tma_band_size_H1         = 3;
extern double  tma_band_size_H4         = 2.5;
extern double  tma_band_size_D1         = 2.5;
extern double  tma_band_size_W1         = 2.5;
extern bool    useTmaCloseBar           = true;
extern double  tmaLimitCloseBandDiff    = 1;

extern string  candlePattern_info         = "=== CANDLE PATTERN SETUP ===";
extern bool    useCandlePattern           = false;
extern int     candlePatternType          = 0; // candlePatternType = 0(ALL), 1(engulf), 2(Pinbar)
extern double  engulfMinFill              = 0.9;
extern double  engulfMaxFill              = 1.5;
extern double  pinbarMinShadow            = 2;
extern double  engulfAtrRequired          = 1.5;
extern double  pinbarAtrRequired          = 1.5;
extern double  candlePatternRequired      = 0.0;

//+------------------------------------------------------------------+
//| CORE TYPES
//+------------------------------------------------------------------+
EATimeframes *timeframes;
EACore *core;
EAZigZagFiboPattern * zup;

//+------------------------------------------------------------------+
//| AVG Volume
//+------------------------------------------------------------------+
   double avgVolumeFastData[][2], avgVolumeSlowData[], avgVolumeValue[];
   bool initialSetupBalanceAvgVol[], setupBalanceAvgVol[];
   int setupBalanceAvgVolShift, setupBalanceAvgVolLastShift;
//+------------------------------------------------------------------+
//| PVA Volume
//+------------------------------------------------------------------+
//   double pvaRisingBullData[][TF_COUNT], pvaRisingBearData[][TF_COUNT], pvaClimaxBullData[][TF_COUNT], pvaClimaxBearData[][TF_COUNT];
//   int pvaVolumeValue[][TF_COUNT][3];
//   bool pvaLongFilter[][TF_COUNT], pvaShortFilter[][TF_COUNT], buySignalByPva[][TF_COUNT], sellSignalByPva[][TF_COUNT];
//+------------------------------------------------------------------+
//| TMA / SLOPE
//+------------------------------------------------------------------+
   double tma_data[][TF_COUNT][2], tma_atr_data[][TF_COUNT], tma_slope_data[][TF_COUNT];
   double tma_upper_data[][TF_COUNT], tma_lower_data[][TF_COUNT];
   double buySignalByTma[][TF_COUNT], sellSignalByTma[][TF_COUNT];
//+------------------------------------------------------------------+
//| CANDLE PATTERN
//+------------------------------------------------------------------+
   double engulfValue[], pinbarValue[], candlePatternValue[];
//+------------------------------------------------------------------+
//| SENTIMENT
//+------------------------------------------------------------------+
   //int   sentimentLong[], sentimentShort[], sentimentLong_usdBase[], sentimentShort_usdBase[];
   double sentimentMfbValues[];
   int sentimentMfbTrend[], manualTrend[], symbolTrend[];
   bool trendShortStop[], trendLongStop[], trendShortClose[], trendLongClose[];
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ORDERS
//+------------------------------------------------------------------+
 HashMap<string, Order*> hashOpenOrders;
 int lastBuyOrderBySetup[][TF_COUNT], lastSellOrderBySetup[][TF_COUNT];
 int lastBuyOrderBySymbol[], lastSellOrderBySymbol[];
OrdersBySymbol ordersBySymbol[];
//+------------------------------------------------------------------+
//| TIME VARIABLES
//+------------------------------------------------------------------+
   datetime iTime_Sentiment, period_check_sentiment;
   datetime iTime_currentTF, period_check_currentTF;
   datetime iTime_filterAllTicks, period_check_filterAllTicks;
   bool update_sentiment, update_currentTF, update_allTicks;

//+------------------------------------------------------------------+
//| MESSAGES VARIABLES
//+------------------------------------------------------------------+
   string msgSentiment, msgIndicatorsSignal[], msgZupSignal[], info_symbol[];
//+------------------------------------------------------------------+
//| MARGIN
//+------------------------------------------------------------------+
   // double lotsBySymbol[], buyLotsBySymbol[], sellLotsBySymbol[];
   // double lotsByCurrency[], buyLotsByCurrency[], sellLotsByCurrency[];
   // double marginBySymbol[], marginByCurrency[];
   // double lotsSizeBySymbol[], lotsSizeBySCurrency[];
   // double lotsTotal, lotsHedgeTotal, marginTotal;
   // double marginLevel;
   // int setupBalanceByMargin_shift[];
   // bool setupBalanceByBuyMargin[][TF_COUNT], setupBalanceBySellMargin[][TF_COUNT];
   // static int fibo_maxCount = 20;

//+------------------------------------------------------------------+
//| VARIABLES
//+------------------------------------------------------------------+


   bool firstUpdate, dataWaiting[];
   int countMultiplesOrders;
   double multiplesOrders[];
   string multiplesOrdersType[];
   double takeprofitBySetup[][TF_COUNT], stoplossBySetup[][TF_COUNT];
   int   ticket, ordersClosed;
   bool     tradeSetupEnabled = false;
   bool     useIndicator, usePvaOpen, usePvaFilter, useAvgVolume;
   bool     useManualCurrencyStrength, useTimeLimit;
   string info_balance;

//+------------------------------------------------------------------+
//| initCore
//+------------------------------------------------------------------+
void initCore()
  {
//----
   logMessage(LOG_INFO,"",0,"initCore",StringConcatenate("Initializing EA .."));

   core = new EACore();
   core.initialize();
   timeframes = new EATimeframes(core.getSymbolCount() );

   zup = new EAZigZagFiboPattern(core, timeframes);
   if(zup.UseZigZag()){
      zup.InitZUP();
   }



   period_check_sentiment = period_check_currentTF = period_check_filterAllTicks = 0;
   ordersClosed = 0; marginLevel = marginTotal = 0;
   firstUpdate = true;
   update_allTicks = true;

   usePvaFilter = usePvaVolume && (usePvaRisingFilter || usePvaClimaxFilter);
   usePvaOpen = usePvaVolume && (usePvaRisingOpen || usePvaClimaxOpen);
   useManualCurrencyStrength = (manualStrongCurrenciesStr != "" || manualWeakCurrenciesStr != "");

   useAvgVolume = (useAvgVolumeFilter || useAvgVolumeBalance);
   useIndicator = (useCandlePattern || useAvgVolume || useTma || usePvaVolume);
   tradeSetupEnabled = (zup.UseZigZag() || useIndicator);
   LogDebugLevel = DebugLevel;
   if(myfxbook_dataFile != "") _myfxbook_dataFile = myfxbook_dataFile;
   if(myfxbook_fileLock != "") _myfxbook_fileLock = myfxbook_fileLock;


   if(timeframeSentiment < timeframes.DefaultValue()) timeframeSentiment = timeframes.DefaultValue();



   //ArrayResize(allowedSpread, core.getSymbolCount() ); ArrayInitialize(allowedSpread, true);
   //ArrayResize(currentSpreadBySymbol, core.getSymbolCount() );  ArrayInitialize(currentSpreadBySymbol, 0.0);
   //ArrayResize(maxSpreadBySymbol, core.getSymbolCount() );

   /*ArrayResize(relativeSymbolValue, core.getSymbolCount() ); ArrayInitialize(relativeSymbolValue, 1.0);
   for(int iSym=0; iSym < core.getSymbolCount() ; iSym++){
      double bid = MarketInfo(brokerSymbols[iSym],MODE_BID);
      if(bid > 0){
         relativeSymbolValue[iSym] = (bid / (100000 * MarketInfo(brokerSymbols[iSym],MODE_POINT)));
         logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue: ",brokerSymbols[iSym]," is ",relativeSymbolValue[iSym]));
      }
      else{
         logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue (not found:BID=0): ",brokerSymbols[iSym]," is ",relativeSymbolValue[iSym]));
      }
   }
   if(maxSpread > 0){
      if(useRelativeSpread){
         for(int iSym=0; iSym < core.getSymbolCount() ; iSym++){
            maxSpreadBySymbol[iSym] = MathCeil(maxSpread * relativeSymbolValue[iSym]);
            logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("Max (",maxSpread,") Relative spread from ",brokerSymbols[iSym]," is ",maxSpreadBySymbol[iSym]));
         }
      }
      else ArrayInitialize(maxSpreadBySymbol, maxSpread);
   }
   else ArrayInitialize(maxSpreadBySymbol, 0.0);

   ArrayResize(stopLevelBySymbol, core.getSymbolCount() );
   for(int iSym=0; iSym < core.getSymbolCount() ; iSym++){
      stopLevelBySymbol[iSym] = MarketInfo(brokerSymbols[iSym], MODE_STOPLEVEL);
   }*/

   ArrayResize(takeprofitBySetup, core.getSymbolCount() ); ArrayInitialize(takeprofitBySetup, 0.0);
   ArrayResize(stoplossBySetup, core.getSymbolCount() ); ArrayInitialize(stoplossBySetup, 0.0);

   countMultiplesOrders = 1;
   if(useTakeProfitMultiplesOrders)
   {
      if(takeprofitMultiplesOrders != ""){
         string tokens[];
         countMultiplesOrders =  StringSplit(takeprofitMultiplesOrders,StringGetCharacter(";",0),tokens);
         if(countMultiplesOrders > 1 && (countMultiplesOrders % 2) == 0)
         {
            int countTokens = countMultiplesOrders;
            countMultiplesOrders = countMultiplesOrders/2;
            ArrayResize(multiplesOrders, countMultiplesOrders); ArrayInitialize(multiplesOrders, 0);
            ArrayResize(multiplesOrdersType, countMultiplesOrders);
            int pos = 0;
            for(int i=0; i < countTokens; i+=2){

               multiplesOrdersType[pos] = tokens[i];
               multiplesOrders[pos] = StrToDouble(tokens[i+1]);
               logMessage(LOG_INFO, "", 0, "initCore", StringConcatenate("Initializing takeprofitMultiplesOrders - Type: ",multiplesOrdersType[pos],", Value: ", multiplesOrders[pos]));
               pos++;
            }
         }
         else{
            logMessage(LOG_ERROR, "", 0, "initCore", StringConcatenate("takeprofitMultiplesOrders tokens = ", countMultiplesOrders));
            useTakeProfitMultiplesOrders = false;
            countMultiplesOrders = 1;
         }
      }
   }

   //if(useMarginController){
      ArrayResize(lotsBySymbol, core.getSymbolCount() ); ArrayInitialize(lotsBySymbol, 0);
      ArrayResize(buyLotsBySymbol, core.getSymbolCount() ); ArrayInitialize(buyLotsBySymbol, 0);
      ArrayResize(sellLotsBySymbol, core.getSymbolCount() ); ArrayInitialize(sellLotsBySymbol, 0);
      ArrayResize(marginBySymbol, core.getSymbolCount() ); ArrayInitialize(marginBySymbol, 0);
      ArrayResize(lotsSizeBySymbol, core.getSymbolCount() ); ArrayInitialize(lotsSizeBySymbol, 0);

      ArrayResize(lotsByCurrency, core.getCurrencyCount()); ArrayInitialize(lotsByCurrency, 0);
      ArrayResize(buyLotsByCurrency, core.getCurrencyCount()); ArrayInitialize(buyLotsByCurrency, 0);
      ArrayResize(sellLotsByCurrency, core.getCurrencyCount()); ArrayInitialize(sellLotsByCurrency, 0);
      ArrayResize(marginByCurrency, core.getCurrencyCount()); ArrayInitialize(marginByCurrency, 0);
      ArrayResize(lotsSizeBySCurrency, core.getCurrencyCount()); ArrayInitialize(lotsSizeBySCurrency, 0);

      ArrayResize(setupBalanceByMargin_shift, core.getSymbolCount() ); ArrayInitialize(setupBalanceByMargin_shift, 0);
      ArrayResize(setupBalanceByBuyMargin, core.getSymbolCount() ); ArrayInitialize(setupBalanceByBuyMargin, true);
      ArrayResize(setupBalanceBySellMargin, core.getSymbolCount() ); ArrayInitialize(setupBalanceBySellMargin, true);
   //}
   ArrayResize(ordersBySymbol, core.getSymbolCount() );
   for (int iSym = 0; iSym < core.getSymbolCount() ; iSym++){
      ordersBySymbol[iSym].resetSymbol(core.getSymbol(iSym));
   }
   ArrayResize(msgZupSignal, core.getSymbolCount() );
   ArrayResize(info_symbol, core.getSymbolCount() );
   ArrayResize(msgIndicatorsSignal, core.getSymbolCount() );
   ArrayResize(dataWaiting, core.getSymbolCount() ); ArrayInitialize(dataWaiting, true);
   ArrayResize(lastBuyOrderBySetup, core.getSymbolCount() ); ArrayInitialize(lastBuyOrderBySetup, distanceOrdersBySetup+1);
   ArrayResize(lastSellOrderBySetup, core.getSymbolCount() ); ArrayInitialize(lastSellOrderBySetup, distanceOrdersBySetup+1);
   ArrayResize(lastBuyOrderBySymbol, core.getSymbolCount() ); ArrayInitialize(lastBuyOrderBySymbol, distanceOrdersBySymbol+1);
   ArrayResize(lastSellOrderBySymbol, core.getSymbolCount() ); ArrayInitialize(lastSellOrderBySymbol, distanceOrdersBySymbol+1);

   ArrayResize(buySignalByIndicators, core.getSymbolCount() ); ArrayInitialize(buySignalByIndicators, false);
   ArrayResize(sellSignalByIndicators, core.getSymbolCount() ); ArrayInitialize(sellSignalByIndicators, false);
   ArrayResize(buySignalByTma, core.getSymbolCount() ); ArrayInitialize(buySignalByTma, false);
   ArrayResize(sellSignalByTma, core.getSymbolCount() ); ArrayInitialize(sellSignalByTma, false);

   int count = 0; string _currency, _currencies[];

   if(useSentimentMyFxBook){
      update_sentiment = false;
      ArrayResize(symbolTrend, core.getSymbolCount() ); ArrayInitialize(symbolTrend, 0);
      ArrayResize(trendShortStop, core.getSymbolCount() ); ArrayInitialize(trendShortStop, false);
      ArrayResize(trendLongStop, core.getSymbolCount() ); ArrayInitialize(trendLongStop, false);
      ArrayResize(trendShortClose, core.getSymbolCount() ); ArrayInitialize(trendShortClose, false);
      ArrayResize(trendLongClose, core.getSymbolCount() ); ArrayInitialize(trendLongClose, false);
   }

   if(useManualCurrencyStrength){
      ArrayResize(manualTrend, core.getCurrencyCount()); ArrayInitialize(manualTrend, 0);

      if(manualStrongCurrenciesStr != ""){
         count =  StringSplit(manualStrongCurrenciesStr,StringGetCharacter(",",0),_currencies);
         for(int i=0; i < count; i++){
            _currency = _currencies[i];
            if(core.hashCurrencyPos.contains(_currency)) {
               manualTrend[core.hashCurrencyPos[_currency]]++;
               logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing manual Strong currencies: Add ", _currency));
            }
         }
      }
      if(manualWeakCurrenciesStr != ""){
         count =  StringSplit(manualWeakCurrenciesStr,StringGetCharacter(",",0),_currencies);
         for(int i=0; i < count; i++){
            _currency = _currencies[i];
            if(core.hashCurrencyPos.contains(_currency)) {
               manualTrend[core.hashCurrencyPos[_currency]]--;
               logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing manual Weak currencies: Add ", _currency));
            }
         }
      }

      if(!useSentimentMyFxBook)
      {
         int iCur1=0, iCur2=0;
         for(int i=0; i<core.getSymbolCount() ; i++){
            string _symbol = core.getRawSymbol(i);
            string _currency1 = StringSubstr(_symbol, 0,3);
            string _currency2 = StringSubstr(_symbol, 3,3);
            if(core.hashCurrencyPos.contains(_currency1)){
               iCur1 = core.hashCurrencyPos[_currency1];
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "initCore", StringConcatenate("Stop trading ",_symbol,". Currency1 (",_currency1,") not found in core.hashCurrencyPos"));
               trendShortStop[i] = trendLongStop[i] = true;
               continue;
            }
            if(core.hashCurrencyPos.contains(_currency2)){
               iCur2 = core.hashCurrencyPos[_currency2];
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "initCore", StringConcatenate("Stop trading ",_symbol,". Currency2 (",_currency2,") not found in core.hashCurrencyPos"));
               trendShortStop[i] = trendLongStop[i] = true;
               continue;
            }
            symbolTrend[i] += manualTrend[iCur1] - manualTrend[iCur2];
         }
      }
   }

   if(useSentimentMyFxBook){
      ArrayResize(sentimentMfbValues, core.getCurrencyCount()); ArrayInitialize(sentimentMfbValues, 0.0);
      ArrayResize(sentimentMfbTrend, core.getCurrencyCount()); ArrayInitialize(sentimentMfbTrend, 0);
      string currencyArray[];
      core.getCurrencyArray(currencyArray);
      initSentimentMyFxBookData(currencyArray);
      updateSentimentMyFxBook();
   }

   if(useIndicator){
      ArrayResize(filterSignalByTimeframe, core.getSymbolCount() ); ArrayInitialize(filterSignalByTimeframe, false);
      ArrayResize(atrFastData, core.getSymbolCount() ); ArrayInitialize(atrFastData, 0);
      ArrayResize(atrSlowData, core.getSymbolCount() ); ArrayInitialize(atrSlowData, 0);
      ArrayResize(bars, core.getSymbolCount() ); ArrayInitialize(bars, 0);
   }
   if(useAvgVolume){
      ArrayResize(avgVolumeFastData, core.getSymbolCount() ); ArrayInitialize(avgVolumeFastData, 0);
      ArrayResize(avgVolumeSlowData, core.getSymbolCount() ); ArrayInitialize(avgVolumeSlowData, 0);
      ArrayResize(avgVolumeValue, core.getSymbolCount() ); ArrayInitialize(avgVolumeValue, 0);
   }
   ArrayResize(initialSetupBalanceAvgVol, TF_COUNT); ArrayInitialize(initialSetupBalanceAvgVol, true);
   ArrayResize(setupBalanceAvgVol, TF_COUNT); ArrayInitialize(setupBalanceAvgVol, true);
   setupBalanceAvgVolShift = setupBalanceAvgVolLastShift = 0;
   if(useAvgVolumeBalance){
      logMessage(LOG_WARN, "", timeframes.DefaultValue(), "initCore", StringConcatenate("AvgVolumeBalance enabled: ",avgVB_initial_setup));
      string setupBalanceStr[];
      int _count =  StringSplit(avgVB_initial_setup,StringGetCharacter(",",0),setupBalanceStr);
      if(_count == TF_COUNT){
         for(int iSet=0; iSet < TF_COUNT; iSet++){
            if(setupBalanceStr[iSet] == "0"){
               initialSetupBalanceAvgVol[iSet] = setupBalanceAvgVol[iSet] = false;
               logMessage(LOG_WARN, "", timeframes.DefaultValue(), "initCore", StringConcatenate("AvgVolumeBalance setup(",iSet,") = ",setupBalanceStr[iSet], "(false)"));
            }
            else{
               initialSetupBalanceAvgVol[iSet] = setupBalanceAvgVol[iSet] = true;
               logMessage(LOG_WARN, "", timeframes.DefaultValue(), "initCore", StringConcatenate("AvgVolumeBalance setup(",iSet,") = ",setupBalanceStr[iSet],"(true)"));
            }
         }
      }
      else{
         useAvgVolumeBalance = false;
         logMessage(LOG_CRITICAL, "", timeframes.DefaultValue(), "initCore", StringConcatenate("failed to initialize AvgVolumeBalance: ",avgVB_initial_setup));
      }
   }
   if(useTma){
      ArrayResize(tma_data, core.getSymbolCount() ); ArrayInitialize(tma_data, 0);
      ArrayResize(tma_atr_data, core.getSymbolCount() ); ArrayInitialize(tma_atr_data, 0);
      ArrayResize(tma_slope_data, core.getSymbolCount() ); ArrayInitialize(tma_slope_data, 0);
      ArrayResize(tma_upper_data, core.getSymbolCount() ); ArrayInitialize(tma_upper_data, 0);
      ArrayResize(tma_lower_data, core.getSymbolCount() ); ArrayInitialize(tma_lower_data, 0);
      ArrayResize(buySignalByTma, core.getSymbolCount() ); ArrayInitialize(buySignalByTma, 0);
      ArrayResize(sellSignalByTma, core.getSymbolCount() ); ArrayInitialize(sellSignalByTma, 0);
   }
   if(useCandlePattern){
      ArrayResize(engulfValue, core.getSymbolCount() ); ArrayInitialize(engulfValue, 0);
      ArrayResize(pinbarValue, core.getSymbolCount() ); ArrayInitialize(pinbarValue, 0);
      ArrayResize(candlePatternValue, core.getSymbolCount() ); ArrayInitialize(candlePatternValue, 0);
   }
}
//+------------------------------------------------------------------+
void deinitCore()
{
   if(core != NULL) delete(core);
   if(timeframes != NULL) delete(timeframes);
   if(zup != NULL) delete(zup);


}

//+------------------------------------------------------------------+
void updateSentiment(){
   update_sentiment = false;
   if(useSentimentMyFxBook){
      iTime_Sentiment = iTime(NULL,timeframeSentiment,0);
      if(period_check_sentiment != iTime_Sentiment){
         update_sentiment = true;
         updateSentimentMyFxBook();
         period_check_sentiment = iTime_Sentiment;
      }
   }
}
//+------------------------------------------------------------------+
void updateCurrentTimeframe(){
   update_currentTF = false;
   iTime_currentTF = iTime(NULL,timeframes.DefaultValue(),0);
   if(period_check_currentTF != iTime_currentTF){
      update_currentTF = true;
      period_check_currentTF = iTime_currentTF;
   }
}
//+------------------------------------------------------------------+
void updateStopLossAndTakeProfit()
{
   for(int iSymbol=0; iSymbol < core.getSymbolCount(); iSymbol++)
   {
      for(int iSetup=0; iSetup < TF_COUNT; iSetup++)
      {
         if(timeframes.Updated(iSymbol,iSetup))
         {
           if(takeprofit_atr > 0){
              takeprofitBySetup[iSymbol][iSetup] = takeprofit_atr * atrSlowData[core.getSymbolPos()][iSetup];
           }
           if(stoploss_atr > 0){
             stoplossBySetup[core.getSymbolPos()][iSetup] = stoploss_atr * atrSlowData[core.getSymbolPos()][iSetup];
           }
         }
      }
   }
}
//+------------------------------------------------------------------+
void updateIndicatorsData()
{
   for(int iSymbol=0; iSymbol < core.getSymbolCount(); iSymbol++)
   {
     for(int iSetup = 0; iSetup < TF_COUNT; iSetup++)
     {
       if(timeframes.Updated(iSymbol,iSetup))
       {
         int bars_ = iBars(core.getSymbol(iSymbol), timeframes.Value(iSetup))-1;
         int atrFastPeriod_ = (bars_ < atrFastPeriod) ? bars_ : atrFastPeriod;
         int atrSlowPeriod_ = (bars_ < atrSlowPeriod) ? bars_ : atrSlowPeriod;
         bars[iSymbol][iSetup] = bars_;
         atrFastData[iSymbol][iSetup] = iATR(core.getSymbol(iSymbol), timeframes.Value(iSetup), atrFastPeriod_, 0);
         atrSlowData[iSymbol][iSetup] = iATR(core.getSymbol(iSymbol), timeframes.Value(iSetup), atrSlowPeriod_, 0);
       }

     }

      dataWaiting[iSymbol] = false;
      firstUpdate = false;
   }
}
//+------------------------------------------------------------------+
/*void updateIndicatorsSignals()
{
   if(useAvgVolume && timeframes.Updated(iSymbol, avgVolumeTfPos)){
      if(avgVolumeSlowData[iSymbol] != 0)
         avgVolumeValue[iSymbol] = avgVolumeFastData[iSymbol][0] / avgVolumeSlowData[iSymbol];
      else
         avgVolumeValue[iSymbol] = 1;
   }
}*/
//+------------------------------------------------------------------+
/*void updateIndicatorsMessages(){

   msgIndicatorsSignal[iSymbol] = symbol;

   /*if(useBands){
      msgIndicatorsSignal[iSymbol] += " - bbW:"+DoubleToString(bandsWidth[iSymbol],1)+" - bbEx:"+DoubleToString(bandsExpansion[iSymbol],1)+" - bbDiff:"+DoubleToString(bandsTrendExpansion[iSymbol],1);
      msgIndicatorsSignal[iSymbol] += " - bbUpEx:"+DoubleToString(bandsUpperExpansion[iSymbol],1)+" - bbLoEx:"+DoubleToString(bandsLowerExpansion[iSymbol],1);
   }*/
   /*if(useAvgVolume){
      msgIndicatorsSignal[iSymbol] += ", Vlm:"+DoubleToString(avgVolumeValue[iSymbol],1);
   }
   /*if(usePvaVolume){
      msgIndicatorsSignal[iSymbol] += ", Pva:"+DoubleToString(pvaVolumeValue[iSymbol],0);
   }
   if(useCandlePattern){
      msgIndicatorsSignal[iSymbol] += ", Engulf:"+DoubleToString(engulfValue[iSymbol],2);
      msgIndicatorsSignal[iSymbol] += ", Pinbar:"+DoubleToString(pinbarValue[iSymbol],2);
   }*/
   /*msgIndicatorsSignal[iSymbol] += NL;
}*/

//+------------------------------------------------------------------+
/*void updateIndicatorsTradeSignal()
{
   bool avgVolFilter = false;
   if((!useAvgVolumeFilter || avgVolumeRequiredAbove == 0 || avgVolumeValue[iSymbol] >= avgVolumeRequiredAbove) &&
      (!useAvgVolumeFilter || avgVolumeRequiredBelow == 0 || avgVolumeValue[iSymbol] <= avgVolumeRequiredBelow)
   ){
      avgVolFilter = true; //filterSignalByTimeframe[iSymbol] = true;
   }

   for(int iSetup_=0; iSetup_<TF_COUNT; iSetup_++)
   {
      sellSignalByIndicators[iSymbol][iSetup_] = buySignalByIndicators[iSymbol][iSetup_] = filterSignalByTimeframe[iSymbol][iSetup_] = false;

      if( //((!useCandlePattern || engulfAtrRequired == 0 || engulfValue[iSymbol] <= -engulfAtrRequired) ||
          //(!useCandlePattern || pinbarAtrRequired == 0 || pinbarValue[iSymbol] <= -pinbarAtrRequired)) &&
          //(!useCandlePattern || candlePatternRequired == 0 || candlePatternValue[iSymbol] <= -candlePatternRequired) &&
         ((!usePvaVolume || !usePvaOpen) || sellSignalByPva[iSymbol][iSetup_])
         ){
            sellSignalByIndicators[iSymbol][iSetup_] = true;
         }

      if( //((!useCandlePattern || engulfAtrRequired == 0 || engulfValue[iSymbol] >= engulfAtrRequired) ||
          //(!useCandlePattern || pinbarAtrRequired == 0 || pinbarValue[iSymbol] >= pinbarAtrRequired)) &&
          //(!useCandlePattern || candlePatternRequired == 0 || candlePatternValue[iSymbol] >= candlePatternRequired) &&
         ((!usePvaVolume || !usePvaOpen) || buySignalByPva[iSymbol][iSetup_])
         ) {
         buySignalByIndicators[iSymbol][iSetup_] = true;
      }
   }
}*/
//+------------------------------------------------------------------+
void updateCurrencyTrendSignals(){
   if(update_sentiment){
      ArrayInitialize(symbolTrend, 0.0);
      ArrayInitialize(trendShortStop, false); ArrayInitialize(trendLongStop, false);
      ArrayInitialize(trendShortClose, false); ArrayInitialize(trendLongClose, false);

      for(int i=0; i<core.getSymbolCount() ; i++)
      {
         if(useSentimentMyFxBook || useManualCurrencyStrength){
            string _currency1, _currency2, _symbol;
            int iCur1 = 0, iCur2 = 0, myfxbookSymbolTrend;
            double myfxbookSymbolValue;

            SentimentCurrencyClass *_sentimentCurrency1, *_sentimentCurrency2;
            _symbol = core.getRawSymbol(i);
            _currency1 = StringSubstr(_symbol, 0,3);
            _currency2 = StringSubstr(_symbol, 3,3);
            if(core.hashCurrencyPos.contains(_currency1)){
               iCur1 = core.hashCurrencyPos[_currency1];
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "updateCurrencyTrendSignals", StringConcatenate("Stop trading ",_symbol,". Currency1 (",_currency1,") not found in core.hashCurrencyPos"));
               trendShortStop[i] = trendLongStop[i] = true;
               continue;
            }
            if(core.hashCurrencyPos.contains(_currency2)){
               iCur2 = core.hashCurrencyPos[_currency2];
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "updateCurrencyTrendSignals", StringConcatenate("Stop trading ",_symbol,". Currency2 (",_currency2,") not found in core.hashCurrencyPos"));
               trendShortStop[i] = trendLongStop[i] = true;
               continue;
            }
            if(useManualCurrencyStrength){
               symbolTrend[i] += manualTrend[iCur1] - manualTrend[iCur2];
            }

            if(useSentimentMyFxBook){
               myfxbookSymbolTrend = 0;
               datetime timeCurrent = TimeLocal();

               if((timeCurrent - time_lastUpdateMFB) > (maxOutdatedSentimentTime*60)){
                  trendShortStop[i] = trendLongStop[i] = true;
                  logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "updateCurrencyTrendSignals", StringConcatenate(
                     "Stop trading ",_symbol,". MyFxBook Sentiment outdated. timeCurrent: ",timeCurrent,", updatedMFB: ",time_lastUpdateMFB,", maxOutdatedtTime: ",maxOutdatedSentimentTime));
                  continue;
               }
               _sentimentCurrency1 = hashSentimentCurrencies[_currency1];
               _sentimentCurrency2 = hashSentimentCurrencies[_currency2];

               if(_sentimentCurrency1 == NULL || _sentimentCurrency2 == NULL){
                  trendShortStop[i] = trendLongStop[i] = true;
                  logMessage(LOG_ERROR, _symbol, timeframes.DefaultValue(), "updateCurrencyTrendSignals", StringConcatenate(
                     "Stop trading ",_symbol,".Not found objects in hashSentimentCurrencies."));
                  continue;
               }
               myfxbookSymbolValue = _sentimentCurrency1.netVolumePercent  - _sentimentCurrency2.netVolumePercent;
               myfxbookSymbolTrend = 0;

               for(double j=sentimentBalanceBegin; j <= sentimentBalanceEnd; j+=sentimentBalanceStep){
                  if(myfxbookSymbolValue >= j) myfxbookSymbolTrend --;
                  else break;
               }
               for(double j=-sentimentBalanceBegin; j >= -sentimentBalanceEnd; j-=sentimentBalanceStep){
                  if(myfxbookSymbolValue <= j) myfxbookSymbolTrend ++;
                  else break;
               }
               symbolTrend[i] += myfxbookSymbolTrend;

               if(sentimentLimitStopSymbol != 0 && myfxbookSymbolValue <= sentimentLimitStopSymbol){ trendShortStop[i] = true; }
               if(sentimentLimitStopSymbol != 0 && myfxbookSymbolValue >= -sentimentLimitStopSymbol){ trendLongStop[i] = true; }
               if(sentimentLimitCloseSymbol != 0 && myfxbookSymbolValue <= sentimentLimitCloseSymbol){ trendShortClose[i] = true; }
               if(sentimentLimitCloseSymbol != 0 && myfxbookSymbolValue >= -sentimentLimitCloseSymbol){ trendLongClose[i] = true; }
            }
         }
         if(trendLimitStopSymbol != 0 && symbolTrend[i] >= trendLimitStopSymbol){ trendShortStop[i] = true; }
         if(trendLimitStopSymbol != 0 && symbolTrend[i] <= -trendLimitStopSymbol){ trendLongStop[i] = true; }
         if(trendLimitCloseSymbol != 0 && symbolTrend[i] >= trendLimitCloseSymbol){ trendShortClose[i] = true; }
         if(trendLimitCloseSymbol != 0 && symbolTrend[i] <= -trendLimitCloseSymbol){ trendLongClose[i] = true; }
      }
   }
}
//+------------------------------------------------------------------+
bool checkMarginLevel(){
   double margin_level = 0;
   if(marginLevelMin > 0 && marginLevel > 0){
      //Print(StringConcatenate("OnTick - AccountEquity:",AccountEquity(),", AccountMargin:",AccountMargin(),", margin_level:",margin_level));
      if(marginLevel < marginLevelMin){
         //Print(StringConcatenate("MarginLevelMin WARN - AccountEquity:",equity,", AccountMargin:",accountMargin,", margin_level:",margin_level,", marginLevelMin:",marginLevelMin));
         return false;
      }
   }
   return true;
}
//+------------------------------------------------------------------+
void updateMarginController(){

   string _currency1, _currency2, _symbol;
   int pos1, pos2;
   double fullEquity = AccountEquity() * AccountLeverage();

   ArrayInitialize(lotsBySymbol, 0); ArrayInitialize(marginBySymbol, 0);
   ArrayInitialize(buyLotsBySymbol, 0); ArrayInitialize(sellLotsBySymbol, 0);
   ArrayInitialize(lotsSizeBySymbol, 0);

   if(marginPerCurrency > 0){
      ArrayInitialize(lotsByCurrency, 0); ArrayInitialize(marginByCurrency, 0);
      ArrayInitialize(buyLotsByCurrency, 0); ArrayInitialize(sellLotsByCurrency, 0);
      ArrayInitialize(lotsSizeBySCurrency, 0);
   }
   foreachm(string,key,Order*,order,hashOpenOrders)
   {
       if(order != NULL){
         //logMessage(LOG_DEBUG, brokerSymbols[order.iSymbol], timeframe, "updateMarginController", StringConcatenate("Synchronizing memory: order removed from memory, ticket: ",order.ticket));
         if(order.orderType == OP_BUY){
            buyLotsBySymbol[order.iSymbol] += order.lots;
         }
         else if(order.orderType == OP_SELL){
            sellLotsBySymbol[order.iSymbol] += order.lots;
         }
       }
   }
   marginTotal = lotsTotal = lotsHedgeTotal = 0;
   for(int iSym=0; iSym < core.getSymbolCount() ; iSym++){
      lotsBySymbol[iSym] = buyLotsBySymbol[iSym] - sellLotsBySymbol[iSym];
      lotsSizeBySymbol[iSym] = LotSize * lotsBySymbol[iSym];
      marginBySymbol[iSym] = (lotsSizeBySymbol[iSym]/fullEquity)*100;

      if(marginPerCurrency){
         _symbol = core.getRawSymbol(iSym);
         _currency1 = StringSubstr(_symbol, 0,3);
         _currency2 = StringSubstr(_symbol, 3,3);
         pos1 = core.hashCurrencyPos[_currency1];
         pos2 = core.hashCurrencyPos[_currency2];
         lotsByCurrency[pos1] += lotsBySymbol[iSym];
         lotsByCurrency[pos2] -= lotsBySymbol[iSym];
         marginByCurrency[pos1] += marginBySymbol[iSym];
         marginByCurrency[pos2] -= marginBySymbol[iSym];
       }
       marginTotal += MathAbs(marginBySymbol[iSym]);
       lotsTotal += buyLotsBySymbol[iSym] + sellLotsBySymbol[iSym];
       lotsHedgeTotal += MathAbs(lotsBySymbol[iSym]);

      if(useSetupBalanceByMargin){
         int shift = 0;
         if(marginBySymbol[iSym] > (marginPerSymbol*setupBalance_marginBegin)){
            shift = 1;
            for(double currentMarginStep = setupBalance_marginBegin; currentMarginStep < 1; currentMarginStep += setupBalance_marginStep){
                if(marginBySymbol[iSym] > (marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] <= (marginPerSymbol*(currentMarginStep+setupBalance_marginStep))){ break; }
                else{ shift++; }
            }
         }
         else if(marginBySymbol[iSym] < -(marginPerSymbol*setupBalance_marginBegin) ){
            shift = -1;
            for(double currentMarginStep = setupBalance_marginBegin; currentMarginStep < 1; currentMarginStep += setupBalance_marginStep){
                if(marginBySymbol[iSym] < -(marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] >= -(marginPerSymbol*(currentMarginStep+setupBalance_marginStep))){ break; }
                else{ shift--; }
            }
         }
         if(setupBalanceByMargin_shift[iSym] != shift){
            if(shift == 0){
               for(int i=0; i<TF_COUNT; i++){
                  setupBalanceByBuyMargin[iSym][i] = true;
                  setupBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift > 0){
               for(int i=0; i<TF_COUNT; i++){
                  setupBalanceByBuyMargin[iSym][i] = (i >= shift) ? true : false;
                  setupBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift < 0){
               for(int i=0; i<TF_COUNT; i++){
                  setupBalanceByBuyMargin[iSym][i] = true;
                  setupBalanceBySellMargin[iSym][i] = (i >= (-shift)) ? true : false;
               }
            }
         }
         setupBalanceByMargin_shift[iSym] = shift;
      }
   }
}
//+------------------------------------------------------------------+
