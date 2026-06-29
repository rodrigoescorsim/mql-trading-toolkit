//+------------------------------------------------------------------+
//|                                              MurreyMathLines.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "rodrigo.escorsim@gmail.com"
#property strict

#include <modulos/Utils.mqh>

static int murreyLinesSize = 13;
static int murreyRangeSize = 12;

//+------------------------------------------------------------------+
enum MURREY_DIRECTION{
   LOWER, UPPER, BOTH
};

//+------------------------------------------------------------------+
//| MurreyMathLines Class                                            |
//+------------------------------------------------------------------+
class MurreyMathSettings{
public:
   bool signalOpenBuy[], signalOpenSell[];
   bool signalCloseBuy[], signalCloseSell[];
   bool range1OpenBuy[], range1OpenSell[];
   bool range2OpenBuy[], range2OpenSell[];
   bool range3OpenBuy[], range3OpenSell[];
   int  trend1values[], trend2values[], trend3values[];
   MURREY_DIRECTION open_direction, close_direction;
   
   MurreyMathSettings(MURREY_DIRECTION _open_direction, MURREY_DIRECTION _close_direction){
      open_direction = _open_direction; close_direction = _close_direction;
   }
   MurreyMathSettings(){
      open_direction = LOWER; close_direction = UPPER;
   }
   
   void InitializeSignalOpenBuy(string array_str){
      ArrayResize(signalOpenBuy, murreyLinesSize); ArrayInitialize(signalOpenBuy, false); 
      InitializeBooleanArray(signalOpenBuy, array_str, murreyLinesSize, "signalOpenBuy");
   }
   void InitializeSignalOpenSell(string array_str){
      ArrayResize(signalOpenSell, murreyLinesSize); ArrayInitialize(signalOpenSell, false);   
      InitializeBooleanArray(signalOpenSell, array_str, murreyLinesSize, "signalOpenSell");
   } 
   void InitializeSignalCloseBuy(string array_str){
      ArrayResize(signalCloseBuy, murreyLinesSize); ArrayInitialize(signalCloseBuy, false);  
      InitializeBooleanArray(signalCloseBuy, array_str, murreyLinesSize, "signalCloseBuy");
   }
   void InitializeSignalCloseSell(string array_str){
      ArrayResize(signalCloseSell, murreyLinesSize); ArrayInitialize(signalCloseSell, false);  
      InitializeBooleanArray(signalCloseSell, array_str, murreyLinesSize, "signalCloseSell");
   }
   void InitializeRange1OpenBuy(string array_str){
      ArrayResize(range1OpenBuy, murreyRangeSize); ArrayInitialize(range1OpenBuy, false);  
      InitializeBooleanArray(range1OpenBuy, array_str, murreyRangeSize, "Range1OpenBuy");
   }
   void InitializeRange1OpenSell(string array_str){
      ArrayResize(range1OpenSell, murreyRangeSize); ArrayInitialize(range1OpenSell, false);  
      InitializeBooleanArray(range1OpenSell, array_str, murreyRangeSize, "Range1OpenSell");
   }
   void InitializeRange2OpenBuy(string array_str){
      ArrayResize(range2OpenBuy, murreyRangeSize); ArrayInitialize(range2OpenBuy, false);  
      InitializeBooleanArray(range2OpenBuy, array_str, murreyRangeSize, "Range2OpenBuy");
   }
   void InitializeRange2OpenSell(string array_str){
      ArrayResize(range2OpenSell, murreyRangeSize); ArrayInitialize(range2OpenSell, false);  
      InitializeBooleanArray(range2OpenSell, array_str, murreyRangeSize, "Range2OpenSell");
   }
   void InitializeRange3OpenBuy(string array_str){
      ArrayResize(range3OpenBuy, murreyRangeSize); ArrayInitialize(range3OpenBuy, false);  
      InitializeBooleanArray(range3OpenBuy, array_str, murreyRangeSize, "Range3OpenBuy");
   }
   void InitializeRange3OpenSell(string array_str){
      ArrayResize(range3OpenSell, murreyRangeSize); ArrayInitialize(range3OpenSell, false);  
      InitializeBooleanArray(range3OpenSell, array_str, murreyRangeSize, "Range3OpenSell");
   }
   void InitializeTrend1Values(string array_str){
      ArrayResize(trend1values, murreyRangeSize); ArrayInitialize(trend1values, 0);  
      InitializeIntegerArray(trend1values, array_str, murreyRangeSize, "trend1values");
   }
   void InitializeTrend2Values(string array_str){
      ArrayResize(trend2values, murreyRangeSize); ArrayInitialize(trend2values, 0);  
      InitializeIntegerArray(trend2values, array_str, murreyRangeSize, "trend2values");
   }
   void InitializeTrend3Values(string array_str){
      ArrayResize(trend3values, murreyRangeSize); ArrayInitialize(trend3values, 0);  
      InitializeIntegerArray(trend3values, array_str, murreyRangeSize, "trend3values");
   }
private:
   //+------------------------------------------------------------------+
   void InitializeBooleanArray(bool &murrey_array_values[], string murrey_str, int arraySize, string _id){
      string murrey_arr_str[], murreyValues="";
      int _size = 0;
      _size = StringSplit(murrey_str,StringGetCharacter(",",0),murrey_arr_str);
      if(_size != arraySize){ logMessage(LOG_ERROR,"",0,"MurreyMathInitialize",StringConcatenate("Invalid murrey_",_id,"_values(",murrey_str,") size != ",arraySize));}
      else{
         for(int i=0; i<arraySize;i++){
            murrey_array_values[i] = StringToInteger(murrey_arr_str[i]);
            murreyValues = StringConcatenate(murreyValues, " ", murrey_array_values[i]);
         }
         logMessage(LOG_INFO,"",0,"MurreyMathInitialize",StringConcatenate("Initializing murrey_",_id,"_values(", murreyValues,")"));
      }
   }
   //+------------------------------------------------------------------+
   void InitializeIntegerArray(int &murrey_array_values[], string murrey_str, int arraySize, string _id){
      string murrey_arr_str[], murreyValues="";
      int _size = 0;
      _size = StringSplit(murrey_str,StringGetCharacter(",",0),murrey_arr_str);
      if(_size != arraySize){ logMessage(LOG_ERROR,"",0,"MurreyMathInitialize",StringConcatenate("Invalid murrey_",_id,"_values(",murrey_str,") size != ",arraySize));}
      else{
         for(int i=0; i<arraySize;i++){
            murrey_array_values[i] = (int)StringToInteger(murrey_arr_str[i]);
            murreyValues = StringConcatenate(murreyValues, " ", murrey_array_values[i]);
         }
         logMessage(LOG_INFO,"",0,"MurreyMathInitialize",StringConcatenate("Initializing murrey_",_id,"_values(", murreyValues,")"));
      }
   }
};

