//+------------------------------------------------------------------+
//|                                                    EASymbols.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <mql4-lib/Collection/HashMap.mqh>
#include <mql4-lib/Collection/HashSet.mqh>
#include <modulos/OrdersControl2.mqh>
#include <modulos/Utils.mqh>
#include <modulos/EATimeframes.mqh>
//+------------------------------------------------------------------+
extern string  sym1_info                   = "===================================";
extern string  sym2_info                   = "========== SYMBOLS SETUP ==========";
extern string  sym3_info                   = "===================================";
extern string  symbol_prefix               = "";
extern string  symbol_suffix               = "";
extern string  symbolsStr1                 = "AUDJPY,AUDNZD,AUDUSD,AUDCHF,AUDCAD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD";
extern string  symbolsStr2                 = "GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,GBPNZD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";//
//extern string  symbolsStr3                 = "";
extern string  symbolsStr3                 = "USDSGD,AUDSGD,CHFSGD,EURDKK,EURHKD,EURNOK,EURPLN,EURSEK,EURSGD,GBPDKK,GBPNOK,GBPSEK,GBPSGD,SGDJPY,USDCNH,USDCZK,USDDKK,USDHKD,USDMXN,USDNOK,USDPLN,USDSEK,XAUUSD,XAUAUD,XAUCHF,XAUEUR,XAUGBP,XAUJPY";
//extern string  symbolsInfo                 = "AUDJPY,AUDNZD,AUDUSD,AUDCHF,AUDCAD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,GBPNZD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,XAUUSD";;
extern string  currenciesStr               = "";
extern string  currenciesInfo              = "USD,EUR,GBP,JPY,CHF,CAD,AUD,NZD,XAU,SGD";
extern FILL_TYPE currencyFillType          = FILL_EXCLUSIVE;
extern string  core1_info                  = "================================";
extern string  core2_info                  = "========== CORE SETUP ==========";
extern string  core3_info                  = "================================";
extern bool    tradeEnabled                = true;
extern bool    alertSignalEnabled          = false;
extern bool    printSignalEnabled          = false;
extern bool    emailSignalEnabled          = false;
extern LOG_TYPE logLevel                   = LOG_INFO;
extern bool    debugIndicators             = false;
extern bool    allTicks                    = true;
extern int     filterAllTicksBySeconds     = 10;
extern int     Magic                       = 36963;
extern bool    useMagicToClose             = true;
extern int     gmt_offset                  = 1;
extern int     gmt_offset_brazil           = -2;
extern INIT_ORDER_TYPE initOrderType       = INIT_NOT_CLOSE;
//extern bool    initCloseLongShortOnly      = true;
extern bool    Hedge                       = false;
extern NO_HEDGE_TYPE noHedgeType           = NO_HEDGE_CLOSE_ALL;
extern bool    closeProfitOnly             = true;
extern double  profitMinByAtr              = 2.5;
extern string  Orders1_Info                = "==================================";
extern string  Orders2_Info                = "========== ORDERS SETUP ==========";
extern string  Orders3_Info                = "==================================";
extern double  maxSpread                   = 30;
extern double  Commission                  = 0;
extern int     Slippage                    = 3;
extern bool    useRelativeSpread           = false;
extern bool    useSpreadAtr                = false;
extern int     spreadAtrTimeframe          = 1;
extern int     spreadAtrPeriod             = 50;
extern double  spreadAtrRatio              = 0.6;
extern double  LotSize                     = 100000;
extern double  Lots                        = 0.01;
extern double  MarginLevelMax              = 150;
extern double  RiskLevel                   = 0.022;
extern double  RiskLevel_multiply          = 0.0;
extern int     maxOrdersBySide             = 2;
extern int     maxOrdersBySetup            = 0;
extern int     maxOrdersBySymbol           = 0;
extern int     maxOrders                   = 200;
extern double  takeprofit_atr              = 0;
extern double  stoploss_atr                = 0;
extern bool    useTargetProfit             = false;
extern double  targetProfitPercentage      = 5;
extern double  targetlossPercentage        = 20;
extern string  trend1_Info                 = "=================================";
extern string  trend2_Info                 = "========== TREND SETUP ==========";
extern string  trend3_Info                 = "=================================";
extern string  currenciesLongOnlySetup1Str       = "";
extern string  currenciesLongOnlySetup2Str       = "";
extern string  currenciesLongOnlySetup3Str       = "";
extern string  currenciesLongOnlySetup4Str       = "";
extern string  currenciesLongOnlySetup5Str       = "";
extern string  currenciesLongOnlySetup6Str       = "";
extern string  currenciesLongOnlySetup7Str       = "";
extern string  currenciesShortOnlySetup1Str      = "";
extern string  currenciesShortOnlySetup2Str      = "";
extern string  currenciesShortOnlySetup3Str      = "";
extern string  currenciesShortOnlySetup4Str      = "";
extern string  currenciesShortOnlySetup5Str      = "";
extern string  currenciesShortOnlySetup6Str      = "";
extern string  currenciesShortOnlySetup7Str      = "";
extern string  currenciesFilterSetup1Str      = "";
extern string  currenciesFilterSetup2Str      = "";
extern string  currenciesFilterSetup3Str      = "";
extern string  currenciesFilterSetup4Str      = "";
extern string  currenciesFilterSetup5Str      = "";
extern string  currenciesFilterSetup6Str      = "";
extern string  currenciesFilterSetup7Str      = "";


//+------------------------------------------------------------------+
class EACore{

 public:
   string symbol, rawSymbol;
   string currency1, currency2;
   int symbolDigits, iSymbol;//, iSetup;
   double symbolPoint, spread, BID, ASK;
   int currency_count, brokerSymbol_count, usdSymbol_count, symbol_count;
   int leverage;
   
