
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/controllers/auth_controllers.dart';
// import 'package:jitco_app/controllers/cart_controller.dart';
// import 'package:jitco_app/models/PostModel.dart';
// import 'package:jitco_app/models/cart_model.dart';
// import 'package:jitco_app/models/contract_model.dart';
// import 'package:jitco_app/models/outlet_model.dart';
// import 'package:jitco_app/services/api_service.dart';
// import 'package:velocity_x/velocity_x.dart';

// class ContractScreen extends StatefulWidget {
//   const ContractScreen({super.key});

//   @override
//   State<ContractScreen> createState() => _ContractScreenState();
// }

// class _ContractScreenState extends State<ContractScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final AuthController _authController = Get.find<AuthController>();
//   late ApiService _apiService;

//   // State variables
//   PostModel? _categories;
//   ContractModel? _contractData;
//   bool _isLoading = true;
//   bool _isLoadingCategories = true;
//   String? _selectedCategoryId = 'all';
//   String _searchQuery = '';

//   // Pagination
//   int _currentPage = 1;
//   final int _itemsPerPage = 20;
//   bool _hasMore = true;
//   bool _isLoadingMore = false;

//   OutletModel? cityWarehouse;
//   String? _warehouseId;

//   @override
//   void initState() {
//     super.initState();
//     // _fetchIdFromWarehouse();
//     _initializeServices();
//     // _loadContractData();
//   }

//   void _addToCart(
//     String productId,
//     String productName,
//     productImage,
//     String productPrice,
//     String productGst,
//     String productSlug,
//     // dynamic product,
//   ) {
//     final CartController cartController = Get.find<CartController>();

//     final cartItem = CartItem(
//       id: productId,
//       name: productName,
//       image: productImage,
//       price: double.tryParse(productPrice) ?? 0.0,
//       gstPercentage: double.tryParse(productGst) ?? 0.0,
//       quantity: 1,
//       categorySlug: productSlug,
//       selectedVariant: '1 pc.', // Default variant
//     );

//     cartController.addToCart(cartItem);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$productName added to cart'),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   Future<void> _fetchIdFromWarehouse() async {
//     try {
//       print('START: _fetchIdFromWarehouse() called');

//       // 1. Fetch outlets
//       print('Fetching user outlets...');
//       final outletResponse = await _apiService.getUserOutlet();

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
//         final result = await _apiService.getWarehouseIdByCity(
//           page: 1,
//           limit: 1,
//           encodedCity: cityName,
//         );

//         // 5. Process warehouse response - FIXED HERE
//         print('📊 Warehouse API response: ${result}');

//         if (result['data'] != null) {
//           // Check if data is a List or a single object
//           if (result['data'] is List) {
//             final warehouseList = result['data'] as List;

//             if (warehouseList.isNotEmpty) {
//               print('✅ Warehouse data found in list!');
//               final warehouseData = warehouseList[0];
//               final warehouseId = warehouseData['_id'];

//               print('🏭 Warehouse _id: $warehouseId');

//               // Store the warehouse ID
//               setState(() {
//                 _warehouseId = warehouseId;
//                 cityWarehouse = OutletModel.fromJson(warehouseData);
//               });

//               print('✅ Warehouse model created with ID: ${cityWarehouse!.id}');
//             } else {
//               print('❌ No warehouses found for city: $cityName');
//             }
//           }
//           // Handle if data is a single object (not a list)
//           else if (result['data'] is Map) {
//             print('✅ Warehouse data found as single object!');
//             final warehouseData = result['data'] as Map<String, dynamic>;
//             final warehouseId = warehouseData['_id'];

//             print('🏭 Warehouse _id: $warehouseId');

//             // Store the warehouse ID
//             setState(() {
//               _warehouseId = warehouseId;
//               cityWarehouse = OutletModel.fromJson(warehouseData);
//             });

//             print('✅ Warehouse model created with ID: ${cityWarehouse!.id}');
//           } else {
//             print(
//               '❌ Invalid warehouse data format: ${result['data'].runtimeType}',
//             );
//           }
//         } else {
//           print('❌ No data in warehouse response');
//         }
//       } else {
//         print('❌ Failed to fetch outlets: ${outletResponse['message']}');
//       }
//     } catch (e) {
//       print('❌ Error in _fetchIdFromWarehouse: $e');
//       print('Stack trace: ${e.toString()}');
//     } finally {
//       print('🏁 END: _fetchIdFromWarehouse() completed');
//     }
//   }

