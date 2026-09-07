import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDetail extends StatefulWidget {
  const RatingDetail({super.key});

  @override
  State<RatingDetail> createState() => _RatingDetailState();
}

class _RatingDetailState extends State<RatingDetail> {
  late final double displayRating;
  late final int reviews;

  @override
  void initState() {
    super.initState();

    final rating = 3.1 + Random().nextDouble() * (4.9 - 3.1);

    displayRating = double.parse(rating.toStringAsFixed(1));

    reviews = Random().nextInt(100) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: displayRating,
          itemCount: 5,
          itemSize: 20,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
        ),
        const SizedBox(width: 8),
        Text(
          "$displayRating ($reviews reviews)",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
