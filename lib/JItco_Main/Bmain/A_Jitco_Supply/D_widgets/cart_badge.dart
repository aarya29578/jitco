// widgets/cart_badge.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';

class CartBadgeIcon extends StatelessWidget {
  final bool isActive;
  final double? iconSize;
  final Color? activeColor;
  final Color? nonActiveColor;

  const CartBadgeIcon({
    super.key,
    required this.isActive,
    this.iconSize,
    this.activeColor,
    this.nonActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GetX<CartController>(
      init: Get.find<CartController>(),
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
