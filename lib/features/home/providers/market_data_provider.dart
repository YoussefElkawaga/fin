import 'package:flutter/foundation.dart';
import 'package:fin/features/home/data/models/market_data.dart';
import 'package:fin/features/home/data/repositories/market_repository.dart';
import 'dart:async';
import 'dart:math';
import 'package:fin/features/home/data/models/chart_data.dart';
import 'package:fin/core/network/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:fin/core/services/location_service.dart';
import 'package:fin/core/services/financial_advisor_service.dart';
import 'package:flutter/services.dart';
import 'package:fin/core/services/financial_data_service.dart';
import 'package:fin/features/home/data/models/price_alert.dart';
import 'package:fin/features/home/data/models/market_overview.dart';
import 'package:fin/features/home/data/models/stock_price.dart';

class MarketDataProvider extends ChangeNotifier {
  final MarketRepository _repository;
  final FinancialDataService _financialService;
  Timer? _updateTimer;
  Timer? _priceUpdateTimer;
  
  final LocationService _locationService = GetIt.I<LocationService>();
  final FinancialAdvisorService _advisorService = GetIt.I<FinancialAdvisorService>();
  List<FinancialAdvice>? _financialAdvice;
  String? _currentCountry;
  MarketOverview? _marketOverview;
  
  MarketDataProvider(this._repository, this._financialService) {
    // Start listening to real-time updates
    final apiClient = GetIt.instance.get<ApiClient>();
    apiClient.setOnPriceUpdateCallback(_handleRealTimeUpdate);
    
    // Initialize with some default stocks
    _stockPrices = [
      StockPrice(
        symbol: 'AAPL',
        currentPrice: 175.0,
        openPrice: 174.0,
        dayHigh: 176.0,
        dayLow: 173.0,
        volume: 1000000,
      ),
      StockPrice(
        symbol: 'GOOGL',
        currentPrice: 140.0,
        openPrice: 139.0,
        dayHigh: 141.0,
        dayLow: 138.0,
        volume: 800000,
      ),
      StockPrice(
        symbol: 'MSFT',
        currentPrice: 380.0,
        openPrice: 378.0,
        dayHigh: 382.0,
        dayLow: 377.0,
        volume: 900000,
      ),
      StockPrice(
        symbol: 'AMZN',
        currentPrice: 170.0,
        openPrice: 168.0,
        dayHigh: 171.0,
        dayLow: 167.0,
        volume: 750000,
      ),
      StockPrice(
        symbol: 'NVDA',
        currentPrice: 780.0,
        openPrice: 775.0,
        dayHigh: 785.0,
        dayLow: 770.0,
        volume: 1200000,
      ),
      StockPrice(
        symbol: 'META',
        currentPrice: 485.0,
        openPrice: 480.0,
        dayHigh: 487.0,
        dayLow: 479.0,
        volume: 850000,
      ),
      StockPrice(
        symbol: 'TSLA',
        currentPrice: 190.0,
        openPrice: 188.0,
        dayHigh: 192.0,
        dayLow: 187.0,
        volume: 1100000,
      ),
    ];
    
    // Start periodic updates
    _startPeriodicUpdates();
    
    // Initial load
    refreshData();
    _initializeLocationBasedServices();
  }
  
  MarketData? _marketData;
  bool _isLoading = true;
  String? _error;
  
  MarketData? get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<ChartData>? _chartData;
  List<ChartData>? get chartData => _chartData;
  
  List<StockPrice>? _stockPrices;
  List<StockPrice>? get stockPrices => _stockPrices;
  
  String _currentTimeframe = '1D';
  String get currentTimeframe => _currentTimeframe;
  int get advancingStocks => _stockPrices?.where((s) => s.currentPrice > s.openPrice).length ?? 0;
  int get decliningStocks => _stockPrices?.where((s) => s.currentPrice < s.openPrice).length ?? 0;
  double get volatilityIndex {
    if (_stockPrices == null) return 0;
    final changes = _stockPrices!.map((s) => (s.currentPrice - s.openPrice) / s.openPrice * 100);
    final avgChange = changes.reduce((a, b) => a + b) / changes.length;
    final squaredDiffs = changes.map((c) => (c - avgChange) * (c - avgChange));
    return sqrt(squaredDiffs.reduce((a, b) => a + b) / changes.length);
  }