//+------------------------------------------------------------------+
//| MurreyMathLines Class                                            |
//+------------------------------------------------------------------+
class MurreyMath{
private:
   string symbol;
   int timeframe;
   int periodtotake;
   int beginer;
   bool useAtrRangeFilter, signal_closeBar;
   int atrPeriod;
   datetime iTime_murrey, period_check_murrey; 
   double sum,v1,v2,v1_last,v2_last,fractal;
   double range,octave,mn,mx, mmRange_last;
   double x1,x2,x3,x4,x5,x6,y1,y2,y3,y4,y5,y6;
   double finalH,finalL;
   double minAtrRange, murreyMathRange;
   double delta;
   int lastMatchOpenBuyPos, lastMatchOpenSellPos, lastMatchCloseBuyPos, lastMatchCloseSellPos;
   int lastTradedOpenBuyPos, lastTradedOpenSellPos, lastTradedCloseBuyPos, lastTradedCloseSellPos;
   bool tradedOpenBuy[13], tradedOpenSell[13], tradedCloseBuy[13], tradedCloseSell[13];
   MurreyMathSettings *settings;
   bool openBuySignal, openSellSignal, closeBuySignal, closeSellSignal;
   bool openBuyRange1, openBuyRange2, openBuyRange3;
   bool openSellRange1, openSellRange2, openSellRange3;
   int trend1, trend2, trend3;
public:
   double mmLines[13];
   double mmLinesDelta[13][2];
   bool updated, murreyFilterAtr;
   