   int iCurrency1, iCurrency2;
   double currentSpreadBySymbol[], maxSpreadBySymbol[], commissionBySymbol[];
   double relativeSymbolValue[], stopLevelBySymbol[];
   bool allowedSpread[], update_allTicks;
   datetime iTime_filterAllTicks, period_check_filterAllTicks;
   bool initError;

   double lotsBySymbol[], buyLotsBySymbol[], sellLotsBySymbol[];
   double lotsByCurrency[], buyLotsByCurrency[], sellLotsByCurrency[];
   double marginBySymbol[], marginByCurrency[];
   double lotsSizeBySymbol[], lotsSizeBySCurrency[];
   int setupBalanceByMargin_shift[];
   bool setupBalanceByBuyMargin[][TF_COUNT], setupBalanceBySellMargin[][TF_COUNT];
   double spreadAtr[];

   double riskBySymbol[], pipValueBySymbol[], atrRiskBySymbol[], atrNormRiskBySymbol[];

public:
   string currencies[], brokerSymbols[], rawSymbols[], usdSymbols[][3];
   HashMap<string, int> hashSymbolPos;
   HashMap<string, int> hashRawSymbolPos;
   HashMap<string, int> hashCurrencyPos;
   HashMap<string, int> hashUsdSymbolPos;
   HashMap<string, string> hashCurrencyUsdSymbol;
   HashSet<string> setCurrencyLongOnly[7];
   HashSet<string> setCurrencyShortOnly[7];
   HashSet<string> setCurrencyFilter[7];
   
   HashMap<string, Order*> hashOpenOrders;
   OrdersBySymbol ordersBySymbol[];

   //+------------------------------------------------------------------+
   EACore(){
   }
   //+------------------------------------------------------------------+
   ~EACore(){
   }
   //+------------------------------------------------------------------+
   string getSymbol(int iSym) { return brokerSymbols[iSym]; }
   string getRawSymbol(int iSym) { return rawSymbols[iSym]; }
   string getCurrentSymbol(){ return symbol; }
   int getSymbolPos(){ return iSymbol; }
   string getCurrentRawSymbol(){ return rawSymbol; }
   int getSymbolDigits() { return symbolDigits; }
   int getSymbolDigits(int iSym) { return (int)MarketInfo(brokerSymbols[iSym],MODE_DIGITS); }
   double getSymbolPoint() { return symbolPoint; }
   double getSymbolPoint(int iSym) { return MarketInfo(brokerSymbols[iSym],MODE_POINT); }
   double getSymbolSpread() { return spread; }
   double getSymbolAsk() { return ASK; }
   double getSymbolBid() { return BID; }
   int getSymbolCount() { return symbol_count; }
   int getUsdSymbolCount() { return usdSymbol_count; }
   int getBrokerSymbolCount() { return brokerSymbol_count; }
   int getCurrencyCount() { return currency_count; }
   void getCurrencyArray(string& currencyArray[] ) { ArrayCopy(currencyArray,currencies,0,0,WHOLE_ARRAY); }
   bool AllowedSpread(int iSym) { return allowedSpread[iSym]; }
   double getCurrentStopLevel() { return stopLevelBySymbol[iSymbol]; }
   double getStopLevel(int iSym) { return stopLevelBySymbol[iSym]; }

   //+------------------------------------------------------------------+
   int getSymbolPosition(string _symbol){
      for (int i = 0; i < getSymbolCount() ; i++) {
         if(brokerSymbols[i] == _symbol){
            return i;
         }
      }
      return -1;
   }
   //+------------------------------------------------------------------+
   double lotSizeByRisk(int _iSymbol, int _iSetup, int _orderType){
      double risk = riskBySymbol[_iSymbol];
      if(RiskLevel_multiply != 0){
         if(_orderType == OP_BUY && ordersBySymbol[_iSymbol].ordersBySetup[_iSetup].countBuy > 0){
            risk = risk * (1+(ordersBySymbol[_iSymbol].ordersBySetup[_iSetup].countBuy * RiskLevel_multiply));
         }
         if(_orderType == OP_SELL && ordersBySymbol[_iSymbol].ordersBySetup[_iSetup].countSell > 0){
            risk = risk * (1+(ordersBySymbol[_iSymbol].ordersBySetup[_iSetup].countSell * RiskLevel_multiply));
         }

      }
      double _lots = (AccountEquity()*risk)/10000;
      string _symbol = brokerSymbols[_iSymbol];
      double _lotstep = MarketInfo (_symbol, MODE_LOTSTEP);
      if(useRelativeSpread) _lots = _lots / relativeSymbolValue[iSymbol];
      _lots = NormalizeDouble(_lots, 2);
      //Print(StringConcatenate("Final Lots Calculed: ", _lots));
      return _lots < _lotstep ? _lotstep : _lots;
   }
   // lot size com stoploss definido:
   // double tradeVolume = AccountFreeMargin() * Risk/100 / ( StopLossPoints * MarketInfo( Symbol(), MODE_TICKVALUE ) );
   //+------------------------------------------------------------------+
   void UpdateSymbol(int iSym, EATimeframes *_timeframes)
   {
      iSymbol = iSym;
      symbol    = brokerSymbols[iSymbol];
      rawSymbol = rawSymbols[iSymbol];
      currency1 = StringSubstr(rawSymbol, 0,3);
      currency2 = StringSubstr(rawSymbol, 3,3);
      iCurrency1 = hashCurrencyPos[currency1];
      iCurrency2 = hashCurrencyPos[currency2];

      BID = MarketInfo(symbol,MODE_BID);
      ASK = MarketInfo(symbol,MODE_ASK);
      symbolDigits = (int)MarketInfo(symbol,MODE_DIGITS);
      symbolPoint = MarketInfo(symbol,MODE_POINT);
      if(symbolPoint == 0.0){
         if(currency1 == "XAU") symbolPoint = 0.01;
         if(currency2 == "JPY") symbolPoint = 0.001;
         else symbolPoint = 0.00001;

      }
      currentSpreadBySymbol[iSymbol] = MarketInfo(symbol,MODE_SPREAD);

      if(useSpreadAtr){
         if(_timeframes.IsUpdatedCurrentTF()){
            spreadAtr[iSymbol] = iATR(symbol, spreadAtrTimeframe, spreadAtrPeriod, 1);
         }
         //Print("ATR: " + DoubleToString(spreadAtr[iSymbol]/symbolPoint,5));
         maxSpreadBySymbol[iSymbol] = (spreadAtr[iSymbol] / symbolPoint * spreadAtrRatio) + commissionBySymbol[iSymbol];
         //Print("currentSpreadBySymbol: " + DoubleToString(currentSpreadBySymbol[iSymbol],2) + ", maxSpreadAtrBySymbol: " + DoubleToString(maxSpreadBySymbol[iSymbol],2));
         if(currentSpreadBySymbol[iSymbol] > maxSpreadBySymbol[iSymbol]) 
            allowedSpread[iSymbol] = false;
         else
            allowedSpread[iSymbol] = true;
      }
      else if(maxSpread > 0){
         if(currentSpreadBySymbol[iSymbol] > maxSpreadBySymbol[iSymbol]) 
            allowedSpread[iSymbol] = false;
         else
            allowedSpread[iSymbol] = true;
      }
      else { 
         allowedSpread[iSymbol] = true;
      }
      //logMessage(LOG_WARN, symbol, 0, "OnTick", StringConcatenate("Checking spread: current: ",currentSpreadBySymbol[iSymbol], ", max: ", maxSpreadBySymbol[iSymbol]));
   }

