#include <Trade\Trade.mqh>
#include "Util.mqh"

//+------------------------------------------------------------------+

class Trade: public CTrade
{
public:
    string id;
    ulong ticket;
    double open_price;
    double take_distance;
    double stop_distance;
    double reference_price;
    bool filled;
    bool filled_tp;
    bool filled_sl;
    Trade * tradeTP;
    Trade * tradeSL;

    //+------------------------------------------------------------------+    
    Trade(string _id) : id(_id), ticket(0), open_price(0.0), take_distance(0.0), stop_distance(0.0), reference_price(0.0), filled(false), filled_tp(false), filled_sl(false), tradeTP(NULL), tradeSL(NULL) {
    
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
        }
        else {
           if(account_type == NETTING) {
                openStoplossLimit(tick_arr[0].bid);
                if(tradeTP != NULL) {
                    OrderDelete(tradeTP.ticket);
                }
                PrintFormat("CloseOrder: encerrando posição netting ticket: %d", ticket);
            }
            else {
                PositionClose(ticket);  // Close the selected position 
                PrintFormat("CloseOrder: encerrando posição hedge ticket: %d", ticket);
            }
        }
    }
    //+------------------------------------------------------------------+
    void openTakeProfit() {
        Trade *trade = new Trade(id);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            double takeprofit = NormalizeDouble(RequestPrice() + TakeProfit, Digits());
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
            double takeprofit = NormalizeDouble(RequestPrice() - TakeProfit, Digits());
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
        Trade *trade = new Trade(id);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        double ticksize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            double stoploss = NormalizeDouble(RequestPrice() - StopLoss, Digits());
            stoploss = ((int)(stoploss / ticksize)) * ticksize;
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
            double stoploss = NormalizeDouble(RequestPrice() + StopLoss, Digits());
            stoploss = ((int)(stoploss / ticksize)) * ticksize;
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
        Trade *trade = new Trade(id);
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
                PrintFormat("Erro ao enviar ordem BUY LIMIT. Price: %f", price );
                delete trade;
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            
            if(trade.BuyLimit(lots, price, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                trade.ticket = trade.ResultOrder();
                tradeSL = trade;
            }
            else {
                PrintFormat("Erro ao enviar ordem SELL LIMIT. Price: %f", price );
                delete trade;
            } 
        }     
    }
    //+------------------------------------------------------------------+
    void openStoplossLimit() {
        Trade *trade = new Trade(id);
        trade.SetExpertMagicNumber(order_magic);
        double lots = RequestVolume();
        double ticksize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
        ENUM_ORDER_TYPE type = RequestType();
        if(type == ORDER_TYPE_BUY_LIMIT) {
            for(int i = 0; i < 5; i++) {
                MqlTick tick;
                SymbolInfoTick(Symbol(), tick);
                double price = ((int)(tick.bid / ticksize)) * ticksize;
                if(trade.SellLimit(lots, price, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                    trade.ticket = trade.ResultOrder();
                    tradeSL = trade;
                    break;
                }
                else {
                    PrintFormat("Erro ao enviar ordem BUY LIMIT. Price: %f", tick_arr[0].bid );
                }
            }
        }
        else if(type == ORDER_TYPE_SELL_LIMIT) {
            for(int i = 0; i < 5; i++) {
                MqlTick tick;
                SymbolInfoTick(Symbol(), tick);
                double price = ((int)(tick.ask / ticksize)) * ticksize;
                if(trade.BuyLimit(lots, price, _Symbol, 0, 0, ORDER_TIME_DAY, 0, ea_comment)) {
                    trade.ticket = trade.ResultOrder();
                    tradeSL = trade;
                    break;
                }
                else {
                    PrintFormat("Erro ao enviar ordem SELL LIMIT. Price: %f", tick_arr[0].ask );
                }
            }
        }     
    }
    //+------------------------------------------------------------------+
    bool deleteTakeProfit() {
        if(tradeTP != NULL) {
            
            if(!tradeTP.OrderDelete(tradeTP.ticket)) {
                PrintFormat("Erro ao deletar ordem de TakeProfit, ticket %d Error: %d", tradeTP.ticket, GetLastError());
                return false;
            }
        }
        return true;
    }
    //+------------------------------------------------------------------+
    bool deleteStopLoss() {
        if(tradeSL != NULL) {
            if(!tradeSL.OrderDelete(tradeSL.ticket)) {
                PrintFormat("Erro ao deletar ordem de StopLoss, ticket %d Error: %d", tradeSL.ticket, GetLastError());
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
    double trailingStopLoss() {
        double stoploss = StopLoss;    
    
        if(RequestType() == ORDER_TYPE_BUY_LIMIT) {
            double current_take_distance = (RequestPrice() + TakeProfit) - tick_arr[0].bid;
            if(current_take_distance > TakeProfit) current_take_distance = TakeProfit;
            if(take_distance == 0 || current_take_distance < take_distance) {
                take_distance = current_take_distance;
            }
            double multiplier = (StopLoss + TakeProfit) / TakeProfit;
            stoploss = (take_distance * multiplier) - TakeProfit;
        }
        else if(RequestType() == ORDER_TYPE_SELL_LIMIT) {
            double current_take_distance = tick_arr[0].ask - (RequestPrice() - TakeProfit);
            if(current_take_distance > TakeProfit) current_take_distance = TakeProfit;
            if(take_distance == 0 || current_take_distance < take_distance) {
                take_distance = current_take_distance;
            }
            double multiplier = (StopLoss + TakeProfit) / TakeProfit;
            stoploss = (take_distance * multiplier) - TakeProfit;
        }
        return stoploss ;
    }
    //+------------------------------------------------------------------+
    double updateTrailingTakeProfit() {
        double takeprofit = TakeProfit;
        CTrade trade;   
        
        if(open_price == 0.0) open_price = RequestPrice();

        if(RequestType() == ORDER_TYPE_SELL_LIMIT) {
            double stopCalculated = reference_price - StopLoss;
            double current_stop_distance = tick_arr[0].bid - stopCalculated;
            
            if(current_stop_distance > StopLoss) { 
                current_stop_distance = StopLoss;
             }
            
            if(stop_distance == 0 || current_stop_distance < stop_distance) 
                stop_distance = current_stop_distance;
                
            double distance = (StopLoss + TakeProfit) / 2;
            double multiplier = ((StopLoss - stop_distance) / StopLoss);
            takeprofit = TakeProfit - (distance *  multiplier);
            double newTP = reference_price + takeprofit;
            
            if(newTP < open_price) {
                //PrintFormat("TrailingTakeProfit (BUY) NewTP: %f  RequestPrice(): %f", newTP, RequestPrice());
                trade.OrderModify(ticket, tickNormalized(newTP), 0, 0, ORDER_TIME_DAY, 0, 0);
                open_price = newTP;
            }
        }
        else if(RequestType() == ORDER_TYPE_BUY_LIMIT) {
            double stopCalculated = reference_price + StopLoss;
            double current_stop_distance = stopCalculated -  tick_arr[0].bid;
            
            if(current_stop_distance > StopLoss) { 
                current_stop_distance = StopLoss;
             }
             
            if(stop_distance == 0 || current_stop_distance < stop_distance) 
                stop_distance = current_stop_distance;
                
            double distance = (StopLoss + TakeProfit) / 2;
            double multiplier = ((StopLoss - stop_distance) / StopLoss);
            takeprofit = TakeProfit - (distance *  multiplier);
            
            double newTP = reference_price - takeprofit;

            if(newTP > open_price) {
                //PrintFormat("TrailingTakeProfit (SELL) NewTP: %f  RequestPrice(): %f", newTP, RequestPrice());
                trade.OrderModify(ticket, tickNormalized(newTP), 0, 0, ORDER_TIME_DAY, 0, 0); 
                open_price = newTP;
            }
            
        }
        return takeprofit;
    }
    //+------------------------------------------------------------------+
};