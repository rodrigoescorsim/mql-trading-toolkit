//+------------------------------------------------------------------+
//|                                                  EAIndicator.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EAIndicator.mqh>
#include <mql4-lib/Collection/Vector.mqh>

//+------------------------------------------------------------------+
class EAIndicatorsMatch{
protected:
    Vector<EAIndicator*> indicators;

public:
  EAIndicatorsMatch(){
  }
  void AddIndicator(EAIndicator* indicator){
    indicators.add(indicator);
  }
  void RemoveIndicator(EAIndicator* indicator){
    indicators.remove(indicator);
  }
  void UpdateIndicatorsAllData(){
    foreachv(EAIndicator*,indicator,indicators){
      indicator.UpdateAllData();
    }
  }
  void UpdateIndicatorsDataBySymbol(int iSym){
    foreachv(EAIndicator*,indicator,indicators){
      indicator.UpdateDataBySymbol(iSym);
    }
  }
  void UpdateIndicatorsAllSignal(){
    foreachv(EAIndicator*,indicator,indicators){
      indicator.UpdateAllSignal();
    }
  }
  void UpdateIndicatorsSignalBySymbol(int iSym){
    foreachv(EAIndicator*,indicator,indicators){
      indicator.UpdateSignalBySymbol(iSym);
    }
  }
  void DealocateIndicators(){
    foreachv(EAIndicator*,indicator,indicators){
      if(indicator != NULL) delete(indicator);
    }
    indicators.clear();
  }
  //+------------------------------------------------------------------+
  string getInfoBySymbol(int iSym){
    string symbolInfo = "";
    foreachv(EAIndicator*,indicator,indicators){
      symbolInfo += indicator.GetInfoBySymbol(iSym) + NL;
    }
    return symbolInfo;
  }
  //+------------------------------------------------------------------+
  bool MatchBuySignal(int iSym, int iSet){
    if(indicators.size() == 0) return false;
    bool buy = true;
    bool buy_or = false; int or_count = 0;
    bool buy_and = true; int and_count = 0;
    foreachv(EAIndicator*,indicator,indicators){
      if(indicator.GetOpenSignalType() == AND){
        buy_and = buy_and && indicator.BuySignal(iSym, iSet);
        and_count++;
      }
      else if(indicator.GetOpenSignalType() == OR){
        buy_or = buy_or || indicator.BuySignal(iSym, iSet);
        or_count++;
      }
    }
    if(and_count > 0)
      buy = buy && buy_and;
    if(or_count > 0)
      buy = buy || buy_or;
    return buy;
  }
  //+------------------------------------------------------------------+
  bool MatchSellSignal(int iSym, int iSet){
    if(indicators.size() == 0) return false;
    bool sell = true;
    bool sell_or = false; int or_count = 0;
    bool sell_and = true; int and_count = 0;
    foreachv(EAIndicator*,indicator,indicators){
      if(indicator.GetOpenSignalType() == AND){
        sell_and = sell_and && indicator.SellSignal(iSym, iSet);
        and_count++;
      }
      else if(indicator.GetOpenSignalType() == OR){
        sell_or = sell_or || indicator.SellSignal(iSym, iSet);
        or_count++;
      }
    }
    if(and_count > 0)
      sell = sell && sell_and;
    if(or_count > 0)
      sell = sell || sell_or;
    return sell;
  }
  //+------------------------------------------------------------------+
  bool MatchCloseBuy(int iSym, int iSet){
    if(indicators.size() == 0) return false;
    bool close = true;
    bool close_or = false; int or_count = 0;
    bool close_and = true; int and_count = 0;
    foreachv(EAIndicator*,indicator,indicators){
      if(indicator.GetCloseSignalType() == AND){
        close_and = close_and && indicator.CloseBuySignal(iSym, iSet);
        and_count++;
      }
      else if(indicator.GetCloseSignalType() == OR){
        close_or = close_or || indicator.CloseBuySignal(iSym, iSet);
        or_count++;
      }
    }
    if(and_count > 0)
      close = close && close_and;
    if(or_count > 0)
      close = close || close_or;
    //Print(StringConcatenate("MatchCloseBuy: ", close, ", iSym :", iSym, ", iSet: ", iSet));
    return close;
  }
  //+------------------------------------------------------------------+
  bool MatchCloseSell(int iSym, int iSet){
    if(indicators.size() == 0) return false;
    bool close = true;
    bool close_or = false; int or_count = 0;
    bool close_and = true; int and_count = 0;
    foreachv(EAIndicator*,indicator,indicators){
      if(indicator.GetCloseSignalType() == AND){
        close_and = close_and && indicator.CloseSellSignal(iSym, iSet);
        and_count++;
      }
      else if(indicator.GetCloseSignalType() == OR){
        close_or = close_or || indicator.CloseSellSignal(iSym, iSet);
        or_count++;
      }
    }
    if(and_count > 0)
      close = close && close_and;
    if(or_count > 0)
      close = close || close_or;
    //Print(StringConcatenate("MatchCloseSell: ", close, ", iSym :", iSym, ", iSet: ", iSet));
    return close;
  }
  //+------------------------------------------------------------------+
};
//+------------------------------------------------------------------+
