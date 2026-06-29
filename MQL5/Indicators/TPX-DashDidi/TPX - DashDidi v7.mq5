//+------------------------------------------------------------------+
//|                                            TPX - DashDidi (Wind) |
//|                                    Converted from MQL4 to MQL5  |
//|                               Original author: Rodrigo Escorsim |
//|                       Conversion assistant: Cascade AI (2025)  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property version   "1.00"
#property strict
#property indicator_plots 0   // sem plots gráficos

//+------------------------------------------------------------------+
//| INPUT PARAMETERS (unchanged)                                     |
//+------------------------------------------------------------------+
input string  lb_1 = ""; // ------------- SETUP -------------
input string Ativos1 = "AUDUSD,AUDCAD,AUDCHF,AUDJPY,AUDNZD,CADCHF,CADJPY,CHFJPY,EURUSD,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD";
input string Ativos2 = "GBPUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,NZDUSD,NZDCAD,NZDCHF,NZDJPY,USDCAD,USDCHF,USDJPY";
input string Ativos3 = "XAUUSD,US30";
input string Timeframes = "H1,H4,D1,W1";
input int     didiCurtaLength      = 3; // DIDI média curta
input int     didiMediaLength      = 8; // DIDI média central 
input int     didiLongaLength      = 20; // DIDI média longa
input int     didiMethod           = 0;  // DIDI Method: 0 - SMA, 1 - EMA, 2 - SMMA, 3 - LWMA
input ENUM_APPLIED_PRICE didiPrice            = PRICE_CLOSE;  // DIDI Applied price: 0 - Close, 1 - Open, 2 - High, 3 - Low, 4 - Median, 5 - Typical, 6 - Weighted  
input int     didiShift            = 1; // DIDI shift
input int     adx_period           = 8;
input int     adx_shift            = 1;

// Parâmetros do filtro HeikenAshi
input string HeikenAshiPath = "DashDidi\\Heiken Ashi";
input int    HeikenAshiShift = 1;
input ENUM_TIMEFRAMES HeikenAshiTimeframe = PERIOD_D1;
input bool   HabilitarFiltroHeikenAshi = true;

input string NewChartTemplate = "DashDidi"; // Template utilizado na abertura de gráficos
input bool   useTimeToUpdate = false; // Habilitar atualização por tempo
input int    secondsUpdate = 5; // Intervalo de atualização (segundos)
//+------------------------------------------------------------------+
input string               lb_2              = "";             // ----------- NOTIFICATION -----------
input bool                 HabilitarAlertaCurta = true;       // Habilitar alerta de curta (linha azul)
input bool                 HabilitarAlertaAgulhada = true;    // Habilitar alerta de agulhada
input bool                 HabilitarAlertaPontoFalso = true;  // Habilitar alerta de ponto falso
input bool                 UseAlert          = true;           // Habilitar  janela Alert
input bool                 UseNotification   = true;           // Habilitar Notification 
input bool                 UseSound          = true;           // Habilitar Sound
input string               SoundName         = "alert2.wav";   // Sound Name

//+------------------------------------------------------------------+
input string lb_3 = ""; // ------------- LAYOUT -------------
input color color_window_background   = clrBlack;
input color color_subwindow_background = clrBlack;
input color color_timeframe_text      = clrWhite;
input color color_timeframe_background = C'88,88,88';
 
input color color_didi_text      = clrBlack;
input color color_didi_longa = clrYellow;
input color color_didi_curta = clrAqua;

input color color_didi_alert_buy = clrAqua;
input color color_didi_alert_sell = clrYellow;
input color color_didi_alert_disable = C'76,76,76';
input color color_didi_alert_enable = clrRed;

input color color_adx_background = C'76,76,76';
input color color_adx_buy = clrAqua;
input color color_adx_sell = clrYellow;
input color color_adx_neutral = clrWhite;

input int    layout_colunas = 6; // quantidade de colunas
input int buttonXsize = 72; // largura dos campos
int buttonYsize = 16; // altura dos campos
input string symbolFont = "Calibri Bold";    // fonte do nome do simbolo
input int symbolFontSize = 12;         // tamanho da fonte do nome do simbolo
input string lblFont = "Arial";    // fonte do label didi
input int lblFontSize = 10;         // tamanho da fonte do label didi
input string adxFont = "Arial";    // fonte do label adx
input int adxFontSize = 8;         // tamanho da fonte do label adx
input int WindowIndex = 0; // indice da janela (0 - principal)

//+------------------------------------------------------------------+
//| GLOBAL STRUCTS                                                   |
//+------------------------------------------------------------------+

