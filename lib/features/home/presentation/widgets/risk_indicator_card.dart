import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';

class RiskIndicatorCard extends StatefulWidget {
  const RiskIndicatorCard({super.key});

  @override
  State<RiskIndicatorCard> createState() => _RiskIndicatorCardState();
}

class _RiskIndicatorCardState extends State<RiskIndicatorCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scoreAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRiskColor(double score) {
    if (score < 3) return Colors.green;
    if (score < 5) return Colors.yellow;
    if (score < 7) return Colors.orange;
    return Colors.red;
  }

  String _getRiskLevel(double score) {
    if (score < 3) return 'Low';
    if (score < 5) return 'Moderate';
    if (score < 7) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Risk Level',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // TODO: Show risk info dialog
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                final data = provider.marketData;
                if (data == null) return const SizedBox();
                
                return ScaleTransition(
                  scale: _scoreAnimation,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: CircularProgressIndicator(
                              value: data.riskScore / 10,
                              strokeWidth: 12,
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getRiskColor(data.riskScore),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                data.riskScore.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getRiskLevel(data.riskScore),
                                style: TextStyle(
                                  color: _getRiskColor(data.riskScore),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Market risk is ${_getRiskLevel(data.riskScore).toLowerCase()}. Consider adjusting your portfolio accordingly.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 