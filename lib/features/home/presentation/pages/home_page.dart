import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/presentation/widgets/market_overview_card.dart';
import 'package:fin/features/home/presentation/widgets/risk_indicator_card.dart';
import 'package:fin/features/home/presentation/widgets/news_sentiment_card.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/presentation/widgets/stock_ticker_bar.dart';
import 'package:fin/features/home/presentation/widgets/market_chart_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Overview'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Navigate to notifications page
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              // TODO: Navigate to profile page
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
                const NewsSentimentCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add quick action
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Set Alert'),
        tooltip: 'Set Price Alert',
      ),
    );
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
}