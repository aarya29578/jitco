// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/models/Jit/categorymodel.dart';
// import 'package:jitco_app/models/outlet_model.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Screens/JM_Product_Screen/jm_product_screen.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Api_Service/api.dart';
// import 'package:jitco_app/services/api_service.dart';
// class JMCategoryScreen extends StatefulWidget {
//   const JMCategoryScreen({super.key});
//   @override
//   State<JMCategoryScreen> createState() => _JMCategoryScreenState();
// }
// class _JMCategoryScreenState extends State<JMCategoryScreen> {
//   // final categoryfetch prodController = Get.put(categoryfetch());
// final ApiServices apiServices = Get.find<ApiServices>();
// final CategoryController controller = Get.put(CategoryController());
// OutletModel? cityWarehouse;
// String? _warehouseId;
// @override
// void initState() {
//   super.initState();
//   _fetchIdFromWarehouse();
// }
// Future<void> _fetchIdFromWarehouse() async {
//   try {
//     print('START: _fetchIdFromWarehouse() called');
//     // 1. Fetch outlets
//     print('Fetching user outlets...');
//     final outletResponse = await apiServices.getUserOutlet();
//     if (outletResponse['success'] == true && outletResponse['data'] is List) {
//       final outlets = outletResponse['data'] as List;
//       if (outlets.isEmpty) {
//         print('No outlets found for user');
//         return;
//       }
//       // 2. Convert first outlet to OutletModel
//       print('Creating OutletModel from first outlet...');
//       final outlet = OutletModel.fromJson(outlets[0]);
//       // 3. Get city name directly from OutletModel
//       final cityName = outlet.cityName;
//       print('City name from OutletModel: "$cityName"');
//       if (cityName == null || cityName.isEmpty) {
//         print('City name is null or empty in OutletModel');
//         return;
//       }
//       // 4. Call warehouse API with city name
//       print('Calling warehouse API with city: "$cityName"...');
//       final result = await apiServices.getWarehouseIdByCity(
//         page: 1,
//         limit: 1,
//         encodedCity: cityName,
//       );
//       // 5. Process warehouse response - FIXED HERE
//       print('Warehouse API response: ${result}');
//       if (result['data'] != null) {
//         // Check if data is a List or a single object
//         if (result['data'] is List) {
//           final warehouseList = result['data'] as List;
//           if (warehouseList.isNotEmpty) {
//             print('Warehouse data found in list!');
//             final warehouseData = warehouseList[0];
//             final warehouseId = warehouseData['_id'];
//             print('Warehouse _id: $warehouseId');
//             // Store the warehouse ID
//             setState(() {
//               _warehouseId = warehouseId;
//               cityWarehouse = OutletModel.fromJson(warehouseData);
//             });
//             print('Warehouse model created with ID: ${cityWarehouse!.id}');
//           } else {
//             print('No warehouses found for city: $cityName');
//           }
//         }
//         // Handle if data is a single object (not a list)
//         else if (result['data'] is Map) {
//           print('Warehouse data found as single object!');
//           final warehouseData = result['data'] as Map<String, dynamic>;
//           final warehouseId = warehouseData['_id'];
//           print('Warehouse _id: $warehouseId');
//           // Store the warehouse ID
//           setState(() {
//             _warehouseId = warehouseId;
//             cityWarehouse = OutletModel.fromJson(warehouseData);
//           });
//           print('Warehouse model created with ID: ${cityWarehouse!.id}');
//         } else {
//           print(
//             'Invalid warehouse data format: ${result['data'].runtimeType}',
//           );
//         }
//       } else {
//         print('No data in warehouse response');
//       }
//     } else {
//       print('Failed to fetch outlets: ${outletResponse['message']}');
//     }
//   } catch (e) {
//     print('Error in _fetchIdFromWarehouse: $e');
//     print('Stack trace: ${e.toString()}');
//   } finally {
//     print('END: _fetchIdFromWarehouse() completed');
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text(
//       //     "CATEGORIES ",
//       //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       //   ),
//       //   backgroundColor: Colors.orangeAccent.shade400,
//       //   centerTitle: true,
//       // ),
//       backgroundColor: Colors.orange,
//       body: Column(
//         children: [
//           SizedBox(height: 60),
//           Text(
//             "Explore Our Categories",
//             style: TextStyle(
//               fontSize: 20,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 20),
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 4,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextFormField(
//                 // controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search Categories...",
//                   prefixIcon: Icon(Icons.search, color: Colors.orange),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 15,
//                   ),
//                   // suffixIcon: _isSearching
//                   //     ? IconButton(
//                   //         icon: Icon(Icons.clear, color: Colors.grey),
//                   //         onPressed: _clearSearch,
//                   //       )
//                   //     : null,
//                 ),
//                 // onChanged: _onSearchChanged,
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//           // PRODUCT LIST
//           Expanded(
//             child: Obx(() {
//               if (controller.isLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return GridView.builder(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 10,
//                 ),
//                 itemCount: controller.categoryList.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1.1,
//                 ),
//                 itemBuilder: (context, index) {
//                   final item = controller.categoryList[index];
//                   return GestureDetector(
//                     onTap: () {
//                       debugPrint("CATEGORY SLUG ${item.slug}");
//                       Get.to(
//                         () => JMProductScreen(
//                           categorySlug: item.slug,
//                           categoryId: item.id,
//                           categoryName: item.name,
//                         ), // ya ProductPage
//                         // arguments: {"categorySlug": item.slug},
//                       );
//                       print("categoryslug:${item.slug}");
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.network(
//                               item.image ?? "",
//                               height: 80,
//                               width: 80,
//                               fit: BoxFit.cover,
//                               errorBuilder: (c, e, s) => const Icon(
//                                 Icons.image_not_supported,
//                                 size: 50,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Center(
//                               child: Text(
//                                 item.name ?? "No Name",
//                                 textAlign: TextAlign.center,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _ProductCard extends StatefulWidget {
//   final CategoryModel product;
//   const _ProductCard({required this.product});
//  @override
//   State<_ProductCard> createState() => _ProductCardState();
// }
// class _ProductCardState extends State<_ProductCard> {
//   int selectedIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     // final prices = widget.product.price ?? [];
//     // final selectedPrice = prices.isNotEmpty ? prices[selectedIndex].price : 0;
//     TextEditingController searchcontroller = TextEditingController();
//     return Column(
//       children: [
//         GestureDetector(
//           child: Container(
//             height: 230,
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: const [
//                 BoxShadow(color: Colors.black12, blurRadius: 6),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.asset(
//                         "lib/assets/images/Capture.png",
//                         height: 100,
//                         width: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.product.name ?? "",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             widget.product.description ?? "",
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(color: Colors.grey.shade600),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/models/Jit/categorymodel.dart';
// import 'package:jitco_app/models/PostModel.dart';
// import 'package:jitco_app/models/outlet_model.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Api_Service/api.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Controllers/Jm_category_controller.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Screens/JM_Product_Screen/jm_product_screen.dart';
// import 'package:jitco_app/screens/Jitco_Supply_Home/C_Universal_Product/universal_product_screen.dart';
// import 'package:jitco_app/services/api_service.dart';
// import 'package:velocity_x/velocity_x.dart';

// class JMCategoryScreen extends StatefulWidget {
//   const JMCategoryScreen({super.key});

//   @override
//   State<JMCategoryScreen> createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<JMCategoryScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   // final AuthController _authController = Get.find<AuthController>();
//   final FocusNode _searchFocus = FocusNode();

//   Timer? _debounce;

//   List<CategoryData> displayedCategories = [];

//   int _currentPage = 1;
//   static const int _limit = 20;
//   int _totalPages = 1;
//   bool isLoadingInitial = true;
//   bool isLoadingMore = false;
//   bool hasMore = true;

//   String _searchText = "";

//   final JMApiService _apiService = Get.put(JMApiService());

//   @override
//   void initState() {
//     super.initState();
//     _fetchIdFromWarehouse();
//     fetchProducts(isInitial: true);
//     _scrollController.addListener(_onScroll);
//     _searchFocus.addListener(() {
//       if (_searchFocus.hasFocus) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     _searchFocus.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   final ApiServices apiServices = Get.find<ApiServices>();

//   final CategoryController controller = Get.put(CategoryController());
//   OutletModel? cityWarehouse;
//   String? _warehouseId;

//   Future<void> _fetchIdFromWarehouse() async {
//     try {
//       print('START: _fetchIdFromWarehouse() called');

//       // 1. Fetch outlets
//       print('Fetching user outlets...');
//       final outletResponse = await apiServices.getUserOutlet();

//       if (outletResponse['success'] == true && outletResponse['data'] is List) {
//         final outlets = outletResponse['data'] as List;

//         if (outlets.isEmpty) {
//           print('No outlets found for user');
//           return;
//         }

//         // 2. Convert first outlet to OutletModel
//         print('Creating OutletModel from first outlet...');
//         final outlet = OutletModel.fromJson(outlets[0]);

//         // 3. Get city name directly from OutletModel
//         final cityName = outlet.cityName;
//         print('City name from OutletModel: "$cityName"');

//         if (cityName == null || cityName.isEmpty) {
//           print('City name is null or empty in OutletModel');
//           return;
//         }

//         // 4. Call warehouse API with city name
//         print('Calling warehouse API with city: "$cityName"...');
//         final result = await apiServices.getWarehouseIdByCity(
//           page: 1,
//           limit: 1,
//           encodedCity: cityName,
//         );

//         // 5. Process warehouse response - FIXED HERE
//         print('Warehouse API response: ${result}');

//         if (result['data'] != null) {
//           // Check if data is a List or a single object
//           if (result['data'] is List) {
//             final warehouseList = result['data'] as List;

//             if (warehouseList.isNotEmpty) {
//               print('Warehouse data found in list!');
//               final warehouseData = warehouseList[0];
//               final warehouseId = warehouseData['_id'];

//               print('Warehouse _id: $warehouseId');

//               // Store the warehouse ID
//               setState(() {
//                 _warehouseId = warehouseId;
//                 cityWarehouse = OutletModel.fromJson(warehouseData);
//               });

//               print('Warehouse model created with ID: ${cityWarehouse!.id}');
//             } else {
//               print('No warehouses found for city: $cityName');
//             }
//           }
//           // Handle if data is a single object (not a list)
//           else if (result['data'] is Map) {
//             print('Warehouse data found as single object!');
//             final warehouseData = result['data'] as Map<String, dynamic>;
//             final warehouseId = warehouseData['_id'];

//             print('Warehouse _id: $warehouseId');

//             // Store the warehouse ID
//             setState(() {
//               _warehouseId = warehouseId;
//               cityWarehouse = OutletModel.fromJson(warehouseData);
//             });

//             print('Warehouse model created with ID: ${cityWarehouse!.id}');
//           } else {
//             print(
//               'Invalid warehouse data format: ${result['data'].runtimeType}',
//             );
//           }
//         } else {
//           print('No data in warehouse response');
//         }
//       } else {
//         print('Failed to fetch outlets: ${outletResponse['message']}');
//       }
//     } catch (e) {
//       print('Error in _fetchIdFromWarehouse: $e');
//       print('Stack trace: ${e.toString()}');
//     } finally {
//       print('END: _fetchIdFromWarehouse() completed');
//     }
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (hasMore && !isLoadingMore) {
//         _currentPage++;
//         fetchProducts(isInitial: false);
//       }
//     }
//   }

//   Future<void> fetchProducts({required bool isInitial}) async {
//     if (!hasMore && !isInitial) return;

//     if (isInitial) {
//       if (mounted) setState(() => isLoadingInitial = true);
//     } else {
//       if (mounted) setState(() => isLoadingMore = true);
//     }

//     try {
//       final result = await _apiService.searchCategories(
//         page: _currentPage,
//         limit: _limit,
//         search: _searchText,
//       );

//       // if (mounted) {
//       //   setState(() {
//       //     _totalPages = (result.totalPages ?? 1).toInt();
//       //     // _totalPages = int.tryParse(result.totalPages?.toString() ?? '1') ?? 1;

//       //     if (result.data != null) {
//       //       if (isInitial) {
//       //         displayedCategories = result.data!;
//       //       } else {
//       //         displayedCategories.addAll(result.data!);
//       //       }
//       //     }

//       //     hasMore = _currentPage < _totalPages;
//       //   });
//       // }
//     } catch (e) {
//       print("Error fetching categories: $e");
//       // You can show a snackbar or dialog for error handling
//     }

//     if (mounted) {
//       setState(() {
//         isLoadingInitial = false;
//         isLoadingMore = false;
//       });
//     }
//   }

//   void _onCategoryTap(CategoryModel category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => JMProductScreen(
//           categoryId: category.id,
//           categorySlug: category.slug,
//           categoryName: category.name,
//           // isBrandScreen: false, // This is a category screen, not brand
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.orange.shade700,
//       appBar: AppBar(
//         surfaceTintColor: Colors.orange.shade700,
//         backgroundColor: Colors.orange.shade700,
//         elevation: 0,
//         title: const Text(
//           "Explore Our Categories",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 25,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               10.heightBox,
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: _searchController,
//                   focusNode: _searchFocus,
//                   decoration: const InputDecoration(
//                     hintText: "Search categories...",
//                     prefixIcon: Icon(Icons.search, color: Colors.orange),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                   ),
//                   onChanged: (value) {
//                     if (!_searchFocus.hasFocus) {
//                       _searchFocus.requestFocus();
//                     }

//                     if (_debounce?.isActive ?? false) _debounce!.cancel();

//                     _debounce = Timer(const Duration(milliseconds: 350), () {
//                       _searchText = value;
//                       _currentPage = 1;
//                       displayedCategories.clear();
//                       fetchProducts(isInitial: true);
//                     });
//                   },
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Expanded(
//               //   child: isLoadingInitial
//               //       ? const Center(
//               //           child: CircularProgressIndicator(color: Colors.orange),
//               //         )
//               //       : GridView.builder(
//               //           controller: _scrollController,
//               //           padding: const EdgeInsets.only(bottom: 20),
//               //           itemCount:
//               //               displayedCategories.length +
//               //               (isLoadingMore ? 1 : 0),
//               //           gridDelegate:
//               //               const SliverGridDelegateWithFixedCrossAxisCount(
//               //                 crossAxisCount: 2,
//               //                 crossAxisSpacing: 12,
//               //                 mainAxisSpacing: 12,
//               //                 childAspectRatio: 1.1,
//               //               ),
//               //           itemBuilder: (context, index) {
//               //             if (index == displayedCategories.length) {
//               //               return const Center(
//               //                 child: CircularProgressIndicator(
//               //                   color: Colors.orange,
//               //                 ),
//               //               );
//               //             }
//               //             // final category = displayedCategories[index];
//               //             final item = controller.categoryList[index];
//               //             return GestureDetector(
//               //               onTap: () {
//               //                 debugPrint("CATEGORY SLUG ${item.slug}");
//               //                 Get.to(
//               //                   () => JMProductScreen(
//               //                     categorySlug: item.slug,
//               //                     categoryId: item.id,
//               //                     categoryName: item.name,
//               //                   ), // ya ProductPage
//               //                   // arguments: {"categorySlug": item.slug},
//               //                 );
//               //                 print("categoryslug:${item.slug}");
//               //               },
//               //               child: Container(
//               //                 decoration: BoxDecoration(
//               //                   color: Colors.white,
//               //                   borderRadius: BorderRadius.circular(15),
//               //                   boxShadow: const [
//               //                     BoxShadow(
//               //                       color: Colors.black12,
//               //                       blurRadius: 4,
//               //                       offset: Offset(0, 2),
//               //                     ),
//               //                   ],
//               //                 ),
//               //                 child: Column(
//               //                   mainAxisAlignment: MainAxisAlignment.center,
//               //                   children: [
//               //                     ClipRRect(
//               //                       borderRadius: BorderRadius.circular(12),
//               //                       child: Image.network(
//               //                         item.image ?? "",
//               //                         height: 80,
//               //                         width: 80,
//               //                         fit: BoxFit.cover,
//               //                         errorBuilder: (c, e, s) => const Icon(
//               //                           Icons.image_not_supported,
//               //                           size: 50,
//               //                           color: Colors.grey,
//               //                         ),
//               //                       ),
//               //                     ),
//               //                     const SizedBox(height: 10),
//               //                     Padding(
//               //                       padding: const EdgeInsets.symmetric(
//               //                         horizontal: 10,
//               //                       ),
//               //                       child: Center(
//               //                         child: Text(
//               //                           item.name ?? "No Name",
//               //                           textAlign: TextAlign.center,
//               //                           maxLines: 2,
//               //                           overflow: TextOverflow.ellipsis,
//               //                           style: const TextStyle(
//               //                             fontSize: 14,
//               //                             fontWeight: FontWeight.w600,
//               //                           ),
//               //                         ),
//               //                       ),
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ),
//               //             );
//               //             // return GestureDetector(
//               //             //   onTap: () => _onCategoryTap(category),
//               //             //   child: Container(
//               //             //     decoration: BoxDecoration(
//               //             //       color: Colors.white,
//               //             //       borderRadius: BorderRadius.circular(15),
//               //             //       boxShadow: const [
//               //             //         BoxShadow(
//               //             //           color: Colors.black12,
//               //             //           blurRadius: 4,
//               //             //           offset: Offset(0, 2),
//               //             //         ),
//               //             //       ],
//               //             //     ),
//               //             //     child: Column(
//               //             //       mainAxisAlignment: MainAxisAlignment.center,
//               //             //       children: [
//               //             //         ClipRRect(
//               //             //           borderRadius: BorderRadius.circular(12),
//               //             //           child: Image.network(
//               //             //             category.image ?? "",
//               //             //             height: 80,
//               //             //             width: 80,
//               //             //             fit: BoxFit.cover,
//               //             //             errorBuilder: (c, e, s) => const Icon(
//               //             //               Icons.image_not_supported,
//               //             //               size: 50,
//               //             //               color: Colors.grey,
//               //             //             ),
//               //             //           ),
//               //             //         ),
//               //             //         const SizedBox(height: 10),
//               //             //         Padding(
//               //             //           padding: const EdgeInsets.symmetric(
//               //             //             horizontal: 10,
//               //             //           ),
//               //             //           child: Center(
//               //             //             child: Text(
//               //             //               category.categoryName ?? "No Name",
//               //             //               textAlign: TextAlign.center,
//               //             //               maxLines: 2,
//               //             //               overflow: TextOverflow.ellipsis,
//               //             //               style: const TextStyle(
//               //             //                 fontSize: 14,
//               //             //                 fontWeight: FontWeight.w600,
//               //             //               ),
//               //             //             ),
//               //             //           ),
//               //             //         ),
//               //             //       ],
//               //             //     ),
//               //             //   ),
//               //             // );
//               //             // Expanded(
//               //             //   child: Obx(() {
//               //             //     if (controller.isLoading.value) {
//               //             //       return const Center(
//               //             //         child: CircularProgressIndicator(),
//               //             //       );
//               //             //     }
//               //             //     return GridView.builder(
//               //             //       padding: const EdgeInsets.symmetric(
//               //             //         horizontal: 10,
//               //             //         vertical: 10,
//               //             //       ),
//               //             //       itemCount: controller.categoryList.length,
//               //             //       gridDelegate:
//               //             //           const SliverGridDelegateWithFixedCrossAxisCount(
//               //             //             crossAxisCount: 2,
//               //             //             crossAxisSpacing: 12,
//               //             //             mainAxisSpacing: 12,
//               //             //             childAspectRatio: 1.1,
//               //             //           ),
//               //             //       itemBuilder: (context, index) {
//               //             //         final item = controller.categoryList[index];
//               //             //         return GestureDetector(
//               //             //           onTap: () {
//               //             //             debugPrint("CATEGORY SLUG ${item.slug}");
//               //             //             Get.to(
//               //             //               () => JMProductScreen(
//               //             //                 categorySlug: item.slug,
//               //             //                 categoryId: item.id,
//               //             //                 categoryName: item.name,
//               //             //               ), // ya ProductPage
//               //             //               // arguments: {"categorySlug": item.slug},
//               //             //             );
//               //             //             print("categoryslug:${item.slug}");
//               //             //           },
//               //             //           child: Container(
//               //             //             decoration: BoxDecoration(
//               //             //               color: Colors.white,
//               //             //               borderRadius: BorderRadius.circular(15),
//               //             //               boxShadow: const [
//               //             //                 BoxShadow(
//               //             //                   color: Colors.black12,
//               //             //                   blurRadius: 4,
//               //             //                   offset: Offset(0, 2),
//               //             //                 ),
//               //             //               ],
//               //             //             ),
//               //             //             child: Column(
//               //             //               mainAxisAlignment:
//               //             //                   MainAxisAlignment.center,
//               //             //               children: [
//               //             //                 ClipRRect(
//               //             //                   borderRadius: BorderRadius.circular(
//               //             //                     12,
//               //             //                   ),
//               //             //                   child: Image.network(
//               //             //                     item.image ?? "",
//               //             //                     height: 80,
//               //             //                     width: 80,
//               //             //                     fit: BoxFit.cover,
//               //             //                     errorBuilder: (c, e, s) =>
//               //             //                         const Icon(
//               //             //                           Icons.image_not_supported,
//               //             //                           size: 50,
//               //             //                           color: Colors.grey,
//               //             //                         ),
//               //             //                   ),
//               //             //                 ),
//               //             //                 const SizedBox(height: 10),
//               //             //                 Padding(
//               //             //                   padding: const EdgeInsets.symmetric(
//               //             //                     horizontal: 10,
//               //             //                   ),
//               //             //                   child: Center(
//               //             //                     child: Text(
//               //             //                       item.name ?? "No Name",
//               //             //                       textAlign: TextAlign.center,
//               //             //                       maxLines: 2,
//               //             //                       overflow: TextOverflow.ellipsis,
//               //             //                       style: const TextStyle(
//               //             //                         fontSize: 14,
//               //             //                         fontWeight: FontWeight.w600,
//               //             //                       ),
//               //             //                     ),
//               //             //                   ),
//               //             //                 ),
//               //             //               ],
//               //             //             ),
//               //             //           ),
//               //             //         );
//               //             //       },
//               //             //     );
//               //             //   }),
//               //             // );
//               //           },
//               //         ),
//               // ),
//               // PRODUCT LIST
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   return GridView.builder(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 10,
//                     ),
//                     itemCount: controller.categoryList.length,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 12,
//                           mainAxisSpacing: 12,
//                           childAspectRatio: 1.1,
//                         ),
//                     itemBuilder: (context, index) {
//                       final item = controller.categoryList[index];

//                       return GestureDetector(
//                         onTap: () {
//                           debugPrint("CATEGORY SLUG ${item.slug}");
//                           _onCategoryTap(item);
//                           print("categoryslug:${item.slug}");
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 4,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Image.network(
//                                   item.image ?? "",
//                                   height: 80,
//                                   width: 80,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (c, e, s) => const Icon(
//                                     Icons.image_not_supported,
//                                     size: 50,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     item.name ?? "No Name",
//                                     textAlign: TextAlign.center,
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_category_product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/b_JM_Category/jm_category_product_screen.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Screens/JM_Product_Screen/jm_all_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:velocity_x/velocity_x.dart';

/// Only show the relevant parts - remove redundant code
class JMCategoryScreen extends StatefulWidget {
  const JMCategoryScreen({super.key});

  @override
  State<JMCategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<JMCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiServices apiServices = Get.find<ApiServices>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  final JmCategoryController controller = Get.put(JmCategoryController());
  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchIdFromWarehouse(); // Keep this if needed
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMore();
    }
  }

  // void _onCategoryTap(CategoryModel category) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => JMProductScreen(
  //         categoryId: category.id,
  //         categorySlug: category.slug,
  //         categoryName: category.name,
  //       ),
  //     ),
  //   );
  // }

  void _onCategoryTap(CategoryModel category) {
    print("Navigating to products with category: ${category.name}");

    Get.to(
      () => JMCategoryProductScreen(
        categoryId: category.id,
        categorySlug: category.slug,
        categoryName: category.name,
        // fromCategoryScreen: true,
      ),
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => JMCategoryProductScreen(
    //       categoryId: category.id,
    //       categorySlug: category.slug,
    //       categoryName: category.name,
    //       // fromCategoryScreen: true,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.orange.shade700,
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        title: const Text(
          "Explore Our Categories",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              10.heightBox,
              // Search Bar
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(10),
              //     boxShadow: const [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 4,
              //         offset: Offset(0, 2),
              //       ),
              //     ],
              //   ),
              //   child: TextField(
              //     controller: _searchController,
              //     focusNode: _searchFocus,
              //     decoration: const InputDecoration(
              //       hintText: "Search categories...",
              //       prefixIcon: Icon(Icons.search, color: Colors.orange),
              //       border: InputBorder.none,
              //       contentPadding: EdgeInsets.symmetric(
              //         horizontal: 20,
              //         vertical: 15,
              //       ),
              //     ),
              //     onChanged: controller.onSearchChanged,
              //   ),
              // ),
              Container(
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
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,

                  onChanged: (value) {
                    controller.onSearchChanged(value);
                    setState(() {}); // rebuild to show/hide cancel icon
                  },

                  decoration: InputDecoration(
                    // filled: true,
                    // fillColor: Colors.white,
                    // hintText: "Search categories...",
                    // hintStyle: const TextStyle(color: Colors.grey),
                    // prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    hintText: "Search categories...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    /// CANCEL BUTTON
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear(); // Clear UI
                              controller.searchText =
                                  ""; // Reset controller state
                              controller.fetchCategories(
                                isInitial: true,
                              ); // Reload
                              _searchFocus.unfocus(); // optional polish
                              setState(() {}); // Hide icon
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Categories Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.categoryList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }

                  if (controller.categoryList.isEmpty) {
                    return const Center(
                      child: Text(
                        "No categories found",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        // Handle scroll end if needed
                      }
                      return false;
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount:
                          controller.categoryList.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                      itemBuilder: (context, index) {
                        // Loading indicator for load more
                        if (index == controller.categoryList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          );
                        }

                        final category = controller.categoryList[index];
                        return GestureDetector(
                          onTap: () => _onCategoryTap(category),
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
                                    category.image,
                                    height: 80,
                                    width: 80,
                                    // fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
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
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep your _fetchIdFromWarehouse() method as is
  // Future<void> _fetchIdFromWarehouse() async {
  //   // Your existing code...
  // }
}
