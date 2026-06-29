//+------------------------------------------------------------------+
//|                                                         CCFp.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict

double usdPairs_maValue[][2];

void initCCFp(string &currencies[]){

}

void CCFp()
{
   double EURUSD_Fast;
   double EURUSD_Slow;
   double GBPUSD_Fast;
   double GBPUSD_Slow;
   double AUDUSD_Fast;
   double AUDUSD_Slow;
   double NZDUSD_Fast;
   double NZDUSD_Slow;
   double USDCAD_Fast;
   double USDCAD_Slow;
   double USDCHF_Fast;
   double USDCHF_Slow;
   double USDJPY_Fast;
   double USDJPY_Slow;

      if (EUR) {
         EURUSD_Fast = ma("EURUSD", Fast, MA_Method, Price, i);
         EURUSD_Slow = ma("EURUSD", Slow, MA_Method, Price, i);
         if (!EURUSD_Fast || !EURUSD_Slow) break;
      }
      if (GBP) {
         GBPUSD_Fast = ma("GBPUSD", Fast, MA_Method, Price, i);
         GBPUSD_Slow = ma("GBPUSD", Slow, MA_Method, Price, i);
         if (!GBPUSD_Fast || !GBPUSD_Slow) break;
      }
      if (AUD) {
         AUDUSD_Fast = ma("AUDUSD", Fast, MA_Method, Price, i);
         AUDUSD_Slow = ma("AUDUSD", Slow, MA_Method, Price, i);
         if (!AUDUSD_Fast || !AUDUSD_Slow) break;
      }
      if (NZD) {
         NZDUSD_Fast = ma("NZDUSD", Fast, MA_Method, Price, i);
         NZDUSD_Slow = ma("NZDUSD", Slow, MA_Method, Price, i);
         if (!NZDUSD_Fast || !NZDUSD_Slow) break;
      }
      if (CAD) {
         USDCAD_Fast = ma("USDCAD", Fast, MA_Method, Price, i);
         USDCAD_Slow = ma("USDCAD", Slow, MA_Method, Price, i);
         if (!USDCAD_Fast || !USDCAD_Slow) break;
      }
      if (CHF) {
         USDCHF_Fast = ma("USDCHF", Fast, MA_Method, Price, i);
         USDCHF_Slow = ma("USDCHF", Slow, MA_Method, Price, i);
         if (!USDCHF_Fast || !USDCHF_Slow) break;
      }
      if (JPY) {
         USDJPY_Fast = ma("USDJPY", Fast, MA_Method, Price, i);
         USDJPY_Slow = ma("USDJPY", Slow, MA_Method, Price, i);
         if (!USDJPY_Fast || !USDJPY_Slow) break;
      }

      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "USD", 0) != -1) || (ShowOnlyPairOnChart == FALSE && USD == TRUE)) {
         arrUSD[i] = 0;
         if (EUR) arrUSD[i] += (EURUSD_Slow / EURUSD_Fast - 1.0);
         if (GBP) arrUSD[i] += (GBPUSD_Slow / GBPUSD_Fast - 1.0);
         if (AUD) arrUSD[i] += (AUDUSD_Slow / AUDUSD_Fast - 1.0);
         if (NZD) arrUSD[i] += (NZDUSD_Slow / NZDUSD_Fast - 1.0);
         if (CHF) arrUSD[i] += (USDCHF_Fast / USDCHF_Slow - 1.0);
         if (CAD) arrUSD[i] += (USDCAD_Fast / USDCAD_Slow - 1.0);
         if (JPY) arrUSD[i] += (USDJPY_Fast / USDJPY_Slow - 1.0);
         arrUSD[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "EUR", 0) != -1) || (ShowOnlyPairOnChart == FALSE && EUR == TRUE)) {
         arrEUR[i] = 0;
         if (USD) arrEUR[i] += (EURUSD_Fast / EURUSD_Slow - 1.0);
         if (GBP) arrEUR[i] += (EURUSD_Fast / GBPUSD_Fast / (EURUSD_Slow / GBPUSD_Slow) - 1.0);
         if (AUD) arrEUR[i] += (EURUSD_Fast / AUDUSD_Fast / (EURUSD_Slow / AUDUSD_Slow) - 1.0);
         if (NZD) arrEUR[i] += (EURUSD_Fast / NZDUSD_Fast / (EURUSD_Slow / NZDUSD_Slow) - 1.0);
         if (CHF) arrEUR[i] += (EURUSD_Fast * USDCHF_Fast / (EURUSD_Slow * USDCHF_Slow) - 1.0);
         if (CAD) arrEUR[i] += (EURUSD_Fast * USDCAD_Fast / (EURUSD_Slow * USDCAD_Slow) - 1.0);
         if (JPY) arrEUR[i] += (EURUSD_Fast * USDJPY_Fast / (EURUSD_Slow * USDJPY_Slow) - 1.0);
         arrEUR[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "GBP", 0) != -1) || (ShowOnlyPairOnChart == FALSE && GBP == TRUE)) {
         arrGBP[i] = 0;
         if (USD) arrGBP[i] += (GBPUSD_Fast / GBPUSD_Slow - 1.0);
         if (EUR) arrGBP[i] += (EURUSD_Slow / GBPUSD_Slow / (EURUSD_Fast / GBPUSD_Fast) - 1.0);
         if (AUD) arrGBP[i] += (GBPUSD_Fast / AUDUSD_Fast / (GBPUSD_Slow / AUDUSD_Slow) - 1.0);
         if (NZD) arrGBP[i] += (GBPUSD_Fast / NZDUSD_Fast / (GBPUSD_Slow / NZDUSD_Slow) - 1.0);
         if (CHF) arrGBP[i] += (GBPUSD_Fast * USDCHF_Fast / (GBPUSD_Slow * USDCHF_Slow) - 1.0);
         if (CAD) arrGBP[i] += (GBPUSD_Fast * USDCAD_Fast / (GBPUSD_Slow * USDCAD_Slow) - 1.0);
         if (JPY) arrGBP[i] += (GBPUSD_Fast * USDJPY_Fast / (GBPUSD_Slow * USDJPY_Slow) - 1.0);
         arrGBP[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "AUD", 0) != -1) || (ShowOnlyPairOnChart == FALSE && AUD == TRUE)) {
         arrAUD[i] = 0;
         if (USD) arrAUD[i] += (AUDUSD_Fast / AUDUSD_Slow - 1.0);
         if (EUR) arrAUD[i] += (EURUSD_Slow / AUDUSD_Slow / (EURUSD_Fast / AUDUSD_Fast) - 1.0);
         if (GBP) arrAUD[i] += (GBPUSD_Slow / AUDUSD_Slow / (GBPUSD_Fast / AUDUSD_Fast) - 1.0);
         if (NZD) arrAUD[i] += (AUDUSD_Fast / NZDUSD_Fast / (AUDUSD_Slow / NZDUSD_Slow) - 1.0);
         if (CHF) arrAUD[i] += (AUDUSD_Fast * USDCHF_Fast / (AUDUSD_Slow * USDCHF_Slow) - 1.0);
         if (CAD) arrAUD[i] += (AUDUSD_Fast * USDCAD_Fast / (AUDUSD_Slow * USDCAD_Slow) - 1.0);
         if (JPY) arrAUD[i] += (AUDUSD_Fast * USDJPY_Fast / (AUDUSD_Slow * USDJPY_Slow) - 1.0);
         arrAUD[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "NZD", 0) != -1) || (ShowOnlyPairOnChart == FALSE && NZD == TRUE)) {
         arrNZD[i] = 0;
         if (USD) arrNZD[i] += (NZDUSD_Fast / NZDUSD_Slow - 1.0);
         if (EUR) arrNZD[i] += (EURUSD_Slow / NZDUSD_Slow / (EURUSD_Fast / NZDUSD_Fast) - 1.0);
         if (GBP) arrNZD[i] += (GBPUSD_Slow / NZDUSD_Slow / (GBPUSD_Fast / NZDUSD_Fast) - 1.0);
         if (AUD) arrNZD[i] += (AUDUSD_Slow / NZDUSD_Slow / (AUDUSD_Fast / NZDUSD_Fast) - 1.0);
         if (CHF) arrNZD[i] += (NZDUSD_Fast * USDCHF_Fast / (NZDUSD_Slow * USDCHF_Slow) - 1.0);
         if (CAD) arrNZD[i] += (NZDUSD_Fast * USDCAD_Fast / (NZDUSD_Slow * USDCAD_Slow) - 1.0);
         if (JPY) arrNZD[i] += (NZDUSD_Fast * USDJPY_Fast / (NZDUSD_Slow * USDJPY_Slow) - 1.0);
         arrNZD[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "CAD", 0) != -1) || (ShowOnlyPairOnChart == FALSE && CAD == TRUE)) {
         arrCAD[i] = 0;
         if (USD) arrCAD[i] += (USDCAD_Slow / USDCAD_Fast - 1.0);
         if (EUR) arrCAD[i] += (EURUSD_Slow * USDCAD_Slow / (EURUSD_Fast * USDCAD_Fast) - 1.0);
         if (GBP) arrCAD[i] += (GBPUSD_Slow * USDCAD_Slow / (GBPUSD_Fast * USDCAD_Fast) - 1.0);
         if (AUD) arrCAD[i] += (AUDUSD_Slow * USDCAD_Slow / (AUDUSD_Fast * USDCAD_Fast) - 1.0);
         if (NZD) arrCAD[i] += (NZDUSD_Slow * USDCAD_Slow / (NZDUSD_Fast * USDCAD_Fast) - 1.0);
         if (CHF) arrCAD[i] += (USDCHF_Fast / USDCAD_Fast / (USDCHF_Slow / USDCAD_Slow) - 1.0);
         if (JPY) arrCAD[i] += (USDJPY_Fast / USDCAD_Fast / (USDJPY_Slow / USDCAD_Slow) - 1.0);
         arrCAD[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "CHF", 0) != -1) || (ShowOnlyPairOnChart == FALSE && CHF == TRUE)) {
         arrCHF[i] = 0;
         if (USD) arrCHF[i] += (USDCHF_Slow / USDCHF_Fast - 1.0);
         if (EUR) arrCHF[i] += (EURUSD_Slow * USDCHF_Slow / (EURUSD_Fast * USDCHF_Fast) - 1.0);
         if (GBP) arrCHF[i] += (GBPUSD_Slow * USDCHF_Slow / (GBPUSD_Fast * USDCHF_Fast) - 1.0);
         if (AUD) arrCHF[i] += (AUDUSD_Slow * USDCHF_Slow / (AUDUSD_Fast * USDCHF_Fast) - 1.0);
         if (NZD) arrCHF[i] += (NZDUSD_Slow * USDCHF_Slow / (NZDUSD_Fast * USDCHF_Fast) - 1.0);
         if (CAD) arrCHF[i] += (USDCHF_Slow / USDCAD_Slow / (USDCHF_Fast / USDCAD_Fast) - 1.0);
         if (JPY) arrCHF[i] += (USDJPY_Fast / USDCHF_Fast / (USDJPY_Slow / USDCHF_Slow) - 1.0);
         arrCHF[i] *= 1000.0;
      }
      if ((ShowOnlyPairOnChart == TRUE && StringFind(Symbol(), "JPY", 0) != -1) || (ShowOnlyPairOnChart == FALSE && JPY == TRUE)) {
         arrJPY[i] = 0;
         if (USD) arrJPY[i] += (USDJPY_Slow / USDJPY_Fast - 1.0);
         if (EUR) arrJPY[i] += (EURUSD_Slow * USDJPY_Slow / (EURUSD_Fast * USDJPY_Fast) - 1.0);
         if (GBP) arrJPY[i] += (GBPUSD_Slow * USDJPY_Slow / (GBPUSD_Fast * USDJPY_Fast) - 1.0);
         if (AUD) arrJPY[i] += (AUDUSD_Slow * USDJPY_Slow / (AUDUSD_Slow * USDJPY_Fast) - 1.0);
         if (NZD) arrJPY[i] += (NZDUSD_Slow * USDJPY_Slow / (NZDUSD_Fast * USDJPY_Fast) - 1.0);
         if (CAD) arrJPY[i] += (USDJPY_Slow / USDCAD_Slow / (USDJPY_Fast / USDCAD_Slow) - 1.0);
         if (CHF) arrJPY[i] += (USDJPY_Slow / USDCHF_Slow / (USDJPY_Slow / USDCHF_Fast) - 1.0);
         arrJPY[i] *= 1000.0;
      }

}

double ma(string sym, int per, int Mode, int Price, int i) {
   double res = 0;
   int k = 4;   // 1; Brandon
   int ma_shift = 0;
   int tf = 0;
   string mySym;
   
  mySym = symbol_prefix + sym + symbol_suffix;
   
   switch (Period()) {
   case PERIOD_M1:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 5;
   case PERIOD_M5:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 3;
   case PERIOD_M15:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 2;
   case PERIOD_M30:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 2;
   case PERIOD_H1:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 4;
   case PERIOD_H4:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 6;
   case PERIOD_D1:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 5;  // 4; Brandon
   case PERIOD_W1:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
      k += 4;
   case PERIOD_MN1:
      res += iMA(mySym, tf, per * k, ma_shift, Mode, Price, i);
   }
   // Comment("per*k  ",per*k);
   // Comment("k>MN ",k," res ",res);   
   return (res);
}
