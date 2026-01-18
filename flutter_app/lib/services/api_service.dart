import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_data_model.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // get market data
  Future<MarketDataModel> getMarketData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/market-data'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return MarketDataModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // get analytics overview
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/analytics/overview'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load analytics: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // get analytics trends
  Future<Map<String, dynamic>> getAnalyticsTrends(String timeframe) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/analytics/trends?timeframe=$timeframe'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load trends: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // get analytics sentiment
  Future<Map<String, dynamic>> getAnalyticsSentiment() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/analytics/sentiment'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load sentiment: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
