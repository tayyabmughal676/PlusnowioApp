import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/market_data_model.dart';

class DetailScreen extends StatelessWidget {
  final Data data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final compactCurrencyFormat = NumberFormat.compactCurrency(symbol: '\$');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    
    final changePercent = (data.changePercent24h ?? 0) / 100;
    final isPositive = changePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(data.symbol ?? 'Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Section
            Center(
              child: Column(
                children: [
                  Text(
                    currencyFormat.format(data.price ?? 0),
                    style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: changeColor,
                        size: 32,
                      ),
                      Text(
                        '${percentFormat.format(changePercent.abs())} (${data.change24h ?? 0})',
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Statistics Section
            Text(
              'Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _StatRow(
              label: '24h High',
              value: currencyFormat.format(data.high24h ?? 0),
            ),
            _StatRow(
              label: '24h Low',
              value: currencyFormat.format(data.low24h ?? 0),
            ),
            _StatRow(
              label: 'Market Cap',
              value: compactCurrencyFormat.format(data.marketCap ?? 0),
            ),
            _StatRow(
              label: 'Volume (24h)',
              value: compactCurrencyFormat.format(data.volume ?? 0),
            ),
            if (data.lastUpdated != null)
              _StatRow(
                label: 'Last Updated',
                value: DateFormat.yMMMd()
                    .add_jms()
                    .format(DateTime.parse(data.lastUpdated!)),
              ),
            const SizedBox(height: 32),

            // Description Section
            Text(
              'About ${data.symbol?.split('/').first ?? 'Asset'}',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            Text(
              data.description ?? 'No description available.',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
