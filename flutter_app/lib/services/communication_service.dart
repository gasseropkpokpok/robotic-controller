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
      
      // Assume connected if we can listen to the stream
      _connectionStatusController.add(true);

      _channel!.stream.listen(
        (message) {
          // Can handle incoming data from ESP32/PC here
        },
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

  void _sendJson(Map<String, dynamic> data) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        // Silently ignore send errors
      }
    }
  }

  void sendSliderValue(int id, int value) {
    _sendJson({
      'type': 'slider',
      'id': id,
      'value': value,
    });
  }

  void sendCommand(String command) {
    _sendJson({
      'type': 'command',
      'value': command,
    });
  }

  void sendText(String text) {
    _sendJson({
      'type': 'text',
      'value': text,
    });
  }

  void dispose() {
    _connectionStatusController.close();
    _channel?.sink.close();
  }
}
