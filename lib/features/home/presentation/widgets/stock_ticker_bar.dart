import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fin/features/home/providers/market_data_provider.dart';

class StockTickerBar extends StatefulWidget {
  const StockTickerBar({super.key});

  @override
  State<StockTickerBar> createState() => _StockTickerBarState();
}

class _StockTickerBarState extends State<StockTickerBar> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Slower scroll
    )..repeat();

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(
          (_animationController.value * maxScroll * 2) % maxScroll,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Slightly taller
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<MarketDataProvider>(
        builder: (context, provider, child) {
          final stocks = provider.stockPrices;
          if (stocks == null) return const SizedBox();

          final sortedStocks = List.from(stocks)
            ..sort((a, b) => b.currentPrice.compareTo(a.currentPrice));

          return Column(
            children: [
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                        Text(
                          ' ${sortedStocks.first.symbol} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '\$${sortedStocks.first.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                        Text(
                          ' ${sortedStocks.last.symbol} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '\$${sortedStocks.last.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stocks.length * 2, // Duplicate items for smooth infinite scroll
                  itemBuilder: (context, index) {
                    final stock = stocks[index % stocks.length];
                    final priceChange = stock.currentPrice - stock.openPrice;
                    final changePercentage = (priceChange / stock.openPrice) * 100;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            stock.symbol,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${stock.currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: changePercentage >= 0
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: changePercentage >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 