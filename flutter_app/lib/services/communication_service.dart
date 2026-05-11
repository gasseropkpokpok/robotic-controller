import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CommunicationService {
  WebSocketChannel? _channel;
  final _connectionStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> connect(String ip) async {
    try {
      final wsUrl = Uri.parse('ws://$ip:8765');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _connectionStatusController.add(true);

      _channel!.stream.listen(
        (message) {},
        onDone: () {
          _connectionStatusController.add(false);
        },
        onError: (error) {
          _connectionStatusController.add(false);
        },
      );
    } catch (e) {
      _connectionStatusController.add(false);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _connectionStatusController.add(false);
  }

  void _sendRaw(String data) {
    if (_channel != null) {
      try {
        _channel!.sink.add(data);
      } catch (e) {
        // Silently ignore send errors
      }
    }
  }

  /// Send all slider values as a flat map: {"J1": 45, "J2": -30, ...}
  void sendAllSliders(Map<String, int> values) {
    _sendRaw(jsonEncode(values));
  }

  /// Send a simple command string: "set", "user one", etc.
  void sendCommand(String command) {
    _sendRaw(command);
  }

  void dispose() {
    _connectionStatusController.close();
    _channel?.sink.close();
  }
}
