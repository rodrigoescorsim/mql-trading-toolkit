
double getNormalizedValue(double percentual) {
    MqlTick tick;
    SymbolInfoTick(Symbol(), tick);
    double price = (tick.bid * percentual)/100.0;
    return tickNormalized(price);  
}

double tickNormalized(double price) {
    double ticksize= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
    return ((int)(price / ticksize)) * ticksize;
}