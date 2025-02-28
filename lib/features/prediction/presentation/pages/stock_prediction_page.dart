import 'package:flutter/material.dart';
import 'package:fin/core/services/stock_prediction_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fin/features/prediction/data/models/stock_prediction.dart';
import 'package:fl_chart/fl_chart.dart';

class StockPredictionPage extends StatefulWidget {
  const StockPredictionPage({super.key});

  @override
  State<StockPredictionPage> createState() => _StockPredictionPageState();
}

class _StockPredictionPageState extends State<StockPredictionPage> {
  final TextEditingController _symbolController = TextEditingController();
  final StockPredictionService _predictionService = StockPredictionService();
  StockPrediction? _predictionResult;
  bool _isLoading = false;
  String? _error;

  Future<void> _predictStockPrice() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      setState(() => _error = 'Please enter a stock symbol');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _predictionService.predictStockPrice(symbol);
      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Price Prediction',
          style: TextStyle(fontFamily: 'Product Sans'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            if (_isLoading) 
              _buildLoadingIndicator()
            else if (_error != null) 
              _buildErrorMessage()
            else if (_predictionResult != null) 
              _buildPredictionResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Stock Symbol',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a stock symbol to get price predictions and analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Product Sans',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                hintText: 'e.g., AAPL, GOOGL, MSFT',
                hintStyle: TextStyle(
                  fontFamily: 'Product Sans',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: const TextStyle(fontFamily: 'Product Sans'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _predictStockPrice,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  'Predict Price',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing market data...',
              style: TextStyle(
                fontFamily: 'Product Sans',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.errorContainer,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  fontFamily: 'Product Sans',
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResult() {
    final prediction = _predictionResult!;
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Prediction Results',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildMetricRow(
              'Latest Predicted Price',
              '\$${prediction.futurePrices.last.toStringAsFixed(2)}',
              Icons.trending_up,
            ),
            _buildMetricRow(
              'Confidence Level',
              '${(prediction.confidence * 100).toStringAsFixed(1)}%',
              Icons.verified_outlined,
            ),
            _buildMetricRow(
              'Market Trend',
              prediction.metrics.trend.toUpperCase(),
              Icons.show_chart,
            ),
            _buildMetricRow(
              'Risk Level',
              prediction.metrics.riskLevel.toUpperCase(),
              Icons.warning_outlined,
            ),
            _buildMetricRow(
              'Volatility',
              '${(prediction.metrics.volatility * 100).toStringAsFixed(1)}%',
              Icons.analytics_outlined,
            ),
            const SizedBox(height: 16),
            _buildPriceChart(prediction.futurePrices),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart(List<double> prices) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.surfaceVariant,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      'Day ${value.toInt() + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _calculateInterval(prices),
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 1,
              ),
              left: BorderSide(
                color: Theme.of(context).colorScheme.surfaceVariant,
                width: 1,
              ),
            ),
          ),
          minX: 0,
          maxX: prices.length.toDouble() - 1,
          minY: _calculateMinY(prices),
          maxY: _calculateMaxY(prices),
          lineBarsData: [
            LineChartBarData(
              spots: prices.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(List<double> prices) {
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);
    final difference = max - min;
    return difference / 5;
  }

  double _calculateMinY(List<double> prices) {
    final min = prices.reduce((a, b) => a < b ? a : b);
    return min - (min * 0.05); // 5% padding
  }

  double _calculateMaxY(List<double> prices) {
    final max = prices.reduce((a, b) => a > b ? a : b);
    return max + (max * 0.05); // 5% padding
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'About Stock Prediction',
          style: TextStyle(fontFamily: 'Product Sans'),
        ),
        content: const Text(
          'This feature uses machine learning algorithms to predict stock prices based on historical data and market trends. Predictions are estimates and should not be the sole basis for investment decisions.',
          style: TextStyle(fontFamily: 'Product Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(fontFamily: 'Product Sans'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }
} 