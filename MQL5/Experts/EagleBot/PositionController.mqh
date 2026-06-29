#include "Trade.mqh"
#include "CVector.mqh"
 #include <Arrays\ArrayInt.mqh>
enum TargetType {VALOR_FIXO, VALOR_PERCENTUAL};
enum TIPO_CONTA_MT5 { HEDGE, NETTING, AUTO_DETECT };

input string input_info_management = "=== GERENCIAMENTO DE RISCO ==="; //-
input TIPO_CONTA_MT5 input_account_type = AUTO_DETECT;
input long order_magic = 369001;            // Número único do EA (magic)
input double TakeProfit = 15;
input double StopLoss = 10;
input bool useTrailingStop = false;         // Habilitar TrailingStop
input int maxOrders = 1;                    // Quantidade de ordens simultâneas
input double Lots = 1;                      // Lotes (Contratos)
input bool UseProportionalLots = false;     // Habilitar ajuste automático de contratos.
input double ProportionalLots = 0.5;        // Quantidade de contratos a cada 1000 BRL de saldo
input bool useDailyTarget = false;          // Habilitar gerenciamento de perda e lucro diário
input TargetType dailyTargetType = VALOR_PERCENTUAL; // Tipo de gerencimanto
input double dailyTakeProfitValue = 5.0;    // Ganho máximo diário
input double dailyStopLossValue = 5.0;      // Perda máxima diário
input int input_wait_after_loss_min = 0;    // Tempo de espera após StopLoss
input int input_wait_after_win_min = 0;     // Tempo de espera após TakeProfit

TIPO_CONTA_MT5 account_type;
string ea_comment;

//+------------------------------------------------------------------+
class PositionController
{
public: 
    CVector<Trade *> opened_trades;
    datetime datetime_last_loss, datetime_last_win;
    int count_daily_gain, count_daily_loss;
    int count_weekly_gain, count_weekly_loss;
    int count_monthly_gain, count_monthly_loss;
    double daily_profit, dailyTakeProfit, dailyStopLoss;
    double weekly_profit, monthly_profit; 
    
