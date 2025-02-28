class PriceAlert {
  final String symbol;
  final double targetPrice;
  final bool isAbove;
  final bool isEnabled;

  PriceAlert({
    required this.symbol,
    required this.targetPrice,
    required this.isAbove,
    this.isEnabled = true,
  });
} 