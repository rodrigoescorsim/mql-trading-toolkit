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
#include <modulos/ZigzagController.mqh>
#include <modulos/HarmonicPatterns.mqh>
#include <modulos/PitchforkController.mqh>
#include <modulos/MurreyMath.mqh>
#include <modulos/Utils.mqh>
#include <modulos/hash.mqh>

extern string  timeframe_sym_info      = "=== SYMBOLS SETUP ===";
extern string  symbol_prefix           = ""; 
extern string  symbol_suffix           = "";
extern string  symbolsStr              = "";
extern string  symbolsInfo             = "AUDJPY,AUDNZD,AUDUSD,AUDCHF,AUDCAD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPUSD,GBPNZD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,XAUUSD";;
extern string  currenciesStr           = "";
extern string  currenciesInfo          = "USD,EUR,GBP,JPY,CHF,CAD,AUD,NZD,XAU,SGD";
extern FILL_TYPE currencyFillType      = FILL_EXCLUSIVE;
extern string  general_Info                    = "=== GENERAL SETUP ===";
extern bool    tradeEnabled            = true;
extern bool    tradeFirstTick          = true;
extern bool    alertSignalEnabled      = false;
extern bool    printSignalEnabled      = false;
extern bool    allTicks                = true;
extern int     filterAllTicksBySeconds = 10;
extern int     Magic                   = 1234321;  
extern bool    useMagicToClose         = false; 
extern INIT_ORDER_TYPE initOrderType   = INIT_NOT_CLOSE;
extern bool    Hedge                   = false;
extern NO_HEDGE_TYPE noHedgeType       = NO_HEDGE_CLOSE_AND_OPEN;
extern double  noHedgeBalanceDelta     = 0.6;
extern string  MM_Info                    = "=== MONEY MANAGEMENT SETUP ==="; 
extern double  Commission                 = 7;
extern int     Slippage                   = 3;    
extern double  maxSpread                  = 20; 
extern bool    useRelativeSpread          = true;  
extern double  LotSize                    = 100000;          
extern double  Lots                       = 0.01;
extern double  Risk                       = 0.1; // risk > 0 = enabled 
extern double  RiskMax                    = 0.4; 
extern double  riskBySetupMultiplier      = 1;
extern double  riskByTrendMultiplier      = 1.3;
extern double  riskByFiboMultiplier       = 1.3;
extern double  riskByZZSizeMultiplier     = 1.2;
extern double  riskByAtrToMedianMultiplier= 1.3;
extern string  Orders_Info                = "=== ORDERS SETUP ===";
extern int     distanceOrdersBySetup      = 20;  
extern int     distanceOrdersBySymbol     = 10; 
extern int     maxOrdersBySide            = 0;
extern int     maxOrdersBySetup           = 0;
extern int     maxOrdersBySymbol          = 0;
extern int     maxOrders                  = 200;
extern string  OrdersExpiration_Info      = "=== ORDERS EXPIRATION ===";
extern bool    useOrderExpiration         = true;
extern int     expireOrderTimeframeTime   = 30;
extern double  expireSetupTimeMultiplier  = 1.3;
extern EXPIRE_ORDER_TYPE expireOrderType  = EXPIRE_NOHEDGE;
extern int     expireStoploss             = 50;
extern double  expireStoplossMultiplier   = 1.3;
extern double  expireMarginSetupBegin     = 3;
extern double  expireMarginSetupStep      = 1;
extern string  Margin_Info                = "=== MARGIN SETUP ===";
extern bool    useMarginController        = true;
extern double  marginLevelMin             = 120;
extern double  marginPerSymbol            = 10;
extern double  marginPerCurrency          = 30;
extern bool    useTrendBalanceByMargin    = true;
extern double  trendBalance_marginBegin   = 0.2;
extern double  trendBalance_marginStep    = 0.2;
extern bool    useFiboBalanceByMargin     = true;
extern double  fiboBalance_marginBegin    = 0.4;
extern double  fiboBalance_marginStep     = 0.15;
extern bool    useSetupBalanceByMargin    = true;
extern double  setupBalance_marginBegin   = 0.3;
extern double  setupBalance_marginStep    = 0.1;
extern string  takeprofitstoploss_info    = "=== TAKEPROFIT/STOPLOSS ===";
extern double  TakeProfit                 = 0;
extern double  takeProfit_setupMultiplier = 1.4;
extern double  StopLoss                   = 0;
extern double  stopLoss_setupMultiplier   = 1.4;
extern string  tp_sl_fibo_info             = "=== TAKEPROFIT/STOPLOSS FIBO ===";
extern double  takeprofitByfiboPointCD     = 0.0;          
extern double  takeprofitByfiboPointBC     = 0.0;     
extern double  takeprofitByfiboPointXD     = 0.0;         
extern double  takeprofitByfiboPointAD     = 0.0; 
extern double  takeprofitByfiboPointAB     = 0.0;     
extern double  takeprofitTrendAjustStep    = 0.2;
extern double  stoplossByfiboPointCD       = 0.0;
extern string  tp_sl_filter_info           = "=== STOPLOSS FILTER ===";
extern double  filterSL_minSpreadRatio     = 0;
extern double  filterSL_spreadMultiplier   = 1.4;
extern double  filterSL_minAtrRatio        = 0;
extern double  filterSL_atrMultiplier      = 1.4;
extern string  tp_tp_filter_info           = "=== TAKEPROFIT FILTER ===";
extern double  filterTP_minSpreadRatio     = 1.5;
extern double  filterTP_spreadMultiplier   = 1.4;
extern double  filterTP_minAtrRatio        = 1.5;
extern double  filterTP_atrMultiplier      = 1.4;
extern string  barForce_info               = "=== BAR FORCE SETUP ===";
extern bool    useBarForce                 = false;
extern ENUM_TIMEFRAMES barForce_timeframe  = PERIOD_D1;
extern int     barForce_atrPeriod          = 20;
extern int     dailyForceStop              = 2;
extern int     weeklyForceStop             = 2;
extern int     monthlyForceStop            = 0;
extern int     dailyForceClose             = 2;
extern int     weeklyForceClose            = 2;
extern int     monthlyForceClose           = 0;
extern int     dailyForceMax               = 4;
extern int     weeklyForceMax              = 4;
extern int     monthlyForceMax             = 0;
extern int     totalForceStop              = 6;
extern int     totalForceClose             = 9;
extern int     totalForceMax               = 12;
extern int     candlesCloseConfirmation    = 5;
extern string  extremeFilter_info          = "=== EXTREME FILTER SETUP ===";
extern bool    useExtremeMaFilter          = false;
extern int     maFilter_timeframe          = 1;
extern ENUM_MA_METHOD maFilter_method      = MODE_EMA;
extern int     maFilter_MaPeriodBegin      = 12;
extern double  maFilter_MaPeriodMultiplier = 1.4;
extern int     maFilter_AtrPeriodBegin      = 40;
extern double  maFilter_AtrPeriodMultiplier = 1.4;
extern double  maFilter_AtrBandsBegin       = 0.6;
extern double  maFilter_AtrBandsMultiplier  = 1.3;
extern double  maFilter_atrStop            = 0;
extern double  maFilter_atrOpen            = 2.5;
extern double  maFilter_atrClose           = 0;
extern string  trend_info                 = "=== TREND SETUP ===";
extern double  trendLimitStopSymbol       = 0;
extern double  trendLimitCloseSymbol      = 0;
extern string  manualStrongCurrenciesStr  = "";
extern string  manualWeakCurrenciesStr    = "";
extern string  currenciesLongOnlyStr      = "";
extern string  currenciesShortOnlyStr     = "";
extern bool    initCloseLongShortOnly     = true;
extern bool    useCCFpTrendControl        = false;
extern int     timeframeCCFp              = 5;
extern int     ccfp_MA_Method             = 3;
extern int     ccfp_Price                 = 6;
extern int     ccfp_Fast                  = 10;
extern int     ccfp_Slow                  = 25;
extern double  ccfpBalanceBegin           = 0.5;
extern double  ccfpBalanceStep            = 0.5;
extern double  ccfpBalanceEnd             = 2.5;
extern double  ccfpLimitStopSymbol        = 3.5;
extern double  ccfpLimitCloseSymbol       = 4;
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
extern string     MurreyMath_signal_info        = "=== MURREY MATH SIGNAL ===";
extern bool       murrey_signal_closeBar        = true;
extern double     murrey_signal_delta           = 0.04;
extern bool       murrey_signal_visual          = false;
extern bool       murrey_range_visual           = false;
extern bool       use_murrey_avgBalance         = false;
extern int        murrey_close_avgStep          = 16;
extern int        murrey_range1_avgStep         = 16;
extern int        murrey_range2_avgStep         = 16;
extern string     MurreyMath_openSignal_info    = "=== MURREY MATH OPEN SIGNAL ===";
extern TIMEFRAME  murrey_openSignal_timeframe   = OFF;
extern int        murrey_openSignal_period      = 64;
extern MURREY_DIRECTION murrey_open_direction   = LOWER;
extern double     murrey_openSignal_minAtr      = 0;
extern int        murrey_openSignal_AtrPeriod   = 300;
extern string     murrey_openSignal_buyStr      = "0,0,0,0,0,0,1,1,1,1,1,1,1"; 
extern string     murrey_openSignal_sellStr     = "1,1,1,1,1,1,1,0,0,0,0,0,0";
extern string     MurreyMath_closeSignal_info   = "=== MURREY MATH CLOSE SIGNAL ===";
extern TIMEFRAME  murrey_closeSignal_timeframe  = OFF;
extern int        murrey_closeSignal_period     = 64;
extern MURREY_DIRECTION murrey_close_direction   = UPPER;
extern double     murrey_closeSignal_minAtr     = 0;
extern int        murrey_closeSignal_AtrPeriod  = 300;
extern string     murrey_closeSignal_buyStr     = "1,1,1,1,1,1,1,0,0,0,0,0,0"; 
extern string     murrey_closeSignal_sellStr    = "0,0,0,0,0,0,1,1,1,1,1,1,1";
extern string     MurreyMath_Range_info         = "=== MURREY MATH RANGE ===";
extern TIMEFRAME  murrey_range1_timeframe       = OFF;
extern int        murrey_range1_period          = 64;
extern double     murrey_range1_minAtr          = 0;
extern int        murrey_range1_AtrPeriod       = 300;
extern string     murrey_range1_openBuyStr      = "0,0,0,0,0,0,0,0,1,1,1,1";
extern string     murrey_range1_openSellStr     = "1,1,1,1,0,0,0,0,0,0,0,0";
extern TIMEFRAME  murrey_range2_timeframe       = OFF;
extern int        murrey_range2_period          = 64;
extern double     murrey_range2_minAtr          = 0;
extern int        murrey_range2_AtrPeriod       = 300;
extern string     murrey_range2_openBuyStr      = "0,0,0,0,0,0,0,0,1,1,1,1";
extern string     murrey_range2_openSellStr     = "1,1,1,1,0,0,0,0,0,0,0,0";
extern TIMEFRAME  murrey_range3_timeframe       = OFF;
extern int        murrey_range3_period          = 64;
extern double     murrey_range3_minAtr          = 0;
extern int        murrey_range3_AtrPeriod       = 300;
extern string     murrey_range3_openBuyStr     = "0,0,0,0,0,0,0,0,1,1,1,1";
extern string     murrey_range3_openSellStr    = "1,1,1,1,0,0,0,0,0,0,0,0";
extern string     MurreyMath_Trend_info         = "=== MURREY MATH TREND ===";
extern TIMEFRAME  murrey_trend1_timeframe       = OFF;
extern int        murrey_trend1_period          = 64;
extern string     murrey_trend1_sequence_str    = "-2,-1,0,1,1,0,0,-1,-1,0,1,2";
extern TIMEFRAME  murrey_trend2_timeframe       = OFF;
extern int        murrey_trend2_period          = 64;
extern string     murrey_trend2_sequence_str    = "-2,-1,0,1,1,0,0,-1,-1,0,1,2";
extern TIMEFRAME  murrey_trend3_timeframe       = OFF;
extern int        murrey_trend3_period          = 64;
extern string     murrey_trend3_sequence_str    = "-2,-1,0,1,1,0,0,-1,-1,0,1,2";
extern string  Zigzag_info              = "=== ZIGZAG SETUP ===";
extern ZIGZAG_TYPE zigzag_type          = ZZ_MT4;
extern int     use_zigzag_setup1        = true;
extern int     use_zigzag_setup2        = true;
extern int     use_zigzag_setup3        = true;
extern int     use_zigzag_setup4        = true;
extern int     use_zigzag_setup5        = true;
extern int     use_zigzag_setup6        = true;
extern int     use_zigzag_setup7        = true;
extern int     zigzag_fibo_shift        = 3;
extern bool    zz_ignore_equal_line_CD  = true;
extern bool    zz_ignore_equal_line_BC  = true;
extern bool    zz_ignore_equal_line_AB  = false;
extern bool    zz_ignore_equal_line_XA  = false;
extern string  Zigzag_setup               = "=== ZIGZAG SIGNAL ===";
extern bool    use_zigzag_size            = false;
extern double  zz_CD_size_MIN             = 0.0;
extern double  zz_CD_size_MAX             = 0.0;
extern double  zz_BC_size_MIN             = 0.0;
extern double  zz_BC_size_MAX             = 0.0;
extern double  zz_AB_size_MIN             = 0.0;
extern double  zz_AB_size_MAX             = 0.0;
extern double  zz_XA_size_MIN             = 0.0;
extern double  zz_XA_size_MAX             = 0.0;
extern bool    use_zigzag_angle           = false;
extern double  zz_CD_angle_MIN            = 0.0;
extern double  zz_CD_angle_MAX            = 0.0;
extern double  zz_BC_angle_MIN            = 0.0;
extern double  zz_BC_angle_MAX            = 0.0;
extern double  zz_AB_angle_MIN            = 0.0;
extern double  zz_AB_angle_MAX            = 0.0;
extern double  zz_XA_angle_MIN            = 0.0;
extern double  zz_XA_angle_MAX            = 0.0;
extern string  fibonacci_signal           = "=== FIBONACCI SIGNAL ===";
extern bool    use_fiboPatterns           = true;
extern string  fibo_numbers_string        = "0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236";
extern ZZ_FIBO_PATTERN fibo_pattern_main  = BD_PATTERN;
extern string  fibo_BD_patterns            = "1.0,1.272,1.618,2.0,2.236,2.618,3.1416";    
extern string  fibo_BD_minorCombination    = "";    
extern string  fibo_AC_patterns            = "";         
extern string  fibo_XB_patterns            = "";  
extern string  fibo_XD_patterns            = "";  
extern string  fibo_AD_patterns            = "";  
extern double  fibo_patterns_delta         = 0.04;       
extern bool    update_currentFiboBD        = false;  
extern string  fibo_strong1_patterns       = "1.272,1.618,2.0,2.272,2.618,3.1416";    
extern string  fibo_strong2_patterns       = "1.618,2.0,2.272,2.618,3.1416";   
extern string  fibo_strong3_patterns       = "2.0,2.272,2.618,3.1416";   
extern string  fibo_strong4_patterns       = "2.272,2.618,3.1416"; 
extern string  fibo_weak1_patterns         = "0.618,1.0,1.618,2.0,2.618,3.1416";  
extern string  fibo_weak2_patterns         = "0.5,0.618,1.0,1.618,2.0,2.618,3.1416";  
extern string  fibo_weak3_patterns         = "0.382,0.5,0.618,1.0,1.618,2.0,2.618,3.1416";  
extern string  fibo_weak4_patterns         = "0.236,0.382,0.5,0.618,1.0,1.618,2.0,2.618,3.1416";  
extern bool    use_fiboMinMax              = false;
extern double  fibo_BD_MIN                 = 0.0;       
extern double  fibo_BD_MAX                 = 0.0;     
extern double  fibo_AC_MIN                 = 0.0;       
extern double  fibo_AC_MAX                 = 0.0;    
extern double  fibo_XB_MIN                 = 0.0;       
extern double  fibo_XB_MAX                 = 0.0;    
extern double  fibo_XD_MIN                 = 0.0;       
extern double  fibo_XD_MAX                 = 0.0;    
extern string  Pitchfork_info                = "=== PITCHFORK SIGNAL ===";
extern bool    usePitchfork                  = false;
extern double  atrToApMedianBegin            = 2;
extern double  atrToApMedianMultiplier       = 1.618;
extern double  pitchfork_priceRange          = 0.40; 
extern double  pitchfork_timeRange           = 0.40;
extern bool    use_apSignal_triggerBreak     = true;
extern bool    use_apSignal_triggerBorder    = true;
extern bool    use_triggerAngleDirection     = false;
extern double  triggerAngleDirectionMIN      = 0;
extern double  triggerAngleDirectionMAX      = 0;
extern bool    use_triggerAngleExpansion     = false;
extern double  triggerAngleExpansionMIN      = 0;
extern double  triggerAngleExpansionMAX      = 0;
extern bool    pitchfork_uniqueSignalByPeak  = false;
/*** PITCHFORK TAKEPROFIT ***/
extern bool    use_apTakeprofit_median       = true;
extern bool    use_apTakeprofit_channel      = false;
/*** PITCHFORK STOPLOSS ***/
//extern bool    use_apStoploss_reaction       = false;
extern bool    use_apStoploss_peak           = false;
extern bool    use_apStoploss_trigger        = false;
extern double  apStoploss_delta              = 0.04;

extern string  HarmonicPatterns_info      = "=== HARMONIC PATTERNS SETUP ===";
extern bool    useHarmonicPatterns        = false;

extern string  bands_info                 = "=== BANDS SETUP ===";
extern bool    useBands                   = false;
extern int     bbPeriod                   = 20;
extern double  bbDeviation                = 2.0;
extern int     atrFastPeriod              = 10;
extern string  bbExpansion_info           = "=== BANDS EXPANSION SETUP ===";
extern bool    useBandsExpasionSignal     = false;
extern bool    useBandsExpasioncloseAll   = false;
extern double  bandsExpansionAbove        = 0.8;
extern double  bandsTrendExpansionAbove   = 0.2;
extern double  bandsWidthBelow            = 6.0;
extern string  bbRejection_info           = "=== BANDS REJECTION SETUP ===";
extern bool    useBandsRejectionSignal    = false;
extern double  bandsWidthAbove            = 2.0;
extern double  bandsExpansionBelow        = 1.0;
extern double  bandsOppositeExpansionBelow = 0.0;

extern string  pvaVolume_info          = "=== PVA VOLUME SETUP ===";
extern bool    usePvaVolume            = false;
extern int     pvaRisingDuration       = 2;
extern int     pvaClimaxDuration       = 4;
extern double  pvaVolumeRequired       = 2;
extern bool    usePvaRisingFilter      = false;
extern bool    usePvaClimaxFilter      = false;
extern bool    usePvaAlternativeTF     = false;
extern int     pvaAlternativeTF        = 15;


extern string  avgVolume_info          = "=== AVG VOLUME SETUP ===";
extern bool    useAvgVolumeFilter      = false;
extern int     avgVolumePeriodFast     = 27;
extern int     avgVolumePeriodSlow     = 500;
extern double  avgVolumeRequiredAbove  = 1.0;
extern double  avgVolumeRequiredBelow  = 0.0;
extern bool    useAvgVolumeBalance     = true;
extern string  avgVB_initial_setup     = "0,1,1,1,1,1,0";
extern double  avgVB_begin             = 1;
extern double  avgVB_step              = 0.2;

extern string  candlePattern_info         = "=== CANDLE PATTERN SETUP ===";
extern bool    useCandlePattern           = false;
extern int     candlePatternType          = 0; // candlePatternType = 0(ALL), 1(engulf), 2(Pinbar)
extern double  engulfMinFill              = 0.9;
extern double  engulfMaxFill              = 1.5;
extern double  pinbarMinShadow            = 2;
extern double  engulfAtrRequired          = 1.5;
extern double  pinbarAtrRequired          = 1.5;
extern double  candlePatternRequired      = 0.0;

extern string  TradeTimeFilter_Info    = "=== TRADE TIME SETUP ===";
extern   int   gmt_offset              = 1; // tickmill=3
extern   int   gmt_offset_brazil       = -2;
extern   bool  useTimeTradeFilter      = false;
extern   int   Start_Trade_Hour        = 0;               //GMT Start Trade Hour
extern   int   Start_Trade_Minute      = 0;                //GMT Start Trade Minute
extern   int   End_Trade_Hour          = 21;               //GMT End Trade Hour
extern   int   End_Trade_Minute        = 0;                //GMT End Trade Minute 
extern   bool  useTimeLimitToClose     = false;
extern  double timeCloseByMaxMargin    = 1.0; 
extern  int    timeCloseByMaxOrdersSide= 4; 
extern   int   tradeLimit_Hour         = 21;               
extern   int   tradeLimit_Minute       = 30;  
extern   bool  useTimeLimitFriday      = false;
extern   int   fridayLimit_Hour        = 20;               
extern   int   fridayLimit_Minute      = 50;  
extern string  WindowTimeFilter_Info      = "=== WINDOW TIME SETUP ===";
extern   bool  useWindowTimeZZSetup       = false;
extern string  window_time_info           = "HH(Begin),MM(Begin),HH(End),MM(End),Setup1(0/1),setup2,setup3,setup4,setup5,setup6,setup7";
extern   bool  window_time_closeOrders    = false;
extern string  window1_time_zz_setup      = "00,00,07,00,0,1,1,1,0,0,0";
//extern string  window1_exclude_currencies = "JPY,AUD";         
extern string  window2_time_zz_setup      = "07,00,11,00,0,0,0,1,1,1,0";
//extern string  window2_exclude_currencies = "GBP,EUR";  
extern string  window3_time_zz_setup      = "11,00,15,00,0,0,0,0,0,1,1";
//extern string  window3_exclude_currencies = "USD,CAD";  
extern string  window4_time_zz_setup      = "15,00,21,00,0,0,1,1,1,0,0";
//extern string  window4_exclude_currencies = "";  
extern string  window5_time_zz_setup      = "";
//extern string  window5_exclude_currencies = "";  
extern string  others_info             = "=== OTHERS ===";
extern int     DebugLevel              = 3;
extern bool    VisualDebug             = false;
extern bool    VisualFiltersDebug      = false;
extern bool    showInfoAccount         = true;
extern bool    showInfoPitchfork       = false;
extern bool    showInfoSentiment       = true;
extern bool    showInfoFilters         = true;
extern bool    showInfoRatios          = true;
extern bool    showInfoTrendsBalance   = true;
extern bool    showInfoSetups          = true;
extern bool    showInfoSymbols         = false;
extern bool    showInfoOrders          = true;

bool useSentimentSharkFx = false;
int fibonacciSequence[20] = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946};
double fibonacciNumbers[20] = {0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236};
//int lightFibonacciSequence[20] = {1, 2, 3, 4, 6, 9, 13, 19, 28, 41, 60, 88, 129, 189};
int fibonacciSequence_count = 20;

//+------------------------------------------------------------------+
//| ZIGZAG                     
//+------------------------------------------------------------------+      
   ZigzagController *zzCtrl[][7];
   GeometrySettings *settings[][7];  
   bool zupInitializedBySetup[][7], zupInitializedBySymbol[];  
   bool buySignalByZzSizeSetup[][7], sellSignalByZzSizeSetup[][7];
   bool buySignalByZzAngleSetup[][7], sellSignalByZzAngleSetup[][7];
   bool ignore_equal_zigzag[][7];
//+------------------------------------------------------------------+
//| PITCHFORK                          
//+------------------------------------------------------------------+   
   PitchforkController *pitchforkCtrl[][7];
   bool buySignalByPitchforkSetup[][7], sellSignalByPitchforkSetup[][7];
   double pitchforkLastPeakSignal[][7];
   double atrToMedianBySetup[7];
//+------------------------------------------------------------------+
//| MURREY MATH LINES                           
//+------------------------------------------------------------------+   
   bool   useMurreyMath;
   MurreyMath *murreyOpenSignal[], *murreyCloseSignal[], *murreyRange1[], *murreyRange2[], *murreyRange3[], *murreyTrend1[], *murreyTrend2[], *murreyTrend3[];
   
   //bool   murreySignalsOpenBuy[13], murreySignalsOpenSell[13];
   //bool   murreySignalsCloseBuy[13], murreySignalsCloseSell[13];
   //bool   murreyRangeOpenBuy[12], murreyRangeOpenSell[12];

   //int    murreyTrendSequence[12], murreyTrendBySymbol[];
   //bool   openBuySignalByMurreyLines[], openSellSignalByMurreyLines[];
   //bool   closeBuySignalByMurreyLines[], closeSellSignalByMurreyLines[];
   //bool   openBuySignalByMurreyRange[], openSellSignalByMurreyRange[];
   //int   murrey_lastOpenBuyMatchPos[],murrey_lastOpenSellMatchPos[],murrey_lastCloseBuyMatchPos[],murrey_lastCloseSellMatchPos[];
   //int   murrey_lastOpenBuyTradePos[],murrey_lastOpenSellTradePos[],murrey_lastCloseBuyTradePos[],murrey_lastCloseSellTradePos[];
//+------------------------------------------------------------------+
//| HARMONIC PATTERNS                            
//+------------------------------------------------------------------+   
   HarmonicPatterns* harmonicPatterns[][7];
   bool buySignalByHarmonicSetup[][7], sellSignalByHarmonicSetup[][7];