   MurreyMath(string _symbol, int _timeframe, int _periodtotake, double _delta, int _atrPeriod, double _minAtrRange, bool _signal_closeBar, MurreyMathSettings *_murreySettings){
      symbol = _symbol;
      timeframe = _timeframe;
      periodtotake = _periodtotake;
      beginer = 0;
      delta = _delta;
      signal_closeBar = _signal_closeBar;
      updated = false;
      v1_last = v2_last = mmRange_last = 0;
      atrPeriod = _atrPeriod;
      minAtrRange = _minAtrRange;
      settings = _murreySettings;
      murreyMathRange = 0;
      ArrayInitialize(mmLines, 0.0);
      ArrayInitialize(mmLinesDelta, 0.0);
      useAtrRangeFilter = (minAtrRange > 0.0);
      openBuySignal = openSellSignal = closeBuySignal = closeSellSignal = false;
      openBuyRange1 = openBuyRange2 = openBuyRange3 = false;
      openSellRange1 = openSellRange2 = openSellRange3 = false;
      murreyFilterAtr = false;
      
      lastMatchOpenBuyPos = lastMatchOpenSellPos = lastMatchCloseBuyPos = lastMatchCloseSellPos = -1;
      lastTradedOpenBuyPos = lastTradedOpenSellPos = lastTradedCloseBuyPos = lastTradedCloseSellPos = -1;
      ArrayInitialize(tradedOpenBuy, false);
      ArrayInitialize(tradedOpenSell, false);
      ArrayInitialize(tradedCloseBuy, false);
      ArrayInitialize(tradedCloseSell, false);
   };
   
