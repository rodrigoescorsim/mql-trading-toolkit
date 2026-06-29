//+------------------------------------------------------------------+
//|                                                    EAInd_PVA.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
//+------------------------------------------------------------------+
extern string  cog1_info                = "===========================================";
extern string  cog2_info                = "========== CenterOfGravity SETUP ==========";
extern string  cog3_info                = "===========================================";
extern bool    useCoG                   = false;
extern int     cog_bars_back            = 125;
extern int     cog_m                    = 2;
extern int     cog_i                    = 0;
extern double  cog_kstd                 = 2.0;
extern bool    cog_close_center         = true;
extern bool    cog_use_sq_minor_bands   = true;
extern bool    cog_use_min_size         = true;
extern double  cog_size_min             = 8.0;
extern bool    cog_use_slope            = true;
extern double  cog_slope_min            = 0.0;
extern double  cog_slope_trend_max      = 0.0;
extern bool    cog_use_size_slope_line  = true;
extern bool    cog_use_limit_max_size   = false;
extern double  cog_size_max             = 13.0;
extern double  cog_slope_line_max       = 1.0;
extern double  cog_slope_max_open       = 1.2;
extern double  cog_slope_max_close      = 1.4;
extern SIGNAL_TYPE cog_openSignalType   = AND;
extern SIGNAL_TYPE cog_closeSignalType  = NOT;
//+------------------------------------------------------------------+

