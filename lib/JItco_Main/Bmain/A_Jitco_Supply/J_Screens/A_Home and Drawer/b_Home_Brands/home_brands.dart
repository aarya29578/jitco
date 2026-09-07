import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/brand_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart'; // Import the UniversalProductScreen
import 'package:velocity_x/velocity_x.dart';

class HomeBrands extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  HomeBrands({super.key, this.onSeeAllTap});

  final brandController = Get.put(BrandController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (brandController.isLoading.value) {
        return Center(child: Column());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Shop by Brands',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Spacer(),
                // Text(
                //   'See All',
                //   style: TextStyle(color: Colors.blue),
                // ).onTap(onSeeAllTap),
              ],
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brandController.brandList.length,
              itemBuilder: (context, index) {
                final item = brandController.brandList[index];

                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => UniversalProductScreen(
                        // id: item.id,
                        brandSlug: item.slug ?? "",
                        brandName: item.name ?? "Brand Products",
                        isBrandScreen:
                            true, // Important: This tells it's a brand screen
                      ),
                      transition: Transition.rightToLeft,
                    );
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => UniversalProductScreen(
                    //       brandSlug: item.slug ?? "",
                    //       brandName: item.name ?? "Brand Products",
                    //       isBrandScreen: true,
                    //     ),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: 90,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 120,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.image != null && item.image!.isNotEmpty
                                ? Image.network(item.image!, fit: BoxFit.cover)
                                : Icon(Icons.image_not_supported, size: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 90,
                          height: 32,
                          child: AutoSizeText(
                            item.name ?? "",
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
