import 'package:fin/features/home/data/models/market_data.dart';
import 'package:fin/core/network/api_client.dart';
import 'dart:math';
import 'package:fin/features/home/data/models/chart_data.dart';

class MarketRepository {
  final ApiClient _apiClient;
  
  MarketRepository(this._apiClient);
  
  Future<MarketData> getMarketData({String timeframe = '1D'}) async {
    try {
      final response = await _apiClient.getMarketData(timeframe: timeframe);
      final data = response.data;
      
      // Process historical data
      final List<dynamic> historicalPrices = data['historical_prices'] ?? [];
      List<ChartData> historicalData = historicalPrices.map((point) {
        return ChartData(
          timestamp: DateTime.fromMillisecondsSinceEpoch(point['timestamp']),
          price: point['price'].toDouble(),
          volume: point['volume'].toDouble(),
        );
      }).toList();

      // Calculate market metrics
      double totalVolume = historicalData.fold(0, (sum, point) => sum + point.volume);
      int advancingStocks = data['advancing_stocks'] ?? 0;
      int decliningStocks = data['declining_stocks'] ?? 0;
      double volatilityIndex = _calculateVolatility(historicalData);
      
      return MarketData(
        currentPrice: historicalData.last.price,
        percentageChange: _calculatePercentageChange(historicalData),
        riskScore: _calculateRiskScore(volatilityIndex),
        sentiment: _calculateMarketSentiment(advancingStocks, decliningStocks),
        recentNews: _processNewsData(data['news'] ?? []),
        totalVolume: totalVolume,
        advancingStocks: advancingStocks,
        decliningStocks: decliningStocks,
        volatilityIndex: volatilityIndex,
        historicalData: historicalData,
        marketSentiment: _getMarketSentiment(advancingStocks, decliningStocks),
      );
    } catch (e) {
      throw Exception('Failed to process market data: $e');
    }
  }
  
  double _calculateVolatility(List<ChartData> data) {
    if (data.length < 2) return 0;
    final prices = data.map((e) => e.price).toList();
    final returns = List.generate(prices.length - 1, 
      (i) => (prices[i + 1] - prices[i]) / prices[i]);
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final squaredDiffs = returns.map((r) => (r - mean) * (r - mean));
    return sqrt(squaredDiffs.reduce((a, b) => a + b) / (returns.length - 1)) * sqrt(252);
  }
  
  String _getMarketSentiment(int advancing, int declining) {
    final ratio = advancing / (advancing + declining);
    if (ratio > 0.65) return 'Bullish';
    if (ratio > 0.55) return 'Moderately Bullish';
    if (ratio > 0.45) return 'Neutral';
    if (ratio > 0.35) return 'Moderately Bearish';
    return 'Bearish';
  }
  
  double _calculateRiskScore(double change) {
    // Calculate risk score based on market volatility
    final absChange = change.abs();
    if (absChange > 10) return 9.0;
    if (absChange > 5) return 7.0;
    if (absChange > 2) return 5.0;
    return 3.0;
  }

  double _calculatePercentageChange(List<ChartData> data) {
    if (data.length < 2) return 0;
    final firstPrice = data.first.price;
    final lastPrice = data.last.price;
    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }

  String _calculateMarketSentiment(int advancing, int declining) {
    final ratio = advancing / (advancing + declining);
    if (ratio > 0.6) return 'Positive';
    if (ratio < 0.4) return 'Negative';
    return 'Neutral';
  }

  List<NewsItem> _processNewsData(List<dynamic> newsData) {
    return newsData.map((news) => NewsItem(
      title: news['title'] ?? '',
      source: news['source'] ?? 'Unknown',
      sentiment: news['sentiment'] ?? 'Neutral',
      publishedAt: DateTime.parse(news['published_at'] ?? DateTime.now().toIso8601String()),
    )).toList();
  }
} 