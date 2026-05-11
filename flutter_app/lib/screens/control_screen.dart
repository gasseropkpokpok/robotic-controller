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

  static const _joints = ['J1', 'J2', 'J3', 'J4', 'J5'];
  static const _labels = ['JOINT-A', 'JOINT-B', 'JOINT-C', 'JOINT-D', 'JOINT-E'];

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
                  BoxShadow(
                    color: appState.isConnected ? Colors.greenAccent : Colors.red,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              appState.isConnected
                  ? 'UPLINK: ${appState.deviceType.toUpperCase()} [${appState.targetIp}]'
                  : 'OFFLINE - NO UPLINK',
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
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
              icon: Icon(
                appState.isConnected ? Icons.settings_ethernet : Icons.wifi,
                color: Colors.redAccent,
              ),
              label: Text(
                appState.isConnected ? 'MANAGE' : 'CONNECT',
                style: const TextStyle(color: Colors.redAccent),
              ),
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
        child: Column(
          children: [
            // Sliders panel — scrollable if needed
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: ListView.builder(
                  itemCount: _joints.length,
                  itemBuilder: (context, index) {
                    final joint = _joints[index];
                    return RoboticSlider(
                      id: index + 1,
                      label: _labels[index],
                      value: appState.sliderValues[joint]!.toDouble(),
                      onChanged: (v) => appState.updateSlider(joint, v.round()),
                    );
                  },
                ),
              ),
            ),
            // Command bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
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
                        hintText: 'ENTER COMMAND...',
                        prefixIcon: Icon(Icons.terminal, color: Colors.redAccent),
                        isDense: true,
                      ),
                      onSubmitted: (v) {
                        if (v.isNotEmpty) {
                          appState.sendCommand(v.trim());
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        appState.sendCommand(_textController.text.trim());
                        _textController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Icon(Icons.send),
                  ),
                  const SizedBox(width: 24),
                  Container(width: 2, height: 36, color: Colors.redAccent.withOpacity(0.3)),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: () => appState.sendCommand('set'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('SET', style: TextStyle(letterSpacing: 2)),
                  ),
                  const SizedBox(width: 12),
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
    );
  }
}
