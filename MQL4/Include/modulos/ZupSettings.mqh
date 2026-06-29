//+------------------------------------------------------------------+
//|                                                  ZupSettings.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict

#define    _DAYSECONDS_ 86400

//--------------------------------------------------------
// ZUP Variables
//--------------------------------------------------------
static long     chartId = ChartID();
static bool     debug_zup = false;
static bool     debug_pitchfork = true;
static bool     debug_pattern = false;
static bool     visual_zup = true;
static bool     visual_pitchfork = true;
static bool     visual_pattern = true;

static int      fiboRound = 3;
//static double   retpatterns[20]={0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236};
static double   retpatterns[20]={0.146,0.236,0.382,0.447,0.5,0.618,0.707,0.786,0.886,1.0,1.128,1.272,1.414,1.618,2.0,2.236,2.618,3.1416,3.618,4.236};
static string   retpatternstxt[20]={".146",".236",".382",".447",".5",".618",".707",".786",".886","1.0","1.128","1.272","1.414","1.618","2.0","2.236","2.618","3.14","3.618","4.236"};
static int      retpatternsSize = 20;
       double   deltapatterns[3][20][2];
static double   ExtDeltaGartley         = 0.09;
static double   ExtDeltaGartleyPRZ      = 0.02;
static double   ExtDelta                = 0.04;

class WindowTime{
public:
   bool inUse, inTime;
   int hourBegin, hourEnd, minuteBegin, minuteEnd, gmt_offset;
   bool setups[7];
   WindowTime(){ 
      hourBegin = hourEnd = minuteBegin = minuteEnd = 0; ArrayInitialize(setups, false); inUse = inTime = false; 
   }
   WindowTime(int _gmt_offset, int hourB, int minuteB, int hourE, int minuteE ){ 
      hourBegin = hourB+_gmt_offset; minuteBegin = minuteB; hourEnd = hourE+_gmt_offset; minuteEnd = minuteE; ArrayInitialize(setups, false); inUse = true; inTime = false; gmt_offset = _gmt_offset;
   }
   WindowTime(int _gmt_offset, int hourB, int minuteB, int hourE, int minuteE, bool s1, bool s2, bool s3, bool s4, bool s5, bool s6, bool s7){ 
      hourBegin = hourB+_gmt_offset; minuteBegin = minuteB; hourEnd = hourE+_gmt_offset; minuteEnd = minuteE; inUse = true; inTime = false; gmt_offset = _gmt_offset;
      setups[0] = s1; setups[1] = s2; setups[2] = s3; setups[3] = s4; setups[4] = s5; setups[5] = s6; setups[6] = s7;  
  }
  string WindowTimeToStr(){
     return StringConcatenate("gmt_offset(",gmt_offset,") Begin(",hourBegin,":",minuteBegin,") End(",hourEnd,":",minuteEnd,") Setups(",setups[0],",",setups[1],",",setups[2],",",setups[3],",",setups[4],",",setups[5],",",setups[6],")");
  }
  void PrintWindowTime(){
     Print("WindowTime: "+WindowTimeToStr());
  }
  bool checkIfTimeInsideWindow(){
      datetime timeCurrent = TimeCurrent(); 
      int hourCurrent =  TimeHour(timeCurrent);
      int minuteCurrent = TimeMinute(timeCurrent);
      if(hourCurrent >= hourBegin && hourCurrent < hourEnd){
         if( ( hourCurrent != hourBegin || (hourCurrent == hourBegin && minuteCurrent >= minuteBegin)) && 
             ( hourCurrent != hourEnd || (hourCurrent == hourEnd && minuteCurrent < minuteEnd)) ){
            inTime = true;
            return true;    
         }
      }
      inTime = false;
      return false;
  }
};

enum NO_HEDGE_TYPE{ NO_HEDGE_CLOSE, NO_HEDGE_CLOSE_AND_OPEN, NO_HEDGE_CLOSE_ALL, NO_HEDGE_CLOSE_ALL_AND_INVERT, NO_HEDGE_FIBO_INVERT, NO_HEDGE_CLOSE_WITH_BALANCE};
enum ZZ_FIBO_PATTERN{ BD_PATTERN, XD_PATTERN, AC_PATTERN, XB_PATTERN, AD_PATTERN };
//--------------------------------------------------------
// Pitchfork Chart Settings
//--------------------------------------------------------
class PitchForkChartSettings{
public:
   color color_median, color_trigger, color_tynes, color_reaction, color_projection, color_line_info;
   bool ray;   ENUM_LINE_STYLE  style;   int  width;
   int font_sizeSmall, font_sizeMedium, font_sizeLarge;
   PitchForkChartSettings(color clr_median, color clr_tynes, color clr_trigger, color clr_reaction, color clr_projection, color clr_line_info, bool _ray,  ENUM_LINE_STYLE _style, int _width){
      color_median = clr_median; color_tynes = clr_tynes; color_trigger = clr_trigger; color_reaction = clr_reaction; color_projection = clr_projection;
      color_line_info = clr_line_info; ray = _ray; style = _style; width = _width;
      font_sizeSmall = 9; font_sizeMedium = 11; font_sizeLarge = 13; 
   }
};
static PitchForkChartSettings chartAP_Black1(clrLime, clrLime, clrLightGreen, clrDarkSeaGreen, clrWhite, clrGold, false, STYLE_DASHDOTDOT, 1 );
static PitchForkChartSettings chartAP_Black2(clrCyan, clrCyan, clrSkyBlue, clrDeepSkyBlue, clrIndianRed, clrGold, false, STYLE_DASHDOTDOT, 1 );
static PitchForkChartSettings chartAP_White1(clrLime, clrLime, clrSpringGreen, clrLimeGreen, clrBlack, clrIndianRed, false, STYLE_DASHDOTDOT, 1 );
static PitchForkChartSettings chartAP_White2(clrDodgerBlue, clrDodgerBlue, clrSlateBlue, clrRoyalBlue, clrBlack, clrIndianRed, false, STYLE_DASHDOTDOT, 1 );

