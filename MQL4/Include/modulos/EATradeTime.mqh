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
//+------------------------------------------------------------------+
//| Externs
//+------------------------------------------------------------------+
extern string  WindowTime1_Info           = "=======================================";
extern string  WindowTime2_Info           = "========== WINDOW TIME SETUP ==========";
extern string  WindowTime3_Info           = "=======================================";
extern   bool  useWindowTimeSetup         = false;
extern string  window_time_info           = "TIME: HH(Begin),MM(Begin),HH(End),MM(End),Mon,Tue,Wed,thu,Fri,CloseAll(Y,N)";
extern string  window1_time_str           = "00,00,19,00,1,1,1,1,1,Y";
extern string  window2_time_str           = "";
extern string  window3_time_str           = "";
extern string  window4_time_str           = "";
extern string  window5_time_str           = "";
extern string  window_setup_info          = "SETUP: Setup1,setup2,setup3,setup4,setup5,setup6,setup7";
extern string  window1_setup_str          = "1,1,1,1,1,1,1";
extern string  window2_setup_str          = "0,0,0,0,1,1,1";
extern string  window3_setup_str          = "0,0,0,1,1,1,0";
extern string  window4_setup_str          = "0,0,1,1,1,0,0";
extern string  window5_setup_str          = "";
extern SIGNAL_TYPE window_openSignalType  = AND;
extern SIGNAL_TYPE window_closeSignalType = OR;

