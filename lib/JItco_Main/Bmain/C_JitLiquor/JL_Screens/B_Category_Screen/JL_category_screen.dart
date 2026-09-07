import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/B_Category_Screen/try_shimmer_category.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/liquor/JL_app_gradient.dart';

class JlCategoryScreen extends StatefulWidget {
  const JlCategoryScreen({super.key});

  @override
  State<JlCategoryScreen> createState() => _JlCategoryScreenState();
}

class _JlCategoryScreenState extends State<JlCategoryScreen> {
  final categoryliqfetch prodController = Get.put(categoryliqfetch());
  final JLCategoryController _jlCategoryController = Get.put(JLCategoryController());
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        _jlCategoryController.loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(
      context,
    ).extension<JlAppGradient>()?.primaryGradient;

    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Text(
                "Explore Our Categories",
                // style: GoogleFonts.merienda(
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: Container(
            //     // height: 50,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: TextField(
            //       onChanged: (value) => controller.searchQuery.value = value,
            //       decoration: InputDecoration(
            //         hintText: "Search products...",
            //         prefixIcon: const Icon(Icons.search, color: Colors.orange),
            //         // border: OutlineInputBorder(
            //         //   borderRadius: BorderRadius.circular(10),
            //         // ),
            //         border: InputBorder.none,
            //         contentPadding: const EdgeInsets.symmetric(vertical: 0),
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                // child: TextField(
                //   controller: _searchController,
                //   focusNode: _searchFocus,
                //   decoration: const InputDecoration(
                //     hintText: "Search categories...",
                //     prefixIcon: Icon(Icons.search, color: Colors.orange),
                //     border: InputBorder.none,
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 15,
                //     ),
                //   ),
                //   onChanged: (value) => controller.searchQuery.value = value,
                // ),
                child: Obx(
                  () => TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: "Search categories...",
                      // hintText: "Search liquor...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.orange,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),

                      ///CANCEL / CLEAR BUTTON
                      suffixIcon: _jlCategoryController.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _jlCategoryController.searchQuery.value =
                                    ""; // triggers rebuild
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => _jlCategoryController.searchQuery.value = value,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_jlCategoryController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                ///TRY SHIMMER IN THIS
                // if (controller.isLoading.value) {
                //   return GridView.builder(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 8,
                //     ),
                //     gridDelegate:
                //         const SliverGridDelegateWithFixedCrossAxisCount(
                //           crossAxisCount: 2,
                //           crossAxisSpacing: 8,
                //           mainAxisSpacing: 8,
                //           childAspectRatio: 1.1,
                //         ),
                //     itemCount: 6, // number of skeleton items
                //     itemBuilder: (_, __) => const CategorySkeletonItem(),
                //   );
                // }
                if (_jlCategoryController.liqourList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Categories found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  // itemCount: controller.filteredList.length,
                  // itemCount: controller.liqourList.length,
                  itemCount:
                      _jlCategoryController.liqourList.length +
                      (_jlCategoryController.isLoadingMore.value ? 1 : 0),

                  ///TRY SHIMMER IN THIS
                  // itemCount:
                  //     controller.liqourList.length +
                  //     (controller.isLoadingMore.value ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _jlCategoryController.liqourList.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    final item = _jlCategoryController.liqourList[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => JlProductScreen(
                            title: _jlCategoryController.liqourList[index].name,
                            categorySlugs: _jlCategoryController.liqourList[index].slug,
                            categoryId: _jlCategoryController.liqourList[index].id,
                            // id: controller.filteredList[index].id,
                          ),
                        );
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => JlProductScreen(
                        //       categorySlugs: controller.liqourList[index].slug,
                        //       categoryId: controller.liqourList[index].id,
                        //     ),
                        //   ),
                        // );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 5,
                          right: 5,
                          left: 5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.image ?? "",
                                  height: 100,
                                  width: 100,
                                  // fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Center(
                                  child: Text(
                                    item.name ?? "No Name",
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
