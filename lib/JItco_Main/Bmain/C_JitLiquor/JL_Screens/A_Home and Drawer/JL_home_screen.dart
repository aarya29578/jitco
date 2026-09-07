import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartcount.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/A_Home%20and%20Drawer/JL_Drawer/JL_drawer_home.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Widgets/JL_consts.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/liquor/JL_beer.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/liquor/JL_wines.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/grid_item.dart';
import 'package:velocity_x/velocity_x.dart';

class JlHomeScreen extends StatefulWidget {
  const JlHomeScreen({super.key, Null Function()? onSeeAllTap});

  @override
  State<JlHomeScreen> createState() => _JlHomeScreenState();
}

List<Map<String, String>> imageList = [
  {
    "image": swiperJL[0],
    "title": 'Discover, Order, and Manage Liquor -',
    "subtitle": 'Just-In-Time. ',
    "jitco": 'JITCO Liquor',
  },
  {
    "image": swiperJL[1],
    "title": 'Discover, Order, and Manage Liquor -',
    "subtitle": 'Just-In-Time. ',
    "jitco": 'JITCO Liquor',
  },
  {
    "image": swiperJL[2],
    "title": 'Discover, Order, and Manage Liquor -',
    "subtitle": 'Just-In-Time. ',
    "jitco": 'JITCO Liquor',
  },
];

