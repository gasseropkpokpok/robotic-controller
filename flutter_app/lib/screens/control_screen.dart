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
      resizeToAvoidBottomInset: false, // Prevent keyboard from pushing everything up
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: appState.isConnected ? Colors.greenAccent : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: appState.isConnected ? Colors.greenAccent : Colors.red,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              appState.isConnected
                  ? 'UPLINK: ${appState.deviceType.toUpperCase()} [${appState.targetIp}]'
                  : 'OFFLINE - NO UPLINK',
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: TextButton.icon(
              icon: Icon(
                appState.isConnected ? Icons.settings_ethernet : Icons.wifi,
                color: Colors.redAccent,
                size: 18,
              ),
              label: Text(
                appState.isConnected ? 'MANAGE' : 'CONNECT',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
            // Sliders panel — No scrollbar, fits all 5 sliders
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // This distributes sliders perfectly
                  children: List.generate(_joints.length, (index) {
                    final joint = _joints[index];
                    return RoboticSlider(
                      id: index + 1,
                      label: _labels[index],
                      value: appState.sliderValues[joint]!.toDouble(),
                      onChanged: (v) => appState.updateSlider(joint, v.round()),
                    );
                  }),
                ),
              ),
            ),
            // Command bar
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(color: Colors.redAccent.withOpacity(0.04), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'ENTER COMMAND...',
                        prefixIcon: Icon(Icons.terminal, color: Colors.redAccent, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (v) {
                        if (v.isNotEmpty) {
                          appState.sendCommand(v.trim());
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        appState.sendCommand(_textController.text.trim());
                        _textController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Icon(Icons.send, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 32, color: Colors.redAccent.withOpacity(0.2)),
                  const SizedBox(width: 16),
                  _CompactCommandButton(
                    label: 'SET',
                    icon: Icons.check_circle_outline,
                    onPressed: () => appState.sendCommand('set'),
                  ),
                  const SizedBox(width: 8),
                  _CompactCommandButton(
                    label: 'OP1',
                    icon: Icons.person_outline,
                    onPressed: () => appState.sendCommand('user one'),
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

class _CompactCommandButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _CompactCommandButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(letterSpacing: 1, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: const Size(0, 0),
      ),
    );
  }
}
