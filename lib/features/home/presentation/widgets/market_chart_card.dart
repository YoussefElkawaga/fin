import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/data/models/chart_data.dart';
import 'package:fin/features/home/data/models/market_data.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class MarketChartCard extends StatefulWidget {
  const MarketChartCard({super.key});

  @override
  State<MarketChartCard> createState() => _MarketChartCardState();
}

class _MarketChartCardState extends State<MarketChartCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();

    // Reset animation when data updates
    Provider.of<MarketDataProvider>(context, listen: false)
        .addListener(_resetAnimation);
  }

  void _resetAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    Provider.of<MarketDataProvider>(context, listen: false)
        .removeListener(_resetAnimation);
    _controller.dispose();
    super.dispose();
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
                Expanded(
                  child: Text('Market Overview', style: Theme.of(context).textTheme.titleLarge),
                ),
                _buildTimeframeSelector(),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                final data = provider.marketData;
                if (data == null) return const Center(child: CircularProgressIndicator());

                return Column(
                  children: [
                    _buildChart(context, data.historicalData),
                    const SizedBox(height: 16),
                    _buildMarketMetrics(context, data),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        return SegmentedButton<String>(
          selected: {provider.currentTimeframe},
          onSelectionChanged: (Set<String> selection) {
            provider.updateTimeframe(selection.first);
          },
          segments: const [
            ButtonSegment(value: '1D', label: Text('1D')),
            ButtonSegment(value: '1W', label: Text('1W')),
            ButtonSegment(value: '1M', label: Text('1M')),
            ButtonSegment(value: '1Y', label: Text('1Y')),
          ],
        );
      },
    );
  }
  Widget _buildChart(BuildContext context, List<ChartData> data) {
    if (data.isEmpty) return const SizedBox(height: 200);
    
    final minPrice = data.map((e) => e.price).reduce(math.min);
    final maxPrice = data.map((e) => e.price).reduce(math.max);
    final priceRange = maxPrice - minPrice;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minPrice - (priceRange * 0.05),
              maxY: maxPrice + (priceRange * 0.05),
              clipData: FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: _getPriceInterval(data),
                verticalInterval: _getTimeInterval(context, data),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    strokeWidth: 0.5,
                    dashArray: [5, 5],
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    strokeWidth: 0.5,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _getTimeInterval(context, data),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= data.length || value.toInt() < 0) return const Text('');
                      final date = data[value.toInt()].timestamp;
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          _formatDateTime(context, date),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _getPriceInterval(data),
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(2),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.price,
                    );
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.35,
                  preventCurveOverShooting: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        Theme.of(context).colorScheme.primary.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.8],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  String _formatDateTime(BuildContext context, DateTime dateTime) {
    switch (Provider.of<MarketDataProvider>(context, listen: false).currentTimeframe) {
      case '1D': return DateFormat('HH:mm').format(dateTime);
      case '1W': return DateFormat('E').format(dateTime);
      case '1M': return DateFormat('MMM d').format(dateTime);
      case '1Y': return DateFormat('MMM').format(dateTime);
      default: return DateFormat('MMM d').format(dateTime);
    }
  }

  double _getTimeInterval(BuildContext context, List<ChartData> data) {
    final timeframe = Provider.of<MarketDataProvider>(context, listen: false).currentTimeframe;
    switch (timeframe) {
      case '1D': return data.length / 6;
      case '1W': return data.length / 7;
      case '1M': return data.length / 6;
      case '1Y': return data.length / 12;
      default: return data.length / 6;
    }
  }

  double _getPriceInterval(List<ChartData> data) {
    final prices = data.map((e) => e.price).toList();
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    return (maxPrice - minPrice) / 5;
  }

  Widget _buildMarketMetrics(BuildContext context, MarketData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(context, 'Volume', '${(data.totalVolume / 1000000).toStringAsFixed(1)}M', Icons.show_chart),
              _buildMetricItem(context, 'VIX', data.volatilityIndex.toStringAsFixed(2), Icons.analytics),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(context, 'Advancing', data.advancingStocks.toString(), Icons.arrow_upward, color: Colors.green),
              _buildMetricItem(context, 'Declining', data.decliningStocks.toString(), Icons.arrow_downward, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}