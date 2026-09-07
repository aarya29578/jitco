import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/JM_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_home_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/b_JM_Category/jm_category_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/jm_drawer.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/c_JM_Product_Screen/jm_all_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Widgets/jm_cart_badge_icon.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/jitco_menu_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart'
    hide CategoryController;
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:velocity_x/velocity_x.dart';

class JMHomeScreen extends StatefulWidget {
  const JMHomeScreen({super.key, Null Function()? onSeeAllTap});

  @override
  State<JMHomeScreen> createState() => _JMHomeScreenState();
}

List<Map<String, String>> imageList = [
  {
    "image": 'assets/JM_assets/Images/JMswipe1.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe2.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe3.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe4.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe5.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe6.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
  {
    "image": 'assets/JM_assets/Images/JMswipe7.webp',
    "title": 'Unique experience and Flavours',
    "subtitle": 'all under one name-',
    "jitco": 'JITCO',
  },
];

class _JMHomeScreenState extends State<JMHomeScreen> {
  final JmHomeCategoryController controller =
      Get.find<JmHomeCategoryController>();
  final ScrollController _scrollController = ScrollController();
  final ApiServices apiServices = Get.find<ApiServices>();
  bool _isLoadingMore = false;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Fetch initial data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchIdFromWarehouse();
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      // if (controller.categoryList.isEmpty && !controller.isLoading.value) {
      //   controller.fetchCategories(page: 1, limit: 20);
      // }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If we're at the bottom, not loading, and have more items
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        !controller.isLoading.value &&
        controller.hasMore.value) {
      _loadMoreCategories();
    }
  }

  Future<void> _loadMoreCategories() async {
    if (_isLoadingMore || controller.isLoading.value) return;

    setState(() {
      _isLoadingMore = true;
    });

    await controller.loadMore();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshCategories() async {
    await controller.refresh();
  }

  Future<void> _fetchIdFromWarehouse() async {
    try {
      print('START: _fetchIdFromWarehouse() called');

      // 1. Fetch outlets
      print('Fetching user outlets...');
      final outletResponse = await apiServices.getUserOutlet();

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
        final result = await apiServices.getWarehouseIdByCity(
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
      // backgroundColor: Colors.grey[200],
      drawer: Drawer(
        shape: Border(),
        backgroundColor: Colors.white,
        child: JMDrawer(),
      ),
      // backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            floating: true,
            pinned: false,
            snap: false,
            expandedHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.white),
            ),
            title: SizedBox(
              width: 75,
              child: SvgPicture.asset('assets/logo.svg'),
            ),
            actions: [
              JmCartBadgeIcon(
                isActive: true,
                activeColor: Colors.grey,
                nonActiveColor: Colors.grey,
              ).onTap(() {
                // Get.to(() => BottomNavItem(initialIndex: 3));
                // final bottomNavState = context
                //     .findAncestorStateOfType<JitcoMenuNavBarState>();
                // if (bottomNavState != null) {
                //   bottomNavState.switchToTab(
                //     3,
                //   ); // Switch to Products tab (index 2)
                // }
                Get.find<JmBottomNavController>().switchTab(4);
              }),
              20.widthBox,
              IconButton(
                onPressed: () {
                  // final bottomNavState = context
                  //     .findAncestorStateOfType<JitcoMenuNavBarState>();
                  // if (bottomNavState != null) {
                  //   bottomNavState.switchToTab(2);
                  // }
                  // Get.find<JmBottomNavController>().switchTab(3);
                  Get.find<JmBottomNavController>().openProductSearch();
                },
                icon: Icon(Icons.search, size: 23),
              ),
              7.widthBox,
            ],
          ),

          // Carousel Slider Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                17.heightBox,
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 20 / 9,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    height: 180,
                    enlargeCenterPage: true,
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
                SizedBox(height: 40),
              ],
            ),
          ),

          // Categories Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(right: 17, left: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Categories",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "See All",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      5.widthBox,
                      Icon(
                        Icons.arrow_circle_right_outlined,
                        // Icons.arrow_forward_ios_rounded,
                        color: Colors.orange.shade700,
                        size: 18,
                      ),
                    ],
                  ).onTap(() {
                    // final bottomNavState = context
                    //     .findAncestorStateOfType<JitcoMenuNavBarState>();
                    // if (bottomNavState != null) {
                    //   bottomNavState.switchToTab(1);
                    // }
                    Get.find<JmBottomNavController>().switchTab(2);
                  }),
                  // TextButton(
                  //   onPressed: () {},
                  //   child: Row(
                  //     children: [
                  //       const Text(
                  //         "See All",
                  //         style: TextStyle(
                  //           fontSize: 15,
                  //           color: Colors.orange,
                  //           // fontWeight: FontWeight.w400,
                  //         ),
                  //       ),
                  //       5.widthBox,
                  //       Icon(Icons.arrow_forward_ios, size: 14),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Categories Grid
          Obx(() {
            if (controller.isLoading.value && controller.categoryList.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (controller.categoryList.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("No categories found"),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  // Check if we need to show loading indicator at the end
                  if (index >= controller.categoryList.length) {
                    return Container(); // Empty container for safety
                  }

                  final item = controller.categoryList[index];

                  return GestureDetector(
                    onTap: () {
                      debugPrint("CATEGORY SLUG ${item.slug}");
                      Get.to(
                        () => JMCategoryProductScreen(
                          categoryName: item.name,
                          categoryId: item.id,
                          // categoryName: item.name,
                          categorySlug: item.slug,
                        ),
                        // arguments: {"categorySlug": item.slug},
                      );
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => JMCategoryProductScreen(
                      //       categoryName: item.name,
                      //       categoryId: item.id,
                      //       // categoryName: item.name,
                      //       categorySlug: item.slug,
                      //     ),
                      //   ),
                      // );
                    },
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
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  );
                }, childCount: 4), //controller.categoryList.length
              ),
            );
          }),

          // Loading more indicator
          // SliverToBoxAdapter(
          //   child: Obx(() {
          //     if (_isLoadingMore ||
          //         (controller.isLoading.value &&
          //             controller.categoryList.isNotEmpty)) {
          //       return Padding(
          //         padding: const EdgeInsets.all(20.0),
          //         child: Center(child: CircularProgressIndicator()),
          //       );
          //     }

          //     if (!controller.hasMore.value &&
          //         controller.categoryList.isNotEmpty) {
          //       return Padding(
          //         padding: const EdgeInsets.all(20.0),
          //         child: Center(
          //           child: Text(
          //             "No more categories",
          //             style: TextStyle(color: Colors.grey),
          //           ),
          //         ),
          //       );
          //     }

          //     return SizedBox.shrink();
          //   }),
          // ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 10)),
        ],
      ),
    );
  }
}

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/models/Jit/categorymodel.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Controllers/Jm_category_controller.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Screens/JM_Home/JM_Drawer/jm_drawer.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Screens/JM_Product_Screen/jm_product_screen.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/jitco_menu_nav_bar.dart';
// import 'package:velocity_x/velocity_x.dart';

