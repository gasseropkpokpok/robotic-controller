import 'package:flutter/material.dart';

class RoboticSlider extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0000),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Courier',
                  fontSize: 11,
                ),
              ),
              Text(
                '${value.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.redAccent,
              inactiveTrackColor: Colors.red.withOpacity(0.1),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: value,
              min: -90,
              max: 90,
              divisions: 180,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