class _JlHomeScreenState extends State<JlHomeScreen> {
  final LiquorController controller = Get.put(LiquorController());
  final WinesLiqFetch wines = Get.put(WinesLiqFetch());
  final beerLiqFetch beers = Get.put(beerLiqFetch());
  final ApiServices _apiService = Get.find<ApiServices>();

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    Get.put(categoryliqfetch()); // for categories / spirits
    Get.put(WinesLiqFetch()); // for wines products
    Get.put(beerLiqFetch()); // for beers products
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchIdFromWarehouse();
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
    });
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
    return Scaffold(
      drawer: Drawer(
        shape: Border(),
        backgroundColor: Colors.white,
        child: JlDrawerHome(),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: SizedBox(height: 40, width: 70, child: SvgPicture.asset(logo)),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Get.to(() => JlBottomNavBar(initialIndex: 2));
      //       },
      //       icon: Icon(Icons.search, size: 25),
      //     ),
      //     10.widthBox,
      //   ],
      // ),
      body: CustomScrollView(
        slivers: [
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
              JlCartBadgeIcon(
                isActive: true,
                activeColor: Colors.grey,
                nonActiveColor: Colors.grey,
              ).onTap(() {
                // Get.to(() => JlBottomNavBar(initialIndex: 3));
                final bottomNavState = context
                    .findAncestorStateOfType<JlBottomNavBarState>();
                if (bottomNavState != null) {
                  bottomNavState.switchToTab(
                    4,
                  ); // Switch to Products tab (index 2)
                }
              }),
              20.widthBox,
              IconButton(
                onPressed: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => JlBottomNavBar(initialIndex: 2),
                  //   ),
                  // );
                  // Get.to(() => JlBottomNavBar(initialIndex: 2));
                  // final bottomNavState = context
                  //     .findAncestorStateOfType<JlBottomNavBarState>();
                  // if (bottomNavState != null) {
                  //   bottomNavState.switchToTab(
                  //     2,
                  //   ); // Switch to Products tab (index 2)
                  // }
                  // Get.find<JlBottomNavController>().switchTab(3);
                  Get.find<JlBottomNavController>().openProductSearch();
                },
                icon: const Icon(Icons.search, size: 25),
              ),
              10.widthBox,
            ],
          ),
          // Carousel Slider Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  enlargeCenterPage: true,
                  aspectRatio: 20 / 9,
                  autoPlay: false,
                  autoPlayInterval: Duration(seconds: 3),
                ),
                items: imageList.map((item) {
                  return SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            item['image']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          left: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item['subtitle']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item['jitco']!,
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Explore Spirit's Section
          SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Spirit's",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  TextButton(
                    // onPressed: () {
                    //   Get.to(
                    //     () => JlProductScreen(
                    //       categorySlugs: "spirits",
                    //       // categoryId: item['title']!,
                    //     ),
                    //   );
                    // },
                    onPressed: () {
                      if (controller.liqourList.isEmpty) return;

                      final item = controller.liqourList.first;

                      Get.to(
                        () => JlProductScreen(
                          title: "All Spirits",
                          categorySlugs: item.categorySlug,
                          categoryId: item.categoryId,
                        ),
                      );
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => JlProductScreen(
                      //       title: "All Spirit's",
                      //       categorySlugs: item.categorySlug,
                      //       categoryId: item.categoryId,
                      //     ),
                      //   ),
                      // );
                    },

                    child: Row(
                      children: [
                        Text(
                          "See All",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                        5.widthBox,
                        Icon(
                          Icons.arrow_circle_right_outlined,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Spirit's Grid Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            sliver: _buildSpiritsGrid(),
          ),

          // Explore Wines Section
          SliverToBoxAdapter(child: SizedBox(height: 30)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Wines",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  TextButton(
                    // onPressed: () {
                    //   Get.to(() => JlProductScreen(categorySlugs: "wines"));
                    // },
                    onPressed: () {
                      if (wines.list.isEmpty) return;

                      final item = wines.list.first;

                      Get.to(
                        () => JlProductScreen(
                          title: "All Wines",
                          categorySlugs: item.categorySlug,
                          categoryId: item.categoryId,
                        ),
                      );
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => JlProductScreen(
                      //       title: "All Wines",
                      //       categorySlugs: item.categorySlug,
                      //       categoryId: item.categoryId,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Row(
                      children: [
                        Text(
                          "See All",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                        5.widthBox,
                        Icon(
                          Icons.arrow_circle_right_outlined,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SliverToBoxAdapter(child: SizedBox(height: 15)),

          // Wines Grid Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            sliver: _buildWinesGrid(),
          ),

          // Explore Beers Section
          SliverToBoxAdapter(child: SizedBox(height: 30)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Beers",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  TextButton(
                    // onPressed: () {
                    //   Get.to(() => JlProductScreen(categorySlugs: "beer"));
                    // },
                    onPressed: () {
                      if (beers.list.isEmpty) return;

                      final item = beers.list.first;

                      Get.to(
                        () => JlProductScreen(
                          title: "All Beers",
                          categorySlugs: item.categorySlug,
                          categoryId: item.categoryId,
                        ),
                      );
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => JlProductScreen(
                      //       title: "All Beers",
                      //       categorySlugs: item.categorySlug,
                      //       categoryId: item.categoryId,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Row(
                      children: [
                        Text(
                          "See All",
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                        5.widthBox,
                        Icon(
                          Icons.arrow_circle_right_outlined,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SliverToBoxAdapter(child: SizedBox(height: 5)),

          // Beers Grid Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            sliver: _buildBeersGrid(),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // Helper method to build Spirits Grid
  Widget _buildSpiritsGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (controller.filteredList.isEmpty) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: Center(child: const Text('no spirits found!')),
          ),
        );
      }

      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.99,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = controller.liqourList[index];
          return GestureDetector(
            onTap: () {
              debugPrint("CATEGORY SLUG 👉 ${item.slug}");
              Get.to(
                () => JlDetailScreen(
                  slug: item.slug,
                  id: item.id,
                  warehouseId: _warehouseId,
                ),
                arguments: {"categorySlug": item.slug},
              );
            },
            child:
                // Card(
                //   color: Colors.grey.shade100,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Expanded(
                //           child: ClipRRect(
                //             borderRadius: const BorderRadius.vertical(
                //               top: Radius.circular(10),
                //               bottom: Radius.circular(10),
                //             ),
                //             child: SizedBox(
                //               height: 110,
                //               child: Image.network(
                //                 item.productImage.isNotEmpty
                //                     ? item.productImage.first
                //                     : '',
                //                 height: 110,
                //                 width: double.infinity,
                //                 loadingBuilder: (context, child, loadingProgress) {
                //                   if (loadingProgress == null) return child;
                //                   return const Center(
                //                     child: CircularProgressIndicator(
                //                       strokeWidth: 2,
                //                     ),
                //                   );
                //                 },
                //                 errorBuilder: (context, error, stackTrace) {
                //                   return SizedBox(
                //                     height: 110,
                //                     child: Center(
                //                       child: const Icon(
                //                         Icons.image_not_supported,
                //                         size: 90,
                //                         color: Colors.grey,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.all(5),
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Center(
                //                 child: Text(
                //                   item.productName,
                //                   maxLines: 2,
                //                   overflow: TextOverflow.ellipsis,
                //                   style: const TextStyle(
                //                     fontSize: 13,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //               ),
                //               const SizedBox(height: 4),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Card(
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
                            item.productImage.first,
                            width: double.infinity,
                            // fit: BoxFit.cover,
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
                          item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        }, childCount: min(4, controller.liqourList.length)),
      );
    });
  }

  // Helper method to build Wines Grid
  Widget _buildWinesGrid() {
    return Obx(() {
      if (wines.isLoading.value) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (wines.list.isEmpty) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: Center(child: const Text("no wines found!")),
          ),
        );
      }

      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.99,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = wines.list[index];
          return GestureDetector(
            onTap: () {
              debugPrint("CATEGORY SLUG 👉 ${item.slug}");
              // Get.to(
              //   () => Winesdetail(slug: item.slug, id: item.id),
              //   arguments: {"categorySlug": item.slug},
              // );
              Get.to(
                () => JlDetailScreen(
                  slug: item.slug,
                  id: item.id,
                  warehouseId: _warehouseId,
                ),
                arguments: {"categorySlug": item.slug},
              );
            },
            child:
                // Card(
                //   color: Colors.grey.shade100,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Expanded(
                //           child: ClipRRect(
                //             borderRadius: const BorderRadius.vertical(
                //               top: Radius.circular(10),
                //               bottom: Radius.circular(10),
                //             ),
                //             child: SizedBox(
                //               height: 110,
                //               child: Image.network(
                //                 item.productImage.isNotEmpty
                //                     ? item.productImage.first
                //                     : '',
                //                 height: 110,
                //                 width: double.infinity,
                //                 loadingBuilder: (context, child, loadingProgress) {
                //                   if (loadingProgress == null) return child;
                //                   return const Center(
                //                     child: CircularProgressIndicator(
                //                       strokeWidth: 2,
                //                     ),
                //                   );
                //                 },
                //                 errorBuilder: (context, error, stackTrace) {
                //                   return SizedBox(
                //                     height: 110,
                //                     child: Center(
                //                       child: const Icon(
                //                         Icons.image_not_supported,
                //                         size: 90,
                //                         color: Colors.grey,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.all(5),
                //           child: Column(
                //             children: [
                //               Center(
                //                 child: Text(
                //                   item.productName,
                //                   maxLines: 2,
                //                   overflow: TextOverflow.ellipsis,
                //                   style: const TextStyle(
                //                     fontSize: 13,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //               ),
                //               const SizedBox(height: 4),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Card(
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
                            item.productImage.first,
                            width: double.infinity,
                            // fit: BoxFit.cover,
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
                          item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        }, childCount: min(2, wines.list.length)),
      );
    });
  }

  // Helper method to build Beers Grid
  Widget _buildBeersGrid() {
    return Obx(() {
      if (beers.isLoading.value) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }

      if (beers.list.isEmpty) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: Center(child: const Text("no Beers found!")),
          ),
        );
      }

      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.99,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = beers.list[index];
          return GestureDetector(
            onTap: () {
              debugPrint("CATEGORY SLUG 👉 ${item.slug}");
              // Get.to(
              //   () => beerdetails(slug: item.slug, id: item.id),
              //   arguments: {"categorySlug": item.slug},
              // );
              Get.to(
                () => JlDetailScreen(
                  slug: item.slug,
                  id: item.id,
                  warehouseId: _warehouseId,
                ),
                arguments: {"categorySlug": item.slug},
              );
            },
            child:
                // Card(
                //   color: Colors.grey.shade100,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Container(
                //     padding: const EdgeInsets.all(8),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Expanded(
                //           child: ClipRRect(
                //             borderRadius: const BorderRadius.vertical(
                //               top: Radius.circular(10),
                //               bottom: Radius.circular(10),
                //             ),
                //             child: SizedBox(
                //               height: 110,
                //               child: Image.network(
                //                 item.productImage.isNotEmpty
                //                     ? item.productImage.first
                //                     : '',
                //                 height: 110,
                //                 width: double.infinity,
                //                 loadingBuilder: (context, child, loadingProgress) {
                //                   if (loadingProgress == null) return child;
                //                   return const Center(
                //                     child: CircularProgressIndicator(
                //                       strokeWidth: 2,
                //                     ),
                //                   );
                //                 },
                //                 errorBuilder: (context, error, stackTrace) {
                //                   return SizedBox(
                //                     height: 110,
                //                     child: Center(
                //                       child: const Icon(
                //                         Icons.image_not_supported,
                //                         size: 90,
                //                         color: Colors.grey,
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.all(5),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Center(
                //                 child: Text(
                //                   item.productName,
                //                   maxLines: 2,
                //                   overflow: TextOverflow.ellipsis,
                //                   style: const TextStyle(
                //                     fontSize: 13,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //               ),
                //               const SizedBox(height: 4),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Card(
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
                            item.productImage.first,
                            width: double.infinity,
                            // fit: BoxFit.cover,
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
                          item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        }, childCount: min(3, beers.list.length)),
      );
    });
  }
}
