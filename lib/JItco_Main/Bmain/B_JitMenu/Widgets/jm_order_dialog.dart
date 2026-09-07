import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showOrderDialog(BuildContext context, VoidCallback tap) {
  if (Platform.isIOS) {
    // iOS Cupertino Dialog
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Order"),
        content: Text("Are you sure you want to order this product?"),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => Get.back(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text("Yes"),
            onPressed: () {
              // Get.back();
              tap();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                });
              });
            },
          ),
        ],
      ),
    );
  } else {
    // Android Material Dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Order", style: TextStyle(fontWeight: FontWeight.w500)),
        content: Text("Are you sure you want to order this product?"),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.black54)),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: Text("Yes", style: TextStyle(color: Colors.orange)),
            onPressed: () {
              // Get.back();
              tap();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = Navigator.of(context);
                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
