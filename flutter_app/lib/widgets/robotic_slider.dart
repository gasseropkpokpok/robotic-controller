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
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0000),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.15),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
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
                  fontFamily: 'Courier',
                  fontSize: 9,
                  height: 1,
                ),
              ),
              Text(
                '${value.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  fontSize: 9,
                  height: 1,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeTrackColor: Colors.redAccent,
              inactiveTrackColor: Colors.red.withOpacity(0.1),
              thumbColor: Colors.white,
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: SizedBox(
              height: 18,
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
