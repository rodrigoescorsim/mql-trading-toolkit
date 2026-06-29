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
#include <mql4-lib/Collection/HashMap.mqh>
#include <modulos/JAson.mqh>
//+------------------------------------------------------------------+
//| Externs
//+------------------------------------------------------------------+
extern string  SSI_Info1                 = "=======================================";
extern string  SSI_Info2                 = "========++== SSI SENTIMENT ====++======";
extern string  SSI_Info3                 = "=======================================";
extern   bool  useSSI                    = true;
extern string  ssi_api_url               = "https://c.fxssi.com/api/current-ratios";
extern string  ssi_open_diff             = "0,0,-4,-8,-12,-16,-20";
extern string  ssi_close_diff            = "-10,-10,-16,-22,-28,-34,-40";
extern bool    moderate_usd              = true;
extern SIGNAL_TYPE ssi_openSignalType    = AND;
extern SIGNAL_TYPE ssi_closeSignalType   = OR;

string ssi_currencies[] = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD", "XAU"};
string ssi_symbols[] = {"USDCHF", "GBPUSD", "EURUSD", "USDJPY", "USDCAD", "NZDUSD", "AUDUSD", "XAUUSD", "USDX"};
int ssi_sym_count = 9;
   
string targetFile = "ssi_data.json";

