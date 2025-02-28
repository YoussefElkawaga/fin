class StockRecommendation {
  final String symbol;
  final String name;
  final double currentPrice;
  final double potentialReturn;
  final String analystRating;
  final String source;
  final List<String> insights;

  StockRecommendation({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.potentialReturn,
    required this.analystRating,
    required this.source,
    this.insights = const [],
  });
} 