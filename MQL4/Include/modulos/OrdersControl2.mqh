//+------------------------------------------------------------------+
//|                                                ordersControl.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict
#include "HashMap2.mqh"

//+------------------------------------------------------------------+
//| STRUCTURES, CLASS AND TEMPLATES                            
//+------------------------------------------------------------------+
static int setup_count_ = 7;

class Order
{
public:
   int ticket;
   int orderType;
   int iSetup, iSymbol;
   double profit;
   double commission;
   double lots;
   double swap;
   datetime openTime, timeAux;
   bool expired;
   Order * next;
   Order * previous;
   Order(int _ticket, int _iSymbol, int _iSetup, int _orderType, double _lots, double _profit, double _commission, double _swap, datetime _openTime){
      this.ticket = _ticket;
      this.iSymbol = _iSymbol;
      this.iSetup = _iSetup;
      this.orderType = _orderType;
      this.next = NULL;
      this.previous = NULL;
      this.lots = _lots;
      this.profit = _profit;
      this.commission = _commission;
      this.swap = _swap;
      this.openTime = _openTime;
      this.timeAux = 0;
      this.expired = false;
   }
   Order(){
      this.ticket = this.iSetup = this.orderType = 0; this.openTime = 0; this.timeAux = 0;
      this.next = NULL; this.previous = NULL; this.expired = false;
      this.lots = this.profit = this.commission = this.swap = 0.0;
   }
   double getNetProfit(){
      return this.profit + this.commission + this.swap;
   }
   string getOrderStr(){
      return StringConcatenate("Order-> Ticket(",ticket,"),iSymbol(",iSymbol,"),iSetup(",iSetup,"),OrderType(",orderType,"),Profit(",profit,"),OpenTime(",openTime,")");
   }
};
/// Convenience class for storing objects as hash values.
class HashOrder : public HashValue {
    private:
        Order *val;
    public:
        HashOrder(Order *v) { val=v;}
        ~HashOrder(){ if(val != NULL) delete(val); }
        Order* getVal() { return val; }
};
class OrdersBySetup{
public:
   int openOrders, closedOrders;
   double openProfit, openCommission, openSwap, openNetProfit;
   double closedProfit, closedCommission, closedSwap, closedNetProfit;
   
   int countBuy, countSell;
   Order * first;
   Order * last;
   OrdersBySetup(){
      openOrders = closedOrders = 0;
      openProfit = openCommission = openSwap = openNetProfit = 0.0;
      closedProfit = closedCommission = closedSwap = closedNetProfit = 0.0;
      countBuy = countSell = 0;
      first = last = NULL;
   }
   void addOrder_no(Order *_order){
      if(first == NULL){ first = _order; last = _order; }
      else{
         this.last.next = _order;
         _order.previous = this.last;
         this.last = _order;
      }
      this.openOrders++;  
      if(_order.orderType == OP_BUY || _order.orderType == OP_BUYLIMIT || _order.orderType == OP_BUYSTOP) this.countBuy++;
      else if(_order.orderType == OP_SELL || _order.orderType == OP_SELLLIMIT || _order.orderType == OP_SELLSTOP) this.countSell++;
   }
   Order* removeOrder_no(int _ticket){
      Order * aux = NULL;
      Order * current = first;
      while(current != NULL){
         if(current.ticket == _ticket){
            aux = current;
            if(first == aux){
               first = aux.next;
               if(first != NULL) first.previous = NULL;
            }
            else if(last == aux){
               last = aux.previous;
               if(last != NULL) last.next = NULL;
            }
            else{
               aux.previous.next = aux.next;
               aux.next.previous = aux.previous;
            }
            this.openOrders--;
            this.closedOrders++;    
            if(OrderSelect(_ticket, SELECT_BY_TICKET, MODE_HISTORY)){
               //Print(StringConcatenate("RemoveOrder_no: ticket: ",_ticket,", preClosedProfit: ",closedProfit,", OrderProfit: ",OrderProfit()));
               closedProfit += OrderProfit();
               closedCommission += OrderCommission();
               closedSwap += OrderSwap();
               closedNetProfit = closedProfit + closedCommission + closedSwap;
            }
            else Print(StringConcatenate("ERROR in removeOrder_no: OrderSelect(",_ticket,", SELECT_BY_TICKET, MODE_HISTORY) return false."));
            
            if(aux.orderType == OP_BUY || aux.orderType == OP_BUYLIMIT || aux.orderType == OP_BUYSTOP) this.countBuy--;
            else if(aux.orderType == OP_SELL || aux.orderType == OP_SELLLIMIT || aux.orderType == OP_SELLSTOP) this.countSell--;
            break;
         }
         current = current.next;
      }
      return aux;
   }
   Order* getOrder_no(int _ticket){
      Order * aux = NULL;
      Order * current = first;
      while(current != NULL){
         if(current.ticket == _ticket){
            aux = current;
            break;
         }
         current = current.next;
      }
      return aux;
   }
   void updateProfitBySetup(){
      Order * aux = NULL;
      Order * current = first;
      openProfit = openCommission = openSwap = openNetProfit = 0.0;
      while(current != NULL){
         openProfit += current.profit;
         openCommission += current.commission;
         openSwap += current.swap;
         openNetProfit += current.getNetProfit();
         current = current.next;
      }
   }
};

class OrdersBySymbol
{
public:
   string symbol;
   int countBySymbol, countBuyBySymbol, countSellBySymbol;
   OrdersBySetup* ordersBySetup[7];
   
   void resetSymbol(string _sym){
      this.countBySymbol = this.countBuyBySymbol = this.countSellBySymbol = 0;
      this.symbol = _sym;
      for(int _iSetup = 0; _iSetup < setup_count_; _iSetup++){
         if(ordersBySetup[_iSetup] != NULL) delete(ordersBySetup[_iSetup]);
         ordersBySetup[_iSetup] = new OrdersBySetup();
      }
   }
   void addOrder(Order *_order){
      this.ordersBySetup[_order.iSetup].addOrder_no(_order);
      this.countBySymbol++;
      if(_order.orderType == OP_BUY) countBuyBySymbol++;
      else if(_order.orderType == OP_SELL) countSellBySymbol++;
   }
   //void addOrder(int _ticket, int _setup, int _orderType, double _profit){
   //   this.ordersBySetup[_setup].addOrder_no(new Order(_ticket, _setup, _orderType, _profit));
   //   this.countBySymbol++; ordersOpen++;
   //} 
   Order* removeOrder(int _ticket, int _setup){
      Order* removed = ordersBySetup[_setup].removeOrder_no(_ticket);
      Order* next = NULL;
      if(removed != NULL){
         this.countBySymbol--;
         if(removed.orderType == OP_BUY) countBuyBySymbol--;
         else if(removed.orderType == OP_SELL) countSellBySymbol--;
         next = removed.next;
      }
      return removed;
   }
   /*Order* getOrderByTicket(int _ticket){
      Order* aux = NULL;
      for(int _iTF = 0; _iTF < setup_count_; _iTF++){
         aux = this.ordersBySetup[_iTF].getOrder_no(_ticket);
         if(aux != NULL) break;
      }
      return aux;
   }*/
   Order* getOrder(int _iSetup, int _ticket){
      Order* aux = NULL;
      aux = this.ordersBySetup[_iSetup].getOrder_no(_ticket);
      return aux;
   }  
};

template <typename T> 
void Remove(T& A[], int iPos){
   int iLast = ArraySize(A) - 1;
   A[iPos] = A[iLast];
   ArrayResize(A, iLast);
}
                                     