//+------------------------------------------------------------------+
//| FIBONACCI                            
//+------------------------------------------------------------------+   
   int fibo_BD_pattern_size, fibo_AC_pattern_size, fibo_XB_pattern_size, fibo_XD_pattern_size, fibo_BD_minor_size, fibo_AD_pattern_size;
   double fibo_BD_pattern_values[], fibo_AC_pattern_values[], fibo_XB_pattern_values[], fibo_XD_pattern_values[], fibo_BD_minor_values[], fibo_AD_pattern_values[];
   double fibo_BD_delta_values[][2], fibo_AC_delta_values[][2], fibo_XB_delta_values[][2], fibo_XD_delta_values[][2], fibo_BD_minor_delta_values[][2], fibo_AD_delta_values[][2];  
   int fibo_strong_size[4], fibo_weak_size[4];
   
   double fibo_strong1_values[], fibo_strong2_values[], fibo_strong3_values[], fibo_strong4_values[];
   double fibo_strong1_delta_values[][2], fibo_strong2_delta_values[][2], fibo_strong3_delta_values[][2], fibo_strong4_delta_values[][2]; 
   double fibo_weak1_values[], fibo_weak2_values[], fibo_weak3_values[], fibo_weak4_values[];
   double fibo_weak1_delta_values[][2], fibo_weak2_delta_values[][2], fibo_weak3_delta_values[][2], fibo_weak4_delta_values[][2];
   double fibo_lastMatchFibo[][7], fibo_lastTradeFibo[][7];
   int fibo_lastMatchFiboPos[][7], fibo_lastTradeFiboPos[][7];
   int fibo_lastTradeType[][7]; 
   bool buySignalByFiboPatternSetup[][7], sellSignalByFiboPatternSetup[][7], buySignalByFiboMinMaxSetup[][7], sellSignalByFiboMinMaxSetup[][7];
//+------------------------------------------------------------------+
//| MA_FILTER / BAR_FORCE    
//+------------------------------------------------------------------+  
   double maFilterMaValue[][7], maFilterAtrValue[][7], maFilterAtrBands[7];
   int maFilterMaPeriod[7], maFilterAtrPeriod[7];
   double maFilterCloseUp[][7], maFilterCloseDn[][7], maFilterOpenUp[][7], maFilterOpenDn[][7], maFilterStopUp[][7], maFilterStopDn[][7];   
   int dailyForceTrend[], weeklyForceTrend[], monthlyForceTrend[], totalBarForceTrend[];
   double dailyForceLimits[][12], weeklyForceLimits[][12], monthlyForceLimits[][12];
   double dailyAtrValue[], weeklyAtrValue[], monthlyAtrValue[]; 
   bool maFilterShortStop[][7], maFilterLongStop[][7], maFilterShortClose[][7], maFilterLongClose[][7], maFilterShortOpen[][7], maFilterLongOpen[][7];
   bool barForceShortStop[], barForceLongStop[], barForceShortClose[], barForceLongClose[];
   int barForceShortCount[], barForceLongCount[]; 
   bool useDailyBarForce, useWeeklyBarForce, useMonthlyBarForce;
//+------------------------------------------------------------------+
//| Indicators                             
//+------------------------------------------------------------------+
   bool buySignalByTimeframe[], sellSignalByTimeframe[], filterSignalByTimeframe[];
   double atrFastData[], atrSlowData[];
//+------------------------------------------------------------------+
//| AVG Volume                               
//+------------------------------------------------------------------+
   double avgVolumeFastData[][2], avgVolumeSlowData[], avgVolumeValue[];
   bool initialSetupBalanceAvgVol[], setupBalanceAvgVol[];
   int setupBalanceAvgVolShift, setupBalanceAvgVolLastShift;
//+------------------------------------------------------------------+
//| PVA Volume                               
//+------------------------------------------------------------------+ 
   double pvaRisingBullData[][4], pvaRisingBearData[][4], pvaClimaxBullData[][4], pvaClimaxBearData[][4], pvaVolumeValue[];
   bool pvaLongFilter[], pvaShortFilter[];
//+------------------------------------------------------------------+
//| BANDS                             
//+------------------------------------------------------------------+ 
   double bandsUpperData[][2], bandsMainData[][2], bandsLowerData[][2]; 
   double bandsWidth[], bandsUpperExpansion[], bandsLowerExpansion[],  bandsExpansion[], bandsTrendExpansion[]; 
   double bandsExpansionBullSignal[], bandsExpansionBearSignal[], bandsRejectionBullSignal[], bandsRejectionBearSignal[]; 
//+------------------------------------------------------------------+
//| CANDLE PATTERN                            
//+------------------------------------------------------------------+ 
   double engulfValue[], pinbarValue[], candlePatternValue[];
//+------------------------------------------------------------------+
//| SENTIMENT / CCFp                   
//+------------------------------------------------------------------+ 
   //int   sentimentLong[], sentimentShort[], sentimentLong_usdBase[], sentimentShort_usdBase[];
   double ccfpValues[], sentimentMfbValues[], sentimentSfxValues[];   
   int ccfpTrend[], sentimentMfbTrend[], sentimentSfxTrend[], manualTrend[], symbolTrend[], marginTrendBySymbol[];
   bool trendShortStop[], trendLongStop[], trendShortClose[], trendLongClose[];
//+------------------------------------------------------------------+
//| SYMBOLS / CURRENCIES                           
//+------------------------------------------------------------------+
    string listCurrencies[], listBrokerSymbols[], listCleanSymbols[], listUsdSymbols[][3];
    Hash *hashCurrencies, *hashBrokerSymbols, *hashCleanSymbols, *hashUsdSymbol;
    int currencies_count, brokerSymbols_count, usdSymbols_count, symbols_count;
    Hash *hashCurrencyUsdSymbol;
    double usdSymbols_maValue[][2];
    Hash *hashCurrenciesLongOnly, *hashCurrenciesShortOnly;
    string symbol, cleanSymbol, currency1, currency2;
    int iCurrency1, iCurrency2;
//+------------------------------------------------------------------+
//| ORDERS                           
//+------------------------------------------------------------------+
    Hash *hashOpenOrders;
    Order *order;
    HashOrder *hashOrder;
    OrdersBySymbol ordersBySymbol[];
    int lastBuyOrderBySetup[][7], lastSellOrderBySetup[][7];
    int lastBuyOrderBySymbol[], lastSellOrderBySymbol[];
//+------------------------------------------------------------------+
//| TIME VARIABLES                              
//+------------------------------------------------------------------+
   datetime iTime_Symbol, iTime_Sentiment, period_check_sentiment; 
   datetime iTime_currentTF, period_check_currentTF;
   datetime iTime_barForce, period_check_barForce;
   datetime iTime_maFilter, period_check_maFilter;
   datetime iTime_ccfp, period_check_ccfp; 
   datetime iTime_filterAllTicks, period_check_filterAllTicks;
   datetime period_check_symbol[];
   bool update_TFBySymbol[], update_sentiment, update_ccfp, update_currentTF, update_barforce, update_maFilter, update_allTicks, update_marginTrend;

//+------------------------------------------------------------------+
//| MESSAGES VARIABLES                              
//+------------------------------------------------------------------+
   string msgSentiment, msgIndicatorsSignal[], msgZupSignal[], info_symbol[];
//+------------------------------------------------------------------+
//| SPREAD VARIABLES                              
//+------------------------------------------------------------------+
   bool filterSpread[];
   double maxSpreadBySymbol[], relativeSymbolValue[], currentSpreadBySymbol[], stopLevelBySymbol[];
//+------------------------------------------------------------------+
//| MARGIN                           
//+------------------------------------------------------------------+
   double lotsBySymbol[], buyLotsBySymbol[], sellLotsBySymbol[];
   double lotsByCurrency[], buyLotsByCurrency[], sellLotsByCurrency[];
   double marginBySymbol[], marginByCurrency[];
   double lotsSizeBySymbol[], lotsSizeBySCurrency[];
   double lotsTotal, lotsHedgeTotal, marginTotal;
   double marginLevel;
   int fiboBalanceByMargin_shift[], setupBalanceByMargin_shift[];
   bool setupBalanceByBuyMargin[][7], setupBalanceBySellMargin[][7], fiboBalanceByBuyMargin[][20], fiboBalanceBySellMargin[][20];
   static int fibo_maxCount = 20;
//+------------------------------------------------------------------+
//| TIME VARIABLES                              
//+------------------------------------------------------------------+
   int      start_hour_server, end_hour_server, start_minute_server, end_minute_server, last_hour, last_minute, use_minute;
   int      limit_hour_server, limit_minute_server, last_limit_hour, last_limit_minute;
   int      fridayLimit_hour_server, fridayLimit_minute_server, last_fridayLimit_hour, last_fridayLimit_minute;
   bool     timeTradeEnabled, timeFridayDisabled, timeLimitCloseEnabled, lastTimeTradeEnabled;
   string   infoTimeTrade, infoTimeLimitClose;
   WindowTime *windowTime[5]; int lastWindowTime;
//+------------------------------------------------------------------+
//| VARIABLES                              
//+------------------------------------------------------------------+
   static int setupValue[7][3];
   static int setup_count = 7;
   bool firstUpdate, dataWaiting[], setupInUse[7], windowSetupEnabled[7], lastWindowSetupEnabled[7];//, windowExcludeCurrencies[], windowAllowedSymbols[];
   int atrSlowPeriod;      
   double symbolPoint, spread, BID, ASK, equity, accountMargin;
   int leverage;
   double takeprofitBySetup[][7], stoplossBySetup[][7], hedgeBuyBySetup[][7], hedgeSellBySetup[][7];
   int   symbolDigits, iSymbol, iSetup, ticket, timeframe, ordersClosed; 
   bool     tradeSetupEnabled, last_trade_enabled = false;
   bool     useIndicator, useZigzag, usePva, usePvaFilter, use_fiboMM, useSentiment, useAvgVolume;
   bool     use_ignore_equal_line, useCurrencyTrends, useManualCurrencyStrength, useTimeLimit;
   string info_balance;
   string sp         = "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n";
   string NL         = "\n";
   
