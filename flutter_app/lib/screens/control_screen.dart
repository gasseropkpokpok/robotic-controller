import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/robotic_slider.dart';
import 'connection_screen.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: appState.isConnected ? Colors.greenAccent : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: appState.isConnected ? Colors.greenAccent : Colors.red, blurRadius: 10, spreadRadius: 2),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              appState.isConnected 
                ? 'UPLINK ESTABLISHED: ${appState.deviceType.toUpperCase()} [${appState.targetIp}]'
                : 'OFFLINE - NO UPLINK',
              style: const TextStyle(fontSize: 14, letterSpacing: 2, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: TextButton.icon(
              icon: Icon(appState.isConnected ? Icons.settings_ethernet : Icons.wifi, color: Colors.redAccent),
              label: Text(appState.isConnected ? 'MANAGE UPLINK' : 'CONNECT', style: const TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConnectionScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    RoboticSlider(id: 1, label: 'JOINT-A'),
                    RoboticSlider(id: 2, label: 'JOINT-B'),
                    RoboticSlider(id: 3, label: 'JOINT-C'),
                    RoboticSlider(id: 4, label: 'JOINT-D'),
                    RoboticSlider(id: 5, label: 'JOINT-E'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(fontFamily: 'Courier'),
                        decoration: const InputDecoration(
                          hintText: 'ENTER OVERRIDE COMMAND...',
                          prefixIcon: Icon(Icons.terminal, color: Colors.redAccent),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          appState.sendText(_textController.text);
                          _textController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Icon(Icons.send),
                    ),
                    const SizedBox(width: 32),
                    Container(width: 2, height: 40, color: Colors.redAccent.withOpacity(0.3)),
                    const SizedBox(width: 32),
                    ElevatedButton.icon(
                      onPressed: () => appState.sendCommand('set'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('SET', style: TextStyle(letterSpacing: 2)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => appState.sendCommand('user one'),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('OP1', style: TextStyle(letterSpacing: 2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
