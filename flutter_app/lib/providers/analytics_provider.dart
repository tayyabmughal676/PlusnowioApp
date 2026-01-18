import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _trends;
  Map<String, dynamic>? _sentiment;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get overview => _overview;

  Map<String, dynamic>? get trends => _trends;

  Map<String, dynamic>? get sentiment => _sentiment;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // load overview
  Future<void> loadOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAnalyticsOverview();
      _overview = response['data'];
    } catch (e) {
      _error = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // load trends
  Future<void> loadTrends(String timeframe) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAnalyticsTrends(timeframe);
      _trends = response['data'];
    } catch (e) {
      _error = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // load sentiment data
  Future<void> loadSentiment() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAnalyticsSentiment();
      _sentiment = response['data'];
    } catch (e) {
      _error = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // handle errors
  String _handleError(dynamic e) {
    debugPrint('Analytics Error: $e');
    if (e.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please check your internet.';
    }
    return 'Failed to load analytics data. Tap to retry.';
  }
}
