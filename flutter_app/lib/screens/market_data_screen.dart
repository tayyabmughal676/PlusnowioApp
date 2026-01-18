import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/market_data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/market_data_model.dart';
import 'detail_screen.dart';

enum SortOption { symbol, price, change }

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortBy = SortOption.symbol;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MarketDataProvider>(context, listen: false);
      provider.loadMarketData().then((_) {
        provider.startUpdates();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return PopupMenuButton<ThemeMode>(
              icon: Icon(themeProvider.getThemeIcon()),
              onSelected: (ThemeMode mode) {
                themeProvider.setThemeMode(mode);
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ThemeMode>>[
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: ListTile(
                    leading: Icon(Icons.brightness_auto_rounded),
                    title: Text('System'),
                  ),
                ),
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: ListTile(
                    leading: Icon(Icons.light_mode_rounded),
                    title: Text('Light'),
                  ),
                ),
                const PopupMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: ListTile(
                    leading: Icon(Icons.dark_mode_rounded),
                    title: Text('Dark'),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (SortOption result) {
              setState(() {
                if (_sortBy == result) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = result;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.symbol,
                child: ListTile(
                  leading: Icon(Icons.sort_by_alpha),
                  title: Text('Symbol'),
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.price,
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Price'),
                ),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.change,
                child: ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('Change'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/]')),
              ],
              decoration: InputDecoration(
                hintText: 'Search assets (e.g. BTC)...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong.',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async =>
                                await provider.loadMarketData(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<Data> marketDataList =
                    List.from(provider.marketData.data ?? []);

                if (_searchQuery.isNotEmpty) {
                  marketDataList = marketDataList.where((data) {
                    return (data.symbol ?? '')
                        .toLowerCase()
                        .contains(_searchQuery);
                  }).toList();
                }

                marketDataList.sort((a, b) {
                  int compare;
                  switch (_sortBy) {
                    case SortOption.symbol:
                      compare = (a.symbol ?? '').compareTo(b.symbol ?? '');
                      break;
                    case SortOption.price:
                      compare = (a.price ?? 0).compareTo(b.price ?? 0);
                      break;
                    case SortOption.change:
                      compare = (a.changePercent24h ?? 0)
                          .compareTo(b.changePercent24h ?? 0);
                      break;
                  }
                  return _sortAscending ? compare : -compare;
                });

                if (marketDataList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Theme.of(context).hintColor),
                        const SizedBox(height: 16),
                        const Text('No assets match your search'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => await provider.loadMarketData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemExtent: 92,
                    itemCount: marketDataList.length,
                    itemBuilder: (context, index) {
                      return _MarketDataItem(
                        key: ValueKey(marketDataList[index].symbol),
                        data: marketDataList[index],
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDataItem extends StatelessWidget {
  final Data data;
  final int index;

  const _MarketDataItem({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);

    final changePercent = (data.changePercent24h ?? 0) / 100;
    final isPositive = changePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 30)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DetailScreen(data: data),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(begin: begin, end: end).chain(
                      CurveTween(curve: curve),
                    );
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${data.symbol}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        data.symbol?.split('/').first ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.symbol ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vol: ${NumberFormat.compactCurrency(symbol: '\$').format(data.volume ?? 0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(data.price ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: changeColor,
                              size: 16,
                            ),
                            Text(
                              percentFormat.format(changePercent.abs()),
                              style: TextStyle(
                                color: changeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