class Bar;   // forward declaration
//--- Simple vector class for Bar* (no templates in MQL5)
class BarVector{
private:
   Bar* elements[];
public:
   int Total() { return ArraySize(elements); }
   void Add(Bar* value){
      int n=ArraySize(elements);
      ArrayResize(elements,n+1);
      elements[n]=value;
   }
   void Clear(){ ArrayResize(elements,0); }
   Bar* At(const int index){ return elements[index]; }
// operador de índice para compatibilidade com sintaxe antiga
Bar* operator[](const int index){ return elements[index]; }
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES (KEPT AS IN ORIGINAL)                           |
//+------------------------------------------------------------------+
int axisX = 10; 
int axisY = 10;
int   posX, posY;                                             
int   win_index, buttonsCount;
string  prefix_name;
string message;
static string indicator_name = "DashDidi";
color clrAux;
string strAux;
long chartId;
int symbols_count;
string symbols_list[];
int tfs_count;
string tfs_list[];
int periods_list[];

// Número máximo de timeframes suportados pelo painel. Aumente se necessário.
#define MAX_TFS 10
 
int handleHeikenAshi[];                    // Heiken Ashi handles (1-D)
int handleMACurta[][MAX_TFS];              // MA Curta handles  [symbol][tf]
int handleMAMedia[][MAX_TFS];              // MA Média handles  [symbol][tf]
int handleMALonga[][MAX_TFS];              // MA Longa handles  [symbol][tf]
int handleADX[][MAX_TFS];                  // ADX handles       [symbol][tf]

//--- salva configuração original do gráfico para restaurar em OnDeinit
color orig_color_background,
      orig_color_foreground,
      orig_color_grid,
      orig_color_volume,
      orig_color_chart_up,
      orig_color_chart_down,
      orig_color_chart_line,
      orig_color_candle_bull,
      orig_color_candle_bear;
int   orig_chart_mode;

//--- Bar object remains unchanged ----------------------------------
class Bar {
public:
   string symbol;
   datetime current_time, check_time;
   bool updated;
   ENUM_TIMEFRAMES timeframe;
   bool alertaAgulhada, alertaAgulhadaPontoFalso;
   bool alertaCurta;
   // HeikenAshi
   int heikenAshiValue;
   bool heikenAshiBuy;
   bool heikenAshiSell;

   Bar(string _symbol, ENUM_TIMEFRAMES _timeframe){
      symbol = _symbol;
      timeframe = _timeframe;
      check_time = 0;
      updated = false;
      alertaCurta = false;
      alertaAgulhada = alertaAgulhadaPontoFalso = false;
      heikenAshiValue = 0;
      heikenAshiBuy = heikenAshiSell = false;
   }

