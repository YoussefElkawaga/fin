import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fin/core/storage/local_storage.dart';
import 'package:fin/core/services/service_locator.dart';
import 'package:fin/features/home/data/models/chart_data.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiClient {
  late final Dio _dio;
  final LocalStorage _storage = getIt<LocalStorage>();
  WebSocketChannel? _channel;
  Function(List<Map<String, dynamic>>)? _onPriceUpdateCallback;
  
  // Update base URL to use Yahoo Finance API
  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance';
  static const String _finnhubWsUrl = 'wss://ws.finnhub.io';
  static const String _finnhubApiKey = 'cv0m0hpr01qo8sshj2t0cv0m0hpr01qo8sshj2tg'; // Get free key from finnhub.io
  static const List<String> _symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA'];
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: kIsWeb 
          ? 'https://cors-anywhere.herokuapp.com/$_baseUrl'
          : _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        // Fall back to mock data on error
        if (error.type == DioExceptionType.connectionError) {
          return handler.resolve(_getMockData());
        }
        return handler.next(error);
      },
    ));

    _initializeWebSocket();
  }
  
  void _initializeWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('$_finnhubWsUrl?token=$_finnhubApiKey'),
    );

    // Subscribe to symbols
    for (final symbol in _symbols) {
      _channel?.sink.add(jsonEncode({
        'type': 'subscribe',
        'symbol': symbol
      }));
    }

    // Listen for real-time updates
    _channel?.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'trade') {
        _handlePriceUpdate(data);
      }
    });
  }

  void _handlePriceUpdate(Map<String, dynamic> data) {
    final updates = _symbols.map((symbol) {
      final price = data['data'].firstWhere(
        (d) => d['s'] == symbol,
        orElse: () => null,
      );
      
      if (price != null) {
        return {
          'symbol': symbol,
          'price': price['p'],
          'volume': price['v'],
          'timestamp': DateTime.fromMillisecondsSinceEpoch(price['t']),
        };
      }
      return null;
    }).whereType<Map<String, dynamic>>().toList();

    _onPriceUpdateCallback?.call(updates);
  }

  void setOnPriceUpdateCallback(Function(List<Map<String, dynamic>>) callback) {
    _onPriceUpdateCallback = callback;
  }

  Future<Response> getMarketData({String timeframe = '1D'}) async {
    try {
      // For demo purposes, return mock data instead of making actual API calls
      await Future.delayed(const Duration(milliseconds: 500));
      return Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'historical_prices': List.generate(
            100,
            (i) => {
              'timestamp': DateTime.now().subtract(Duration(minutes: 100 - i)).millisecondsSinceEpoch,
              'price': 100 + (i * 0.5) + (Random().nextDouble() * 2 - 1),
              'volume': 1000000 + Random().nextInt(500000),
            },
          ),
          'advancing_stocks': 280,
          'declining_stocks': 220,
          'news': [
            {
              'title': 'Market shows strong momentum',
              'source': 'Financial Times',
              'sentiment': 'Positive',
              'published_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            },
            {
              'title': 'Tech sector faces headwinds',
              'source': 'Reuters',
              'sentiment': 'Negative',
              'published_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
            },
          ],
        },
        statusCode: 200,
      );
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Failed to fetch market data: $e',
      );
    }
  }

  String _getInterval(String timeframe) {
    switch (timeframe) {
      case '1D': return '5m';
      case '1W': return '15m';
      case '1M': return '1d';
      case '1Y': return '1wk';
      default: return '5m';
    }
  }

  String _getCompanyName(String symbol) {
    switch (symbol) {
      case 'AAPL': return 'Apple Inc.';
      case 'MSFT': return 'Microsoft Corp.';
      case 'GOOGL': return 'Alphabet Inc.';
      case 'AMZN': return 'Amazon.com Inc.';
      case 'NVDA': return 'NVIDIA Corp.';
      default: return symbol;
    }
  }

  String _formatMarketCap(num marketCap) {
    if (marketCap >= 1e12) return '${(marketCap / 1e12).toStringAsFixed(1)}T';
    if (marketCap >= 1e9) return '${(marketCap / 1e9).toStringAsFixed(1)}B';
    if (marketCap >= 1e6) return '${(marketCap / 1e6).toStringAsFixed(1)}M';
    return marketCap.toString();
  }

  String _formatVolume(num volume) {
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(1)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(1)}K';
    return volume.toString();
  }

  String _calculateMarketSentiment(double averageChange) {
    if (averageChange > 1.5) return 'Very Positive';
    if (averageChange > 0) return 'Positive';
    if (averageChange > -1.5) return 'Neutral';
    return 'Negative';
  }

  double _calculateVolatilityIndex(List<Map<String, dynamic>> earnings) {
    final changes = earnings.map((e) => e['change_percent'] as double).toList();
    final mean = changes.reduce((a, b) => a + b) / changes.length;
    final variance = changes.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / changes.length;
    return sqrt(variance) * 2; // Simplified volatility calculation
  }

  Response _getMockData() {
    return Response(
      requestOptions: RequestOptions(path: '/market/data'),
      data: {
        'status': 'success',
        'country': 'US',
        'data': {
          'market_overview': {
            'index_value': 4185.82,
            'change_percent': 0.75,
            'volume': '125M',
          },
          // Add other mock data as needed
        }
      },
      statusCode: 200,
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
  }

  Dio get dio => _dio;
} 