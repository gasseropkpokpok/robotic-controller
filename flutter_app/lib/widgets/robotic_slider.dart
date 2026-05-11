import 'package:flutter/material.dart';

class RoboticSlider extends StatefulWidget {
  final int id;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const RoboticSlider({
    super.key,
    required this.id,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RoboticSlider> createState() => _RoboticSliderState();
}

class _RoboticSliderState extends State<RoboticSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: Colors.redAccent.withOpacity(0.07), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 90,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Courier',
                fontSize: 13,
              ),
            ),
          ),
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
                activeTrackColor: Colors.redAccent,
                inactiveTrackColor: Colors.red.withOpacity(0.2),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: widget.value,
                min: -90,
                max: 90,
                divisions: 180,
                onChanged: widget.onChanged,
              ),
            ),
          ),
          // Value display
          Container(
            width: 64,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0000),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '${widget.value.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
