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
      margin: const EdgeInsets.all(1), // Absolute minimum margin
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 0), // Tightened padding
      decoration: BoxDecoration(
        color: const Color(0xFF0A0000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
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
                  letterSpacing: 0.5,
                  fontFamily: 'Courier',
                  fontSize: 10,
                ),
              ),
              Text(
                '${value.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          // Compact Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3, // Thinner track
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), // Smaller thumb
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.redAccent,
              inactiveTrackColor: Colors.red.withOpacity(0.1),
              thumbColor: Colors.white,
              // Tighten the slider's internal vertical space
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: SizedBox(
              height: 28, // Fix height to minimize vertical space
              child: Slider(
                value: value,
                min: -90,
                max: 90,
                divisions: 180,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
