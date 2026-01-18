import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/cache_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  final CacheService _cacheService = CacheService();

  MarketDataModel marketData = MarketDataModel();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Try to load from cache first for immediate UI update
    final cachedData = await _cacheService.getMarketData();
    if (cachedData != null && marketData.data == null) {
      marketData = MarketDataModel.fromJson(cachedData);
      debugPrint('marketData; ${marketData.toJson()}');
      notifyListeners();
    }

    try {
      final data = await _apiService.getMarketData();
      marketData = data;
      // Save to cache for offline support
      await _cacheService.saveMarketData(data.toJson());
    } catch (e) {
      debugPrint('Error loading market data: $e');
      // Only set error if we have no data at all (neither cache nor previous fetch)
      if (marketData.data == null || marketData.data!.isEmpty) {
        _error = 'Unable to connect. Please check your internet connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startUpdates() {
    _wsService.connect();
    _wsService.stream?.listen((update) {
      _handleMarketUpdate(update);
    });
  }

  void stopUpdates() {
    _wsService.disconnect();
  }

  void _handleMarketUpdate(Map<String, dynamic> update) {
    if (update['type'] == 'market_update' && update['data'] != null) {
      final updatedItem = Data.fromJson(update['data']);
      final index = marketData.data
              ?.indexWhere((item) => item.symbol == updatedItem.symbol) ??
          -1;

      if (index != -1) {
        marketData.data![index] = updatedItem;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    stopUpdates();
    super.dispose();
  }
}
