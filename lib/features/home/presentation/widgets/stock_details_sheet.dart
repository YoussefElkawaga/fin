import 'package:flutter/material.dart';
import 'package:fin/core/services/stock_scraper_service.dart';
import 'package:fin/features/home/data/models/stock_recommendation.dart';

class StockDetailsSheet extends StatelessWidget {
  final StockRecommendation recommendation;

  const StockDetailsSheet({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          children: [
            Text(
              '${recommendation.name} (${recommendation.symbol})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...recommendation.insights.map((insight) => ListTile(
              leading: const Icon(Icons.insights),
              title: Text(insight),
            )),
          ],
        ),
      ),
    );
  }
} 