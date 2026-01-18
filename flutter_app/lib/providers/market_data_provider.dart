import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../services/cache_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  final CacheService _cacheService = CacheService();

  MarketDataModel _marketData = MarketDataModel();
  bool _isLoading = false;
  String? _error;
  String? _refreshError;
  StreamSubscription? _subscription;

  MarketDataModel get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get refreshError => _refreshError;

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    _refreshError = null;
    notifyListeners();

    // Try to load from cache first for immediate UI update
    final cachedData = await _cacheService.getMarketData();
    if (cachedData != null && (_marketData.data?.isEmpty ?? true)) {
      _marketData = MarketDataModel.fromJson(cachedData);
      debugPrint('marketData from cache: ${_marketData.toJson()}');
      notifyListeners();
    }

    try {
      final data = await _apiService.getMarketData();
      _marketData = data;
      // Save to cache for offline support
      await _cacheService.saveMarketData(data.toJson());
    } catch (e) {
      debugPrint('Error loading market data: $e');
      
      final errorMessage = 'Unable to connect. Please check your internet connection.';
      
      // If we have no data at all, set the hard error (shows error screen)
      if (_marketData.data == null || _marketData.data!.isEmpty) {
        _error = errorMessage;
      } else {
        // If we have cached data, set a refresh error (can be shown as a snackbar)
        _refreshError = errorMessage;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRefreshError() {
    _refreshError = null;
    notifyListeners();
  }

  void startUpdates() {
    _wsService.connect();
    // Cancel any existing subscription before starting a new one
    _subscription?.cancel();
    _subscription = _wsService.stream?.listen((update) {
      _handleMarketUpdate(update);
    });
  }

  void stopUpdates() {
    _subscription?.cancel();
    _subscription = null;
    _wsService.disconnect();
  }

  void _handleMarketUpdate(Map<String, dynamic> update) {
    if (update['type'] == 'market_update' && update['data'] != null) {
      final updatedItem = Data.fromJson(update['data']);
      final index = _marketData.data
              ?.indexWhere((item) => item.symbol == updatedItem.symbol) ??
          -1;

      if (index != -1) {
        _marketData.data![index] = updatedItem;
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
