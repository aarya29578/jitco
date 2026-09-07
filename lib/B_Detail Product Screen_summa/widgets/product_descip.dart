import 'package:flutter/material.dart';

class ProductDescip extends StatefulWidget {
  const ProductDescip({super.key});

  @override
  State<ProductDescip> createState() => _ProductDescipState();
}

class _ProductDescipState extends State<ProductDescip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(children: []),
      ),
    );
  }
}
