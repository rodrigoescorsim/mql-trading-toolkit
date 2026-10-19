# mql-trading-toolkit

A collection of Expert Advisors and Indicators for MetaTrader 4 and MetaTrader 5, built over 15+ years of algorithmic trading development.

All projects are original work — production-tested on live accounts across forex, indices, and commodities.

---

## Expert Advisors

### MQL5

| EA | Description |
|----|-------------|
| **[OTRX-HFT-Arbitrage](MQL5/Experts/OTRX-HFT-ARBITRAGEM/)** | HFT arbitrage between two brokers via ZeroMQ TCP socket. Routes signals from a fast broker to a slow broker in real time. |
| **[Tesla2](MQL5/Experts/Tesla2/)** | Fibonacci Fan breakout system with modular architecture (FiboFan, PositionController, BB, ATR, ADX). Supports backtest, trial, and sale deployment modes. |
| **[CandleX](MQL5/Experts/CandleX/)** | Entry filter based on candle geometry — minimum/maximum body size, shadow ratio, and timing window. Modular: TickController, BarController, PositionController. |
| **[Control](MQL5/Experts/Control/)** | Multi-filter EA with ATR, ADX, and FastMA confirmation. Designed for B3 (Brazilian stock exchange) instruments. |
| **[ProjecaoM15](MQL5/Experts/ProjecaoM15/)** | Trades Fibonacci projections on M15. Modules: Projection, Bollinger Bands, MA, ATR, ADX, Economic Calendar, BarController. |
| **[EagleBot](MQL5/Experts/EagleBot/)** | Modular EA with account-based licensing infrastructure. |
| **[FibotPhi](MQL5/Experts/FibotPhi/)** | Fibonacci PHI ratio breakout strategy. |
| **[quotex](MQL5/Experts/quotex/)** | Multi-symbol pattern scanner — monitors 30+ forex pairs, indices, and crypto across 14 timeframes (M2 to H4). No external dependencies. |

### MQL4

| EA | Description |
|----|-------------|
| **[ExtremeTmaTrader](MQL4/Experts/ExtremeTmaTrader/)** | The most architecturally complex EA in this collection. TMA + Center of Gravity strategy with 12+ include modules: EACore, EAIndicatorsMatch, EAMarginControl, EATma, EACoG, EAValueChart, EAPower, EADistances, EATradeTime, EAMACD, EABar. |
| **[HeikenTS](MQL4/Experts/HeikenTS/)** | Trailing stop manager based on Heiken Ashi candle direction. Supports partial close after N positive candles, directional filter (buy/sell/both), and maps positions via CHashMap. |
| **[TPX-HEDGE-Media9-EA](MQL4/Experts/TPX-HEDGE-Media9-EA/)** | Multi-symbol hedge EA. Opens a hedge position when MA(9) closes against the original trade. Configurable ATR take profit, partial close, and pairs via CSV file. |
| **[TPX-SupplyDemand-EA](MQL4/Experts/TPX-SupplyDemand-EA/)** | Multi-symbol EA that reads Supply & Demand zones from an external indicator and filters entries with Heiken Ashi and configurable risk/reward ratio. |

---

## Indicators

### MQL5

| Indicator | Description |
|-----------|-------------|
| **[TPX-DashDidi (MT5)](MQL5/Indicators/TPX-DashDidi/)** | Multi-symbol Didi Index dashboard for MT5. Monitors ~40 currency pairs across 4 timeframes with Heiken Ashi filter. |

### MQL4

| Indicator | Description |
|-----------|-------------|
| **[TPX-DashDidi (MT4)](MQL4/Indicators/TPX-DashDidi/)** | Multi-symbol Didi Index dashboard for MT4. Automatically opens charts with a configurable template. |
| **[TPX-DashPvaVolumes](MQL4/Indicators/TPX-DashPvaVolumes/)** | Multi-symbol PVA (Price Volume Analysis) dashboard. Displays volume signals per pair across multiple timeframes. |

---

## Installation

**MT4:**
1. Copy the `.mq4` or `.ex4` file to `[MetaTrader 4 data folder]/MQL4/Experts/` or `/Indicators/`
2. Restart MetaTrader or right-click the Navigator → Refresh
3. Drag onto a chart and configure inputs

**MT5:**
1. Copy the `.mq5` or `.ex5` file to `[MetaTrader 5 data folder]/MQL5/Experts/` or `/Indicators/`
2. Restart MetaTrader or right-click the Navigator → Refresh
3. Drag onto a chart and configure inputs

For EAs that use `#include` modules (ExtremeTmaTrader, HeikenTS, Tesla2, etc.), copy the entire project folder — the includes must be in the same directory as the main `.mq4`/`.mq5` file, or in the platform's `/Include/` folder.

---

## Requirements

- MetaTrader 4 or MetaTrader 5
- MQL4/MQL5 compiler (included in the platform)
- For OTRX-HFT-Arbitrage: ZeroMQ library for MQL5 (`Zmq.mqh`)

---

## Author

**Rodrigo Escorsim** — Senior C++ & MQL Developer  
[GitHub](https://github.com/rodrigoescorsim) · [LinkedIn](https://linkedin.com/in/rodrigoescorsim)
