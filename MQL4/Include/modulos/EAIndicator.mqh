//+------------------------------------------------------------------+
//|                                                  EAIndicator.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
#include <modulos/EATimeframes.mqh>
#include <modulos/EACore.mqh>
#include <mql4-lib/Collection/Vector.mqh>
//+------------------------------------------------------------------+
enum SIGNAL_TYPE{ OR, AND, NOT };
enum CLOSE_TYPE{ CLOSE_ONE, CLOSE_TF_MINOR, CLOSE_ALL };
//+------------------------------------------------------------------+
class EAIndicator{
protected:
    EATimeframes* timeframes;
    EACore* core;
    string name;
    bool buySignal[][TF_COUNT], sellSignal[][TF_COUNT];
    bool closeBuy[][TF_COUNT], closeSell[][TF_COUNT];
    bool symbolUpdated[], setupUpdated[][TF_COUNT];
    bool isDrawable[];
    SIGNAL_TYPE openSignalType;
    SIGNAL_TYPE closeSignalType;
    CLOSE_TYPE closeType;
    bool firstUpdate;
    bool tickUpdate;
    int shift_begin;
    int data_depth;
public:
  virtual void UpdateData(int iSym, int iSet) = 0;
  virtual void UpdateSignal(int iSym, int iSet) = 0;
  virtual void DrawIndicator(int iSym, int iSet){}

  virtual string GetInfoBySymbol(int iSym){
     string buyInfo="", sellInfo="", closeBuyInfo="", closeSellInfo="";
     for(int iSet=0; iSet<TF_COUNT; iSet++){
       if(timeframes.InUse(iSet)){
         buyInfo += StringConcatenate((int)buySignal[iSym][iSet],",");
         sellInfo += StringConcatenate((int)sellSignal[iSym][iSet],",");
         closeBuyInfo += StringConcatenate((int)closeBuy[iSym][iSet],",");
         closeSellInfo += StringConcatenate((int)closeSell[iSym][iSet],",");
       }
     }
     if(StringLen(buyInfo) > 0) buyInfo = StringSubstr(buyInfo,0,StringLen(buyInfo)-1);
     if(StringLen(sellInfo) > 0) sellInfo = StringSubstr(sellInfo,0,StringLen(sellInfo)-1);
     if(StringLen(closeBuyInfo) > 0) closeBuyInfo = StringSubstr(closeBuyInfo,0,StringLen(closeBuyInfo)-1);
     if(StringLen(closeSellInfo) > 0) closeSellInfo = StringSubstr(closeSellInfo,0,StringLen(closeSellInfo)-1);
     return StringConcatenate(name,": Buy(",buyInfo,"),CloseBuy:(",closeBuyInfo,"),Sell(",sellInfo,"),CloseSell(",closeSellInfo,")");
  }