//+------------------------------------------------------------------+
//| Class EAPower
//+------------------------------------------------------------------+
class EASSI : public EAIndicator
{
//+------------------------------------------------------------------+
private:
   //double power[8];
   HashMap<string, double> ssi_currency_map;
   HashMap<string, double> ssi_symbol_map;
   double open_diff[];
   double close_diff[];
   string info_open_diff, info_close_diff;
public:
//+------------------------------------------------------------------+
public:
   EASSI(EACore* _core, EATimeframes* _timeframes)
      : EAIndicator(_core, _timeframes, "TradeTime")
   {
      if(useSSI)
      {
         openSignalType  = ssi_openSignalType;
         closeSignalType = ssi_closeSignalType;
         
         info_open_diff = info_close_diff = "";
         int count;
         
         string open_str[];
         count =  StringSplit(ssi_open_diff,StringGetCharacter(",",0),open_str);
         ArrayResize(open_diff, count);
         info_open_diff = "Open(";
         for(int i=0; i < count; i++){
            open_diff[i] = StringToDouble(open_str[i]);
            info_open_diff += DoubleToString(open_diff[i], 2) + ",";
         }
         info_open_diff += ") ";
         
         string close_str[];
         count =  StringSplit(ssi_close_diff,StringGetCharacter(",",0),close_str);
         ArrayResize(close_diff, count);
         info_close_diff = "Close(";
         for(int i=0; i < count; i++){
            close_diff[i] = StringToDouble(close_str[i]);
            info_close_diff += DoubleToString(close_diff[i], 2) + ",";
         }
         info_close_diff += ") ";
         
      }

   }
   //+------------------------------------------------------------------+
   ~EASSI()
   {
   }
   //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet){}
   //+------------------------------------------------------------------+
   virtual void UpdateAllData()
   {
     if(!timeframes.IsUpdatedCurrentTF()) return;
     FileDelete(targetFile);
     if (HttpGET(ssi_api_url, targetFile)){
     
         int f = FileOpen(targetFile, FILE_TXT|FILE_READ, '?');
         if (f == 0) {
            // File not found
            Print("Response file not found! tempFile Path: ", targetFile);
            logMessage(LOG_ERROR, Symbol(), Period(), "EASSI::UpdateAllData", StringConcatenate("FileOpen returns INVALID_HANDLE -> tempFile: ",targetFile, ", LastError: ",GetLastError()));
            return;
         }

         string content;
         while(!FileIsEnding(f)) 
         {
            // Read one line...
            content += FileReadString(f);
         }
         Print("File: " + targetFile + " Content: " + content);
         
         CJAVal js(NULL,jtUNDEF);
         bool ret = js.Deserialize(content);
         if(ret) {
            for(int i=0; i<ssi_sym_count; i++) {
               ssi_symbol_map.set(ssi_symbols[i], js["pairs"][ssi_symbols[i]]["average"].ToDbl());
            }
         }
         else {
            logMessage(LOG_ERROR, Symbol(), Period(), "EASSI", StringConcatenate("JSON PARSER FAIL")); 
         }
         
         foreachm(string,_symbol,double,_value,ssi_symbol_map) {
            //info += _currency + ":" + DoubleToString(_value,2) + " ";
            //"USDCHF", "GBPUSD", "EURUSD", "USDJPY", "USDCAD", "NZDUSD", "AUDUSD", "USDX"
            if(_symbol == "USDCHF") {
               ssi_currency_map.set("CHF", (100.0 - _value));
            }
            else if(_symbol == "GBPUSD") {
               ssi_currency_map.set("GBP", _value);
            }
            else if(_symbol == "EURUSD") {
               ssi_currency_map.set("EUR", _value);
            }
            else if(_symbol == "USDJPY") {
               ssi_currency_map.set("JPY", (100.0 - _value));
            }
            else if(_symbol == "USDCAD") {
               ssi_currency_map.set("CAD", (100.0 - _value));
            }
            else if(_symbol == "NZDUSD") {
               ssi_currency_map.set("NZD", _value);
            }
            else if(_symbol == "AUDUSD") {
               ssi_currency_map.set("AUD", _value);
            }
            else if(_symbol == "XAUUSD") {
               ssi_currency_map.set("XAU", _value);
            }
            else if(_symbol == "USDX") {
               ssi_currency_map.set("USD", _value);
            }
         }
         /*foreachm(string,_symbol,double,_value,ssi_currency_map) {
            Print("SSI Currency: " + _symbol + ": " + DoubleToString(_value, 2));
         }*/
         FileClose(f);   
      }
      else{
         logMessage(LOG_ERROR, Symbol(), Period(), "EASSI", StringConcatenate("HttpGET Fail: Cannot update MyFxBook Sentiment Data")); 
      }

   }
   //+------------------------------------------------------------------+
   void UpdateData(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   void UpdateSignalBySymbol(int iSym){
      if(!timeframes.IsUpdatedCurrentTF()) return;
      
      string rawSymbol = core.getRawSymbol(iSym);
      string currency1 = StringSubstr(rawSymbol, 0,3);
      string currency2 = StringSubstr(rawSymbol, 3,3);
      
      for(int iSet=0; iSet < TF_COUNT; iSet++){
         buySignal[iSym][iSet] = true;
         closeBuy[iSym][iSet] = false;
      }
      
      if(ssi_currency_map.contains(currency1) || ssi_currency_map.contains(currency2)) {
         bool isUSD = (currency1 == "USD" || currency2 == "USD");
         double value_currency1 = 50;
         if(ssi_currency_map.contains(currency1))
            value_currency1 = ssi_currency_map[currency1];
            
         double value_currency2 = 50;
         if(ssi_currency_map.contains(currency2))
            value_currency2 = ssi_currency_map[currency2];
          
         double diff = value_currency2 - value_currency1;
         double distance_currency1 = (value_currency1 - 50); 
         double distance_currency2 = (value_currency2 - 50);
         
         //+------------------------------------------------------------------+
         for(int iSet=0; iSet < TF_COUNT; iSet++) {
            bool buy = false;
            if(diff >= open_diff[iSet]) { 
               if(isUSD && moderate_usd) {
                  if( (currency1 != "USD" || distance_currency1 >= open_diff[iSet]) && 
                      (currency2 != "USD" || distance_currency2 <= -open_diff[iSet])) {
                     buy = true;
                  }
               }
               else {
                  buy = true;
               }
            }
            sellSignal[iSym][iSet] = buy;
            //+------------------------------------------------------------------+
            bool sell = false;
            if(diff <= -open_diff[iSet]) {
               if(isUSD && moderate_usd) {
                  if( (currency1 != "USD" || distance_currency1 <= -open_diff[iSet]) && 
                      (currency2 != "USD" || distance_currency2 >= open_diff[iSet])) {
                     sell = true;
                  }
               }
               else {
                  sell = true;
               }
            }
            sellSignal[iSym][iSet] = sell; 
            //+------------------------------------------------------------------+
            bool _closeBuy = false;
            if(diff < close_diff[iSet]) {
               if(isUSD && moderate_usd) {
                  if( (currency1 != "USD" || distance_currency1 < -close_diff[iSet]) || 
                      (currency2 != "USD" || distance_currency2 > close_diff[iSet])) {
                     _closeBuy = true;
                  }
               }
               else {
                  _closeBuy = true;
               }
            }
            closeBuy[iSym][iSet] = _closeBuy;
            //+------------------------------------------------------------------+
            bool _closeSell = false;
            if(diff > -close_diff[iSet]) {
               if(isUSD && moderate_usd) {
                  if( (currency1 != "USD" || distance_currency1 > close_diff[iSet]) || 
                      (currency2 != "USD" || distance_currency2 < -close_diff[iSet])) {
                     _closeSell = true;
                  }
               }
               else {
                  _closeSell = true;
               }
            }
            closeSell[iSym][iSet] = _closeSell;
         }
         //+------------------------------------------------------------------+

         /*for(int iSet=0; iSet < TF_COUNT; iSet++){
             if(diff >= open_diff[iSet] && (!isUSD || !moderate_usd || (distance_currency1 >= open_diff[iSet] && distance_currency2 <= -open_diff[iSet]))) { 
               buySignal[iSym][iSet] = true;
             }
             else {
               buySignal[iSym][iSet] = false;
             }
             
             if(diff <= -open_diff[iSet] && (!isUSD || !moderate_usd || (distance_currency1 <= -open_diff[iSet] && distance_currency2 >= open_diff[iSet]))) {
               sellSignal[iSym][iSet] = true;
             }
             else { 
               sellSignal[iSym][iSet] = false;
             }
             
             if(diff < close_diff[iSet] || (isUSD && moderate_usd && (distance_currency1 < -close_diff[iSet] || distance_currency2 > close_diff[iSet]))) { 
               closeBuy[iSym][iSet] = true;
             }
             else {
               closeBuy[iSym][iSet] = false;
             }
             
             if(diff > -close_diff[iSet] || (isUSD && moderate_usd && (distance_currency1 > close_diff[iSet] || distance_currency2 < -close_diff[iSet]))) {
               closeSell[iSym][iSet] = true;
             } 
             else {
               closeSell[iSym][iSet] = false;
             }
          }*/
      }
   }
   //+------------------------------------------------------------------+
   void UpdateSignal(int iSym, int iSet)
   {
   }
   //+------------------------------------------------------------------+
   string GetInfoBySymbol(int iSym){
      string info = "";
      info += "SSI: ";
      foreachm(string,_currency,double,_value,ssi_currency_map) {
         info += _currency + ":" + DoubleToString(_value,2) + " ";
      }
      info += NL + "SSI BUY(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(buySignal[iSym][iSet], " ");
         }
      }
      info += ") SELL(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(sellSignal[iSym][iSet], " ");
         }
      }
      info += ") CloseBuy(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(closeBuy[iSym][iSet], " ");
         }
      }
      info += ") CloseSell(" ;
      for(int iSet=0; iSet<TF_COUNT; iSet++){
         if(timeframes.InUse(iSet)){
            info += StringConcatenate(closeSell[iSym][iSet], " ");
         }
      }
      info += ")";
      return info;
   }
   //+------------------------------------------------------------------+
};
//+------------------------------------------------------------------+
//////// HTTP GET code ////////