   bool Update(){
      updated = false;
      current_time = GetBarTime(symbol,timeframe,0);
      if(check_time != current_time){
         updated = true;
         check_time = current_time;
         alertaCurta = false;
         alertaAgulhada = alertaAgulhadaPontoFalso = false;
      }
      return updated;
   }
};

// Vector containers (original library works both in MT4 and MT5)
BarVector bars[];     // One vector per symbol / timeframe matrix
BarVector barsD1;     // D1 timeframe objects for HeikenAshi filter
//+------------------------------------------------------------------+
//|  HELPER FUNCTION PROTOTYPES (from the original file)             |
//|  Please scroll down for implementations.                         |
//+------------------------------------------------------------------+
void refresh();
void createPanel();
void DisplayButton(string _name, string _text, int x, int y, int sizeX, int sizeY, color clrBg, color clrText, bool pressed=false);
int stringToTimeFrame(const string tf);               // unchanged
void calculateDidi(string _symbol,int _period,double &didiCurta,double &didiLonga,int _shift);
void calculateAdx(string _symbol,int _period,double &adx,double &dip,double &dim,int _shift);

//+------------------------------------------------------------------+
//| EVENT HANDLERS                                                   |
//+------------------------------------------------------------------+
int OnInit(){
   IndicatorSetString(INDICATOR_SHORTNAME, indicator_name);
   chartId = ChartID();

   win_index = ChartWindowFind(chartId, indicator_name);
   Print("win_index: "+(string)win_index);
   if(win_index == -1) win_index = 1;
   prefix_name = indicator_name+"_"+(string)win_index+"_";
   

   //--- symbol/timeframe parsing (unchanged)
   string Ativos = Ativos1;
   if(StringLen(Ativos)>0 && StringLen(Ativos2)>0) Ativos += ",";
   Ativos += Ativos2;
   if(StringLen(Ativos)>0 && StringLen(Ativos3)>0) Ativos += ",";
   Ativos += Ativos3;

   symbols_count = StringSplit(Ativos,',',symbols_list);
   if(symbols_count==0){
      symbols_count=1;
      ArrayResize(symbols_list,1);
      symbols_list[0] = Symbol();
   }

   tfs_count = StringSplit(Timeframes,',',tfs_list);
   if(tfs_count==0){
      tfs_count=1;
      ArrayResize(tfs_list,1);
      ArrayResize(periods_list,1);
      tfs_list[0] = PeriodToString(Period());
      periods_list[0] = Period();
   }else{
      ArrayResize(periods_list,tfs_count);
      for(int i=0;i<tfs_count;i++)
         periods_list[i] = stringToTimeFrame(tfs_list[i]);
   }

   //--- allocate Bar objects
   ArrayResize(bars, symbols_count);
   for(int i=0;i<symbols_count;i++){
      SymbolSelect(symbols_list[i],true);
      for(int j=0;j<tfs_count;j++)
         bars[i].Add(new Bar(symbols_list[i],(ENUM_TIMEFRAMES)periods_list[j]));
      barsD1.Add(new Bar(symbols_list[i],HeikenAshiTimeframe));
   }
   
   ArrayResize(handleHeikenAshi, symbols_count);
   //--- create MA/ADX handle matrices -------------------------------------------------
   ArrayResize(handleMACurta, symbols_count);
   ArrayResize(handleMAMedia, symbols_count);
   ArrayResize(handleMALonga, symbols_count);
   ArrayResize(handleADX,      symbols_count);

   for(int i=0; i<symbols_count; i++)
   {
      string _symbol = symbols_list[i];
      SymbolSelect(_symbol,true);
      
      handleHeikenAshi[i]  = iCustom(_symbol, HeikenAshiTimeframe, HeikenAshiPath, clrNONE, clrNONE);
      if(handleHeikenAshi[i]==INVALID_HANDLE )
         PrintFormat("Handle para HeikenAshi invalido para o simbolo: %s", _symbol);

     //--- preenche os handles para cada timeframe deste símbolo --------------------
     for(int j=0;j<tfs_count;j++)
     {
        ENUM_TIMEFRAMES _tf = (ENUM_TIMEFRAMES)periods_list[j];
        if(j < MAX_TFS) // segurança contra overflow
        {
            handleMACurta[i][j] = iMA(_symbol, _tf, didiCurtaLength, 0, (ENUM_MA_METHOD)didiMethod, didiPrice);
            handleMAMedia[i][j] = iMA(_symbol, _tf, didiMediaLength, 0, (ENUM_MA_METHOD)didiMethod, didiPrice);
            handleMALonga[i][j] = iMA(_symbol, _tf, didiLongaLength, 0, (ENUM_MA_METHOD)didiMethod, didiPrice);
            handleADX[i][j]     = iADX(_symbol, _tf, adx_period);
        }        // debug
         if(j < MAX_TFS)
         {
            if(handleMACurta[i][j]==INVALID_HANDLE || handleMAMedia[i][j]==INVALID_HANDLE || handleMALonga[i][j]==INVALID_HANDLE || handleADX[i][j]==INVALID_HANDLE)
               PrintFormat("Handle inválido (MA/ADX) para %s %s", _symbol, PeriodToString(periods_list[j]));
         }
     }
      
   }
   
   for(int i = ObjectsTotal(chartId,0)-1; i>=0; i--){
      string objname = ObjectName(chartId,i,0);
      if(StringFind(objname,prefix_name) > -1)
         ObjectDelete(chartId,objname);
   }

   //--- salva valores atuais do gráfico
   orig_color_background = (color)ChartGetInteger(chartId, CHART_COLOR_BACKGROUND);
   orig_color_foreground = (color)ChartGetInteger(chartId, CHART_COLOR_FOREGROUND);
   orig_color_grid       = (color)ChartGetInteger(chartId, CHART_COLOR_GRID);
   orig_color_volume     = (color)ChartGetInteger(chartId, CHART_COLOR_VOLUME);
   orig_color_chart_up   = (color)ChartGetInteger(chartId, CHART_COLOR_CHART_UP);
   orig_color_chart_down = (color)ChartGetInteger(chartId, CHART_COLOR_CHART_DOWN);
   orig_color_chart_line = (color)ChartGetInteger(chartId, CHART_COLOR_CHART_LINE);
   orig_color_candle_bull= (color)ChartGetInteger(chartId, CHART_COLOR_CANDLE_BULL);
   orig_color_candle_bear= (color)ChartGetInteger(chartId, CHART_COLOR_CANDLE_BEAR);
   orig_chart_mode       = (int)ChartGetInteger(chartId, CHART_MODE);

//--- chart appearance like original
   ChartSetInteger(chartId, CHART_COLOR_BACKGROUND, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_FOREGROUND, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_GRID, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_VOLUME, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_CHART_UP, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_CHART_DOWN, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_CHART_LINE, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_CANDLE_BULL, clrNONE);
   ChartSetInteger(chartId, CHART_COLOR_CANDLE_BEAR, clrNONE);
   ChartSetInteger(chartId, CHART_MODE, CHART_LINE);

   createPanel();

   if(useTimeToUpdate)
      EventSetTimer(secondsUpdate);

   refresh();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   Print("OnDeinit()");
   //--- delete UI objects
   for(int i = ObjectsTotal(chartId,0)-1; i>=0; i--){
      string objname = ObjectName(chartId,i,0);
      if(StringFind(objname,prefix_name) > -1)
         ObjectDelete(chartId,objname);
   }
   //ObjectsDeleteAll(chartId,-1,0);
   //ObjectsDeleteAll(chartId,win_index,0);

   //--- restaura configuração original do gráfico
   ChartSetInteger(chartId, CHART_COLOR_BACKGROUND, orig_color_background);
   ChartSetInteger(chartId, CHART_COLOR_FOREGROUND, orig_color_foreground);
   ChartSetInteger(chartId, CHART_COLOR_GRID,       orig_color_grid);
   ChartSetInteger(chartId, CHART_COLOR_VOLUME,     orig_color_volume);
   ChartSetInteger(chartId, CHART_COLOR_CHART_UP,   orig_color_chart_up);
   ChartSetInteger(chartId, CHART_COLOR_CHART_DOWN, orig_color_chart_down);
   ChartSetInteger(chartId, CHART_COLOR_CHART_LINE, orig_color_chart_line);
   ChartSetInteger(chartId, CHART_COLOR_CANDLE_BULL,orig_color_candle_bull);
   ChartSetInteger(chartId, CHART_COLOR_CANDLE_BEAR,orig_color_candle_bear);
   ChartSetInteger(chartId, CHART_MODE,             orig_chart_mode);

   //--- release Bar objects
   for(int i=0;i<symbols_count;i++){
      for(int j=0;j<tfs_count;j++)
         delete bars[i][j];
      bars[i].Clear();
      delete barsD1[i];
   }
   barsD1.Clear();

   //--- release indicator handles -----------------------------------------------------
   for(int i=0;i<symbols_count;i++)
   {
      if(handleHeikenAshi[i]!=INVALID_HANDLE) IndicatorRelease(handleHeikenAshi[i]);
      for(int j=0;j<tfs_count;j++)
      {
         if(handleMACurta[i][j]!=INVALID_HANDLE)  IndicatorRelease(handleMACurta[i][j]);
         if(handleMAMedia[i][j]!=INVALID_HANDLE)  IndicatorRelease(handleMAMedia[i][j]);
         if(handleMALonga[i][j]!=INVALID_HANDLE)  IndicatorRelease(handleMALonga[i][j]);
         if(handleADX[i][j]!=INVALID_HANDLE)      IndicatorRelease(handleADX[i][j]);
      }
   }

   if(useTimeToUpdate)
      EventKillTimer();
      
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   // We are not using series buffers; indicator acts like a dashboard panel.
   // Refresh only when NOT using timer.
   if(!useTimeToUpdate)
      refresh();
   return(rates_total);
}

//+------------------------------------------------------------------+
void OnTimer(){
   refresh();
}
//--------------------------------------------------------------------
// Atualiza painel
void refresh()
{
   for(int i=0; i<symbols_count; i++)
   {
      string _symbol = symbols_list[i];
      
      if(barsD1[i].Update() || HeikenAshiShift == 0)
      {
         // --- Filtro HeikenAshi ---
         if(handleHeikenAshi[i]!=INVALID_HANDLE )
         {
            double heikenOpen[], heikenClose[];
            
            if(CopyBuffer(handleHeikenAshi[i],0,HeikenAshiShift,1,heikenOpen) > 0 && CopyBuffer(handleHeikenAshi[i],3,HeikenAshiShift,1,heikenClose))
            {
               int heikenAshiValue = (heikenClose[0] >= heikenOpen[0] ? 1 : -1);
               bool heikenAshiBuy  = !HabilitarFiltroHeikenAshi || heikenAshiValue==1;
               bool heikenAshiSell = !HabilitarFiltroHeikenAshi || heikenAshiValue==-1;
         
               // Salva nos objetos Bar D1
               barsD1[i].heikenAshiValue = heikenAshiValue;
               barsD1[i].heikenAshiBuy   = heikenAshiBuy;
               barsD1[i].heikenAshiSell  = heikenAshiSell;
               
               //PrintFormat("Symbol: %s / heikenOpen: %.5f / heikenClose: %.5f / heikenAshiValue: %i", _symbol, heikenOpen[0], heikenClose[0], heikenAshiValue);
         
               // Cor do símbolo
               color symbolColor = (heikenAshiValue==1 ? clrAqua : clrYellow);
               Object_Set_Text("Symbol", i, _symbol, symbolFontSize, symbolFont, symbolColor);
            }
         }
         else {
            handleHeikenAshi[i] = iCustom(_symbol, HeikenAshiTimeframe, HeikenAshiPath, clrNONE, clrNONE);
            barsD1[i].updated = false;
            barsD1[i].check_time = 0;
         }
      }

      // --- percorre timeframes
      for(int j=0; j<tfs_count; j++)
      {
         bars[i][j].Update();
         if(bars[i][j].updated || didiShift==0)
         {
            double curta=0,lastCurta=0,longa=0,lastLonga=0;
            int    curtaCount=0,longaCount=0;
            bool   curtaExit=false,longaExit=false;
            int    shift=didiShift;
            bool   invalid=false;

            while(!(curtaExit && longaExit))
            {
               calculateDidi(_symbol, periods_list[j], curta, longa, shift);
               calculateDidi(_symbol, periods_list[j], lastCurta, lastLonga, shift+1);
               if(!MathIsValidNumber(curta) || !MathIsValidNumber(longa) || curta==0 || longa==0)
               {
                  invalid=true;
                  break;
               }
               if(!curtaExit)
               {
                  curtaCount++;
                  if(curta==0 || ((curta>=1 && lastCurta<1) || (curta<=1 && lastCurta>1)))
                     curtaExit=true;
               }
               if(!longaExit)
               {
                  longaCount++;
                  if(longa==0 || ((longa>=1 && lastLonga<1) || (longa<=1 && lastLonga>1)))
                     longaExit=true;
               }
               shift++;
            }

            string didi_alert1 = "didi_alert1_"+IntegerToString(i)+"_"+IntegerToString(j);
            string didi_alert2 = "didi_alert2_"+IntegerToString(i)+"_"+IntegerToString(j);
            string didi_timeframe = "timeframe_"+IntegerToString(i)+"_"+IntegerToString(j);

            if(invalid)
            {
               Object_Set_Text("didi_curta", i, j, "--", lblFontSize, lblFont, color_didi_text);
               Object_Set_Text("didi_longa", i, j, "--", lblFontSize, lblFont, color_didi_text);
               ObjectSetInteger(chartId, prefix_name+didi_alert2, OBJPROP_BGCOLOR, color_didi_alert_disable);
               ObjectSetInteger(chartId, prefix_name+didi_alert1, OBJPROP_BGCOLOR, color_didi_alert_disable);
               Object_Set_Text("lbl_didi_alert2", i, j, "--", symbolFontSize+1, symbolFont, color_didi_text);
               bars[i][j].updated = false;
               //bars[i][j].check_time = 0;
            }
            else
            {
               Object_Set_Text("didi_curta", i, j, IntegerToString(curtaCount), lblFontSize, lblFont, color_didi_text);
               Object_Set_Text("didi_longa", i, j, IntegerToString(longaCount), lblFontSize, lblFont, color_didi_text);
               Object_Set_Text("lbl_didi_alert2", i, j, IntegerToString(curtaCount), symbolFontSize+1, symbolFont, color_didi_text);

               // recalc para direção mais recente
               calculateDidi(_symbol, periods_list[j], curta, longa, didiShift);
               calculateDidi(_symbol, periods_list[j], lastCurta, lastLonga, didiShift+1);

               string alertType = "--";
               int curtaDirection=0, longaDirection=0;

               if(curta>1 || (curta==1 && lastCurta<1))
               {
                  ObjectSetInteger(chartId,prefix_name+didi_alert2,OBJPROP_BGCOLOR,color_didi_alert_buy);
                  ObjectSetInteger(chartId,prefix_name+didi_timeframe,OBJPROP_COLOR,color_didi_alert_buy);
                  alertType="Compra";
                  curtaDirection=1;
               }
               else if(curta<1 || (curta==1 && lastCurta>1))
               {
                  ObjectSetInteger(chartId,prefix_name+didi_alert2,OBJPROP_BGCOLOR,color_didi_alert_sell);
                  ObjectSetInteger(chartId,prefix_name+didi_timeframe,OBJPROP_COLOR,color_didi_alert_sell);
                  alertType="Venda";
                  curtaDirection=-1;
               }

               if(longa<1 || (longa==1 && lastLonga>1))
                  longaDirection=1;
               else if(longa>1 || (longa==1 && lastLonga<1))
                  longaDirection=-1;

               ObjectSetInteger(chartId, prefix_name+didi_alert1, OBJPROP_BGCOLOR, (curtaCount==longaCount ? color_didi_alert_enable : color_didi_alert_disable));

               // alertas
               if(HabilitarAlertaCurta && !bars[i][j].alertaCurta && lastCurta<1 && curta>=1 && barsD1[i].heikenAshiBuy)
               {
                  message = StringFormat("DashDidi - Alerta de Compra em %s %s", _symbol, tfs_list[j]);
                  if(UseAlert) Alert(message);
                  if(UseSound) PlaySound(SoundName);
                  if(UseNotification) SendNotification(message);
                  Print(message);
                  bars[i][j].alertaCurta=true;
               }
               if(HabilitarAlertaCurta && !bars[i][j].alertaCurta && lastCurta>1 && curta<=1 && barsD1[i].heikenAshiSell)
               {
                  message = StringFormat("DashDidi - Alerta de Venda em %s %s", _symbol, tfs_list[j]);
                  if(UseAlert) Alert(message);
                  if(UseSound) PlaySound(SoundName);
                  if(UseNotification) SendNotification(message);
                  Print(message);
                  bars[i][j].alertaCurta=true;
               }

               if(curtaCount==1 && longaCount==1)
               {
                  Print("111"); 

                  if(HabilitarAlertaAgulhada && !bars[i][j].alertaAgulhada && curtaDirection==longaDirection)
                  {
                     Print("333");
                     message = StringFormat("DashDidi - Agulhada de %s em %s %s", alertType, _symbol, tfs_list[j]);
                     if(UseAlert) Alert(message);
                     if(UseSound) PlaySound(SoundName);
                     if(UseNotification) SendNotification(message);
                     Print(message);
                     bars[i][j].alertaAgulhada=true;
                  }
                  if(HabilitarAlertaPontoFalso && !bars[i][j].alertaAgulhadaPontoFalso && curtaDirection!=longaDirection)
                  {
                     message = StringFormat("DashDidi - Agulhada Ponto falso de %s em %s %s", alertType, _symbol, tfs_list[j]);
                     if(UseAlert) Alert(message);
                     if(UseSound) PlaySound(SoundName);
                     if(UseNotification) SendNotification(message);
                     Print(message);
                     bars[i][j].alertaAgulhadaPontoFalso=true;
                  }
                  
               }
            }
         }

         // --- ADX -----------------------------------------------------
         if(adx_shift==0 || bars[i][j].updated)
         {
            double adx,dip,dim;
            calculateAdx(_symbol, periods_list[j], adx, dip, dim, adx_shift);
            color adxColor=color_adx_neutral;
            if(adx>=15 && dip>dim) adxColor=color_adx_buy;
            if(adx>=15 && dip<dim) adxColor=color_adx_sell;

            string _text2="";
            if(adx<23 && adx!=0) _text2="h";
            if(adx>=23 && adx<28 && dip>dim) _text2="ì";
            if(adx>=23 && adx<28 && dip<dim) _text2="î";
            if(adx>=28 && dip>dim) _text2="é";
            if(adx>=28 && dip<dim) _text2="ê";

            string adxText = StringFormat("ADX %s", DoubleToString(adx,1));
            SetAdxText("adx_alert", i, j, adxText, _text2, adxFontSize, adxFont, adxColor);
         }
      }
   }
   
   ChartRedraw(chartId);
}


//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      // Debug
      PrintFormat("OnChartEvent id:%d lparam:%d dparam:%f sparam:%s",id,lparam,dparam,sparam);

