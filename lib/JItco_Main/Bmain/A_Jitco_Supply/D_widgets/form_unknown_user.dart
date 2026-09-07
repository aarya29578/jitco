import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class FormUnknownUser extends StatelessWidget {
  final String formTitle;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const FormUnknownUser({
    super.key,
    required this.formTitle,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          10.heightBox,
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.deepOrangeAccent,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
