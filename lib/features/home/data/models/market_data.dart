import 'package:json_annotation/json_annotation.dart';
import 'package:fin/features/home/data/models/chart_data.dart';

part 'market_data.g.dart';

@JsonSerializable()
class MarketData {
  final double currentPrice;
  final double percentageChange;
  final double riskScore;
  final String sentiment;
  final List<NewsItem> recentNews;
  final double totalVolume;
  final int advancingStocks;
  final int decliningStocks;
  final double volatilityIndex;
  final List<ChartData> historicalData;
  final String marketSentiment;
  
  MarketData({
    required this.currentPrice,
    required this.percentageChange,
    required this.riskScore,
    required this.sentiment,
    required this.recentNews,
    required this.totalVolume,
    required this.advancingStocks,
    required this.decliningStocks,
    required this.volatilityIndex,
    required this.historicalData,
    this.marketSentiment = 'Neutral',
  });
  
  factory MarketData.fromJson(Map<String, dynamic> json) => _$MarketDataFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDataToJson(this);
}

@JsonSerializable()
class NewsItem {
  final String title;
  final String source;
  final String sentiment;
  final DateTime publishedAt;
  
  NewsItem({
    required this.title,
    required this.source,
    required this.sentiment,
    required this.publishedAt,
  });
  
  factory NewsItem.fromJson(Map<String, dynamic> json) => 
      _$NewsItemFromJson(json);
      
  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
} 