import 'package:flutter_test/flutter_test.dart';
import 'package:pulsenow_flutter/models/market_data_model.dart';

void main() {
  group('MarketDataModel Unit Tests', () {
    test('should parse valid JSON correctly', () {
      final json = {
        "success": true,
        "data": [
          {
            "symbol": "BTC/USD",
            "price": 43250.06,
            "change24h": 2.5,
            "changePercent24h": 2.5,
            "volume": 1250000000,
            "high24h": 44500,
            "low24h": 42000,
            "marketCap": 850000000000,
            "lastUpdated": "2026-01-18T07:39:28.767Z"
          }
        ]
      };

      final model = MarketDataModel.fromJson(json);

      expect(model.success, true);
      expect(model.data?.length, 1);
      expect(model.data?[0].symbol, 'BTC/USD');
      expect(model.data?[0].price, 43250.06);
    });

    test('should handle string values for numeric fields gracefully', () {
      final json = {
        "success": true,
        "data": [
          {
            "symbol": "ETH/USD",
            "price": "2651.13",
            "change24h": "-1.2",
            "volume": "850000000"
          }
        ]
      };

      final model = MarketDataModel.fromJson(json);

      expect(model.data?[0].price, 2651.13);
      expect(model.data?[0].change24h, -1.2);
      expect(model.data?[0].volume, 850000000);
    });

    test('should handle null values in JSON', () {
      final json = {
        "success": true,
        "data": [
          {
            "symbol": "SOL/USD",
            "price": null,
            "change24h": 5.3
          }
        ]
      };

      final model = MarketDataModel.fromJson(json);

      expect(model.data?[0].symbol, 'SOL/USD');
      expect(model.data?[0].price, null);
      expect(model.data?[0].change24h, 5.3);
    });

    test('toJson should return correct map structure', () {
      final data = Data(
        symbol: 'ADA/USD',
        price: 0.52,
        change24h: 1.8,
      );
      final model = MarketDataModel(success: true, data: [data]);

      final json = model.toJson();

      expect(json['success'], true);
      expect(json['data'][0]['symbol'], 'ADA/USD');
      expect(json['data'][0]['price'], 0.52);
    });
  });
}
