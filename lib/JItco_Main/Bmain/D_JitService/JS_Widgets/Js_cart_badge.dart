// widgets/cart_badge.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';

class JsCartBadgeIcon extends StatelessWidget {
  final bool isActive;
  final double? iconSize;
  final Color? activeColor;
  final Color? nonActiveColor;

  const JsCartBadgeIcon({
    super.key,
    required this.isActive,
    this.iconSize,
    this.activeColor,
    this.nonActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<JsCartcontroller>(
      init: Get.find<JsCartcontroller>(),
      builder: (cartController) {
        // Calculate total products efficiently
        final totalProducts = cartController.totalNumberOfProducts;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              // color: isActive ? Colors.deepOrangeAccent : Colors.grey,
              color: isActive ? activeColor : nonActiveColor,
              size: iconSize,
            ),
            if (totalProducts > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalProducts > 99 ? '99+' : totalProducts.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: totalProducts > 9 ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
