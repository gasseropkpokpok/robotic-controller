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
        toolbarHeight: 40, // Shorter AppBar
        title: Row(
          children: [
            _ConnectionStatusIndicator(isConnected: appState.isConnected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appState.isConnected
                    ? 'UPLINK: ${appState.deviceType.toUpperCase()} [${appState.targetIp}]'
                    : 'OFFLINE',
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
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
              size: 18,
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
            // Compact Slider Area
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(), // Snappier scrolling if needed
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    // Grid for first 4 sliders - flatter aspect ratio
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2, // Much flatter to save vertical space
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
                    // 5th slider
                    RoboticSlider(
                      id: 5,
                      label: _labels[4],
                      value: appState.sliderValues[_joints[4]]!.toDouble(),
                      onChanged: (v) => appState.updateSlider(_joints[4], v.round()),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ultra-Compact Bottom Command Bar
            Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Colors.redAccent.withOpacity(0.15))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 36, // Fixed height for input
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'CMD...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            ),
                            onSubmitted: (v) {
                              if (v.isNotEmpty) {
                                appState.sendCommand(v.trim());
                                _textController.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 40,
                        height: 36,
                        child: IconButton.filled(
                          onPressed: () {
                            if (_textController.text.isNotEmpty) {
                              appState.sendCommand(_textController.text.trim());
                              _textController.clear();
                            }
                          },
                          icon: const Icon(Icons.send, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _CompactQuickButton(
                        label: 'SET',
                        onPressed: () => appState.sendCommand('set'),
                      ),
                      const SizedBox(width: 6),
                      _CompactQuickButton(
                        label: 'USER ONE',
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isConnected ? Colors.greenAccent : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CompactQuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CompactQuickButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 0.5)),
      ),
    );
  }
}
