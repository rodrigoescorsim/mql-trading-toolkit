//+------------------------------------------------------------------+
//|                                               TPX - Força ADX.mq5|
//|                       Converted from original MQL4 version       |
//|           Shows ADX strength across multiple timeframes          |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_plots 0   // purely graphical
#property version   "1.00"

//---- input parameters
input int   ADXPeriod        = 8;
input int   SpreadThreshold  = 6;
input bool  Show_M1_ADX      = true;
input bool  Show_M5_ADX      = true;
input bool  Show_M15_ADX     = true;
input bool  Show_M30_ADX     = true;
input bool  Show_H1_ADX      = true;
input bool  Show_H4_ADX      = true;
input bool  Show_D1_ADX      = true;
input bool  Show_W1_ADX      = true;
input bool  Show_MN1_ADX     = true;

//---- ADX handles (MAIN/PLUSDI/MINUSDI share a single handle)
int handle_M1  = INVALID_HANDLE;
int handle_M5  = INVALID_HANDLE;
int handle_M15 = INVALID_HANDLE;
int handle_M30 = INVALID_HANDLE;
int handle_H1  = INVALID_HANDLE;
int handle_H4  = INVALID_HANDLE;
int handle_D1  = INVALID_HANDLE;
int handle_W1  = INVALID_HANDLE;
int handle_MN1 = INVALID_HANDLE;

//--- indicator short name (set during OnInit)
string ind_name = "";

//---- helper struct
struct TFData
  {
   string  name;      // text prefix
   ENUM_TIMEFRAMES tf;
   int     handle;
   bool    enabled;
  };
TFData tfs[];

//+------------------------------------------------------------------+
//| Create ADX handle helper                                         |
//+------------------------------------------------------------------+
int createADXHandle(ENUM_TIMEFRAMES timeframe)
  {
   int h=iADX(_Symbol,timeframe,ADXPeriod);
   if(h==INVALID_HANDLE)
      Print("Failed to create ADX handle for TF ",timeframe, " error ",GetLastError());
   return h;
  }

//+------------------------------------------------------------------+
//| Delete all ADX handles                                           |
//+------------------------------------------------------------------+
void releaseHandles()
  {
   for(int i=0;i<ArraySize(tfs);i++)
     {
      if(tfs[i].handle!=INVALID_HANDLE)
         IndicatorRelease(tfs[i].handle);
     }
  }

