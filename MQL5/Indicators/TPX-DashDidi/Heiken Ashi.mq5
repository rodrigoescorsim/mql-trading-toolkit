//+------------------------------------------------------------------+
//|                                                  Heiken Ashi.mq5 |
//|                             Copyright 2000-2025, MetaQuotes Ltd. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2005-2025, MetaQuotes Ltd."
#property link        "https://www.mql5.com"
#property description "Heiken Ashi Indicator for MQL5"
#property version     "1.00"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

//--- plot Heiken Ashi
#property indicator_label1  "Heiken Ashi"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input color BearColor = clrRed;    // Bear candlestick color
input color BullColor = clrWhite;  // Bull candlestick color

//--- indicator buffers
double HAOpen[];
double HAHigh[];
double HALow[];
double HAClose[];
double HAColors[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, HAOpen, INDICATOR_DATA);
   SetIndexBuffer(1, HAHigh, INDICATOR_DATA);
   SetIndexBuffer(2, HALow, INDICATOR_DATA);
   SetIndexBuffer(3, HAClose, INDICATOR_DATA);
   SetIndexBuffer(4, HAColors, INDICATOR_COLOR_INDEX);
   
   //--- set colors
   PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, BearColor);   // Bear candle (red)
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, BullColor);   // Bull candle (white)
   
   //--- set drawing begin
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 1);
   
   //--- set indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Heiken Ashi");
   
   //--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Heiken Ashi calculation function                                 |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int start;
   
   //--- check for minimum bars
   if(rates_total <= 1)
      return(0);
   
   //--- determine starting position
   if(prev_calculated == 0)
   {
      //--- set first candle
      HAOpen[0] = open[0];
      HAHigh[0] = high[0];
      HALow[0] = low[0];
      HAClose[0] = close[0];
      //--- set color for first candle
      HAColors[0] = (HAClose[0] >= HAOpen[0]) ? 1.0 : 0.0;  // 1 = Bull (white), 0 = Bear (red)
      start = 1;
   }
   else
   {
      start = prev_calculated - 1;
   }
   
   //--- main calculation loop
   for(int i = start; i < rates_total; i++)
   {
      //--- calculate Heiken Ashi values
      HAOpen[i] = (HAOpen[i-1] + HAClose[i-1]) / 2.0;
      HAClose[i] = (open[i] + high[i] + low[i] + close[i]) / 4.0;
      HAHigh[i] = MathMax(high[i], MathMax(HAOpen[i], HAClose[i]));
      HALow[i] = MathMin(low[i], MathMin(HAOpen[i], HAClose[i]));
      
      //--- set color based on candle direction
      HAColors[i] = (HAClose[i] >= HAOpen[i]) ? 1.0 : 0.0;  // 1 = Bull (white), 0 = Bear (red)
   }
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+