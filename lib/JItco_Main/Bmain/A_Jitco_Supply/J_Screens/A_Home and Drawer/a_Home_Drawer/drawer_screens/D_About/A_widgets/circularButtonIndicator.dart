import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressCircle extends StatelessWidget {
  final int percentage;
  final double percentageReal;

  const ProgressCircle({
    super.key,
    required this.percentage,
    required this.percentageReal,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 12.0,
          percent: percentageReal, // 90%
          progressColor: Colors.orange,
          backgroundColor: Colors.orange.shade100,
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            "$percentage %",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}