  virtual void UpdateDataBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
      if(!timeframes.InUse(iSet)) continue;
      if(tickUpdate || timeframes.IsUpdated(iSym,iSet)){
        UpdateData(iSym, iSet);
      }
      if(isDrawable[iSym] && timeframes.IsUpdated(iSym,iSet)){
        DrawIndicator(iSym, iSet);
      }
    }
  }
  virtual void UpdateSignalBySymbol(int iSym){
    for(int iSet=0; iSet < TF_COUNT; iSet++){
      if(!timeframes.InUse(iSet)) continue;
      if(tickUpdate || timeframes.IsUpdated(iSym,iSet)){
        UpdateSignal(iSym, iSet);
      }
    }
  }
  virtual void UpdateAllData(){
    for(int iSym=0; iSym<core.getSymbolCount(); iSym++){
        UpdateDataBySymbol(iSym);
    }
  }
  virtual void UpdateAllSignal(){
    for(int iSym=0; iSym<core.getSymbolCount(); iSym++){
        UpdateSignalBySymbol(iSym);
    }
  }
  bool BuySignal(int iSym, int iSet){
    return buySignal[iSym][iSet] && !closeBuy[iSym][iSet];
  }
  bool SellSignal(int iSym, int iSet){
    return sellSignal[iSym][iSet] && !closeSell[iSym][iSet];
  }
  bool CloseBuySignal(int iSym, int iSet){
    return closeBuy[iSym][iSet];
  }
  bool CloseSellSignal(int iSym, int iSet){
    return closeSell[iSym][iSet];
  }
  SIGNAL_TYPE GetOpenSignalType() { return openSignalType; }
  SIGNAL_TYPE GetCloseSignalType() { return closeSignalType; }
  CLOSE_TYPE GetCloseType() { return closeType; }

  void SetOpenSignalType(SIGNAL_TYPE signalType) { openSignalType = signalType; }
  void SetCloseSignalType(SIGNAL_TYPE signalType) { closeSignalType = signalType; }
  void SetCloseType(CLOSE_TYPE cType) { closeType = cType; }

  int GetShiftBegin() { return shift_begin; }
  void SetShiftBegin(int shift) { shift_begin = shift; }

  int GetDataDepth() { return data_depth; }
  void SetDataDepth(int depth) { data_depth = depth; }

  string GetName() { return name; }

  EAIndicator(EACore* _core, EATimeframes* _timeframes, string _name){
    timeframes = _timeframes;
    core = _core;
    name = _name;
    firstUpdate = true;
    tickUpdate = false;
    shift_begin = 1;
    data_depth = 1;
    openSignalType = AND;
    closeSignalType = OR;
    closeType = CLOSE_TF_MINOR;
    ArrayResize(buySignal, core.getSymbolCount());
    ArrayResize(sellSignal, core.getSymbolCount());
    ArrayResize(closeBuy, core.getSymbolCount());
    ArrayResize(closeSell, core.getSymbolCount());
    ArrayResize(symbolUpdated, core.getSymbolCount());
    ArrayResize(setupUpdated, core.getSymbolCount());
    ArrayResize(isDrawable, core.getSymbolCount());
    ArrayInitialize(symbolUpdated, false);
    ArrayInitialize(setupUpdated, false);
    for(int iSym=0; iSym<core.getSymbolCount(); iSym++){
        isDrawable[iSym] = core.getSymbol(iSym) == Symbol();
    }
    ResetAllSignals();
  }

  void ResetSignal(int iSym, int iSet){
    buySignal[iSym][iSet] = false;
    sellSignal[iSym][iSet] = false;
    closeBuy[iSym][iSet] = false;
    closeSell[iSym][iSet] = false;
  }
  void ResetSignal(int iSym){
    for(int iSet=0; iSet<TF_COUNT; iSet++){
       buySignal[iSym][iSet] = false;
       sellSignal[iSym][iSet] = false;
       closeBuy[iSym][iSet] = false;
       closeSell[iSym][iSet] = false;
    }
  }
  void ResetAllSignals(){
    ArrayInitialize(buySignal, false);
    ArrayInitialize(sellSignal, false);
    ArrayInitialize(closeBuy, false);
    ArrayInitialize(closeSell, false);
  }

 protected:
  void DrawChannel(string dir, double pr1, color clr=clrYellow){
   if (Bars<2) return;
   string obj_name=_Symbol+" "+dir+TimeToStr(Time[0]);
   string obj_name_prev=_Symbol+" "+dir+TimeToStr(Time[1]);

   if(ObjectFind(obj_name) < 0){
      double pr2 = pr1;
      if(ObjectFind(obj_name_prev) == 0) pr2 = ObjectGetDouble(0,obj_name_prev,OBJPROP_PRICE,1);

      ObjectCreate(obj_name, OBJ_TREND,0,Time[1],pr2,Time[0],pr1);
      ObjectSet(obj_name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0,obj_name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(0,obj_name,OBJPROP_WIDTH,1);
      //ObjectSet(obj_name,OBJPROP_BACK,true);
      ObjectSet(obj_name,OBJPROP_SELECTABLE,false);
   }
}

};
//+------------------------------------------------------------------+