struct cog_struct{
  double highSq;
  double lowSq;
  double highStd;
  double lowStd;
};
//+------------------------------------------------------------------+
class EACoG : public EAIndicator
{
  public:
   double highSq[][TF_COUNT][2];
   double highStd[][TF_COUNT][2];
   double lowSq[][TF_COUNT][2];
   double lowStd[][TF_COUNT][2];
   double cogCenter[][TF_COUNT][2];
   double highSqDistance[][TF_COUNT];
   double highStdDistance[][TF_COUNT];
   double lowSqDistance[][TF_COUNT];
   double lowStdDistance[][TF_COUNT];
   double cogCenterDistanceBid[][TF_COUNT];
   double cogCenterDistanceAsk[][TF_COUNT];
   double cogSlopeValue[][TF_COUNT];
   double cogSqSize[][TF_COUNT];
   double cogStdSize[][TF_COUNT];
  private:
   double fx[];
   double ai[10,10], b[10], x[10], sx[20];
   double sum;
   int    p, n, f;
   double qq, mm, tt;
   int    ii, jj, kk, ll, nn;
   double sq, std;
   double line_add, line_mult;
  //+------------------------------------------------------------------+
  public:
  EACoG(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "EACoG")
  {
     data_depth = 2;
     openSignalType = cog_openSignalType;
     closeSignalType = cog_closeSignalType;
     nn = cog_m + 1;
     ArrayResize(highSq, core.getSymbolCount()); ArrayInitialize(highSq, 0);
     ArrayResize(highStd, core.getSymbolCount()); ArrayInitialize(highStd, 0);
     ArrayResize(lowSq, core.getSymbolCount()); ArrayInitialize(lowSq, 0);
     ArrayResize(lowStd, core.getSymbolCount()); ArrayInitialize(lowStd, 0);
     ArrayResize(cogCenter, core.getSymbolCount()); ArrayInitialize(cogCenter, 0);
     ArrayResize(highSqDistance, core.getSymbolCount()); ArrayInitialize(highSqDistance, 0);
     ArrayResize(highStdDistance, core.getSymbolCount()); ArrayInitialize(highStdDistance, 0);
     ArrayResize(lowSqDistance, core.getSymbolCount()); ArrayInitialize(lowSqDistance, 0);
     ArrayResize(lowStdDistance, core.getSymbolCount()); ArrayInitialize(lowStdDistance, 0);
     ArrayResize(cogCenterDistanceBid, core.getSymbolCount()); ArrayInitialize(cogCenterDistanceBid, 0);
     ArrayResize(cogCenterDistanceAsk, core.getSymbolCount()); ArrayInitialize(cogCenterDistanceAsk, 0);
     ArrayResize(cogSlopeValue, core.getSymbolCount()); ArrayInitialize(cogSlopeValue, 0);
     ArrayResize(cogSqSize, core.getSymbolCount()); ArrayInitialize(cogSqSize, 0);
     ArrayResize(cogStdSize, core.getSymbolCount()); ArrayInitialize(cogStdSize, 0);
     ArrayResize(fx, cog_bars_back+10); ArrayInitialize(fx, 0);
     if(cog_use_size_slope_line){
       cog_use_min_size = true;
       cog_use_slope = true;
       line_add = B(cog_size_min, cog_slope_min, cog_size_max, cog_slope_line_max);
       line_mult = A(cog_size_min, cog_slope_min, cog_size_max, cog_slope_line_max);
       Print("EACOG Indicatorc -> line_add: "+DoubleToString(line_add,2)+" - line_mult: "+DoubleToString(line_mult,2));
     }
  }
     //+------------------------------------------------------------------+
   void DrawIndicator(int iSym, int iSet) override{
      DrawChannel("cogCenter_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), cogCenter[iSym][iSet][0], clrWhite);
      if(cog_use_sq_minor_bands){
         DrawChannel("cogHighSq_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), highSq[iSym][iSet][0], clrMistyRose);
         DrawChannel("cogLowSq_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), lowSq[iSym][iSet][0], clrMistyRose);
      }
      DrawChannel("cogHighStd_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), highStd[iSym][iSet][0], clrLightPink);
      DrawChannel("cogLowStd_"+IntegerToString(iSet)+"_"+IntegerToString(iSym), lowStd[iSym][iSet][0], clrLightPink);
   }
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
    string cogSlopeInfo="";
    string cogStdBuyDistInfo="", cogSqBuyDistInfo="";
    string cogStdSellDistInfo="", cogSqSellDistInfo="", cogCenterDistanceInfo="";
    string cogStdSizeInfo="", cogSqSizeInfo="";
    int digits = (int) MarketInfo(core.getSymbol(iSym),MODE_DIGITS);

    for(int iSet=0; iSet<TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
        sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
        closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
        closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");
        cogSlopeInfo += StringConcatenate(DoubleToString(cogSlopeValue[iSym][iSet],2),",");

        cogStdBuyDistInfo += StringConcatenate(lowStdDistance[iSym][iSet],",");
        cogSqBuyDistInfo += StringConcatenate(lowSqDistance[iSym][iSet],",");
        cogStdSellDistInfo += StringConcatenate(highStdDistance[iSym][iSet],",");
        cogSqSellDistInfo += StringConcatenate(highSqDistance[iSym][iSet],",");
        cogCenterDistanceInfo += StringConcatenate(cogCenterDistanceBid[iSym][iSet],",");

        cogStdSizeInfo += StringConcatenate(DoubleToString(cogStdSize[iSym][iSet],2),",");
        cogSqSizeInfo += StringConcatenate(DoubleToString(cogSqSize[iSym][iSet],2),",");
      }
    }
    if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
    if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);
    if(StringLen(closeBuyInfo) > 0) closeBuyInfo = StringSubstr(closeBuyInfo,0,StringLen(closeBuyInfo)-1);
    if(StringLen(closeSellInfo) > 0) closeSellInfo = StringSubstr(closeSellInfo,0,StringLen(closeSellInfo)-1);
    if(StringLen(cogSlopeInfo) > 0) cogSlopeInfo = StringSubstr(cogSlopeInfo,0,StringLen(cogSlopeInfo)-1);
    if(StringLen(cogStdBuyDistInfo) > 0) cogStdBuyDistInfo = StringSubstr(cogStdBuyDistInfo,0,StringLen(cogStdBuyDistInfo)-1);
    if(StringLen(cogSqBuyDistInfo) > 0) cogSqBuyDistInfo = StringSubstr(cogSqBuyDistInfo,0,StringLen(cogSqBuyDistInfo)-1);
    if(StringLen(cogStdSellDistInfo) > 0) cogStdSellDistInfo = StringSubstr(cogStdSellDistInfo,0,StringLen(cogStdSellDistInfo)-1);
    if(StringLen(cogSqSellDistInfo) > 0) cogSqSellDistInfo = StringSubstr(cogSqSellDistInfo,0,StringLen(cogSqSellDistInfo)-1);
    if(StringLen(cogCenterDistanceInfo) > 0) cogCenterDistanceInfo = StringSubstr(cogCenterDistanceInfo,0,StringLen(cogCenterDistanceInfo)-1);
    if(StringLen(cogStdSizeInfo) > 0) cogStdSizeInfo = StringSubstr(cogStdSizeInfo,0,StringLen(cogStdSizeInfo)-1);
    if(StringLen(cogSqSizeInfo) > 0) cogSqSizeInfo = StringSubstr(cogSqSizeInfo,0,StringLen(cogSqSizeInfo)-1);

    return StringConcatenate(name,": Buy(",buyInfo,"),CloseBuy:(",closeBuyInfo,"),Sell(",sellInfo,"),CloseSell(",closeSellInfo,")",NL,
                             name,": SqBuyDist(",cogSqBuyDistInfo,"),StdBuyDist(",cogStdBuyDistInfo,")", NL,
                             name,": SqSellDist(",cogSqSellDistInfo,"),StdSellDist(",cogStdSellDistInfo,")", NL,
                             name,": centerDist(",cogCenterDistanceInfo,"),Slope(",cogSlopeInfo,")",
                             ": SqSize(",cogSqSizeInfo,"),StdSize(",cogStdSizeInfo,")");
  }
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
     updateCoGvalues(iSym, iSet);

     double atr = timeframes.getAtrSlow(iSym,iSet);
     if(atr == 0){
       Print( StringConcatenate("WARNING ATR == 0 EACoG::UpdateData - ",core.getSymbol(iSym)," ",timeframes.PosToStr(iSet)) );
       return;
     }
     cogSlopeValue[iSym][iSet] = ((fx[0] - fx[1]) / (timeframes.getAtrSlow(iSym,iSet) * 0.1)) ;
     cogSqSize[iSym][iSet] = (highSq[iSym][iSet][0] - lowSq[iSym][iSet][0]) / timeframes.getAtrSlow(iSym, iSet);
     cogStdSize[iSym][iSet] = (highStd[iSym][iSet][0] - lowStd[iSym][iSet][0]) / timeframes.getAtrSlow(iSym, iSet);
  }
  //+------------------------------------------------------------------+
  void UpdateSignalBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
      if(timeframes.InUse(iSet)){
        UpdateSignal(iSym, iSet);
      }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;

