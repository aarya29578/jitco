import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_card.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:velocity_x/velocity_x.dart';

class UniversalProductScreen extends StatefulWidget {
  final String? id;
  final String? categorySlug;
  final String? categoryName;
  final String? brandSlug;
  final String? brandName;
  final bool isBrandScreen;
  final bool autoFocusSearch;

  const UniversalProductScreen({
    super.key,
    this.id,
    this.categorySlug,
    this.categoryName,
    this.brandSlug,
    this.brandName,
    this.isBrandScreen = false,
    this.autoFocusSearch = false,
  });

  @override
  State<UniversalProductScreen> createState() => _UniversalProductScreenState();
}

class _UniversalProductScreenState extends State<UniversalProductScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _searchController = TextEditingController();
  final ApiServices _apiService = Get.find<ApiServices>();
  final ProductSearchController searchController =
      Get.find<ProductSearchController>();
  final FocusNode _focusNode = FocusNode();

  // Add a timer for debouncing search
  Timer? _searchDebounce;
  bool _isSearching = false;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    _fetchIdFromWarehouse();

    // if (widget.autoFocusSearch) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     FocusScope.of(context).requestFocus(_focusNode);
    //   });
    // }
    final bottomNavController = Get.find<BottomNavController>();
    ever(bottomNavController.shouldFocusSearch, (value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_focusNode);
        });

        bottomNavController.shouldFocusSearch.value = false;
      }
    });
    print("UniversalProductScreen initialized");
    if (widget.isBrandScreen) {
      print("Brand Slug: ${widget.brandSlug}");
      print("Brand Name: ${widget.brandName}");
    } else {
      print("Category Slug: ${widget.categorySlug}");
      print("Category Name: ${widget.categoryName}");
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _searchDebounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      searchController.clearSearch();
      return;
    }

    // Start a new timer for debouncing
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
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

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Determine what to search within
    String? categoryId;
    String? brandId;

    if (widget.isBrandScreen) {
      // Search within brand
      brandId = widget.brandSlug;
      print("Searching within brand: $brandId, query: '$query'");
    } else if (widget.id != null) {
      // Search within category
      categoryId = widget.id;
      print("Searching within category: $categoryId, query: '$query'");
    } else {
      // Search all products
      print("Searching all products, query: '$query'");
    }

    searchController.searchProducts(
      query,
      categoryId: categoryId,
      brandId: brandId,
      warehouseId: _warehouseId,
      userId: _authController.userId.value.trim(),
    );
    print(
      "UserId........????????????????????????????: '${_authController.userId.value.trim()}'",
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    searchController.clearSearch();
  }

  String _getScreenTitle() {
    if (widget.isBrandScreen) {
      return widget.brandName ?? "Brand Products";
    } else {
      return widget.categoryName ?? "All Products";
    }
  }

  String _getSubtitle() {
    if (_isSearching) {
      return "Searching for \"${_searchController.text}\"";
    } else if (widget.isBrandScreen) {
      return "Products from ${widget.brandName!}";
    } else if (widget.categoryName != null) {
      return "Products in ${widget.categoryName!}";
    } else {
      return "All available products";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        title: Text(
          _getScreenTitle(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          // if (_isSearching)
          //   IconButton(
          //     icon: Icon(Icons.clear, color: Colors.white),
          //     onPressed: _clearSearch,
          //   ),
          if (widget.isBrandScreen || widget.categoryName != null)
            CartBadgeIcon(
              isActive: true,
              activeColor: Colors.white,
              nonActiveColor: Colors.grey,
            ).onTap(() {
              // Get.to(() => BottomNavItem(initialIndex: 3));
              // final bottomNavState = context
              //     .findAncestorStateOfType<JitcoSupplyNavBarState>();
              // if (bottomNavState != null) {
              //   bottomNavState.switchToTab(
              //     3,
              //   ); // Switch to Products tab (index 2)
              // }
              Get.find<BottomNavController>().switchTab(4);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final navigator = Navigator.of(context);

                if (navigator.canPop()) {
                  navigator.pop();
                }
              });
            }),
          22.widthBox,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),

            // Subtitle Info
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Text(
            //     _getSubtitle(),
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            SizedBox(height: 8),

            // Main content
            Expanded(
              child: GetBuilder<ProductSearchController>(
                builder: (controller) {
                  final hasSearchResults =
                      controller.searchedProducts.isNotEmpty;
                  final isSearching = _isSearching || controller.isLoading;

                  if (isSearching && controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  // Show search results when searching and we have results
                  if (_isSearching && hasSearchResults) {
                    return UniversalProductCard(
                      searchQuery: _searchController.text,
                      isBrandScreen: widget.isBrandScreen,
                      productsOverride: controller.searchedProducts,
                      isSearching: true, // This is the key fix
                      key: ValueKey(
                        "search_${_searchController.text}_${DateTime.now().millisecondsSinceEpoch}",
                      ),
                      categorySlug: widget.isBrandScreen
                          ? null
                          : widget.categorySlug,
                      categoryName: widget.isBrandScreen
                          ? null
                          : widget.categoryName,
                      brandSlug: widget.isBrandScreen ? widget.brandSlug : null,
                      brandName: widget.isBrandScreen ? widget.brandName : null,
                    );
                  }

                  // Show no results message when searching but no results
                  if (_isSearching && !hasSearchResults) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.white60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products found for "${_searchController.text}"',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'in ${widget.categoryName ?? "all categories"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _clearSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.orange,
                            ),
                            child: Text('Clear Search'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Default category/brand products (no search)
                  return UniversalProductCard(
                    isBrandScreen: widget.isBrandScreen,
                    categorySlug: widget.isBrandScreen
                        ? null
                        : widget.categorySlug,
                    categoryName: widget.isBrandScreen
                        ? null
                        : widget.categoryName,
                    brandSlug: widget.isBrandScreen ? widget.brandSlug : null,
                    brandName: widget.isBrandScreen ? widget.brandName : null,
                    searchQuery: _searchController.text,
                    isSearching: false, // Make sure this is false
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