//+------------------------------------------------------------------+
//| initCore                         
//+------------------------------------------------------------------+
void initCore()
  {
//----
   logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing EA core..."));
   
   last_hour = last_minute = last_trade_enabled = -1;
   useTimeLimit = (useTimeLimitToClose || useTimeLimitFriday);
   if(useTimeLimitToClose){
      datetime timeCurrent = TimeCurrent(); 
      last_limit_hour = TimeHour(timeCurrent);
      last_limit_minute = TimeMinute(timeCurrent);
   }
   if(useTimeLimitFriday){
      datetime timeCurrent = TimeCurrent(); 
      last_fridayLimit_hour = TimeHour(timeCurrent);
      last_fridayLimit_minute = TimeMinute(timeCurrent);
   }
   
   period_check_sentiment = period_check_ccfp = period_check_currentTF = period_check_maFilter = period_check_barForce = period_check_filterAllTicks = 0;
   ordersClosed = 0; marginLevel = marginTotal = 0;
   firstUpdate = true;
   update_allTicks = true;
   use_fiboMM = (takeprofitByfiboPointCD > 0 || takeprofitByfiboPointXD > 0 || takeprofitByfiboPointAD > 0 || takeprofitByfiboPointAB > 0 || takeprofitByfiboPointBC > 0 || stoplossByfiboPointCD > 0);
   usePva = (usePvaVolume || usePvaRisingFilter || usePvaClimaxFilter);
   usePvaFilter = (usePvaRisingFilter || usePvaClimaxFilter);
   useManualCurrencyStrength = (manualStrongCurrenciesStr != "" || manualWeakCurrenciesStr != "");
   useZigzag = (use_zigzag_angle || use_zigzag_size || usePitchfork || useHarmonicPatterns || use_fiboPatterns || use_fiboMinMax || use_fiboMM);
   useAvgVolume = (useAvgVolumeFilter || useAvgVolumeBalance);
   useIndicator = (useCandlePattern || useAvgVolume || usePva || useBands);
   use_ignore_equal_line = (zz_ignore_equal_line_CD || zz_ignore_equal_line_BC || zz_ignore_equal_line_AB || zz_ignore_equal_line_XA);
   tradeSetupEnabled = (useZigzag || useIndicator || (useExtremeMaFilter && maFilter_atrOpen > 0) || murrey_openSignal_timeframe != OFF);
   LogDebugLevel = DebugLevel;
   if(myfxbook_dataFile != "") _myfxbook_dataFile = myfxbook_dataFile;
   if(myfxbook_fileLock != "") _myfxbook_fileLock = myfxbook_fileLock;
   //if(riskBySetupMultiplier == 0) riskBySetupMultiplier = 1;
   timeframe = Period();
   if(maFilter_timeframe < timeframe) maFilter_timeframe = timeframe;
   if(timeframeCCFp < timeframe) timeframeCCFp = timeframe; 
   if(timeframeSentiment < timeframe) timeframeSentiment = timeframe; 
   
   equity = AccountEquity(); 
   leverage = AccountLeverage();
   accountMargin = AccountMargin();
   hashOpenOrders = new Hash();
   hashCurrenciesLongOnly = new Hash();
   hashCurrenciesShortOnly = new Hash();
   
   setupInUse[0] = use_zigzag_setup1;
   setupInUse[1] = use_zigzag_setup2; 
   setupInUse[2] = use_zigzag_setup3; 
   setupInUse[3] = use_zigzag_setup4; 
   setupInUse[4] = use_zigzag_setup5; 
   setupInUse[5] = use_zigzag_setup6; 
   setupInUse[6] = use_zigzag_setup7;  
   
   if(usePitchfork){
      for(int i=0; i<setup_count; i++){
         atrToMedianBySetup[i] = atrToApMedianBegin * (MathPow(atrToApMedianMultiplier, i));
          //Print(StringConcatenate("atrToMedianBySetup[",i,"] = ",atrToMedianBySetup[i]," - Begin: ",atrToApMedianBegin," - Multiplier: ",atrToApMedianMultiplier));
      }
   }

   ArrayInitialize(setupValue,0);
   if(zigzag_type == ZZ_MT4){
      for(int i=0; i<setup_count; i++){
         //[0]depth  [1]deviation [2]backstep
         setupValue[i][0] = fibonacciSequence[i+zigzag_fibo_shift+3];
         setupValue[i][1] = fibonacciSequence[i+zigzag_fibo_shift+1];
         setupValue[i][2] = fibonacciSequence[i+zigzag_fibo_shift];
      }
   }
   else if(zigzag_type == CZIGZAG){
      setupValue[0][0] = 13;
      setupValue[0][1] = 5;
      setupValue[1][0] = 55;
      setupValue[1][1] = 21;
      setupValue[2][0] = 144;
      setupValue[2][1] = 55;
      setupValue[3][0] = 233;
      setupValue[3][1] = 89;
      setupValue[4][0] = 377;
      setupValue[4][1] = 144;
      setupValue[5][0] = 610;
      setupValue[5][1] = 233;
      setupValue[6][0] = 987;
      setupValue[6][1] = 377;

   }
   else if(zigzag_type == ZZ_NEM4){
       for(int i=0; i<setup_count; i++){
         setupValue[i][0] = fibonacciSequence[i+zigzag_fibo_shift+1];
         setupValue[i][1] = fibonacciSequence[i+zigzag_fibo_shift];
         setupValue[i][2] = fibonacciSequence[i+zigzag_fibo_shift+2];
         logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing Setup ",i," with ZZ_NEM4(",setupValue[i][0],",",setupValue[i][1],",",setupValue[i][2],")" )); 
      }
   }
   
   if (timeframe == 1) atrSlowPeriod = 1440;
   else if(timeframe == 5) atrSlowPeriod = 288;
   else atrSlowPeriod = 100;
   
   infoTimeLimitClose = infoTimeTrade = "";
   timeLimitCloseEnabled = false;
   
   if(useTimeTradeFilter){
      start_hour_server = Start_Trade_Hour + gmt_offset;
      end_hour_server = End_Trade_Hour + gmt_offset;
      if(start_hour_server > 23)  start_hour_server -= 24;
      if(start_hour_server < 0) start_hour_server += 24;
      if(end_hour_server > 23) end_hour_server -= 24;
      if(end_hour_server < 0) end_hour_server += 24;
      start_minute_server = Start_Trade_Minute;
      end_minute_server = End_Trade_Minute;
      if(start_minute_server == 0 && end_minute_server == 0)
         use_minute = false;
      timeTradeEnabled = false;   
      infoTimeTrade = StringConcatenate("TradeTime - Start Time: ",start_hour_server,"h ",start_minute_server,"m / ","End Time: ",end_hour_server,"h ",end_minute_server,"m / Trade Enabled: ");
    }
    else{ timeTradeEnabled = true; }
    lastTimeTradeEnabled = timeTradeEnabled;
    timeFridayDisabled = false;
    
    if(useTimeLimitToClose){
      limit_hour_server = tradeLimit_Hour + gmt_offset;
      limit_minute_server = tradeLimit_Minute; 
      infoTimeLimitClose += StringConcatenate("Time limit to close: ",limit_hour_server,"h ",limit_minute_server,"m",NL);
    }
    if(useTimeLimitFriday){
      fridayLimit_hour_server = fridayLimit_Hour + gmt_offset;
      fridayLimit_minute_server = fridayLimit_Minute; 
      infoTimeLimitClose += StringConcatenate("Friday limit to close: ",fridayLimit_hour_server,"h ",fridayLimit_minute_server,"m",NL);
    }
   
   initCurrenciesAndSymbols();
   
   ArrayInitialize(windowSetupEnabled, 1);
   ArrayInitialize(lastWindowSetupEnabled, 1);
   //ArrayResize(windowExcludeCurrencies, currencies_count); ArrayInitialize(windowExcludeCurrencies, false);
   //ArrayResize(windowAllowedSymbols, symbols_count); ArrayInitialize(windowAllowedSymbols, true);
   
   if(useWindowTimeZZSetup){
      createWindowTime(window1_time_zz_setup, 0);
      createWindowTime(window2_time_zz_setup, 1);
      createWindowTime(window3_time_zz_setup, 2);
      createWindowTime(window4_time_zz_setup, 3);
      createWindowTime(window5_time_zz_setup, 4);
      lastWindowTime = -1;
   }

   ArrayResize(hedgeBuyBySetup, symbols_count); ArrayInitialize(hedgeBuyBySetup, Hedge);
   ArrayResize(hedgeSellBySetup, symbols_count); ArrayInitialize(hedgeSellBySetup, Hedge);
   ArrayResize(update_TFBySymbol, symbols_count); ArrayInitialize(update_TFBySymbol, true);
   ArrayResize(filterSpread, symbols_count); ArrayInitialize(filterSpread, true);
   ArrayResize(currentSpreadBySymbol, symbols_count);  ArrayInitialize(currentSpreadBySymbol, 0.0);
   ArrayResize(maxSpreadBySymbol, symbols_count); 
   
   ArrayResize(relativeSymbolValue, symbols_count); ArrayInitialize(relativeSymbolValue, 1.0);
   for(int iSym=0; iSym < symbols_count; iSym++){
      double bid = MarketInfo(listBrokerSymbols[iSym],MODE_BID);
      if(bid > 0){
         relativeSymbolValue[iSym] = (bid / (100000 * MarketInfo(listBrokerSymbols[iSym],MODE_POINT)));
         logMessage(LOG_WARN, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue: ",listBrokerSymbols[iSym]," is ",relativeSymbolValue[iSym]));
      }
      else{
         logMessage(LOG_WARN, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("RelativeSymbolValue (not found:BID=0): ",listBrokerSymbols[iSym]," is ",relativeSymbolValue[iSym])); 
      } 
   } 
   if(maxSpread > 0){
      if(useRelativeSpread){
         for(int iSym=0; iSym < symbols_count; iSym++){
            maxSpreadBySymbol[iSym] = MathCeil(maxSpread * relativeSymbolValue[iSym]);
            logMessage(LOG_WARN, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("Max (",maxSpread,") Relative spread from ",listBrokerSymbols[iSym]," is ",maxSpreadBySymbol[iSym]));    
         }   
      }
      else ArrayInitialize(maxSpreadBySymbol, maxSpread);
   }
   else ArrayInitialize(maxSpreadBySymbol, 0.0); 
   
   ArrayResize(stopLevelBySymbol, symbols_count);
   for(int iSym=0; iSym < symbols_count; iSym++){
      stopLevelBySymbol[iSym] = MarketInfo(listBrokerSymbols[iSym], MODE_STOPLEVEL);
   }
   
   ArrayResize(takeprofitBySetup, symbols_count); ArrayInitialize(takeprofitBySetup, 0.0); 
   ArrayResize(stoplossBySetup, symbols_count); ArrayInitialize(stoplossBySetup, 0.0); 
   if(TakeProfit > 0){
      for(int iSym=0; iSym < symbols_count; iSym++){
         if(takeProfit_setupMultiplier > 0){  
            for(int i=0; i < setup_count; i++){
               takeprofitBySetup[iSym][i] = TakeProfit * ((MathPow(takeProfit_setupMultiplier,i))*relativeSymbolValue[iSym]);
               logMessage(LOG_INFO, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("TakeProfit(",listBrokerSymbols[iSym],") by setup(",i,") multiplier(",takeProfit_setupMultiplier,") is ",takeprofitBySetup[iSym][i])); 
            }
         }
         else{
            logMessage(LOG_INFO, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("TakeProfit(",listBrokerSymbols[iSym],")  is ",(TakeProfit * relativeSymbolValue[iSym]))); 
            for(int i=0; i < setup_count; i++){
               takeprofitBySetup[iSym][i] = TakeProfit * relativeSymbolValue[iSym];
            }
         }
      }
   }
   if(StopLoss > 0){
      for(int iSym=0; iSym < symbols_count; iSym++){
         if(stopLoss_setupMultiplier > 0){  
            for(int i=0; i < setup_count; i++){
               stoplossBySetup[iSym][i] = StopLoss * ((MathPow(stopLoss_setupMultiplier,i))*relativeSymbolValue[iSym]);
               logMessage(LOG_INFO, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("StopLoss(",listBrokerSymbols[iSym],") by setup(",i,") multiplier(",stopLoss_setupMultiplier,") is ",stoplossBySetup[iSym][i])); 
            }
         }
         else{
            logMessage(LOG_INFO, listBrokerSymbols[iSym], 0, "initCore", StringConcatenate("StopLoss(",listBrokerSymbols[iSym],")  is ",(StopLoss * relativeSymbolValue[iSym]))); 
            for(int i=0; i < setup_count; i++){
               stoplossBySetup[iSym][i] = StopLoss * relativeSymbolValue[iSym];
            }
         }
      }
   }
   if(!useMarginController && (useTimeLimitToClose && timeCloseByMaxMargin > 0)) useMarginController = true;
   if(!useMarginController && useTrendBalanceByMargin) useTrendBalanceByMargin = false;
   if(!useMarginController && useFiboBalanceByMargin) useFiboBalanceByMargin = false;
   if(!useMarginController && useSetupBalanceByMargin) useSetupBalanceByMargin = false;
   //if(useMarginController){
      ArrayResize(lotsBySymbol, symbols_count); ArrayInitialize(lotsBySymbol, 0);
      ArrayResize(buyLotsBySymbol, symbols_count); ArrayInitialize(buyLotsBySymbol, 0);
      ArrayResize(sellLotsBySymbol, symbols_count); ArrayInitialize(sellLotsBySymbol, 0);
      ArrayResize(marginBySymbol, symbols_count); ArrayInitialize(marginBySymbol, 0);
      ArrayResize(lotsSizeBySymbol, symbols_count); ArrayInitialize(lotsSizeBySymbol, 0);
      
      ArrayResize(lotsByCurrency, currencies_count); ArrayInitialize(lotsByCurrency, 0);
      ArrayResize(buyLotsByCurrency, currencies_count); ArrayInitialize(buyLotsByCurrency, 0);
      ArrayResize(sellLotsByCurrency, currencies_count); ArrayInitialize(sellLotsByCurrency, 0);
      ArrayResize(marginByCurrency, currencies_count); ArrayInitialize(marginByCurrency, 0);
      ArrayResize(lotsSizeBySCurrency, currencies_count); ArrayInitialize(lotsSizeBySCurrency, 0);
      
      ArrayResize(fiboBalanceByMargin_shift, symbols_count); ArrayInitialize(fiboBalanceByMargin_shift, 0);
      ArrayResize(setupBalanceByMargin_shift, symbols_count); ArrayInitialize(setupBalanceByMargin_shift, 0);
      ArrayResize(setupBalanceByBuyMargin, symbols_count); ArrayInitialize(setupBalanceByBuyMargin, true);
      ArrayResize(setupBalanceBySellMargin, symbols_count); ArrayInitialize(setupBalanceBySellMargin, true);
      ArrayResize(fiboBalanceByBuyMargin, symbols_count); ArrayInitialize(fiboBalanceByBuyMargin, true);
      ArrayResize(fiboBalanceBySellMargin, symbols_count); ArrayInitialize(fiboBalanceBySellMargin, true);
   //}
   ArrayResize(ordersBySymbol, symbols_count);
   for (iSymbol = 0; iSymbol < symbols_count; iSymbol++){
      ordersBySymbol[iSymbol].resetSymbol(listBrokerSymbols[iSymbol]);  
   }
   ArrayResize(info_symbol, symbols_count); 
   ArrayResize(msgIndicatorsSignal, symbols_count);
   ArrayResize(msgZupSignal, symbols_count);
   ArrayResize(period_check_symbol, symbols_count); ArrayInitialize(period_check_symbol, 0);
   ArrayResize(dataWaiting, symbols_count); ArrayInitialize(dataWaiting, true);
   ArrayResize(lastBuyOrderBySetup, symbols_count); ArrayInitialize(lastBuyOrderBySetup, distanceOrdersBySetup+1);
   ArrayResize(lastSellOrderBySetup, symbols_count); ArrayInitialize(lastSellOrderBySetup, distanceOrdersBySetup+1);
   ArrayResize(lastBuyOrderBySymbol, symbols_count); ArrayInitialize(lastBuyOrderBySymbol, distanceOrdersBySymbol+1);
   ArrayResize(lastSellOrderBySymbol, symbols_count); ArrayInitialize(lastSellOrderBySymbol, distanceOrdersBySymbol+1);
   ArrayResize(ignore_equal_zigzag, symbols_count); ArrayInitialize(ignore_equal_zigzag, false);
   
   ArrayResize(buySignalByTimeframe, symbols_count); ArrayInitialize(buySignalByTimeframe, false);
   ArrayResize(sellSignalByTimeframe, symbols_count); ArrayInitialize(sellSignalByTimeframe, false);
   ArrayResize(buySignalByZzSizeSetup, symbols_count); ArrayInitialize(buySignalByZzSizeSetup, false);
   ArrayResize(sellSignalByZzSizeSetup, symbols_count); ArrayInitialize(sellSignalByZzSizeSetup, false);
   ArrayResize(buySignalByZzAngleSetup, symbols_count); ArrayInitialize(buySignalByZzAngleSetup, false);
   ArrayResize(sellSignalByZzAngleSetup, symbols_count); ArrayInitialize(sellSignalByZzAngleSetup, false);
   ArrayResize(buySignalByFiboPatternSetup, symbols_count); ArrayInitialize(buySignalByFiboPatternSetup, false);
   ArrayResize(sellSignalByFiboPatternSetup, symbols_count); ArrayInitialize(sellSignalByFiboPatternSetup, false);
   ArrayResize(buySignalByFiboMinMaxSetup, symbols_count); ArrayInitialize(buySignalByFiboMinMaxSetup, false);
   ArrayResize(sellSignalByFiboMinMaxSetup, symbols_count); ArrayInitialize(sellSignalByFiboMinMaxSetup, false);
   ArrayResize(buySignalByHarmonicSetup, symbols_count); ArrayInitialize(buySignalByHarmonicSetup, false);
   ArrayResize(sellSignalByHarmonicSetup, symbols_count); ArrayInitialize(sellSignalByHarmonicSetup, false);
   ArrayResize(buySignalByPitchforkSetup, symbols_count); ArrayInitialize(buySignalByPitchforkSetup, false);
   ArrayResize(sellSignalByPitchforkSetup, symbols_count); ArrayInitialize(sellSignalByPitchforkSetup, false);
   
   useDailyBarForce = useWeeklyBarForce = useMonthlyBarForce = false;
   if(useBarForce){
      if(dailyForceStop > 0 || dailyForceClose > 0 || dailyForceMax > 0) useDailyBarForce = true;
      if(weeklyForceStop > 0 || weeklyForceClose > 0 || weeklyForceMax > 0) useWeeklyBarForce = true;
      if(monthlyForceStop > 0 || monthlyForceClose > 0 || monthlyForceMax > 0) useMonthlyBarForce = true;   
      ArrayResize(dailyForceLimits, symbols_count); ArrayInitialize(dailyForceLimits, 0);
      ArrayResize(weeklyForceLimits, symbols_count); ArrayInitialize(weeklyForceLimits, 0);
      ArrayResize(monthlyForceLimits, symbols_count); ArrayInitialize(monthlyForceLimits, 0);
      ArrayResize(dailyAtrValue, symbols_count); ArrayInitialize(dailyAtrValue, 0);
      ArrayResize(weeklyAtrValue, symbols_count); ArrayInitialize(weeklyAtrValue, 0);
      ArrayResize(monthlyAtrValue, symbols_count); ArrayInitialize(monthlyAtrValue, 0);
      ArrayResize(dailyForceTrend, symbols_count); ArrayInitialize(dailyForceTrend, 0);
      ArrayResize(weeklyForceTrend, symbols_count); ArrayInitialize(weeklyForceTrend, 0);
      ArrayResize(monthlyForceTrend, symbols_count); ArrayInitialize(monthlyForceTrend, 0);
      ArrayResize(totalBarForceTrend, symbols_count); ArrayInitialize(totalBarForceTrend, 0);
      ArrayResize(barForceShortStop, symbols_count); ArrayInitialize(barForceShortStop, false);
      ArrayResize(barForceLongStop, symbols_count); ArrayInitialize(barForceLongStop, false);
      ArrayResize(barForceShortClose, symbols_count); ArrayInitialize(barForceShortClose, false);
      ArrayResize(barForceLongClose, symbols_count); ArrayInitialize(barForceLongClose, false);
      ArrayResize(barForceShortCount, symbols_count); ArrayInitialize(barForceShortCount, 0);
      ArrayResize(barForceLongCount, symbols_count); ArrayInitialize(barForceLongCount, 0);
      
   }
   if(useExtremeMaFilter){
      ArrayResize(maFilterMaValue, symbols_count); ArrayInitialize(maFilterMaValue, 0);
      ArrayResize(maFilterAtrValue, symbols_count); ArrayInitialize(maFilterAtrValue, 0);
      ArrayResize(maFilterOpenUp, symbols_count); ArrayInitialize(maFilterOpenUp, 0);
      ArrayResize(maFilterOpenDn, symbols_count); ArrayInitialize(maFilterOpenDn, 0);
      ArrayResize(maFilterCloseUp, symbols_count); ArrayInitialize(maFilterCloseUp, 0);
      ArrayResize(maFilterCloseDn, symbols_count); ArrayInitialize(maFilterCloseDn, 0);
      ArrayResize(maFilterStopUp, symbols_count); ArrayInitialize(maFilterStopUp, 0);
      ArrayResize(maFilterStopDn, symbols_count); ArrayInitialize(maFilterStopDn, 0);
      ArrayResize(maFilterShortStop, symbols_count); ArrayInitialize(maFilterShortStop, false);
      ArrayResize(maFilterLongStop, symbols_count); ArrayInitialize(maFilterLongStop, false);
      ArrayResize(maFilterShortOpen, symbols_count); ArrayInitialize(maFilterShortOpen, false);
      ArrayResize(maFilterLongOpen, symbols_count); ArrayInitialize(maFilterLongOpen, false);
      ArrayResize(maFilterShortClose, symbols_count); ArrayInitialize(maFilterShortClose, false);
      ArrayResize(maFilterLongClose, symbols_count); ArrayInitialize(maFilterLongClose, false);
      for(int i=0; i<setup_count; i++){
         maFilterMaPeriod[i] = (int) (maFilter_MaPeriodBegin * (MathPow(maFilter_MaPeriodMultiplier, i)));
         maFilterAtrPeriod[i] = (int) (maFilter_AtrPeriodBegin * (MathPow(maFilter_AtrPeriodMultiplier, i)));
         maFilterAtrBands[i] = maFilter_AtrBandsBegin * (MathPow(maFilter_AtrBandsMultiplier, i));
      } 
   }
   useCurrencyTrends = (useManualCurrencyStrength || useCCFpTrendControl || useSentimentMyFxBook || useSentimentSharkFx || useTrendBalanceByMargin);
   useSentiment = (useSentimentMyFxBook || useSentimentSharkFx);
   if(useSentiment){ update_sentiment = false; }
   int count = 0; string _currency, _currencies[];
   
   if(useCurrencyTrends){ 
      ArrayResize(symbolTrend, symbols_count); ArrayInitialize(symbolTrend, 0);
      ArrayResize(trendShortStop, symbols_count); ArrayInitialize(trendShortStop, false);
      ArrayResize(trendLongStop, symbols_count); ArrayInitialize(trendLongStop, false);
      ArrayResize(trendShortClose, symbols_count); ArrayInitialize(trendShortClose, false);
      ArrayResize(trendLongClose, symbols_count); ArrayInitialize(trendLongClose, false);
   }
   update_marginTrend = true; 
   if(useTrendBalanceByMargin){
      ArrayResize(marginTrendBySymbol, symbols_count); ArrayInitialize(marginTrendBySymbol, 0);
      
   } 
   if(useManualCurrencyStrength){
      ArrayResize(manualTrend, currencies_count); ArrayInitialize(manualTrend, 0);
      
      if(manualStrongCurrenciesStr != ""){
         count =  StringSplit(manualStrongCurrenciesStr,StringGetCharacter(",",0),_currencies);
         for(int i=0; i < count; i++){
            _currency = _currencies[i];
            if(hashCurrencies.hContainsKey(_currency)) {
               manualTrend[hashCurrencies.hGetInt(_currency)]++;
               logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing manual Strong currencies: Add ", _currency));
            }
         }
      }
      if(manualWeakCurrenciesStr != ""){
         count =  StringSplit(manualWeakCurrenciesStr,StringGetCharacter(",",0),_currencies);
         for(int i=0; i < count; i++){
            _currency = _currencies[i];
            if(hashCurrencies.hContainsKey(_currency)) {
               manualTrend[hashCurrencies.hGetInt(_currency)]--;
               logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing manual Weak currencies: Add ", _currency));
            }
         }
      }
      
      if(!useCCFpTrendControl && !useSentimentMyFxBook && !useSetupBalanceByMargin){
         Print(StringConcatenate("useManualCurrencyStrength -> ENTER if(!useCCFpTrendControl && !useSentimentMyFxBook){"));
         int iCur1=0, iCur2=0;
         for(int i=0; i<symbols_count; i++){
            string _symbol = listCleanSymbols[i];
            string _currency1 = StringSubstr(_symbol, 0,3); 
            string _currency2 = StringSubstr(_symbol, 3,3); 
            if(hashCurrencies.hContainsKey(_currency1)){
               iCur1 = hashCurrencies.hGetInt(_currency1);
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframe, "initCore", StringConcatenate("Stop trading ",_symbol,". Currency1 (",_currency1,") not found in hashCurrencies"));
               trendShortStop[i] = trendLongStop[i] = true; 
               continue;
            }
            if(hashCurrencies.hContainsKey(_currency2)){
               iCur2 = hashCurrencies.hGetInt(_currency2);
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframe, "initCore", StringConcatenate("Stop trading ",_symbol,". Currency2 (",_currency2,") not found in hashCurrencies"));
               trendShortStop[i] = trendLongStop[i] = true; 
               continue;
            }
            symbolTrend[i] += manualTrend[iCur1] - manualTrend[iCur2];
         }
         info_balance = "CURRENCIES BALANCE:"+NL; 
         info_balance += "Symbols Strong4: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] >= 4) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Strong3: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == 3) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Strong2: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == 2) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Strong1: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == 1) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Neutral: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == 0) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Weak1: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == -1) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Weak2: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == -2) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Weak3: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] == -3) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL;
         info_balance += "Symbols Weak4: "; for(int i=0;i<symbols_count;i++) if(symbolTrend[i] <= -4) { info_balance += listCleanSymbols[i] + " "; } info_balance += NL; 
      }
   }
   if(currenciesLongOnlyStr != ""){
      count = StringSplit(currenciesLongOnlyStr,StringGetCharacter(",",0),_currencies);
      for(int i=0; i < count; i++){
         _currency = _currencies[i];
         if(!hashCurrenciesLongOnly.hContainsKey(_currency)) {
            hashCurrenciesLongOnly.hPutInt(_currency,0);
            logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing currencies Long Only: Add ", _currency));
         }
      }
   }
   if(currenciesShortOnlyStr != ""){
      count = StringSplit(currenciesShortOnlyStr,StringGetCharacter(",",0),_currencies);
      for(int i=0; i < count; i++){
         _currency = _currencies[i];
         if(!hashCurrenciesShortOnly.hContainsKey(_currency)) {
            hashCurrenciesShortOnly.hPutInt(_currency,0);
            logMessage(LOG_WARN, "", 0, "initCore", StringConcatenate("Initializing currencies Short Only: Add ", _currency));
         }
      }
   }
   if(useCCFpTrendControl){
      ArrayResize(ccfpValues, currencies_count); ArrayInitialize(ccfpValues, 0.0);
      ArrayResize(ccfpTrend, currencies_count); ArrayInitialize(ccfpTrend, 0);
      int currencyMultiplier = currencies_count/2;
      ccfpBalanceBegin *= currencyMultiplier;
      ccfpBalanceStep *= currencyMultiplier;
      ccfpBalanceEnd *= currencyMultiplier;
      
   }
   
   if(useSentimentMyFxBook){
      ArrayResize(sentimentMfbValues, currencies_count); ArrayInitialize(sentimentMfbValues, 0.0);
      ArrayResize(sentimentMfbTrend, currencies_count); ArrayInitialize(sentimentMfbTrend, 0);
      initSentimentMyFxBookData(listCurrencies);
      //updateSentimentMyFxBook();
   }
   if(useSentimentSharkFx){
      ArrayResize(sentimentSfxValues, currencies_count); ArrayInitialize(sentimentSfxValues, 0.0);
      ArrayResize(sentimentSfxTrend, currencies_count); ArrayInitialize(sentimentSfxTrend, 0);
   }
    
   if(useZigzag){
      ArrayResize(zzCtrl, symbols_count);
      ArrayResize(settings, symbols_count);
      ArrayResize(zupInitializedBySetup, symbols_count); ArrayInitialize(zupInitializedBySetup, false);
      ArrayResize(zupInitializedBySymbol, symbols_count); ArrayInitialize(zupInitializedBySymbol, false);
   }

   useMurreyMath = ((murrey_openSignal_timeframe != OFF) || (murrey_closeSignal_timeframe != OFF) || (murrey_range1_timeframe != OFF) || (murrey_range2_timeframe != OFF) ||
                    (murrey_range3_timeframe != OFF) || (murrey_trend1_timeframe != OFF) || (murrey_trend2_timeframe != OFF) || (murrey_trend3_timeframe != OFF));
   
   if(useMurreyMath){
      MurreyMathSettings *murreySettings = new MurreyMathSettings(murrey_open_direction, murrey_close_direction);
   
      if(murrey_openSignal_timeframe != OFF){
         murreySettings.InitializeSignalOpenBuy(murrey_openSignal_buyStr);
         murreySettings.InitializeSignalOpenSell(murrey_openSignal_sellStr);
         ArrayResize(murreyOpenSignal, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyOpenSignal[i] = new MurreyMath(listBrokerSymbols[i], murrey_openSignal_timeframe, murrey_openSignal_period, murrey_signal_delta, murrey_openSignal_AtrPeriod, murrey_openSignal_minAtr, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_closeSignal_timeframe != OFF){
         murreySettings.InitializeSignalCloseBuy(murrey_closeSignal_buyStr);
         murreySettings.InitializeSignalCloseSell(murrey_closeSignal_sellStr);
         ArrayResize(murreyCloseSignal, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyCloseSignal[i] = new MurreyMath(listBrokerSymbols[i], murrey_closeSignal_timeframe, murrey_closeSignal_period, murrey_signal_delta, murrey_closeSignal_AtrPeriod, murrey_closeSignal_minAtr, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_range1_timeframe != OFF){
         murreySettings.InitializeRange1OpenBuy(murrey_range1_openBuyStr);
         murreySettings.InitializeRange1OpenSell(murrey_range1_openSellStr);
         ArrayResize(murreyRange1, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyRange1[i] = new MurreyMath(listBrokerSymbols[i], murrey_range1_timeframe, murrey_range1_period, murrey_signal_delta, murrey_range1_AtrPeriod, murrey_range1_minAtr, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_range2_timeframe != OFF){
         murreySettings.InitializeRange2OpenBuy(murrey_range2_openBuyStr);
         murreySettings.InitializeRange2OpenSell(murrey_range2_openSellStr);
         ArrayResize(murreyRange2, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyRange2[i] = new MurreyMath(listBrokerSymbols[i], murrey_range2_timeframe, murrey_range2_period, murrey_signal_delta, murrey_range2_AtrPeriod, murrey_range2_minAtr, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_range3_timeframe != OFF){
         murreySettings.InitializeRange3OpenBuy(murrey_range3_openBuyStr);
         murreySettings.InitializeRange3OpenSell(murrey_range3_openSellStr);
         ArrayResize(murreyRange3, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyRange3[i] = new MurreyMath(listBrokerSymbols[i], murrey_range3_timeframe, murrey_range3_period, murrey_signal_delta, murrey_range3_AtrPeriod, murrey_range3_minAtr, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_trend1_timeframe != OFF){
         murreySettings.InitializeTrend1Values(murrey_trend1_sequence_str);
         ArrayResize(murreyTrend1, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyTrend1[i] = new MurreyMath(listBrokerSymbols[i], murrey_trend1_timeframe, murrey_trend1_period, murrey_signal_delta, 0, 0, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_trend2_timeframe != OFF){
         murreySettings.InitializeTrend2Values(murrey_trend2_sequence_str);
         ArrayResize(murreyTrend2, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyTrend2[i] = new MurreyMath(listBrokerSymbols[i], murrey_trend2_timeframe, murrey_trend2_period, murrey_signal_delta, 0, 0, murrey_signal_closeBar, murreySettings);
         }
      }
      if(murrey_trend3_timeframe != OFF){
         murreySettings.InitializeTrend3Values(murrey_trend3_sequence_str);
         ArrayResize(murreyTrend3, symbols_count);
         for (int i = 0; i < symbols_count; i++){
            murreyTrend3[i] = new MurreyMath(listBrokerSymbols[i], murrey_trend3_timeframe, murrey_trend3_period, murrey_signal_delta, 0, 0, murrey_signal_closeBar, murreySettings);
         }
      }
   }
   if(use_fiboPatterns){  
      InitializeFiboPattern(fibo_BD_pattern_values, fibo_BD_delta_values, fibo_BD_pattern_size, fibo_BD_patterns, "BD");
      InitializeFiboPattern(fibo_AC_pattern_values, fibo_AC_delta_values, fibo_AC_pattern_size, fibo_AC_patterns, "AC");
      InitializeFiboPattern(fibo_XB_pattern_values, fibo_XB_delta_values, fibo_XB_pattern_size, fibo_XB_patterns, "XB");
      InitializeFiboPattern(fibo_XD_pattern_values, fibo_XD_delta_values, fibo_XD_pattern_size, fibo_XD_patterns, "XD");
      InitializeFiboPattern(fibo_AD_pattern_values, fibo_AD_delta_values, fibo_AD_pattern_size, fibo_AD_patterns, "AD");
      InitializeFiboPattern(fibo_BD_minor_values, fibo_BD_minor_delta_values, fibo_BD_minor_size, fibo_BD_minorCombination, "BD_minor");
      ArrayResize(fibo_lastMatchFibo, symbols_count); ArrayInitialize(fibo_lastMatchFibo, 0.0);
      ArrayResize(fibo_lastTradeType, symbols_count); ArrayInitialize(fibo_lastTradeType, 0);
      ArrayResize(fibo_lastTradeFibo, symbols_count); ArrayInitialize(fibo_lastTradeFibo, 0.0);     
      InitializeFiboWeakStrong();
   }
   ArrayResize(fibo_lastMatchFiboPos, symbols_count); ArrayInitialize(fibo_lastMatchFiboPos, 0);
   ArrayResize(fibo_lastTradeFiboPos, symbols_count); ArrayInitialize(fibo_lastTradeFiboPos, 0);  
      
   if(useHarmonicPatterns){
      ArrayResize(harmonicPatterns, symbols_count);     
   }
   if(usePitchfork){
      ArrayResize(pitchforkCtrl, symbols_count); 
      ArrayResize(pitchforkLastPeakSignal, symbols_count); ArrayInitialize(pitchforkLastPeakSignal, 0);      
   }
   if(useIndicator){
      ArrayResize(filterSignalByTimeframe, symbols_count); ArrayInitialize(filterSignalByTimeframe, false);
      ArrayResize(atrFastData, symbols_count); ArrayInitialize(atrFastData, 0);
      ArrayResize(atrSlowData, symbols_count); ArrayInitialize(atrSlowData, 0);
   }
   if(useAvgVolume){
      ArrayResize(avgVolumeFastData, symbols_count); ArrayInitialize(avgVolumeFastData, 0);
      ArrayResize(avgVolumeSlowData, symbols_count); ArrayInitialize(avgVolumeSlowData, 0);
      ArrayResize(avgVolumeValue, symbols_count); ArrayInitialize(avgVolumeValue, 0);
   }
   ArrayResize(initialSetupBalanceAvgVol, setup_count); ArrayInitialize(initialSetupBalanceAvgVol, true);
   ArrayResize(setupBalanceAvgVol, setup_count); ArrayInitialize(setupBalanceAvgVol, true);
   setupBalanceAvgVolShift = setupBalanceAvgVolLastShift = 0;
   if(useAvgVolumeBalance){
      logMessage(LOG_WARN, "", timeframe, "initCore", StringConcatenate("AvgVolumeBalance enabled: ",avgVB_initial_setup));
      string setupBalanceStr[];
      int _count =  StringSplit(avgVB_initial_setup,StringGetCharacter(",",0),setupBalanceStr);
      if(_count == setup_count){
         for(int iSet=0; iSet < setup_count; iSet++){
            if(setupBalanceStr[iSet] == "0"){
               initialSetupBalanceAvgVol[iSet] = setupBalanceAvgVol[iSet] = false;
               logMessage(LOG_WARN, "", timeframe, "initCore", StringConcatenate("AvgVolumeBalance setup(",iSet,") = ",setupBalanceStr[iSet], "(false)"));
            }
            else{
               initialSetupBalanceAvgVol[iSet] = setupBalanceAvgVol[iSet] = true;
               logMessage(LOG_WARN, "", timeframe, "initCore", StringConcatenate("AvgVolumeBalance setup(",iSet,") = ",setupBalanceStr[iSet],"(true)"));
            }
         }
      }
      else{
         useAvgVolumeBalance = false;
         logMessage(LOG_CRITICAL, "", timeframe, "initCore", StringConcatenate("failed to initialize AvgVolumeBalance: ",avgVB_initial_setup));
      }
   }
   if(usePva){
      ArrayResize(pvaRisingBullData, symbols_count); ArrayInitialize(pvaRisingBullData, 0);
      ArrayResize(pvaRisingBearData, symbols_count); ArrayInitialize(pvaRisingBearData, 0);
      ArrayResize(pvaClimaxBullData, symbols_count); ArrayInitialize(pvaClimaxBullData, 0);
      ArrayResize(pvaClimaxBearData, symbols_count); ArrayInitialize(pvaClimaxBearData, 0);
      ArrayResize(pvaVolumeValue, symbols_count); ArrayInitialize(pvaVolumeValue, 0);
      ArrayResize(pvaLongFilter, symbols_count); ArrayInitialize(pvaLongFilter, false);
      ArrayResize(pvaShortFilter, symbols_count); ArrayInitialize(pvaShortFilter, false);
   }
   if(useBands){
      ArrayResize(bandsUpperData, symbols_count); ArrayInitialize(bandsUpperData, 0);
      ArrayResize(bandsMainData, symbols_count); ArrayInitialize(bandsMainData, 0);
      ArrayResize(bandsLowerData, symbols_count); ArrayInitialize(bandsLowerData, 0);
      ArrayResize(bandsWidth, symbols_count); ArrayInitialize(bandsWidth, 0);
      ArrayResize(bandsUpperExpansion, symbols_count); ArrayInitialize(bandsUpperExpansion, 0);
      ArrayResize(bandsLowerExpansion, symbols_count); ArrayInitialize(bandsLowerExpansion, 0);
      ArrayResize(bandsExpansion, symbols_count); ArrayInitialize(bandsExpansion, 0);
      ArrayResize(bandsExpansionBullSignal, symbols_count); ArrayInitialize(bandsExpansionBullSignal, 0);
      ArrayResize(bandsExpansionBearSignal, symbols_count); ArrayInitialize(bandsExpansionBearSignal, 0);
      ArrayResize(bandsRejectionBullSignal, symbols_count); ArrayInitialize(bandsRejectionBullSignal, 0);
      ArrayResize(bandsRejectionBearSignal, symbols_count); ArrayInitialize(bandsRejectionBearSignal, 0);
      ArrayResize(bandsTrendExpansion, symbols_count); ArrayInitialize(bandsTrendExpansion, 0);
   }
   if(useCandlePattern){
      ArrayResize(engulfValue, symbols_count); ArrayInitialize(engulfValue, 0);
      ArrayResize(pinbarValue, symbols_count); ArrayInitialize(pinbarValue, 0);
      ArrayResize(candlePatternValue, symbols_count); ArrayInitialize(candlePatternValue, 0);
   }   
}
//+------------------------------------------------------------------+ 
void deinitCore(){
   for (int _iSymbol = 0; _iSymbol < symbols_count; _iSymbol++) 
   {
      for(int _iSetup=0; _iSetup < setup_count; _iSetup++){
         if(setupInUse[_iSetup]){ 
            if(useZigzag){
               if(settings[_iSymbol][_iSetup] != NULL) delete(settings[_iSymbol][_iSetup]);
               if(zzCtrl[_iSymbol][_iSetup] != NULL) delete(zzCtrl[_iSymbol][_iSetup]);
               if(usePitchfork){
                  if(pitchforkCtrl[_iSymbol][_iSetup] != NULL) delete(pitchforkCtrl[_iSymbol][_iSetup]); 
               }
               if(useHarmonicPatterns)
                  if(harmonicPatterns[_iSymbol][_iSetup] != NULL) delete(harmonicPatterns[_iSymbol][_iSetup]);
            }
         }  
      }
      if(murrey_openSignal_timeframe != OFF){  if(murreyOpenSignal[_iSymbol] != NULL) delete(murreyOpenSignal[_iSymbol]); }
      if(murrey_closeSignal_timeframe != OFF){  if(murreyCloseSignal[_iSymbol] != NULL) delete(murreyCloseSignal[_iSymbol]); }
      if(murrey_range1_timeframe != OFF){  if(murreyRange1[_iSymbol] != NULL) delete(murreyRange1[_iSymbol]); }
      if(murrey_range2_timeframe != OFF){  if(murreyRange2[_iSymbol] != NULL) delete(murreyRange2[_iSymbol]); }
      if(murrey_range3_timeframe != OFF){  if(murreyRange3[_iSymbol] != NULL) delete(murreyRange3[_iSymbol]); }
      if(murrey_trend1_timeframe != OFF){  if(murreyTrend1[_iSymbol] != NULL) delete(murreyTrend1[_iSymbol]); }
      if(murrey_trend2_timeframe != OFF){  if(murreyTrend2[_iSymbol] != NULL) delete(murreyTrend2[_iSymbol]); }
      if(murrey_trend3_timeframe != OFF){  if(murreyTrend3[_iSymbol] != NULL) delete(murreyTrend3[_iSymbol]); }
   }
   if(hashOpenOrders != NULL) delete(hashOpenOrders);
   if(hashBrokerSymbols != NULL) delete(hashBrokerSymbols);
   if(hashCleanSymbols != NULL) delete(hashCleanSymbols);
   if(hashCurrencies != NULL) delete(hashCurrencies);
   if(hashCurrencyUsdSymbol != NULL) delete(hashCurrencyUsdSymbol);
   if(hashUsdSymbol != NULL) delete(hashUsdSymbol);
   if(hashCurrenciesLongOnly != NULL) delete(hashCurrenciesLongOnly);
   if(hashCurrenciesShortOnly != NULL) delete(hashCurrenciesShortOnly);
   if(useWindowTimeZZSetup){
      for(int i=0; i<5; i++){
         if(windowTime[i] != NULL) delete(windowTime[i]);
      }
      
   }
   if(useSentimentMyFxBook) deinitSentimentMyFxBookData();
}
//+------------------------------------------------------------------+ 
void initZUP(){  
   TYPE_EXECUTION execution = EXECUTION_EA;
   if(VisualDebug && symbol == Symbol()) 
      execution = EXECUTION_DEBUG;
   for(int _iSetup=0; _iSetup < setup_count; _iSetup++){
      if(setupInUse[_iSetup] && !zupInitializedBySetup[iSymbol][_iSetup]){
         settings[iSymbol][_iSetup] = new GeometrySettings();
         int _init = settings[iSymbol][_iSetup].initSettings(symbol, timeframe, symbolDigits ,symbolPoint, zigzag_type, setupValue[_iSetup][0], setupValue[_iSetup][1], setupValue[_iSetup][2], execution, allTicks, (use_fiboPatterns && update_currentFiboBD),use_zigzag_angle, use_zigzag_size ); 
         if(_init != INIT_SUCCEEDED){
            //logMessage(LOG_ERROR, symbol, timeframe, "initZUP", "initSymbolInfo() FAILED: "+settings[iSymbol][_iSetup].error);
            delete(settings[iSymbol][_iSetup]);
            continue;
         }
         bool _useApMedian = (atrToApMedianBegin > 0 || pitchfork_priceRange > 0 || pitchfork_timeRange > 0);
         bool _useApTynes = false;
         bool _useApTrigger = (use_apSignal_triggerBreak || use_apSignal_triggerBorder || use_triggerAngleDirection || use_triggerAngleExpansion);
         bool _useApAngle = (use_triggerAngleDirection || use_triggerAngleExpansion);
         bool _useApSize = false;
         settings[iSymbol][_iSetup].setApSettings(_useApMedian, _useApTynes, _useApTrigger, _useApAngle, _useApSize);
         zzCtrl[iSymbol][_iSetup] = new ZigzagController(settings[iSymbol][_iSetup]); 
         _init = zzCtrl[iSymbol][_iSetup].initZigZag();     
         if(_init != INIT_SUCCEEDED){
            logMessage(LOG_ERROR, symbol, timeframe, "initZUP", "ZupController.initZigZag()() FAILED!");
            delete(zzCtrl[iSymbol][_iSetup]);
            continue;
         }
         if(useHarmonicPatterns){
            harmonicPatterns[iSymbol][_iSetup] = new HarmonicPatterns();
         }
         if(usePitchfork){
            pitchforkCtrl[iSymbol][_iSetup] = new PitchforkController();
            pitchforkCtrl[iSymbol][_iSetup].initPitchfork(zzCtrl[iSymbol][_iSetup]);
         }
         zupInitializedBySetup[iSymbol][_iSetup] = true;
      }
   }
   zupInitializedBySymbol[iSymbol] = true;
   for(int _iSetup=0; _iSetup<setup_count; _iSetup++){
      if(setupInUse[_iSetup]) zupInitializedBySymbol[iSymbol] = zupInitializedBySymbol[iSymbol] && zupInitializedBySetup[iSymbol][_iSetup];
   }
}
//+------------------------------------------------------------------+ 
bool initCurrenciesAndSymbols(){
   hashBrokerSymbols = new Hash();
   hashCleanSymbols = new Hash();
   hashCurrencies = new Hash();
   hashCurrencyUsdSymbol = new Hash();
   hashUsdSymbol = new Hash();
   Hash *hashCurrenciesTemp = new Hash();
   
   string symbolsTemp[], currenciesTemp[];
   string _currency1, _currency2, _brokerSymbol, _cleanSymbol;
   int countTemp = 0, pos;
   symbols_count = currencies_count = 0;
   brokerSymbols_count = SymbolsTotal(false);
   HashLoop *l;
   
   if(currenciesStr != ""){

      countTemp = StringSplit(currenciesStr,StringGetCharacter(",",0),currenciesTemp);
      for(int iCur = 0; iCur < countTemp; iCur++){
         _currency1 = currenciesTemp[iCur];
         if(StringLen(_currency1) != 3) {
            logMessage(LOG_ERROR, symbol, timeframe, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Currency ",_currency1,": StringLen != 3"));
            continue;
         }
         if(!hashCurrencies.hContainsKey(_currency1)){
            hashCurrencies.hPutInt(_currency1, currencies_count);
            currencies_count++;
         }
      }
      for(int i=0;i<brokerSymbols_count;i++){
         _brokerSymbol = SymbolName(i,false);
         _cleanSymbol = _brokerSymbol;
         
         if(symbol_prefix != "" && StringFind(_brokerSymbol, symbol_prefix) == -1) continue;
         if(symbol_suffix != "" && StringFind(_brokerSymbol, symbol_suffix) == -1) continue;
         if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
         if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);
         
         if(StringLen(_cleanSymbol) == 6) {
            _currency1 = StringSubstr(_cleanSymbol, 0,3);
            _currency2 = StringSubstr(_cleanSymbol, 3,3);
            if( (currencyFillType == FILL_INCLUSIVE && (hashCurrencies.hContainsKey(_currency1) || hashCurrencies.hContainsKey(_currency2))) ||
                (currencyFillType == FILL_EXCLUSIVE && (hashCurrencies.hContainsKey(_currency1) && hashCurrencies.hContainsKey(_currency2)))
              ){
               logMessage(LOG_WARN, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Found symbol ", _cleanSymbol," by Currency list"));
               hashCleanSymbols.hPutInt(_cleanSymbol, symbols_count);
               hashBrokerSymbols.hPutInt(_brokerSymbol, symbols_count);
               symbols_count++;
               if(currencyFillType == FILL_INCLUSIVE){
                  if(!hashCurrencies.hContainsKey(_currency1)){ hashCurrenciesTemp.hPutInt(_currency1, currencies_count); currencies_count++; }
                  if(!hashCurrencies.hContainsKey(_currency2)){ hashCurrenciesTemp.hPutInt(_currency2, currencies_count); currencies_count++; }
               }
            }
         }
      } 
      for( l = new HashLoop(hashCurrenciesTemp) ; l.hasNext() ; l.next()) {
         hashCurrencies.hPutInt(l.key(),l.valInt());
      }
      delete(l);
   }

   countTemp = 0;
   if(symbolsStr != ""){
      countTemp =  StringSplit(symbolsStr,StringGetCharacter(",",0),symbolsTemp);
   }
   for(int iSym=0; iSym < countTemp; iSym++){
      _cleanSymbol = symbolsTemp[iSym];
      if(StringLen(_cleanSymbol) != 6) {
         logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Symbol ",_cleanSymbol,": StringLen != 6"));
         continue;
      }
      hashCleanSymbols.hPutInt(_cleanSymbol, symbols_count);
      hashBrokerSymbols.hPutInt(symbol_prefix+_cleanSymbol+symbol_suffix, symbols_count);
      symbols_count++;
      
      _currency1 = StringSubstr(_cleanSymbol, 0,3);
      _currency2 = StringSubstr(_cleanSymbol, 3,3);
      if(!hashCurrencies.hContainsKey(_currency1)){
         hashCurrencies.hPutInt(_currency1, currencies_count);
         currencies_count++;
      }
      if(!hashCurrencies.hContainsKey(_currency2)){
         hashCurrencies.hPutInt(_currency2, currencies_count);
         currencies_count++;
      }
   }

   if(symbols_count == 0){
      _cleanSymbol = _brokerSymbol = Symbol();
      if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
      if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);
      
      if(StringLen(_cleanSymbol) != 6) {
         logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Ignoring Symbol ",_cleanSymbol,": StringLen != 6"));
      }
      hashCleanSymbols.hPutInt(_cleanSymbol, symbols_count);
      hashBrokerSymbols.hPutInt(_brokerSymbol, symbols_count);
      symbols_count++;
      
      _currency1 = StringSubstr(_cleanSymbol, 0,3);
      _currency2 = StringSubstr(_cleanSymbol, 3,3);
      hashCurrencies.hPutInt(_currency1, currencies_count);
      currencies_count++;
      hashCurrencies.hPutInt(_currency2, currencies_count);
      currencies_count++; 
   } 
   // END FILL hashCurrencies, hashBrokerSymbols, hashCleanSymbols
   // BEGIN FILL listCurrencies, listBrokerSymbols, listCleanSymbols
   
   if(symbols_count == 0 || currencies_count == 0){
      logMessage(LOG_ERROR, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Unable to start EA, no valid symbol/currency found!"));
      return false;logMessage(LOG_INFO, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing list of currencies, size: ", currencies_count,"/",hashCurrencies.getCount()));
   }
   ArrayResize(listCurrencies,currencies_count);
   ArrayResize(listCleanSymbols,symbols_count);
   ArrayResize(listBrokerSymbols,symbols_count);
   
   
   for( l = new HashLoop(hashCurrencies) ; l.hasNext() ; l.next()) {
      _currency1 = l.key(); 
      pos = l.valInt();
      logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of currencies: ", pos, "-", _currency1));
      listCurrencies[pos] = _currency1;
   }
   delete(l);
   logMessage(LOG_INFO, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing list of broker symbols, size: ", symbols_count,"/",hashBrokerSymbols.getCount()));
   for( l = new HashLoop(hashBrokerSymbols) ; l.hasNext() ; l.next()) {
      _brokerSymbol = l.key(); 
      pos = l.valInt();
      logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of broker symbols: ", pos, "-", _brokerSymbol));
      listBrokerSymbols[pos] = _brokerSymbol;
   }
   delete(l);
   logMessage(LOG_INFO, symbol, 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing list of clean symbols, size: ", symbols_count,"/",hashCleanSymbols.getCount()));
   for( l = new HashLoop(hashCleanSymbols) ; l.hasNext() ; l.next()) {
      _cleanSymbol = l.key(); 
      pos = l.valInt();
      logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("List of clean symbols: ", pos, "-", _cleanSymbol));
      listCleanSymbols[pos] = _cleanSymbol;
   }
   delete(l);   
   // END FILL listCurrencies, listBrokerSymbols, listCleanSymbols

   for(int iCurrency=0; iCurrency<currencies_count; iCurrency++){
      if(listCurrencies[iCurrency] != "USD"){
         if(!hashCurrencyUsdSymbol.hContainsKey(listCurrencies[iCurrency])){
            for(int i=0;i<brokerSymbols_count;i++){
               _cleanSymbol = SymbolName(i,false);
               if(StringFind(_cleanSymbol,"USD") != -1 && StringFind(_cleanSymbol,listCurrencies[iCurrency]) != -1){
                  if(symbol_prefix != "") _cleanSymbol = cutPrefix(_cleanSymbol, symbol_prefix);
                  if(symbol_suffix != "") _cleanSymbol = cutSuffix(_cleanSymbol, symbol_suffix);
                  //logMessage(LOG_INFO, "", 0, "initCurrenciesAndSymbols", StringConcatenate("Initializing hashCurrencyUsdSymbol: ", listCurrencies[iCurrency], "-", _cleanSymbol));
                  hashCurrencyUsdSymbol.hPutString(listCurrencies[iCurrency], _cleanSymbol);
                  break;
               }
            }
         }
      }
   }
   
   usdSymbols_count = hashCurrencyUsdSymbol.getCount();
   ArrayResize(usdSymbols_maValue, usdSymbols_count);
   ArrayResize(listUsdSymbols, usdSymbols_count);
 
   int iUsdSym = 0; string currency;
   for( l = new HashLoop(hashCurrencyUsdSymbol) ; l.hasNext() ; l.next()) {
      currency = l.key(); symbol = l.valString();
      listUsdSymbols[iUsdSym][0]=symbol;
      listUsdSymbols[iUsdSym][1]=StringSubstr(symbol, 0,3);
      listUsdSymbols[iUsdSym][2]=StringSubstr(symbol, 3,3);
      hashUsdSymbol.hPutInt(symbol, iUsdSym);
      iUsdSym++;
      logMessage(LOG_INFO, symbol, timeframe, "initCurrenciesAndSymbols", StringConcatenate("hashCurrencyUsdSymbol Currency: ",currency,", Symbol: ",symbol, ", size: ", hashCurrencyUsdSymbol.getCount()));
   }
   delete(l);
   if(hashCurrenciesTemp != NULL) delete hashCurrenciesTemp;
   //if(iUsdSym != usdSymbols_count){ logMessage(LOG_ERROR, "", timeframe, "initCurrenciesAndSymbols", StringConcatenate("Expected USD symbols is ",usdSymbols_count, ", found ",iUsdSym,".")); }
   
   return true;
}
//+------------------------------------------------------------------+ 
void updateAllTicks(){
   update_allTicks = false;
   iTime_filterAllTicks = TimeCurrent(); 
   if( (iTime_filterAllTicks - period_check_filterAllTicks) >= filterAllTicksBySeconds ){
      update_allTicks = true;
      period_check_filterAllTicks = iTime_filterAllTicks;
   }
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
void updateCCFp(){
   update_ccfp = false;
   iTime_ccfp = iTime(NULL,timeframeCCFp,0); 
   if(period_check_ccfp != iTime_ccfp){
      update_ccfp = true;
      updateCCFpValues();
      period_check_ccfp = iTime_ccfp;
   }
}
//+------------------------------------------------------------------+ 
void updateCurrentTimeframe(){
   update_currentTF = false;
   iTime_currentTF = iTime(NULL,timeframe,0); 
   if(period_check_currentTF != iTime_currentTF){
      update_currentTF = true;
      period_check_currentTF = iTime_currentTF;
   }
}
//+------------------------------------------------------------------+ 
void updateBarForce(){
   update_barforce = false;
   iTime_barForce = iTime(NULL,barForce_timeframe,0); 
   if(period_check_barForce != iTime_barForce){
      string _symbol = "";
      update_barforce = true;
      for(int i=0; i<symbols_count; i++){
         _symbol = listBrokerSymbols[i];
         double priceOpen = 0, priceClose = 0, priceHigh = 0, priceLow = 0;
         double priceBodyHigh = 0, priceBodyLow = 0;
         if(useDailyBarForce){
            dailyAtrValue[i] = iATR(_symbol, PERIOD_D1, barForce_atrPeriod, 0);
            priceOpen = iOpen(_symbol, PERIOD_D1, 1);
            priceClose = iClose(_symbol, PERIOD_D1, 1);
            priceHigh = iHigh(_symbol, PERIOD_D1, 1);
            priceLow = iLow(_symbol, PERIOD_D1, 1);
            priceBodyHigh = MathMax(priceOpen, priceClose);
            priceBodyLow = MathMin(priceOpen, priceClose);
            dailyForceLimits[i][0] = priceHigh + (dailyAtrValue[i]*2);
            dailyForceLimits[i][1] = priceHigh + (dailyAtrValue[i]*1.5);
            dailyForceLimits[i][2] = priceHigh + (dailyAtrValue[i]);
            dailyForceLimits[i][3] = priceHigh + (dailyAtrValue[i]*0.5);
            dailyForceLimits[i][4] = priceHigh;
            dailyForceLimits[i][5] = priceBodyHigh;
            dailyForceLimits[i][6] = priceBodyLow;
            dailyForceLimits[i][7] = priceLow;
            dailyForceLimits[i][8] = priceLow - (dailyAtrValue[i]*0.5);
            dailyForceLimits[i][9] = priceLow - (dailyAtrValue[i]);
            dailyForceLimits[i][10] = priceLow - (dailyAtrValue[i]*1.5);
            dailyForceLimits[i][11] = priceLow - (dailyAtrValue[i]*2); 
         }
         if(useWeeklyBarForce){
            weeklyAtrValue[i] = iATR(_symbol, PERIOD_W1, barForce_atrPeriod, 0);
            priceOpen = iOpen(_symbol, PERIOD_W1, 1);
            priceClose = iClose(_symbol, PERIOD_W1, 1);
            priceHigh = iHigh(_symbol, PERIOD_W1, 1);
            priceLow = iLow(_symbol, PERIOD_W1, 1);
            priceBodyHigh = MathMax(priceOpen, priceClose);
            priceBodyLow = MathMin(priceOpen, priceClose);
            weeklyForceLimits[i][0] = priceHigh + (weeklyAtrValue[i]*2);
            weeklyForceLimits[i][1] = priceHigh + (weeklyAtrValue[i]*1.5);
            weeklyForceLimits[i][2] = priceHigh + (weeklyAtrValue[i]);
            weeklyForceLimits[i][3] = priceHigh + (weeklyAtrValue[i]*0.5);
            weeklyForceLimits[i][4] = priceHigh;
            weeklyForceLimits[i][5] = priceBodyHigh;
            weeklyForceLimits[i][6] = priceBodyLow;
            weeklyForceLimits[i][7] = priceLow;
            weeklyForceLimits[i][8] = priceLow - (weeklyAtrValue[i]*0.5);
            weeklyForceLimits[i][9] = priceLow - (weeklyAtrValue[i]);
            weeklyForceLimits[i][10] = priceLow - (weeklyAtrValue[i]*1.5);
            weeklyForceLimits[i][11] = priceLow - (weeklyAtrValue[i]*2);
         }
         if(useMonthlyBarForce){
            monthlyAtrValue[i] = iATR(_symbol, PERIOD_MN1, barForce_atrPeriod, 0);
            priceOpen = iOpen(_symbol, PERIOD_MN1, 1);
            priceClose = iClose(_symbol, PERIOD_MN1, 1);
            priceHigh = iHigh(_symbol, PERIOD_MN1, 1);
            priceLow = iLow(_symbol, PERIOD_MN1, 1);
            priceBodyHigh = MathMax(priceOpen, priceClose);
            priceBodyLow = MathMin(priceOpen, priceClose);
            monthlyForceLimits[i][0] = priceHigh + (monthlyAtrValue[i]*2);
            monthlyForceLimits[i][1] = priceHigh + (monthlyAtrValue[i]*1.5);
            monthlyForceLimits[i][2] = priceHigh + (monthlyAtrValue[i]);
            monthlyForceLimits[i][3] = priceHigh + (monthlyAtrValue[i]*0.5);
            monthlyForceLimits[i][4] = priceHigh;
            monthlyForceLimits[i][5] = priceBodyHigh;
            monthlyForceLimits[i][6] = priceBodyLow;
            monthlyForceLimits[i][7] = priceLow;
            monthlyForceLimits[i][8] = priceLow - (monthlyAtrValue[i]*0.5);
            monthlyForceLimits[i][9] = priceLow - (monthlyAtrValue[i]);
            monthlyForceLimits[i][10] = priceLow - (monthlyAtrValue[i]*1.5);
            monthlyForceLimits[i][11] = priceLow - (monthlyAtrValue[i]*2);
         }

      }
      period_check_barForce = iTime_barForce;
   }
}
//+------------------------------------------------------------------+ 
void updateMaFilter(){
   update_maFilter = false;
   iTime_maFilter = iTime(NULL,maFilter_timeframe,0); 
   if(iTime_maFilter == 0){
      logMessage(LOG_CRITICAL, "", timeframe, "updateMaFilter", StringConcatenate("ERROR: iTime_maFilter == 0.0 (Invalid timeframe)"));
   }
   if(period_check_maFilter != iTime_maFilter){
      string _symbol = "";
      update_maFilter = true;
      int shift = allTicks ? 0 : 1;
      for(int iSym=0; iSym<symbols_count; iSym++){
         _symbol = listBrokerSymbols[iSym];
         for(int iSet=0; iSet < setup_count; iSet++){
            maFilterMaValue[iSym][iSet] = iMA(_symbol, maFilter_timeframe, maFilterMaPeriod[iSet], 0, maFilter_method, PRICE_CLOSE, shift);
            if(maFilterMaValue[iSym][iSet] == 0.0){
               logMessage(LOG_CRITICAL, _symbol, timeframe, "updateMaFilter", StringConcatenate("ERROR: maFilterMaValue == 0.0 (the historical data are not sufficient)"));
            }
            maFilterAtrValue[iSym][iSet] = iATR(_symbol, maFilter_timeframe, maFilterAtrPeriod[iSet], shift);
            if(maFilterAtrValue[iSym][iSet] == 0.0){
               logMessage(LOG_CRITICAL, _symbol, timeframe, "updateMaFilter", StringConcatenate("ERROR: maFilterAtrValue == 0.0 (the historical data are not sufficient)"));
            }
            double atrValueBySetup = (maFilterAtrValue[iSym][iSet] * maFilterAtrBands[iSet]);
            maFilterStopUp[iSym][iSet] = maFilterMaValue[iSym][iSet] + (atrValueBySetup*maFilter_atrStop);
            maFilterStopDn[iSym][iSet] = maFilterMaValue[iSym][iSet] - (atrValueBySetup*maFilter_atrStop);
            maFilterOpenUp[iSym][iSet] = maFilterMaValue[iSym][iSet] + (atrValueBySetup*maFilter_atrOpen);
            maFilterOpenDn[iSym][iSet] = maFilterMaValue[iSym][iSet] - (atrValueBySetup*maFilter_atrOpen);
            maFilterCloseUp[iSym][iSet] = maFilterMaValue[iSym][iSet] + (atrValueBySetup*maFilter_atrClose);
            maFilterCloseDn[iSym][iSet] = maFilterMaValue[iSym][iSet] - (atrValueBySetup*maFilter_atrClose);
            
         }
      }
      period_check_maFilter = iTime_maFilter;
   }
}
//+------------------------------------------------------------------+ 
void updateCCFpValues(){
   int iUsdSym, iCurrencies;
   ArrayInitialize(usdSymbols_maValue, 0.0);
   ArrayInitialize(ccfpValues, 0.0);
   
   for(iUsdSym=0; iUsdSym < usdSymbols_count; iUsdSym++){
      usdSymbols_maValue[iUsdSym][0] = ma(listUsdSymbols[iUsdSym][0], ccfp_Fast, ccfp_MA_Method, ccfp_Price, 0);
      usdSymbols_maValue[iUsdSym][1] = ma(listUsdSymbols[iUsdSym][0], ccfp_Slow, ccfp_MA_Method, ccfp_Price, 0);
      if (usdSymbols_maValue[iUsdSym][0] == 0.0 || usdSymbols_maValue[iUsdSym][1] == 0.0){
         logMessage(LOG_ERROR, listUsdSymbols[iUsdSym][0], timeframeCCFp, "updateCCFpValues", StringConcatenate("usdSymbols_maValue == 0"));
         return;
      }
   }
   for(iCurrencies=0;iCurrencies<currencies_count; iCurrencies++){
      ccfpValues[iCurrencies] = 0;
      for(iUsdSym=0; iUsdSym < usdSymbols_count; iUsdSym++){
         if(listCurrencies[iCurrencies] == "USD"){
            if(listUsdSymbols[iUsdSym][1] == "USD")
               ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][0] / usdSymbols_maValue[iUsdSym][1] - 1.0);
            else if(listUsdSymbols[iUsdSym][2] == "USD")
               ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][1] / usdSymbols_maValue[iUsdSym][0] - 1.0);
            else logMessage(LOG_ERROR, listUsdSymbols[iUsdSym][0], timeframeCCFp, "updateCCFpValues", StringConcatenate(" USD Currency not found in Symbol ",listUsdSymbols[iUsdSym][0]));
         }
         else{
            int iSymbolMain = -1;
            HashInt *hashInt; HashString *hashString;
            hashString = hashCurrencyUsdSymbol.hGet(listCurrencies[iCurrencies]);
            if(hashString != NULL){
               hashInt = hashUsdSymbol.hGet(hashString.getVal());
               if(hashInt != NULL)
                  iSymbolMain = hashInt.getVal();
            }
            if(iSymbolMain < 0) {
               logMessage(LOG_ERROR, listUsdSymbols[iUsdSym][0], timeframeCCFp, "updateCCFpValues", StringConcatenate("iSymbolMain not found, currency is ",iCurrencies,"/",listCurrencies[iCurrencies]));
            }

            for(int j=0; j<usdSymbols_count;j++){
               if((listUsdSymbols[j][1]=="USD" && listUsdSymbols[j][2]==listCurrencies[iCurrencies]) || (listUsdSymbols[j][2]=="USD" && listUsdSymbols[j][1]==listCurrencies[iCurrencies])){
                  iSymbolMain = j; break;
               }
            }
            
            if(listUsdSymbols[iSymbolMain][2] == "USD"){
               if(listUsdSymbols[iUsdSym][1] == "USD"){
                  if(listUsdSymbols[iUsdSym][2] == listCurrencies[iCurrencies]){
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][1] / usdSymbols_maValue[iUsdSym][0] - 1.0);
                  }
                  else{
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iSymbolMain][0] * usdSymbols_maValue[iUsdSym][0] / (usdSymbols_maValue[iSymbolMain][1] * usdSymbols_maValue[iUsdSym][1]) - 1.0);
                  }
               }
               else if(listUsdSymbols[iUsdSym][2] == "USD"){
                  if(listUsdSymbols[iUsdSym][1] == listCurrencies[iCurrencies]){
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][0] / usdSymbols_maValue[iUsdSym][1] - 1.0);
                  }
                  else{
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iSymbolMain][0] / usdSymbols_maValue[iUsdSym][0] / (usdSymbols_maValue[iSymbolMain][1] / usdSymbols_maValue[iUsdSym][1]) - 1.0);
                  }
               }
               else logMessage(LOG_ERROR, "", timeframeCCFp, "updateCCFpValues", StringConcatenate(" USD Currency not found in Symbol ",listUsdSymbols[iUsdSym][0]));
            }
            else{
               if(listUsdSymbols[iUsdSym][1] == "USD"){
                  if(listUsdSymbols[iUsdSym][2] == listCurrencies[iCurrencies]){
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][1] / usdSymbols_maValue[iUsdSym][0] - 1.0);
                  }
                  else{
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iSymbolMain][1] / usdSymbols_maValue[iUsdSym][1] / (usdSymbols_maValue[iSymbolMain][0] / usdSymbols_maValue[iUsdSym][0]) - 1.0);
                  }
               }
               else if(listUsdSymbols[iUsdSym][2] == "USD"){
                  if(listUsdSymbols[iUsdSym][1] == listCurrencies[iCurrencies]){
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][0] / usdSymbols_maValue[iUsdSym][1] - 1.0);
                  }
                  else{
                     ccfpValues[iCurrencies] += (usdSymbols_maValue[iUsdSym][1] * usdSymbols_maValue[iSymbolMain][1] / (usdSymbols_maValue[iUsdSym][0] * usdSymbols_maValue[iSymbolMain][0]) - 1.0);
                  }
               }
               else logMessage(LOG_ERROR, "", timeframeCCFp, "updateCCFpValues", StringConcatenate(" USD Currency not found in Symbol ",listUsdSymbols[iUsdSym][0]));
            }
         }
      }
      ccfpValues[iCurrencies] *= 1000.0;
   }
}
//+------------------------------------------------------------------+ 
double ma(string sym, int per, int Mode, int Price, int i) {
   double res = 0;
   int k = 4;   // 1; Brandon
   int ma_shift = 0, tf = 0;
   string mySym;
   mySym = symbol_prefix + sym + symbol_suffix;  
   switch (Period()) {
   case PERIOD_M1: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 5;
   case PERIOD_M5: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 3;
   case PERIOD_M15: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 2;
   case PERIOD_M30: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 2;
   case PERIOD_H1: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 4;
   case PERIOD_H4: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 6;
   case PERIOD_D1: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 5;  // 4; Brandon
   case PERIOD_W1: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i); k += 4;
   case PERIOD_MN1: res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
   }
   // Comment("per*k  ",per*k); Comment("k>MN ",k," res ",res);   
   return (res);
}
//+------------------------------------------------------------------+ 
void drawInfoPanel(int _X, int _Y){
   string label_name = "InfoPanelEA";      
   ObjectCreate(0,label_name,OBJ_RECTANGLE_LABEL,0,0,0);            
   ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,1); 
   ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,15);
   ObjectSetInteger(0,label_name,OBJPROP_XSIZE,_X); 
   ObjectSetInteger(0,label_name,OBJPROP_YSIZE,_Y);
   ObjectSetInteger(0,label_name, OBJPROP_BGCOLOR,clrDarkBlue); 
   ObjectSetString(0,label_name,OBJPROP_TEXT,"Cache");    
   ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,label_name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,label_name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,label_name,OBJPROP_WIDTH,1); 
   ChartSetInteger (0, CHART_FOREGROUND , 0, false);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+ 