//   Future<void> _initializeServices() async {
//     try {
//       // Get the initialized ApiService from GetX
//       _apiService = Get.find<ApiService>();
//       print('✅ ApiService loaded successfully');
//       await _loadInitialData();
//     } catch (e) {
//       print('❌ Error initializing services: $e');
//       // Show error message
//       Get.snackbar(
//         'Error',
//         'Failed to initialize services. Please restart the app.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//       setState(() {
//         _isLoading = false;
//         _isLoadingCategories = false;
//       });
//     }
//   }

//   Future<void> _loadInitialData() async {
//     try {
//       // 1️⃣ MUST complete first
//       await _fetchIdFromWarehouse();

//       // 2️⃣ These can run in parallel
//       await Future.wait([_loadCategories(), _loadContractData()]);
//     } catch (e) {
//       print('❌ Error loading initial data: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to load data: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _isLoadingCategories = false;
//       });
//     }
//   }

//   Future<void> _loadCategories() async {
//     try {
//       print('📡 Loading categories...');
//       final categories = await _apiService.fetchProductCategories(
//         page: 1,
//         limit: 200,
//       );
//       print('✅ Categories loaded: ${categories.data?.length ?? 0} items');
//       setState(() {
//         _categories = categories;
//       });
//     } catch (e) {
//       print('❌ Error loading categories: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to load categories',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Future<void> _loadContractData({bool loadMore = false}) async {
//   //   try {
//   //     if (!loadMore) {
//   //       setState(() {
//   //         _isLoading = true;
//   //         _currentPage = 1;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _isLoadingMore = true;
//   //       });
//   //     }

//   //     print('📡 Loading contract data (page: $_currentPage)...');

//   //     final contractData = await _apiService.getContractData(
//   //       page: _currentPage,
//   //       limit: _itemsPerPage,
//   //       categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
//   //       search: _searchQuery.isNotEmpty ? _searchQuery : null,
//   //       warehouseId: _warehouseId,
//   //     );

//   //     print('✅ Contract data loaded: ${contractData.data.length} items');
//   //     print('📊 Total items: ${contractData.total}');

//   //     setState(() {
//   //       if (loadMore && _contractData != null) {
//   //         // Append new data
//   //         _contractData = ContractModel(
//   //           success: contractData.success,
//   //           total: contractData.total,
//   //           page: contractData.page,
//   //           limit: contractData.limit,
//   //           totalPages: contractData.totalPages,
//   //           data: [..._contractData!.data, ...contractData.data],
//   //         );
//   //       } else {
//   //         // Replace with new data
//   //         _contractData = contractData;
//   //       }

//   //       // Check if there are more pages
//   //       _hasMore = _currentPage < contractData.totalPages;
//   //       _isLoadingMore = false;
//   //     });
//   //   } catch (e) {
//   //     print('❌ Error loading contract data: $e');
//   //     Get.snackbar(
//   //       'Error',
//   //       'Failed to load products: ${e.toString()}',
//   //       backgroundColor: Colors.red,
//   //       colorText: Colors.white,
//   //     );
//   //     setState(() {
//   //       _isLoading = false;
//   //       _isLoadingMore = false;
//   //     });
//   //   } finally {
//   //     if (!loadMore) {
//   //       setState(() {
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   }
//   // }

//   Future<void> _loadContractData({bool loadMore = false}) async {
//     try {
//       if (!loadMore) {
//         setState(() {
//           _isLoading = true;
//           _currentPage = 1;
//         });
//       } else {
//         setState(() {
//           _isLoadingMore = true;
//         });
//       }

//       print('📡 Loading contract data (page: $_currentPage)...');

//       ContractModel contractData;

//       // DECIDE WHICH API TO USE:
//       if (_searchQuery.isNotEmpty) {
//         // USE SEARCH API for searching
//         print('🔍 Using SEARCH API for query: "$_searchQuery"');

//         contractData = await _apiService.searchContractProducts(
//           query: _searchQuery,
//           categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
//           page: _currentPage,
//           limit: _itemsPerPage,
//           warehouseId: _warehouseId,
//         );
//       } else {
//         // USE getContractData for browsing
//         print('📦 Using getContractData API for browsing');

//         contractData = await _apiService.getContractData(
//           page: _currentPage,
//           limit: _itemsPerPage,
//           categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
//           search: null,
//           warehouseId: _warehouseId,
//         );
//       }