   //+------------------------------------------------------------------+
   void initialize()
   {
      LogDebugLevel = logLevel;
      initError = false;
      period_check_filterAllTicks = 0;

      initSymbolsAndCurrencies();

      ArrayResize(currentSpreadBySymbol, symbol_count);  ArrayInitialize(currentSpreadBySymbol, 0.0);
      ArrayResize(maxSpreadBySymbol, symbol_count); ArrayInitialize(maxSpreadBySymbol, 0.0);
      ArrayResize(commissionBySymbol, symbol_count); ArrayInitialize(commissionBySymbol, 0.0);
      ArrayResize(allowedSpread, symbol_count); ArrayInitialize(allowedSpread, true);
      ArrayResize(relativeSymbolValue, symbol_count); ArrayInitialize(relativeSymbolValue, 1.0);
      ArrayResize(stopLevelBySymbol, symbol_count); ArrayInitialize(stopLevelBySymbol, 0.0);

      ArrayResize(setupBalanceByMargin_shift, symbol_count ); ArrayInitialize(setupBalanceByMargin_shift, 0);
      ArrayResize(setupBalanceByBuyMargin, symbol_count ); ArrayInitialize(setupBalanceByBuyMargin, true);
      ArrayResize(setupBalanceBySellMargin, symbol_count ); ArrayInitialize(setupBalanceBySellMargin, true);

      ArrayResize(spreadAtr, symbol_count);  ArrayInitialize(spreadAtr, 0.0);
      ArrayResize(ordersBySymbol, symbol_count);
      for (iSymbol = 0; iSymbol < symbol_count; iSymbol++){
         ordersBySymbol[iSymbol].resetSymbol( brokerSymbols[iSymbol]);
      }

      for(int iSym=0; iSym < symbol_count; iSym++){
         double bid = MarketInfo(brokerSymbols[iSym],MODE_BID);
         if(bid > 0){
            relativeSymbolValue[iSym] = (bid / (100000 * MarketInfo(brokerSymbols[iSym],MODE_POINT)));
            logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue: ",brokerSymbols[iSym]," is ",relativeSymbolValue[iSym]));
         }
         else{
            logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue (not found:BID=0): ",brokerSymbols[iSym]," is ",relativeSymbolValue[iSym]));
         }
      }

      if(useSpreadAtr){
         if(Commission > 0){
            for(int iSym=0; iSym < symbol_count; iSym++){
            
               commissionBySymbol[iSym] = Commission / MarketInfo(brokerSymbols[iSym],MODE_TICKVALUE);
               Print("MODE_TICKSIZE: "+DoubleToString(MarketInfo(brokerSymbols[iSym],MODE_TICKVALUE),2)+", CommissionBySymbol: " + DoubleToString(commissionBySymbol[iSym],2));
            }
          }
        }
        else if(maxSpread > 0){
          if(useRelativeSpread){
            for(int iSym=0; iSym < symbol_count; iSym++){
               maxSpreadBySymbol[iSym] = MathCeil(maxSpread * relativeSymbolValue[iSym]);
               logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initCore", StringConcatenate("Max (",maxSpread,") Relative spread from ",brokerSymbols[iSym]," is ",maxSpreadBySymbol[iSym]));
            }
         }
         else ArrayInitialize(maxSpreadBySymbol, maxSpread);
      }
      else ArrayInitialize(maxSpreadBySymbol, 0.0);

      ArrayResize(stopLevelBySymbol, symbol_count);
      for(int iSym=0; iSym < symbol_count; iSym++){
         stopLevelBySymbol[iSym] = MarketInfo(brokerSymbols[iSym], MODE_STOPLEVEL);
      }
      
      string currenciesLongOnlyStr[7];
      string currenciesShortOnlyStr[7];
      string currenciesFilterStr[7];
      currenciesLongOnlyStr[0] = currenciesLongOnlySetup1Str;
      currenciesLongOnlyStr[1] = currenciesLongOnlySetup2Str;
      currenciesLongOnlyStr[2] = currenciesLongOnlySetup3Str;
      currenciesLongOnlyStr[3] = currenciesLongOnlySetup4Str;
      currenciesLongOnlyStr[4] = currenciesLongOnlySetup5Str;
      currenciesLongOnlyStr[5] = currenciesLongOnlySetup6Str;
      currenciesLongOnlyStr[6] = currenciesLongOnlySetup7Str;
      currenciesShortOnlyStr[0] = currenciesShortOnlySetup1Str;
      currenciesShortOnlyStr[1] = currenciesShortOnlySetup2Str;
      currenciesShortOnlyStr[2] = currenciesShortOnlySetup3Str;
      currenciesShortOnlyStr[3] = currenciesShortOnlySetup4Str;
      currenciesShortOnlyStr[4] = currenciesShortOnlySetup5Str;
      currenciesShortOnlyStr[5] = currenciesShortOnlySetup6Str;
      currenciesShortOnlyStr[6] = currenciesShortOnlySetup7Str;
      currenciesFilterStr[0] = currenciesFilterSetup1Str;
      currenciesFilterStr[1] = currenciesFilterSetup2Str;
      currenciesFilterStr[2] = currenciesFilterSetup3Str;
      currenciesFilterStr[3] = currenciesFilterSetup4Str;
      currenciesFilterStr[4] = currenciesFilterSetup5Str;
      currenciesFilterStr[5] = currenciesFilterSetup6Str;
      currenciesFilterStr[6] = currenciesFilterSetup7Str;
      
      for(int i=0; i<TF_COUNT;i++)
      {
         if(currenciesLongOnlyStr[i] != ""){
            string _currency, _currencies[];
            int count = StringSplit(currenciesLongOnlyStr[i],StringGetCharacter(",",0),_currencies);
            for(int j=0; j < count; j++){
               _currency = _currencies[j];
               if(!setCurrencyLongOnly[i].contains(_currency)) {
                  setCurrencyLongOnly[i].add(_currency);
                  logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing currencies Long Only: Add ", _currency, " Setup: ", i));
               }
            }
         }
         if(currenciesShortOnlyStr[i] != ""){
            string _currency, _currencies[];
            int count = StringSplit(currenciesShortOnlyStr[i],StringGetCharacter(",",0),_currencies);
            for(int j=0; j < count; j++){
               _currency = _currencies[j];
               if(!setCurrencyShortOnly[i].contains(_currency)) {
                  setCurrencyShortOnly[i].add(_currency);
                  logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing currencies Short Only Add ", _currency, " Setup: ", i));
               }
            }
         }
         if(currenciesFilterStr[i] != ""){
            string _currency, _currencies[];
            int count = StringSplit(currenciesFilterStr[i],StringGetCharacter(",",0),_currencies);
            for(int j=0; j < count; j++){
               _currency = _currencies[j];
               if(!setCurrencyFilter[i].contains(_currency)) {
                  setCurrencyFilter[i].add(_currency);
                  logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing currencies Filter Add ", _currency, " Setup: ", i));
               }
            }
         }
      }
      
      initRiskValues();
      InitCloseOrders();
   }
   //+------------------------------------------------------------------+
   void initRiskValues() {
   
      ArrayResize(riskBySymbol, symbol_count);
      ArrayInitialize(riskBySymbol, RiskLevel);

      ArrayResize(pipValueBySymbol, symbol_count);
      ArrayInitialize(pipValueBySymbol, 0.0);
      ArrayResize(atrRiskBySymbol, symbol_count);
      ArrayInitialize(atrRiskBySymbol, 0.0);
      ArrayResize(atrNormRiskBySymbol, symbol_count);
      ArrayInitialize(atrNormRiskBySymbol, 0.0);
   
      if(symbol_count > 1) {
        for(int iSym=0; iSym < symbol_count; iSym++) {
          string _symbol = rawSymbols[iSym];
          string _brokerSym = brokerSymbols[iSym];
          double _contractSize = MarketInfo(_brokerSym, MODE_LOTSIZE);
          double _point = MarketInfo(_brokerSym, MODE_POINT);
          
          if(_point == 0) {
            logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initRiskValues", "Error MODE_POINT == 0");
            continue;
          }
          
          string _currency1 = StringSubstr(_symbol, 0,3);
          string _currency2 = StringSubstr(_symbol, 3,3);
          
          string usdSymbol1 = _currency2 + "USD";
          string usdSymbol2 = "USD" + _currency2;
          
          if(_currency2 == "USD") 
          {
              pipValueBySymbol[iSym] = 1.0;
          }
          else if(_currency1 == "USD") 
          {
              double bid = MarketInfo(_brokerSym, MODE_BID);
              pipValueBySymbol[iSym] = _contractSize * _point * (1 / bid);
          }
          else if(hashRawSymbolPos.contains(usdSymbol1)) 
          {
             int iSymbolUsd = hashRawSymbolPos[usdSymbol1];
             string brokerSym = brokerSymbols[iSymbolUsd];
             double valueYYYUSD = MarketInfo(brokerSym, MODE_BID);
             pipValueBySymbol[iSym] = _contractSize * _point * valueYYYUSD;
          }
          else if(hashRawSymbolPos.contains(usdSymbol2)) 
          {
             int iSymbolUsd = hashRawSymbolPos[usdSymbol2];
             string brokerSym = brokerSymbols[iSymbolUsd];
             double valueYYYUSD = (1 / MarketInfo(brokerSym, MODE_BID));
             double pointSym = MarketInfo(brokerSymbols[iSym], MODE_POINT);
             pipValueBySymbol[iSym] = _contractSize * _point * valueYYYUSD;
          }
          
          atrRiskBySymbol[iSym] = iATR(_brokerSym, PERIOD_M15, 500, 1) / _point;  
        }
        
        double atrSum = 0.0;
        int atrCount = 0;
        for(int iSym=0; iSym < symbol_count; iSym++) {
            if(atrRiskBySymbol[iSym] != 0) {
              atrSum += atrRiskBySymbol[iSym];
              atrCount++;
            }
        }
        double atrAverage = atrSum / atrCount;
        for(int iSym=0; iSym < symbol_count; iSym++) {
            if(atrRiskBySymbol[iSym] != 0) {
               atrNormRiskBySymbol[iSym] = atrRiskBySymbol[iSym] / atrAverage;
               riskBySymbol[iSym] = RiskLevel * ((1 / pipValueBySymbol[iSym]) / atrNormRiskBySymbol[iSym]);
            }
            else {
               riskBySymbol[iSym] = RiskLevel * 0.66;
            }
            
            logMessage(LOG_WARN, brokerSymbols[iSym], 0, "initRiskValues", 
               StringFormat("Pos: %d - PipValue: %.2f - Atr: %.2f - AtrNorm: %.2f - Risk: %.4f", 
                  iSym, pipValueBySymbol[iSym], atrRiskBySymbol[iSym], atrNormRiskBySymbol[iSym], riskBySymbol[iSym]));
        }
        
        
        //atrNormRiskBySymbol[iSym] = 0.0;
      }
   }
   //+------------------------------------------------------------------+
   bool ValidadeFilterAllTicks()
   {
      bool validTick = true;
      if(allTicks && filterAllTicksBySeconds > 0)
      {
         update_allTicks = false;
         iTime_filterAllTicks = TimeCurrent();
         if( (iTime_filterAllTicks - period_check_filterAllTicks) >= filterAllTicksBySeconds ){
            update_allTicks = true;
            period_check_filterAllTicks = iTime_filterAllTicks;
         }
         validTick = update_allTicks;
      }
      return validTick;
   }
   //+------------------------------------------------------------------+
   string getInfoDateTime(){
      string _info = "";
      datetime timeCurrent = TimeCurrent();
      datetime timeGmt = timeCurrent + (-gmt_offset * 3600);
      datetime timeBrazil = timeGmt + (gmt_offset_brazil * 3600);
      _info += "Time Server: "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" / ";
      _info += "Time Brazil: "+TimeToStr(timeBrazil,TIME_DATE|TIME_SECONDS)+" / ";
      _info += "Time GMT: "+TimeToStr(timeGmt,TIME_DATE|TIME_SECONDS)+" / ";
      _info += "Offset: "+IntegerToString(gmt_offset);
      _info += NL;
      return _info;
   }
   //+------------------------------------------------------------------+
   string getInfoAccount(){
      string _info = "";

      _info += "Balance: "+DoubleToString(AccountBalance(),2)+" / ";
      _info += "Equity: "+DoubleToString(AccountEquity(),2)+" / ";
      _info += "FreeMargin: "+DoubleToString(AccountFreeMargin(),2)+" / ";
      _info += "MarginLevel: "+DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2)+" / ";
      _info += "Stopout: "+DoubleToString(AccountStopoutLevel(),0)+" / ";
      _info += "Lot: "+DoubleToString((RiskLevel > 0 ? lotSizeByRisk(RiskLevel) : Lots),2)+" / ";
      _info += "Profit: "+DoubleToString(AccountProfit(),2)+" "+AccountCurrency();
      _info += NL;
      return _info;
   }
   //+------------------------------------------------------------------+
   string getInfoSpread()
   {
      string _info  = "Spread Filter: ";
      bool find = false;
      for(int i=0; i < symbol_count; i++){
         if(!allowedSpread[i]){
            _info += StringConcatenate(brokerSymbols[i],"(",DoubleToString(currentSpreadBySymbol[i],2),"/Max:",DoubleToString(maxSpreadBySymbol[i],2),")");
            if(find) _info += ", ";
            find = true;
         }
      }
      if(!find) _info += "OK";
      _info += NL;
      return _info;
   }
   //+------------------------------------------------------------------+
   string getHeader(string ea_name){

      string _header = sp;
      _header += "==++== "+ea_name+" ==++=="+NL;
      _header += "Symbols: " + IntegerToString(symbol_count) + " / Currencies: " + currenciesStr;
      if(!tradeEnabled) _header += " / TRADE DISABLED";
      _header += NL + sp;
      return _header;
   }
   //+------------------------------------------------------------------+
