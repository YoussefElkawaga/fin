import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';
import 'package:fin/features/home/data/models/price_alert.dart';
import 'package:fin/features/home/data/models/stock_price.dart';

class PriceAlertPage extends StatefulWidget {
  const PriceAlertPage({super.key});

  @override
  State<PriceAlertPage> createState() => _PriceAlertPageState();
}

class _PriceAlertPageState extends State<PriceAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAbove = true;
  String? _selectedSymbol;

  @override
  void dispose() {
    _symbolController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Consumer<MarketDataProvider>(
        builder: (context, provider, _) {
          final alerts = provider.priceAlerts;
          final stocks = provider.stockPrices ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available Stocks',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${stocks.length} stocks',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: stocks.length,
                          itemBuilder: (context, index) {
                            final stock = stocks[index];
                            final priceChange = stock.currentPrice - stock.openPrice;
                            final changePercentage = (priceChange / stock.openPrice) * 100;
                            final isPositive = changePercentage >= 0;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSymbol = stock.symbol;
                                  _symbolController.text = stock.symbol;
                                });
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _selectedSymbol == stock.symbol
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedSymbol == stock.symbol
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            stock.symbol,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _selectedSymbol == stock.symbol
                                                  ? theme.colorScheme.primary
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isPositive
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 16,
                                          color: isPositive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${stock.currentPrice.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isPositive ? Colors.green : Colors.red)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${isPositive ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: isPositive ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildAlertForm(context, provider, stocks),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active_outlined, 
                        color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                    'Active Alerts',
                        style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                      ),
                      const Spacer(),
                      Text(
                        '${alerts.length} alerts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (alerts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active alerts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAlertCard(
                        context,
                        alerts[index],
                        provider,
                      ),
                      childCount: alerts.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertForm(
    BuildContext context,
    MarketDataProvider provider,
    List<StockPrice> stocks,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_alert_outlined, 
                    color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
              Text(
                'Create New Alert',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSymbol,
                decoration: InputDecoration(
                  labelText: 'Select Stock',
                  prefixIcon: const Icon(Icons.show_chart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: stocks.map((stock) {
                  return DropdownMenuItem(
                    value: stock.symbol,
                    child: Row(
                      children: [
                        Text(stock.symbol),
                        const SizedBox(width: 8),
                        Text(
                          '\$${stock.currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSymbol = value;
                    _symbolController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Target Price',
                  hintText: 'e.g., 150.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Above', style: theme.textTheme.bodyLarge),
                      value: true,
                      groupValue: _isAbove,
                      onChanged: (value) {
                        setState(() => _isAbove = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text('Below', style: theme.textTheme.bodyLarge),
                      value: false,
                      groupValue: _isAbove,
                      onChanged: (value) {
                        setState(() => _isAbove = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      provider.addPriceAlert(
                        PriceAlert(
                          symbol: _selectedSymbol!,
                          targetPrice: double.parse(_priceController.text),
                          isAbove: _isAbove,
                          isEnabled: true,
                        ),
                      );
                      _selectedSymbol = null;
                      _symbolController.clear();
                      _priceController.clear();
                      setState(() => _isAbove = true);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Create Alert'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    PriceAlert alert,
    MarketDataProvider provider,
  ) {
    final theme = Theme.of(context);
    final currentPrice = provider.stockPrices
        ?.firstWhere(
          (stock) => stock.symbol == alert.symbol,
          orElse: () => StockPrice(
            symbol: alert.symbol,
            currentPrice: 0,
            openPrice: 0,
            dayHigh: 0,
            dayLow: 0,
            volume: 0,
          ),
        )
        .currentPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Dismissible(
        key: Key(alert.symbol + alert.targetPrice.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.onError,
          ),
        ),
        onDismissed: (_) => provider.deleteAlert(alert),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              alert.symbol[0],
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                alert.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Icon(
                alert.isAbove ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: alert.isAbove ? Colors.green : Colors.red,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target: ${alert.isAbove ? 'Above' : 'Below'} \$${alert.targetPrice.toStringAsFixed(2)}',
              ),
              if (currentPrice != null && currentPrice > 0)
                Text(
                  'Current: \$${currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: Switch.adaptive(
            value: alert.isEnabled,
            onChanged: (value) {
              provider.toggleAlertEnabled(alert, value);
            },
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Price Alerts'),
        content: const Text(
          'Price alerts notify you when a stock reaches your target price.\n\n'
          '• Set alerts for when prices go above or below your target\n'
          '• Enable or disable alerts using the switch\n'
          '• Swipe left to delete an alert\n'
          '• You\'ll receive notifications when price conditions are met',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
} 
  
