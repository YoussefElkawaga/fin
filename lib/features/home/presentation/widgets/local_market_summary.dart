import 'package:flutter/material.dart';

class LocalMarketSummary extends StatelessWidget {
  final String countryCode;

  const LocalMarketSummary({
    super.key,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              _getMarketSummary(countryCode),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getKeywords(countryCode).map((keyword) {
                return Chip(
                  label: Text(keyword),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getMarketSummary(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return 'The Egyptian market shows resilience despite global challenges. High interest rates provide opportunities in fixed-income investments, while the EGP valuation presents potential for long-term equity growth.';
      case 'US':
        return 'US markets continue to be driven by tech sector performance and Federal Reserve policy decisions. Corporate earnings and inflation data remain key factors for market direction.';
      default:
        return 'Market data not available for this region.';
    }
  }

  List<String> _getKeywords(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return ['High Interest Rates', 'Currency Valuation', 'Reform Program', 'Banking Sector'];
      case 'US':
        return ['Tech Sector', 'Fed Policy', 'Corporate Earnings', 'Treasury Yields'];
      default:
        return [];
    }
  }
} 