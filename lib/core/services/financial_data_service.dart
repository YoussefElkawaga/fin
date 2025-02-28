import 'package:dio/dio.dart';
import '../network/api_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FinancialDataService {
  final ApiClient _apiClient;
  final String _baseUrl = 'https://api.example.com/financial-data';
  final String _apiKey = '1CmR7iE3oTH9sHnpV25RCk2XlExNtFdY';  // Replace with your API key

  FinancialDataService(this._apiClient);

  Future<Map<String, dynamic>> getLocalFinancialData(String countryCode) async {
    try {
      final response = await _apiClient.dio.get(
        '$_baseUrl/$countryCode',
      );
      
      return _parseFinancialData(response.data, countryCode);
    } catch (e) {
      // Fallback to mock data for demo
      return _getMockFinancialData(countryCode);
    }
  }

  Future<Map<String, dynamic>> getCountryMarketData(String countryCode) async {
    try {
      // Get country-specific market indices
      final response = await _apiClient.dio.get('/market/get-summary', 
        queryParameters: {'country': countryCode});
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      // Fallback to mock data if API fails
      return _getMockCountryData(countryCode);
    } catch (e) {
      print('Error getting country market data: $e');
      return _getMockCountryData(countryCode);
    }
  }

  Map<String, dynamic> _parseFinancialData(Map<String, dynamic> data, String countryCode) {
    return {
      'inflation_rate': data['inflation_rate']?.toDouble() ?? _getDefaultRate(countryCode, 'inflation'),
      'interest_rate': data['interest_rate']?.toDouble() ?? _getDefaultRate(countryCode, 'interest'),
      'gdp_growth': data['gdp_growth']?.toDouble() ?? _getDefaultRate(countryCode, 'gdp'),
      'unemployment_rate': data['unemployment_rate']?.toDouble() ?? _getDefaultRate(countryCode, 'unemployment'),
      'currency': data['currency'] ?? _getDefaultCurrency(countryCode),
      'market_sentiment': data['market_sentiment'] ?? 'neutral',
      'country_risk': data['country_risk']?.toDouble() ?? _getCountryRisk(countryCode),
      'exchange_rate': data['exchange_rate']?.toDouble() ?? _getExchangeRate(countryCode),
      'market_cap_to_gdp': data['market_cap_to_gdp']?.toDouble() ?? _getMarketCapToGDP(countryCode),
    };
  }

  Map<String, dynamic> _getMockFinancialData(String countryCode) {
    final Map<String, Map<String, dynamic>> mockData = {
      'US': {
        'inflation_rate': 3.4,
        'interest_rate': 5.25,
        'gdp_growth': 2.1,
        'unemployment_rate': 3.7,
        'currency': 'USD',
        'market_sentiment': 'positive',
        'country_risk': 0.8,
        'exchange_rate': 1.0,
        'market_cap_to_gdp': 1.95,
      },
      'GB': {
        'inflation_rate': 4.0,
        'interest_rate': 5.25,
        'gdp_growth': 1.8,
        'unemployment_rate': 4.2,
        'currency': 'GBP',
        'market_sentiment': 'neutral',
        'country_risk': 1.2,
        'exchange_rate': 0.79,
        'market_cap_to_gdp': 1.45,
      },
      'EU': {
        'inflation_rate': 2.9,
        'interest_rate': 4.5,
        'gdp_growth': 1.5,
        'unemployment_rate': 6.5,
        'currency': 'EUR',
        'market_sentiment': 'neutral',
        'country_risk': 1.0,
        'exchange_rate': 0.92,
        'market_cap_to_gdp': 1.25,
      },
      'JP': {
        'inflation_rate': 2.1,
        'interest_rate': 0.1,
        'gdp_growth': 1.2,
        'unemployment_rate': 2.6,
        'currency': 'JPY',
        'market_sentiment': 'positive',
        'country_risk': 1.1,
        'exchange_rate': 148.5,
        'market_cap_to_gdp': 1.35,
      },
    };

    return mockData[countryCode] ?? _getDefaultFinancialData();
  }

  Map<String, dynamic> _getDefaultFinancialData() {
    return {
      'inflation_rate': 3.0,
      'interest_rate': 4.0,
      'gdp_growth': 2.0,
      'unemployment_rate': 5.0,
      'currency': 'USD',
      'market_sentiment': 'neutral',
      'country_risk': 1.5,
      'exchange_rate': 1.0,
      'market_cap_to_gdp': 1.0,
    };
  }

  double _getDefaultRate(String countryCode, String type) {
    final rates = {
      'US': {'inflation': 3.4, 'interest': 5.25, 'gdp': 2.1, 'unemployment': 3.7},
      'GB': {'inflation': 4.0, 'interest': 5.25, 'gdp': 1.8, 'unemployment': 4.2},
      'EU': {'inflation': 2.9, 'interest': 4.5, 'gdp': 1.5, 'unemployment': 6.5},
      'JP': {'inflation': 2.1, 'interest': 0.1, 'gdp': 1.2, 'unemployment': 2.6},
    };
    return rates[countryCode]?[type] ?? rates['US']?[type] ?? 0.0;
  }

  String _getDefaultCurrency(String countryCode) {
    final currencies = {
      'US': 'USD',
      'GB': 'GBP',
      'EU': 'EUR',
      'JP': 'JPY',
      'CH': 'CHF',
      'AU': 'AUD',
      'CA': 'CAD',
    };
    return currencies[countryCode] ?? 'USD';
  }

  double _getCountryRisk(String countryCode) {
    final risks = {
      'US': 0.8,
      'GB': 1.2,
      'EU': 1.0,
      'JP': 1.1,
      'CH': 0.9,
      'AU': 1.3,
      'CA': 1.0,
    };
    return risks[countryCode] ?? 1.5;
  }

  double _getExchangeRate(String countryCode) {
    final rates = {
      'US': 1.0,
      'GB': 0.79,
      'EU': 0.92,
      'JP': 148.5,
      'CH': 0.88,
      'AU': 1.52,
      'CA': 1.35,
    };
    return rates[countryCode] ?? 1.0;
  }

  double _getMarketCapToGDP(String countryCode) {
    final ratios = {
      'US': 1.95,
      'GB': 1.45,
      'EU': 1.25,
      'JP': 1.35,
      'CH': 2.15,
      'AU': 1.28,
      'CA': 1.42,
    };
    return ratios[countryCode] ?? 1.0;
  }

  Map<String, dynamic> _getMockCountryData(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return {
          'mainIndex': {
            'name': 'EGX30',
            'value': 24500.50,
            'change': 1.2,
            'topSectors': [
              {'name': 'Banking', 'performance': 2.5},
              {'name': 'Real Estate', 'performance': 1.8},
              {'name': 'Telecommunications', 'performance': 1.3},
            ],
          },
          'currency': {
            'usdRate': 30.90,
            'trend': 'stable',
          },
          'interestRate': 11.25,
          'marketCap': '450B EGP',
        };
      
      case 'US':
        return {
          'mainIndex': {
            'name': 'S&P 500',
            'value': 4185.82,
            'change': 0.75,
            'topSectors': [
              {'name': 'Technology', 'performance': 2.1},
              {'name': 'Healthcare', 'performance': 1.5},
              {'name': 'Finance', 'performance': 0.8},
            ],
          },
          'currency': {
            'trend': 'strong',
          },
          'interestRate': 5.25,
          'marketCap': '40T USD',
        };
      
      default:
        return {
          'mainIndex': {
            'name': 'Global Markets',
            'value': 1000.0,
            'change': 0.5,
          },
          'recommendation': 'Consider global diversification',
        };
    }
  }

  Future<Map<String, dynamic>> getMarketOverview(String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.financialmodelingprep.com/api/v3/market-overview?apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load market data');
    } catch (e) {
      throw Exception('Error fetching market data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopGainers() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.financialmodelingprep.com/api/v3/stock_market/gainers?apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      throw Exception('Failed to load gainers data');
    } catch (e) {
      throw Exception('Error fetching gainers: $e');
    }
  }

  Future<Map<String, dynamic>> getEconomicIndicators(String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.financialmodelingprep.com/api/v3/economic-indicators/$countryCode?apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load economic indicators');
    } catch (e) {
      throw Exception('Error fetching economic data: $e');
    }
  }
} 