//+------------------------------------------------------------------+
//| Class WindowTime
//+------------------------------------------------------------------+
class WindowTime {
public:
   bool inUse, inTime, lastInTime;
   int hourBegin, hourEnd, minuteBegin, minuteEnd;
   int lastHour, lastMinute;
   bool useMinute, closeAll;
   bool setups[7], days[5];
   //+------------------------------------------------------------------+
   WindowTime(string window_time_str, string window_setup_str, int gmt_offset_)
   {
      inUse = inTime = lastInTime = false;
      if(window_time_str != "" && window_setup_str != "")
      {
         string time_data[];
         string setup_data[];
         int time_size = StringSplit(window_time_str,StringGetCharacter(",",0),time_data);
         int setup_size = StringSplit(window_setup_str,StringGetCharacter(",",0),setup_data);

         if(time_size != 10 || setup_size != 7) {
            logMessage(LOG_CRITICAL, "", 0, "createWindowTime", StringConcatenate("INVALID WINDOW: TimeStr: ", window_time_str, " - SetupStr: ", window_setup_str));
            return;
         }

         hourBegin = StrToInteger(time_data[0]);
         minuteBegin = StrToInteger(time_data[1]);
         hourEnd = StrToInteger(time_data[2]);
         minuteEnd = StrToInteger(time_data[3]);
         days[0] = StrToInteger(time_data[4]);
         days[1] = StrToInteger(time_data[5]);
         days[2] = StrToInteger(time_data[6]);
         days[3] = StrToInteger(time_data[7]);
         days[4] = StrToInteger(time_data[8]);
         if(time_data[9] == "Y") closeAll = true;
         else if(time_data[9] == "N") closeAll = false;
         else{
            logMessage(LOG_CRITICAL, "", 0, "createWindowTime", StringConcatenate("INVALID CloseAll: TimeStr: ", window_time_str, " - SetupStr: ", window_setup_str));
            return;
         }
         setups[0] = StrToInteger(setup_data[0]);
         setups[1] = StrToInteger(setup_data[1]);
         setups[2] = StrToInteger(setup_data[2]);
         setups[3] = StrToInteger(setup_data[3]);
         setups[4] = StrToInteger(setup_data[4]);
         setups[5] = StrToInteger(setup_data[5]);
         setups[6] = StrToInteger(setup_data[6]);

         if(minuteBegin == 0 && minuteEnd == 0)
            useMinute = false;

         inUse = true;
         lastHour = lastMinute = 0;
      }
   }
   //+------------------------------------------------------------------+
   string WindowTimeToStr(){
     return StringConcatenate("WindowTime: Begin(",hourBegin,":",minuteBegin,") End(",hourEnd,":",minuteEnd,") ",
     "Days(",days[0],",",days[1],",",days[2],",",days[3],",",days[4],") CloseAll(",closeAll,") ",
     "Setups(",setups[0],",",setups[1],",",setups[2],",",setups[3],",",setups[4],",",setups[5],",",setups[6],")");
   }
   void PrintWindowTime(){
     Print(WindowTimeToStr());
   }
   //+------------------------------------------------------------------+
   bool checkIfTimeInsideWindow(datetime timeCurrent, bool& changed)
   {
      int hourCurrent =  TimeHour(timeCurrent);
      int minuteCurrent = TimeMinute(timeCurrent);
      lastInTime = inTime;
      inTime = false;
      changed = false;

      //if(lastHour == hourCurrent && (lastMinute == minuteCurrent || (hourCurrent != hourBegin && hourCurrent != hourEnd ))){
      //   return lastInTime;
      //}
      int iDay = DayOfWeek() - 1;
      //Print(StringConcatenate("iDay:", iDay, ", hourCurrent:", hourCurrent, ", hourBegin:",hourBegin, ", hourEnd:", hourEnd));
      if(iDay >= 0 && iDay <= 4 && days[iDay])
      {
         if(hourCurrent >= hourBegin && hourCurrent <= hourEnd)
         {
            inTime = true;
            if(hourCurrent == hourBegin){
               if(minuteCurrent < minuteBegin)
                  inTime = false;
            }
            if(hourCurrent == hourEnd){
               if(minuteCurrent >= minuteEnd)
                  inTime = false;
            }
         }
         //Print(StringConcatenate("inTime:", inTime, ", minuteCurrent:", minuteCurrent, ", minuteBegin:",minuteBegin, ", minuteEnd:", minuteEnd));
      }
      lastHour = hourCurrent;
      lastMinute = minuteCurrent;
      if(inTime != lastInTime){
         changed = true;
      }
      lastInTime = inTime;
      return inTime;
   }
};
//+------------------------------------------------------------------+
//| Class EATradeTime
//+------------------------------------------------------------------+
class EATradeTime : public EAIndicator
{
//+------------------------------------------------------------------+
private:
   Vector<WindowTime*> times;
   bool setupOpen[TF_COUNT];//, setupClose[TF_COUNT];
public:
//+------------------------------------------------------------------+
public:
   EATradeTime(EACore* _core, EATimeframes* _timeframes)
      : EAIndicator(_core, _timeframes, "TradeTime")
   {
      if(useWindowTimeSetup)
      {
         openSignalType  = window_openSignalType;
         closeSignalType = window_closeSignalType;
    
         ArrayInitialize(setupOpen, false);
         //ArrayInitialize(setupClose, false);

         WindowTime* windowTime;
         windowTime = new WindowTime(window1_time_str, window1_setup_str, gmt_offset);
         if(windowTime.inUse) times.push(windowTime);
         else delete(windowTime);

         windowTime = new WindowTime(window2_time_str, window2_setup_str, gmt_offset);
         if(windowTime.inUse) times.push(windowTime);
         else delete(windowTime);

         windowTime = new WindowTime(window3_time_str, window3_setup_str, gmt_offset);
         if(windowTime.inUse) times.push(windowTime);
         else delete(windowTime);

         windowTime = new WindowTime(window4_time_str, window4_setup_str, gmt_offset);
         if(windowTime.inUse) times.push(windowTime);
         else delete(windowTime);

         windowTime = new WindowTime(window5_time_str, window5_setup_str, gmt_offset);
         if(windowTime.inUse) times.push(windowTime);
         else delete(windowTime);

         foreachv(WindowTime*,time,times){
            time.PrintWindowTime();
         }
      }

   }
   //+------------------------------------------------------------------+
   ~EATradeTime()
   {
      foreachv(WindowTime*,time,times){
         delete(time);
      }
      times.clear();
   }
   //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
   //+------------------------------------------------------------------+
   virtual void UpdateAllData()
   {
     if(!timeframes.IsUpdatedCurrentTF()) return;
   
     //ResetAllSignals();
     ArrayInitialize(setupOpen, false);
     //ArrayInitialize(setupClose, false);

     datetime timeCurrent = TimeCurrent();
     bool changed = false;
     bool close = false;

     foreachv(WindowTime*,time,times)
     {
        bool inTime = time.checkIfTimeInsideWindow(timeCurrent, changed); 
        
        //Print(StringConcatenate("checkIfTimeInsideWindow:", time.WindowTimeToStr()));
        //Print(StringConcatenate("timeCurrent:", timeCurrent, ", changed:", changed, ", inTime:",inTime));
        
        if(inTime)
        {
          for(int iSet=0; iSet<TF_COUNT; iSet++)
          {
            if(time.setups[iSet])
               setupOpen[iSet] = true;
          }
        }
     }
   }
   //+------------------------------------------------------------------+
   void UpdateData(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   void UpdateSignal(int iSym, int iSet)
   {
   if(!timeframes.IsUpdatedCurrentTF()) return;
   if(setupOpen[iSet]){
      buySignal[iSym][iSet] = true;
      sellSignal[iSym][iSet] = true;
      closeBuy[iSym][iSet] = false;
      closeSell[iSym][iSet] = false;
   }
   else{
      buySignal[iSym][iSet] = false;
      sellSignal[iSym][iSet] = false;
      closeBuy[iSym][iSet] = true;
      closeSell[iSym][iSet] = true;
   }
     /*buySignal[iSym][iSet] = setupOpen[iSet];
     sellSignal[iSym][iSet] = setupOpen[iSet];
     closeBuy[iSym][iSet] = setupClose[iSet];
     closeSell[iSym][iSet] = setupClose[iSet];*/
   }
   //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      foreachv(WindowTime*,time,times){
         info += time.WindowTimeToStr() + "\n";
      }
      info += StringConcatenate("FinalWindowTime:",
      " SetupOpen(",setupOpen[0],",",setupOpen[1],",",setupOpen[2],",",setupOpen[3],",",setupOpen[4],",",setupOpen[5],",",setupOpen[6],")"//,
      //" SetupClose(",setupClose[0],",",setupClose[1],",",setupClose[2],",",setupClose[3],",",setupClose[4],",",setupClose[5],",",setupClose[6],")"
      );
      return info;
   }
   //+------------------------------------------------------------------+
};
//+------------------------------------------------------------------+