#import "kernel32.dll"
   int  CreateFileW(string lpFileName, int dwDesiredAccess, int dwShareMode, int lpSecurityAttributes, int dwCreationDisposition, int dwFlagsAndAttributes, int hTemplateFile);
   int  WriteFile(int hFile, string lpBuffer, int nNumberOfBytesToWrite, int &lpNumberOfBytesWritten[], int lpOverlapped);
   int  CloseHandle(int hObject);
#import


#import "wininet.dll"
   int InternetOpenW(string sAgent, int lAccessType, string sProxyName="", string sProxyBypass="", int lFlags=0);
   int InternetOpenUrlW(int hInternetSession, string sUrl, string sHeaders="", int lHeadersLength=0, int lFlags=0,
      int lContext=0);
   int InternetReadFile(int hFile, uchar &arr[], int lNumBytesToRead, int& lNumberOfBytesRead[]);
   int InternetCloseHandle(int hInet);
#import


#define INTERNET_OPEN_TYPE_DIRECT       0
#define INTERNET_OPEN_TYPE_PRECONFIG    1
#define INTERNET_OPEN_TYPE_PROXY        3

// Had to cut the following two defines because of silly MQL4 identifier limits

#define _IGNORE_REDIRECT_TO_HTTP        0x00008000
#define _IGNORE_REDIRECT_TO_HTTPS       0x00004000

