class StockPrediction {
  final String symbol;
  final List<double> futurePrices;
  final double confidence;
  final String predictionDate;
  final PredictionMetrics metrics;

  StockPrediction({
    required this.symbol,
    required this.futurePrices,
    required this.confidence,
    required this.predictionDate,
    required this.metrics,
  });

  factory StockPrediction.fromJson(Map<String, dynamic> json) {
    return StockPrediction(
      symbol: json['symbol'] as String,
      futurePrices: (json['future_prices'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      predictionDate: json['prediction_date'] as String,
      metrics: PredictionMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
    );
  }
}

class PredictionMetrics {
  final double volatility;
  final String trend;
  final String riskLevel;

  PredictionMetrics({
    required this.volatility,
    required this.trend,
    required this.riskLevel,
  });

  factory PredictionMetrics.fromJson(Map<String, dynamic> json) {
    return PredictionMetrics(
      volatility: (json['volatility'] as num).toDouble(),
      trend: json['trend'] as String,
      riskLevel: json['risk_level'] as String,
    );
  }
} 