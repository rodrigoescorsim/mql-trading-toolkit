

void PrintMqlTradeTransaction(const MqlTradeTransaction &t) {

   PrintFormat("MqlTradeTransaction- deal: %d order: %d Symbol: %s Type: %s OrderType: %s OrderState: %s DealType: %s TimeType: %s TimeExpir.: %s Price: %f PriceTrigger: %f SL: %f TP: %f Volume: %f Position: %d PositionBy: %d", 
      t.deal, t.order, t.symbol, EnumToString(t.type), EnumToString(t.order_type), EnumToString(t.order_state),
      EnumToString(t.deal_type), EnumToString(t.time_type), TimeToString(t.time_expiration), t.price, t.price_trigger, 
      t.price_sl, t.price_tp, t.volume, t.position, t.position_by);
}

void PrintMqlTradeRequest(const MqlTradeRequest &req) {
   PrintFormat("MqlTradeRequest- Action: %s Magic: %d Order: %d Sym: %s Vol: %f Price: %f StopLimit: %f SL: %f TP: %f Deviation: %d OrderType: %s TypeFilling: %s TypeTime: %s, Expiration: %s Comment: %s  Position: %d PositionBy: %d",
      EnumToString(req.action), req.magic, req.order, req.symbol, req.volume, req.price, req.stoplimit,
      req.sl, req.tp, req.deviation, EnumToString(req.type), EnumToString(req.type_filling), EnumToString(req.type_time),
      TimeToString(req.expiration), req.comment, req.position, req.position_by);
}

void PrintMqlTradeResult(const MqlTradeResult &res) {
   PrintFormat("MqlTradeResult- RetCode: %d Deal: %d Order: %d Vol: %f Price: %f Bid: %f Ask: %f Comment: %s  RequestId: %d RetCodeExt: %d",
      res.retcode, res.deal, res.order, res.volume, res.price, res.bid, res.ask, res.comment, res.request_id, res.retcode_external);
}