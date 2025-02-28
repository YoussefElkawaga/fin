import 'package:flutter/material.dart';
import 'package:fin/features/home/data/models/market_overview.dart';

class MarketOverviewPanel extends StatelessWidget {
  final MarketOverview overview;

  const MarketOverviewPanel({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Market Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildMetricsGrid(context),
          const Divider(height: 1),
          _buildMarketStatus(context),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: overview.metrics.length,
      itemBuilder: (context, index) {
        final metric = overview.metrics[index];
        return _buildMetricCard(context, metric);
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, MarketMetric metric) {
    final theme = Theme.of(context);
    final isPositive = metric.change >= 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.name,
            style: theme.textTheme.titleSmall,
          ),
          const Spacer(),
          Text(
            '${metric.value.toStringAsFixed(2)} ${metric.unit}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              Text(
                '${metric.change.abs().toStringAsFixed(2)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStatus(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(
                context,
                'Trend: ${overview.status.trend.toUpperCase()}',
                Icons.trending_up,
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                context,
                'Volatility: ${(overview.status.volatility * 100).round()}%',
                Icons.analytics,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: overview.status.confidence,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            'Market Confidence: ${(overview.status.confidence * 100).round()}%',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: theme.colorScheme.primary,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall,
      ),
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }
} 