// class JMHomeScreen extends StatefulWidget {
//   const JMHomeScreen({super.key});

//   @override
//   State<JMHomeScreen> createState() => _JMHomeScreenState();
// }

// List<Map<String, String>> imageList = [
//   {
//     "image": 'assets/Jit-Menu-Images/Capture.png',
//     "title": 'Unique experience and Flavours',
//     "subtitle": 'all under one name-',
//     "jitco": 'JITCO',
//   },
//   {
//     "image": 'assets/Jit-Menu-Images/cooking.png',
//     "title": 'Unique experience and Flavours',
//     "subtitle": 'all under one name-',
//     "jitco": 'JITCO',
//   },
//   {
//     "image": 'assets/Jit-Menu-Images/hdui.jpg',
//     "title": 'Unique experience and Flavours',
//     "subtitle": 'all under one name-',
//     "jitco": 'JITCO',
//   },
//   {
//     "image": 'assets/Jit-Menu-Images/sidhus.jpg',
//     "title": 'Unique experience and Flavours',
//     "subtitle": 'all under one name-',
//     "jitco": 'JITCO',
//   },
// ];

// class _JMHomeScreenState extends State<JMHomeScreen> {
//   final CategoryController controller = Get.find<CategoryController>();
//   final ScrollController _scrollController = ScrollController();
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize after first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_isInitialized && mounted) {
//         _initializeData();
//       }
//     });

//     // Add scroll listener
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _initializeData() {
//     if (_isInitialized) return;

//     _isInitialized = true;

//     // Only fetch if we don't have data
//     if (controller.categoryList.isEmpty && !controller.isLoading.value) {
//       controller.fetchCategories(isInitial: true);
//     }
//   }

//   void _onScroll() {
//     // Simple scroll detection - load more when near bottom
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;

//     if (maxScroll - currentScroll <= 200) {
//       _loadMore();
//     }
//   }

//   void _loadMore() {
//     if (!controller.isLoading.value &&
//         !controller.isLoadingMore.value &&
//         controller.hasMore.value) {
//       controller.loadMoreCategories();
//     }
//   }

//   Future<void> _refreshData() async {
//     await controller.refreshCategories();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(backgroundColor: Colors.white, child: JMDrawer()),
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: CustomScrollView(
//           controller: _scrollController,
//           physics: const AlwaysScrollableScrollPhysics(),
//           slivers: [
//             // App Bar
//             SliverAppBar(
//               surfaceTintColor: Colors.white,
//               backgroundColor: Colors.white,
//               floating: true,
//               pinned: false,
//               snap: false,
//               expandedHeight: 0,
//               title: SizedBox(
//                 width: 75,
//                 child: SvgPicture.asset('assets/logo.svg'),
//               ),
//               actions: [
//                 IconButton(
//                   onPressed: () {
//                     final bottomNavState = context
//                         .findAncestorStateOfType<JitcoMenuNavBarState>();
//                     if (bottomNavState != null) {
//                       bottomNavState.switchToTab(2);
//                     }
//                   },
//                   icon: const Icon(Icons.search, size: 23),
//                 ),
//                 7.widthBox,
//               ],
//             ),

//             // Carousel Section
//             SliverToBoxAdapter(
//               child: Column(
//                 children: [
//                   17.heightBox,
//                   CarouselSlider(
//                     options: CarouselOptions(
//                       aspectRatio: 20 / 9,
//                       autoPlay: true,
//                       autoPlayInterval: const Duration(seconds: 3),
//                       height: 180,
//                       enlargeCenterPage: true,
//                       viewportFraction: 0.9,
//                     ),
//                     items: imageList.map((item) {
//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 5),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15),
//                           child: Stack(
//                             fit: StackFit.expand,
//                             children: [
//                               Image.asset(item['image']!, fit: BoxFit.cover),
//                               Positioned(
//                                 bottom: 15,
//                                 left: 15,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.black.withOpacity(0.7),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 8,
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         item['title']!,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             item['subtitle']!,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             item['jitco']!,
//                                             style: TextStyle(
//                                               color: Colors.orange.shade700,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 15,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),

//             // Categories Header
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Explore Categories",
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.grey[800],
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     // You can add warehouse info here if needed
//                   ],
//                 ),
//               ),
//             ),

//             SliverToBoxAdapter(child: const SizedBox(height: 20)),

//             // Categories Grid
//             Obx(() {
//               // Show loading
//               if (controller.isLoading.value &&
//                   controller.categoryList.isEmpty) {
//                 return SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(40.0),
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.orange.shade700,
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               // Show empty state
//               if (controller.categoryList.isEmpty) {
//                 return SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(40.0),
//                     child: Center(
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.category,
//                             size: 60,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "No categories found",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               // Show grid
//               return SliverPadding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 sliver: SliverGrid(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: 1.1,
//                   ),
//                   delegate: SliverChildBuilderDelegate((context, index) {
//                     if (index >= controller.categoryList.length) {
//                       return const SizedBox.shrink();
//                     }

//                     final item = controller.categoryList[index];

//                     return GestureDetector(
//                       onTap: () {
//                         Get.to(
//                           () => JMProductScreen(
//                             categoryId: item.id,
//                             categorySlug: item.slug,
//                             categoryName: item.name,
//                           ),
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 6,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: Colors.grey[100],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Image.network(
//                                   item.image,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       color: Colors.grey[200],
//                                       child: Icon(
//                                         Icons.category,
//                                         size: 40,
//                                         color: Colors.grey[400],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 10),

//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                               ),
//                               child: Text(
//                                 item.name,
//                                 textAlign: TextAlign.center,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }, childCount: controller.categoryList.length),
//                 ),
//               );
//             }),

//             // Loading more indicator
//             Obx(() {
//               if (controller.isLoadingMore.value) {
//                 return SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.orange.shade700,
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               return const SliverToBoxAdapter(child: SizedBox.shrink());
//             }),

//             // Bottom padding
//             SliverToBoxAdapter(child: const SizedBox(height: 20)),
//           ],
//         ),
//       ),
//     );
//   }
// }