//       print('✅ Contract data loaded: ${contractData.data.length} items');
//       print('📊 Total items: ${contractData.total}');
//       print('📊 Success: ${contractData.success}');
//       print('📊 Page: ${contractData.page}/${contractData.totalPages}');

//       setState(() {
//         if (loadMore && _contractData != null) {
//           // Append new data
//           _contractData = ContractModel(
//             success: contractData.success,
//             total: contractData.total,
//             page: contractData.page,
//             limit: contractData.limit,
//             totalPages: contractData.totalPages,
//             data: [..._contractData!.data, ...contractData.data],
//           );
//         } else {
//           // Replace with new data
//           _contractData = contractData;
//         }

//         // Check if there are more pages
//         _hasMore = _currentPage < contractData.totalPages;
//         _isLoadingMore = false;
//       });
//     } catch (e) {
//       print('❌ Error loading contract data: $e');

//       // Handle specific errors
//       String errorMessage = 'Failed to load products';
//       if (e.toString().contains('Query parameter is required')) {
//         errorMessage = 'Please enter a search term';
//       } else if (e.toString().contains('Network error')) {
//         errorMessage = 'Network error. Please check your connection';
//       }

//       Get.snackbar(
//         'Error',
//         errorMessage,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: Duration(seconds: 3),
//       );

//       setState(() {
//         _isLoading = false;
//         _isLoadingMore = false;
//       });
//     } finally {
//       if (!loadMore) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadMoreData() async {
//     if (_isLoadingMore || !_hasMore) return;

//     print('📡 Loading more data (page: ${_currentPage + 1})...');
//     setState(() {
//       _currentPage++;
//     });

//     await _loadContractData(loadMore: true);
//   }

//   void _onSearchChanged(String value) {
//     _searchQuery = value.trim();
//     // Only search if query is empty (clear search)
//     if (_searchQuery.isEmpty) {
//       _performSearch();
//     }
//   }

//   void _performSearch() {
//     // Debounce search - wait 500ms before searching
//     Future.delayed(const Duration(milliseconds: 500), () {
//       print('🔍 Performing search: "$_searchQuery"');
//       _loadContractData();
//     });
//   }

//   void _clearSearch() {
//     _searchController.clear();
//     setState(() {
//       _searchQuery = '';
//     });
//     print('🧹 Search cleared');
//     _loadContractData();
//   }

//   void _showBottomSheetFilter() {
//     if (_isLoadingCategories) return;

