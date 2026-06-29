//+------------------------------------------------------------------+
//|                                              IndicatorsClass.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
enum TIMEFRAME{
   OFF=-1, CURRENT=0, M1=1, M5=5, M15=15, M30=30, H1=60, H4=240, D1=1440, W1=10080, MN1=43200
};
//+------------------------------------------------------------------+
extern string  tf1_Info                = "=====================================";
extern string  tf2_Info                = "========== TIMEFRAME SETUP ==========";
extern string  tf3_Info                = "=====================================";
extern bool    use_timeframe_setup1    = false;
extern bool    use_timeframe_setup2    = true;
extern bool    use_timeframe_setup3    = true;
extern bool    use_timeframe_setup4    = true;
extern bool    use_timeframe_setup5    = true;
extern bool    use_timeframe_setup6    = true;
extern bool    use_timeframe_setup7    = false;
extern TIMEFRAME timeframe_setup1      = 1;
extern TIMEFRAME timeframe_setup2      = 5;
extern TIMEFRAME timeframe_setup3      = 15;
extern TIMEFRAME timeframe_setup4      = 60;
extern TIMEFRAME timeframe_setup5      = 240;
extern TIMEFRAME timeframe_setup6      = 1440;
extern TIMEFRAME timeframe_setup7      = 10080;
extern string  atr1_info                = "===============================";
extern string  atr2_info                = "========== ATR SETUP ==========";
extern string  atr3_info                = "===============================";
extern int     atrFastPeriod            = 50;
extern int     atrSlowPeriod            = 500;
//+------------------------------------------------------------------+
#ifndef TF_COUNT
   #define TF_COUNT 7
#endif
//+------------------------------------------------------------------+
class EATimeframes{
  protected:
  string symbols[];
  int symbols_count;
  bool setupInUse[TF_COUNT], updated[][TF_COUNT], updatedCurrentTF;
  int setupTFValue[TF_COUNT];
  int default_pos, default_value;
  datetime period_check[][TF_COUNT];
  datetime iTime_currentTF, period_check_currentTF;
  double atrFastData[][TF_COUNT], atrSlowData[][TF_COUNT];
  int bars[][TF_COUNT];
  bool useATR;
public:
  EATimeframes(string &brokerSymbols[])
  {
    useATR = true;
    symbols_count = ArraySize(brokerSymbols);
    ArrayResize(symbols, symbols_count);
    ArrayCopy(symbols,brokerSymbols,0,0,WHOLE_ARRAY);

    setupInUse[0] = use_timeframe_setup1; setupTFValue[0] = timeframe_setup1;
    setupInUse[1] = use_timeframe_setup2; setupTFValue[1] = timeframe_setup2;
    setupInUse[2] = use_timeframe_setup3; setupTFValue[2] = timeframe_setup3;
    setupInUse[3] = use_timeframe_setup4; setupTFValue[3] = timeframe_setup4;
    setupInUse[4] = use_timeframe_setup5; setupTFValue[4] = timeframe_setup5;
    setupInUse[5] = use_timeframe_setup6; setupTFValue[5] = timeframe_setup6;
    setupInUse[6] = use_timeframe_setup7; setupTFValue[6] = timeframe_setup7;
    ArrayResize(updated, symbols_count);
    ArrayInitialize(updated, true);
    ArrayResize(period_check, symbols_count);
    ArrayInitialize(period_check, 0);

    ArrayResize(atrFastData, symbols_count );
    ArrayInitialize(atrFastData, 0);
    ArrayResize(atrSlowData, symbols_count );
    ArrayInitialize(atrSlowData, 0);
    ArrayResize(bars, symbols_count );
    ArrayInitialize(bars, 0);

    for(int i=0; i<TF_COUNT;i++)
    {
      if(setupInUse[i]){
         default_pos = i;
         default_value = setupTFValue[i];
         break;
      }
    }
    period_check_currentTF = 0;
  }
  //+------------------------------------------------------------------+
   void UpdateCurrentTF()
   {
      updatedCurrentTF = false;
      iTime_currentTF = iTime(NULL,default_value,0);
      if(period_check_currentTF != iTime_currentTF){
         updatedCurrentTF = true;
         period_check_currentTF = iTime_currentTF;
      }
   }
  //+------------------------------------------------------------------+
  bool UpdateAllSymbols()
  {
    bool hasUpdate = false;
     for(int iSym = 0; iSym < symbols_count; iSym++)
     {
       bool isUpdated = UpdateBySymbol(iSym);
       hasUpdate = hasUpdate || isUpdated;
     }
     return hasUpdate;
  }
  //+------------------------------------------------------------------+
  bool UpdateBySymbol(int iSym)
  {
    bool hasUpdate = false;
    for(int iSet = 0; iSet < TF_COUNT; iSet++)
    {
      bool isUpdated = UpdateBySetup(iSym, iSet);
      hasUpdate = hasUpdate || isUpdated;
    }
    return hasUpdate;
  }
  //+------------------------------------------------------------------+
  bool UpdateBySetup(int iSym, int iSet)
  {
    bool hasUpdate = false;
    updated[iSym][iSet] = false;
    datetime iTime_Setup = iTime(symbols[iSym],setupTFValue[iSet],0);
    if(period_check[iSym][iSet] != iTime_Setup)
    {
       hasUpdate = updated[iSym][iSet] = true;
       period_check[iSym][iSet] = iTime_Setup;
       int bars_ = iBars(symbols[iSym], setupTFValue[iSet]) - 1;
       int atrFastPeriod_ = (bars_ < atrFastPeriod) ? bars_ : atrFastPeriod;
       int atrSlowPeriod_ = (bars_ < atrSlowPeriod) ? bars_ : atrSlowPeriod;
       bars[iSym][iSet] = bars_;
       atrFastData[iSym][iSet] = iATR(symbols[iSym],setupTFValue[iSet], atrFastPeriod_, 1);
       atrSlowData[iSym][iSet] = iATR(symbols[iSym],setupTFValue[iSet], atrSlowPeriod_, 1);
       
       //Print(StringConcatenate("Timeframes SETUP - ",symbols[iSym],", ",PosToStr(iSet),", AtrFast: ",atrFastData[iSym][iSet],", AtrSlow: ", atrSlowData[iSym][iSet]));
    }
    return hasUpdate;
  }
  //+------------------------------------------------------------------+
  int GetMaxBars(int iSym, int iSet, int nbars){
    int bars_ = bars[iSym][iSet];
    return (bars_ < nbars) ? bars_ : nbars;
  }
  double getAtrFast(int iSym, int iSet){
     return atrFastData[iSym][iSet];
  }
  double getAtrSlow(int iSym, int iSet){
    return atrSlowData[iSym][iSet];
  }
  bool IsUpdated(int iSymbol_, int iTF_){
   return updated[iSymbol_][iTF_];
  }
  bool IsUpdatedCurrentTF(){
   return updatedCurrentTF;
  }
  bool InUse(int iTF_){
    return setupInUse[iTF_];
  }
  int Value(int iTF_){
    return setupTFValue[iTF_];
  }
  int DefaultValue(){
    return default_value;
  }
  int DefaultPosition(){
    return default_pos;
  }
  string defaultStr(){
    return ValueToStr(default_value);
  }
  string PosToStr(int pos){
    return ValueToStr(setupTFValue[pos]);
  }
  bool GetUseATR() { return useATR; }
  void SetUseATR(bool use) { useATR = use; }

  string ValueToStr(int tf_value)
  {
      string tf_string;
      switch(tf_value) {
         case PERIOD_M1:  tf_string="M1"  ; break;
         case PERIOD_M5:  tf_string="M5"  ; break;
         case PERIOD_M15: tf_string="M15" ; break;
         case PERIOD_M30: tf_string="M30" ; break;
         case PERIOD_H1:  tf_string="H1"  ; break;
         case PERIOD_H4:  tf_string="H4"  ; break;
         case PERIOD_D1:  tf_string="D1"  ; break;
         case PERIOD_W1:  tf_string="W1"  ; break;
         case PERIOD_MN1: tf_string="MN";
      }
      return(tf_string);
  }
};
//+------------------------------------------------------------------+
