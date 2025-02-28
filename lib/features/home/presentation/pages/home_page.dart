import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/presentation/widgets/market_overview_card.dart';
import 'package:fin/features/home/presentation/widgets/risk_indicator_card.dart';
import 'package:fin/features/home/presentation/widgets/news_sentiment_card.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/presentation/widgets/stock_ticker_bar.dart';
import 'package:fin/features/home/presentation/widgets/market_chart_card.dart';
import 'package:fin/features/home/presentation/widgets/financial_advice_card.dart';
import 'package:fin/features/home/presentation/pages/location_advisor_page.dart';
import 'package:fin/features/home/presentation/pages/investment_chat_page.dart';
import 'package:fin/features/prediction/presentation/pages/stock_prediction_page.dart';
import 'package:fin/features/home/presentation/pages/price_alert_page.dart';
import 'package:fin/features/profile/presentation/pages/profile_page.dart';
import 'package:fin/core/providers/theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fin'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => _showNotificationsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Stock Prediction',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockPredictionPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Location Advice',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationAdvisorPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StockTickerBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const MarketChartCard(),
                const SizedBox(height: 16),
                const RiskIndicatorCard(),
                const SizedBox(height: 16),
                Consumer<MarketDataProvider>(
                  builder: (context, provider, _) {
                    final advice = provider.financialAdvice;
                    if (advice == null) return const SizedBox();
                    
                    return Column(
                      children: advice.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FinancialAdviceCard(advice: item),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const NewsSentimentCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvestmentChatPage(),
                ),
              );
            },
            child: const Icon(Icons.chat),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'alert',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PriceAlertPage(),
                ),
              );
            },
            icon: const Icon(Icons.add_alert),
            label: const Text('Set Alert'),
            tooltip: 'Set Price Alert',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Clear all notifications
                        Navigator.pop(context);
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  _NotificationItem(
                    icon: Icons.trending_up,
                    title: 'AAPL Price Alert',
                    message: 'Apple stock has risen above \$190.50',
                    time: '2 min ago',
                    color: Colors.green,
                  ),
                  _NotificationItem(
                    icon: Icons.warning_outlined,
                    title: 'High Market Volatility',
                    message: 'Market volatility has increased significantly',
                    time: '15 min ago',
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // Handle notification tap
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMarketInsightsCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Market Insights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInsightCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Market Trends',
                  subtitle: 'Analyze patterns',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInsightCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Risk Analysis',
                  subtitle: 'Risk breakdown',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildInsightCard(
                  context,
                  icon: Icons.article,
                  title: 'Reports',
                  subtitle: 'Expert analysis',
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInsightCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Card(
    elevation: 0,
    color: color.withOpacity(0.1),
    child: InkWell(
      onTap: () {
        // TODO: Navigate to respective page
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}