void deleteInfoPanel(){
   ObjectDelete("InfoPanelEA");
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
   if(useTimeTradeFilter){ _info += NL + infoTimeTrade + (timeTradeEnabled ? "yes" : "no"); }
   if(useTimeLimitToClose){ _info += NL + infoTimeLimitClose; }
   _info += NL;
   return _info;
}
//+------------------------------------------------------------------+ 
string getInfoAccount(){
   string _info = "";

   _info += "Balance: "+DoubleToString(AccountBalance(),2)+" / ";
   _info += "Equity: "+DoubleToString(AccountEquity(),2)+" / ";
   _info += "FreeMargin: "+DoubleToString(AccountFreeMargin(),2)+" / ";
   _info += "Leverage: "+IntegerToString(leverage)+" / ";
   _info += "Stopout: "+DoubleToString(AccountStopoutLevel(),0)+" / ";
   _info += "Lot: "+DoubleToString((Risk > 0 ? lotSizeByRisk(Risk) : Lots),2)+" / ";
   _info += "Profit: "+DoubleToString(AccountProfit(),2)+" "+AccountCurrency();
   _info += NL;
   return _info;
}
//+------------------------------------------------------------------+ 
string getHeader(string ea_name){

   string _header = sp; 
   _header += "==++== "+ea_name+" ==++=="+NL; 
   _header += "Symbols: " + IntegerToString(symbols_count) + " / Currencies: " + currenciesStr;
   if(!tradeEnabled) _header += " / TRADE DISABLED";
   _header += NL + sp;
   return _header;
}
//+------------------------------------------------------------------+ 
bool checkTimeTrade(){
   bool enabled = false;
   datetime timeCurrent = TimeCurrent(); 
   int hourCurrent =  TimeHour(timeCurrent);
   int minuteCurrent = TimeMinute(timeCurrent);
   
   if(last_hour == hourCurrent && (last_minute == minuteCurrent || (hourCurrent != start_hour_server && hourCurrent != end_hour_server ))){
      return last_trade_enabled;
   }
   
   if(start_hour_server <= end_hour_server){
      if(hourCurrent >= start_hour_server && hourCurrent <= end_hour_server){
         enabled = true;
         if(hourCurrent == start_hour_server){
            if(minuteCurrent < start_minute_server)
               enabled = false;
         }
         if(hourCurrent == end_hour_server){
            if(minuteCurrent >= start_minute_server)
               enabled = false;
         }
      }
   }else{ 
      if(hourCurrent >= start_hour_server || hourCurrent <= end_hour_server){
         enabled = true;
         if(hourCurrent == start_hour_server){
            if(minuteCurrent < start_minute_server)
               enabled = false;
         }
         if(hourCurrent == end_hour_server){
            if(minuteCurrent >= start_minute_server)
               enabled = false;
         }
      }
   }
   last_hour = hourCurrent;
   last_minute = minuteCurrent;
   last_trade_enabled = enabled;
   return enabled;
}
//+------------------------------------------------------------------+ 
bool checkTimeLimitClose(){
   bool limit = false;
   datetime timeCurrent = TimeCurrent(); 
   int hourCurrent =  TimeHour(timeCurrent);
   int minuteCurrent = TimeMinute(timeCurrent);
   
   if(limit_minute_server == 0){
      if(last_limit_hour < limit_hour_server && hourCurrent >= limit_hour_server){
         limit = true;
      }
   }
   else if(limit_minute_server > 0){
      if(limit_hour_server == hourCurrent &&  last_limit_minute < limit_minute_server && minuteCurrent >= limit_minute_server){
         limit = true;
      }
   }
   
   last_limit_hour = hourCurrent;
   last_limit_minute = minuteCurrent;
   return limit;
}
//+------------------------------------------------------------------+ 
bool checkFridayLimitClose(){
   bool limit = false;
   timeFridayDisabled = false;
   if(DayOfWeek() == 5){
      datetime timeCurrent = TimeCurrent(); 
      int hourCurrent =  TimeHour(timeCurrent);
      int minuteCurrent = TimeMinute(timeCurrent);
      
      if(fridayLimit_minute_server == 0){
         if(hourCurrent >= fridayLimit_hour_server){
            if(last_fridayLimit_hour < fridayLimit_hour_server) limit = true;
            timeFridayDisabled = true;
         }
      }
      else if(fridayLimit_minute_server > 0){
         if(hourCurrent > fridayLimit_hour_server || (hourCurrent == fridayLimit_hour_server &&  minuteCurrent >= fridayLimit_minute_server)){
            timeFridayDisabled = true;
         }   
         if(hourCurrent == fridayLimit_hour_server && last_fridayLimit_minute < fridayLimit_minute_server && minuteCurrent >= fridayLimit_minute_server){
            limit = true;
         }
      }
      
      last_fridayLimit_hour = hourCurrent;
      last_fridayLimit_minute = minuteCurrent;
   }
   return limit;
}
//+------------------------------------------------------------------+ 
void updateTimeframeBySymbol(){
   update_TFBySymbol[iSymbol] = false;
   iTime_Symbol = iTime(symbol,timeframe,0); 
   if(period_check_symbol[iSymbol] != iTime_Symbol){
      update_TFBySymbol[iSymbol] = true;
      period_check_symbol[iSymbol] = iTime_Symbol;
   }
}
//+------------------------------------------------------------------+
void updateIndicatorsData(){

   if((useBands || useCandlePattern) && update_TFBySymbol[iSymbol]){
      atrFastData[iSymbol] = iATR(symbol, timeframe, atrFastPeriod, 0);
      atrSlowData[iSymbol] = iATR(symbol, timeframe, atrSlowPeriod, 0);
      if(atrFastData[iSymbol] == 0.0 || atrSlowData[iSymbol] == 0.0){
         if(dataWaiting[iSymbol]) msgIndicatorsSignal[iSymbol] = symbol+" Data Waiting ..." + NL;
         return;
      }
   }
   dataWaiting[iSymbol] = false;

   if(useAvgVolume && update_TFBySymbol[iSymbol]){   
      if(firstUpdate)
         avgVolumeFastData[iSymbol][1] = iCustom(symbol,timeframe,"Vertex/volumeMA", avgVolumePeriodFast, 1,  2, 2);
      else
         avgVolumeFastData[iSymbol][1] = avgVolumeFastData[iSymbol][0];
      avgVolumeFastData[iSymbol][0] = iCustom(symbol,timeframe,"Vertex/volumeMA", avgVolumePeriodFast, 1,  2, 1);
      avgVolumeSlowData[iSymbol] = iCustom(symbol,timeframe,"Vertex/volumeMA", avgVolumePeriodSlow, 0,  2, 1);
   }
   if(usePva && update_TFBySymbol[iSymbol]){
      pvaRisingBullData[iSymbol][1] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 2, 1);
      pvaRisingBearData[iSymbol][1] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 3, 1);
      pvaClimaxBullData[iSymbol][1] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 4, 1);
      pvaClimaxBearData[iSymbol][1] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 5, 1);
      if(usePvaAlternativeTF){
         pvaRisingBullData[iSymbol][3] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 2, 1);
         pvaRisingBearData[iSymbol][3] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 3, 1);
         pvaClimaxBullData[iSymbol][3] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 4, 1);
         pvaClimaxBearData[iSymbol][3] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 5, 1);
      }
   }
   if(usePva && allTicks){
      pvaRisingBullData[iSymbol][0] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 2, 0);
      pvaRisingBearData[iSymbol][0] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 3, 0);
      pvaClimaxBullData[iSymbol][0] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 4, 0);
      pvaClimaxBearData[iSymbol][0] = iCustom(symbol,timeframe,"Vertex/PVA_Volumes_ModVertex", 5, 0);
      if(usePvaAlternativeTF){
         pvaRisingBullData[iSymbol][2] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 2, 0);
         pvaRisingBearData[iSymbol][2] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 3, 0);
         pvaClimaxBullData[iSymbol][2] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 4, 0);
         pvaClimaxBearData[iSymbol][2] = iCustom(symbol,pvaAlternativeTF,"Vertex/PVA_Volumes_ModVertex", 5, 0);
      }
   }

   if(useBands && update_TFBySymbol[iSymbol]){
      if(firstUpdate){
         bandsUpperData[iSymbol][1] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_UPPER, 2);
         bandsMainData[iSymbol][1] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_MAIN, 2);
         bandsLowerData[iSymbol][1] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_LOWER, 2);
      }
      else{
         bandsUpperData[iSymbol][1] = bandsUpperData[iSymbol][0];
         bandsMainData[iSymbol][1] = bandsMainData[iSymbol][0];
         bandsLowerData[iSymbol][1] = bandsLowerData[iSymbol][0];
      }
      bandsUpperData[iSymbol][0] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_UPPER, 1);
      bandsMainData[iSymbol][0] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_MAIN, 1);
      bandsLowerData[iSymbol][0] = iBands(symbol, timeframe, bbPeriod, bbDeviation, 0, PRICE_CLOSE, MODE_LOWER, 1);
   }

   firstUpdate = false;
}
//+------------------------------------------------------------------+ 
void updateIndicatorsSignals(){   
  
   if(useBands){
      bandsWidth[iSymbol] = (bandsUpperData[iSymbol][0] - bandsLowerData[iSymbol][0]) / atrSlowData[iSymbol];
      bandsUpperExpansion[iSymbol] = (bandsUpperData[iSymbol][0] - bandsUpperData[iSymbol][1]) / atrSlowData[iSymbol];
      bandsLowerExpansion[iSymbol] = (bandsLowerData[iSymbol][1] - bandsLowerData[iSymbol][0]) / atrSlowData[iSymbol];
      bandsExpansion[iSymbol] = bandsUpperExpansion[iSymbol] + bandsLowerExpansion[iSymbol];
      bandsTrendExpansion[iSymbol] = bandsUpperExpansion[iSymbol] - bandsLowerExpansion[iSymbol];
      if(useBandsExpasionSignal || useBandsExpasioncloseAll){
         bandsExpansionBullSignal[iSymbol] = bandsExpansionBearSignal[iSymbol] = 0;
         if(bandsExpansion[iSymbol] >= bandsExpansionAbove && bandsWidth[iSymbol] <= bandsWidthBelow){
            if(bandsTrendExpansion[iSymbol] > 0 && bandsTrendExpansion[iSymbol] >= bandsTrendExpansionAbove){
               bandsExpansionBullSignal[iSymbol] = ((bandsExpansion[iSymbol] + bandsTrendExpansion[iSymbol])*10)/(bandsWidth[iSymbol]);
            }
            if(bandsTrendExpansion[iSymbol] < 0 && bandsTrendExpansion[iSymbol] <= -bandsTrendExpansionAbove){
               bandsExpansionBearSignal[iSymbol] = ((bandsExpansion[iSymbol] - bandsTrendExpansion[iSymbol])*10)/(bandsWidth[iSymbol]);
            }
         }  
      }
      if(useBandsRejectionSignal){
         bandsRejectionBullSignal[iSymbol] = bandsRejectionBearSignal[iSymbol] = 0;
      }
   }
   if(useCandlePattern && update_TFBySymbol[iSymbol]){
      double engulfFill;
      double pips_co_s2 = iClose(symbol, timeframe, 2) - iOpen(symbol, timeframe, 2);
      double pips_co_s1 = iClose(symbol, timeframe, 1) - iOpen(symbol, timeframe, 1);
      double pips_cl_s1 = iClose(symbol, timeframe, 1) - iLow(symbol, timeframe, 1);
      double pips_hc_s1 = iHigh(symbol, timeframe, 1) - iClose(symbol, timeframe, 1);
      double pips_ho_s1 = iHigh(symbol, timeframe, 1) - iOpen(symbol, timeframe, 1);
      double pips_ol_s1 = iOpen(symbol, timeframe, 1) - iLow(symbol, timeframe, 1);
      
      /********* Calculating PINBAR *********/
      double pinbarAtrRange = 0;
      double pinbarUpperShadow = 0, pinbarLowerShadow = 0, pinbarRelativeUpperShadow = 0, pinbarRelativeLowerShadow = 0, pinbarBody; 
      double pinbarBullAtrRange = 0, pinbarBearAtrRange = 0;
      pinbarValue[iSymbol] = 0;
      
      pinbarBody = pips_co_s1;
      if(pinbarBody > 0){
         pinbarUpperShadow = pips_hc_s1;
         pinbarLowerShadow = pips_ol_s1;
         pinbarBullAtrRange = (pinbarLowerShadow + pinbarBody) / atrSlowData[iSymbol];
         pinbarBearAtrRange = pinbarUpperShadow / atrSlowData[iSymbol];
      }
      else if(pips_co_s1 < 0){
         pinbarUpperShadow = pips_ho_s1;
         pinbarLowerShadow =  pips_cl_s1;
         pinbarBullAtrRange = pinbarLowerShadow / atrSlowData[iSymbol];
         pinbarBearAtrRange = (pinbarUpperShadow + MathAbs(pinbarBody)) / atrSlowData[iSymbol];
      }
      
      if( (pinbarBody == 0 || (pinbarUpperShadow/MathAbs(pinbarBody)) >= pinbarMinShadow) && (pinbarLowerShadow == 0 || (pinbarUpperShadow/pinbarLowerShadow) >= pinbarMinShadow)){ // bear pinbarMinShadow OK
         pinbarValue[iSymbol] = - pinbarBearAtrRange;
      }
      else if( (pinbarBody == 0 || (pinbarLowerShadow/MathAbs(pinbarBody)) >= pinbarMinShadow) && (pinbarUpperShadow == 0 || (pinbarLowerShadow/pinbarUpperShadow) >= pinbarMinShadow)){ // bull pinbarMinShadow OK
         pinbarValue[iSymbol] = pinbarBullAtrRange;
      }      
      
      /********* Calculating ENGULF *********/
      double candleAtr_s2 = pips_co_s2 / atrSlowData[iSymbol];
      double candleAtr_s1 = pips_co_s1 / atrSlowData[iSymbol];
      engulfFill = candleAtr_s2 != 0 ? MathAbs(candleAtr_s1) / MathAbs(candleAtr_s2) : 0;
       if(((pips_co_s1 > 0 && pips_co_s2 < 0) || (pips_co_s1 < 0 && pips_co_s2 > 0)) && engulfFill >= engulfMinFill && engulfFill <= engulfMaxFill){ 
         engulfValue[iSymbol] = candleAtr_s1 * engulfFill;
      }
      else{
         engulfValue[iSymbol] = 0.0;
      }
      //Print(StringConcatenate("EngulfPattern - pips_co_s1: ",pips_co_s1,", pips_co_s2: ",pips_co_s2,", candleAtr_s1: ",candleAtr_s1,", candleAtr_s2: ",candleAtr_s2 ));
      //Print(StringConcatenate("EngulfPattern - Atr:",atrSlowData[iSymbol],", engulfFill: ", engulfFill, ", engulfValue: ", engulfValue[iSymbol]));
      
      /********* Calculating CANDLE PATTERN *********/
      candlePatternValue[iSymbol] = engulfValue[iSymbol] + pinbarValue[iSymbol];
   
   }
   if(usePvaVolume){
      if(pvaVolumeValue[iSymbol] > 0) pvaVolumeValue[iSymbol]--;
      if(pvaVolumeValue[iSymbol] < 0) pvaVolumeValue[iSymbol]++;
      
      bool alternative = false;
      if(usePvaAlternativeTF){
         if(pvaVolumeValue[iSymbol] < pvaClimaxDuration && (pvaClimaxBullData[iSymbol][3] > 0 || (allTicks && pvaClimaxBullData[iSymbol][2] > 0))) {
            pvaVolumeValue[iSymbol] = pvaClimaxDuration; alternative = true;
         }
         else if(pvaVolumeValue[iSymbol] < pvaRisingDuration && (pvaRisingBullData[iSymbol][3] > 0 || (allTicks && pvaRisingBullData[iSymbol][2] > 0))) {
            pvaVolumeValue[iSymbol] = pvaRisingDuration;  alternative = true;
         }
         if(pvaVolumeValue[iSymbol] > -pvaClimaxDuration && (pvaClimaxBearData[iSymbol][3] > 0 || (allTicks && pvaClimaxBearData[iSymbol][2] > 0))) {
            pvaVolumeValue[iSymbol] = -pvaClimaxDuration;  alternative = true;
         }
         else if(pvaVolumeValue[iSymbol] > -pvaRisingDuration &&  (pvaRisingBearData[iSymbol][3] > 0 || (allTicks && pvaRisingBearData[iSymbol][2] > 0))) {
            pvaVolumeValue[iSymbol] = -pvaRisingDuration;  alternative = true;
         }
      }
          
      if(!alternative && (pvaClimaxBullData[iSymbol][1] > 0 || (allTicks && pvaClimaxBullData[iSymbol][0] > 0))) 
         pvaVolumeValue[iSymbol] = pvaClimaxDuration;
      else if(!alternative && (pvaRisingBullData[iSymbol][1] > 0 || (allTicks && pvaRisingBullData[iSymbol][0] > 0))) 
         pvaVolumeValue[iSymbol] = pvaRisingDuration;
      if(!alternative && (pvaClimaxBearData[iSymbol][1] > 0 || (allTicks && pvaClimaxBearData[iSymbol][0] > 0)))   
         pvaVolumeValue[iSymbol] = -pvaClimaxDuration;
      else if(!alternative && (pvaRisingBearData[iSymbol][1] > 0 || (allTicks && pvaRisingBearData[iSymbol][0] > 0)))   
         pvaVolumeValue[iSymbol] = -pvaRisingDuration; 
      
   }
   if(usePvaFilter){
      pvaShortFilter[iSymbol] = pvaLongFilter[iSymbol] = false;

      if( (usePvaClimaxFilter && pvaClimaxBullData[iSymbol][1] > 0) || (usePvaRisingFilter && pvaRisingBullData[iSymbol][1] > 0) ||
          (allTicks && (usePvaClimaxFilter && pvaClimaxBullData[iSymbol][0] > 0)) || (allTicks && (usePvaRisingFilter && pvaRisingBullData[iSymbol][0] > 0))){
         pvaShortFilter[iSymbol] = true;   
      }
      if( (usePvaClimaxFilter && pvaClimaxBearData[iSymbol][1] > 0) || (usePvaRisingFilter && pvaRisingBearData[iSymbol][1] > 0) ||
          (allTicks && (usePvaClimaxFilter && pvaClimaxBearData[iSymbol][0] > 0)) || (allTicks && (usePvaRisingFilter && pvaRisingBearData[iSymbol][0] > 0))){
         pvaLongFilter[iSymbol] = true;   
      }
      if(usePvaAlternativeTF){
         if(!pvaShortFilter[iSymbol] && ( (usePvaClimaxFilter && pvaClimaxBullData[iSymbol][3] > 0) || (usePvaRisingFilter && pvaRisingBullData[iSymbol][3] > 0) ||
             (allTicks && (usePvaClimaxFilter && pvaClimaxBullData[iSymbol][2] > 0)) || (allTicks && (usePvaRisingFilter && pvaRisingBullData[iSymbol][2] > 0)))){
            pvaShortFilter[iSymbol] = true;   
         }
         if(!pvaLongFilter[iSymbol] && ( (usePvaClimaxFilter && pvaClimaxBearData[iSymbol][3] > 0) || (usePvaRisingFilter && pvaRisingBearData[iSymbol][3] > 0) ||
             (allTicks && (usePvaClimaxFilter && pvaClimaxBearData[iSymbol][2] > 0)) || (allTicks && (usePvaRisingFilter && pvaRisingBearData[iSymbol][2] > 0)))){
            pvaLongFilter[iSymbol] = true;   
         }
      }
   }
   
   if(useAvgVolume){  
      avgVolumeValue[iSymbol] = avgVolumeFastData[iSymbol][0] / avgVolumeSlowData[iSymbol]; 
   }
}
//+------------------------------------------------------------------+ 
void updateIndicatorsMessages(){   

   msgIndicatorsSignal[iSymbol] = symbol;

   if(useBands){     
      msgIndicatorsSignal[iSymbol] += " - bbW:"+DoubleToString(bandsWidth[iSymbol],1)+" - bbEx:"+DoubleToString(bandsExpansion[iSymbol],1)+" - bbDiff:"+DoubleToString(bandsTrendExpansion[iSymbol],1); 
      msgIndicatorsSignal[iSymbol] += " - bbUpEx:"+DoubleToString(bandsUpperExpansion[iSymbol],1)+" - bbLoEx:"+DoubleToString(bandsLowerExpansion[iSymbol],1);
   }
   if(useAvgVolume){
      msgIndicatorsSignal[iSymbol] += ", Vlm:"+DoubleToString(avgVolumeValue[iSymbol],1); 
   }
   if(usePvaVolume){
      msgIndicatorsSignal[iSymbol] += ", Pva:"+DoubleToString(pvaVolumeValue[iSymbol],0); 
   }
   if(useCandlePattern){
      msgIndicatorsSignal[iSymbol] += ", Engulf:"+DoubleToString(engulfValue[iSymbol],2); 
      msgIndicatorsSignal[iSymbol] += ", Pinbar:"+DoubleToString(pinbarValue[iSymbol],2); 
   }
   msgIndicatorsSignal[iSymbol] += NL; 
}
//+------------------------------------------------------------------+ 
void updateZupMessages(int iSym){   
   msgZupSignal[iSym] = ""; 
   for(int _iSetup=0; _iSetup<setup_count; _iSetup++){
      if(setupInUse[_iSetup]){
         string avgVB_msg = "", fiboBalance_msg = "", setupBalance_msg = "";
         if(useAvgVolumeBalance){ avgVB_msg = StringConcatenate("AvgVBalance(",(setupBalanceAvgVol[_iSetup] ? "E" : "D"),",S:",setupBalanceAvgVolShift,"),"); }
         if(useFiboBalanceByMargin){ fiboBalance_msg = StringConcatenate("FiboBalance(S:",fiboBalanceByMargin_shift[iSym],"),"); }
         if(useSetupBalanceByMargin){ setupBalance_msg = StringConcatenate("SetupBalance(S:",setupBalanceByMargin_shift[iSym],"/Buy:",(setupBalanceByBuyMargin[iSym][_iSetup] ? "E" : "D"),
         "/Sell:",(setupBalanceBySellMargin[iSym][_iSetup] ? "E" : "D"),"),"); }
         
         msgZupSignal[iSym] += StringConcatenate(symbol, "/Setup",_iSetup,"(",setupValue[_iSetup][0],",",setupValue[_iSetup][1],",",setupValue[_iSetup][2],") ");
         msgZupSignal[iSym] += avgVB_msg + fiboBalance_msg + setupBalance_msg;
         if(zzCtrl[iSym][_iSetup] != NULL){
            if(use_zigzag_size){     
               msgZupSignal[iSym] += "ZzSize: ";
               if(zz_CD_size_MIN > 0) msgZupSignal[iSym] += StringConcatenate("CdMin(",zz_CD_size_MIN,",",zzCtrl[iSym][_iSetup].lineCD.size,") ");
               if(zz_CD_size_MAX > 0) msgZupSignal[iSym] += StringConcatenate("CdMax(",zz_CD_size_MAX,",",zzCtrl[iSym][_iSetup].lineCD.size,") ");
               if(zz_BC_size_MIN > 0) msgZupSignal[iSym] += StringConcatenate("BcMin(",zz_BC_size_MIN,",",zzCtrl[iSym][_iSetup].lineBC.size,") ");
               if(zz_BC_size_MAX > 0) msgZupSignal[iSym] += StringConcatenate("BcMax(",zz_BC_size_MAX,",",zzCtrl[iSym][_iSetup].lineBC.size,") ");
               if(zz_AB_size_MIN > 0) msgZupSignal[iSym] += StringConcatenate("AbMin(",zz_AB_size_MIN,",",zzCtrl[iSym][_iSetup].lineAB.size,") ");
               if(zz_AB_size_MAX > 0) msgZupSignal[iSym] += StringConcatenate("AbMax(",zz_AB_size_MAX,",",zzCtrl[iSym][_iSetup].lineAB.size,") ");
               if(zz_XA_size_MIN > 0) msgZupSignal[iSym] += StringConcatenate("XaMin(",zz_XA_size_MIN,",",zzCtrl[iSym][_iSetup].lineXA.size,") ");
               if(zz_XA_size_MAX > 0) msgZupSignal[iSym] += StringConcatenate("XaMax(",zz_XA_size_MAX,",",zzCtrl[iSym][_iSetup].lineXA.size,") ");
            }
            if(use_zigzag_angle){     
               msgZupSignal[iSym] += ", ZzAngle: ";
               if(zz_CD_angle_MIN > 0) msgZupSignal[iSym] += StringConcatenate("CdMin(",zz_CD_angle_MIN,",",zzCtrl[iSym][_iSetup].lineCD.angle,") ");
               if(zz_CD_angle_MAX > 0) msgZupSignal[iSym] += StringConcatenate("CdMax(",zz_CD_angle_MAX,",",zzCtrl[iSym][_iSetup].lineCD.angle,") ");
               if(zz_BC_angle_MIN > 0) msgZupSignal[iSym] += StringConcatenate("BcMin(",zz_BC_angle_MIN,",",zzCtrl[iSym][_iSetup].lineBC.angle,") ");
               if(zz_BC_angle_MAX > 0) msgZupSignal[iSym] += StringConcatenate("BcMax(",zz_BC_angle_MAX,",",zzCtrl[iSym][_iSetup].lineBC.angle,") ");
               if(zz_AB_angle_MIN > 0) msgZupSignal[iSym] += StringConcatenate("AbMin(",zz_AB_angle_MIN,",",zzCtrl[iSym][_iSetup].lineAB.angle,") ");
               if(zz_AB_angle_MAX > 0) msgZupSignal[iSym] += StringConcatenate("AbMax(",zz_AB_angle_MAX,",",zzCtrl[iSym][_iSetup].lineAB.angle,") ");
               if(zz_XA_angle_MIN > 0) msgZupSignal[iSym] += StringConcatenate("XaMin(",zz_XA_angle_MIN,",",zzCtrl[iSym][_iSetup].lineXA.angle,") ");
               if(zz_XA_angle_MAX > 0) msgZupSignal[iSym] += StringConcatenate("XaMax(",zz_XA_angle_MAX,",",zzCtrl[iSym][_iSetup].lineXA.angle,") ");
            }
            if(use_fiboMinMax){     
               msgZupSignal[iSym] += ", FiboMM: ";
               if(fibo_BD_MIN > 0) msgZupSignal[iSym] += StringConcatenate("BdMin(",fibo_BD_MIN,",",zzCtrl[iSym][_iSetup].fiboBD,") ");
               if(fibo_BD_MAX > 0) msgZupSignal[iSym] += StringConcatenate("BdMax(",fibo_BD_MAX,",",zzCtrl[iSym][_iSetup].fiboBD,") ");
               if(fibo_AC_MIN > 0) msgZupSignal[iSym] += StringConcatenate("AcMin(",fibo_AC_MIN,",",zzCtrl[iSym][_iSetup].fiboAC,") ");
               if(fibo_AC_MAX > 0) msgZupSignal[iSym] += StringConcatenate("AcMax(",fibo_AC_MAX,",",zzCtrl[iSym][_iSetup].fiboAC,") ");
               if(fibo_XB_MIN > 0) msgZupSignal[iSym] += StringConcatenate("XbMin(",fibo_XB_MIN,",",zzCtrl[iSym][_iSetup].fiboXB,") ");
               if(fibo_XB_MAX > 0) msgZupSignal[iSym] += StringConcatenate("XbMax(",fibo_XB_MAX,",",zzCtrl[iSym][_iSetup].fiboXD,") ");
               if(fibo_XD_MIN > 0) msgZupSignal[iSym] += StringConcatenate("XdMin(",fibo_XD_MIN,",",zzCtrl[iSym][_iSetup].fiboXD,") ");
               if(fibo_XD_MAX > 0) msgZupSignal[iSym] += StringConcatenate("XdMax(",fibo_XD_MAX,",",zzCtrl[iSym][_iSetup].fiboXD,") ");
            }
            if(use_fiboPatterns){
               double fiboBD = 0;
               if(update_currentFiboBD) fiboBD = zzCtrl[iSym][_iSetup].fiboCurrentBD;
               else fiboBD = zzCtrl[iSym][_iSetup].fiboBD;
               msgZupSignal[iSym] += ", FiboPat: ";
               if(fibo_BD_pattern_size > 0) msgZupSignal[iSym] += StringConcatenate("BD(",fibo_BD_patterns,")(",fiboBD,") ");
               if(fibo_AC_pattern_size > 0) msgZupSignal[iSym] += StringConcatenate("AC(",fibo_AC_patterns,")(",zzCtrl[iSym][_iSetup].fiboAC,") ");
               if(fibo_XB_pattern_size > 0) msgZupSignal[iSym] += StringConcatenate("XB(",fibo_XB_patterns,")(",zzCtrl[iSym][_iSetup].fiboXB,") ");
               if(fibo_XD_pattern_size > 0) msgZupSignal[iSym] += StringConcatenate("XD(",fibo_XD_patterns,")(",zzCtrl[iSym][_iSetup].fiboXD,") ");
            }
         }   
         msgZupSignal[iSym] += NL;
      }
   }
}
//+------------------------------------------------------------------+ 
void updateIndicatorsTradeSignal(){

   sellSignalByTimeframe[iSymbol] = buySignalByTimeframe[iSymbol] = filterSignalByTimeframe[iSymbol] = false;
   
   if((!useAvgVolumeFilter || avgVolumeRequiredAbove == 0 || avgVolumeValue[iSymbol] >= avgVolumeRequiredAbove) &&
      (!useAvgVolumeFilter || avgVolumeRequiredBelow == 0 || avgVolumeValue[iSymbol] <= avgVolumeRequiredBelow) 
      ){
      filterSignalByTimeframe[iSymbol] = true;
   }

   if(((!useCandlePattern || engulfAtrRequired == 0 || engulfValue[iSymbol] <= -engulfAtrRequired) ||
      (!useCandlePattern || pinbarAtrRequired == 0 || pinbarValue[iSymbol] <= -pinbarAtrRequired)) &&
      (!useCandlePattern || candlePatternRequired == 0 || candlePatternValue[iSymbol] <= -candlePatternRequired) &&
      (!usePvaVolume || pvaVolumeRequired == 0 || pvaVolumeValue[iSymbol] <= -pvaVolumeRequired) &&
      (!(usePvaClimaxFilter || usePvaRisingFilter) || !pvaShortFilter[iSymbol] )
      ){
         sellSignalByTimeframe[iSymbol] = true;
      }

   if(((!useCandlePattern || engulfAtrRequired == 0 || engulfValue[iSymbol] >= engulfAtrRequired) ||
      (!useCandlePattern || pinbarAtrRequired == 0 || pinbarValue[iSymbol] >= pinbarAtrRequired)) &&
      (!useCandlePattern || candlePatternRequired == 0 || candlePatternValue[iSymbol] >= candlePatternRequired) &&
      (!usePvaVolume || pvaVolumeRequired == 0 || pvaVolumeValue[iSymbol] >= pvaVolumeRequired) &&
      (!(usePvaClimaxFilter || usePvaRisingFilter) || !pvaLongFilter[iSymbol] )
      ) {  
      buySignalByTimeframe[iSymbol] = true;
   }  
}
//+------------------------------------------------------------------+ 
void updateMaFilterSignals(){
   for(iSetup = 0; iSetup < setup_count; iSetup++){
      if(setupInUse[iSetup]){ 
         double _bid = BID;
         double _ask = ASK;
         if(!allTicks) { _bid = iHigh(symbol, timeframe, 1); _ask = iLow(symbol, timeframe, 1); }
         if(update_TFBySymbol[iSymbol]){
            maFilterLongStop[iSymbol][iSetup] = maFilterShortStop[iSymbol][iSetup] = false;
            if(maFilter_atrStop > 0 && BID > maFilterStopUp[iSymbol][iSetup])
               maFilterLongStop[iSymbol][iSetup] = true;
            if(maFilter_atrStop > 0 && ASK < maFilterStopDn[iSymbol][iSetup])
               maFilterShortStop[iSymbol][iSetup] = true;
         }
         maFilterLongClose[iSymbol][iSetup] = maFilterShortClose[iSymbol][iSetup] = false;
         if(allTicks){
            if(maFilter_atrClose > 0 && BID > maFilterCloseUp[iSymbol][iSetup])
               maFilterLongClose[iSymbol][iSetup] = true;
            if(maFilter_atrClose > 0 && ASK < maFilterCloseDn[iSymbol][iSetup])
               maFilterShortClose[iSymbol][iSetup] = true;
         }
         else{
            if(maFilter_atrClose > 0 && BID < maFilterCloseUp[iSymbol][iSetup] && iHigh(symbol, timeframe, 1) >= maFilterCloseUp[iSymbol][iSetup])
               maFilterLongClose[iSymbol][iSetup] = true;
            if(maFilter_atrClose > 0 && ASK > maFilterCloseDn[iSymbol][iSetup] && iLow(symbol, timeframe, 1) <= maFilterCloseDn[iSymbol][iSetup])
               maFilterShortClose[iSymbol][iSetup] = true;
         }
         maFilterLongOpen[iSymbol][iSetup] = maFilterShortOpen[iSymbol][iSetup] = false;
         if(allTicks){
            if(maFilter_atrOpen > 0 && BID > maFilterOpenUp[iSymbol][iSetup])
               maFilterShortOpen[iSymbol][iSetup] = true;
            if(maFilter_atrOpen > 0 && ASK < maFilterOpenDn[iSymbol][iSetup])
               maFilterLongOpen[iSymbol][iSetup] = true;
         }
         else{
            if(maFilter_atrOpen > 0 && BID < maFilterOpenUp[iSymbol][iSetup] && iHigh(symbol, timeframe, 1) >= maFilterOpenUp[iSymbol][iSetup])
               maFilterShortOpen[iSymbol][iSetup] = true;
            if(maFilter_atrOpen > 0 && ASK > maFilterOpenDn[iSymbol][iSetup] && iLow(symbol, timeframe, 1) <= maFilterOpenDn[iSymbol][iSetup])
               maFilterLongOpen[iSymbol][iSetup] = true;
         }
      }
   }
}
//+------------------------------------------------------------------+
void updateBarForceSignals(){
   barForceLongStop[iSymbol] = barForceLongClose[iSymbol] = false;
   barForceShortStop[iSymbol] = barForceShortClose[iSymbol] = false;
    
   if(useDailyBarForce){
      dailyForceTrend[iSymbol] = 0;
      if(BID > dailyForceLimits[iSymbol][0]) dailyForceTrend[iSymbol] = 6;
      else if(BID <= dailyForceLimits[iSymbol][11]) dailyForceTrend[iSymbol] = -6;
      else{
         int trendValue = 5;
         for(int count=0; count<11; count++){
            if(BID <= dailyForceLimits[iSymbol][count] && BID > dailyForceLimits[iSymbol][count+1]){
               dailyForceTrend[iSymbol] = trendValue;
               break;
            }
            trendValue--;
         }
      }
      if(dailyForceStop > 0 && dailyForceTrend[iSymbol] >= dailyForceStop) barForceShortStop[iSymbol] = true;
      else if(dailyForceStop > 0 && dailyForceTrend[iSymbol] <= -dailyForceStop) barForceLongStop[iSymbol] = true;
      if(dailyForceClose > 0 && dailyForceTrend[iSymbol] >= dailyForceClose) barForceShortClose[iSymbol] = true;
      else if(dailyForceClose > 0 && dailyForceTrend[iSymbol] <= -dailyForceClose) barForceLongClose[iSymbol] = true;
      if(dailyForceMax > 0 && dailyForceTrend[iSymbol] >= dailyForceMax) barForceLongStop[iSymbol] = true;
      else if(dailyForceMax > 0 && dailyForceTrend[iSymbol] <= -dailyForceMax) barForceShortStop[iSymbol] = true;
   }
   if(useWeeklyBarForce){
      weeklyForceTrend[iSymbol] = 0;
      if(BID > weeklyForceLimits[iSymbol][0]) weeklyForceTrend[iSymbol] = 6;
      else if(BID <= weeklyForceLimits[iSymbol][11]) weeklyForceTrend[iSymbol] = -6;
      else{
         int trendValue = 5;
         for(int count=0; count<11; count++){
            if(BID <= weeklyForceLimits[iSymbol][count] && BID > weeklyForceLimits[iSymbol][count+1]){
               weeklyForceTrend[iSymbol] = trendValue;
               break;
            }
            trendValue--;
         }
      }
      if(weeklyForceStop > 0 && weeklyForceTrend[iSymbol] >= weeklyForceStop) barForceShortStop[iSymbol] = true;
      else if(weeklyForceStop > 0 && weeklyForceTrend[iSymbol] <= -weeklyForceStop) barForceLongStop[iSymbol] = true;
      if(weeklyForceClose > 0 && weeklyForceTrend[iSymbol] >= weeklyForceClose) barForceShortClose[iSymbol] = true;
      else if(weeklyForceClose > 0 && weeklyForceTrend[iSymbol] <= -weeklyForceClose) barForceLongClose[iSymbol] = true;
      if(weeklyForceMax > 0 && weeklyForceTrend[iSymbol] >= weeklyForceMax) barForceLongStop[iSymbol] = true;
      else if(weeklyForceMax > 0 && weeklyForceTrend[iSymbol] <= -weeklyForceMax) barForceShortStop[iSymbol] = true;
   }
   if(useMonthlyBarForce){
      monthlyForceTrend[iSymbol] = 0;
      if(BID > monthlyForceLimits[iSymbol][0]) monthlyForceTrend[iSymbol] = 6;
      else if(BID <= monthlyForceLimits[iSymbol][11]) monthlyForceTrend[iSymbol] = -6;
      else{
         int trendValue = 5;
         for(int count=0; count<11; count++){
            if(BID <= monthlyForceLimits[iSymbol][count] && BID > monthlyForceLimits[iSymbol][count+1]){
               monthlyForceTrend[iSymbol] = trendValue;
               break;
            }
            trendValue--;
         }
      }
      if(monthlyForceStop > 0 && monthlyForceTrend[iSymbol] >= monthlyForceStop) barForceShortStop[iSymbol] = true;
      else if(monthlyForceStop > 0 && monthlyForceTrend[iSymbol] <= -monthlyForceStop) barForceLongStop[iSymbol] = true;
      if(monthlyForceClose > 0 && monthlyForceTrend[iSymbol] >= monthlyForceClose) barForceShortClose[iSymbol] = true;
      else if(monthlyForceClose > 0 && monthlyForceTrend[iSymbol] <= -monthlyForceClose) barForceLongClose[iSymbol] = true;
      if(monthlyForceMax > 0 && monthlyForceTrend[iSymbol] >= monthlyForceMax) barForceLongStop[iSymbol] = true;
      else if(monthlyForceMax > 0 && monthlyForceTrend[iSymbol] <= -monthlyForceMax) barForceShortStop[iSymbol] = true;
   }
   
      totalBarForceTrend[iSymbol] = 0;
      if(useDailyBarForce) totalBarForceTrend[iSymbol] += dailyForceTrend[iSymbol];
      if(useWeeklyBarForce) totalBarForceTrend[iSymbol] += weeklyForceTrend[iSymbol];
      if(useMonthlyBarForce) totalBarForceTrend[iSymbol] += monthlyForceTrend[iSymbol];
      
      if(totalForceStop > 0 && totalBarForceTrend[iSymbol] >= totalForceStop) barForceShortStop[iSymbol] = true;
      else if(totalForceStop > 0 && totalBarForceTrend[iSymbol] <= -totalForceStop) barForceLongStop[iSymbol] = true;
      if(totalForceClose > 0 && totalBarForceTrend[iSymbol] >= totalForceClose) barForceShortClose[iSymbol] = true;
      else if(totalForceClose > 0 && totalBarForceTrend[iSymbol] <= -totalForceClose) barForceLongClose[iSymbol] = true;
      if(totalForceMax > 0 && totalBarForceTrend[iSymbol] >= totalForceMax) barForceLongStop[iSymbol] = true;
      else if(totalForceMax > 0 && totalBarForceTrend[iSymbol] <= -totalForceMax) barForceShortStop[iSymbol] = true;
      
      if(update_TFBySymbol[iSymbol]){
         if(barForceLongStop[iSymbol]){
            barForceLongCount[iSymbol]++;
         }
         else{
            barForceLongCount[iSymbol] = 0;
         }
         if(barForceShortClose[iSymbol]){
            barForceShortCount[iSymbol]++;
         }
         else{
            barForceShortCount[iSymbol] = 0;
         }
      }
}
//+------------------------------------------------------------------+ 
void updateZigZagSizeTradeSignals(){
   sellSignalByZzSizeSetup[iSymbol][iSetup] = buySignalByZzSizeSetup[iSymbol][iSetup] = false;
   if( (zz_CD_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_CD_size_MAX) && 
       (zz_CD_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_CD_size_MIN) && 
       (zz_BC_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_BC_size_MAX) && 
       (zz_BC_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_BC_size_MIN) &&
       (zz_AB_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_AB_size_MAX) && 
       (zz_AB_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_AB_size_MIN) &&
       (zz_XA_size_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.size <= zz_XA_size_MAX) && 
       (zz_XA_size_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.size >= zz_XA_size_MIN)
      ){
         if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
            sellSignalByZzSizeSetup[iSymbol][iSetup] = true;
         else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
            buySignalByZzSizeSetup[iSymbol][iSetup] = true;
   }
}
//+------------------------------------------------------------------+ 
void updateZigZagSizeAngleSignals(){
   sellSignalByZzAngleSetup[iSymbol][iSetup] = buySignalByZzAngleSetup[iSymbol][iSetup] = false;
   if( (zz_CD_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_CD_angle_MAX) && 
       (zz_CD_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_CD_angle_MIN) && 
       (zz_BC_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_BC_angle_MAX) && 
       (zz_BC_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_BC_angle_MIN) &&
       (zz_AB_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_AB_angle_MAX) && 
       (zz_AB_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_AB_angle_MIN) &&
       (zz_XA_angle_MAX == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle <= zz_XA_angle_MAX) && 
       (zz_XA_angle_MIN == 0 || zzCtrl[iSymbol][iSetup].lineCD.angle >= zz_XA_angle_MIN)
      ){
         if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
            sellSignalByZzAngleSetup[iSymbol][iSetup] = true;
         else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
            buySignalByZzAngleSetup[iSymbol][iSetup] = true;
   }
}
//+------------------------------------------------------------------+ 
void updateFiboMinMaxTradeSignals(){
   sellSignalByFiboMinMaxSetup[iSymbol][iSetup] = buySignalByFiboMinMaxSetup[iSymbol][iSetup] = false;
   if( (fibo_BD_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboBD <= fibo_BD_MAX) && 
       (fibo_BD_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboBD >= fibo_BD_MIN) && 
       (fibo_AC_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboAC <= fibo_AC_MAX) && 
       (fibo_AC_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboAC >= fibo_AC_MIN) &&
       (fibo_XB_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboXB <= fibo_XB_MAX) && 
       (fibo_XB_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboXB >= fibo_XB_MIN) &&
       (fibo_XD_MAX == 0 || zzCtrl[iSymbol][iSetup].fiboXD <= fibo_XD_MAX) && 
       (fibo_XD_MIN == 0 || zzCtrl[iSymbol][iSetup].fiboXD >= fibo_XD_MIN)
      ){
         if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH)
            sellSignalByFiboMinMaxSetup[iSymbol][iSetup] = true;
         else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW)
            buySignalByFiboMinMaxSetup[iSymbol][iSetup] = true;
   }   
}
//+------------------------------------------------------------------+ 
void updateFiboPatternsTradeSignals(){

   sellSignalByFiboPatternSetup[iSymbol][iSetup] = buySignalByFiboPatternSetup[iSymbol][iSetup] = false; 
   bool  fibo_matched = true, trendFiboMatched = true;
   double fiboValue = 0;
   ZZ_FIBO_PATTERN fibo_pattern = BD_PATTERN;
   
   if(fibo_pattern_main == BD_PATTERN){
      fiboValue = zzCtrl[iSymbol][iSetup].fiboBD;
      if(update_currentFiboBD || !allTicks) fiboValue = zzCtrl[iSymbol][iSetup].fiboCurrentBD;
      else fiboValue = zzCtrl[iSymbol][iSetup].fiboBD;
   }
   else if(fibo_pattern_main == AC_PATTERN){
      fiboValue = zzCtrl[iSymbol][iSetup].fiboAC;
      fibo_pattern = AC_PATTERN;
   }
   else if(fibo_pattern_main == XB_PATTERN){
      fiboValue = zzCtrl[iSymbol][iSetup].fiboXB;
      fibo_pattern = XB_PATTERN;
   }
   else if(fibo_pattern_main == XD_PATTERN){
      fiboValue = zzCtrl[iSymbol][iSetup].fiboXD;
      fibo_pattern = XD_PATTERN;
   }
   else if(fibo_pattern_main == AD_PATTERN){
      fiboValue = zzCtrl[iSymbol][iSetup].fiboAD;
      fibo_pattern = AD_PATTERN;
   }
   
   if(useCurrencyTrends && symbolTrend[iSymbol] != 0){
      if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW){
         if(symbolTrend[iSymbol] <= -4) trendFiboMatched = matchFiboPattern(fibo_strong4_values, fibo_strong4_delta_values, fibo_strong_size[3], fiboValue, (fibo_pattern_main == fibo_pattern)); 
         if(symbolTrend[iSymbol] == -3) trendFiboMatched = matchFiboPattern(fibo_strong3_values, fibo_strong3_delta_values, fibo_strong_size[2], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == -2) trendFiboMatched = matchFiboPattern(fibo_strong2_values, fibo_strong2_delta_values, fibo_strong_size[1], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == -1) trendFiboMatched = matchFiboPattern(fibo_strong1_values, fibo_strong1_delta_values, fibo_strong_size[0], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == 1) trendFiboMatched = matchFiboPattern(fibo_weak1_values, fibo_weak1_delta_values, fibo_weak_size[0], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == 2) trendFiboMatched = matchFiboPattern(fibo_weak2_values, fibo_weak2_delta_values, fibo_weak_size[1], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == 3) trendFiboMatched = matchFiboPattern(fibo_weak3_values, fibo_weak3_delta_values, fibo_weak_size[2], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] >= 4) trendFiboMatched = matchFiboPattern(fibo_weak4_values, fibo_weak4_delta_values, fibo_weak_size[3], fiboValue, (fibo_pattern_main == fibo_pattern));
      }
      else{
         if(symbolTrend[iSymbol] >= 4) trendFiboMatched = matchFiboPattern(fibo_strong4_values, fibo_strong4_delta_values, fibo_strong_size[3], fiboValue, (fibo_pattern_main == fibo_pattern)); 
         if(symbolTrend[iSymbol] == 3) trendFiboMatched = matchFiboPattern(fibo_strong3_values, fibo_strong3_delta_values, fibo_strong_size[2], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == 2) trendFiboMatched = matchFiboPattern(fibo_strong2_values, fibo_strong2_delta_values, fibo_strong_size[1], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == 1) trendFiboMatched = matchFiboPattern(fibo_strong1_values, fibo_strong1_delta_values, fibo_strong_size[0], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == -1) trendFiboMatched = matchFiboPattern(fibo_weak1_values, fibo_weak1_delta_values, fibo_weak_size[0], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == -2) trendFiboMatched = matchFiboPattern(fibo_weak2_values, fibo_weak2_delta_values, fibo_weak_size[1], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] == -3) trendFiboMatched = matchFiboPattern(fibo_weak3_values, fibo_weak3_delta_values, fibo_weak_size[2], fiboValue, (fibo_pattern_main == fibo_pattern));
         if(symbolTrend[iSymbol] <= -4) trendFiboMatched = matchFiboPattern(fibo_weak4_values, fibo_weak4_delta_values, fibo_weak_size[3], fiboValue, (fibo_pattern_main == fibo_pattern));
      }     
   }
   if(fibo_matched && trendFiboMatched && fibo_BD_pattern_size > 0 && (!useCurrencyTrends || symbolTrend[iSymbol] == 0)){
      fibo_matched = matchFiboPattern(fibo_BD_pattern_values, fibo_BD_delta_values, fibo_BD_pattern_size, zzCtrl[iSymbol][iSetup].fiboBD, (fibo_pattern_main == BD_PATTERN));
   }  
   if(fibo_matched && trendFiboMatched && fibo_XD_pattern_size > 0 && (!useCurrencyTrends || symbolTrend[iSymbol] == 0)){
      fibo_matched = matchFiboPattern(fibo_XD_pattern_values, fibo_XD_delta_values, fibo_XD_pattern_size, zzCtrl[iSymbol][iSetup].fiboXD, (fibo_pattern_main == XD_PATTERN));
   }
   if(fibo_matched && trendFiboMatched && fibo_XB_pattern_size > 0 && (!useCurrencyTrends || symbolTrend[iSymbol] == 0)){
      fibo_matched = matchFiboPattern(fibo_XB_pattern_values, fibo_XB_delta_values, fibo_XB_pattern_size, zzCtrl[iSymbol][iSetup].fiboXB, (fibo_pattern_main == XB_PATTERN));
   }
   if(fibo_matched && trendFiboMatched && fibo_AC_pattern_size > 0 && (!useCurrencyTrends || symbolTrend[iSymbol] == 0)){
      fibo_matched = matchFiboPattern(fibo_AC_pattern_values, fibo_AC_delta_values, fibo_AC_pattern_size, zzCtrl[iSymbol][iSetup].fiboAC, (fibo_pattern_main == AC_PATTERN));
   }
   if(fibo_matched && trendFiboMatched && fibo_AD_pattern_size > 0 && (!useCurrencyTrends || symbolTrend[iSymbol] == 0)){
      fibo_matched = matchFiboPattern(fibo_AD_pattern_values, fibo_AD_delta_values, fibo_AD_pattern_size, zzCtrl[iSymbol][iSetup].fiboAD, (fibo_pattern_main == AD_PATTERN));
   }

   if(fibo_matched && trendFiboMatched){
      if(fibo_BD_minor_size > 0){
         bool foundMinor = false;
         for(int iSetupMinor = iSetup-1; iSetupMinor >= 0; iSetupMinor--){
            if(setupInUse[iSetupMinor] && zzCtrl[iSymbol][iSetup].lineCD.pointA.price != zzCtrl[iSymbol][iSetupMinor].lineCD.pointA.price ){
               if(matchFiboPattern(fibo_BD_minor_values, fibo_BD_minor_delta_values, fibo_BD_minor_size, zzCtrl[iSymbol][iSetupMinor].fiboBD, false)){
                  foundMinor = true; break;
               }
            }
         }
         if(!foundMinor) return;
      }
      
      if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH && 
         !(fibo_lastTradeType[iSymbol][iSetup] == OP_SELL && fibo_lastTradeFibo[iSymbol][iSetup] >= fibo_lastMatchFibo[iSymbol][iSetup])){
         sellSignalByFiboPatternSetup[iSymbol][iSetup] = true;
         //Print("sellSignalByFiboPatternSetup[iSymbol][_iSetup] = true;");
      }
      else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW && 
         !(fibo_lastTradeType[iSymbol][iSetup] == OP_BUY && fibo_lastTradeFibo[iSymbol][iSetup] >= fibo_lastMatchFibo[iSymbol][iSetup])){
         buySignalByFiboPatternSetup[iSymbol][iSetup] = true;
         //Print("buySignalByFiboPatternSetup[iSymbol][_iSetup] = true;");
      }
   }  
}
//+------------------------------------------------------------------+ 
void updatePitchforkTradeSignals(){

   sellSignalByPitchforkSetup[iSymbol][iSetup] = buySignalByPitchforkSetup[iSymbol][iSetup] = false;
   bool buyTriggerBreakSignal = !use_apSignal_triggerBreak; 
   bool sellTriggerBreakSignal = !use_apSignal_triggerBreak; 
   bool buyTriggerBorderSignal = !use_apSignal_triggerBorder; 
   bool sellTriggerBorderSignal = !use_apSignal_triggerBorder; 
   
   bool priceRangeSignal = (pitchfork_priceRange == 0 || pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.percentPriceToMedian <= pitchfork_priceRange);
   bool timeRangeSignal = (pitchfork_timeRange == 0 || pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.percentTimeToMedian <= pitchfork_timeRange);
   bool angleDirectionSignal = !use_triggerAngleDirection;
   bool angleExpansionSignal = !use_triggerAngleExpansion;
   
   if(use_triggerAngleDirection){
      int directionValue = (pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.angle + pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.angle)/2;
      bool directionMax = (MathAbs(directionValue) <= triggerAngleDirectionMAX);
      bool directionMin = (MathAbs(directionValue) >= triggerAngleDirectionMIN);
      angleDirectionSignal = (directionMax && directionMin);
   }
   if(use_triggerAngleExpansion){
      int expansionValue = 0;
      if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW){
         expansionValue = (pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.angle - pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.angle);
      }
      else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH){
         expansionValue = (pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.angle - pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.angle);
      }   
      bool expansionMax = (MathAbs(expansionValue) <= triggerAngleExpansionMAX);
      bool expansionMin = (MathAbs(expansionValue) >= triggerAngleExpansionMIN);
      angleExpansionSignal = (expansionMax && expansionMin);
   }
   
   if(use_apSignal_triggerBorder){
      if(!pitchfork_uniqueSignalByPeak || pitchforkLastPeakSignal[iSymbol][iSetup] != zzCtrl[iSymbol][iSetup].lineCD.pointA.price){
         if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW){
            double price = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].settings.priceAsk : iLow(symbol, timeframe, 1);
            double currentTriggerXAB = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceLastBar;
            if(price < currentTriggerXAB){ //(atrToMedianBySetup[iSetup] == 0 || ( (atrToMedianBySetup[iSetup]*settings[iSymbol][iSetup].atrValue) < (pitchforkCtrl[iSymbol][iSetup].settings.priceBid - pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.lineMedian.priceCurrentBar))) ){
               buyTriggerBorderSignal = true;
            }
         }
         else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH ){
            double price = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].settings.priceBid : iHigh(symbol, timeframe, 1);
            double currentTriggerXAB = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceLastBar;
            if(price > currentTriggerXAB){  //(atrToMedianBySetup[iSetup] == 0 || ( (atrToMedianBySetup[iSetup]*settings[iSymbol][iSetup].atrValue) < (pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.lineMedian.priceCurrentBar - pitchforkCtrl[iSymbol][iSetup].settings.priceAsk))) ){
               sellTriggerBorderSignal = true;
            }

         }
      }
   }
   if(use_apSignal_triggerBreak){
      if(!pitchfork_uniqueSignalByPeak || pitchforkLastPeakSignal[iSymbol][iSetup] != zzCtrl[iSymbol][iSetup].lineCD.pointA.price){
         if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_LOW){
            double priceOpen = (allTicks) ? iOpen(symbol, timeframe, 0) : iOpen(symbol, timeframe, 1);
            double priceClose = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].settings.priceBid : iClose(symbol, timeframe, 1);
            //double currentTriggerXAB = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceLastBar;
            double currentTriggerABC = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.priceLastBar;
            //double pipsToMedian = (pitchforkCtrl[iSymbol][iSetup].settings.priceBid - pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.lineMedian.priceCurrentBar);
            //Print(StringConcatenate("pipsToMedian: ",pipsToMedian," atr:",settings[iSymbol][iSetup].atrValue, ", takeprofit_minRatioAtr:",takeprofit_minRatioAtr));
            if(priceClose > currentTriggerABC && priceOpen <= currentTriggerABC){ //(atrToMedianBySetup[iSetup] == 0 || ( (atrToMedianBySetup[iSetup]*settings[iSymbol][iSetup].atrValue) < (pitchforkCtrl[iSymbol][iSetup].settings.priceBid - pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.lineMedian.priceCurrentBar))) ){
               buyTriggerBreakSignal = true;
            }
         }
         else if(zzCtrl[iSymbol][iSetup].lineCD.line_direction == DIRECTION_HIGH ){
            double priceOpen = (allTicks) ? iOpen(symbol, timeframe, 0) : iOpen(symbol, timeframe, 1);
            double priceClose = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].settings.priceAsk : iClose(symbol, timeframe, 1);
            //double currentTriggerXAB = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineTrigger.priceLastBar;
            double currentTriggerABC = (allTicks) ? pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.priceCurrentBar : pitchforkCtrl[iSymbol][iSetup].pitchforkABC.lineTrigger.priceLastBar;
            //double pipsToMedian = (pitchforkCtrl[iSymbol][iSetup].pitchforkXAB.lineMedian.priceCurrentBar - pitchforkCtrl[iSymbol][iSetup].settings.priceAsk);
            //Print(StringConcatenate("pipsToMedian: ",pipsToMedian," atr:",settings[iSymbol][iSetup].atrValue, ", takeprofit_minRatioAtr:",takeprofit_minRatioAtr));
            if(priceClose < currentTriggerABC && priceOpen >= currentTriggerABC){// (atrToMedianBySetup[iSetup] == 0 || ( (atrToMedianBySetup[iSetup]*settings[iSymbol][iSetup].atrValue) < (pitchforkCtrl[iSymbol][iSetup].pitchforkBCD.lineMedian.priceCurrentBar - pitchforkCtrl[iSymbol][iSetup].settings.priceAsk))) ){
               sellTriggerBreakSignal = true;
            }

         }
      }
   }
   
   buySignalByPitchforkSetup[iSymbol][iSetup] = (priceRangeSignal && timeRangeSignal && angleDirectionSignal && angleExpansionSignal && buyTriggerBreakSignal && buyTriggerBorderSignal);
   sellSignalByPitchforkSetup[iSymbol][iSetup] = (priceRangeSignal && timeRangeSignal && angleDirectionSignal && angleExpansionSignal && sellTriggerBreakSignal && sellTriggerBorderSignal);
}
//+------------------------------------------------------------------+ 
void updateHarmonicTradeSignals(){

   sellSignalByHarmonicSetup[iSymbol][iSetup] = buySignalByHarmonicSetup[iSymbol][iSetup] = false; 

}
//+------------------------------------------------------------------+ 
void updateCurrencyTrendSignals(){ 
   if(update_ccfp || update_sentiment || update_marginTrend){
      ArrayInitialize(symbolTrend, 0.0);
      ArrayInitialize(trendShortStop, false); ArrayInitialize(trendLongStop, false);  
      ArrayInitialize(trendShortClose, false); ArrayInitialize(trendLongClose, false);  
      
      for(int i=0; i<symbols_count; i++){
         if(useTrendBalanceByMargin){
            symbolTrend[i] += marginTrendBySymbol[i];
         }
         if(useCCFpTrendControl || useSentimentMyFxBook || useManualCurrencyStrength){
            string _currency1, _currency2, _symbol;
            int iCur1 = 0, iCur2 = 0, ccfpSymbolTrend;
            double ccfpSymbolValue, myfxbookSymbolValue, myfxbookSymbolTrend;
            HashSentimentCurrency *_hashSentimentCurrency1, *_hashSentimentCurrency2;
            SentimentCurrencyClass *_sentimentCurrency1, *_sentimentCurrency2;
            _symbol = listCleanSymbols[i];
            _currency1 = StringSubstr(_symbol, 0,3); 
            _currency2 = StringSubstr(_symbol, 3,3); 
            if(hashCurrencies.hContainsKey(_currency1)){
               iCur1 = hashCurrencies.hGetInt(_currency1);
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate("Stop trading ",_symbol,". Currency1 (",_currency1,") not found in hashCurrencies"));
               trendShortStop[i] = trendLongStop[i] = true; 
               continue;
            }
            if(hashCurrencies.hContainsKey(_currency2)){
               iCur2 = hashCurrencies.hGetInt(_currency2);
            }
            else {
               logMessage(LOG_ERROR, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate("Stop trading ",_symbol,". Currency2 (",_currency2,") not found in hashCurrencies"));
               trendShortStop[i] = trendLongStop[i] = true; 
               continue;
            }
            if(useManualCurrencyStrength){
               symbolTrend[i] += manualTrend[iCur1] - manualTrend[iCur2];
            }
            if(useCCFpTrendControl){
               ccfpSymbolTrend = 0;
               ccfpSymbolValue = ccfpValues[iCur1] - ccfpValues[iCur2];
               for(double j=ccfpBalanceBegin; j <= ccfpBalanceEnd; j+=ccfpBalanceStep){
                  if(ccfpSymbolValue >= j) ccfpSymbolTrend ++;
                  else break;
               }
               for(double j=-ccfpBalanceBegin; j >= -ccfpBalanceEnd; j-=ccfpBalanceStep){
                  if(ccfpSymbolValue <= j) ccfpSymbolTrend --;
                  else break;
               }
               symbolTrend[i] += ccfpSymbolTrend;
               
               if(ccfpLimitStopSymbol != 0 && ccfpSymbolValue >= ccfpLimitStopSymbol){ trendShortStop[i] = true; }
               if(ccfpLimitStopSymbol != 0 && ccfpSymbolValue <= -ccfpLimitStopSymbol){ trendLongStop[i] = true; }
               if(ccfpLimitCloseSymbol != 0 && ccfpSymbolValue >= ccfpLimitCloseSymbol){ trendShortClose[i] = true; }
               if(ccfpLimitCloseSymbol != 0 && ccfpSymbolValue <= -ccfpLimitCloseSymbol){ trendLongClose[i] = true; }
               
               //logMessage(LOG_WARN, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate(
               //   "CCFpTrend(",_symbol," Updated, ccfpCurrency1:",ccfpValues[iCur1],", ccfpCurrency2:",ccfpValues[iCur2],", TrendValue: ",ccfpSymbolTrend));
            }
            if(useSentimentMyFxBook){ 
               myfxbookSymbolTrend = 0;
               datetime timeCurrent = TimeLocal();
               
               if((timeCurrent - time_lastUpdateMFB) > (maxOutdatedSentimentTime*60)){
                  trendShortStop[i] = trendLongStop[i] = true; 
                  logMessage(LOG_ERROR, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate(
                     "Stop trading ",_symbol,". MyFxBook Sentiment outdated. timeCurrent: ",timeCurrent,", updatedMFB: ",time_lastUpdateMFB,", maxOutdatedtTime: ",maxOutdatedSentimentTime));
                  continue;
               }
               _hashSentimentCurrency1 = hashSentimentCurrencies.hGet(_currency1);
               _hashSentimentCurrency2 = hashSentimentCurrencies.hGet(_currency2);
               if(_hashSentimentCurrency1 == NULL || _hashSentimentCurrency2 == NULL){
                  trendShortStop[i] = trendLongStop[i] = true; 
                  logMessage(LOG_ERROR, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate(
                     "Stop trading ",_symbol,".Not found HashValue in hashSentimentCurrencies."));
                  continue;
               }
               _sentimentCurrency1 = _hashSentimentCurrency1.getVal();
               _sentimentCurrency2 = _hashSentimentCurrency2.getVal();
               if(_sentimentCurrency1 == NULL || _sentimentCurrency2 == NULL){
                  trendShortStop[i] = trendLongStop[i] = true; 
                  logMessage(LOG_ERROR, _symbol, timeframe, "updateCurrencyTrendSignals", StringConcatenate(
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
               
               if(sentimentLimitStopSymbol != 0 && myfxbookSymbolValue >= sentimentLimitStopSymbol){ trendShortStop[i] = true; }
               if(sentimentLimitStopSymbol != 0 && myfxbookSymbolValue <= -sentimentLimitStopSymbol){ trendLongStop[i] = true; }
               if(sentimentLimitCloseSymbol != 0 && myfxbookSymbolValue >= sentimentLimitCloseSymbol){ trendShortClose[i] = true; }
               if(sentimentLimitCloseSymbol != 0 && myfxbookSymbolValue <= -sentimentLimitCloseSymbol){ trendLongClose[i] = true; }
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
void updateZigzagEqualLines(){
   int iSetup2 = iSetup-1;
   ignore_equal_zigzag[iSymbol][iSetup] = false;
   if(iSetup2 >= 0 && setupInUse[iSetup] && setupInUse[iSetup2]){
      if( (!zz_ignore_equal_line_CD || zzCtrl[iSymbol][iSetup].lineCD.pointA.price == zzCtrl[iSymbol][iSetup2].lineCD.pointA.price) &&
          (!zz_ignore_equal_line_BC || zzCtrl[iSymbol][iSetup].lineBC.pointA.price == zzCtrl[iSymbol][iSetup2].lineBC.pointA.price) &&
          (!zz_ignore_equal_line_AB || zzCtrl[iSymbol][iSetup].lineAB.pointA.price == zzCtrl[iSymbol][iSetup2].lineAB.pointA.price) &&
          (!zz_ignore_equal_line_XA || zzCtrl[iSymbol][iSetup].lineXA.pointA.price == zzCtrl[iSymbol][iSetup2].lineXA.pointA.price)
         ){
         ignore_equal_zigzag[iSymbol][iSetup] = true;
         //logMessage(LOG_WARN, symbol, 0, "updateZigzagEqualLines", StringConcatenate("Ignoring ZIGZAG Equals lines. setups: ",setupValue[_iSetup][0],"(",_iSetup,"), ", setupValue[_iSetup2][0],"(",_iSetup2,")"));
      }
   }
}
//+------------------------------------------------------------------+ 
void DrawChannel(string dir, double pr1, color clr=clrYellow){ 
   if (Bars<2) return;
   string name=_Symbol+" "+dir+TimeToStr(Time[0]);
   string name_prev=_Symbol+" "+dir+TimeToStr(Time[1]);
   
   if(ObjectFind(name) < 0){
      double pr2 = pr1;
      if(ObjectFind(name_prev) == 0) pr2 = ObjectGetDouble(0,name_prev,OBJPROP_PRICE,1);
      
      ObjectCreate(name, OBJ_TREND,0,Time[1],pr2,Time[0],pr1);
      ObjectSet(name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false); 
      ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
      //ObjectSet(name,OBJPROP_BACK,true);
      ObjectSet(name,OBJPROP_SELECTABLE,false);
   }
}
//+------------------------------------------------------------------+
void DrawWarn(string text, color col){
   if(!VisualDebug) return;
   
   string obid=_Symbol+TimeToStr(Time[0]);
   if(ObjectFind(obid)!=-1) ObjectDelete(obid);
   
   ENUM_ANCHOR_POINT anc;
   double price = 0;

   if((WindowPriceMax()+WindowPriceMin())/2 < Bid){
      //price=channel_lower1-Entry_Break*2*_Point;
      anc=ANCHOR_RIGHT;
   }else{
      //price=channel_upper1+Entry_Break*2*_Point;
      anc=ANCHOR_LEFT;
   }
   
   ObjectCreate(obid, OBJ_TEXT, 0, Time[0], price);
   ObjectSet(obid, OBJPROP_ANGLE, 90);
   ObjectSet(obid,OBJPROP_ANCHOR,anc);
   ObjectSet(obid,OBJPROP_BACK,false);
   ObjectSetText(obid,text,10,"Arial",col);
}
//+------------------------------------------------------------------+ 
int TimeFrameToInt(string _timeframeStr) 
{
   int _timeframe = -1;
   if(_timeframeStr == "M1") _timeframe = PERIOD_M1;
   else if(_timeframeStr == "M5") _timeframe = PERIOD_M5;
   else if(_timeframeStr == "M15") _timeframe = PERIOD_M15;
   else if(_timeframeStr == "M30") _timeframe = PERIOD_M30;
   else if(_timeframeStr == "H1") _timeframe = PERIOD_H1;
   else if(_timeframeStr == "H4") _timeframe = PERIOD_H4;
   else if(_timeframeStr == "D1") _timeframe = PERIOD_D1;
   else if(_timeframeStr == "W1") _timeframe = PERIOD_W1;
   else if(_timeframeStr == "MN1") _timeframe = PERIOD_MN1;
   return _timeframe;
}
//+------------------------------------------------------------------+ 
int SetupPosToInt(string _pos) 
{
   int _setupPos = -1;
   for(int i=0; i < setup_count; i++){
      if(IntegerToString(i) == _pos){
         _setupPos = i;
         break;
      }
   }
   return _setupPos;
}
//+------------------------------------------------------------------+ 
int getSymbolPosition(string _symbol){
   int _iSymbol = -1;
   for (int i = 0; i < symbols_count; i++) {
      if(listBrokerSymbols[i] == _symbol){
         _iSymbol = i;
         break;
      }
   }
   return _iSymbol;
}
//+------------------------------------------------------------------+
void InitializeFiboPattern(double &fibo_pattern_values[], double &fibo_delta_values[][], int &fibo_pattern_size, string fibo_patterns, string fibo_id ){
   string fibo_pat_arr_str[];
   fibo_pattern_size = StringSplit(fibo_patterns,StringGetCharacter(",",0),fibo_pat_arr_str);
   if(fibo_pattern_size < 0){ logMessage(LOG_ERROR,"",timeframe,"initCore",StringConcatenate("Invalid fibo_",fibo_id,"_patterns, value: ",fibo_patterns));}
   else if(fibo_pattern_size > 0){
      ArrayResize(fibo_pattern_values, fibo_pattern_size);
      ArrayInitialize(fibo_pattern_values, 0.0);
      ArrayResize(fibo_delta_values , fibo_pattern_size);
      ArrayInitialize(fibo_delta_values, 0.0);
      
      for(int i=0; i<fibo_pattern_size;i++){
         fibo_pattern_values[i] = StringToDouble(fibo_pat_arr_str[i]);
         fibo_delta_values[i][0] = fibo_pattern_values[i] * (1 - fibo_patterns_delta);
         fibo_delta_values[i][1] = fibo_pattern_values[i] * (1 + fibo_patterns_delta);
         //logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_",fibo_id,"_patterns, i: ",i,", value: ",fibo_pattern_values[i],", delta[0]: ",fibo_delta_values[i][0],", delta[1]: ", fibo_delta_values[i][1]));
      }
   }
}
//+------------------------------------------------------------------+
void InitializeFiboWeakStrong(){

   string fibo_strong1_str[], fibo_strong2_str[], fibo_strong3_str[], fibo_strong4_str[];
   string fibo_weak1_str[], fibo_weak2_str[], fibo_weak3_str[], fibo_weak4_str[];
   fibo_strong_size[0] = StringSplit(fibo_strong1_patterns,StringGetCharacter(",",0),fibo_strong1_str);
   fibo_strong_size[1] = StringSplit(fibo_strong2_patterns,StringGetCharacter(",",0),fibo_strong2_str);
   fibo_strong_size[2] = StringSplit(fibo_strong3_patterns,StringGetCharacter(",",0),fibo_strong3_str);
   fibo_strong_size[3] = StringSplit(fibo_strong4_patterns,StringGetCharacter(",",0),fibo_strong4_str);
   
   fibo_weak_size[0] = StringSplit(fibo_weak1_patterns,StringGetCharacter(",",0),fibo_weak1_str);
   fibo_weak_size[1] = StringSplit(fibo_weak2_patterns,StringGetCharacter(",",0),fibo_weak2_str);
   fibo_weak_size[2] = StringSplit(fibo_weak3_patterns,StringGetCharacter(",",0),fibo_weak3_str);
   fibo_weak_size[3] = StringSplit(fibo_weak4_patterns,StringGetCharacter(",",0),fibo_weak4_str);
   
   if(fibo_strong_size[0] > 0){
      ArrayResize(fibo_strong1_values, fibo_strong_size[0]); ArrayInitialize(fibo_strong1_values, 0.0);
      ArrayResize(fibo_strong1_delta_values , fibo_strong_size[0]); ArrayInitialize(fibo_strong1_delta_values, 0.0); 
      for(int i=0; i<fibo_strong_size[0];i++){
         fibo_strong1_values[i] = StringToDouble(fibo_strong1_str[i]);
         fibo_strong1_delta_values[i][0] = fibo_strong1_values[i] * (1 - fibo_patterns_delta);
         fibo_strong1_delta_values[i][1] = fibo_strong1_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_strong1_patterns, i: ",i,", value: ",fibo_strong1_values[i],", delta[0]: ",fibo_strong1_delta_values[i][0],", delta[1]: ", fibo_strong1_delta_values[i][1]));
      }
   }
   if(fibo_strong_size[1] > 0){
      ArrayResize(fibo_strong2_values, fibo_strong_size[1]); ArrayInitialize(fibo_strong2_values, 0.0);
      ArrayResize(fibo_strong2_delta_values , fibo_strong_size[1]); ArrayInitialize(fibo_strong2_delta_values, 0.0); 
      for(int i=0; i<fibo_strong_size[1];i++){
         fibo_strong2_values[i] = StringToDouble(fibo_strong2_str[i]);
         fibo_strong2_delta_values[i][0] = fibo_strong2_values[i] * (1 - fibo_patterns_delta);
         fibo_strong2_delta_values[i][1] = fibo_strong2_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_strong2_patterns, i: ",i,", value: ",fibo_strong2_values[i],", delta[0]: ",fibo_strong2_delta_values[i][0],", delta[1]: ", fibo_strong2_delta_values[i][1]));
      }
   }
   if(fibo_strong_size[2] > 0){
      ArrayResize(fibo_strong3_values, fibo_strong_size[2]); ArrayInitialize(fibo_strong3_values, 0.0);
      ArrayResize(fibo_strong3_delta_values , fibo_strong_size[2]); ArrayInitialize(fibo_strong3_delta_values, 0.0); 
      for(int i=0; i<fibo_strong_size[2];i++){
         fibo_strong3_values[i] = StringToDouble(fibo_strong3_str[i]);
         fibo_strong3_delta_values[i][0] = fibo_strong3_values[i] * (1 - fibo_patterns_delta);
         fibo_strong3_delta_values[i][1] = fibo_strong3_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_strong3_patterns, i: ",i,", value: ",fibo_strong3_values[i],", delta[0]: ",fibo_strong3_delta_values[i][0],", delta[1]: ", fibo_strong3_delta_values[i][1]));
      }
   }
   if(fibo_strong_size[3] > 0){
      ArrayResize(fibo_strong4_values, fibo_strong_size[3]); ArrayInitialize(fibo_strong4_values, 0.0);
      ArrayResize(fibo_strong4_delta_values , fibo_strong_size[3]); ArrayInitialize(fibo_strong4_delta_values, 0.0); 
      for(int i=0; i<fibo_strong_size[3];i++){
         fibo_strong4_values[i] = StringToDouble(fibo_strong4_str[i]);
         fibo_strong4_delta_values[i][0] = fibo_strong4_values[i] * (1 - fibo_patterns_delta);
         fibo_strong4_delta_values[i][1] = fibo_strong4_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_strong4_patterns, i: ",i,", value: ",fibo_strong4_values[i],", delta[0]: ",fibo_strong4_delta_values[i][0],", delta[1]: ", fibo_strong4_delta_values[i][1]));
      }
   }
   
   if(fibo_weak_size[0] > 0){
      ArrayResize(fibo_weak1_values, fibo_weak_size[0]); ArrayInitialize(fibo_weak1_values, 0.0);
      ArrayResize(fibo_weak1_delta_values , fibo_weak_size[0]); ArrayInitialize(fibo_weak1_delta_values, 0.0); 
      for(int i=0; i<fibo_weak_size[0];i++){
         fibo_weak1_values[i] = StringToDouble(fibo_weak1_str[i]);
         fibo_weak1_delta_values[i][0] = fibo_weak1_values[i] * (1 - fibo_patterns_delta);
         fibo_weak1_delta_values[i][1] = fibo_weak1_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_weak1_patterns, i: ",i,", value: ",fibo_weak1_values[i],", delta[0]: ",fibo_weak1_delta_values[i][0],", delta[1]: ", fibo_weak1_delta_values[i][1]));
      }
   }
   if(fibo_weak_size[1] > 0){
      ArrayResize(fibo_weak2_values, fibo_weak_size[1]); ArrayInitialize(fibo_weak2_values, 0.0);
      ArrayResize(fibo_weak2_delta_values , fibo_weak_size[1]); ArrayInitialize(fibo_weak2_delta_values, 0.0); 
      for(int i=0; i<fibo_weak_size[1];i++){
         fibo_weak2_values[i] = StringToDouble(fibo_weak2_str[i]);
         fibo_weak2_delta_values[i][0] = fibo_weak2_values[i] * (1 - fibo_patterns_delta);
         fibo_weak2_delta_values[i][1] = fibo_weak2_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_weak2_patterns, i: ",i,", value: ",fibo_weak2_values[i],", delta[0]: ",fibo_weak2_delta_values[i][0],", delta[1]: ", fibo_weak2_delta_values[i][1]));
      }
   }
   if(fibo_weak_size[2] > 0){
      ArrayResize(fibo_weak3_values, fibo_weak_size[2]); ArrayInitialize(fibo_weak3_values, 0.0);
      ArrayResize(fibo_weak3_delta_values , fibo_weak_size[2]); ArrayInitialize(fibo_weak3_delta_values, 0.0); 
      for(int i=0; i<fibo_weak_size[2];i++){
         fibo_weak3_values[i] = StringToDouble(fibo_weak3_str[i]);
         fibo_weak3_delta_values[i][0] = fibo_weak3_values[i] * (1 - fibo_patterns_delta);
         fibo_weak3_delta_values[i][1] = fibo_weak3_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_weak3_patterns, i: ",i,", value: ",fibo_weak3_values[i],", delta[0]: ",fibo_weak3_delta_values[i][0],", delta[1]: ", fibo_weak3_delta_values[i][1]));
      }
   }
   if(fibo_weak_size[3] > 0){
      ArrayResize(fibo_weak4_values, fibo_weak_size[3]); ArrayInitialize(fibo_weak4_values, 0.0);
      ArrayResize(fibo_weak4_delta_values , fibo_weak_size[3]); ArrayInitialize(fibo_weak4_delta_values, 0.0); 
      for(int i=0; i<fibo_weak_size[3];i++){
         fibo_weak4_values[i] = StringToDouble(fibo_weak4_str[i]);
         fibo_weak4_delta_values[i][0] = fibo_weak4_values[i] * (1 - fibo_patterns_delta);
         fibo_weak4_delta_values[i][1] = fibo_weak4_values[i] * (1 + fibo_patterns_delta);
         logMessage(LOG_INFO,"",timeframe,"initCore",StringConcatenate("Initializing fibo_weak4_patterns, i: ",i,", value: ",fibo_weak4_values[i],", delta[0]: ",fibo_weak4_delta_values[i][0],", delta[1]: ", fibo_weak4_delta_values[i][1]));
      }
   } 
}
//+------------------------------------------------------------------+
bool matchFiboPattern(double &fibo_pattern_values[], double &fibo_delta_values[][], int fibo_pattern_size, double fibo, bool setLastFiboMatched){
   bool match = false;
   for(int i=0; i<fibo_pattern_size; i++){
      if(fibo >= fibo_delta_values[i][0] && fibo <= fibo_delta_values[i][1]){
         match = true; 
         if(setLastFiboMatched){
            fibo_lastMatchFibo[iSymbol][iSetup] = fibo_pattern_values[i];
            fibo_lastMatchFiboPos[iSymbol][iSetup] = i;
         }
         break;
      }
   }
   return match;
}
//+------------------------------------------------------------------+
/*bool matchFiboPattern(double &fibo_pattern_values[], double &fibo_delta_values[][], int fibo_pattern_size, double fibo){
   bool match = false;
   for(int i=0; i<fibo_pattern_size; i++){
      if(fibo >= fibo_delta_values[i][0] && fibo <= fibo_delta_values[i][1]){
         match = true; break;
      }
   }
   return match;
}*/
//+------------------------------------------------------------------+
double lotSizeByRisk(int _iSymbol, int _iSetup, int _orderType){
   double _lots = (AccountEquity()*Risk)/10000;
   string _symbol = listBrokerSymbols[_iSymbol];
   double _lotstep = MarketInfo (_symbol, MODE_LOTSTEP);
   //Print(StringConcatenate("New Order -> lotSizeByRisk(Sym: ",_symbol,",setup: ",_iSetup,",OrderType: ",OrderTypeToString( _orderType),") Lots: ",_lots));
   _lots = riskBySetupMultiplier == 0 ? _lots : _lots * MathPow(riskBySetupMultiplier, _iSetup);
   if(useRelativeSpread) _lots = _lots / relativeSymbolValue[iSymbol];
   double _lotsMax = _lots * (RiskMax/Risk);
   double addLotsTrend = 0; double addLotsFibo = 0; 
   double addLotsZZSize = 0; double addLotsAPMedian = 0;
   
   if(useCurrencyTrends && riskByTrendMultiplier != 0){
      if(_orderType == OP_BUY){
         if(symbolTrend[_iSymbol] >= 0) addLotsTrend = (_lots * MathPow(riskByTrendMultiplier, symbolTrend[_iSymbol])) - _lots;
         else addLotsTrend = (_lots / MathPow(riskByTrendMultiplier, MathAbs(symbolTrend[_iSymbol]))) - _lots;
      }
      else if(_orderType == OP_SELL){
         if(symbolTrend[_iSymbol] >= 0) addLotsTrend = (_lots / MathPow(riskByTrendMultiplier, symbolTrend[_iSymbol])) - _lots;
         else addLotsTrend = (_lots * MathPow(riskByTrendMultiplier, MathAbs(symbolTrend[_iSymbol]))) - _lots;
      } 
   }
   if(use_fiboPatterns && riskByFiboMultiplier != 0){
      double _fibo = (fibo_lastMatchFibo[_iSymbol][_iSetup] >= 1) ? fibo_lastMatchFibo[_iSymbol][_iSetup] : 1;
      addLotsFibo = (_lots * MathPow(riskByFiboMultiplier, _fibo)) - _lots;
   }
   if(use_zigzag_size && riskByZZSizeMultiplier != 0){
      addLotsZZSize = (_lots * MathPow(riskByZZSizeMultiplier, zzCtrl[_iSymbol][_iSetup].lineCD.size)) - _lots;
   }
   if(usePitchfork && riskByAtrToMedianMultiplier != 0 && atrToMedianBySetup[_iSetup] > 0){
      double pipsToMedian = 0; double relativeAtrValue = 0;
      if(_orderType == OP_BUY){
         pipsToMedian = (pitchforkCtrl[iSymbol][_iSetup].pitchforkBCD.lineMedian.priceCurrentBar - pitchforkCtrl[iSymbol][_iSetup].settings.priceAsk);
      }
      else if(_orderType == OP_SELL){
         pipsToMedian = (pitchforkCtrl[iSymbol][_iSetup].settings.priceBid - pitchforkCtrl[iSymbol][_iSetup].pitchforkBCD.lineMedian.priceCurrentBar);
      }
      relativeAtrValue = (pipsToMedian / settings[iSymbol][_iSetup].atrValue) / atrToMedianBySetup[_iSetup];
      addLotsAPMedian = (_lots * MathPow(riskByAtrToMedianMultiplier, relativeAtrValue)) - _lots;
      //Print(StringConcatenate("relativeAtrValue:",relativeAtrValue," (pipsToMedian(", pipsToMedian,") / atrValue(",settings[iSymbol][_iSetup].atrValue,") / atrToMedianBySetup[",_iSetup,"](",atrToMedianBySetup[_iSetup],")"));
   }
   
   //Print(StringConcatenate("LotSizeBySetup:", _lots,", lotAddTrend:",addLotsTrend,", lotAddFibo:",addLotsFibo,", lotAddZzSize:",addLotsZZSize,", lotAddApMedian:",addLotsAPMedian));
   _lots = _lots + addLotsTrend + addLotsFibo + addLotsZZSize + addLotsAPMedian;
   
   _lots = NormalizeDouble(_lots, 2);
   //Print(StringConcatenate("Final Lots Calculed: ", _lots));
   if(_lots > _lotsMax){ 
      Print(StringConcatenate("Fixing maximum risk, lots of maximum has been reached. lots: ",_lots,", lotsMax: ",_lotsMax));
      _lots = _lotsMax;
   }
   return _lots < _lotstep ? _lotstep : _lots; 
}
// lot size com stoploss definido:
// double tradeVolume = AccountFreeMargin() * Risk/100 / ( StopLossPoints * MarketInfo( Symbol(), MODE_TICKVALUE ) );
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

   HashLoop *l;
   string key, _currency1, _currency2, _symbol;
   int pos1, pos2;
   double fullEquity = equity * leverage;
   
   ArrayInitialize(lotsBySymbol, 0); ArrayInitialize(marginBySymbol, 0);
   ArrayInitialize(buyLotsBySymbol, 0); ArrayInitialize(sellLotsBySymbol, 0);
   ArrayInitialize(lotsSizeBySymbol, 0);

   if(marginPerCurrency > 0){
      ArrayInitialize(lotsByCurrency, 0); ArrayInitialize(marginByCurrency, 0);
      ArrayInitialize(buyLotsByCurrency, 0); ArrayInitialize(sellLotsByCurrency, 0);
      ArrayInitialize(lotsSizeBySCurrency, 0);
   }
   for( l = new HashLoop(hashOpenOrders) ; l.hasNext() ; l.next()) {
       key = l.key();
       hashOrder = l.val();
       order = hashOrder.getVal();
       if(order != NULL){ 
         //logMessage(LOG_DEBUG, listBrokerSymbols[order.iSymbol], timeframe, "updateMarginController", StringConcatenate("Synchronizing memory: order removed from memory, ticket: ",order.ticket));
         if(order.orderType == OP_BUY){
            buyLotsBySymbol[order.iSymbol] += order.lots;
         }
         else if(order.orderType == OP_SELL){
            sellLotsBySymbol[order.iSymbol] += order.lots;
         }
       } 
   }
   marginTotal = lotsTotal = lotsHedgeTotal = 0;
   for(int iSym=0; iSym < symbols_count; iSym++){
      lotsBySymbol[iSym] = buyLotsBySymbol[iSym] - sellLotsBySymbol[iSym];
      lotsSizeBySymbol[iSym] = LotSize * lotsBySymbol[iSym];
      marginBySymbol[iSym] = (lotsSizeBySymbol[iSym]/fullEquity)*100;
      
      if(marginPerCurrency){
         _symbol = listCleanSymbols[iSym];
         _currency1 = StringSubstr(_symbol, 0,3);
         _currency2 = StringSubstr(_symbol, 3,3);
         pos1 = hashCurrencies.hGetInt(_currency1);
         pos2 = hashCurrencies.hGetInt(_currency2);  
         lotsByCurrency[pos1] += lotsBySymbol[iSym];
         lotsByCurrency[pos2] -= lotsBySymbol[iSym]; 
         marginByCurrency[pos1] += marginBySymbol[iSym];
         marginByCurrency[pos2] -= marginBySymbol[iSym];  
       }
       marginTotal += MathAbs(marginBySymbol[iSym]);
       lotsTotal += buyLotsBySymbol[iSym] + sellLotsBySymbol[iSym];
       lotsHedgeTotal += MathAbs(lotsBySymbol[iSym]);
       
       if(useTrendBalanceByMargin){
         int trend = 0;
         if(marginBySymbol[iSym] > (marginPerSymbol*trendBalance_marginBegin)){
            trend = -1;
            for(double currentMarginStep = trendBalance_marginBegin; currentMarginStep < 1; currentMarginStep += trendBalance_marginStep){
                if(marginBySymbol[iSym] > (marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] <= (marginPerSymbol*(currentMarginStep+trendBalance_marginStep))){ break; }
                else{ trend--; }
            }
         }
         else if(marginBySymbol[iSym] < -(marginPerSymbol*trendBalance_marginBegin) ){
            trend = 1;
            for(double currentMarginStep = trendBalance_marginBegin; currentMarginStep < 1; currentMarginStep += trendBalance_marginStep){
                if(marginBySymbol[iSym] < -(marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] >= -(marginPerSymbol*(currentMarginStep+trendBalance_marginStep))){ break; }
                else{ trend++; }
            }
         }
         if(marginTrendBySymbol[iSym] != trend){
            //logMessage(LOG_WARN,_symbol,timeframe,"updateMarginController",StringConcatenate("CHANGE TREND MARGIN. old:",marginTrendBySymbol[iSym],", new:",trend));
            marginTrendBySymbol[iSym] = trend;
            update_marginTrend = true;
         }
       }
       
       if(useFiboBalanceByMargin){
         int shift = 0;
         if(marginBySymbol[iSym] > (marginPerSymbol*fiboBalance_marginBegin)){
            shift = 1;
            for(double currentMarginStep = fiboBalance_marginBegin; currentMarginStep < 1; currentMarginStep += fiboBalance_marginStep){
                if(marginBySymbol[iSym] > (marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] <= (marginPerSymbol*(currentMarginStep+fiboBalance_marginStep))){ break; }
                else{ shift++; }
            }
         }
         else if(marginBySymbol[iSym] < -(marginPerSymbol*fiboBalance_marginBegin) ){
            shift = -1;
            for(double currentMarginStep = fiboBalance_marginBegin; currentMarginStep < 1; currentMarginStep += fiboBalance_marginStep){
                if(marginBySymbol[iSym] < -(marginPerSymbol*currentMarginStep) && marginBySymbol[iSym] >= -(marginPerSymbol*(currentMarginStep+fiboBalance_marginStep))){ break; }
                else{ shift--; }
            }
         }
         if(fiboBalanceByMargin_shift[iSym] != shift){
            if(shift == 0){ 
               for(int i=0; i<fibo_maxCount; i++){
                  fiboBalanceByBuyMargin[iSym][i] = true;
                  fiboBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift > 0){
               for(int i=0; i<fibo_maxCount; i++){
                  fiboBalanceByBuyMargin[iSym][i] = (i >= shift) ? true : false;
                  fiboBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift < 0){
               for(int i=0; i<fibo_maxCount; i++){
                  fiboBalanceByBuyMargin[iSym][i] = true;
                  fiboBalanceBySellMargin[iSym][i] = (i >= (-shift)) ? true : false;
               }
            }
         }
         fiboBalanceByMargin_shift[iSym] = shift;
      }
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
               for(int i=0; i<setup_count; i++){
                  setupBalanceByBuyMargin[iSym][i] = true;
                  setupBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift > 0){
               for(int i=0; i<setup_count; i++){
                  setupBalanceByBuyMargin[iSym][i] = (i >= shift) ? true : false;
                  setupBalanceBySellMargin[iSym][i] = true;
               }
            }
            else if(shift < 0){
               for(int i=0; i<setup_count; i++){
                  setupBalanceByBuyMargin[iSym][i] = true;
                  setupBalanceBySellMargin[iSym][i] = (i >= (-shift)) ? true : false;
               }
            }
         }
         setupBalanceByMargin_shift[iSym] = shift;
      }
   }
   delete l;
}
//+------------------------------------------------------------------+ 
void createWindowTime(string _window_time, int iWindow){
   if(_window_time != ""){
      string data[];
      int size = StringSplit(_window_time,StringGetCharacter(",",0),data);
      if(size != 11) { 
         logMessage(LOG_CRITICAL, "", 0, "createWindowTime", StringConcatenate("INVALID window",iWindow+1,"_time_zz_setup. String: ", _window_time)); 
         windowTime[iWindow] = new WindowTime();
      }
      else{
         windowTime[iWindow] = new WindowTime(gmt_offset, StrToInteger(data[0]), StrToInteger(data[1]), StrToInteger(data[2]), StrToInteger(data[3]),
         StrToInteger(data[4]),StrToInteger(data[5]),StrToInteger(data[6]),StrToInteger(data[7]),StrToInteger(data[8]),StrToInteger(data[9]),StrToInteger(data[10])
         );
         windowTime[iWindow].PrintWindowTime();
      } 
   }
   else{
      windowTime[iWindow] = new WindowTime();
   }
}
//+------------------------------------------------------------------+
//| MurreyMath Update Function                              |
//+------------------------------------------------------------------+
void updateMurreyMathValues()
{
   if(!update_TFBySymbol[iSymbol]) return;
   int periodTakeShift = 0;
   
   if(murrey_openSignal_timeframe != OFF){
      murreyOpenSignal[iSymbol].updateValues();
      murreyOpenSignal[iSymbol].updateOpenBuySignal();
      murreyOpenSignal[iSymbol].updateOpenSellSignal();
   }
   if(murrey_closeSignal_timeframe != OFF){
      if(useAvgVolumeBalance && use_murrey_avgBalance){
         periodTakeShift = setupBalanceAvgVolShift * murrey_close_avgStep;
      }
      murreyCloseSignal[iSymbol].updateValues(periodTakeShift);
      murreyCloseSignal[iSymbol].updateCloseBuySignal();
      murreyCloseSignal[iSymbol].updateCloseSellSignal();
   }
   if(murrey_range1_timeframe != OFF){
      if(useAvgVolumeBalance && use_murrey_avgBalance){
         periodTakeShift = setupBalanceAvgVolShift * murrey_range1_avgStep;
      }
      murreyRange1[iSymbol].updateValues(periodTakeShift);
      murreyRange1[iSymbol].updateOpenBuyRange(1);
      murreyRange1[iSymbol].updateOpenSellRange(1);
   }
   if(murrey_range2_timeframe != OFF){
      if(useAvgVolumeBalance && use_murrey_avgBalance){
         periodTakeShift = setupBalanceAvgVolShift * murrey_range2_avgStep;
      }
      murreyRange2[iSymbol].updateValues(periodTakeShift);
      murreyRange2[iSymbol].updateOpenBuyRange(2);
      murreyRange2[iSymbol].updateOpenSellRange(2);
   }
   if(murrey_range3_timeframe != OFF){
      murreyRange3[iSymbol].updateValues();
      murreyRange3[iSymbol].updateOpenBuyRange(3);
      murreyRange3[iSymbol].updateOpenSellRange(3);
   }
   if(murrey_trend1_timeframe != OFF){
      murreyTrend1[iSymbol].updateValues();
      
   }
   if(murrey_trend2_timeframe != OFF){
      murreyTrend2[iSymbol].updateValues();

   }
   if(murrey_trend3_timeframe != OFF){
      murreyTrend3[iSymbol].updateValues(); 
   }
 }
//+------------------------------------------------------------------+
void DrawMurreyMath(string id, MurreyMath *murreyMath){
   //Print(StringConcatenate("DrawMurreyMath(",id,"), murreyMath.mmLines[0](",murreyMath.mmLines[0],"), murreyMath.mmLines[12](",murreyMath.mmLines[12],")"));  
   DrawChannel("mml_"+id+"_+2/8"+TimeFrameToString(timeframe), murreyMath.mmLines[0], clrRed);
   DrawChannel("mml_"+id+"_+1/8"+TimeFrameToString(timeframe), murreyMath.mmLines[1], clrRed);
   DrawChannel("mml_"+id+"_8/8"+TimeFrameToString(timeframe), murreyMath.mmLines[2], clrCoral);
   DrawChannel("mml_"+id+"_7/8"+TimeFrameToString(timeframe), murreyMath.mmLines[3], clrCoral);
   DrawChannel("mml_"+id+"_6/8"+TimeFrameToString(timeframe), murreyMath.mmLines[4], clrYellow);
   DrawChannel("mml_"+id+"_5/8"+TimeFrameToString(timeframe), murreyMath.mmLines[5], clrYellow);
   DrawChannel("mml_"+id+"_4/8"+TimeFrameToString(timeframe), murreyMath.mmLines[6], clrDodgerBlue);
   DrawChannel("mml_"+id+"_3/8"+TimeFrameToString(timeframe), murreyMath.mmLines[7], clrYellow);
   DrawChannel("mml_"+id+"_2/8"+TimeFrameToString(timeframe), murreyMath.mmLines[8], clrYellow);
   DrawChannel("mml_"+id+"_1/8"+TimeFrameToString(timeframe), murreyMath.mmLines[9], clrCoral);
   DrawChannel("mml_"+id+"_0/8"+TimeFrameToString(timeframe), murreyMath.mmLines[10], clrCoral);
   DrawChannel("mml_"+id+"_-1/8"+TimeFrameToString(timeframe), murreyMath.mmLines[11], clrRed);
   DrawChannel("mml_"+id+"_-2/8"+TimeFrameToString(timeframe), murreyMath.mmLines[12], clrRed);
}
//+------------------------------------------------------------------+