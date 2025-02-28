import 'package:flutter/material.dart';
import 'package:fin/core/services/financial_advisor_service.dart';

class FinancialAdviceCard extends StatelessWidget {
  final FinancialAdvice advice;

  const FinancialAdviceCard({
    super.key,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showAdviceDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(advice.category),
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      advice.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildConfidenceIndicator(context, advice.confidence),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                advice.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildActionChips(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context, double confidence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getConfidenceColor(confidence).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 16,
            color: _getConfidenceColor(confidence),
          ),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getConfidenceColor(confidence),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: advice.actions.map((action) {
        return ActionChip(
          label: Text(action),
          onPressed: () {},
          avatar: const Icon(Icons.arrow_forward, size: 16),
        );
      }).toList(),
    );
  }

  void _showAdviceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AdviceDetailsSheet(advice: advice),
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
}

class _AdviceDetailsSheet extends StatelessWidget {
  final FinancialAdvice advice;

  const _AdviceDetailsSheet({required this.advice});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: controller,
          children: [
            Text(advice.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(advice.description),
            const SizedBox(height: 24),
            ...advice.actions.map((action) => ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(action),
            )),
          ],
        ),
      ),
    );
  }
} 