//     showModalBottomSheet(
//       backgroundColor: Colors.white,
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.8,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     "Filter by Category".text
//                         .size(20)
//                         .fontWeight(FontWeight.bold)
//                         .make(),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close),
//                     ),
//                   ],
//                 ),
//                 Divider(color: Colors.grey[300]),
//                 10.heightBox,
//                 Expanded(
//                   child: _isLoadingCategories
//                       ? const Center(child: CircularProgressIndicator())
//                       : ListView(
//                           shrinkWrap: true,
//                           children: [
//                             // "All" option
//                             ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               leading: Radio<String>(
//                                 value: 'all',
//                                 groupValue: _selectedCategoryId,
//                                 onChanged: (String? value) {
//                                   setState(() {
//                                     _selectedCategoryId = value;
//                                   });
//                                   Navigator.pop(context);
//                                   print('🎯 Selected: All Categories');
//                                   _loadContractData();
//                                 },
//                                 activeColor: Colors.orange.shade700,
//                               ),
//                               title: const Text('All Categories'),
//                               onTap: () {
//                                 setState(() {
//                                   _selectedCategoryId = 'all';
//                                 });
//                                 Navigator.pop(context);
//                                 print('🎯 Selected: All Categories');
//                                 _loadContractData();
//                               },
//                             ),
//                             // Category options
//                             ...(_categories?.data ?? [])
//                                 .where(
//                                   (category) =>
//                                       category.show == true &&
//                                       category.isActive == true,
//                                 )
//                                 .map((category) {
//                                   return ListTile(
//                                     contentPadding: EdgeInsets.zero,
//                                     leading: Radio<String>(
//                                       value: category.id ?? '',
//                                       groupValue: _selectedCategoryId,
//                                       onChanged: (String? value) {
//                                         setState(() {
//                                           _selectedCategoryId = value;
//                                         });
//                                         Navigator.pop(context);
//                                         print(
//                                           '🎯 Selected: ${category.categoryName}',
//                                         );
//                                         _loadContractData();
//                                       },
//                                       activeColor: Colors.orange.shade700,
//                                     ),
//                                     title: Text(
//                                       category.categoryName ??
//                                           'Unnamed Category',
//                                     ),
//                                     subtitle:
//                                         category.description?.isNotEmpty == true
//                                         ? Text(
//                                             category.description!,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey[600],
//                                             ),
//                                           )
//                                         : null,
//                                     onTap: () {
//                                       setState(() {
//                                         _selectedCategoryId = category.id;
//                                       });
//                                       Navigator.pop(context);
//                                       print(
//                                         '🎯 Selected: ${category.categoryName}',
//                                       );
//                                       _loadContractData();
//                                     },
//                                   );
//                                 })
//                                 .toList(),
//                           ],
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _getSelectedCategoryName() {
//     if (_selectedCategoryId == 'all') {
//       return 'All Categories';
//     }

//     if (_categories == null || _categories!.data == null) {
//       return 'Select Category';
//     }

//     final category = _categories!.data!.firstWhere(
//       (cat) => cat.id == _selectedCategoryId,
//       orElse: () => CategoryData(),
//     );

//     return category.categoryName ?? 'Select Category';
//   }

//   Widget _buildProductItem(ContractProduct product) {
//     return Card(
//       color: Colors.white,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       elevation: 2,
//       // surfaceTintColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: InkWell(
//         onTap: () {
//           // Navigate to product details if needed
//           print('📱 Tapped product: ${product.name}');
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.grey[100],
//                 ),
//                 child:
//                     product.firstImage != null && product.firstImage!.isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           product.firstImage!,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value:
//                                     loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                           loadingProgress.expectedTotalBytes!
//                                     : null,
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Icon(
//                               Icons.shopping_bag,
//                               color: Colors.orange.shade700,
//                               size: 40,
//                             );
//                           },
//                         ),
//                       )
//                     : Icon(
//                         Icons.shopping_bag,
//                         color: Colors.orange.shade700,
//                         size: 40,
//                       ),
//               ),
//               12.widthBox,

//               // Product Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     4.heightBox,

//                     if (product.description != null &&
//                         product.description!.isNotEmpty)
//                       Text(
//                         product.description!,
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                     6.heightBox,

//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             product.category,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.orange.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: product.inStock
//                                 ? Colors.green[50]
//                                 : Colors.red[50],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             product.inStock ? 'In Stock' : 'Out of Stock',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: product.inStock
//                                   ? Colors.green[700]
//                                   : Colors.red[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     6.heightBox,

//                     Row(
//                       children: [
//                         Text(
//                           '₹${product.price.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         8.widthBox,
//                         if (product.unit != null)
//                           Text(
//                             '/${product.unit}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         const Spacer(),
//                         // if (product.brand != null && product.brand!.isNotEmpty)
//                         //   Container(
//                         //     padding: const EdgeInsets.symmetric(
//                         //       horizontal: 6,
//                         //       vertical: 2,
//                         //     ),
//                         //     decoration: BoxDecoration(
//                         //       color: Colors.blue[50],
//                         //       borderRadius: BorderRadius.circular(4),
//                         //     ),
//                         //     child: Text(
//                         //       product.brand!,
//                         //       style: TextStyle(
//                         //         fontSize: 11,
//                         //         color: Colors.blue[700],
//                         //         fontWeight: FontWeight.w500,
//                         //       ),
//                         //       maxLines: 1,
//                         //       overflow: TextOverflow.ellipsis,
//                         //     ),
//                         //   ),
//                       ],
//                     ),

//                     // Quantity indicator if available
//                     if (product.quantity != null && product.quantity! > 0)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4),
//                         child: Text(
//                           'Available: ${product.quantity} ${product.unit ?? 'units'}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ),

//                     15.heightBox,
//                     // ElevatedButton(onPressed: () {}, child: const Text('')),
//                     Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.deepOrangeAccent,
//                         borderRadius: BorderRadius.circular(1),
//                       ),
//                       child: SizedBox(
//                         height: 40,
//                         width: double.infinity,
//                         child: Obx(() {
//                           final cartController = Get.find<CartController>();
//                           final isInCart = cartController.cartItems.any(
//                             (item) => item.id == product.id,
//                           );

//                           return ElevatedButton(
//                             onPressed: () {
//                               if (isInCart) {
//                                 cartController.removeFromCart(product.id);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       '${product.name} removed from cart',
//                                     ),
//                                     backgroundColor: Colors.red,
//                                     duration: Duration(seconds: 2),
//                                   ),
//                                 );
//                               } else {
//                                 _addToCart(
//                                   product.id,
//                                   product.name,
//                                   product.firstImage,
//                                   product.price.toString(),
//                                   product.gstPercentage.toString(),
//                                   product.slug,
//                                 );
//                                 print(
//                                   'contract slulg?????????????????????????????**************: ${product.slug}',
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               backgroundColor: isInCart
//                                   ? Colors.red
//                                   : Colors.orange.shade700,
//                               padding: EdgeInsets.all(4),
//                             ),
//                             child: Text(
//                               isInCart ? 'Remove' : 'Add to Cart',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             // constraints: BoxConstraints(),
//                           );
//                         }),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductList() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_contractData == null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.grey, size: 70),
//             10.heightBox,
//             const Text(
//               'Failed to load products',
//               style: TextStyle(fontSize: 17),
//             ),
//             5.heightBox,
//             const Text(
//               'Please check your connection and try again',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//               textAlign: TextAlign.center,
//             ),
//             20.heightBox,
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange.shade700,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: _loadContractData,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_contractData!.data.isEmpty) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 70),
//           10.heightBox,
//           const Text('No Contracted Products', style: TextStyle(fontSize: 17)),
//           5.heightBox,
//           Text(
//             _searchQuery.isNotEmpty
//                 ? 'No products found for "$_searchQuery"'
//                 : 'You don\'t have any contracted products yet',
//             style: TextStyle(color: Colors.grey, fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//           20.heightBox,
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange.shade700,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: _loadContractData,
//             child: const Text('Refresh'),
//           ),
//         ],
//       );
//     }

