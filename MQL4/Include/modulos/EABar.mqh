//+------------------------------------------------------------------+
//|                                                    EAMacd.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
struct Bar {
   datetime current_time, check_time;
   bool updated;
   ENUM_TIMEFRAMES timeframe;
   
   Bar(ENUM_TIMEFRAMES _timeframe) {
      timeframe = _timeframe;
      check_time = 0;
      updated = false;
   }
   Bar(int _timeframe) {
      timeframe = (ENUM_TIMEFRAMES)_timeframe;
      check_time = 0;
      updated = false;
   }

   bool Update()
   {
      updated = false;
      current_time = iTime(NULL,timeframe,0);
      if(check_time != current_time){
         updated = true;
         check_time = current_time;
      }
      return updated;
   }
};
//+------------------------------------------------------------------+
