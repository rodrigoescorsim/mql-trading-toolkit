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
extern string  margin1_info                 = "==================================";
extern string  margin2_info                 = "========== MARGIN SETUP ==========";
extern string  margin3_info                 = "==================================";
extern bool    useMarginController          = false;
extern double  marginLevelMin               = 120;
extern double  marginPerSymbol              = 10;
extern double  marginPerCurrency            = 30;
extern SIGNAL_TYPE margin_openSignalType    = AND;
extern SIGNAL_TYPE margin_closeSignalType   = NOT;

//+------------------------------------------------------------------+
class EAMarginControl : public EAIndicator
{
  private:
  double lotsBySymbol[], buyLotsBySymbol[], sellLotsBySymbol[];
  double lotsByCurrency[], buyLotsByCurrency[], sellLotsByCurrency[];
  double marginBySymbol[], marginByCurrency[];
  double lotsSizeBySymbol[], lotsSizeByCurrency[];
  double lotsTotal, lotsHedgeTotal, marginTotal;
  double marginLevel;

  public:
  EAMarginControl(EACore* _core, EATimeframes* _timeframes)
  : EAIndicator(_core, _timeframes, "MarginCtrl")
  {
    tickUpdate = true;
    openSignalType = margin_openSignalType;
    closeSignalType = margin_closeSignalType;
    ArrayResize(lotsBySymbol, core.getSymbolCount());
    ArrayResize(marginBySymbol, core.getSymbolCount());
    ArrayResize(buyLotsBySymbol, core.getSymbolCount());
    ArrayResize(sellLotsBySymbol, core.getSymbolCount());
    ArrayResize(lotsSizeBySymbol, core.getSymbolCount());
    ArrayResize(lotsByCurrency, core.getSymbolCount());
    ArrayResize(marginByCurrency, core.getSymbolCount());
  }
  //+------------------------------------------------------------------+
  void DrawIndicator(int iSym, int iSet){}
  //+------------------------------------------------------------------+
  void UpdateData(int iSym, int iSet)
  {
  }
  //+------------------------------------------------------------------+
  void UpdateSignal(int iSym, int iSet)
  {
    buySignal[iSym][iSet] = sellSignal[iSym][iSet] = true;
    closeBuy[iSym][iSet] = closeSell[iSym][iSet] = false;

    if(marginPerSymbol > 0)
    {
       if(marginBySymbol[iSym] > marginPerSymbol){
         buySignal[iSym][iSet] = false;
       }
       else if(marginBySymbol[iSym] < -marginPerSymbol){
         sellSignal[iSym][iSet] = false;
       }
    }
    if(marginPerCurrency > 0)
    {
      string rawSymbol = core.getRawSymbol(iSym);
      string currency1 = StringSubstr(rawSymbol, 0,3);
      string currency2 = StringSubstr(rawSymbol, 3,3);
      int iCurrency1 = core.hashCurrencyPos[currency1];
      int iCurrency2 = core.hashCurrencyPos[currency2];
       if( marginByCurrency[iCurrency1] > marginPerCurrency || marginByCurrency[iCurrency2] < -marginPerCurrency ) {
          buySignal[iSym][iSet] = false; closeSell[iSym][iSet] = true;
       }
       else if( marginByCurrency[iCurrency2] > marginPerCurrency || marginByCurrency[iCurrency1] < -marginPerCurrency ){
          sellSignal[iSym][iSet] = false; closeBuy[iSym][iSet] = true;
       }
    }
  }
  //+------------------------------------------------------------------+
  void UpdateAllData()
  {
    ArrayInitialize(lotsBySymbol, 0);
    ArrayInitialize(marginBySymbol, 0);
    ArrayInitialize(buyLotsBySymbol, 0);
    ArrayInitialize(sellLotsBySymbol, 0);
    ArrayInitialize(lotsSizeBySymbol, 0);
    ArrayInitialize(lotsByCurrency, 0);
    ArrayInitialize(marginByCurrency, 0);

    string _currency1, _currency2, _symbol;
    int pos1, pos2;
    double fullEquity = AccountEquity() * AccountLeverage();

    foreachm(string,key,Order*,order,core.hashOpenOrders)
    {
        if(order != NULL){
          //logMessage(LOG_DEBUG, brokerSymbols[order.iSymbol], timeframe, "updateMarginController", StringConcatenate("Synchronizing memory: order removed from memory, ticket: ",order.ticket));
          if(order.orderType == OP_BUY){
             buyLotsBySymbol[order.iSymbol] += order.lots;
          }
          else if(order.orderType == OP_SELL){
             sellLotsBySymbol[order.iSymbol] += order.lots;
          }
        }
    }
    marginTotal = 0.0; lotsTotal = 0.0; lotsHedgeTotal = 0.0;

    for(int iSym=0; iSym < core.getSymbolCount() ; iSym++){
       lotsBySymbol[iSym] = buyLotsBySymbol[iSym] - sellLotsBySymbol[iSym];
       lotsSizeBySymbol[iSym] = LotSize * lotsBySymbol[iSym];
       marginBySymbol[iSym] = (lotsSizeBySymbol[iSym]/fullEquity)*100;

       if(marginPerCurrency){
          _symbol = core.rawSymbols[iSym];
          _currency1 = StringSubstr(_symbol, 0,3);
          _currency2 = StringSubstr(_symbol, 3,3);
          pos1 = core.hashCurrencyPos[_currency1];
          pos2 = core.hashCurrencyPos[_currency2];
          lotsByCurrency[pos1] += lotsBySymbol[iSym];
          lotsByCurrency[pos2] -= lotsBySymbol[iSym];
          marginByCurrency[pos1] += marginBySymbol[iSym];
          marginByCurrency[pos2] -= marginBySymbol[iSym];
        }
        marginTotal += MathAbs(marginBySymbol[iSym]);
        lotsTotal += buyLotsBySymbol[iSym] + sellLotsBySymbol[iSym];
        lotsHedgeTotal += MathAbs(lotsBySymbol[iSym]);
    }
  }
  //+------------------------------------------------------------------+
  string GetInfoBySymbol(int iSym)
  {
    double accountMargin = AccountMargin();
    if(accountMargin > 0){
       marginLevel = (AccountEquity() / accountMargin) * 100.0;
    }
    else { marginLevel = -1; }

     string _info  = StringConcatenate("Margin Details: levelMin(",marginLevelMin,") bySymbol(", marginPerSymbol,") byCurrency(",marginPerCurrency,")",NL );
     _info += StringConcatenate("MarginLevel(",DoubleToString(marginLevel,1),") MarginUsed(",DoubleToString(marginTotal,1),") totalLots(",lotsTotal,") hedgeLots(",lotsHedgeTotal,")",NL);
     if(marginPerCurrency > 0)
     {
        _info += StringConcatenate("Currencies: ");
        for(int i=0; i < core.getSymbolCount(); i++){
          _info += StringConcatenate(core.currencies[i],"(",DoubleToString(marginByCurrency[i],2),") ");
        }
        _info += NL;
     }
     if(marginPerSymbol > 0)
     {
        _info += StringConcatenate("Symbols locked: ");
        for(int i=0; i < core.getSymbolCount(); i++){
          if(MathAbs(marginBySymbol[i]) > marginPerSymbol){
            _info += StringConcatenate(core.rawSymbols[i],"(",DoubleToString(marginBySymbol[i],1),") ");
          }
        }
        _info += NL;
     }
     return _info;
  }
  //+------------------------------------------------------------------+
};
//+------------------------------------------------------------------+
