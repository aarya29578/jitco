import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/A_Home%20and%20Drawer/JL_Drawer/JL_drawer_home.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/Js_drawer_home.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_service_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_consts.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:velocity_x/velocity_x.dart';

class JsHomeScreen extends StatefulWidget {
  const JsHomeScreen({super.key, Null Function()? onSeeAllTap});

  @override
  State<JsHomeScreen> createState() => _JsHomeScreenState();
}

List<Map<String, String>> imageList = [
  {
    "image": swipeImageService[0],
    "title": 'Everything Your Outlet Needs -',
    "subtitle": 'Beyond Products. ',
    "jitco": 'JITCO Service',
  },
  {
    "image": swipeImageService[1],
    "title": 'Everything Your Outlet Needs -',
    "subtitle": 'Beyond Products. ',
    "jitco": 'JITCO Service',
  },
];

class _JsHomeScreenState extends State<JsHomeScreen> {
  final JlHomeCategoryController controller = Get.put(
    JlHomeCategoryController(),
  );
  final ApiServices _apiService = Get.find<ApiServices>();

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    Get.put(JlCategoryController());
    _fetchIdFromWarehouse();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
    });
  }
  // ProductModel? slug;

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
    // final item = controller.categoryList[index]; // IMPORTANT LINE

    return Scaffold(
      drawer: Drawer(
        shape: Border(),
        backgroundColor: Colors.white,
        child: JsDrawerHome(),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: SizedBox(
      //     height: 40,
      //     width: 70,
      //     child: SvgPicture.asset(
      //       logo,
      //       // width: 75,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Get.to(() => JsBottomNavBar(initialIndex: 2));
      //       },
      //       icon: Icon(Icons.search, size: 25),
      //     ),
      //     10.widthBox,
      //     // IconButton(onPressed: () {
      //     // }, icon: Icon(Icons.menu, size: 30)),
      //   ],
      // ),
      body:
          // SingleChildScrollView(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       CarouselSlider(
          //         options: CarouselOptions(
          //           height: 180,
          //           enlargeCenterPage: true,
          //           aspectRatio: 20 / 9,
          //           autoPlay: true,
          //           // viewportFraction: 0.85,
          //           autoPlayInterval: Duration(seconds: 2),
          //         ),
          //         items: imageList.map((item) {
          //           return SizedBox(
          //             height: 200,
          //             width: double.infinity,
          //             child: Stack(
          //               fit: StackFit.expand,
          //               children: [
          //                 ClipRRect(
          //                   borderRadius: BorderRadius.circular(15),
          //                   child: Image.asset(
          //                     item['image']!,
          //                     width: double.infinity,
          //                     fit: BoxFit.cover,
          //                   ),
          //                 ),
          //                 Container(
          //                   height: 400,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                 ),
          //                 Positioned(
          //                   bottom: 15,
          //                   left: 15,
          //                   child: Container(
          //                     decoration: BoxDecoration(
          //                       color: Colors.grey[600],
          //                       borderRadius: BorderRadius.circular(10),
          //                     ),
          //                     child: Padding(
          //                       padding: const EdgeInsets.symmetric(horizontal: 5),
          //                       child: Column(
          //                         mainAxisAlignment: MainAxisAlignment.start,
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Text(
          //                             item['title']!,
          //                             style: TextStyle(
          //                               color: Colors.white,
          //                               fontSize: 13,
          //                               fontWeight: FontWeight.bold,
          //                             ),
          //                           ),
          //                           Row(
          //                             children: [
          //                               Text(
          //                                 item['subtitle']!,
          //                                 style: TextStyle(
          //                                   color: Colors.white,
          //                                   fontSize: 13,
          //                                   fontWeight: FontWeight.bold,
          //                                 ),
          //                               ),
          //                               Text(
          //                                 item['jitco']!,
          //                                 style: TextStyle(
          //                                   color: Colors.orange.shade700,
          //                                   fontWeight: FontWeight.bold,
          //                                   fontSize: 15,
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         }).toList(),
          //       ),
          //       SizedBox(height: 30),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 10),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               "Our Services",
          //               style: TextStyle(fontSize: 20, color: Colors.black),
          //             ),
          //           ],
          //         ),
          //       ),
          //       SizedBox(
          //         height: 400,
          //         child: Obx(() {
          //           if (controller.isLoading.value) {
          //             return const Center(child: CircularProgressIndicator());
          //           }
          //           final list = controller.liqourList;
          //           if (list.isEmpty) {
          //             return const Center(
          //               child: Text(
          //                 "No services available",
          //                 style: TextStyle(fontSize: 16, color: Colors.grey),
          //               ),
          //             );
          //           }
          //           return GridView.builder(
          //             physics: const NeverScrollableScrollPhysics(),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 10,
          //               vertical: 10,
          //             ),
          //             itemCount: list.length, // ← dynamic & correct
          //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //               crossAxisCount: 2,
          //               crossAxisSpacing: 10,
          //               mainAxisSpacing: 10,
          //               childAspectRatio: 0.99,
          //             ),
          //             itemBuilder: (context, index) {
          //               final item = list[index]; // safe now
          //               return GestureDetector(
          //                 onTap: () {
          //                   debugPrint("CATEGORY SLUG 👉 ${item.slug}");
          //                   Get.to(
          //                     () => liqdetail(slug: item.slug, id: item.id),
          //                     arguments: {"categorySlug": item.slug},
          //                   );
          //                 },
          //                 child: Card(
          //                   color: Colors.grey.shade100,
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                   child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Expanded(
          //                           child: ClipRRect(
          //                             borderRadius: const BorderRadius.vertical(
          //                               top: Radius.circular(10),
          //                               bottom: Radius.circular(10),
          //                             ),
          //                             child: Image.network(
          //                               item.image.isNotEmpty ? item.image : "",
          //                               height: 120,
          //                               width: double.infinity,
          //                               // fit: BoxFit.fitHeight,
          //                               loadingBuilder:
          //                                   (context, child, loadingProgress) {
          //                                     if (loadingProgress == null)
          //                                       return child;
          //                                     return const Center(
          //                                       child: CircularProgressIndicator(
          //                                         strokeWidth: 2,
          //                                       ),
          //                                     );
          //                                   },
          //                               errorBuilder: (context, error, stackTrace) {
          //                                 return const Center(
          //                                   child: Icon(
          //                                     Icons.image_not_supported,
          //                                     size: 90,
          //                                     color: Colors.grey,
          //                                   ),
          //                                 );
          //                               },
          //                             ),
          //                           ),
          //                         ),
          //                         Padding(
          //                           padding: const EdgeInsets.all(5),
          //                           child: Column(
          //                             crossAxisAlignment: CrossAxisAlignment.start,
          //                             children: [
          //                               Center(
          //                                 child: Text(
          //                                   item.categoryName,
          //                                   maxLines: 1,
          //                                   overflow: TextOverflow.ellipsis,
          //                                   style: const TextStyle(
          //                                     fontSize: 13,
          //                                     fontWeight: FontWeight.w700,
          //                                   ),
          //                                 ),
          //                               ),
          //                               const SizedBox(height: 4),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               );
          //             },
          //           );
          //         }),
          //       ),
          //     ],
          //   ),
          // ),
          CustomScrollView(
            slivers: [
              /// Sliver AppBar (scroll-aware)
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                pinned: false,
                floating: true,
                elevation: 1,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: SizedBox(
                  height: 40,
                  width: 70,
                  child: SvgPicture.asset(logo),
                ),
                actions: [
                  JsCartBadgeIcon(
                    isActive: true,
                    activeColor: Colors.grey,
                    nonActiveColor: Colors.grey,
                  ).onTap(() {
                    // Get.to(() => BottomNavItem(initialIndex: 3));
                    // final bottomNavState = context
                    //     .findAncestorStateOfType<JsBottomNavBarState>();
                    // if (bottomNavState != null) {
                    //   bottomNavState.switchToTab(
                    //     3,
                    //   ); // Switch to Products tab (index 2)
                    // }
                    Get.find<JsBottomNavController>().switchTab(4);
                  }),
                  20.widthBox,
                  IconButton(
                    onPressed: () {
                      // JsBottomNavBar(initialIndex: 2);
                      // final bottomNavState = context
                      //     .findAncestorStateOfType<JsBottomNavBarState>();
                      // if (bottomNavState != null) {
                      //   bottomNavState.switchToTab(
                      //     2,
                      //   ); // Switch to Products tab (index 2)
                      // }
                      // Get.find<JsBottomNavController>().switchTab(3);
                      Get.find<JsBottomNavController>().openProductSearch();
                    },
                    icon: const Icon(Icons.search, size: 25),
                  ),
                  10.widthBox,
                ],
              ),

              /// 🔹 App spacing
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              /// 🔹 Carousel
              SliverToBoxAdapter(
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    aspectRatio: 20 / 9,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                  items: imageList.map((item) {
                    return Container(
                      // padding: const EdgeInsets.symmetric(horizontal: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item['subtitle']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        item['jitco']!,
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 27)),

              /// 🔹 Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "Our Services",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              /// 🔹 Grid (IMPORTANT PART)
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.liqourList.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No services available")),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = controller.liqourList[index];

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => JsServiceScreen(
                              title: "Our Services",
                              categorySlug: item.slug,
                              categoryId: item.id,
                              slug: true,
                              warehouseId: _warehouseId,
                            ),
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
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.image,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Text(
                                  item.categoryName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: controller.liqourList.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                          childAspectRatio: 0.99,
                        ),
                  ),
                );
              }),
            ],
          ),
    );
  }
}
