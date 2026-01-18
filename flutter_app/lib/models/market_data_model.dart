import 'dart:convert';

MarketDataModel marketDataModelFromJson(String str) =>
    MarketDataModel.fromJson(json.decode(str));

String marketDataModelToJson(MarketDataModel data) =>
    json.encode(data.toJson());

class MarketDataModel {
  MarketDataModel({
    bool? success,
    List<Data>? data,
  }) {
    _success = success;
    _data = data;
  }

  MarketDataModel.fromJson(dynamic json) {
    _success = json['success'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }

  bool? _success;
  List<Data>? _data;

  MarketDataModel copyWith({
    bool? success,
    List<Data>? data,
  }) =>
      MarketDataModel(
        success: success ?? _success,
        data: data ?? _data,
      );

  bool? get success => _success;

  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    String? symbol,
    String? description,
    num? price,
    num? change24h,
    num? changePercent24h,
    num? volume,
    num? high24h,
    num? low24h,
    num? marketCap,
    String? lastUpdated,
  }) {
    _symbol = symbol;
    _description = description;
    _price = price;
    _change24h = change24h;
    _changePercent24h = changePercent24h;
    _volume = volume;
    _high24h = high24h;
    _low24h = low24h;
    _marketCap = marketCap;
    _lastUpdated = lastUpdated;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  Data.fromJson(dynamic json) {
    _symbol = json['symbol'];
    _description = json['description'];
    _price = _parseNum(json['price']);
    _change24h = _parseNum(json['change24h']);
    _changePercent24h = _parseNum(json['changePercent24h']);
    _volume = _parseNum(json['volume']);
    _high24h = _parseNum(json['high24h']);
    _low24h = _parseNum(json['low24h']);
    _marketCap = _parseNum(json['marketCap']);
    _lastUpdated = json['lastUpdated'];
  }

  String? _symbol;
  String? _description;
  num? _price;
  num? _change24h;
  num? _changePercent24h;
  num? _volume;
  num? _high24h;
  num? _low24h;
  num? _marketCap;
  String? _lastUpdated;

  Data copyWith({
    String? symbol,
    String? description,
    num? price,
    num? change24h,
    num? changePercent24h,
    num? volume,
    num? high24h,
    num? low24h,
    num? marketCap,
    String? lastUpdated,
  }) =>
      Data(
        symbol: symbol ?? _symbol,
        description: description ?? _description,
        price: price ?? _price,
        change24h: change24h ?? _change24h,
        changePercent24h: changePercent24h ?? _changePercent24h,
        volume: volume ?? _volume,
        high24h: high24h ?? _high24h,
        low24h: low24h ?? _low24h,
        marketCap: marketCap ?? _marketCap,
        lastUpdated: lastUpdated ?? _lastUpdated,
      );

  String? get symbol => _symbol;
  String? get description => _description;
  num? get price => _price;
  num? get change24h => _change24h;
  num? get changePercent24h => _changePercent24h;
  num? get volume => _volume;
  num? get high24h => _high24h;
  num? get low24h => _low24h;
  num? get marketCap => _marketCap;
  String? get lastUpdated => _lastUpdated;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = _symbol;
    map['description'] = _description;
    map['price'] = _price;
    map['change24h'] = _change24h;
    map['changePercent24h'] = _changePercent24h;
    map['volume'] = _volume;
    map['high24h'] = _high24h;
    map['low24h'] = _low24h;
    map['marketCap'] = _marketCap;
    map['lastUpdated'] = _lastUpdated;
    return map;
  }
}