private:
   //+------------------------------------------------------------------+
   void initSymbolsAndCurrencies()
   {
      string symbolsTemp[], currenciesTemp[];
      string _currency1, _currency2, _brokerSymbol, _cleanSymbol;
      int countTemp = 0;
      symbol_count = currency_count = 0;
      brokerSymbol_count = SymbolsTotal(false);
      //HashLoop *l;

      if(currenciesStr != ""){

         countTemp = StringSplit(currenciesStr,StringGetCharacter(",",0),currenciesTemp);
         for(int iCur = 0; iCur < countTemp; iCur++){
            _currency1 = currenciesTemp[iCur];
            if(StringLen(_currency1) != 3) {
               logMessage(LOG_ERROR, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Currency ",_currency1,": StringLen != 3"));
               continue;
            }
            if(!hashCurrencyPos.contains(_currency1)){
               hashCurrencyPos.set(_currency1, currency_count);
               currency_count++;
            }
         }
         HashMap<string,int> hashCurrenciesTemp;
         for(int i=0;i<brokerSymbol_count;i++)
         {
            _brokerSymbol = SymbolName(i,false);
            _cleanSymbol = _brokerSymbol;

            if(symbol_prefix != "" && StringFind(_brokerSymbol, symbol_prefix) == -1) continue;
            if(symbol_suffix != "" && StringFind(_brokerSymbol, symbol_suffix) == -1) continue;
            if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
            if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);

            if(StringLen(_cleanSymbol) == 6) {
               _currency1 = StringSubstr(_cleanSymbol, 0,3);
               _currency2 = StringSubstr(_cleanSymbol, 3,3);
               if( (currencyFillType == FILL_INCLUSIVE && (hashCurrencyPos.contains(_currency1) || hashCurrencyPos.contains(_currency2))) ||
                   (currencyFillType == FILL_EXCLUSIVE && (hashCurrencyPos.contains(_currency1) && hashCurrencyPos.contains(_currency2)))
                 ){
                  logMessage(LOG_WARN, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Found symbol ", _cleanSymbol," by Currency list"));
                  hashRawSymbolPos.set(_cleanSymbol, symbol_count);
                  hashSymbolPos.set(_brokerSymbol, symbol_count);
                  symbol_count++;

                  if(currencyFillType == FILL_INCLUSIVE){
                     if(!hashCurrencyPos.contains(_currency1) && !hashCurrenciesTemp.contains(_currency1)){
                        hashCurrenciesTemp.set(_currency1, currency_count);
                        currency_count++;
                     }
                     if(!hashCurrencyPos.contains(_currency2)  && !hashCurrenciesTemp.contains(_currency2)){
                        hashCurrenciesTemp.set(_currency2, currency_count);
                        currency_count++;
                     }
                  }
               }
            }
         }
         foreachm(string,_currency,int,_pos,hashCurrenciesTemp)
         {
            hashCurrencyPos.set(_currency,_pos);
         }
      }

      countTemp = 0;
      string symbolsStr = symbolsStr1;
      if(symbolsStr2 != "")  symbolsStr = symbolsStr + "," + symbolsStr2;
      if(symbolsStr3 != "")  symbolsStr = symbolsStr + "," + symbolsStr3;
      
      if(symbolsStr != "") {
         countTemp =  StringSplit(symbolsStr,StringGetCharacter(",",0),symbolsTemp);
      }
      for(int iSym=0; iSym < countTemp; iSym++){
         _cleanSymbol = symbolsTemp[iSym];
         if(StringLen(_cleanSymbol) != 6) {
            logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Symbol ",_cleanSymbol,": StringLen != 6"));
            continue;
         }
         string broker_symbol = symbol_prefix+_cleanSymbol+symbol_suffix;
         if(!SymbolSelect(broker_symbol, true)) {
            logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Symbol ",broker_symbol,": UNKNOWN_SYMBOL"));
            continue;
         }
         
         hashRawSymbolPos.set(_cleanSymbol, symbol_count);
         hashSymbolPos.set(broker_symbol, symbol_count);
         symbol_count++;

         _currency1 = StringSubstr(_cleanSymbol, 0,3);
         _currency2 = StringSubstr(_cleanSymbol, 3,3);
         if(!hashCurrencyPos.contains(_currency1)){
            hashCurrencyPos.set(_currency1, currency_count);
            currency_count++;
         }
         if(!hashCurrencyPos.contains(_currency2)){
            hashCurrencyPos.set(_currency2, currency_count);
            currency_count++;
         }
      }

      if(symbol_count == 0){
         _cleanSymbol = _brokerSymbol = Symbol();
         if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
         if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);

         if(StringLen(_cleanSymbol) != 6) {
            logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Symbol ",_cleanSymbol,": StringLen != 6"));
         }
         hashRawSymbolPos.set(_cleanSymbol, symbol_count);
         hashSymbolPos.set(_brokerSymbol, symbol_count);
         symbol_count++;

         _currency1 = StringSubstr(_cleanSymbol, 0,3);
         _currency2 = StringSubstr(_cleanSymbol, 3,3);
         hashCurrencyPos.set(_currency1, currency_count);
         currency_count++;
         hashCurrencyPos.set(_currency2, currency_count);
         currency_count++;
      }
      // END FILL hashCurrencyPos, hashSymbolPos, hashRawSymbolPos
      // BEGIN FILL listCurrencies, listBrokerSymbols, listCleanSymbols

      if(symbol_count == 0 || currency_count == 0){
         logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Unable to start EA, no valid symbol/currency found!"));
         initError = true;
      }
      ArrayResize(currencies,currency_count);
      ArrayResize(rawSymbols,symbol_count);
      ArrayResize(brokerSymbols,symbol_count);



      foreachm(string,_currency,int,_pos,hashCurrencyPos){
         logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of currencies: ", _pos, "-", _currency));
         currencies[_pos] = _currency;
      }

      logMessage(LOG_INFO, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing list of broker symbols, size: ", symbol_count,"/",hashSymbolPos.size()));

      foreachm(string,_brokerSym,int,_pos,hashSymbolPos){
         logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of broker symbols: ", _pos, "-", _brokerSym));
         brokerSymbols[_pos] = _brokerSym;
      }

      logMessage(LOG_INFO, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing list of clean symbols, size: ", symbol_count,"/",hashRawSymbolPos.size()));

      foreachm(string,_cleanSym,int,_pos,hashRawSymbolPos){
         logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of clean symbols: ", _pos, "-", _cleanSym));
         rawSymbols[_pos] = _cleanSym;
      }
      // END FILL listCurrencies, listBrokerSymbols, listCleanSymbols

      for(int iCurrency=0; iCurrency<currency_count; iCurrency++){
         if(currencies[iCurrency] != "USD"){
            if(!hashCurrencyUsdSymbol.contains(currencies[iCurrency])){
               for(int i=0;i<brokerSymbol_count;i++){
                  _cleanSymbol = SymbolName(i,false);
                  if(StringFind(_cleanSymbol,"USD") != -1 && StringFind(_cleanSymbol,currencies[iCurrency]) != -1){
                     if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
                     if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);
                     //logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing hashCurrencyUsdSymbol: ", listCurrencies[iCurrency], "-", _cleanSymbol));
                     hashCurrencyUsdSymbol.set(currencies[iCurrency], _cleanSymbol);
                     break;
                  }
               }
            }
         }
      }

      usdSymbol_count = hashCurrencyUsdSymbol.size();
      ArrayResize(usdSymbols, usdSymbol_count);

      int iUsdSym = 0;
      foreachm(string,_currency,string,_symbol,hashCurrencyUsdSymbol)
      {
         usdSymbols[iUsdSym][0]=symbol;
         usdSymbols[iUsdSym][1]=StringSubstr(_symbol, 0,3);
         usdSymbols[iUsdSym][2]=StringSubstr(_symbol, 3,3);
         hashUsdSymbolPos.set(_symbol, iUsdSym);
         iUsdSym++;
         logMessage(LOG_INFO, _symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("hashCurrencyUsdSymbol Currency: ",_currency,", Symbol: ",_symbol, ", size: ", hashCurrencyUsdSymbol.size()));
      }

      //if(iUsdSym != usdSymbols_count){ logMessage(LOG_ERROR, "", timeframe, "initCurrenciesAndSymbols", StringConcatenate("Expected USD symbols is ",usdSymbols_count, ", found ",iUsdSym,".")); }
   }
   //+------------------------------------------------------------------+
   void InitCloseOrders(){
      if(initOrderType != INIT_NOT_CLOSE){
         int _trade;
         int closeOrderCount = 0;
         for(_trade=OrdersTotal();_trade>=0;_trade--)
         {
            if( ! OrderSelect(_trade, SELECT_BY_POS, MODE_TRADES) ) continue;   // <-- if the OrderSelect fails advance the loop to the next PositionIndex
            bool close = false;
            if(!useMagicToClose || OrderMagicNumber() == Magic){
               if(initOrderType == INIT_CLOSE_ALL || !hashSymbolPos.contains(OrderSymbol())) close = true;
               /*if(initCloseLongShortOnly && !close){
                  string _cleanSymbol = OrderSymbol();
                  if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
                  if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);
                  if(StringLen(_cleanSymbol) == 6) {
                     string _currency1 = StringSubstr(_cleanSymbol, 0,3);
                     string _currency2 = StringSubstr(_cleanSymbol, 3,3);
                     if(OrderType() == OP_BUY && (setCurrencyShortOnly.contains(_currency1) || setCurrencyLongOnly.contains(_currency2))) close = true;
                     else if(OrderType() == OP_SELL && (setCurrencyShortOnly.contains(_currency2) || setCurrencyLongOnly.contains(_currency1))) close = true;
                  }
               }*/
               if(close){
                  if ( ! OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), Slippage ) ){
                     logMessage(LOG_ERROR, OrderSymbol(), 0, "InitCloseOrders", StringConcatenate("Close Order FAILED, lots: ",OrderLots(),", type: ",OrderType(),", order number: ",OrderTicket(),", Error: ",GetLastError()));
                  }
                  else{
                     logMessage(LOG_WARN, OrderSymbol(), 0, "InitCloseOrders", StringConcatenate("Closed Order, lots: ", OrderLots(),", type: ",OrderType(),", profit: ",OrderProfit()));
                     closeOrderCount++;
                  }
               }
            }
         }
         logMessage(LOG_INFO, "", 0, "InitCloseOrders", StringConcatenate("InitType: ",getInitOrderTypeStr(initOrderType),": Closed ", closeOrderCount," Orders!"));
      }
   }
   //+------------------------------------------------------------------+
   //| CHECK LIMIT ORDERS                                               |
   //+------------------------------------------------------------------+
   public:
   bool checkLimit_SellOrders(int iSetup)
   {
      if(maxOrders > 0 && hashOpenOrders.size() >= maxOrders){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open SELL order. ordersOpen(",hashOpenOrders.size(),") >= maxOrders(",maxOrders,")" ));
         return false;
      }
      if(maxOrdersBySymbol > 0 && ordersBySymbol[iSymbol].countBySymbol >= maxOrdersBySymbol){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open SELL order. ordersBySymbol(",ordersBySymbol[iSymbol].countBySymbol,") >= maxOrdersBySymbol(",maxOrdersBySymbol,")" ));
         return false;
      }
      if(maxOrdersBySetup > 0 && ordersBySymbol[iSymbol].ordersBySetup[iSetup].openOrders >= maxOrdersBySetup){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open SELL order. countOrdersByTF(",ordersBySymbol[iSymbol].ordersBySetup[iSetup].openOrders,") >= maxOrdersByTF(",maxOrdersBySetup,")" ));
         return false;
      }
      else if(maxOrdersBySide > 0 && ordersBySymbol[iSymbol].ordersBySetup[iSetup].countSell >= maxOrdersBySide){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open SELL order. countSellByTF(",ordersBySymbol[iSymbol].ordersBySetup[iSetup].countSell,") >= maxOrdersBySide(",maxOrdersBySide,")" ));
         return false;
      }
      return true;
   }
   //+------------------------------------------------------------------+
   bool checkLimit_BuyOrders(int iSetup)
   {
      if(maxOrders > 0 && hashOpenOrders.size() >= maxOrders){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open BUY order. ordersOpen(",hashOpenOrders.size(),") >= maxOrders(",maxOrders,")" ));
         return false;
      }
      if(maxOrdersBySymbol > 0 && ordersBySymbol[iSymbol].countBySymbol >= maxOrdersBySymbol){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open BUY order. ordersBySymbol(",ordersBySymbol[iSymbol].countBySymbol,") >= maxOrdersBySymbol(",maxOrdersBySymbol,")" ));
         return false;
      }
      if(maxOrdersBySetup > 0 && ordersBySymbol[iSymbol].ordersBySetup[iSetup].openOrders >= maxOrdersBySetup){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open BUY order. countOrdersBySetup(",ordersBySymbol[iSymbol].ordersBySetup[iSetup].openOrders,") >= maxOrdersByTF(",maxOrdersBySetup,")" ));
         return false;
      }
      if(maxOrdersBySide > 0 && ordersBySymbol[iSymbol].ordersBySetup[iSetup].countBuy >= maxOrdersBySide){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open BUY order. countBuyBySetup(",ordersBySymbol[iSymbol].ordersBySetup[iSetup].countBuy,") >= maxOrdersBySide(",maxOrdersBySide,")" ));
         return false;
      }
      return true;
   }
   //+------------------------------------------------------------------+
   bool checkMarginLevel()
   {
      if(MarginLevelMax) {
         double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
         if(margin_level > 0 && margin_level < MarginLevelMax){
            //logMessage(LOG_WARN, symbol, 0, StringConcatenate("Cannot open order. MAX MARGIN LEVEL REACHED. MarginLevel: ",margin_level ));
            return false;
         }
      }
      return true;
   }
   //+------------------------------------------------------------------+
   bool IsEnabledForLongPosition(int iSet){
     if(setCurrencyLongOnly[iSet].size() > 0 || setCurrencyShortOnly[iSet].size() > 0) {
       if((!setCurrencyLongOnly[iSet].contains(currency1) && setCurrencyLongOnly[iSet].contains(currency2)) || 
          (setCurrencyShortOnly[iSet].contains(currency1) && !setCurrencyShortOnly[iSet].contains(currency2)) ){
         //logMessage(LOG_WARN, symbol, 0, StringConcatenate("NOT ENABLE TO LONG POSITION. ",currency1," - ",currency2 ));
         return false;
       }
     }
     return true;
   }
   //+------------------------------------------------------------------+
   bool IsEnabledForShortPosition(int iSet){
     if(setCurrencyLongOnly[iSet].size() > 0 || setCurrencyShortOnly[iSet].size() > 0){
       if((setCurrencyLongOnly[iSet].contains(currency1) && !setCurrencyLongOnly[iSet].contains(currency2)) || 
          (setCurrencyShortOnly[iSet].contains(currency2) && !setCurrencyShortOnly[iSet].contains(currency1))){
         //logMessage(LOG_WARN, symbol, 0, StringConcatenate("NOT ENABLE TO SHORT POSITION. ",currency1," - ",currency2 ));
         return false;
       }
     }
     return true;
   }
   //+------------------------------------------------------------------+
   bool IsEnabledCurrencyFilterPosition(int iSet){
     if(setCurrencyFilter[iSet].size() > 0){
       if(setCurrencyFilter[iSet].contains(currency1) || setCurrencyFilter[iSet].contains(currency2)){
         logMessage(LOG_WARN, symbol, 0, StringConcatenate("NOT ENABLE TO FILTER CURRENCY POSITION. ",currency1," - ",currency2 ));
         return false;
       }
     }
     return true;
   }
   //+------------------------------------------------------------------+
   /*bool checkDistance_SellOrders(){
      if(atrDiffOrdersBySymbol > 0)
      {
         Order * lastOrder = ordersBySymbol[iSymbol].lastOrder;
         if(lastOrder != NULL && lastOrder.orderType == OP_SELL)
         {
            double atrPoints = atrSlowData[iSymbol][timeframes.DefaultPosition()] * atrDiffOrdersBySymbol;
            logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("atrDiffOrdersBySymbol SELL ORDER = ",atrPoints ));

            if( atrPoints > (ASK - lastOrder.openPrice)  ){
               logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("Cannot open SELL order. MinAtrPointsBySymbol = ",atrPoints,", CurrentPoints = ",(BID - lastOrder.openPrice),")" ));
               return false;
            }
         }
      }
      if(atrDiffOrdersBySetup > 0)
      {
         Order * lastOrder = ordersBySymbol[iSymbol].ordersBySetup[iSetup].last;
         if(lastOrder != NULL && lastOrder.orderType == OP_SELL)
         {
            double atrPoints = atrSlowData[iSymbol][timeframes.DefaultPosition()] * atrDiffOrdersBySetup;
            logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("atrDiffOrdersBySetup SELL ORDER = ",atrPoints ));

            if( atrPoints > (ASK - lastOrder.openPrice)  ){
               logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("Cannot open SELL order. MinAtrPointsBySetup = ",atrPoints,", CurrentPoints = ",(BID - lastOrder.openPrice),")" ));
               return false;
            }
         }
      }
      return true;
  }

  bool checkDistance_BuyOrders(){
      if(atrDiffOrdersBySymbol > 0)
      {
         Order * lastOrder = ordersBySymbol[iSymbol].lastOrder;
         if(lastOrder != NULL && lastOrder.orderType == OP_BUY)
         {
            double atrPoints = atrSlowData[iSymbol][timeframes.DefaultPosition()] * atrDiffOrdersBySymbol;
            logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("atrDiffOrdersBySymbol BUY ORDER = ",atrPoints ));
            if( atrPoints > (lastOrder.openPrice - BID)  ){
               logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("Cannot open BUY order. MinAtrPointsBySymbol = ",atrPoints,", CurrentPoints = ",(BID - lastOrder.openPrice),")" ));
               return false;
            }
         }
      }
      if(atrDiffOrdersBySetup > 0)
      {
         Order * lastOrder = ordersBySymbol[iSymbol].ordersBySetup[iSetup].last;
         if(lastOrder != NULL && lastOrder.orderType == OP_BUY)
         {
            double atrPoints = atrSlowData[iSymbol][timeframes.DefaultPosition()] * atrDiffOrdersBySetup;
            logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("atrDiffOrdersBySetup BUY ORDER = ",atrPoints ));

            if( atrPoints > (lastOrder.openPrice - BID)  ){
               logMessage(LOG_WARN, symbol, timeframes.DefaultValue(), StringConcatenate("Cannot open BUY order. MinAtrPointsBySetup = ",atrPoints,", CurrentPoints = ",(BID - lastOrder.openPrice),")" ));
               return false;
            }
         }
      }
      return true;
  }*/


//+------------------------------------------------------------------+
};
