import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/liquor/JL_app_gradient.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_service_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class JsCategoryScreen extends StatefulWidget {
  const JsCategoryScreen({super.key});

  @override
  State<JsCategoryScreen> createState() => _JsCategoryScreenState();
}

class _JsCategoryScreenState extends State<JsCategoryScreen> {
  final JlCategoryController controller = Get.put(JlCategoryController());
  final ApiServices _apiService = Get.find<ApiServices>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchIdFromWarehouse();
  }

  @override
  void dispose() {
    // scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchIdFromWarehouse() async {
    try {
      print('START: _fetchIdFromWarehouse() called');

      // 1. Fetch outlets
      print('Fetching user outlets...');
      final outletResponse = await _apiService.getUserOutlet();

      if (outletResponse['success'] == true && outletResponse['data'] is List) {
        final outlets = outletResponse['data'] as List;

        if (outlets.isEmpty) {
          print('No outlets found for user');
          return;
        }

        // 2. Convert first outlet to OutletModel
        print('Creating OutletModel from first outlet...');
        final outlet = OutletModel.fromJson(outlets[0]);

        // 3. Get city name directly from OutletModel
        final cityName = outlet.cityName;
        print('City name from OutletModel: "$cityName"');

        if (cityName == null || cityName.isEmpty) {
          print('City name is null or empty in OutletModel');
          return;
        }

        // 4. Call warehouse API with city name
        print('Calling warehouse API with city: "$cityName"...');
        final result = await _apiService.getWarehouseIdByCity(
          page: 1,
          limit: 1,
          encodedCity: cityName,
        );

        // 5. Process warehouse response - FIXED HERE
        print('Warehouse API response: ${result}');

        if (result['data'] != null) {
          // Check if data is a List or a single object
          if (result['data'] is List) {
            final warehouseList = result['data'] as List;

            if (warehouseList.isNotEmpty) {
              print('Warehouse data found in list!');
              final warehouseData = warehouseList[0];
              final warehouseId = warehouseData['_id'];

              print('Warehouse _id: $warehouseId');

              // Store the warehouse ID
              setState(() {
                _warehouseId = warehouseId;
                cityWarehouse = OutletModel.fromJson(warehouseData);
              });

              print('Warehouse model created with ID: ${cityWarehouse!.id}');
            } else {
              print('No warehouses found for city: $cityName');
            }
          }
          // Handle if data is a single object (not a list)
          else if (result['data'] is Map) {
            print('Warehouse data found as single object!');
            final warehouseData = result['data'] as Map<String, dynamic>;
            final warehouseId = warehouseData['_id'];

            print('Warehouse _id: $warehouseId');

            // Store the warehouse ID
            setState(() {
              _warehouseId = warehouseId;
              cityWarehouse = OutletModel.fromJson(warehouseData);
            });

            print('Warehouse model created with ID: ${cityWarehouse!.id}');
          } else {
            print(
              'Invalid warehouse data format: ${result['data'].runtimeType}',
            );
          }
        } else {
          print('No data in warehouse response');
        }
      } else {
        print('Failed to fetch outlets: ${outletResponse['message']}');
      }
    } catch (e) {
      print('Error in _fetchIdFromWarehouse: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      print('END: _fetchIdFromWarehouse() completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(
      context,
    ).extension<JlAppGradient>()?.primaryGradient;

    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      body: Container(
        // decoration: BoxDecoration(gradient: gradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SafeArea(
              child: Center(
                child: Text(
                  "Explore Our Categories",
                  // style: GoogleFonts.merienda(
                  //   fontSize: 20,
                  //   color: Colors.white,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         contentPadding: const EdgeInsets.symmetric(vertical: 0),
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(10),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Colors.black12,
            //           blurRadius: 4,
            //           offset: Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: TextField(
            //       controller: _searchController,
            //       focusNode: _searchFocus,
            //       decoration: const InputDecoration(
            //         hintText: "Search categories...",
            //         prefixIcon: Icon(Icons.search, color: Colors.orange),
            //         border: InputBorder.none,
            //         contentPadding: EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 15,
            //         ),
            //       ),
            //       onChanged: (value) => controller.searchQuery.value = value,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Obx(
                () => TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: "Search categories...",
                    hintStyle: const TextStyle(color: Colors.grey),

                    prefixIcon: const Icon(Icons.search, color: Colors.orange),

                    /// CANCEL BUTTON
                    suffixIcon: controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              controller.searchQuery.value = "";
                              _searchFocus.unfocus();
                            },
                          )
                        : null,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none, // modern clean look
                    ),
                  ),

                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.liqourList;

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "No categories available",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  itemCount: list.length, // ← dynamic & correct
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.99,
                  ),
                  itemBuilder: (context, index) {
                    final item = list[index]; // safe now

                    return GestureDetector(
                      onTap: () {
                        debugPrint("CATEGORY SLUG  ${item.slug}");
                        Get.to(
                          () => JsServiceScreen(
                            title: "Our Services",
                            categorySlug: item.slug,
                            categoryId: item.id,
                            slug: true,
                            warehouseId: _warehouseId,
                          ),
                          arguments: {"categorySlug": item.slug},
                          transition: Transition.rightToLeft,
                        );
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => JsServiceScreen(
                        //       title: "Our Services",
                        //       categorySlug: item.slug,
                        //       categoryId: item.id,
                        //       slug: true,
                        //       warehouseId: _warehouseId,
                        //     ),
                        //   ),
                        // );

                        ///NAVIGATOR ANIMATION- WORKING
                        // Navigator.of(context).push(
                        //   PageRouteBuilder(
                        //     pageBuilder: (_, animation, __) => JsServiceScreen(
                        //       title: item.categoryName,
                        //       categorySlug: item.slug,
                        //       categoryId: item.id,
                        //       slug: true,
                        //       warehouseId: _warehouseId,
                        //     ),
                        //     transitionsBuilder: (_, animation, __, child) {
                        //       final offsetAnimation = Tween(
                        //         begin: const Offset(1.0, 0.0), // Right → Left
                        //         end: Offset.zero,
                        //       ).animate(animation);
                        //       return SlideTransition(
                        //         position: offsetAnimation,
                        //         child: child,
                        //       );
                        //     },
                        //   ),
                        // );
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                    bottom: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    item.image.isNotEmpty ? item.image : "",
                                    height: 100,
                                    width: 100,
                                    // fit: BoxFit.fitHeight,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 90,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // 10.heightBox,
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        item.categoryName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // const SizedBox(height: 4),
                                  ],
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