   bool updateValues(int periodTakeShift = 0){
      updated = false;
      iTime_murrey = iTime(symbol,timeframe,0);
      if(iTime_murrey == 0) logMessage(LOG_ERROR, symbol, timeframe, "MurreyMath::updateValues", StringConcatenate("UPDATE MURREY MATH FAILED: iTime_murrey == ",iTime_murrey));
      if(period_check_murrey != iTime_murrey){
      
         v1=(iLow(symbol,timeframe,iLowest(symbol,timeframe,MODE_LOW,(periodtotake+periodTakeShift),beginer)));
         v2=(iHigh(symbol,timeframe,iHighest(symbol,timeframe,MODE_HIGH,(periodtotake+periodTakeShift),beginer)));
         if(v1 != v1_last || v2 != v2_last){
            //Print(StringConcatenate("updateMurreyMathValues: v1(",v1,"),v1_last(",v1_last,"),v2(",v2,"),v2_last(",v2_last,")"));
            v1_last = v1; v2_last = v2;
            //+------------------------------------------------------------------+
            //| Determine which Fractal to use.....                              |
            //+------------------------------------------------------------------+
            if(v2<=250000 && v2>25000) fractal = 100000;
            if(v2<=25000 && v2>2500) fractal = 10000;
            if(v2<=2500 && v2>250) fractal = 1000;
            if(v2<=250 && v2>25) fractal = 100;
            if(v2<=25 && v2>12.5) fractal = 12.5;
            if(v2<=12.5 && v2>6.25) fractal = 12.5;
            if(v2<=6.25 && v2>3.125) fractal = 6.25;
            if(v2<=3.125 && v2>1.5625) fractal = 3.125;
            if(v2<=1.5625 && v2>0.390625) fractal = 1.5625;
            if(v2<=0.390625 && v2>0) fractal = 0.1953125;
            // calculating our octave....      
            range=(v2-v1); 
            sum=MathFloor(MathLog(fractal/range)/MathLog(2));
            octave=fractal*(MathPow(0.5,sum)); 
            //mn=MathFloor(v1/octave)*octave;
            mn=v1/octave*octave;
            if((mn+octave)>v2)
               mx=mn+octave; 
            else
               mx=mn+(2*octave);

            // calculating xx
            x1=0;x2=0;x3=0;x4=0;x5=0;x6=0;y1=0;y2=0;y3=0;y4=0;y5=0;y6=0;finalH=0;finalL=0;
            
            if((v1>=(3*(mx-mn)/16+mn))&& (v2<=(9*(mx-mn)/16+mn))) x2=mn+(mx-mn)/2; 
            else x2=0;
            if((v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0)) x1=mn+(mx-mn)/2; 
            else x1=0;
            if((v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn))) x4=mn+3*(mx-mn)/4; 
            else x4=0;
            if((v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0)) x5=mx; 
            else x5=0;
            if((v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0)) x3=mn+3*(mx-mn)/4; 
            else x3=0;
            //x6 when we have no sbj, du {}
            if((x1+x2+x3+x4+x5)==0) x6=mx; else x6=0;
            
            finalH=x1+x2+x3+x4+x5+x6;
            // calculating yy
            //y1
            if(x1>0) y1=mn; else y1=0;
            //y2
            if(x2>0) y2=mn+(mx-mn)/4; else y2=0;
            //y3
            if(x3>0) y3=mn+(mx-mn)/4; else y3=0;
            //y4
            if(x4>0) y4=mn+(mx-mn)/2; else y4=0;
            //y5
            if(x5>0) y5=mn+(mx-mn)/2; else y5=0;
            //y6
            if((finalH>0) && ((y1+y2+y3+y4+y5)==0)) y6=mn; else y6=0;
            
            finalL=y1+y2+y3+y4+y5+y6;

            murreyMathRange =(finalH-finalL)/8;
            if(murreyMathRange != mmRange_last){
               //Print(StringConcatenate("updateMurreyMathValues: murreyMathRange(",murreyMathRange,"),mmRange_last(",mmRange_last,")"));
               mmRange_last = murreyMathRange;    
               if(useAtrRangeFilter){
                  double _atr = iATR(symbol, timeframe, atrPeriod, 1);
                  if(_atr == 0.0) logMessage(LOG_ERROR, symbol, timeframe, "MurreyMath::updateValues", StringConcatenate("UPDATE MURREY MATH FAILED: ATR == ",_atr));
                  double minAtrCalculated = _atr * minAtrRange;
                  //Print(StringConcatenate("murreyMathRange(",murreyMathRange,"), minAtrCalculated(",minAtrCalculated,")"));
                  if(murreyMathRange < minAtrCalculated){
                     murreyFilterAtr = true;
                     //logMessage(LOG_WARN, symbol, timeframe, "MurreyMath::updateValues", StringConcatenate("MURREY MATH RANGE FILTERED: Range(",murreyMathRange,") < AtrCalculated(",minAtrCalculated,")" ));
                     //murreyMathRange = minAtrRange;
                  }
                  else{
                     murreyFilterAtr = false;
                  }
               }
               
               mmLines[12]=(finalL-murreyMathRange*2); 
               mmLines[11]=(finalL-murreyMathRange); 
               mmLines[10]=(finalL); 
               mmLines[9]=(finalL+murreyMathRange);
               mmLines[8]=(finalL+2*murreyMathRange);
               mmLines[7]=(finalL+3*murreyMathRange); 
               mmLines[6]=(finalL+4*murreyMathRange); 
               mmLines[5]=(finalL+5*murreyMathRange); 
               mmLines[4]=(finalL+6*murreyMathRange); 
               mmLines[3]=(finalL+7*murreyMathRange);
               mmLines[2]=(finalL+8*murreyMathRange); 
               mmLines[1]=(finalL+9*murreyMathRange); 
               mmLines[0]=(finalL+10*murreyMathRange); 
         
               for(int iMML=0; iMML < murreyLinesSize; iMML++){
                  mmLinesDelta[iMML][0] = mmLines[iMML] * (1 - delta);
                  mmLinesDelta[iMML][1] = mmLines[iMML] * (1 + delta);
               }
               //Print(StringConcatenate("updateMurreyMathValues: murreyMathRange(",murreyMathLinesLastValue[iSymbol][0],",",murreyMathRange,") finalL(",murreyMathLinesLastValue[iSymbol][1],",",finalL,")"));
               lastMatchOpenBuyPos = lastMatchOpenSellPos = lastMatchCloseBuyPos = lastMatchCloseSellPos = -1;
               lastTradedOpenBuyPos = lastTradedOpenSellPos = lastTradedCloseBuyPos = lastTradedCloseSellPos = -1;
               ArrayInitialize(tradedOpenBuy, false);
               ArrayInitialize(tradedOpenSell, false);
               ArrayInitialize(tradedCloseBuy, false);
               ArrayInitialize(tradedCloseSell, false);
   
               updated = true;
            }

         }
         period_check_murrey = iTime_murrey;
         
      }
      return updated;
   };
   
   void confirmOpenBuySignal(){
      if(lastMatchOpenBuyPos >= 0) { 
         lastTradedOpenBuyPos = lastMatchOpenBuyPos; 
         tradedOpenBuy[lastTradedOpenBuyPos] = true; 
      }
      else logMessage(LOG_ERROR,symbol,timeframe,"MurreyMath::confirmOpenBuySignal",StringConcatenate("Invalid lastMatchOpenBuyPos: ",lastMatchOpenBuyPos));  
   }
   
   bool updateOpenBuySignal(){
      openBuySignal = false;
      if(!murreyFilterAtr){
         for(int iMML=0; iMML < murreyLinesSize; iMML++){          
            if(settings.signalOpenBuy[iMML] && !tradedOpenBuy[iMML]){ 
               if((lastTradedOpenBuyPos == -1) || (settings.open_direction == BOTH) ||
                  (settings.open_direction == UPPER && iMML < lastTradedOpenBuyPos) ||
                  (settings.open_direction == LOWER && iMML > lastTradedOpenBuyPos) )
               {
                  if( (signal_closeBar && iClose(symbol, 0, 1) > mmLines[iMML] && iLow(symbol, 0, 1) <= mmLines[iMML]) ||
                      (!signal_closeBar && MarketInfo(symbol,MODE_BID) >= mmLinesDelta[iMML][0] && MarketInfo(symbol,MODE_BID) <= mmLinesDelta[iMML][1]))
                  {   
                     openBuySignal = true; 
                     lastMatchOpenBuyPos = iMML;
                     break;
                  }
               }
            }
         }    
      }
      return openBuySignal;
   }
   bool getOpenBuySignal(){
      return openBuySignal;
   }
   void confirmOpenSellSignal(){
      if(lastMatchOpenSellPos >= 0){
         lastTradedOpenSellPos = lastMatchOpenSellPos;
         tradedOpenSell[lastTradedOpenSellPos] = true;
      }
      else logMessage(LOG_ERROR,symbol,timeframe,"MurreyMath::confirmOpenSellSignal",StringConcatenate("Invalid lastMatchOpenSellPos: ",lastMatchOpenSellPos));
   }
   
   bool updateOpenSellSignal(){
      openSellSignal = false;
      if(!murreyFilterAtr){
         for(int iMML=murreyLinesSize-1; iMML >= 0; iMML--){          
            if(settings.signalOpenSell[iMML] && !tradedOpenSell[iMML]){ 
               if((lastTradedOpenSellPos == -1) || (settings.open_direction == BOTH) ||
                  (settings.open_direction == UPPER && iMML > lastTradedOpenSellPos) ||
                  (settings.open_direction == LOWER && iMML < lastTradedOpenSellPos) )
               {
                  if( (signal_closeBar && iClose(symbol, 0, 1) < mmLines[iMML] && iHigh(symbol, 0, 1) >= mmLines[iMML]) ||
                      (!signal_closeBar && MarketInfo(symbol,MODE_BID) >= mmLinesDelta[iMML][0] && MarketInfo(symbol,MODE_BID) <= mmLinesDelta[iMML][1]))
                  {   
                     openSellSignal = true; 
                     lastMatchOpenSellPos = iMML;
                     break;
                  }
               }
            }
         }    
      }
      return openSellSignal;
   }
   bool getOpenSellSignal(){
      return openSellSignal;
   }
   
   void confirmCloseBuySignal(){
      //Print(StringConcatenate("confirmCloseBuySignal, lastMatchCloseBuyPos: ",lastMatchCloseBuyPos)); 
      if(lastMatchCloseBuyPos >= 0) { 
         lastTradedCloseBuyPos = lastMatchCloseBuyPos; 
         tradedCloseBuy[lastTradedCloseBuyPos] = true; 
         closeBuySignal = false; 
      }
      else logMessage(LOG_ERROR,symbol,timeframe,"MurreyMath::confirmCloseBuySignal",StringConcatenate("Invalid lastMatchCloseBuyPos: ",lastMatchCloseBuyPos));  
   }
   
   bool updateCloseBuySignal(){
      closeBuySignal = false;
      if(!murreyFilterAtr){
         for(int iMML=murreyLinesSize-1; iMML >= 0; iMML--){          
            if(settings.signalCloseBuy[iMML] && !tradedCloseBuy[iMML]){ 
               if((lastTradedCloseBuyPos == -1) || (settings.close_direction == BOTH) ||
                  (settings.close_direction == UPPER && iMML < lastTradedCloseBuyPos) ||
                  (settings.close_direction == LOWER && iMML > lastTradedCloseBuyPos) )
               {
                  if( (signal_closeBar && iClose(symbol, 0, 1) < mmLines[iMML] && iHigh(symbol, 0, 1) >= mmLines[iMML]) ||
                      (!signal_closeBar && MarketInfo(symbol,MODE_BID) >= mmLinesDelta[iMML][0] && MarketInfo(symbol,MODE_BID) <= mmLinesDelta[iMML][1]))
                  {   
                     closeBuySignal = true; 
                     lastMatchCloseBuyPos = iMML;
                     break;
                  }
               }
            }
         }    
      }
      return closeBuySignal;
   }
   bool getCloseBuySignal(){
      return closeBuySignal;
   }
   
   void confirmCloseSellSignal(){
      //Print(StringConcatenate("confirmCloseSellSignal, lastMatchCloseSellPos: ",lastMatchCloseSellPos)); 
      if(lastMatchCloseSellPos >= 0){
         lastTradedCloseSellPos = lastMatchCloseSellPos;
         tradedCloseSell[lastTradedCloseSellPos] = true;
         closeSellSignal = false;
      }
      else logMessage(LOG_ERROR,symbol,timeframe,"MurreyMath::confirmCloseSellSignal",StringConcatenate("Invalid lastMatchCloseSellPos: ",lastMatchCloseSellPos));
   }
   
   bool updateCloseSellSignal(){
      closeSellSignal = false;
      if(!murreyFilterAtr){
         for(int iMML=0; iMML < murreyLinesSize; iMML++){          
            if(settings.signalCloseSell[iMML] && !tradedCloseSell[iMML]){ 
               if((lastTradedCloseSellPos == -1) || (settings.close_direction == BOTH) ||
                  (settings.close_direction == UPPER && iMML > lastTradedCloseSellPos) ||
                  (settings.close_direction == LOWER && iMML < lastTradedCloseSellPos) )
               {
                  if( (signal_closeBar && iClose(symbol, 0, 1) > mmLines[iMML] && iLow(symbol, 0, 1) <= mmLines[iMML]) ||
                      (!signal_closeBar && MarketInfo(symbol,MODE_BID) >= mmLinesDelta[iMML][0] && MarketInfo(symbol,MODE_BID) <= mmLinesDelta[iMML][1]))
                  {   
                     //Print(StringConcatenate("updateCloseSellSignal, iMML: ",iMML)); 
                     closeSellSignal = true; 
                     lastMatchCloseSellPos = iMML;
                     break;
                  }
               }
            }
         }    
      }
      return closeSellSignal;
   }
   bool getCloseSellSignal(){
      return closeSellSignal;
   }
   
   void updateOpenBuyRange(int openBuyRangeId){
      if(openBuyRangeId == 1){
         openBuyRange1 = _checkOpenBuyRange(settings.range1OpenBuy);
      }
      else if(openBuyRangeId == 2){
         openBuyRange2 = _checkOpenBuyRange(settings.range2OpenBuy);
      }
      else if(openBuyRangeId == 3){
         openBuyRange3 = _checkOpenBuyRange(settings.range3OpenBuy);
      }
   }
   bool getOpenBuyRange1(){ return openBuyRange1; }
   bool getOpenBuyRange2(){ return openBuyRange2; }
   bool getOpenBuyRange3(){ return openBuyRange3; }
   
   void updateOpenSellRange(int openSellRangeId){
      if(openSellRangeId == 1){
         openSellRange1 = _checkOpenSellRange(settings.range1OpenSell);
      }
      else if(openSellRangeId == 2){
         openSellRange2 = _checkOpenSellRange(settings.range2OpenSell);
      }
      else if(openSellRangeId == 3){
         openSellRange3 = _checkOpenSellRange(settings.range3OpenSell);
      }
   }
   bool getOpenSellRange1(){ return openSellRange1; }
   bool getOpenSellRange2(){ return openSellRange2; }
   bool getOpenSellRange3(){ return openSellRange3; }
   
   private:
   bool _checkOpenBuyRange(bool &rangeOpenBuy[]){
      bool inRanged = false;
      if(!murreyFilterAtr){
         double bid = MarketInfo(symbol,MODE_BID);
         for(int iMML=0; iMML < murreyRangeSize; iMML++){
            if(rangeOpenBuy[iMML] && bid <= mmLines[iMML] && bid >= mmLines[iMML+1]){
               inRanged = true; 
               //openBuySignalByMurreyRange[iSymbol] = true; 
               break;
            }
         }
         if(!inRanged && rangeOpenBuy[0] && bid > mmLines[0]) inRanged = true; 
         if(!inRanged && rangeOpenBuy[murreyRangeSize-1] && bid < mmLines[murreyRangeSize]) inRanged = true; 
      }   
      return inRanged;
   } 
   bool _checkOpenSellRange(bool &rangeOpenSell[]){
      bool inRanged = false;  
      if(!murreyFilterAtr){
         double bid = MarketInfo(symbol,MODE_BID);
         for(int iMML=0; iMML < murreyRangeSize; iMML++){
            if(rangeOpenSell[iMML] && bid <= mmLines[iMML] && bid >= mmLines[iMML+1]){
               inRanged = true; 
               break;
            }
         }
         if(!inRanged && rangeOpenSell[0] && bid > mmLines[0]) inRanged = true; 
         if(!inRanged && rangeOpenSell[murreyRangeSize-1] && bid < mmLines[murreyRangeSize]) inRanged = true;
      }
      return inRanged;
   }
   
   
   /*
   
   if(useMurreyMathLinesRange){
      openBuySignalByMurreyRange[iSymbol] = false; openSellSignalByMurreyRange[iSymbol] = false; 
      if(!murreyFilterAtr){
         for(int iMML=0; iMML < murreyRangeSize; iMML++){
            if(murreyRangeOpenBuy[iMML] && BID <= murreyMathLines[iSymbol][iMML] && BID >= murreyMathLines[iSymbol][iMML+1]){
               openBuySignalByMurreyRange[iSymbol] = true; 
               break;
            }
         }
         if(!openBuySignalByMurreyRange[iSymbol] && murreyRangeOpenBuy[0] && BID > murreyMathLines[iSymbol][0]) openBuySignalByMurreyRange[iSymbol] = true; 
         if(!openBuySignalByMurreyRange[iSymbol] && murreyRangeOpenBuy[murreyRangeSize-1] && BID < murreyMathLines[iSymbol][murreyRangeSize]) openBuySignalByMurreyRange[iSymbol] = true; 
         
         for(int iMML=0; iMML < murreyRangeSize; iMML++){
            if(murreyRangeOpenSell[iMML] && BID <= murreyMathLines[iSymbol][iMML] && BID >= murreyMathLines[iSymbol][iMML+1]){
               openSellSignalByMurreyRange[iSymbol] = true; 
               break;
            }
         }
         if(!openSellSignalByMurreyRange[iSymbol] && murreyRangeOpenSell[0] && BID > murreyMathLines[iSymbol][0]) openSellSignalByMurreyRange[iSymbol] = true; 
         if(!openSellSignalByMurreyRange[iSymbol] && murreyRangeOpenSell[murreyRangeSize-1] && BID < murreyMathLines[iSymbol][murreyRangeSize]) openBuySignalByMurreyRange[iSymbol] = true;
      }
   }*/
     
   
   
};