    double bid = MarketInfo(core.getSymbol(iSym),MODE_BID);
    double ask = MarketInfo(core.getSymbol(iSym),MODE_ASK);
    double point = MarketInfo(core.getSymbol(iSym),MODE_POINT);
    if(point == 0){
       Print(StringConcatenate("WARNING point == 0 EACoG::UpdateSignal - " ,core.getSymbol(iSym),timeframes.ValueToStr(iSet)));
       return;
     }

    cogCenterDistanceBid[iSym][iSet] = (int)((bid - cogCenter[iSym][iSet][0]) / point);
    cogCenterDistanceAsk[iSym][iSet] = (int)((ask - cogCenter[iSym][iSet][0]) / point);

    highSqDistance[iSym][iSet] = (int)((highSq[iSym][iSet][0] - bid) / point);
    highStdDistance[iSym][iSet] = (int)((highStd[iSym][iSet][0] - bid) / point);

    lowSqDistance[iSym][iSet] = (int)((bid - lowSq[iSym][iSet][0]) / point);
    lowStdDistance[iSym][iSet] = (int)((bid - lowStd[iSym][iSet][0]) / point);

    double high_distance = highStdDistance[iSym][iSet];
    double low_distance = lowStdDistance[iSym][iSet];
    double cog_size = cogStdSize[iSym][iSet];
    double cog_slope_limit = cog_slope_min;
    bool sell = true, buy = true;

    if(cog_use_sq_minor_bands){
      high_distance = highSqDistance[iSym][iSet];
      low_distance = lowSqDistance[iSym][iSet];
      cog_size = cogSqSize[iSym][iSet];
    }
    if(cog_use_size_slope_line && cog_size > cog_size_min){
      cog_slope_limit = (cog_size * line_mult) + line_add;
      if(cog_use_limit_max_size && cog_size > cog_size_max)
         buy = sell = false;
    }
    if(cog_use_min_size){
      buy = buy && (cog_size > cog_size_min);
      sell = sell && (cog_size > cog_size_min);
    }
    if(cog_use_slope){
      buy = buy && !(cogSlopeValue[iSym][iSet] < -cog_slope_limit);
      sell = sell && !(cogSlopeValue[iSym][iSet] > cog_slope_limit);
    }
    if(cog_slope_max_open > 0){
      if(cogSlopeValue[iSym][iSet] > cog_slope_max_open){
         sell = false;
      }
      if(cogSlopeValue[iSym][iSet] < -cog_slope_max_open){
         buy = false;
      }
    }
    if(cog_slope_trend_max > 0){
      if(cogSlopeValue[iSym][iSet] < -cog_slope_trend_max){
         sell = false;
      }
      if(cogSlopeValue[iSym][iSet] > cog_slope_trend_max){
         buy = false;
      }
    }

    buySignal[iSym][iSet] = buy && (low_distance <= 0);
    sellSignal[iSym][iSet] = sell && (high_distance <= 0);