      //--- timeframe button clicked -------------------------------------------------
      if(StringFind(sparam,"timeframe_")>=0)
      {
         string tokens[];
         int count=StringSplit(sparam,'_',tokens);
         if(count==5)
         {
            int sym_pos=(int)StringToInteger(tokens[3]);
            int tf_pos =(int)StringToInteger(tokens[4]);
            if(sym_pos<symbols_count && tf_pos<tfs_count)
            {
               // reset button state to released so it behaves like push button
               ObjectSetInteger(chartId,sparam,OBJPROP_STATE,0);
               OpenChart(symbols_list[sym_pos],periods_list[tf_pos]);
               return;
            }
         }
      }

      //--- manual refresh button (if any)
      if(StringFind(sparam,"WindowRedraw")>=0)
      {
         refresh();
         return;
      }
   }
}

//+------------------------------------------------------------------+
//|  === ORIGINAL SUPPORT FUNCTIONS (trimmed for brevity) ===        |
//|  Copy the bodies directly from the MT4 code.  Only the signature |
//|  of TimeFrame / Symbol / price series functions may need tweaks. |
//+------------------------------------------------------------------+

// helper functions to locate symbol / timeframe position ---------------------------
int findSymbolIndex(const string sym)
{
   for(int i=0;i<symbols_count;i++)
      if(symbols_list[i]==sym) return i;
   return -1;
}
int findTfIndex(const ENUM_TIMEFRAMES tf)
{
   for(int j=0;j<tfs_count;j++)
      if(periods_list[j]==(int)tf) return j;
   return -1;
}

