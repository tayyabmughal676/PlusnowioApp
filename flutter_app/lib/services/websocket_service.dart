import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  // connect
  void connect() {
    if (_controller != null && !_controller!.isClosed) {
      return;
    }

    _controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
      _channel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            _controller?.add(data);
          } catch (e) {
            debugPrint('Error decoding WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _reconnect();
        },
      );
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _reconnect();
    }
  }

  // reconnect
  void _reconnect() {
    if (_controller == null || _controller!.isClosed) return;

    Future.delayed(const Duration(seconds: 5), () {
      debugPrint('Attempting to reconnect WebSocket...');
      connect();
    });
  }

  // discount
  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _controller = null;
  }
}