//     return ListView.builder(
//       itemCount: _contractData!.data.length + (_hasMore ? 1 : 0),
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemBuilder: (context, index) {
//         if (index < _contractData!.data.length) {
//           return _buildProductItem(_contractData!.data[index]);
//         } else if (_hasMore) {
//           return Padding(
//             padding: const EdgeInsets.all(20),
//             child: Center(
//               child: _isLoadingMore
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _loadMoreData,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange.shade100,
//                         foregroundColor: Colors.orange.shade700,
//                       ),
//                       child: const Text('Load More Products'),
//                     ),
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: "Contracted Products".text.size(20).color(Colors.black87).make(),
//         backgroundColor: Colors.orange.shade700,
//         elevation: 0,
//         surfaceTintColor: Colors.white,
//         actions: [
//           // Add refresh button in app bar
//           IconButton(
//             onPressed: _loadContractData,
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Search and Filter Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: TextFormField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: "Search contracted products...",
//                           prefixIcon: Icon(
//                             Icons.search,
//                             color: Colors.orange.shade700,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 15,
//                           ),
//                           suffixIcon: _searchQuery.isNotEmpty
//                               ? IconButton(
//                                   icon: Icon(Icons.clear, color: Colors.grey),
//                                   onPressed: _clearSearch,
//                                 )
//                               : null,
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _searchQuery = value;
//                           });
//                           _onSearchChanged(value);
//                         },
//                         onFieldSubmitted: (value) {
//                           _performSearch();
//                         },
//                       ),
//                     ),
//                   ),
//                   10.widthBox,
//                   SizedBox(
//                     width: 140,
//                     child: InkWell(
//                       onTap: _showBottomSheetFilter,
//                       borderRadius: BorderRadius.circular(8),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade300),
//                           color: Colors.white,
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.filter_list,
//                               color: Colors.orange.shade700,
//                               size: 20,
//                             ),
//                             6.widthBox,
//                             Expanded(
//                               child: Text(
//                                 _getSelectedCategoryName(),
//                                 style: const TextStyle(
//                                   color: Colors.black87,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             4.widthBox,
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.grey.shade600,
//                               size: 20,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Product Count and Info
//             if (_contractData != null && !_isLoading)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   border: Border(
//                     top: BorderSide(color: Colors.grey[200]!),
//                     bottom: BorderSide(color: Colors.grey[200]!),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${_contractData!.total} products',
//                       style: TextStyle(
//                         color: Colors.grey[700],
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     if (_searchQuery.isNotEmpty)
//                       Chip(
//                         label: Text('"$_searchQuery"'),
//                         deleteIcon: const Icon(Icons.close, size: 14),
//                         onDeleted: _clearSearch,
//                         backgroundColor: Colors.orange[50],
//                       ),
//                   ],
//                 ),
//               ),

//             // Product List
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   await _loadContractData();
//                 },
//                 color: Colors.orange.shade700,
//                 child: _buildProductList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }
