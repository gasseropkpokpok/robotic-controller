import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late TextEditingController _ipController;
  String _selectedDevice = 'PC';
  bool _isScanning = false;
  List<String> _foundDevices = [];
  RawDatagramSocket? _udpSocket;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _ipController = TextEditingController(text: appState.targetIp);
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _foundDevices = [];
    });

    try {
      // Bind to the broadcast port (8766)
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8766);
      _udpSocket?.broadcastEnabled = true;
      
      _udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _udpSocket?.receive();
          if (dg != null) {
            final message = String.fromCharCodes(dg.data);
            // Payload format: "ROBOT_CTRL:IP:PORT"
            if (message.startsWith('ROBOT_CTRL:')) {
              final parts = message.split(':');
              if (parts.length >= 2) {
                final ip = parts[1];
                if (!mounted) return;
                if (!_foundDevices.contains(ip)) {
                  setState(() {
                    _foundDevices.add(ip);
                  });
                }
              }
            }
          }
        }
      });

      // Stop scanning after 15 seconds to save battery/resources
      _scanTimer = Timer(const Duration(seconds: 15), _stopDiscovery);
    } catch (e) {
      debugPrint('UDP Discovery Error: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _stopDiscovery() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    _udpSocket?.close();
    _udpSocket = null;
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  void dispose() {
    _stopDiscovery();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONNECTION MANAGEMENT', style: TextStyle(fontFamily: 'Courier')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: Colors.redAccent.withOpacity(0.1), blurRadius: 100),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Connection Panel
                  Container(
                    width: 400,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hub, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text(
                          'SYSTEM UPLINK',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            fontFamily: 'Courier',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _ipController,
                          style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            labelText: 'TARGET IP ADDRESS',
                            hintText: '192.168.x.x',
                            prefixIcon: Icon(Icons.radar, color: Colors.redAccent),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'PC', label: Text('PC SIMULATION')),
                            ButtonSegment(value: 'ESP32', label: Text('ESP32 HARDWARE')),
                          ],
                          selected: {_selectedDevice},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedDevice = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.red.shade900;
                                }
                                return Colors.transparent;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_ipController.text.trim().isNotEmpty) {
                                context.read<AppState>().connect(
                                  _ipController.text.trim(),
                                  _selectedDevice,
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('INITIALIZE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (context.watch<AppState>().isConnected) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                foregroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                context.read<AppState>().disconnect();
                              },
                              child: const Text('TERMINATE UPLINK'),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Available Devices Panel
                  Container(
                    width: 300,
                    height: 480,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AVAILABLE DEVICES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            if (_isScanning)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20),
                                onPressed: _startDiscovery,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const Divider(color: Colors.redAccent),
                        const SizedBox(height: 8),
                        if (_foundDevices.isEmpty && !_isScanning)
                          const Expanded(
                            child: Center(
                              child: Text('No devices found.', style: TextStyle(color: Colors.white54, fontFamily: 'Courier')),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: _foundDevices.length,
                              itemBuilder: (context, index) {
                                final ip = _foundDevices[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.memory, color: Colors.greenAccent),
                                  title: Text(ip, style: const TextStyle(fontFamily: 'Courier', color: Colors.white)),
                                  onTap: () {
                                    _ipController.text = ip;
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
