import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/core/services/financial_advisor_service.dart';
import 'package:fin/features/home/presentation/widgets/market_insight_card.dart';
import 'package:fin/features/home/presentation/widgets/local_market_summary.dart';
import 'package:fin/features/home/presentation/widgets/market_overview_panel.dart';
import 'package:fin/features/home/data/models/market_overview.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:fin/core/services/location_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fin/features/home/data/models/social_market_advice.dart';

class LocationAdvisorPage extends StatelessWidget {
  const LocationAdvisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location-Based Advice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<MarketDataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final countryCode = provider.currentCountry ?? 'Unknown';
          final countryName = _getCountryName(countryCode);

          return RefreshIndicator(
            onRefresh: () => provider.refreshAdvice(),
            child: CustomScrollView(
              slivers: [
                if (provider.error != null)
                  _buildErrorWidget(context, provider),
                
                // Location Card
                SliverToBoxAdapter(
                  child: _buildLocationCard(context, countryName, countryCode, provider),
                ),

                // Local Market Summary
                SliverToBoxAdapter(
                  child: LocalMarketSummary(countryCode: countryCode),
                ),

                // Market Overview Panel
                SliverToBoxAdapter(
                  child: MarketOverviewPanel(
                    overview: provider.marketOverview ?? MarketOverview(
                      countryCode: countryCode,
                      marketData: {},
                      metrics: [],
                      status: MarketStatus(
                        volatility: 0.0,
                        trend: 'unknown',
                        sentiment: 'neutral',
                        confidence: 0.0,
                      ),
                    ),
                  ),
                ),

                // Market Insights Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Market Insights',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildListDelegate([
                      MarketInsightCard(
                        title: 'Local Indices',
                        value: _getLocalIndex(countryCode),
                        trend: 0.5,
                        icon: Icons.show_chart,
                      ),
                      MarketInsightCard(
                        title: 'Currency',
                        value: _getLocalCurrency(countryCode),
                        trend: -0.2,
                        icon: Icons.currency_exchange,
                      ),
                      MarketInsightCard(
                        title: 'Interest Rate',
                        value: '${_getInterestRate(countryCode)}%',
                        trend: 0.0,
                        icon: Icons.percent,
                      ),
                      MarketInsightCard(
                        title: 'Market Cap',
                        value: _getMarketCap(countryCode),
                        trend: 1.2,
                        icon: Icons.pie_chart,
                      ),
                    ]),
                  ),
                ),

                // Financial Advice Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Personalized Recommendations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),

                _buildAdviceGrid(provider.financialAdvice ?? []),

                // Add Social Media Advice Section
                SliverToBoxAdapter(
                  child: _buildSocialAdviceSection(context, countryCode),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(context),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  String _getCountryName(String countryCode) {
    final countryNames = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'JP': 'Japan',
      'DE': 'Germany',
      'FR': 'France',
      'CA': 'Canada',
      'AU': 'Australia',
      'CN': 'China',
      'IN': 'India',
      'BR': 'Brazil',
    };
    return countryNames[countryCode] ?? 'Unknown Country';
  }

  Widget _buildErrorWidget(BuildContext context, MarketDataProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => provider.retryLocationServices(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, String countryName, String countryCode, MarketDataProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        countryName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Country Code: $countryCode',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () => provider.retryLocationServices(),
                  tooltip: 'Update Location',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalIndex(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return 'EGX 30';
      case 'US':
        return 'S&P 500';
      default:
        return 'N/A';
    }
  }

  String _getLocalCurrency(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return 'EGP';
      case 'US':
        return 'USD';
      default:
        return 'N/A';
    }
  }

  double _getInterestRate(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return 21.25; // Egyptian Central Bank rate
      case 'US':
        return 5.25; // Federal Reserve rate
      default:
        return 0.0;
    }
  }

  String _getMarketCap(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return 'EGP 1.2T';
      case 'US':
        return 'USD 40.2T';
      default:
        return 'N/A';
    }
  }

  Widget _buildMarketSummary(BuildContext context, MarketDataProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMetricCard(
                    context,
                    'Volatility',
                    '${provider.volatilityIndex.toStringAsFixed(1)}%',
                    Icons.show_chart,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricCard(
                    context,
                    'Advancing',
                    provider.advancingStocks.toString(),
                    Icons.trending_up,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricCard(
                    context,
                    'Declining',
                    provider.decliningStocks.toString(),
                    Icons.trending_down,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceGrid(List<FinancialAdvice> advice) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildAdviceCard(context, advice[index]),
        childCount: advice.length,
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context, FinancialAdvice advice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(advice.category),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advice.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              advice.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: advice.confidence,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(advice.confidence * 100).round()}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showAdviceDetails(BuildContext context, FinancialAdvice advice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                advice.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                advice.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Recommended Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...advice.actions.map((action) => ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(action),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Advice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Investment'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Savings'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Wealth Preservation'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Location-Based Advice'),
        content: const Text(
          'This feature provides personalized financial advice based on your current location and local market conditions. The advice is generated using various factors including:\n\n'
          '• Local economic indicators\n'
          '• Market volatility\n'
          '• Interest rates\n'
          '• Currency strength\n\n'
          'Refresh the page to get updated advice based on the latest market data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'investment':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      case 'wealth preservation':
        return Icons.account_balance;
      default:
        return Icons.insights;
    }
  }

  Widget _buildSocialAdviceSection(BuildContext context, String countryCode) {
    final theme = Theme.of(context);
    final socialAdvice = GetIt.I<LocationService>().getSocialMarketAdvice(countryCode);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Insights from Social Media',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: socialAdvice.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final advice = socialAdvice[index];
              return _buildSocialAdviceCard(context, advice);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAdviceCard(BuildContext context, SocialMarketAdvice advice) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                advice.platform == 'X' ? Icons.flutter_dash : Icons.work,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                advice.author,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                timeago.format(advice.timestamp),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            advice.content,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: advice.tags.map((tag) => Chip(
              label: Text(
                '#$tag',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: theme.colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                advice.likes.toString(),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.repeat,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                advice.shares.toString(),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 