  List<FinancialAdvice>? get financialAdvice => _financialAdvice;
  String? get currentCountry => _currentCountry;

  final List<PriceAlert> _priceAlerts = [];
  List<PriceAlert> get priceAlerts => _priceAlerts;

  MarketOverview? get marketOverview => _marketOverview;

  void updateTimeframe(String timeframe) async {
    if (_currentTimeframe == timeframe) return;
    
    _currentTimeframe = timeframe;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getMarketData(timeframe: timeframe);
      _marketData = response;
      _chartData = response.historicalData;
      
      // Ensure immediate update
      notifyListeners();
      
      // Start real-time updates
      _startRealtimeUpdates();
    } catch (e) {
      _error = 'Failed to fetch market data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (_chartData == null || _chartData!.isEmpty) {
        // Initialize with some sample data if empty
        final now = DateTime.now();
        _chartData = List.generate(50, (index) {
          final timestamp = now.subtract(Duration(minutes: (50 - index) * 5));
          return ChartData(
            timestamp: timestamp,
            price: 100.0 + (index * 0.5) + (Random().nextDouble() * 2 - 1),
            volume: 1000000.0 + Random().nextDouble() * 500000,
          );
        });
      } else {
        final lastPrice = _chartData!.last.price;
        final random = Random();
        
        // More realistic price movement
        final volatility = 0.002; // 0.2% volatility
        final change = lastPrice * volatility * (random.nextDouble() * 2 - 1);
        final newPrice = lastPrice + change;
        
        final newVolume = _chartData!.last.volume * (0.9 + random.nextDouble() * 0.2);
        
        _chartData!.add(ChartData(
          timestamp: DateTime.now(),
          price: newPrice,
          volume: newVolume,
        ));
        
        // Keep data length consistent based on timeframe
        final maxDataPoints = _currentTimeframe == '1D' ? 288 : // 5-minute intervals
                            _currentTimeframe == '1W' ? 168 : // Hourly intervals
                            _currentTimeframe == '1M' ? 30 :  // Daily intervals
                            52;  // Weekly intervals for 1Y
                            
        while (_chartData!.length > maxDataPoints) {
          _chartData!.removeAt(0);
        }
        
        // Update market data with new metrics
        if (_marketData != null) {
          _marketData = MarketData(
            currentPrice: newPrice,
            percentageChange: ((newPrice - _chartData!.first.price) / _chartData!.first.price) * 100,
            riskScore: _calculateRiskScore(),
            sentiment: _calculateMarketSentiment(),
            recentNews: _marketData!.recentNews,
            totalVolume: _chartData!.fold(0.0, (sum, data) => sum + data.volume),
            advancingStocks: advancingStocks,
            decliningStocks: decliningStocks,
            volatilityIndex: volatilityIndex,
            historicalData: List.from(_chartData!), // Create a new list to ensure proper update
            marketSentiment: _getMarketSentiment(),
          );
        }
        
        notifyListeners();
      }
    });
  }
  
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _currentCountry = await _repository.getCurrentCountry();
      _marketOverview = await _repository.getMarketOverview(_currentCountry!);
      final response = await _repository.getMarketData(timeframe: _currentTimeframe);
      _marketData = response;
      
      // Initialize chart data with historical prices
      _chartData = response.historicalData;
      
      // Calculate initial market metrics
      final totalVolume = _chartData!.fold(0.0, (sum, data) => sum + data.volume);
      final lastPrice = _chartData!.last.price;
      final firstPrice = _chartData!.first.price;
      final percentageChange = ((lastPrice - firstPrice) / firstPrice) * 100;
      
      // Update market data with real metrics
      _marketData = MarketData(
        currentPrice: lastPrice,
        percentageChange: percentageChange,
        riskScore: _calculateRiskScore(),
        sentiment: _calculateMarketSentiment(),
        recentNews: response.recentNews,
        totalVolume: totalVolume,
        advancingStocks: advancingStocks,
        decliningStocks: decliningStocks,
        volatilityIndex: volatilityIndex,
        historicalData: _chartData!,
        marketSentiment: _getMarketSentiment(),
      );
      
      await refreshAdvice();
      
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch market data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateRiskScore() {
    if (_chartData == null || _chartData!.isEmpty) return 5.0;
    final volatility = volatilityIndex;
    if (volatility > 2.5) return 9.0;
    if (volatility > 1.5) return 7.0;
    if (volatility > 1.0) return 5.0;
    return 3.0;
  }

  String _calculateMarketSentiment() {
    if (_stockPrices == null) return 'Neutral';
    final ratio = advancingStocks / (_stockPrices!.length);
    if (ratio > 0.6) return 'Positive';
    if (ratio < 0.4) return 'Negative';
    return 'Neutral';
  }

  String _getMarketSentiment() {
    if (_stockPrices == null) return 'Neutral';
    final ratio = advancingStocks / (_stockPrices!.length);
    if (ratio > 0.65) return 'Bullish';
    if (ratio > 0.55) return 'Moderately Bullish';
    if (ratio > 0.45) return 'Neutral';
    if (ratio > 0.35) return 'Moderately Bearish';
    return 'Bearish';
  }

  void _handleRealTimeUpdate(List<Map<String, dynamic>> updates) {
    if (_marketData != null && _chartData != null) {
      for (final update in updates) {
        final price = update['price'] as double;
        final volume = update['volume'] as double;
        final timestamp = DateTime.now();

        _chartData!.add(ChartData(
          timestamp: timestamp,
          price: price,
          volume: volume,
        ));

        // Keep only last 100 data points
        if (_chartData!.length > 100) {
          _chartData!.removeAt(0);
        }

        final totalVolume = _chartData!.fold(0.0, (sum, data) => sum + data.volume);
        
        // Update market data with real metrics
        _marketData = MarketData(
          currentPrice: price,
          percentageChange: ((price - _chartData!.first.price) / _chartData!.first.price) * 100,
          riskScore: _calculateRiskScore(),
          sentiment: _calculateMarketSentiment(),
          recentNews: _marketData!.recentNews,
          totalVolume: totalVolume,
          advancingStocks: advancingStocks,
          decliningStocks: decliningStocks,
          volatilityIndex: volatilityIndex,
          historicalData: _chartData!,
          marketSentiment: _getMarketSentiment(),
        );
      }
      
      // Check price alerts after updating prices
      _checkPriceAlerts(_stockPrices ?? []);
      
      notifyListeners();
    }
  }

  void _startRealtimeUpdates() {
    // Update prices every second for real-time effect
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_chartData != null && _chartData!.isNotEmpty) {
        final lastPrice = _chartData!.last.price;
        final random = Random();
        final change = (random.nextDouble() - 0.5) * 2;
        final newPrice = lastPrice + change;
        
        _chartData!.add(ChartData(
          timestamp: DateTime.now(),
          price: newPrice,
          volume: _chartData!.last.volume + random.nextInt(1000),
        ));
        
        // Keep chart data length consistent
        if (_chartData!.length > 100) {
          _chartData!.removeAt(0);
        }
        
        notifyListeners();
      }
    });
  }

  Future<void> _initializeLocationBasedServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Check if location services are enabled
      final isEnabled = await _locationService.isLocationEnabled();
      if (!isEnabled) {
        _error = kIsWeb
          ? 'Please enable location access in your browser settings.'
          : 'Please enable location services in your device settings.';
        notifyListeners();
        _currentCountry = 'US'; // Fallback
        await refreshAdvice();
        return;
      }
      
      int maxAttempts = 3;
      int attempt = 0;
      String? countryCode;
      
      while (attempt < maxAttempts && countryCode == null) {
        try {
          countryCode = await _locationService.getCountryCode()
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () => throw PlatformException(
                  code: 'TIMEOUT',
                  message: 'Location request timed out. Retrying...',
                ),
              );
              
          if (countryCode != null) {
            _error = null;
            _currentCountry = countryCode;
            await refreshAdvice();
            break;
          }
        } catch (e) {
          print('Attempt $attempt failed: $e');
          await Future.delayed(const Duration(seconds: 2));
          attempt++;
          
          if (attempt < maxAttempts) {
            _error = 'Retrying to get location... (Attempt ${attempt + 1}/$maxAttempts)';
            notifyListeners();
          }
        }
      }

      if (countryCode == null) {
        _error = 'Unable to get location. Using default location.';
        _currentCountry = 'US'; // Fallback to US
        await refreshAdvice();
      }
      
    } catch (e) {
      if (e is PlatformException) {
        _error = e.message ?? 'Location services error';
      } else {
        _error = kIsWeb 
          ? 'Please enable location services in your browser settings.'
          : 'Unable to access location services. Using default location.';
      }
      _currentCountry = 'US'; // Fallback to US
      await refreshAdvice();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to manually retry location services
  Future<void> retryLocationServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // First check if location services are enabled
      final isEnabled = await _locationService.isLocationEnabled();
      if (!isEnabled) {
        throw PlatformException(
          code: 'LOCATION_DISABLED',
          message: kIsWeb
            ? 'Please enable location access in your browser settings.'
            : 'Please enable location services in your device settings.',
        );
      }

      // Try to get country code with timeout
      _currentCountry = await _locationService.getCountryCode()
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw PlatformException(
              code: 'TIMEOUT',
              message: 'Location request timed out. Please try again.',
            ),
          );

      if (_currentCountry != null) {
        _error = null;
        await refreshAdvice();
      } else {
        throw PlatformException(
          code: 'LOCATION_ERROR',
          message: 'Unable to determine your location.',
        );
      }
      
    } catch (e) {
      _currentCountry = 'US'; // Fallback
      if (e is PlatformException) {
        _error = '${e.message}. Using default location (US).';
      } else {
        _error = 'Location error: ${e.toString()}. Using default location (US).';
      }
      await refreshAdvice();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAdvice() async {
    if (_currentCountry != null && _marketData != null) {
      _financialAdvice = await _advisorService.generateAdvice(
        _currentCountry!,
        _marketData!,
      );
      notifyListeners();
    }
  }

  Future<void> fetchMarketData() async {
    try {
      final overview = await _financialService.getMarketOverview(_currentCountry ?? 'US');
      final gainers = await _financialService.getTopGainers();
      final indicators = await _financialService.getEconomicIndicators(_currentCountry ?? 'US');
      
      _marketData = MarketData(
        currentPrice: overview['price'] ?? 0.0,
        percentageChange: overview['change'] ?? 0.0,
        riskScore: _calculateRiskScore(),
        sentiment: _calculateMarketSentiment(),
        recentNews: _marketData?.recentNews ?? [],
        totalVolume: overview['volume'] ?? 0.0,
        advancingStocks: advancingStocks,
        decliningStocks: decliningStocks,
        volatilityIndex: volatilityIndex,
        historicalData: _chartData ?? [],
        overview: overview,
        gainers: gainers,
        indicators: indicators,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch market data: ${e.toString()}';
      notifyListeners();
    }
  }

  void startDataUpdates() {
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      fetchMarketData();
    });
  }

  void addPriceAlert(PriceAlert alert) {
    _priceAlerts.add(alert);
    notifyListeners();
  }

  void removePriceAlert(PriceAlert alert) {
    _priceAlerts.remove(alert);
    notifyListeners();
  }

  void _checkPriceAlerts(List<StockPrice> prices) {
    for (final alert in _priceAlerts) {
      if (!alert.isEnabled) continue;
      
      final stock = prices.firstWhere(
        (s) => s.symbol == alert.symbol,
        orElse: () => StockPrice(
          symbol: alert.symbol,
          currentPrice: 0,
          openPrice: 0,
          dayHigh: 0,
          dayLow: 0,
          volume: 0,
        ),
      );
      
      if (stock.currentPrice == 0) continue;

      if (alert.isAbove && stock.currentPrice >= alert.targetPrice) {
        _showNotification(
          'Price Alert: ${alert.symbol}',
          'Price has risen above \$${alert.targetPrice}',
        );
      } else if (!alert.isAbove && stock.currentPrice <= alert.targetPrice) {
        _showNotification(
          'Price Alert: ${alert.symbol}',
          'Price has fallen below \$${alert.targetPrice}',
        );
      }
    }
  }

  void _showNotification(String title, String body) {
    // TODO: Implement actual notification logic using your preferred notification package
    print('Notification: $title - $body');
  }

  void toggleAlertEnabled(PriceAlert alert, bool enabled) {
    final index = _priceAlerts.indexOf(alert);
    if (index != -1) {
      _priceAlerts[index] = PriceAlert(
        symbol: alert.symbol,
        targetPrice: alert.targetPrice,
        isAbove: alert.isAbove,
        isEnabled: enabled,
      );
      notifyListeners();
    }
  }

  void deleteAlert(PriceAlert alert) {
    _priceAlerts.remove(alert);
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }
}