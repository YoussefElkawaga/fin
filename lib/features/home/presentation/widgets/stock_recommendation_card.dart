import 'package:flutter/material.dart';
import 'package:fin/core/services/stock_scraper_service.dart';
import 'package:fin/features/home/presentation/widgets/stock_details_sheet.dart';
import 'package:fin/features/home/data/models/stock_recommendation.dart';

class StockRecommendationCard extends StatelessWidget {
  final StockRecommendation recommendation;

  const StockRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showStockDetails(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    recommendation.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _buildRiskIndicator(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricColumn(
                    context,
                    'Current Price',
                    '\$${recommendation.currentPrice.toStringAsFixed(2)}',
                  ),
                  _buildMetricColumn(
                    context,
                    'Potential Return',
                    '${recommendation.potentialReturn.toStringAsFixed(1)}%',
                    color: recommendation.potentialReturn >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildMetricColumn(
                    context,
                    'Rating',
                    recommendation.analystRating,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Source: ${recommendation.source}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStockDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StockDetailsSheet(recommendation: recommendation),
    );
  }

  Widget _buildRiskIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Risk: Medium',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
} 