//--- Converts string timeframe to ENUM_TIMEFRAMES constant
int stringToTimeFrame(const string tf){
   if(tf=="M1")  return(PERIOD_M1);
   if(tf=="M5")  return(PERIOD_M5);
   if(tf=="M15") return(PERIOD_M15);
   if(tf=="M30") return(PERIOD_M30);
   if(tf=="H1")  return(PERIOD_H1);
   if(tf=="H4")  return(PERIOD_H4);
   if(tf=="D1")  return(PERIOD_D1);
   if(tf=="W1")  return(PERIOD_W1);
   if(tf=="MN1") return(PERIOD_MN1);
   return(Period());
}

//--- Simplified DIDI calculation (copy logic 1-for-1)
void calculateDidi(string _symbol,int _period,double &didiCurta,double &didiLonga,int _shift)
{
   double maCurta = GetMA(_symbol,(ENUM_TIMEFRAMES)_period,didiCurtaLength,0,didiMethod,didiPrice,_shift);
   double maMedia = GetMA(_symbol,(ENUM_TIMEFRAMES)_period,didiMediaLength,0,didiMethod,didiPrice,_shift);
   double maLonga = GetMA(_symbol,(ENUM_TIMEFRAMES)_period,didiLongaLength,0,didiMethod,didiPrice,_shift);
   if(maMedia==0){
      didiCurta = didiLonga = 0;
      return;
   }
   didiCurta = maCurta/maMedia;
   didiLonga = maLonga/maMedia;
}

