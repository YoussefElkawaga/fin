// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
      currentPrice: (json['currentPrice'] as num).toDouble(),
      percentageChange: (json['percentageChange'] as num).toDouble(),
      riskScore: (json['riskScore'] as num).toDouble(),
      sentiment: json['sentiment'] as String,
      recentNews: (json['recentNews'] as List<dynamic>)
          .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      advancingStocks: json['advancingStocks'] as int,
      decliningStocks: json['decliningStocks'] as int,
      volatilityIndex: (json['volatilityIndex'] as num).toDouble(),
      historicalData: (json['historicalData'] as List<dynamic>)
          .map((e) => ChartData(
                timestamp: DateTime.parse(e['timestamp'] as String),
                price: (e['price'] as num).toDouble(),
                volume: (e['volume'] as num).toDouble(),
              ))
          .toList(),
      marketSentiment: json['marketSentiment'] as String? ?? 'Neutral',
    );

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'currentPrice': instance.currentPrice,
      'percentageChange': instance.percentageChange,
      'riskScore': instance.riskScore,
      'sentiment': instance.sentiment,
      'recentNews': instance.recentNews,
      'totalVolume': instance.totalVolume,
      'advancingStocks': instance.advancingStocks,
      'decliningStocks': instance.decliningStocks,
      'volatilityIndex': instance.volatilityIndex,
      'historicalData': instance.historicalData,
      'marketSentiment': instance.marketSentiment,
    };

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
      title: json['title'] as String,
      source: json['source'] as String,
      sentiment: json['sentiment'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
      'title': instance.title,
      'source': instance.source,
      'sentiment': instance.sentiment,
      'publishedAt': instance.publishedAt.toIso8601String(),
    };