//--------------------------------------------------------
// ZigZag Chart Settings
//--------------------------------------------------------  
class ZigZagChartSettings{
public:
   color color_line, color_linkLine, color_linkTxt, color_fiboPatternTxt, color_line_info;
   int font_sizeSmall, font_sizeMedium, font_sizeLarge; 
   bool show_zz_bars;  
   ZigZagChartSettings(color clr_line, color clr_linkLine, color clr_linkTxt, color clr_fiboPatternTxt, color clr_line_info){
      color_line = clr_line; color_linkLine = clr_linkLine; color_linkTxt = clr_linkTxt; color_fiboPatternTxt = clr_fiboPatternTxt; color_line_info = clr_line_info;
      font_sizeSmall = 9; font_sizeMedium = 11; font_sizeLarge = 13; show_zz_bars = true;
   }
};
static ZigZagChartSettings chartZZ_Black(clrWhite, clrViolet, clrGray, clrRed, clrGold);
static ZigZagChartSettings chartZZ_White(clrBlue, clrViolet, clrGray, clrRed, clrIndianRed);
//--------------------------------------------------------
// HarmonicPattern Chart Settings
//--------------------------------------------------------        

//--------------------------------------------------------
// enumerations
//--------------------------------------------------------  
enum PATTERN_TYPE{
    PATTERN_BULLISH, 
    PATTERN_BEARISH
};
enum COLOR_TYPE{
   WHITE, 
   BLACK
};

string getZZSetupLabel(int _pos){
   return StringConcatenate("(",zigzagSetupArr[_pos][0],",",zigzagSetupArr[_pos][1],",",zigzagSetupArr[_pos][2],")");
}
static int zigzagSetupArr[8][3]= {8,5,3, 13,5,3, 21,5,3, 34,5,3, 55,5,3, 89,5,3, 144,5,3, 233,5,3};
static int zigzagNem4SetupArr[8][3]= {5,3,8, 8,5,13, 13,8,21, 21,13,34, 34,21,55, 55,34,89, 89,55,144, 144,89,233};
static int zigzagCZZSetupArr[8][2]= {5,2, 13,5, 55,21, 144,55, 233,89, 377,144, 610,233, 987,377}; 

//--------------------------------------------------------
datetime addDatetimeFix(datetime _time, datetime _add){
   int dayOfWeek = 0;
   
   datetime timeCorrected = _time + _add;
   datetime _timeEnd = timeCorrected;
   datetime _current = _time;
   bool fix = false;
   
   while(_current < _timeEnd){
      dayOfWeek = TimeDayOfWeek(_current);
      if(dayOfWeek == 0 || dayOfWeek == 6){
         timeCorrected = timeCorrected + _DAYSECONDS_;
         fix = true;
      }
      _current = _current + _DAYSECONDS_;
   }
   if(fix) Print(StringConcatenate("addDatetimeFix, _time: ", TimeToStr(_time), ", _add: ", IntegerToString(_add), ", newTime: ", TimeToStr(timeCorrected)));
   return timeCorrected;
}
//--------------------------------------------------------  
datetime addDatetime2(datetime _time, datetime _add){
   int dayOfWeekTime1;
   datetime newTime = _time + _add;
   dayOfWeekTime1 = TimeDayOfWeek(newTime);
   if(dayOfWeekTime1 == 0 || dayOfWeekTime1 == 6){
      newTime += _DAYSECONDS_ * 2;
      Print(StringConcatenate("addDatetime2, _time: ", TimeToStr(_time), ", _add: ", IntegerToString(_add), ", newTime: ", TimeToStr(newTime)));
   }
   return newTime;
}
//-------------------------------------------------------- 
/*datetime subtractWeekends(datetime _begin, datetime _end){
   int dayOfWeek = 0;
   datetime timeCorrected = _end;
   datetime _current = _begin;
   while(_current < _end){
      dayOfWeek = TimeDayOfWeek(_current);
      if(dayOfWeek == 0 || dayOfWeek == 6){
         timeCorrected = timeCorrected - _DAYSECONDS_;
      }
      _current = _current + _DAYSECONDS_;
   }
   return timeCorrected;
}*/
//+------------------------------------------------------------------+