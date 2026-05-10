import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class RoboticSlider extends StatefulWidget {
  final int id;
  final String label;

  const RoboticSlider({
    super.key,
    required this.id,
    required this.label,
  });

  @override
  State<RoboticSlider> createState() => _RoboticSliderState();
}

class _RoboticSliderState extends State<RoboticSlider> {
  double _currentValue = 0;
  Timer? _debounce;

  void _onChanged(double value) {
    setState(() {
      _currentValue = value;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      context.read<AppState>().sendSliderValue(widget.id, value.round());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 12,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 18),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
                value: _currentValue,
                min: -90,
                max: 90,
                divisions: 180,
                onChanged: _onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0000),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.redAccent),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            '${_currentValue.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