//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int OnInit()
  {
   ind_name = StringFormat("ToR 1.02 (%s)",_Symbol);
   IndicatorSetString(INDICATOR_SHORTNAME,ind_name);

   ArrayResize(tfs,9);

   tfs[0].name="1 Min:";  tfs[0].tf=PERIOD_M1;  tfs[0].handle=handle_M1;  tfs[0].enabled=Show_M1_ADX;
   tfs[1].name="5 Min:";  tfs[1].tf=PERIOD_M5;  tfs[1].handle=handle_M5;  tfs[1].enabled=Show_M5_ADX;
   tfs[2].name="15 Min:"; tfs[2].tf=PERIOD_M15; tfs[2].handle=handle_M15; tfs[2].enabled=Show_M15_ADX;
   tfs[3].name="30 Min:"; tfs[3].tf=PERIOD_M30; tfs[3].handle=handle_M30; tfs[3].enabled=Show_M30_ADX;
   tfs[4].name="1 Hr:";   tfs[4].tf=PERIOD_H1;  tfs[4].handle=handle_H1;  tfs[4].enabled=Show_H1_ADX;
   tfs[5].name="4 Hr:";   tfs[5].tf=PERIOD_H4;  tfs[5].handle=handle_H4;  tfs[5].enabled=Show_H4_ADX;
   tfs[6].name="1 Day:";  tfs[6].tf=PERIOD_D1;  tfs[6].handle=handle_D1;  tfs[6].enabled=Show_D1_ADX;
   tfs[7].name="1 Wk:";   tfs[7].tf=PERIOD_W1;  tfs[7].handle=handle_W1;  tfs[7].enabled=Show_W1_ADX;
   tfs[8].name="1 Mn:";   tfs[8].tf=PERIOD_MN1; tfs[8].handle=handle_MN1; tfs[8].enabled=Show_MN1_ADX;

   // create handles
   for(int i=0;i<ArraySize(tfs);i++)
     {
      if(tfs[i].enabled)
         tfs[i].handle = createADXHandle(tfs[i].tf);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // remove labels
   // delete all label objects created by this indicator
   ObjectsDeleteAll(0,"",OBJ_LABEL);
   releaseHandles();
  }
//+------------------------------------------------------------------+
//| Copy single value helper                                         |
//+------------------------------------------------------------------+
bool getADXValues(int handle,double &main,double &plus,double &minus)
   {
    // try to read the current bar first
    double tmpMain[1],tmpPlus[1],tmpMinus[1];
    if(CopyBuffer(handle,0,0,1,tmpMain)==1 &&
       CopyBuffer(handle,1,0,1,tmpPlus)==1 &&
       CopyBuffer(handle,2,0,1,tmpMinus)==1)
      {
       main  = tmpMain[0];
       plus  = tmpPlus[0];
       minus = tmpMinus[0];
       return true;
      }
    // if not available yet (indicator not calculated), fallback to previous closed bar
    if(CopyBuffer(handle,0,1,1,tmpMain)==1 &&
       CopyBuffer(handle,1,1,1,tmpPlus)==1 &&
       CopyBuffer(handle,2,1,1,tmpMinus)==1)
      {
       main  = tmpMain[0];
       plus  = tmpPlus[0];
       minus = tmpMinus[0];
       return true;
      }
    return false; // still not ready
   }

//+------------------------------------------------------------------+
//| Determine color and arrow based on ADX/DI values                 |
//+------------------------------------------------------------------+
void colorArrow(double adx,double plus,double minus,color &clr,string &arrow)
  {
   // default
   clr=clrNONE; arrow="";
   if(adx==0) return;

   // arrow selection
   if(adx<23)
     {
      arrow="h"; // ranging
     }
   else if(adx<28)
     {
      arrow = (plus>minus)?"ì":"î"; // weak trend up/down
     }
   else
     {
      arrow = (plus>minus)?"é":"ê"; // strong trend up/down
     }

   // color selection
   if(adx<15)
      clr=White;
   else
      clr = (plus>minus)?Aqua:Yellow;
  }

//+------------------------------------------------------------------+
//| Main calculation loop                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // number of bars in history
                const int prev_calculated,  // bars already processed
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   
   static int win_idx = -1;
   if(win_idx==-1)
     {
      int tmp = ChartWindowFind(0,ind_name);
      if(tmp<0)
         return(rates_total);
      win_idx = tmp;
      if(win_idx<0)
         return(rates_total);  // wait until subwindow is available
     }

   int yShift = 2;   // vertical offset
   int xShift = 120; // starting horizontal offset
   int step   = 130; // spacing between groups

   for(int i=0,j=0;i<ArraySize(tfs);i++)
     {
      if(!tfs[i].enabled) continue;
      double adx,plus,minus;
      if(!getADXValues(tfs[i].handle,adx,plus,minus))
         continue;
      color clr; string arrow;
      colorArrow(adx,plus,minus,clr,arrow);
      string val = StringFormat("ADX %.2f",adx);

      // prefix label key identifiers
      string prefix = StringFormat("ToR102-%d",i);

       // timeframe text label
       string tagTF = prefix+"-tf";
       if(ObjectFind(0,tagTF)<0)
          ObjectCreate(0,tagTF,OBJ_LABEL,win_idx,0,0);
        
       ObjectSetString(0,tagTF,OBJPROP_TEXT,tfs[i].name);
       ObjectSetInteger(0,tagTF,OBJPROP_FONTSIZE,9);
       ObjectSetString(0,tagTF,OBJPROP_FONT,"Arial");
       ObjectSetInteger(0,tagTF,OBJPROP_COLOR,LightSteelBlue);
       ObjectSetInteger(0,tagTF,OBJPROP_CORNER,0);
       ObjectSetInteger(0,tagTF,OBJPROP_XDISTANCE,xShift + step*j);
       ObjectSetInteger(0,tagTF,OBJPROP_YDISTANCE,yShift);

       // value label
       string tagVal = prefix+"-val";
       if(ObjectFind(0,tagVal)<0)
          ObjectCreate(0,tagVal,OBJ_LABEL,win_idx,0,0);
        
       ObjectSetString(0,tagVal,OBJPROP_TEXT,val);
       ObjectSetInteger(0,tagVal,OBJPROP_FONTSIZE,9);
       ObjectSetString(0,tagVal,OBJPROP_FONT,"Arial");
       ObjectSetInteger(0,tagVal,OBJPROP_COLOR,clr);
       ObjectSetInteger(0,tagVal,OBJPROP_CORNER,0);
       ObjectSetInteger(0,tagVal,OBJPROP_XDISTANCE,xShift + step*j + 42);
       ObjectSetInteger(0,tagVal,OBJPROP_YDISTANCE,yShift);

       // arrow label
       string tagArr = prefix+"-arr";
       if(ObjectFind(0,tagArr)<0)
          ObjectCreate(0,tagArr,OBJ_LABEL,win_idx,0,0);
        
       ObjectSetString(0,tagArr,OBJPROP_TEXT,arrow);
       ObjectSetInteger(0,tagArr,OBJPROP_FONTSIZE,9);
       ObjectSetString(0,tagArr,OBJPROP_FONT,"Wingdings");
       ObjectSetInteger(0,tagArr,OBJPROP_COLOR,clr);
       ObjectSetInteger(0,tagArr,OBJPROP_CORNER,0);
       ObjectSetInteger(0,tagArr,OBJPROP_XDISTANCE,xShift + step*j + 105);
       ObjectSetInteger(0,tagArr,OBJPROP_YDISTANCE,yShift);
      j++;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
