class StockPrice {
  final String symbol;
  final double currentPrice;
  final double openPrice;
  final double dayHigh;
  final double dayLow;
  final double volume;

  StockPrice({
    required this.symbol,
    required this.currentPrice,
    required this.openPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
  });
} 