    if(cog_close_center){
      if(cogCenterDistanceBid[iSym][iSet] >= 0 && high_distance > 0){
         closeBuy[iSym][iSet] = true;
       }
      if(cogCenterDistanceAsk[iSym][iSet] <= 0 && low_distance > 0){
         closeSell[iSym][iSet] = true;
      }
    }
    else{
        if(highStdDistance[iSym][iSet] <= 0){
         closeBuy[iSym][iSet] = true;
       }
       if(lowStdDistance[iSym][iSet] <= 0){
         closeSell[iSym][iSet] = true;
       }
       if(cog_slope_max_close > 0){
         if(cogSlopeValue[iSym][iSet] > cog_slope_max_close){
            closeSell[iSym][iSet] = true;
         }
         if(cogSlopeValue[iSym][iSet] < -cog_slope_max_close){
            closeBuy[iSym][iSet] = true;
         }
       }
    }
  }
  //+------------------------------------------------------------------+
   double B(double x_, double y_, double x0_, double y0_){ //encontra e retorna o coeficiente linear (o valor de
   	return ((y_-y0_)*((-x0_/(x_-x0_))))+y0_;
   }
  //+------------------------------------------------------------------+
   double A(double x_, double y_, double x0_, double y0_){ //encontra e retorna o coeficiente angular (o valor de A)
   	return (y_-y0_)/(x_-x0_);
   }
  //+------------------------------------------------------------------+
  void updateCoGvalues(int iSym, int iSet)
  {
   string _symbol = core.getSymbol(iSym);
   int _timeframe = timeframes.Value(iSet);
   int mi;
   p = cog_bars_back;
   sx[1] = p + 1;

//----------------------sx-------------------------------------------------------------------
   for(mi = 1; mi <= nn * 2 - 2; mi++)
   {
      sum = 0;
      for(n = cog_i; n <= cog_i + p; n++)
      {
         sum += MathPow(n, mi);
      }
      sx[mi + 1] = sum;
   }
//----------------------syx-----------
   for(mi = 1; mi <= nn; mi++)
   {
      sum = 0.00000;
      for(n = cog_i; n <= cog_i + p; n++)
      {
         if(mi == 1)
            sum += iClose(_symbol, _timeframe, n);
         else
            sum += iClose(_symbol, _timeframe, n) * MathPow(n, mi - 1);
      }
      b[mi] = sum;
   }
//===============Matrix=======================================================================================================
   for(jj = 1; jj <= nn; jj++)
   {
      for(ii = 1; ii <= nn; ii++)
      {
         kk = ii + jj - 1;
         ai[ii, jj] = sx[kk];
      }
   }
//===============Gauss========================================================================================================
   for(kk = 1; kk <= nn - 1; kk++)
   {
      ll = 0; mm = 0;
      for(ii = kk; ii <= nn; ii++)
      {
         if(MathAbs(ai[ii, kk]) > mm)
         {
            mm = MathAbs(ai[ii, kk]);
            ll = ii;
         }
      }
      if(ll == 0)
         return;

      if(ll != kk)
      {
         for(jj = 1; jj <= nn; jj++)
         {
            tt = ai[kk, jj];
            ai[kk, jj] = ai[ll, jj];
            ai[ll, jj] = tt;
         }
         tt = b[kk]; b[kk] = b[ll]; b[ll] = tt;
      }
      for(ii = kk + 1; ii <= nn; ii++)
      {
         qq = ai[ii, kk] / ai[kk, kk];
         for(jj = 1; jj <= nn; jj++)
         {
            if(jj == kk)
               ai[ii, jj] = 0;
            else
               ai[ii, jj] = ai[ii, jj] - qq * ai[kk, jj];
         }
         b[ii] = b[ii] - qq * b[kk];
      }
   }
   x[nn] = b[nn] / ai[nn, nn];
   for(ii = nn - 1; ii >= 1; ii--)
   {
      tt = 0;
      for(jj = 1; jj <= nn - ii; jj++)
      {
         tt = tt + ai[ii, ii + jj] * x[ii + jj];
         x[ii] = (1 / ai[ii, ii]) * (b[ii] - tt);
      }
   }
//===========================================================================================================================
   for(n = cog_i; n <= cog_i + p; n++)
   {
      sum = 0;
      for(kk = 1; kk <= cog_m; kk++)
      {
         sum += x[kk + 1] * MathPow(n, kk);
      }
      fx[n] = x[1] + sum;
   }
//-----------------------------------Std-----------------------------------------------------------------------------------
   sq = 0.0;
   for(n = cog_i; n <= cog_i + p; n++)
   {
      sq += MathPow(iClose(_symbol, _timeframe, n) - fx[n], 2);
   }
   sq = MathSqrt(sq / (p + 1)) * cog_kstd;
   std = iStdDev(_symbol, _timeframe, p, MODE_SMA, 0, PRICE_CLOSE, cog_i) * cog_kstd;
   for(n = cog_i; n < cog_i + data_depth; n++)
   {
      cogCenter[iSym][iSet][n] = fx[n];
      highSq[iSym][iSet][n] = fx[n] + sq;
      lowSq[iSym][iSet][n] = fx[n] - sq;
      highStd[iSym][iSet][n] = fx[n] + std;
      lowStd[iSym][iSet][n] = fx[n] - std;
   }
  }

};
