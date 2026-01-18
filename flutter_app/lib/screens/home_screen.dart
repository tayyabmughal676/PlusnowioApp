import 'package:flutter/material.dart';
import 'market_data_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text('PulseNow'),
      //   elevation: 0,
      // ),
      body: SafeArea(child: MarketDataScreen()),
    );
  }
}
