import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static const String _marketDataKey = 'market_data_cache.json';

  // save market data
  Future<void> saveMarketData(Map<String, dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_marketDataKey');
      await file.writeAsString(json.encode(data));
    } catch (e) {
      // Silently fail cache saves
      debugPrint('Error saving market data cache: $e');
    }
  }

  // get cached market data
  Future<Map<String, dynamic>?> getMarketData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_marketDataKey');
      if (await file.exists()) {
        final content = await file.readAsString();
        return json.decode(content);
      }
    } catch (e) {
      // Silently fail cache retrieval
      debugPrint('Error retrieving market data cache: $e');
      return null;
    }
    return null;
  }
}
