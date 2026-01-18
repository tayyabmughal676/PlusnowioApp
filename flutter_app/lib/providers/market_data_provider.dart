import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();

  MarketDataModel marketData = MarketDataModel();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      marketData = data;
    } catch (e) {
      debugPrint('Error loading market data: $e');
      _error = e.toString();
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
      final index = marketData.data?.indexWhere((item) => item.symbol == updatedItem.symbol) ?? -1;
      
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
