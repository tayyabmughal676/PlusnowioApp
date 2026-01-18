import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pulsenow_flutter/models/market_data_model.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  // TODO: Implement getMarketData() method
  // This should call GET /api/market-data and return the response
  // Example:
  // Future<List<Map<String, dynamic>>> getMarketData() async {
  //   final response = await http.get(Uri.parse('$baseUrl/market-data'));
  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     return List<Map<String, dynamic>>.from(jsonData['data']);
  //   } else {
  //     debugPrint('Failed to load market data: ${response.statusCode}');
  //     throw Exception('Failed to load market data: ${response.statusCode}');
  //   }
  // }

  Future<MarketDataModel> getMarketData() async {
    final response = await http.get(Uri.parse('$baseUrl/market-data'));
    if (response.statusCode == 200) {
      return MarketDataModel.fromJson(json.decode(response.body));
      // final jsonData = json.decode(response.body);
      // return List<Map<String, dynamic>>.from(jsonData['data']);
    } else {
      debugPrint('Failed to load market data: ${response.statusCode}');
      throw Exception('Failed to load market data: ${response.statusCode}');
    }
  }
}
