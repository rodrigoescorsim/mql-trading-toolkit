//+------------------------------------------------------------------+
//|                                                      TPX - ADX Color.mq5 |
//|                                          Converted from MQL4 to MQL5 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_color1  Red         // neutral
#property indicator_color2  Silver
#property indicator_color3  Silver
#property indicator_color4  DodgerBlue  // UP
#property indicator_color5  Yellow      // DOWN

//---- input parameters
input int   ADXPeriod     = 8;
input int   colour_level  = 20;

//---- indicator buffers
double ADXBuffer[];
double ADXUpBuffer[];
double ADXDownBuffer[];
double PlusDiBuffer[];
double MinusDiBuffer[];

//---- indicator handle
int    adxHandle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- create handle for built-in ADX indicator
   adxHandle = iADX(_Symbol,_Period,ADXPeriod);
   if(adxHandle==INVALID_HANDLE)
     {
      Print("Failed to create ADX handle, error ",GetLastError());
      return(INIT_FAILED);
     }

//---- set indicator buffers
   SetIndexBuffer(0,ADXBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,PlusDiBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MinusDiBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ADXUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ADXDownBuffer,INDICATOR_DATA);

   ArraySetAsSeries(ADXBuffer,true);
   ArraySetAsSeries(PlusDiBuffer,true);
   ArraySetAsSeries(MinusDiBuffer,true);
   ArraySetAsSeries(ADXUpBuffer,true);
   ArraySetAsSeries(ADXDownBuffer,true);

   //---- plot settings and labels
   // empty value constant
   double empty=EMPTY_VALUE;
   for(int k=0;k<5;k++)
     {
      PlotIndexSetDouble(k,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      PlotIndexSetInteger(k,PLOT_DRAW_BEGIN,ADXPeriod);
      PlotIndexSetInteger(k,PLOT_DRAW_TYPE,DRAW_LINE);
     }

   //---- plot labels
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("ADX(%d)",ADXPeriod));

   PlotIndexSetString(0,PLOT_LABEL,"ADX");
   PlotIndexSetString(1,PLOT_LABEL,"+DI");
   PlotIndexSetString(2,PLOT_LABEL,"-DI");
   PlotIndexSetString(3,PLOT_LABEL,"ADXUp");
   PlotIndexSetString(4,PLOT_LABEL,"ADXDown");

//---- style for ADX neutral line
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(3,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(4,PLOT_LINE_WIDTH,2);

//---- styles for +DI and -DI (dotted line)
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_DOT);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_DOT);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(adxHandle!=INVALID_HANDLE)
      IndicatorRelease(adxHandle);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[]   ,
                const double   &open[]   ,
                const double   &high[]   ,
                const double   &low[]    ,
                const double   &close[]  ,
                const long     &tick_volume[],
                const long     &volume[] ,
                const int      &spread[] )
  {
//---- check for sufficient bars
   if(rates_total<ADXPeriod+2)
      return(0);

   //--- create temporary arrays to copy ADX data
   static double adxArr[];
   static double plusArr[];
   static double minusArr[];

   ArraySetAsSeries(adxArr,true);
   ArraySetAsSeries(plusArr,true);
   ArraySetAsSeries(minusArr,true);

   int copied1 = CopyBuffer(adxHandle,0,0,rates_total,adxArr);
   int copied2 = CopyBuffer(adxHandle,1,0,rates_total,plusArr);
   int copied3 = CopyBuffer(adxHandle,2,0,rates_total,minusArr);
   if(copied1<0 || copied2<0 || copied3<0)
     {
      Print("CopyBuffer error ",GetLastError());
      return(prev_calculated);
     }

   int start = prev_calculated>0 ? prev_calculated-1 : 0;

   for(int i=start; i<rates_total && !IsStopped(); i++)
     {
      double adx_0   = adxArr[i];
      double adx_1   = (i+1<rates_total) ? adxArr[i+1]   : adxArr[i];
      double dmip_0  = plusArr[i];
      double dmip_1  = (i+1<rates_total) ? plusArr[i+1]  : plusArr[i];
      double dmim_0  = minusArr[i];
      double dmim_1  = (i+1<rates_total) ? minusArr[i+1] : minusArr[i];

      // default values
      ADXBuffer[i]     = adx_0;        // always draw neutral line
      ADXUpBuffer[i]   = EMPTY_VALUE;
      ADXDownBuffer[i] = EMPTY_VALUE;

      if(adx_0>adx_1 && dmip_0>dmim_0 && adx_0>=colour_level)
        {
         ADXUpBuffer[i] = adx_0;      // overlay with blue when trend up
        }
      else if(adx_0>adx_1 && dmip_0<dmim_0 && adx_0>=colour_level)
        {
         ADXDownBuffer[i] = adx_0;    // overlay with yellow when trend down
        }
      //--- always store +DI and -DI
      PlusDiBuffer[i]  = dmip_0;
      MinusDiBuffer[i] = dmim_0;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
