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
        toolbarHeight: 50,
        title: Row(
          children: [
            _ConnectionStatusIndicator(isConnected: appState.isConnected),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appState.isConnected
                    ? 'UPLINK: ${appState.deviceType.toUpperCase()} [${appState.targetIp}]'
                    : 'OFFLINE - NO UPLINK',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              appState.isConnected ? Icons.settings_ethernet : Icons.wifi,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content Area for Sliders
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    // Grid for first 4 sliders (2x2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.6, // Adjust based on phone width
                      children: List.generate(4, (index) {
                        final joint = _joints[index];
                        return RoboticSlider(
                          id: index + 1,
                          label: _labels[index],
                          value: appState.sliderValues[joint]!.toDouble(),
                          onChanged: (v) => appState.updateSlider(joint, v.round()),
                        );
                      }),
                    ),
                    // 5th slider (Full width below)
                    RoboticSlider(
                      id: 5,
                      label: _labels[4],
                      value: appState.sliderValues[_joints[4]]!.toDouble(),
                      onChanged: (v) => appState.updateSlider(_joints[4], v.round()),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            
            // Fixed Bottom Command Bar
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Colors.redAccent.withOpacity(0.2))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'COMMAND...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                      IconButton.filled(
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            appState.sendCommand(_textController.text.trim());
                            _textController.clear();
                          }
                        },
                        icon: const Icon(Icons.send, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickButton(
                        label: 'SET',
                        icon: Icons.check_circle_outline,
                        onPressed: () => appState.sendCommand('set'),
                      ),
                      _QuickButton(
                        label: 'USER ONE',
                        icon: Icons.person_outline,
                        onPressed: () => appState.sendCommand('user one'),
                      ),
                    ],
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

class _ConnectionStatusIndicator extends StatelessWidget {
  final bool isConnected;
  const _ConnectionStatusIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isConnected ? Colors.greenAccent : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isConnected ? Colors.greenAccent : Colors.red,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 14),
          label: Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            minimumSize: const Size(0, 0),
          ),
        ),
      ),
    );
  }
}
