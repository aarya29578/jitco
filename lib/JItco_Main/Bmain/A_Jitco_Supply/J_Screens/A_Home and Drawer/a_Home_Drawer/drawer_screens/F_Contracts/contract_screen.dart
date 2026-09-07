// import 'package:flutter/material.dart';
// import 'package:velocity_x/velocity_x.dart';
// //instead of enum, i want to pass the category from the category api or from categorydata model(like: CategoryData categoryName)
// enum FilterCategories { all, pending, confirmed, shipped, delivered, cancelled }
// extension OrderStatusExtension on FilterCategories {
//   String get label {
//     switch (this) {
//       case FilterCategories.all:
//         return "All";
//       case FilterCategories.pending:
//         return "Pending";
//       case FilterCategories.confirmed:
//         return "Confirmed";
//       case FilterCategories.shipped:
//         return "Shipped";
//       case FilterCategories.delivered:
//         return "Delivered";
//       case FilterCategories.cancelled:
//         return "Cancelled";
//     }
//   }
//   // Helper method to convert string to OrderStatus
//   static FilterCategories? fromString(String? status) {
//     if (status == null) return FilterCategories.all;
//     for (var value in FilterCategories.values) {
//       if (value.name == status.toLowerCase()) {
//         return value;
//       }
//     }
//     return FilterCategories.all;
//   }
// }
// class Contract extends StatefulWidget {
//   const Contract({super.key});
//   @override
//   State<Contract> createState() => _ContractState();
// }
// class _ContractState extends State<Contract> {
//   final TextEditingController _searchController = TextEditingController();
//   FilterCategories? selectedStatus = FilterCategories.all;
//   bool _isSearching = false;
//   void _clearSearch() {
//     _searchController.clear();
//     setState(() {
//       _isSearching = false;
//     });
//     // searchController.clearSearch();
//   }
//   void _onSearchChanged(String value) {}
//   void _showBottomSheetFilter() {
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
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     "Filter Categories".text
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
//                 "Order Status".text.size(16).fontWeight(FontWeight.w500).make(),
//                 10.heightBox,
//                 ...FilterCategories.values.map((status) {
//                   return ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     leading: Radio<FilterCategories>(
//                       value: status,
//                       groupValue: selectedStatus,
//                       onChanged: (FilterCategories? value) {
//                         setState(() {
//                           selectedStatus = value;
//                         });
//                         Navigator.pop(context);
//                       },
//                       activeColor: Colors.orange.shade700,
//                     ),
//                     title: Text(status.label),
//                     onTap: () {
//                       setState(() {
//                         selectedStatus = status;
//                       });
//                       Navigator.pop(context);
//                     },
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: Text('Contracted Products')),
//       appBar: AppBar(
//         title: "Contracted Products".text.size(20).color(Colors.black87).make(),
//         backgroundColor: Colors.orange.shade700,
//         elevation: 0,
//         surfaceTintColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
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
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: TextFormField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: "Search...",
//                           prefixIcon: Icon(Icons.search, color: Colors.orange),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 15,
//                           ),
//                           suffixIcon: _isSearching
//                               ? IconButton(
//                                   icon: Icon(Icons.clear, color: Colors.grey),
//                                   onPressed: _clearSearch,
//                                 )
//                               : null,
//                         ),
//                         onChanged: _onSearchChanged,
//                       ),
//                     ),
//                   ),
//                   10.widthBox,
//                   SizedBox(
//                     width: 140,
//                     child: InkWell(
//                       onTap: _showBottomSheetFilter, // or use _showFilterDialog
//                       borderRadius: BorderRadius.circular(8),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade300),
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
//                                 selectedStatus!.label,
//                                 style: TextStyle(
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
//             Expanded(
//               child: Column(
//                 // crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.grey, size: 70),
//                   10.heightBox,
//                   const Text(
//                     'No Products available',
//                     style: TextStyle(fontSize: 17),
//                   ),
//                   5.heightBox,
//                   const Text(
//                     'Check back later for new arrivals',
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                   20.heightBox,
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange.shade700,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadiusGeometry.circular(8),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: const Text('Refresh Page'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// contract.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/PostModel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/contract_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/B_Your_Enquiries/enquires_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  late ApiServices _apiService;

  // State variables
  PostModel? _categories;
  ContractModel? _contractData;
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _selectedCategoryId = 'all';
  String _searchQuery = '';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    // _fetchIdFromWarehouse();
    _initializeServices();
    // _loadContractData();
  }

  void _addToCart(
    String productId,
    String productName,
    productImage,
    String productPrice,
    String productGst,
    String productSlug,
    // dynamic product,
  ) {
    final CartController cartController = Get.find<CartController>();

    final cartItem = CartItem(
      id: productId,
      name: productName,
      image: productImage,
      price: double.tryParse(productPrice) ?? 0.0,
      gstPercentage: double.tryParse(productGst) ?? 0.0,
      quantity: 1,
      categorySlug: productSlug,
      selectedVariant: '1 pc.', // Default variant
    );

    cartController.addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName added to cart'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
          limit: 10, // Increased limit to find the best match
          encodedCity: cityName,
        );

        // 5. Process warehouse response
        print('📊 Warehouse API response: ${result}');

        if (result['data'] != null) {
          List warehouses = [];
          if (result['data'] is List) {
            warehouses = result['data'] as List;
          } else if (result['data'] is Map) {
            warehouses = [result['data']];
          }

          if (warehouses.isNotEmpty) {
            dynamic selectedWarehouse;
            
            // Try to find exact name match or best match
            print('🏗️ Searching through ${warehouses.length} warehouses for best match for "$cityName"...');
            for (var w in warehouses) {
              final wName = w['name']?.toString() ?? '';
              final wId = w['_id']?.toString() ?? '';
              print('   - Checking Warehouse: "$wName" (ID: $wId)');
              
              if (wName.toLowerCase().contains(cityName.toLowerCase())) {
                selectedWarehouse = w;
                print('   ✅ Match found: "$wName"');
                break;
              }
            }

            // Fallback to first if no name match
            if (selectedWarehouse == null) {
              selectedWarehouse = warehouses[0];
              print('   ⚠️ No direct name match, falling back to first result: "${selectedWarehouse['name']}"');
            }

            final warehouseId = selectedWarehouse['_id']?.toString();
            print('🏭 SELECTED WAREHOUSE ID: $warehouseId');

            if (warehouseId != null) {
              // Store the warehouse ID
              setState(() {
                _warehouseId = warehouseId;
                cityWarehouse = OutletModel.fromJson(selectedWarehouse);
              });
              print('✅ Warehouse model created with ID: ${cityWarehouse!.id}');
            }
          } else {
            print('❌ No warehouses found for city: $cityName');
          }
        } else {
          print('❌ No data in warehouse response');
        }
      } else {
        print('❌ Failed to fetch outlets: ${outletResponse['message']}');
      }
    } catch (e) {
      print('❌ Error in _fetchIdFromWarehouse: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      print('🏁 END: _fetchIdFromWarehouse() completed');
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Get the initialized ApiService from GetX
      _apiService = Get.find<ApiServices>();
      print('✅ ApiService loaded successfully');
      await _loadInitialData();
    } catch (e) {
      print('❌ Error initializing services: $e');
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to initialize services. Please restart the app.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      setState(() {
        _isLoading = false;
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // 1️⃣ MUST complete first
      await _fetchIdFromWarehouse();

      // 2️⃣ These can run in parallel
      await Future.wait([_loadCategories(), _loadContractData()]);
    } catch (e) {
      print('❌ Error loading initial data: $e');
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      print('📡 Loading categories...');
      final categories = await _apiService.fetchProductCategories(
        page: 1,
        limit: 200,
      );
      print('✅ Categories loaded: ${categories.data?.length ?? 0} items');
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('❌ Error loading categories: $e');
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Future<void> _loadContractData({bool loadMore = false}) async {
  //   try {
  //     if (!loadMore) {
  //       setState(() {
  //         _isLoading = true;
  //         _currentPage = 1;
  //       });
  //     } else {
  //       setState(() {
  //         _isLoadingMore = true;
  //       });
  //     }

  //     print('📡 Loading contract data (page: $_currentPage)...');

  //     final contractData = await _apiService.getContractData(
  //       page: _currentPage,
  //       limit: _itemsPerPage,
  //       categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
  //       search: _searchQuery.isNotEmpty ? _searchQuery : null,
  //       warehouseId: _warehouseId,
  //     );

  //     print('✅ Contract data loaded: ${contractData.data.length} items');
  //     print('📊 Total items: ${contractData.total}');

  //     setState(() {
  //       if (loadMore && _contractData != null) {
  //         // Append new data
  //         _contractData = ContractModel(
  //           success: contractData.success,
  //           total: contractData.total,
  //           page: contractData.page,
  //           limit: contractData.limit,
  //           totalPages: contractData.totalPages,
  //           data: [..._contractData!.data, ...contractData.data],
  //         );
  //       } else {
  //         // Replace with new data
  //         _contractData = contractData;
  //       }

  //       // Check if there are more pages
  //       _hasMore = _currentPage < contractData.totalPages;
  //       _isLoadingMore = false;
  //     });
  //   } catch (e) {
  //     print('❌ Error loading contract data: $e');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to load products: ${e.toString()}',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     setState(() {
  //       _isLoading = false;
  //       _isLoadingMore = false;
  //     });
  //   } finally {
  //     if (!loadMore) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _loadContractData({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _currentPage = 1;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      print('📡 Loading contract data (page: $_currentPage)...');

      ContractModel contractData;

      // DECIDE WHICH API TO USE:
      if (_searchQuery.isNotEmpty) {
        // USE SEARCH API for searching
        print('🔍 Using SEARCH API for query: "$_searchQuery"');

        contractData = await _apiService.searchContractProducts(
          query: _searchQuery,
          categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
          page: _currentPage,
          limit: _itemsPerPage,
          warehouseId: _warehouseId,
        );
      } else {
        // USE getContractData for browsing
        print('📦 Using getContractData API for browsing');

        contractData = await _apiService.getContractData(
          page: _currentPage,
          limit: _itemsPerPage,
          categoryId: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
          search: null,
          warehouseId: _warehouseId,
        );
      }

      print('✅ Contract data loaded: ${contractData.data.length} items');
      print('📊 Total items: ${contractData.total}');
      print('📊 Success: ${contractData.success}');
      print('📊 Page: ${contractData.page}/${contractData.totalPages}');

      setState(() {
        if (loadMore && _contractData != null) {
          // Append new data
          _contractData = ContractModel(
            success: contractData.success,
            total: contractData.total,
            page: contractData.page,
            limit: contractData.limit,
            totalPages: contractData.totalPages,
            data: [..._contractData!.data, ...contractData.data],
          );
        } else {
          // Replace with new data
          _contractData = contractData;
        }

        // Check if there are more pages
        _hasMore = _currentPage < contractData.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      print('❌ Error loading contract data: $e');

      // Handle specific errors
      String errorMessage = 'Failed to load products';
      if (e.toString().contains('Query parameter is required')) {
        errorMessage = 'Please enter a search term';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    } finally {
      if (!loadMore) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    print('📡 Loading more data (page: ${_currentPage + 1})...');
    setState(() {
      _currentPage++;
    });

    await _loadContractData(loadMore: true);
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    // Only search if query is empty (clear search)
    if (_searchQuery.isEmpty) {
      _performSearch();
    }
  }

  void _performSearch() {
    // Debounce search - wait 500ms before searching
    Future.delayed(const Duration(milliseconds: 500), () {
      print('🔍 Performing search: "$_searchQuery"');
      _loadContractData();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    print('🧹 Search cleared');
    _loadContractData();
  }

  void _showBottomSheetFilter() {
    if (_isLoadingCategories) return;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Filter by Category".text
                        .size(20)
                        .fontWeight(FontWeight.bold)
                        .make(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300]),
                10.heightBox,
                Expanded(
                  child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            // "All" option
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Radio<String>(
                                value: 'all',
                                groupValue: _selectedCategoryId,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                  Navigator.pop(context);
                                  print('🎯 Selected: All Categories');
                                  _loadContractData();
                                },
                                activeColor: Colors.orange.shade700,
                              ),
                              title: const Text('All Categories'),
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = 'all';
                                });
                                Navigator.pop(context);
                                print('🎯 Selected: All Categories');
                                _loadContractData();
                              },
                            ),
                            // Category options
                            ...(_categories?.data ?? [])
                                .where(
                                  (category) =>
                                      category.show == true &&
                                      category.isActive == true,
                                )
                                .map((category) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Radio<String>(
                                      value: category.id ?? '',
                                      groupValue: _selectedCategoryId,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedCategoryId = value;
                                        });
                                        Navigator.pop(context);
                                        print(
                                          '🎯 Selected: ${category.categoryName}',
                                        );
                                        _loadContractData();
                                      },
                                      activeColor: Colors.orange.shade700,
                                    ),
                                    title: Text(
                                      category.categoryName ??
                                          'Unnamed Category',
                                    ),
                                    subtitle:
                                        category.description?.isNotEmpty == true
                                        ? Text(
                                            category.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = category.id;
                                      });
                                      Navigator.pop(context);
                                      print(
                                        '🎯 Selected: ${category.categoryName}',
                                      );
                                      _loadContractData();
                                    },
                                  );
                                })
                                .toList(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSelectedCategoryName() {
    if (_selectedCategoryId == 'all') {
      return 'All Categories';
    }

    if (_categories == null || _categories!.data == null) {
      return 'Select Category';
    }

    final category = _categories!.data!.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () => CategoryData(),
    );

    return category.categoryName ?? 'Select Category';
  }

  Widget _buildProductItem(ContractProduct product) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      // surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Navigate to product details if needed
          print('📱 Tapped product: ${product.name}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child:
                    product.firstImage != null && product.firstImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.firstImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.shopping_bag,
                              color: Colors.orange.shade700,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.shopping_bag,
                        color: Colors.orange.shade700,
                        size: 40,
                      ),
              ),
              12.widthBox,

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.heightBox,

                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    6.heightBox,

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 11,
                              color: product.inStock
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    6.heightBox,

                    if (product.price != 0) ...[
                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          8.widthBox,
                          if (product.unit != null)
                            Text(
                              '/${product.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          const Spacer(),
                          // if (product.brand != null && product.brand!.isNotEmpty)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 6,
                          //       vertical: 2,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: Colors.blue[50],
                          //       borderRadius: BorderRadius.circular(4),
                          //     ),
                          //     child: Text(
                          //       product.brand!,
                          //       style: TextStyle(
                          //         fontSize: 11,
                          //         color: Colors.blue[700],
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                        ],
                      ),
                    ],

                    // Quantity indicator if available
                    if (product.quantity != null && product.quantity! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Available: ${product.quantity} ${product.unit ?? 'units'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                    15.heightBox,
                    // ElevatedButton(onPressed: () {}, child: const Text('')),
                    Container(
                      decoration: BoxDecoration(
                        // color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: product.price != 0
                            ? Obx(() {
                                final cartController =
                                    Get.find<CartController>();
                                final isInCart = cartController.cartItems.any(
                                  (item) => item.id == product.id,
                                );

                                return ElevatedButton(
                                  onPressed: () {
                                    if (isInCart) {
                                      cartController.removeFromCart(product.id);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.name} removed from cart',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      _addToCart(
                                        product.id,
                                        product.name,
                                        product.firstImage,
                                        product.price.toString(),
                                        product.gstPercentage.toString(),
                                        product.slug,
                                      );
                                      print(
                                        'contract slulg?????????????????????????????**************: ${product.slug}',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: isInCart
                                        ? Colors.red
                                        : Colors.orange.shade700,
                                    padding: EdgeInsets.all(4),
                                  ),
                                  child: Text(
                                    isInCart ? 'Remove' : 'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  // constraints: BoxConstraints(),
                                );
                              })
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                                child: SizedBox(
                                  height: 35,
                                  width: 70,
                                  child: Obx(() {
                                    final enquiryController =
                                        Get.find<EnquiryController>();
                                    final isInEnquiry = enquiryController
                                        .enquiryItems
                                        .any(
                                          (enquiry) =>
                                              enquiry.productId == product.id,
                                        );

                                    return TextButton(
                                      onPressed: () async {
                                        if (isInEnquiry) {
                                          // Navigate to enquiry screen
                                          Get.to(() => EnquiresScreen());
                                        } else {
                                          // Show quantity dialog and create enquiry
                                          _showEnquiryDialog(context, product);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: isInEnquiry
                                            ? Colors.blue.shade200
                                            : Colors.blue.shade500,
                                        padding: EdgeInsets.all(4),
                                      ),
                                      child: Text(
                                        isInEnquiry
                                            ? 'View Enquire'
                                            : 'Enquire Now',
                                        style: TextStyle(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnquiryDialog(BuildContext context, dynamic product) {
    final RxInt quantity = 1.obs;
    final TextEditingController controller = TextEditingController(text: '1');
    final TextEditingController commentController = TextEditingController();

    // Sync controller with RxInt
    ever(quantity, (value) {
      if (controller.text != value.toString()) {
        controller.text = value.toString();
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });

    showDialog(
      // barrierColor: Colors.transparent,
      //To prevent the dialog from closing when tapping outside
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Enquire for ${product.name}'),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set quantity:'),
                const SizedBox(height: 10),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: controller,
                            cursorColor: Colors.orange.shade700,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              final q = int.tryParse(value) ?? 1;
                              quantity.value = q < 1 ? 1 : q;
                            },
                          ),
                        ),
                      ),
                      20.heightBox,

                      const Text('Notes(Optional):'),
                      const SizedBox(height: 10),

                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Additional comments...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.orange.shade700,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createEnquiry(
                  product.id,
                  quantity.value,
                  commentController.text.trim(),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange.shade700,
              ),
              child: const Text('Submit Enquiry'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEnquiry(
    String productId,
    int quantity,
    String? comments,
  ) async {
    try {
      final enquiryController = Get.find<EnquiryController>();
      await enquiryController.createEnquiry(
        context,
        productId,
        quantity,
        comments,
      );
    } catch (e) {
      print('Error creating enquiry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create enquiry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contractData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey, size: 70),
            10.heightBox,
            const Text(
              'Failed to load products',
              style: TextStyle(fontSize: 17),
            ),
            5.heightBox,
            const Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            20.heightBox,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _loadContractData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_contractData!.data.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 70),
          10.heightBox,
          const Text('No Contracted Products', style: TextStyle(fontSize: 17)),
          5.heightBox,
          Text(
            _searchQuery.isNotEmpty
                ? 'No products found for "$_searchQuery"'
                : 'You don\'t have any contracted products yet',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          20.heightBox,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _loadContractData,
            child: const Text('Refresh'),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _contractData!.data.length + (_hasMore ? 1 : 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < _contractData!.data.length) {
          return _buildProductItem(_contractData!.data[index]);
        } else if (_hasMore) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _loadMoreData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: Colors.orange.shade700,
                      ),
                      child: const Text('Load More Products'),
                    ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Contracted Products".text.size(20).color(Colors.black87).make(),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          // Add refresh button in app bar
          IconButton(
            onPressed: _loadContractData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search contracted products...",
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.orange.shade700,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: _clearSearch,
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _onSearchChanged(value);
                        },
                        onFieldSubmitted: (value) {
                          _performSearch();
                        },
                      ),
                    ),
                  ),
                  10.widthBox,
                  SizedBox(
                    width: 140,
                    child: InkWell(
                      onTap: _showBottomSheetFilter,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            6.widthBox,
                            Expanded(
                              child: Text(
                                _getSelectedCategoryName(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            4.widthBox,
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Count and Info
            if (_contractData != null && !_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_contractData!.total} products',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text('"$_searchQuery"'),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: _clearSearch,
                        backgroundColor: Colors.orange[50],
                      ),
                  ],
                ),
              ),

            // Product List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadContractData();
                },
                color: Colors.orange.shade700,
                child: _buildProductList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
