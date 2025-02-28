import 'package:fin/core/services/financial_data_service.dart';
import 'package:fin/features/home/data/models/market_data.dart';

class FinancialAdvice {
  final String title;
  final String description;
  final String category;
  final double confidence;
  final List<String> actions;

  FinancialAdvice({
    required this.title,
    required this.description,
    required this.category,
    required this.confidence,
    required this.actions,
  });
}

class FinancialAdvisorService {
  final FinancialDataService _dataService;

  FinancialAdvisorService(this._dataService);

  Future<List<FinancialAdvice>> generateAdvice(String countryCode, MarketData marketData) async {
    List<FinancialAdvice> advice = [];
    
    // Get country-specific market data
    final countryMarketData = await _dataService.getCountryMarketData(countryCode);
    
    switch (countryCode) {
      case 'EG':
        advice.addAll([
          FinancialAdvice(
            title: 'Egyptian Stock Market Opportunities',
            description: 'The EGX30 index shows potential in banking and real estate sectors. '
                'Consider Egyptian pound-denominated investments with current interest rates.',
            category: 'Investment',
            confidence: 0.85,
            actions: [
              'Research EGX30 index funds',
              'Consider Egyptian Treasury Bills',
              'Look into real estate investment trusts',
            ],
          ),
          FinancialAdvice(
            title: 'Currency Diversification',
            description: 'With current EGP rates, consider balancing between local and USD investments.',
            category: 'Wealth Preservation',
            confidence: 0.78,
            actions: [
              'Split investments between EGP and USD',
              'Consider Egyptian sovereign bonds',
              'Monitor Central Bank of Egypt rates',
            ],
          ),
        ]);
        break;

      case 'US':
        advice.addAll([
          FinancialAdvice(
            title: 'US Market Insights',
            description: 'S&P 500 showing strong tech sector performance. '
                'Consider diversified ETF investments.',
            category: 'Investment',
            confidence: 0.82,
            actions: [
              'Research S&P 500 index funds',
              'Consider tech sector ETFs',
              'Monitor Federal Reserve rates',
            ],
          ),
        ]);
        break;

      // Add more countries as needed
      default:
        advice.add(FinancialAdvice(
          title: 'Global Investment Strategy',
          description: 'International market conditions suggest diversified approach.',
          category: 'Investment',
          confidence: 0.75,
          actions: [
            'Consider international ETFs',
            'Research local market opportunities',
            'Monitor global market trends',
          ],
        ));
    }

    return advice;
  }
} 