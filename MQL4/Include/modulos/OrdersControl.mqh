//+------------------------------------------------------------------+
//|                                                ordersControl.mqh |
//|                                            Rodrigo Maia Escorsim |
//|                                       rodrigo.escorsim@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Maia Escorsim"
#property link      "rodrigo.escorsim@gmail.com"
#property strict

//+------------------------------------------------------------------+
//| STRUCTURES, CLASS AND TEMPLATES                            
//+------------------------------------------------------------------+
class Order
{
public:
   int ticket;
   int orderType;
   int timeframe;
   Order * next;
   Order * previous;
   Order(int _ticket, int _timeframe, int _orderType){
      this.ticket = _ticket;
      this.timeframe = _timeframe;
      this.orderType = _orderType;
      this.next = NULL;
      this.previous = NULL;
   }
   Order(){
      this.ticket = 0; 
      this.timeframe = 0;
      this.orderType = 0;
      this.next = NULL;
      this.previous = NULL;
   }
};
class OrdersByTF{
public:
   int count;
   Order * first;
   Order * last;
   OrdersByTF(){
      count = 0;
      first = last = NULL;
   }
   void addOrder_no(Order *order){
      if(first == NULL){ first = order; last = order; }
      else{
         this.last.next = order;
         order.previous = this.last;
         this.last = order;
      }
      this.count++;   
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
            this.count--;    
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
};

class OrdersBySymbol
{
public:
   string symbol;
   int countTotal;
   int countBuyByTF[7];
   int countSellByTF[7];
   OrdersByTF* ordersByTF[7];
   
   void resetSymbol(string _sym){
      this.countTotal=0;
      this.symbol = _sym;
      for(int _iTF = 0; _iTF < timeframes_count; _iTF++){
         this.countBuyByTF[_iTF] = 0;
         this.countSellByTF[_iTF] = 0;
         //if(timeframesInUse[iTF]){
            ordersByTF[_iTF] = new OrdersByTF();
         //}
      }
   }
   int getCountOrdersByTF(int _iTF){
      return this.ordersByTF[_iTF].count;
   }
   void addOrder(int _ticket, int _TF, int _orderType){
      int _iTF = TimeFrameToPos(_TF);
      this.ordersByTF[_iTF].addOrder_no(new Order(_ticket, timeframes[_iTF], _orderType));
      this.countTotal++; ordersOpen++;
      if(_orderType == OP_BUY || _orderType == OP_BUYLIMIT || _orderType == OP_BUYSTOP) this.countBuyByTF[_iTF]++;
      else if(_orderType == OP_SELL || _orderType == OP_SELLLIMIT || _orderType == OP_SELLSTOP) this.countSellByTF[_iTF]++;
   } 
   Order* removeOrder(int _ticket, int _TF){
      int _iTF = TimeFrameToPos(_TF);
      Order* removed = ordersByTF[_iTF].removeOrder_no(_ticket);
      Order* next = NULL;
      if(removed != NULL){
         this.countTotal--; ordersOpen--;
         int _orderType = removed.orderType;
         if(_orderType == OP_BUY || _orderType == OP_BUYLIMIT || _orderType == OP_BUYSTOP) this.countBuyByTF[_iTF]--;
         else if(_orderType == OP_SELL || _orderType == OP_SELLLIMIT || _orderType == OP_SELLSTOP) this.countSellByTF[_iTF]--;
         next = removed.next;
         delete(removed);
      }
      return next;
   }
   Order* getOrderByTicket(int _ticket){
      Order* aux = NULL;
      for(int _iTF = 0; _iTF < timeframes_count; _iTF++){
         aux = this.ordersByTF[_iTF].getOrder_no(_ticket);
         if(aux != NULL) break;
      }
      return aux;
   }  
};

template <typename T> 
void Remove(T& A[], int iPos){
   int iLast = ArraySize(A) - 1;
   A[iPos] = A[iLast];
   ArrayResize(A, iLast);
}
                                     