//--- Simplified ADX (DI+/DI-) helper
void calculateAdx(string _symbol,int _period,double &adx,double &dip,double &dim,int _shift)
{
   if(!GetADX(_symbol,(ENUM_TIMEFRAMES)_period,adx_period,_shift,adx,dip,dim))
   {
      adx=dip=dim=0;
   }
}

//+------------------------------------------------------------------+
//| Panel / UI helper functions (migrated from original indicator)   |
//+------------------------------------------------------------------+

void createPanel(){
   posY = axisY;
   posX = axisX;

   // Main background rectangle
   DisplayRectangle("window_rect",2,2,10000,5000,color_window_background);

   int sizeX = buttonXsize * tfs_count + 10;
   int sizeY = 18 + (buttonYsize*6);
   int symbolPerLine = layout_colunas;

   for(int i=0;i<symbols_count;i++){
      if(i>0 && i%symbolPerLine==0){
         posY += sizeY;
         posX  = axisX;
      }
      DrawSymbol(symbols_list[i],i,posX,posY,sizeX,sizeY);
      posX += sizeX;
   }
}

//--------------------------------------------------------------------
void DrawSymbol(string symbol,int pos,int x,int y,int sizeX,int sizeY){
   string number = IntegerToString(pos);
   DisplayRectangle("symbol_rect_"+number,posX,posY,sizeX-1,sizeY-1,color_subwindow_background);

   DisplayLabel("Symbol",pos,x+7,y+5);
   Object_Set_Text("Symbol",pos,symbol,symbolFontSize,symbolFont,clrWhite);

   int tfPosX = x+5;
   int tfPosY = y+25;
   int buttonHalf = buttonXsize/2;
   for(int i=0;i<tfs_count;i++){
      string tfPos = "_"+number+"_"+IntegerToString(i);
      DisplayButton("timeframe"+tfPos,tfs_list[i],tfPosX+1,tfPosY-1,buttonXsize-2,buttonYsize,color_timeframe_background,color_timeframe_text,false);

      int auxY  = 25;
      int space = 0;
      DisplayDidi("didi_curta"+tfPos,"0",tfPosX+buttonHalf+space,   tfPosY+buttonYsize+space,         (buttonXsize/2)-space*2,auxY-space*2,color_didi_curta,color_didi_text,true);
      DisplayDidi("didi_longa"+tfPos,"0",tfPosX+buttonHalf+space,   tfPosY+buttonYsize+auxY+space,    (buttonXsize/2)-space*2,auxY-space*2,color_didi_longa,color_didi_text,true);

      DisplayDidiAlert("didi_alert1"+tfPos, tfPosX+space,            tfPosY+buttonYsize+space,         (buttonXsize/2)-space*2,(auxY*2)-space*2,color_didi_alert_disable);
      DisplayDidiAlert2("didi_alert2"+tfPos,tfPosX+7,                tfPosY+buttonYsize+7,             (buttonXsize/2)-14,     (auxY*2)-14,     color_didi_alert_disable);

      DisplayAdx("adx_alert"+tfPos,"ADX 00.0",tfPosX+space,         tfPosY+buttonYsize+(auxY*2)+space,buttonXsize-space*2,    auxY-space*2,    color_adx_background,color_adx_neutral,true);

      tfPosX += buttonXsize;
   }
}