    //+------------------------------------------------------------------+
    PositionController() {
        resetValues();
        account_type = input_account_type;
        ea_comment = input_ea_name + " " + input_comment;
        if(account_type == AUTO_DETECT) {
            if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING) {
                account_type = NETTING;
            }
            else {
                account_type = HEDGE;
            }
        }
        PrintFormat("Tipo de conta selecionada: %s", (account_type == NETTING) ? "NETTING" : "HEDGE");
    }
    //+------------------------------------------------------------------+
    ~PositionController() {
        for(int i=0; i<opened_trades.Total(); i++) {
            if(opened_trades[i]) delete opened_trades[i];
        }
    }
    //+------------------------------------------------------------------+
    void resetValues() {
        count_daily_gain = count_daily_loss = 0;
        count_weekly_gain = count_weekly_loss = 0;
        count_monthly_gain = count_monthly_loss = 0;
        daily_profit = weekly_profit = monthly_profit = 0.0;
    }
    //+------------------------------------------------------------------+
    void deleteOpenedOrders() {
        CArrayInt remove;
        for(int i=0; i<opened_trades.Total(); i++) {
            if(opened_trades[i] && !opened_trades[i].filled) {
                opened_trades[i].deleteTakeProfit(); 
                opened_trades[i].OrderDelete(opened_trades[i].ticket);
                remove.Add(i);
            } 
        }
        for(int i=0; i < remove.Total(); i++) {
            opened_trades.Delete(remove[i]);
         }
    }
    //+------------------------------------------------------------------+
    bool openOrderAllowed()
    {
        return (opened_trades.Total() < maxOrders);
    }
    //+------------------------------------------------------------------+
    bool checkWaitAfterLastLoss() {
      if(input_wait_after_loss_min <= 0)
         return false;
         
      bool wait = false;
      double time1 = (double)TimeCurrent(); 
      double time2 = (double)datetime_last_loss;
      double diff_minutes = (time1 - time2) / 60;
      if(diff_minutes <= (double)input_wait_after_loss_min) {
         wait = true;
      }
      return wait;
    }
  //+------------------------------------------------------------------+
  bool checkWaitAfterLastWin() {
    if(input_wait_after_win_min <= 0)
      return false;

    bool wait = false;
    double time1 = (double)TimeCurrent();
    double time2 = (double)datetime_last_win;
    double diff_minutes = (time1 - time2) / 60;
    if(diff_minutes <= (double)input_wait_after_win_min) {
      wait = true;
    }
    return wait;
  }
   //+------------------------------------------------------------------+
    bool checkDailyTargetIsReached() {
        if(useDailyTarget) {
            if(daily_profit >= dailyTakeProfit || daily_profit <= -dailyStopLoss) {
                return true;
            }
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool takeIsReached() {
        if(useDailyTarget && daily_profit >= dailyTakeProfit) {
            return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    bool stopIsReached() {
        if(useDailyTarget && daily_profit  <= -dailyStopLoss) {
            return true;
        }
        return false;
    }
    //+------------------------------------------------------------------+
    void CloseAllOrders()
    {  
        for(int i=0; i<opened_trades.Total(); i++) {
            if(opened_trades[i] != NULL) {
                opened_trades[i].close();
            }
        }
        opened_trades.Clear();
        
        CTrade trade;
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            ulong orderticket = OrderGetTicket(i);
            if(OrderGetInteger(ORDER_MAGIC) == order_magic && 
               OrderGetString(ORDER_SYMBOL) == _Symbol) {
               trade.OrderDelete(orderticket);
               PrintFormat("CloseAllOrders: encerrando ordem ticket: %d", orderticket);
            }
        }
    }
    //+------------------------------------------------------------------+
    void resetDailyTargetValues() {
        daily_profit = 0.0;
        count_daily_gain = count_daily_loss = 0;
        datetime_last_loss = 0;
        datetime_last_win = 0;
        if(useDailyTarget) {
            if(dailyTargetType == VALOR_PERCENTUAL) {
               double balance = AccountInfoDouble(ACCOUNT_BALANCE);
               dailyTakeProfit = (dailyTakeProfitValue/100.0) * balance;
               dailyStopLoss = (dailyStopLossValue/100.0) * balance;
            }
            else {
               dailyTakeProfit = dailyTakeProfitValue;
               dailyStopLoss = dailyStopLossValue;
            }
        }
    }
    //+------------------------------------------------------------------+
    void updateProfit()
    {
        ulong ticket, magic;
        double profit;
        datetime time;
        string symbol;
        long entry;
        resetValues();
        datetime begin_day = iTime(Symbol(), PERIOD_D1, 0);
        datetime begin_week = iTime(Symbol(), PERIOD_W1, 0);
        datetime begin_month = iTime(Symbol(), PERIOD_MN1, 0);
        
        HistorySelect(begin_month, TimeCurrent());
        int total = HistoryDealsTotal();
        for (int i = 0; i < total; i++) {
            ticket = HistoryDealGetTicket(i);
            if (ticket > 0) {
                if (HistoryDealGetInteger(ticket, DEAL_MAGIC, magic)) {
                    if (magic == order_magic) {
                        entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
                        symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
                        if (entry == DEAL_ENTRY_OUT && symbol == _Symbol) {
                            time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
                            profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                            //PrintFormat("Carregando Operação fechada: Price: %f Symbol: %s Type: %d Entry: %d Profit: %f", price, symbol, type, entry, profit);
                            if(time > begin_day) {
                                if(profit > 0) { 
                                  count_daily_gain++;
                                  if(time > datetime_last_win) datetime_last_win = time;
                                } 
                                else {
                                  count_daily_loss++;
                                  if(time > datetime_last_loss) datetime_last_loss = time;
                                }
                                daily_profit += profit;
                             }
                             if(time > begin_week) {
                                if(profit > 0) count_weekly_gain++;
                                else count_weekly_loss++;
                                weekly_profit += profit;
                             }
                             if(time > begin_month) {
                                if(profit > 0) count_monthly_gain++;
                                else count_monthly_loss++;
                                monthly_profit += profit;
                             }   
                        }
                    }
                }
            }
        }
    }
    
    //+------------------------------------------------------------------+
    void TradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
    {
        //PrintMqlTradeTransaction(trans);
        //PrintMqlTradeRequest(request);
        //PrintMqlTradeResult(result);
        int remove = -1;
        
        if(trans.type == TRADE_TRANSACTION_ORDER_DELETE && trans.order_state == ORDER_STATE_FILLED) {
            for(int i=0; i<opened_trades.Total(); i++) {
                Trade *trade = opened_trades[i];
                if(trans.order == trade.ticket) {
                    trade.filled = true;
                    PrintFormat("Ordem Limit %d Preenchida.", trade.ticket);
                    if(account_type == NETTING) {
                        trade.openTakeProfit();
                    }
                    break;
                }
                if(account_type == NETTING) {
                    if(trade.tradeTP != NULL) {
                        if(trade.tradeTP.ticket == trans.order) {
                            PrintFormat("Ordem TakeProfit %d Preenchida.", trade.ticket);
                            trade.filled_tp = true;
                            //closed_trades.Add(trade);
                            datetime_last_win = OrderCloseTime(trade.tradeTP.ticket); 
                            remove = i;  
                            updateProfit();
                            break; 
                        }
                    }
                    if(trade.tradeSL != NULL) {
                        if(trade.tradeSL.ticket == trans.order) {
                            PrintFormat("Ordem StopLoss %d Preenchida.", trade.ticket);
                            trade.filled_sl = true;
                            trade.deleteTakeProfit(); 
                            //closed_trades.Add(trade);
                            datetime_last_loss = OrderCloseTime(trade.tradeSL.ticket);
                            remove = i;  
                            updateProfit();
                            break; 
                        }
                    }
                 }
                 else {
                    if(trans.position == trade.ticket) {
                        if(trans.order_type == ORDER_TYPE_BUY) {
                            if(trans.price <= trade.RequestPrice()) {
                                datetime_last_win = OrderCloseTime(trans.order); 
                            }
                            else {
                                datetime_last_loss = OrderCloseTime(trans.order);
                            }
                        }
                        else if(trans.order_type == ORDER_TYPE_SELL) {
                            if(trans.price >= trade.RequestPrice()) {
                                datetime_last_win = OrderCloseTime(trans.order); 
                            }
                            else {
                                datetime_last_loss = OrderCloseTime(trans.order);
                            }
                        }
                        remove = i;  
                        updateProfit();
                        break;
                    }
                 }
            }
            
            if(remove >= 0) {
                opened_trades.Delete(remove);
            }
        }  
    } 
    //+------------------------------------------------------------------+
    datetime OrderCloseTime( const ulong Ticket )
    {
      return((HistoryOrderGetInteger(Ticket, ORDER_TICKET) == Ticket) || HistoryOrderSelect(Ticket) ? (datetime)HistoryOrderGetInteger(Ticket, ORDER_TIME_DONE) : 0);
    }
    //+------------------------------------------------------------------+
    bool hasOpenedOrder()
    {
        return (!AllowMultipleOrders && opened_trades.Total() > 0);
    }
    //+------------------------------------------------------------------+
    bool OpenLimit(string _id, ENUM_ORDER_TYPE type, double _price) {
       Trade *trade = new Trade(_id);
       trade.SetExpertMagicNumber(order_magic);
       double lots = Lots;
        if (UseProportionalLots) {
            lots = (int)(AccountInfoDouble(ACCOUNT_BALANCE) * ProportionalLots / 1000);
            if(lots == 0) lots = 1;
        }
        double ticksize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
        double price = ((int)(_price / ticksize)) * ticksize;
        double sl = 0;
        double tp = 0;
        
        if (type == ORDER_TYPE_BUY_LIMIT) {
            if(price < _price) price += ticksize;
            
            if(account_type == HEDGE) {
                sl = NormalizeDouble(price - StopLoss, Digits());
                tp = NormalizeDouble(price + TakeProfit, Digits());
            }
            if(trade.BuyLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, ea_comment )) {
               trade.ticket = trade.ResultOrder();
               opened_trades.Add(trade);
            }
            else {
                PrintFormat("Erro ao enviar ordem BUY_LIMIT. Id: %s Price: %f", _id, price );
            }
        }
        else if (type == ORDER_TYPE_SELL_LIMIT) {
            if(price >  _price) price -= ticksize;
            
            if(account_type == HEDGE) {
                sl = NormalizeDouble(price + StopLoss, Digits());
                tp = NormalizeDouble(price - TakeProfit, Digits());
            }
            if(trade.SellLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, ea_comment)) {
               trade.ticket = trade.ResultOrder();
               opened_trades.Add(trade);
            }
            else {
                PrintFormat("Erro ao enviar ordem SELL_LIMIT. Id: %s Price: %f", _id, price );
            }
        }

        return true;
        PrintFormat("Nova ordem LIMIT enviada para o servidor. Id: %s Type: %s Lots: %f Price: %f", _id, EnumToString(type), Lots, price);
    }

    //+------------------------------------------------------------------+
    void updatePositionsBar()
    {
        Trade *trade;
        for(int i=0; i<opened_trades.Total(); i++) {
            trade = opened_trades[i];
            if(trade != NULL) {
                bool exists = PositionSelectByTicket(trade.ticket);
                if(exists && trade.tradeTP != NULL) {
                    if(maxPositionTimeToCLose > 0) {
                       datetime orderTime = (datetime)PositionGetInteger(POSITION_TIME);
                       datetime currentTime = TimeCurrent();
                       long diff = currentTime - orderTime;
                       //PrintFormat("Tempo de Posição aberta: %f", diff);
                       if(maxPositionTimeToCLose > 0 && diff > (maxPositionTimeToCLose*60)) { 
                           int type = (int)PositionGetInteger(POSITION_TYPE);
                           if(type == POSITION_TYPE_BUY) {
                               trade.tradeTP.OrderModify(trade.tradeTP.ticket, tick_arr[0].bid, 0, 0, ORDER_TIME_DAY, 0, 0);
                               PrintFormat("Tempo máximo de operação alcançado. Fechando posição BUY.");
                           }
                           else if(type == POSITION_TYPE_SELL) {
                               trade.tradeTP.OrderModify(trade.tradeTP.ticket, tick_arr[0].ask, 0, 0, ORDER_TIME_DAY, 0, 0);
                               PrintFormat("Tempo máximo de operação alcançado. Fechando posição SELL.");
                           }
                       }
                    }
                }
             }
         }
    }
    
//+------------------------------------------------------------------+
    void updatePositionsTick() {
        int size = opened_trades.Total();
        if(size <= 0) {
            return;
        }
        Trade *trade;
        CArrayInt remove;
        for(int i=0; i<size; i++) {
            trade = opened_trades[i];
            if(trade != NULL) {
                ENUM_ORDER_TYPE type = trade.RequestType();
                double opened_price = trade.RequestPrice();
                
                if(trade.filled && !trade.filled_tp && !trade.filled_sl)  {
                    if(account_type == NETTING) {
                        double stoploss = 0.0;
                        if(trade.tradeSL != NULL) {
                            if(type == ORDER_TYPE_BUY_LIMIT && tick_arr[0].bid > trade.tradeSL.RequestPrice()) {
                                trade.tradeSL.OrderModify(trade.tradeSL.ticket, tick_arr[0].bid, 0, 0, ORDER_TIME_DAY, 0, 0);
                            }
                            else if(type == ORDER_TYPE_SELL_LIMIT && tick_arr[0].ask < trade.tradeSL.RequestPrice()) {
                                trade.tradeSL.OrderModify(trade.tradeSL.ticket, tick_arr[0].ask, 0, 0, ORDER_TIME_DAY, 0, 0);
                            }
                            //PrintFormat("Ordem de StopLoss enviada com sucesso. Price: %f Ticket: %d", stoploss, trade.tradeSL.ticket);
                        }
                        if(trade.tradeSL == NULL ) {
                            
                            if(type == ORDER_TYPE_BUY_LIMIT) {
                                if(useTrailingStop) stoploss = NormalizeDouble(opened_price - trade.trailingStopLoss(), Digits());
                                else stoploss = NormalizeDouble(opened_price - StopLoss, Digits());

                                if(tick_arr[0].bid <= stoploss) {
                                    if(trade.deleteTakeProfit()) {
                                        trade.openStoplossLimit(tick_arr[0].bid); 
                                    }
                                }
                            }
                            else if(type == ORDER_TYPE_SELL_LIMIT) {
                                if(useTrailingStop) stoploss = NormalizeDouble(opened_price + trade.trailingStopLoss(), Digits());
                                else stoploss = NormalizeDouble(opened_price + StopLoss, Digits());
                                
                                if(tick_arr[0].ask >= stoploss) {
                                    if(trade.deleteTakeProfit()) {
                                        trade.openStoplossLimit(tick_arr[0].ask);
                                    }
                                }
                            }   
                        }
                    }
                    else {
                        //PrintFormat("Aguardando execução do StopLoss, ticket %d", trade.ticket);
                    }
                }
                else if(!trade.filled) {
                    if(type == ORDER_TYPE_BUY_LIMIT) {
                        double virtual_tp = NormalizeDouble(opened_price + TakeProfit, Digits());
                        if(tick_arr[0].bid >= virtual_tp) {
                            if(trade.OrderDelete(trade.ticket)) {
                                PrintFormat("TakeVirtual acionado. Apagando ordem limite de buy, ticket %d", trade.ticket);
                                trade.deleteTakeProfit(); 
                                remove.Add(i);
                            }
                            else {
                                PrintFormat("ERRO ao deletar ordem LIMIT de BUY após acionamento do TakeVirtual, ticket %d", trade.ticket);
                            }
                        }
                    }
                    else if(type == ORDER_TYPE_SELL_LIMIT) {
                        double virtual_tp = NormalizeDouble(opened_price - TakeProfit, Digits());
                        if(tick_arr[0].ask <= virtual_tp) {
                            if(trade.OrderDelete(trade.ticket)) {
                                PrintFormat("TakeVirtual acionado. Apagando ordem limite de sell, ticket %d", trade.ticket);
                                trade.deleteTakeProfit();  
                                remove.Add(i);
                            }
                            else {
                                PrintFormat("ERRO ao deletar ordem LIMIT de SELL após acionamento do TakeVirtual, ticket %d", trade.ticket);
                            }
                        }
                    }
                }
            }
         }
         for(int i=0; i < remove.Total(); i++) {
            opened_trades.Delete(remove[i]);
         }
    }
    //+------------------------------------------------------------------+
    void PrintMqlTradeTransaction(const MqlTradeTransaction &t) {
       PrintFormat("MqlTradeTransaction- deal: %d order: %d Symbol: %s Type: %s OrderType: %s OrderState: %s DealType: %s TimeType: %s TimeExpir.: %s Price: %f PriceTrigger: %f SL: %f TP: %f Volume: %f Position: %d PositionBy: %d", 
          t.deal, t.order, t.symbol, EnumToString(t.type), EnumToString(t.order_type), EnumToString(t.order_state),
          EnumToString(t.deal_type), EnumToString(t.time_type), TimeToString(t.time_expiration), t.price, t.price_trigger, 
          t.price_sl, t.price_tp, t.volume, t.position, t.position_by);
    }
    //+------------------------------------------------------------------+
    void PrintMqlTradeRequest(const MqlTradeRequest &req) {
       PrintFormat("MqlTradeRequest- Action: %s Magic: %d Order: %d Sym: %s Vol: %f Price: %f StopLimit: %f SL: %f TP: %f Deviation: %d OrderType: %s TypeFilling: %s TypeTime: %s, Expiration: %s Comment: %s  Position: %d PositionBy: %d",
          EnumToString(req.action), req.magic, req.order, req.symbol, req.volume, req.price, req.stoplimit,
          req.sl, req.tp, req.deviation, EnumToString(req.type), EnumToString(req.type_filling), EnumToString(req.type_time),
          TimeToString(req.expiration), req.comment, req.position, req.position_by);
    }
    //+------------------------------------------------------------------+
    void PrintMqlTradeResult(const MqlTradeResult &res) {
       PrintFormat("MqlTradeResult- RetCode: %d Deal: %d Order: %d Vol: %f Price: %f Bid: %f Ask: %f Comment: %s  RequestId: %d RetCodeExt: %d",
          res.retcode, res.deal, res.order, res.volume, res.price, res.bid, res.ask, res.comment, res.request_id, res.retcode_external);
    }
};

//+------------------------------------------------------------------+
PositionController positionCtrl;
//+------------------------------------------------------------------+