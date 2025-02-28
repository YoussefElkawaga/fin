import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import 'package:fin/features/home/data/models/market_overview.dart';
import 'package:fin/features/home/data/models/social_market_advice.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw PlatformException(
          code: 'LOCATION_DISABLED',
          message: 'Location services are disabled. Please enable them.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw PlatformException(
            code: 'PERMISSION_DENIED',
            message: 'Location permissions are denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw PlatformException(
          code: 'PERMISSION_DENIED_FOREVER',
          message: 'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Get the current position with timeout and accuracy settings
      if (kIsWeb) {
        try {
          final position = await html.window.navigator.geolocation
              .getCurrentPosition(enableHighAccuracy: true)
              .timeout(const Duration(seconds: 15));
              
          return Position(
            longitude: position.coords!.longitude!.toDouble(),
            latitude: position.coords!.latitude!.toDouble(),
            timestamp: DateTime.now(),
            accuracy: position.coords!.accuracy!.toDouble(),
            altitude: position.coords!.altitude?.toDouble() ?? 0.0,
            heading: position.coords!.heading?.toDouble() ?? 0.0,
            speed: position.coords!.speed?.toDouble() ?? 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: position.coords!.altitudeAccuracy?.toDouble() ?? 0.0,
            headingAccuracy: 0.0,
          );
        } catch (e) {
          throw PlatformException(
            code: 'WEB_LOCATION_ERROR',
            message: 'Failed to get web location: $e',
          );
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw PlatformException(
          code: 'TIMEOUT',
          message: 'Location request timed out.',
        ),
      );

    } catch (e) {
      if (e is TimeoutException) {
        throw PlatformException(
          code: 'TIMEOUT',
          message: 'Location request timed out.',
        );
      }
      throw PlatformException(
        code: 'LOCATION_ERROR',
        message: 'Failed to get current position: $e',
      );
    }
  }

  Future<String> getCountryCode() async {
    try {
      final position = await getCurrentPosition();
      print('Got position: ${position.latitude}, ${position.longitude}');
      
      // Direct geocoding attempt
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        print('Raw placemark data: $placemarks');
        
        if (placemarks.isNotEmpty) {
          // Try multiple fields to determine location
          final placemark = placemarks.first;
          
          // Try direct country code
          if (placemark.isoCountryCode?.isNotEmpty ?? false) {
            print('Found country code: ${placemark.isoCountryCode}');
            return placemark.isoCountryCode!.toUpperCase();
          }
          
          // Try administrative area for specific countries
          if (placemark.administrativeArea?.isNotEmpty ?? false) {
            print('Checking administrative area: ${placemark.administrativeArea}');
            if (placemark.administrativeArea?.contains('Cairo') ?? false) {
              return 'EG';
            }
          }
          
          // Try country name
          if (placemark.country?.isNotEmpty ?? false) {
            print('Trying country name: ${placemark.country}');
            // Add common variations of Egypt
            if (placemark.country!.toLowerCase().contains('egypt') || 
                placemark.country!.contains('مصر')) {
              return 'EG';
            }
            
            final countryCode = _getCountryCodeFromName(placemark.country!);
            if (countryCode != null) {
              return countryCode.toUpperCase();
            }
          }
        }
        
        // Coordinate-based fallback for specific regions
        if (_isInEgypt(position.latitude, position.longitude)) {
          return 'EG';
        }
        
      } catch (e) {
        print('Geocoding error: $e');
      }
      
      print('Falling back to coordinate-based detection');
      return _getCountryFromCoordinates(position.latitude, position.longitude);
      
    } catch (e) {
      print('Location service error: $e');
      return 'US';
    }
  }

  bool _isInEgypt(double lat, double lng) {
    // Egypt's approximate bounding box
    return lat >= 22.0 && lat <= 31.5 && lng >= 25.0 && lng <= 35.0;
  }

  String _getCountryFromCoordinates(double lat, double lng) {
    // Add coordinate ranges for common countries
    if (_isInEgypt(lat, lng)) {
      return 'EG';
    }
    // Add more regions as needed
    return 'US'; // Default fallback
  }

  // Updated country mapping with Arabic names
  String? _getCountryCodeFromName(String countryName) {
    final Map<String, String> countryMapping = {
      'Egypt': 'EG',
      'مصر': 'EG',  // Arabic for Egypt
      'جمهورية مصر العربية': 'EG',  // Arabic for Arab Republic of Egypt
      'Cairo': 'EG',
      'القاهرة': 'EG', // Arabic for Cairo
      // ... other mappings ...
    };
    
    return countryMapping[countryName] ?? 
           countryMapping[countryName.toLowerCase()] ??
           countryMapping[countryName.trim()];
  }

  Future<bool> isLocationEnabled() async {
    if (kIsWeb) {
      try {
        await getCurrentPosition();
        return true;
      } catch (e) {
        return false;
      }
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  Stream<Position> getPositionStream() {
    if (kIsWeb) {
      final controller = StreamController<Position>();
      Timer.periodic(const Duration(seconds: 10), (timer) async {
        try {
          final position = await getCurrentPosition();
          controller.add(position);
        } catch (e) {
          print('Error in web position stream: $e');
        }
      });
      return controller.stream;
    } else {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      return Geolocator.getPositionStream(locationSettings: locationSettings);
    }
  }

  Future<MarketOverview> getMarketOverview(String countryCode) async {
    // This would typically come from an API, but for demo purposes:
    final marketData = _getMarketDataForCountry(countryCode);
    return MarketOverview(
      countryCode: countryCode,
      marketData: marketData['overview'] ?? {},
      metrics: _getMetricsForCountry(countryCode),
      status: _getMarketStatus(countryCode),
    );
  }

  Map<String, dynamic> _getMarketDataForCountry(String countryCode) {
    final marketData = {
      'EG': {
        'overview': {
          'mainIndex': 'EGX 30',
          'indexValue': 24500.50,
          'currency': 'EGP',
          'exchangeRate': 30.90,
          'marketCap': '450B',
          'volume': '250M',
          'topGainers': ['COMI', 'HRHO', 'TMGH'],
          'topLosers': ['EAST', 'SWDY', 'ORWE'],
        },
      },
      'US': {
        'overview': {
          'mainIndex': 'S&P 500',
          'indexValue': 4780.25,
          'currency': 'USD',
          'exchangeRate': 1.0,
          'marketCap': '40.5T',
          'volume': '4.2B',
          'topGainers': ['AAPL', 'MSFT', 'GOOGL'],
          'topLosers': ['META', 'TSLA', 'NFLX'],
        },
      },
      // Add more countries as needed
    } as Map<String, Map<String, dynamic>>;

    return marketData[countryCode] ?? marketData['US']!;
  }

  List<MarketMetric> _getMetricsForCountry(String countryCode) {
    final metrics = {
      'EG': [
        MarketMetric(
          name: 'EGX 30',
          value: 24500.50,
          change: 2.5,
          unit: 'points',
          type: MetricType.marketIndex,
        ),
        MarketMetric(
          name: 'USD/EGP',
          value: 50,
          change: -0.3,
          unit: 'EGP',
          type: MetricType.currency,
        ),
        MarketMetric(
          name: 'Interest Rate',
          value: 18.25,
          change: 0.0,
          unit: '%',
          type: MetricType.interest,
        ),
        MarketMetric(
          name: 'Inflation',
          value: 35.7,
          change: 1.2,
          unit: '%',
          type: MetricType.inflation,
        ),
      ],
      'US': [
        MarketMetric(
          name: 'S&P 500',
          value: 4780.25,
          change: 0.8,
          unit: 'points',
          type: MetricType.marketIndex,
        ),
        MarketMetric(
          name: 'EUR/USD',
          value: 1.09,
          change: 0.2,
          unit: 'USD',
          type: MetricType.currency,
        ),
        MarketMetric(
          name: 'Federal Funds Rate',
          value: 5.25,
          change: 0.0,
          unit: '%',
          type: MetricType.interest,
        ),
        MarketMetric(
          name: 'CPI',
          value: 3.4,
          change: -0.1,
          unit: '%',
          type: MetricType.inflation,
        ),
      ],
    } as Map<String, List<MarketMetric>>;

    return metrics[countryCode] ?? metrics['US']!;
  }

  MarketStatus _getMarketStatus(String countryCode) {
    final statuses = {
      'EG': MarketStatus(
        volatility: 0.85,
        trend: 'bullish',
        sentiment: 'positive',
        confidence: 0.75,
      ),
      'US': MarketStatus(
        volatility: 0.45,
        trend: 'neutral',
        sentiment: 'mixed',
        confidence: 0.85,
      ),
    };

    return statuses[countryCode] ?? statuses['US']!;
  }

  List<SocialMarketAdvice> getSocialMarketAdvice(String countryCode) {
    final advice = {
      'EG': [
        SocialMarketAdvice(
          platform: 'X',
          author: '@EGMarketAnalyst',
          content: 'EGX showing strong momentum. Keep an eye on COMI and HRHO. Banking sector looking particularly strong with recent monetary policies. 🚀📈 #EGXToday',
          sentiment: 'positive',
          likes: 1200,
          shares: 342,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          tags: ['EGX', 'Banking', 'Investment'],
        ),
        SocialMarketAdvice(
          platform: 'LinkedIn',
          author: 'Mohamed Hassan',
          content: 'Latest analysis shows increasing foreign investment interest in Egyptian tech stocks. Regulatory changes creating favorable conditions.',
          sentiment: 'positive',
          likes: 856,
          shares: 124,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          tags: ['Technology', 'ForeignInvestment', 'EGX'],
        ),
        SocialMarketAdvice(
          platform: 'X',
          author: '@CairoTrader',
          content: 'USD/EGP volatility creating opportunities in export-oriented companies. Watch for earnings announcements this week. 📊',
          sentiment: 'neutral',
          likes: 645,
          shares: 89,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          tags: ['Forex', 'Trading', 'Exports'],
        ),
      ],
      'US': [
        SocialMarketAdvice(
          platform: 'X',
          author: '@WallStInsider',
          content: 'Fed minutes suggest potential rate pause. Tech stocks could see upside. \$AAPL \$MSFT looking strong 📈',
          sentiment: 'positive',
          likes: 3200,
          shares: 892,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          tags: ['FederalReserve', 'Stocks', 'Technology'],
        ),
        SocialMarketAdvice(
          platform: 'LinkedIn',
          author: 'Sarah Johnson',
          content: 'AI sector continues to outperform. Key focus on semiconductor stocks and cloud computing leaders.',
          sentiment: 'positive',
          likes: 1523,
          shares: 234,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          tags: ['AI', 'Technology', 'Investment'],
        ),
        SocialMarketAdvice(
          platform: 'X',
          author: '@MarketWatch',
          content: 'Small caps showing weakness. Consider defensive positions in current market conditions. 🛡️',
          sentiment: 'negative',
          likes: 892,
          shares: 156,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          tags: ['SmallCaps', 'MarketStrategy', 'Investing'],
        ),
      ],
    };

    return advice[countryCode] ?? advice['US']!;
  }
}