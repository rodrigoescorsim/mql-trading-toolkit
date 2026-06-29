#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+

class Trade: public CTrade
{
public:
    string id;
    double stopLoss;
    double takeProfit;
    double trailingStop;
    double breakeven;
    ulong ticket;
    double open_price;
    datetime open_time;
    double volume;
    double take_distance;
    double last_trailingStop;
    bool filled;
    bool filled_tp;
    bool filled_sl;
    Trade * tradeTP;
    Trade * tradeSL;

    //+------------------------------------------------------------------+    
    Trade(string _id, double _sl, double _tp) : id(_id), stopLoss(_sl), takeProfit(_tp), trailingStop(0), breakeven(0), ticket(0), open_price(0.0), open_time(0), volume(0.0), take_distance(0.0), last_trailingStop(0), filled(false), filled_tp(false), filled_sl(false), tradeTP(NULL), tradeSL(NULL) {
    
    }
    //+------------------------------------------------------------------+    
    Trade(string _id, double _sl, double _tp, double _ts, double _be = 0.0) : id(_id), stopLoss(_sl), takeProfit(_tp), trailingStop(_ts), breakeven(_be), ticket(0), open_price(0.0), open_time(0), volume(0.0), take_distance(0.0), last_trailingStop(0), filled(false), filled_tp(false), filled_sl(false), tradeTP(NULL), tradeSL(NULL) {
    
    }
    //+------------------------------------------------------------------+
    ~Trade() {
        if(tradeTP) delete tradeTP;
        if(tradeSL) delete tradeSL;
    }
    //+------------------------------------------------------------------+
    void close() {
        if(!filled) {
            OrderDelete(ticket);
            PrintFormat("OrderDelete: deletando ordem pendente ticket: %d", ticket);
        }
        else {
            for(int i = 0; i < 500; i++) {
                if(PositionClose(ticket)) {
                    PrintFormat("PositionClose: encerrando posição ticket: %d", ticket);
                    break;
                }
                else {
                    PrintFormat("Error PositionClose: ticket: %d idError: %d", ticket, GetLastError());
                    Sleep(100);
                }
            }
            

        }
    }
    //+------------------------------------------------------------------+
    void openTakeProfit() {
        Trade *trade = new Trade(id, 0, 0);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            double takeprofit = NormalizeDouble(RequestPrice() + takeProfit, Digits());
            if(trade.SellLimit(lots, takeprofit, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
               trade.ticket = trade.ResultOrder();
               tradeTP = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem TAKE_PROFIT. Price: %f", takeprofit );
                delete trade;
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            double takeprofit = NormalizeDouble(RequestPrice() - takeProfit, Digits());
            if(trade.BuyLimit(lots, takeprofit, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
               trade.ticket = trade.ResultOrder();
               tradeTP = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem TAKE_PROFIT. Price: %f", takeprofit );
                delete trade;
            }
        }
    }
    //+------------------------------------------------------------------+
    void openStoploss() {
        Trade *trade = new Trade(id, 0, 0);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            double stoploss = NormalizeDouble(RequestPrice() - stopLoss, Digits());
            if(trade.SellStop(lots, stoploss, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", stoploss );
                delete trade;
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            double stoploss = NormalizeDouble(RequestPrice() + stopLoss, Digits());
            if(trade.BuyStop(lots, stoploss, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", stoploss );
                delete trade;
            }
        }
    }
    //+------------------------------------------------------------------+
    void openStoplossLimit(double price) {
        Trade *trade = new Trade(id, 0, 0);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        double ticksize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
        price = ((int)(price / ticksize)) * ticksize;
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            if(trade.SellLimit(lots, price, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", price );
                delete trade;
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            if(trade.BuyLimit(lots, price, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", price );
                delete trade;
            }
        }     
    }
    //+------------------------------------------------------------------+
    void openStoplossLimit() {
        Trade *trade = new Trade(id, 0, 0);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            if(trade.SellLimit(lots, tick_arr[0].bid, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", tick_arr[0].bid );
                delete trade;
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            if(trade.BuyLimit(lots, tick_arr[0].ask, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem STOPLOSS. Price: %f", tick_arr[0].ask );
                delete trade;
            }
        }     
    }
    //+------------------------------------------------------------------+
    bool deleteTakeProfit() {
        if(tradeTP != NULL) {
            if(!tradeTP.OrderDelete(tradeTP.ticket)) {
                PrintFormat("Erro ao deletar ordem de TakeProfit, ticket %d", tradeTP.ticket);
                return false;
            }
        }
        return true;
    }
    //+------------------------------------------------------------------+
    bool deleteStopLoss() {
        if(tradeSL != NULL) {
            if(!tradeSL.OrderDelete(tradeSL.ticket)) {
                PrintFormat("Erro ao deletar ordem de StopLoss, ticket %d", tradeSL.ticket);
                return false;
            }
        }
        return true;
    }
    //+------------------------------------------------------------------+
    bool isAccepted()
    {
        if (ResultRetcode() == 10009 || ResultRetcode() == 10008)
            return true;
        return false;
    }
    //+------------------------------------------------------------------+
    /*double trailingStopLoss() {
        datetime current_time = TimeCurrent();
        int elapsed = (int)(current_time - open_time);
        double stoploss = StopLoss;
        
        if(elapsed >= trailingStopSeconds) {
            if(RequestType() == ORDER_TYPE_BUY_LIMIT) {
                double current_take_distance = (RequestPrice() + TakeProfit) - tick_arr[0].bid;
                if(current_take_distance > (TakeProfit - trailingStopPoints)) current_take_distance = TakeProfit;
                if(take_distance == 0 || current_take_distance < take_distance) {
                    take_distance = current_take_distance;
                }
                double multiplier = (StopLoss + TakeProfit) / TakeProfit;
                stoploss = (take_distance * multiplier) - TakeProfit + trailingStopMinDistPoints;
            }
            else if(RequestType() == ORDER_TYPE_SELL_LIMIT) {
                double current_take_distance = tick_arr[0].ask - (RequestPrice() - TakeProfit);
                if(current_take_distance > (TakeProfit - trailingStopPoints)) current_take_distance = TakeProfit;
                if(take_distance == 0 || current_take_distance < take_distance) {
                    take_distance = current_take_distance;
                }
                double multiplier = (StopLoss + TakeProfit) / TakeProfit;
                stoploss = (take_distance * multiplier) - TakeProfit + trailingStopMinDistPoints;
            }
        }
        return stoploss ;
    }*/
    //+------------------------------------------------------------------+
    
};