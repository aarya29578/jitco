import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';

import 'package:velocity_x/velocity_x.dart';
import '../../../B_controllers/PerishablesController.dart';

class HomeProducts extends StatelessWidget {
  const HomeProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PerishablesController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Column());
      }

      if (controller.categoryMap.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Text("No items found"),
        );
      }

      return Column(
        children: controller.categoryMap.entries.map((entry) {
          String categoryName = entry.key;
          List<PerishItem> products = entry.value;

          if (products.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: SizedBox(
                  height: 220,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];

                      return InkWell(
                        onTap: () {
                          print(item.slug);
                          print(item.name);

                          Get.to(
                            () => UniversalProductScreen(
                              categorySlug: item.categorySlug ?? "",
                              categoryName: item.name ?? "Products",
                            ),
                            transition: Transition.rightToLeft,
                          );
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (_) => UniversalProductScreen(
                          //       categorySlug: item.categorySlug ?? "",
                          //       categoryName: item.name ?? "Products",
                          //     ),
                          //   ),
                          // );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              10.heightBox,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child:
                                    (item.image != null &&
                                        item.image!.isNotEmpty)
                                    ? Image.network(
                                        item.image!,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.image_not_supported, size: 20),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                ),
                                child: Text(
                                  item.name ?? 'No name',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      );
    });
  }
}
