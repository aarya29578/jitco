import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/JM_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/jitco_menu_nav_bar.dart';
import 'package:velocity_x/velocity_x.dart';

class JmOrderConfirmScreen extends StatelessWidget {
  const JmOrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              // Get.offAll(() => JitcoMenuNavBar());
              Get.find<JmBottomNavController>().switchTab(1);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = Navigator.of(context);

                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                });
              });
            },
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 100, color: Colors.green),
                30.heightBox,
                "Order Placed Successfully!".text
                    .size(26)
                    .fontWeight(FontWeight.bold)
                    .make(),
                13.heightBox,
                "Your order has been placed successfully."
                    .text
                    .size(15)
                    .color(Colors.grey[700])
                    .align(TextAlign.center)
                    .make(),
                40.heightBox,
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Get.offAll(() => JitcoMenuNavBar());
                      Get.find<JmBottomNavController>().switchTab(1);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final navigator = Navigator.of(context);

                          if (navigator.canPop()) {
                            navigator.pop();
                          }
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange.shade700,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Continue Shopping"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
