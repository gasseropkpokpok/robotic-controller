import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/communication_service.dart';

class AppState extends ChangeNotifier {
  final CommunicationService _commService = CommunicationService();
  
  bool _isConnected = false;
  String _targetIp = '';
  String _deviceType = 'Unknown';

  bool get isConnected => _isConnected;
  String get targetIp => _targetIp;
  String get deviceType => _deviceType;

  AppState() {
    _loadSavedIp();
    _commService.connectionStatusStream.listen((status) {
      _isConnected = status;
      notifyListeners();
    });
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _targetIp = prefs.getString('last_ip') ?? '';
    notifyListeners();
  }

  Future<void> connect(String ip, String type) async {
    _targetIp = ip;
    _deviceType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_ip', ip);
    
    await _commService.connect(ip);
  }

  void disconnect() {
    _commService.disconnect();
  }

  void sendSliderValue(int id, int value) {
    _commService.sendSliderValue(id, value);
  }

  void sendCommand(String command) {
    _commService.sendCommand(command);
  }

  void sendText(String text) {
    _commService.sendText(text);
  }
  
  @override
  void dispose() {
    _commService.dispose();
    super.dispose();
  }
}
