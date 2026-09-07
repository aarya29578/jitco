import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String? summary;
  const TextWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Text(
      summary!,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
