class MarketOverview {
  final String countryCode;
  final Map<String, dynamic> marketData;
  final List<MarketMetric> metrics;
  final MarketStatus status;

  MarketOverview({
    required this.countryCode,
    required this.marketData,
    required this.metrics,
    required this.status,
  });
}

class MarketMetric {
  final String name;
  final double value;
  final double change;
  final String unit;
  final MetricType type;

  MarketMetric({
    required this.name,
    required this.value,
    required this.change,
    required this.unit,
    required this.type,
  });
}

class MarketStatus {
  final double volatility;
  final String trend;
  final String sentiment;
  final double confidence;

  MarketStatus({
    required this.volatility,
    required this.trend,
    required this.sentiment,
    required this.confidence,
  });
}

enum MetricType {
  marketIndex,
  currency,
  interest,
  inflation,
  gdp,
  unemployment
} 