//--------------------------------------------------------------------
void Object_Set_Text(string _name,int i,string _text,int _size,string _font,color _clr){
   ObjectSetText(prefix_name+_name+"_"+IntegerToString(i),_text,_size,_font,_clr);
}

void Object_Set_Text(string _name,int i,int j,string _text,int _size,string _font,color _clr){
   string name = prefix_name+_name+"_"+IntegerToString(i)+"_"+IntegerToString(j);
   ObjectSetText(name,_text,_size,_font,_clr);
}

//--------------------------------------------------------------------
void SetAdxText(string _name,int i,int j,string _text,string _text2,int _size,string _font,color _clr){
   string name  = prefix_name+_name+"_"+IntegerToString(i)+"_"+IntegerToString(j);
   ObjectSetText(name,_text,_size,_font,_clr);
   string name2 = prefix_name+"dir_"+_name+"_"+IntegerToString(i)+"_"+IntegerToString(j);
   ObjectSetText(name2,_text2,adxFontSize,"Wingdings",_clr);
}

//--------------------------------------------------------------------
void DisplayAdx(string _name,string _text,int x,int y,int sizeX,int sizeY,color clrBg,color clrText,bool pressed=false){
   string _nameRect = prefix_name+"rect_"+_name;
   string _nameLbl = prefix_name+_name;
   string _nameDirection = prefix_name+"dir_"+_name;
   ObjectCreate(chartId,_nameRect,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YSIZE,sizeY);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_WIDTH,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_CORNER,0);

   ObjectCreate(chartId,_nameLbl,OBJ_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_XDISTANCE,x+4);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_YDISTANCE,y+5);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetText(_nameLbl,_text,adxFontSize,adxFont,clrText);


   ObjectCreate(chartId,_nameDirection,OBJ_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameDirection,OBJPROP_XDISTANCE,x+57);
   ObjectSetInteger(chartId,_nameDirection,OBJPROP_YDISTANCE,y+5);
   ObjectSetInteger(chartId,_nameDirection,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetText(_nameDirection,"h",adxFontSize,"Wingdings",clrText);
}

//--------------------------------------------------------------------
void DisplayDidi(string _name,string _text,int x,int y,int sizeX,int sizeY,color clrBg,color clrText,bool pressed=false){
   string _nameRect = prefix_name+"rect_"+_name;
   string _nameLbl = prefix_name+_name;

   ObjectCreate(chartId,_nameRect,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YSIZE,sizeY);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_WIDTH,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_CORNER,0);

   ObjectCreate(chartId,_nameLbl,OBJ_LABEL,0,0,0,0);
   ObjectSetText(_nameLbl,_text,lblFontSize,lblFont,clrBlack);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_XDISTANCE,x+(buttonXsize/4)+7);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_YDISTANCE,y+5);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
}

//--------------------------------------------------------------------
void DisplayDidiAlert2(string _name,int x,int y,int sizeX,int sizeY,color clrBg){
   string _nameRect = prefix_name+_name;
   string _nameLbl = prefix_name+"lbl_"+_name;

   ObjectCreate(chartId,_nameRect,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YSIZE,sizeY);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_WIDTH,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_CORNER,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BACK,false);

   ObjectCreate(chartId,_nameLbl,OBJ_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_XDISTANCE,x+(buttonXsize/4)+1);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_YDISTANCE,y+8);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetText(_nameLbl,"--",symbolFontSize+1,symbolFont,clrBlack);
}

//--------------------------------------------------------------------
void DisplayDidiAlert(string _name,int x,int y,int sizeX,int sizeY,color clrBg){
   string _nameRect = prefix_name+_name;
   ObjectCreate(chartId,_nameRect,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YSIZE,sizeY);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_WIDTH,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_CORNER,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BACK,false);
}

//--------------------------------------------------------------------
void DisplayButton(string _name,string _text,int x,int y,int sizeX,int sizeY,color clrBg,color clrText,bool pressed=false){
   string _nameButton = prefix_name+_name;
   ObjectCreate(chartId,_nameButton,OBJ_BUTTON,win_index,0,0);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_CORNER,0);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_BACK,false);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_YSIZE,sizeY);
   ObjectSetString(chartId,_nameButton,OBJPROP_FONT,symbolFont);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_FONTSIZE,symbolFontSize);
   ObjectSetString(chartId,_nameButton,OBJPROP_TEXT,_text);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_COLOR,clrText);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_STATE,pressed);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameButton,OBJPROP_SELECTABLE,false);
}

//--------------------------------------------------------------------
void DisplayLabel(string _name,string _text,int x,int y,int sizeX,int sizeY,color clrBg,color clrText,bool pressed=false){
   string _nameRect = prefix_name+"rect_"+_name;
   string _nameLbl = prefix_name+_name;

   ObjectCreate(chartId,_nameRect,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_BGCOLOR,clrBg);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_XSIZE,sizeX);
   ObjectSetInteger(chartId,_nameRect,OBJPROP_YSIZE,sizeY);

   ObjectCreate(chartId,_nameLbl,OBJ_LABEL,0,0,0,0);
   ObjectSetText(_nameLbl,_text,lblFontSize,lblFont,clrBlack);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_XDISTANCE,x+buttonXsize-5);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_YDISTANCE,y+1);
   ObjectSetInteger(chartId,_nameLbl,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
}

