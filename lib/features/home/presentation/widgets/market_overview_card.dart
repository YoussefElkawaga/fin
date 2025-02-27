import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/data/models/market_data.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketOverviewCard extends StatefulWidget {
  const MarketOverviewCard({super.key});

  @override
  State<MarketOverviewCard> createState() => _MarketOverviewCardState();
}

class _MarketOverviewCardState extends State<MarketOverviewCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _priceAnimation;
  late Animation<double> _chartAnimation;
  String _selectedTimeframe = '1D';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _priceAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTimeframeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(value: '1D', label: Text('1D')),
          ButtonSegment<String>(value: '1W', label: Text('1W')),
          ButtonSegment<String>(value: '1M', label: Text('1M')),
          ButtonSegment<String>(value: '1Y', label: Text('1Y')),
        ],
        selected: {_selectedTimeframe},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedTimeframe = newSelection.first;
          });
          context.read<MarketDataProvider>().updateTimeframe(_selectedTimeframe);
        },
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  String _getMarketSummary(MarketData data) {
    final sentiment = data.marketSentiment.toLowerCase();
    final volume = (data.totalVolume / 1000000).toStringAsFixed(1);
    final trend = data.percentageChange >= 0 ? 'up' : 'down';
    final change = data.percentageChange.abs().toStringAsFixed(2);
    
    return '''The market is currently showing $sentiment sentiment with trading volume of $volume million shares. Overall market is $trend $change% with ${data.advancingStocks} stocks advancing and ${data.decliningStocks} declining. Market volatility index (VIX) is at ${data.volatilityIndex.toStringAsFixed(2)}.''';
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
              children: [
                Expanded(
                  child: Text(
                    'Market Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildTimeframeSelector(),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.error != null) {
                  return Center(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }

                final data = provider.marketData;
                if (data == null) return const SizedBox();

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${data.currentPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    data.percentageChange >= 0 
                                        ? Icons.arrow_upward 
                                        : Icons.arrow_downward,
                                    color: data.percentageChange >= 0 
                                        ? Colors.green 
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${data.percentageChange.abs().toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: data.percentageChange >= 0 
                                          ? Colors.green 
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildMarketStatus(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        // Your chart configuration here
                        LineChartData(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMarketSummary(data),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Market Open',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 