//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict


static int LogDebugLevel = 4;
static int handle;
static int reverseSetup[] = {6,5,4,3,2,1,0};
//+------------------------------------------------------------------+
string sp = "----------------------------------------------------------------------------------------------------------------------------------------------------\n";
string NL = "\n";
//enum NO_HEDGE_TYPE{ NO_HEDGE_CLOSE, NO_HEDGE_CLOSE_AND_OPEN, NO_HEDGE_CLOSE_ALL, NO_HEDGE_CLOSE_ALL_AND_INVERT, NO_HEDGE_FIBO_INVERT, NO_HEDGE_CLOSE_WITH_BALANCE};


enum FILL_TYPE{
   FILL_INCLUSIVE, FILL_EXCLUSIVE
}; 
string getFillTypeStr(FILL_TYPE _type){
   switch(_type){
   case FILL_INCLUSIVE: return "FILL_INCLUSIVE";
   case FILL_EXCLUSIVE: return "FILL_EXCLUSIVE";
   }
   return "INVALID";
}
//+------------------------------------------------------------------+
enum EXPIRE_ORDER_TYPE{ 
   EXPIRE_CLOSE, EXPIRE_STOPLOSS, EXPIRE_MARGIN, EXPIRE_NOHEDGE, EXPIRE_NOHEDGE_MARGIN
};
string getExpireOrderTypeStr(EXPIRE_ORDER_TYPE _type){
   switch(_type){
   case EXPIRE_CLOSE: return "EXPIRE_CLOSE";
   case EXPIRE_STOPLOSS: return "EXPIRE_CLOSE_STOPLOSS";
   case EXPIRE_NOHEDGE: return "EXPIRE_NOHEDGE";
   case EXPIRE_MARGIN: return "EXPIRE_MARGIN";
   case EXPIRE_NOHEDGE_MARGIN: return "EXPIRE_NOHEDGE_MARGIN";
   }
   return "EXPIRE_NOTFOUND";
}
//+------------------------------------------------------------------+
enum INIT_ORDER_TYPE{
   INIT_NOT_CLOSE, INIT_CLOSE_ALL, INIT_CLOSE_DIFF_SYMBOL
};
string getInitOrderTypeStr(INIT_ORDER_TYPE _type){
   switch(_type){
   case INIT_NOT_CLOSE: return "INIT_NOT_CLOSE";
   case INIT_CLOSE_ALL: return "INIT_CLOSE_ALL";
   case INIT_CLOSE_DIFF_SYMBOL: return "INIT_CLOSE_DIFF_SYMBOL";
   }
   return "INIT_INVALID";
}
//+------------------------------------------------------------------+
//   OFF=-1, CURRENT=0, M1=1, M5=5, M15=15, M30=30, H1=60, H4=240, D1=1440, W1=10080, MN1=43200
//}; 
//+------------------------------------------------------------------+
enum LOG_TYPE{
   LOG_DEBUG = 5, LOG_INFO = 4, LOG_WARN = 3, LOG_ERROR = 2, LOG_CRITICAL = 1
}; 
void logMessage(LOG_TYPE _type, string _symbol, string _timeframe, string _function, string _message){
   if(LogDebugLevel >= _type){
      Print(StringConcatenate(logTypeToStr(_type),"_",_symbol,"_",_timeframe,"_",_function,": ",_message));
   }
}
void logMessage(LOG_TYPE _type, string _symbol, int _timeframe, string _function, string _message){
   if(LogDebugLevel >= _type){
      Print(StringConcatenate(logTypeToStr(_type),"_",_symbol,"_",TimeFrameToString(_timeframe),"_",_function,": ",_message));
   }
}
void logMessage(LOG_TYPE _type, string _symbol, string _timeframe, string _message){
   if(LogDebugLevel >= _type){
      Print(StringConcatenate(logTypeToStr(_type),"_",_symbol,"_",_timeframe,": ",_message));
   }
}
void logMessage(LOG_TYPE _type, string _symbol, int _timeframe, string _message){
   if(LogDebugLevel >= _type){
      Print(StringConcatenate(logTypeToStr(_type),"_",_symbol,"_",TimeFrameToString(_timeframe),": ",_message));
   }
}
string logTypeToStr(LOG_TYPE _type){
   switch(_type){
      case 1: return "CRITICAL";
      case 2: return "ERROR";
      case 3: return "WARN";
      case 4: return "INFO";
      case 5: return "DEBUG";
   }
   return "UNDEFINED"; 
}
//+------------------------------------------------------------------+ 
void _FileOpen(string _filename){
      handle=FileOpen(_filename,FILE_WRITE|FILE_READ|FILE_TXT," - ");
      if(handle<0)
      {
         string _error = "Failed to open the file by the absolute path. Error code "+IntegerToString(GetLastError());
         Print(_error);
         Alert(_error);
      }
}
//+------------------------------------------------------------------+
void _FileClose(){
   FileClose (handle);
}
//+------------------------------------------------------------------+
void _FileWrite(string _filename, string _msg){
   _FileOpen(_filename);
   if(FileSeek(handle, 0, SEEK_END)) {
      FileWriteString(handle, _msg);
      FileFlush(handle);
   }
   else{ Alert("ERROR: if(FileSeek(handle, 0, SEEK_END))"); }
   _FileClose();
}
//+------------------------------------------------------------------+ 
string TimeFrameToString(int _tf) 
{
   string tfs;
   switch(_tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN";
   }
   return(tfs);
}
//+------------------------------------------------------------------+
string OrderTypeToString(int _order_type){
   switch(_order_type){
      case 0 : return "BUY";
      case 1 : return "SELL";
      case 2 : return "BUYLIMIT";
      case 3 : return "SELLLIMIT";
      case 4 : return "BUYSTOP";
      case 5 : return "SELLSTOP";
   }
   return "OT???";
}
//+------------------------------------------------------------------+
double lotSizeByRisk(double risk){
  return NormalizeDouble(AccountEquity()*risk/10000,2);
}
//+------------------------------------------------------------------+ 
double lotSizeByRisk(double risk, string _symbol){
   double _lots = NormalizeDouble(AccountEquity()*risk/10000,2);
   double _lotstep = MarketInfo (_symbol, MODE_LOTSTEP);
   return _lots < _lotstep ? _lotstep : _lots;
}
// lot size com stoploss definido:
// double tradeVolume = AccountFreeMargin() * Risk/100 / ( StopLossPoints * MarketInfo( Symbol(), MODE_TICKVALUE ) );

//+------------------------------------------------------------------+ 
string cutSuffix(string str, string sep){
   string res = str;
   int index = StringFind(str, sep, 0);
   if (index > 0) res = StringSubstr(str, 0, index);  
   return res;
}
//+------------------------------------------------------------------+ 
string cutPrefix(string str, string sep){
   string res = str;
   int index = StringFind(str, sep, 0);
   if (index != -1)  res = StringSubstr(str, index + StringLen(sep));    
   return res;
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