//--------------------------------------------------------------------
void DisplayRectangle(string _name,int _x,int _y,int _sizeX,int _sizeY,color _clr){
   string name = prefix_name+_name;
   ObjectCreate(chartId,name,OBJ_RECTANGLE_LABEL,win_index,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_WIDTH,0);
   ObjectSetInteger(chartId,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,_x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,_y);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,true);
   ObjectSetInteger(chartId,name,OBJPROP_XSIZE,_sizeX);
   ObjectSetInteger(chartId,name,OBJPROP_YSIZE,_sizeY);
   ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,_clr);
   ObjectSetInteger(chartId,name,OBJPROP_ZORDER,0);
}

//--------------------------------------------------------------------
void DisplayLabel(string name,int i,int x,int y){
   DisplayLabel(name+"_"+IntegerToString(i),x,y);
}

void DisplayLabel(string _name,int x,int y){
   _name = prefix_name+_name;
   ObjectCreate(chartId,_name,OBJ_LABEL,win_index,0,0);
   ObjectSetInteger(chartId,_name,OBJPROP_CORNER,0);
   ObjectSetInteger(chartId,_name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,_name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,_name,OBJPROP_BACK,false);
}

//--------------------------------------------------------------------
void OpenChart(string pair,int timeframe){
   long nextchart = ChartFirst();
   do{
      string sym = ChartSymbol(nextchart);
      if(nextchart!=chartId && StringFind(sym,pair)>=0){
         ChartSetInteger(nextchart,CHART_BRING_TO_TOP,true);
         ChartSetSymbolPeriod(nextchart,pair,(ENUM_TIMEFRAMES)timeframe);
         ChartApplyTemplate(nextchart,NewChartTemplate);
         return;
      }
   }while((nextchart=ChartNext(nextchart))!=-1);
   long newchartid = ChartOpen(pair,(ENUM_TIMEFRAMES)timeframe);
   ChartApplyTemplate(newchartid,NewChartTemplate);
}

//--------------------------------------------------------------------
string PeriodToString(int period){
   switch(period){
      case PERIOD_M1    : return "M1";
      case PERIOD_M5    : return "M5";
      case PERIOD_M15   : return "M15";
      case PERIOD_M30   : return "M30";
      case PERIOD_H1    : return "H1";
      case PERIOD_H4    : return "H4";
      case PERIOD_D1    : return "D1";
      case PERIOD_W1    : return "W1";
      case PERIOD_MN1   : return "MN1";
      default           : return "Current";
   }
}

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| MQL5 compatibility helpers                                       |
//+------------------------------------------------------------------+

// Wrapper que imita o antigo ObjectSetText do MT4
void ObjectSetText(const string name,const string text,const int size,const string font,const color clr)
{
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
}

// Retorna valor de uma média móvel simples usando handles MT5
double GetMA(const string symbol,const ENUM_TIMEFRAMES tf,const int period,const int ma_shift,const int method,const int price,const int shift)
{
   int symIdx = findSymbolIndex(symbol);
   int tfIdx  = findTfIndex(tf);
   int handle = INVALID_HANDLE;
   if(symIdx>=0 && tfIdx>=0)
   {
      if(period==didiCurtaLength)
         if(tfIdx < MAX_TFS) handle = handleMACurta[symIdx][tfIdx];
      else if(period==didiMediaLength)
         if(tfIdx < MAX_TFS) handle = handleMAMedia[symIdx][tfIdx];
      else if(period==didiLongaLength)
         if(tfIdx < MAX_TFS) handle = handleMALonga[symIdx][tfIdx];
   }
   if(handle==INVALID_HANDLE)
      handle = iMA(symbol,tf,period,ma_shift,(ENUM_MA_METHOD)method,price); // fallback

   double buf[];
   if(CopyBuffer(handle,0,shift,1,buf)<=0) return 0;
   return buf[0];
}

// Retorna valores do ADX (MAIN, +DI, -DI) utilizando handles
bool GetADX(const string symbol,const ENUM_TIMEFRAMES tf,const int adxPeriod,const int shift,double &main,double &plus,double &minus)
{
   int symIdx = findSymbolIndex(symbol);
   int tfIdx  = findTfIndex(tf);
   int handle = INVALID_HANDLE;
   if(symIdx>=0 && tfIdx>=0)
      if(tfIdx < MAX_TFS) handle = handleADX[symIdx][tfIdx];
   if(handle==INVALID_HANDLE)
      handle = iADX(symbol,tf,adxPeriod); // fallback

   double bufMain[],bufPlus[],bufMinus[];
   if(CopyBuffer(handle,0,shift,1,bufMain)<=0) return false;
   if(CopyBuffer(handle,1,shift,1,bufPlus)<=0) return false;
   if(CopyBuffer(handle,2,shift,1,bufMinus)<=0) return false;
   main  = bufMain[0];
   plus  = bufPlus[0];
   minus = bufMinus[0];
   return true;
}

// Retorna time de uma barra usando CopyTime
datetime GetBarTime(const string symbol,const ENUM_TIMEFRAMES tf,const int shift)
{
   datetime t[];
   if(CopyTime(symbol,tf,shift,1,t)<=0) return 0;
   return t[0];
}

//+------------------------------------------------------------------+