#define INTERNET_FLAG_KEEP_CONNECTION   0x00400000
#define INTERNET_FLAG_NO_AUTO_REDIRECT  0x00200000
#define INTERNET_FLAG_NO_COOKIES        0x00080000
#define INTERNET_FLAG_RELOAD            0x80000000
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
#define INTERNET_FLAG_DONT_CACHE        0x04000000
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100
#define INTERNET_FLAG_NO_UI             0x00000200

#define HTTP_ADDREQ_FLAG_ADD            0x20000000
#define HTTP_ADDREQ_FLAG_REPLACE        0x80000000

#define INTERNET_SERVICE_HTTP           3
#define INTERNET_DEFAULT_HTTP_PORT      80

#define ICU_ESCAPE                      0x80000000
#define ICU_USERNAME                    0x40000000
#define ICU_NO_ENCODE                   0x20000000
#define ICU_DECODE                      0x10000000
#define ICU_NO_META                     0x08000000
#define ICU_ENCODE_PERCENT              0x00001000
#define ICU_ENCODE_SPACES_ONLY          0x04000000
#define ICU_BROWSER_MODE                0x02000000

#define AGENT                           "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.66 Safari/537.36"
#define BUFSIZ                          1000000

bool HttpGET(string strUrl, string fileName)
{
   long beginTime = TimeLocal();
   long time;
   
  int hSession = InternetOpenW(AGENT, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);
   time = TimeLocal();
   Print(StringConcatenate("TIME POINT 1 is ", IntegerToString(time-beginTime)," beginTime:",beginTime,",time: ", time));
   
  if (hSession == 0) {
    Print("hSession error");
    return(false);
  }

  int hReq = InternetOpenUrlW(hSession, strUrl, NULL, 0, INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_PRAGMA_NOCACHE | INTERNET_FLAG_RELOAD, 0);

   time = TimeLocal();
   Print(StringConcatenate("TIME POINT 2 is ", IntegerToString(time-beginTime)," beginTime:",beginTime,",time: ", time));
   
  if (hReq == 0) {
    Print("hReq error: ",  GetLastError());
    return(false);
  }

  int     lReturn[]  = {1};
  uchar   buffer[BUFSIZ];
  ZeroMemory(buffer);

  int f = FileOpen(fileName, FILE_WRITE|FILE_BIN);
  FileSeek(f, 0, SEEK_SET);
  
  time = TimeLocal();
   Print(StringConcatenate("TIME POINT 4 is ", IntegerToString(time-beginTime)," beginTime:",beginTime,",time: ", time));

  while (TRUE) {
    if (InternetReadFile(hReq, buffer, BUFSIZ, lReturn) <= 0 || lReturn[0] == 0) break;
    
    time = TimeLocal();
   Print(StringConcatenate("TIME POINT 5 is ", IntegerToString(time-beginTime)," beginTime:",beginTime,",time: ", time));
    
    //string s = CharArrayToString(buffer, 0, lReturn[0], CP_UTF8);
    //FileWriteString(f, s, StringBufferLen(s));
    FileWriteArray(f, buffer, 0, lReturn[0]);
  }
  
  FileClose(f);

  InternetCloseHandle(hReq);
  InternetCloseHandle(hSession);

  return (true);
}
//+------------------------------------------------------------------+