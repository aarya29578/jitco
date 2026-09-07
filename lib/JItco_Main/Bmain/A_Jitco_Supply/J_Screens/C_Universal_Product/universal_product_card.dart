import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/auth_models.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/cart_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/B_Your_Enquiries/enquires_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class UniversalProductCard extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;
  final String? brandSlug;
  final String? brandName;
  final String searchQuery;
  final bool isPerishable;
  final bool isBrandScreen;
  final List<dynamic>? productsOverride;
  final bool isSearching;

  const UniversalProductCard({
    super.key,
    this.categorySlug,
    this.categoryName,
    this.brandSlug,
    this.brandName,
    this.searchQuery = "",
    this.isPerishable = false,
    this.isBrandScreen = false,
    this.productsOverride,
    this.isSearching = false, // Add this flag
  });

  @override
  State<UniversalProductCard> createState() => _UniversalProductCardState();

  void updateSearch(result) {}
}

class _UniversalProductCardState extends State<UniversalProductCard> {
  final ApiServices _apiService = Get.find<ApiServices>();
  final AuthController _authController = Get.find<AuthController>();

  List<dynamic> products = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int _currentPage = 1;
  static const int _limit = 20;
  int _totalPages = 1;
  int _totalProducts = 0;
  bool hasMore = true;
  bool isLoadingMore = false;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _debugContractStatus();
    print("ProductCart initialized");
    print("Category Slug: ${widget.categorySlug}");
    print("Category Name: ${widget.categoryName}");
    print("Brand Slug: ${widget.brandSlug}");
    print("Brand Name: ${widget.brandName}");
    print("Is Brand Screen: ${widget.isBrandScreen}");
    print("Is Perishable: ${widget.isPerishable}");
    print("Is Searching: ${widget.isSearching}");
    print("Products Override: ${widget.productsOverride?.length ?? 0}");

    // If we have search results, use them directly
    if (widget.isSearching && widget.productsOverride != null) {
      print("Using search results directly");
      products = widget.productsOverride!;
      isLoading = false;
      _totalProducts = products.length;
      _totalPages = 1;
      hasMore = false;
    } else {
      // Delay fetch to ensure auth is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchIdFromWarehouse();
        await _fetchProducts();
        printContractDebugInfo();
      });
      // Also listen for contract changes
      ever(_authController.hasContract, (hasContract) {
        print('CONTRACT STATUS CHANGED: $hasContract');
        if (mounted) {
          setState(() {});
        }
      });
    }

    _scrollController.addListener(_onScroll);
  }

  void printContractDebugInfo() {
    print('=== CONTRACT DEBUG INFO ===');
    print('Auth Controller hasContract: ${_authController.hasContract.value}');
    print(
      'Auth Controller contractExpireDate: ${_authController.contractExpireDate.value}',
    );
    print('Auth Controller isLoggedIn: ${_authController.isLoggedIn.value}');
    print('Auth Controller companyId: ${_authController.companyId.value}');
    print('===========================');
  }

  @override
  void didUpdateWidget(UniversalProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if search state changed
    if (oldWidget.isSearching != widget.isSearching ||
        oldWidget.productsOverride != widget.productsOverride ||
        oldWidget.searchQuery != widget.searchQuery) {
      print("Search state changed - isSearching: ${widget.isSearching}");
      print("Search results count: ${widget.productsOverride?.length ?? 0}");

      if (widget.isSearching && widget.productsOverride != null) {
        print("Switching to search results");
        setState(() {
          products = widget.productsOverride!;
          isLoading = false;
          _totalProducts = products.length;
          _totalPages = 1;
          hasMore = false;
        });
      } else if (!widget.isSearching) {
        print("Switching back to category products");
        _resetAndFetchProducts();
      }
    }
    // Only reset for category/brand changes when not searching
    else if (!widget.isSearching &&
        (oldWidget.categorySlug != widget.categorySlug ||
            oldWidget.brandSlug != widget.brandSlug ||
            oldWidget.isPerishable != widget.isPerishable ||
            oldWidget.isBrandScreen != widget.isBrandScreen)) {
      print("Parameters changed - Resetting...");
      _resetAndFetchProducts();
    }
  }

  void _onScroll() {
    // Don't load more when searching
    if (widget.isSearching) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoadingMore) {
        _loadMoreProducts();
      }
    }
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

  Future<void> _fetchProducts({bool isLoadMore = false}) async {
    // Don't fetch if we're in search mode
    if (widget.isSearching) return;

    if (!isLoadMore) {
      setState(() {
        isLoading = true;
        hasError = false;
        _currentPage = 1;
      });
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      Map<String, dynamic> result;
      List<dynamic> newProducts = [];
      int totalProducts = 0;
      int totalPages = 1;

      if (widget.isPerishable) {
        // Fetch perishable products
        print("Fetching PERISHABLE products with slug: ${widget.categorySlug}");
        result = await _apiService.fetchPerishables(
          homeProductSlug: widget.categorySlug,
          page: _currentPage,
          limit: _limit,
          search: widget.searchQuery,
          warehouseId: _warehouseId,
          userId: _authController.userId.value,
        );

        newProducts = result['products'] ?? [];
        totalProducts = result['totalProducts'] ?? 0;
        totalPages = result['totalPages'] ?? 1;

        print(
          "Perishable API Success - Products: ${newProducts.length}, Total: $totalProducts",
        );
      } else if (widget.isBrandScreen &&
          widget.brandSlug != null &&
          widget.brandSlug!.isNotEmpty) {
        // Fetch products by brand
        print("Fetching products BY BRAND: ${widget.brandSlug}");
        result = await _apiService.fetchProductsByBrand(
          brandSlug: widget.brandSlug!,
          page: _currentPage,
          limit: _limit,
          warehouseId: _warehouseId,
          userId: _authController.userId.value,
        );

        newProducts = result['products'] ?? [];
        totalProducts = result['totalProducts'] ?? 0;
        totalPages = result['totalPages'] ?? 1;

        print(
          "Brand API Success - Products: ${newProducts.length}, Total: $totalProducts",
        );
      } else if (widget.categorySlug != null &&
          widget.categorySlug!.isNotEmpty) {
        // Fetch products by category
        print("Fetching products BY CATEGORY: ${widget.categorySlug}");
        result = await _apiService.fetchProductsByCategory(
          categorySlug: widget.categorySlug!,
          page: _currentPage,
          limit: _limit,
          warehouseId: _warehouseId,
          userId: _authController.userId.value,
        );

        newProducts = result['products'] ?? [];
        totalProducts = result['totalProducts'] ?? 0;
        totalPages = result['totalPages'] ?? 1;

        print(
          "Category API Success - Products: ${newProducts.length}, Total: $totalProducts",
        );
      } else {
        // Fetch ALL products
        print("Fetching ALL products");
        result = await _apiService.fetchAllProducts(
          page: _currentPage,
          limit: _limit,
          // search: widget.searchQuery,
          warehouseId: _warehouseId,
          userId: _authController.userId.value,
        );

        newProducts = result['products'] ?? [];
        totalProducts = result['totalProducts'] ?? 0;
        totalPages = result['totalPages'] ?? 1;

        print(
          "All Products API Success - Products: ${newProducts.length}, Total: $totalProducts",
        );
      }

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            products.addAll(newProducts);
            print(
              "Added ${newProducts.length} more products. Total now: ${products.length}",
            );
          } else {
            products = newProducts;
            print("Loaded ${products.length} products");
          }

          _totalProducts = totalProducts;
          _totalPages = totalPages;
          hasMore = _currentPage < _totalPages;

          isLoading = false;
          isLoadingMore = false;
        });
      }

      print(
        "Final State - Total products: $_totalProducts, Pages: $_totalPages, Displaying: ${products.length}",
      );
    } catch (e) {
      print("Error fetching products: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  void _resetAndFetchProducts() {
    print("Resetting and fetching products...");
    _currentPage = 1;
    products.clear();
    _totalProducts = 0;
    _fetchProducts();
  }

  void _loadMoreProducts() {
    if (hasMore && !isLoadingMore && !widget.isSearching) {
      print("Loading more products...");
      _currentPage++;
      _fetchProducts(isLoadMore: true);
    }
  }

  void _addToCart(
    String productId,
    String productName,
    String categorySlug,
    dynamic product,
  ) {
    final CartController cartController = Get.find<CartController>();
    final hasContract = _authController.hasContract.value;

    final cartItem = CartItem(
      id: productId,
      name: productName,
      image: _getProductImage(product),
      price: getProductPrice(product) ?? 0.0,
      gstPercentage: double.tryParse(_getProductGST(product)) ?? 0.0,
      quantity: 1,
      categorySlug: categorySlug,
      selectedVariant: '1 pc.',
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

  // Add this method to your UniversalProductCart
  void _debugContractStatus() {
    print('=== CONTRACT STATUS DEBUG ===');
    print('hasContract.value: ${_authController.hasContract.value}');
    print('contractExpireDate: ${_authController.contractExpireDate.value}');
    print('isLoggedIn: ${_authController.isLoggedIn.value}');
    print('companyId: ${_authController.companyId.value}');
    print('authToken exists: ${_authController.authToken.value.isNotEmpty}');

    // Also check if contract fields exist in product data
    if (products.isNotEmpty) {
      final firstProduct = products[0];
      print('First Product Contract Fields:');
      print('  contractPrice: ${firstProduct['contractPrice']}');
      print('  boxPrice: ${firstProduct['boxPrice']}');
      print('  universalPrice: ${firstProduct['universalPrice']}');
      print('  soldAsBox: ${firstProduct['soldAsBox']}');
    }
    print('================================');
  }

  String _getProductName(dynamic product) {
    return product['productName'] ?? 'Unknown Product';
  }

  String _getProductImage(dynamic product) {
    if (product['productImage'] != null &&
        product['productImage'] is List &&
        product['productImage'].isNotEmpty) {
      return product['productImage'][0];
    }
    return '';
  }

  String _getProductPrice(dynamic product) {
    return product['universalPrice']?.toString() ??
        product['mrp']?.toString() ??
        '0';
  }

  double? getProductPrice(dynamic product) {
    print('CALCULATING PRICE FOR: ${product['productName']}');

    final double contractPrice = (product['contractPrice'] ?? 0).toDouble();
    final double boxPrice = (product['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (product['universalPrice'] ?? 0).toDouble();
    final int quantityPerBox = product['quantityPerBox'] ?? 1;

    final bool soldAsBox = product['soldAsBox'] == true;

    print('   soldAsBox: $soldAsBox');
    print('   contractPrice: $contractPrice');
    print('   boxPrice: $boxPrice');
    print('   universalPrice: $universalPrice');
    print('   quantityPerBox: $quantityPerBox');

    if (soldAsBox) {
      if (contractPrice > 0) {
        final price = contractPrice * quantityPerBox;
        print('USING CONTRACT BOX PRICE: $price');
        return price;
      }

      if (boxPrice > 0) {
        print('USING BOX PRICE: $boxPrice');
        return boxPrice;
      }

      if (universalPrice > 0) {
        print('USING UNIVERSAL PRICE (BOX): $universalPrice');
        return universalPrice;
      }

      print('NO PRICE FOUND (BOX)');
      return null;
    } else {
      if (contractPrice > 0) {
        print('USING CONTRACT SINGLE PRICE: $contractPrice');
        return contractPrice;
      }

      if (universalPrice > 0) {
        print('USING UNIVERSAL SINGLE PRICE: $universalPrice');
        return universalPrice;
      }

      print('NO PRICE FOUND (SINGLE)');
      return null;
    }
  }

  String _getProductGST(dynamic product) {
    print(
      'GST****************************************************: ${product['gstPercentage']?.toString() ?? '0'}',
    );
    return product['gstPercentage']?.toString() ?? '0';
  }

  String _getHeaderTitle() {
    if (widget.isSearching) {
      return 'Search Results';
    } else if (widget.isPerishable) {
      return 'Perishable Products';
    } else if (widget.isBrandScreen) {
      return widget.brandName ?? 'Brand Products';
    } else if (widget.categorySlug != null) {
      return widget.categoryName ?? 'Category Products';
    } else {
      return 'All Products';
    }
  }

  String _getEmptyStateMessage() {
    if (widget.isSearching) {
      return 'No products found for "${widget.searchQuery}"';
    } else if (widget.isPerishable) {
      return 'No perishable products found';
    } else if (widget.isBrandScreen) {
      return 'No products found for this brand';
    } else {
      return 'No products found';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && !widget.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.grey[200]),
            SizedBox(height: 16),
            Text(
              _getLoadingMessage(),
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (hasError && !widget.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 50),
            SizedBox(height: 16),
            // Text(
            //   'Error loading products',
            //   style: TextStyle(color: Colors.white, fontSize: 16),
            // ),
            Text(
              'Check Your Internet Connection',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            // SizedBox(height: 8),
            // Text(
            //   errorMessage,
            //   style: TextStyle(color: Colors.white70, fontSize: 12),
            //   textAlign: TextAlign.center,
            // ),
            // SizedBox(height: 8),
            // Text(
            //   'Check Your Internet Connection',
            //   style: TextStyle(color: Colors.white70, fontSize: 12),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetAndFetchProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.white60),
            SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (widget.isSearching && widget.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'in ${widget.categoryName ?? "all categories"}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            if (!widget.isSearching &&
                widget.brandName != null &&
                widget.isBrandScreen)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'from ${widget.brandName}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            if (!widget.isSearching &&
                widget.categoryName != null &&
                !widget.isBrandScreen)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'in ${widget.categoryName}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            SizedBox(height: 16),
            if (!widget.isSearching)
              ElevatedButton(
                onPressed: _resetAndFetchProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                ),
                child: Text('Refresh'),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with product info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 180,
                      child: Text(
                        _getHeaderTitle(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.isSearching
                        ? 'Found (${products.length})'
                        : 'Total Products ($_totalProducts)',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              if (widget.isSearching && widget.searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Searching for "${widget.searchQuery}" in ${widget.categoryName ?? "all categories"}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),

        // Products Grid
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                _onScroll();
              }
              return false;
            },
            child: GridView.builder(
              controller: _scrollController,
              itemCount:
                  products.length +
                  (isLoadingMore && !widget.isSearching ? 1 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.60,
              ),
              itemBuilder: (context, index) {
                // Show loading indicator only when not searching
                if (index == products.length &&
                    isLoadingMore &&
                    !widget.isSearching) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Loading more...',
                            style: TextStyle(
                              color: Colors.grey[200],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final product = products[index];
                final productImage = _getProductImage(product);
                final productName = _getProductName(product);
                final productPrice = _getProductPrice(product);
                // final double productPrice2 = getProductPrice(product);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            height: 145,
                            width: double.infinity,
                            color: Colors.grey[100],
                            child: productImage.isNotEmpty
                                ? Image.network(
                                    productImage,
                                    height: 100,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 40,
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              if (product['universalPrice'] != 0) ...[
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() {
                                        final hasContract =
                                            _authController.hasContract.value;
                                        final double price =
                                            getProductPrice(product) ?? 0.0;
                                        return Flexible(
                                          child: AutoSizeText(
                                            '₹${price}',
                                            maxLines: 1,
                                            minFontSize: 10,
                                            maxFontSize: 30,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        );
                                      }),
                                      5.widthBox,
                                      //add to cart
                                      Container(
                                        decoration: BoxDecoration(
                                          // color: Colors.deepOrangeAccent,
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 35,
                                          width: 70,
                                          child: Obx(() {
                                            final cartController =
                                                Get.find<CartController>();
                                            final isInCart = cartController
                                                .cartItems
                                                .any(
                                                  (item) =>
                                                      item.id == product['_id'],
                                                );

                                            return IconButton(
                                              onPressed: () {
                                                if (isInCart) {
                                                  cartController.removeFromCart(
                                                    product['_id'] ?? '',
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${productName} removed from cart',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      duration: Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  _addToCart(
                                                    product['_id'] ?? '',
                                                    productName,
                                                    product['slug'] ?? '',
                                                    product,
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                isInCart
                                                    ? Icons.remove_shopping_cart
                                                    : Icons.add_shopping_cart,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              style: IconButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: isInCart
                                                    ? Colors.red
                                                    : Colors.orange.shade700,
                                                padding: EdgeInsets.all(4),
                                              ),
                                              constraints: BoxConstraints(),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // if (product['universalPrice'] == 0) ...[
                              //   Container(
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       // color: Colors.deepOrangeAccent,
                              //       borderRadius: BorderRadius.circular(1),
                              //     ),
                              //     child: SizedBox(
                              //       height: 35,
                              //       width: 70,
                              //       child: Obx(() {
                              //         final cartController =
                              //             Get.find<CartController>();
                              //         final isInCart = cartController.cartItems
                              //             .any(
                              //               (item) => item.id == product['_id'],
                              //             );
                              //         return IconButton(
                              //           onPressed: () {
                              //             if (isInCart) {
                              //               cartController.removeFromCart(
                              //                 product['_id'] ?? '',
                              //               );
                              //               ScaffoldMessenger.of(
                              //                 context,
                              //               ).showSnackBar(
                              //                 SnackBar(
                              //                   content: Text(
                              //                     '${productName} removed from cart',
                              //                   ),
                              //                   backgroundColor: Colors.red,
                              //                   duration: Duration(seconds: 2),
                              //                 ),
                              //               );
                              //             } else {
                              //               _addToCart(
                              //                 product['_id'] ?? '',
                              //                 productName,
                              //                 product['slug'] ?? '',
                              //                 product,
                              //               );
                              //             }
                              //           },
                              //           icon: Text(
                              //             isInCart
                              //                 ? 'View Enquire'
                              //                 : 'Enquire Now',
                              //             style: TextStyle(color: Colors.white),
                              //             maxLines: 1,
                              //             overflow: TextOverflow.ellipsis,
                              //           ),
                              //           style: IconButton.styleFrom(
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(
                              //                 10,
                              //               ),
                              //             ),
                              //             backgroundColor:
                              //                 Colors.orange.shade700,
                              //             padding: EdgeInsets.all(4),
                              //           ),
                              //           constraints: BoxConstraints(),
                              //         );
                              //       }),
                              //     ),
                              //   ),
                              // ],
                              if (product['universalPrice'] == 0) ...[
                                Container(
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
                                                enquiry.productId ==
                                                product['_id'],
                                          );

                                      return TextButton(
                                        onPressed: () async {
                                          if (isInEnquiry) {
                                            // Navigate to enquiry screen
                                            Get.to(() => EnquiresScreen());
                                          } else {
                                            // Show quantity dialog and create enquiry
                                            _showEnquiryDialog(
                                              context,
                                              product,
                                            );
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
                              ],
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     AutoSizeText(
                              //       '₹$productPrice',
                              //       maxLines: 1,
                              //       minFontSize: 10,
                              //       maxFontSize: 30,
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.deepOrange,
                              //       ),
                              //     ),
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         // color: Colors.deepOrangeAccent,
                              //         borderRadius: BorderRadius.circular(1),
                              //       ),
                              //       child: SizedBox(
                              //         height: 35,
                              //         width: 70,
                              //         child: Obx(() {
                              //           final cartController =
                              //               Get.find<CartController>();
                              //           final isInCart = cartController
                              //               .cartItems
                              //               .any(
                              //                 (item) =>
                              //                     item.id == product['_id'],
                              //               );
                              //           return IconButton(
                              //             onPressed: () {
                              //               if (isInCart) {
                              //                 cartController.removeFromCart(
                              //                   product['_id'] ?? '',
                              //                 );
                              //                 ScaffoldMessenger.of(
                              //                   context,
                              //                 ).showSnackBar(
                              //                   SnackBar(
                              //                     content: Text(
                              //                       '${productName} removed from cart',
                              //                     ),
                              //                     backgroundColor: Colors.red,
                              //                     duration: Duration(
                              //                       seconds: 2,
                              //                     ),
                              //                   ),
                              //                 );
                              //               } else {
                              //                 _addToCart(
                              //                   product['_id'] ?? '',
                              //                   productName,
                              //                   product['slug'] ?? '',
                              //                   product,
                              //                 );
                              //               }
                              //             },
                              //             icon: Icon(
                              //               isInCart
                              //                   ? Icons.remove_shopping_cart
                              //                   : Icons.add_shopping_cart,
                              //               color: Colors.white,
                              //               size: 18,
                              //             ),
                              //             style: IconButton.styleFrom(
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10),
                              //               ),
                              //               backgroundColor: isInCart
                              //                   ? Colors.red
                              //                   : Colors.orange.shade700,
                              //               padding: EdgeInsets.all(4),
                              //             ),
                              //             constraints: BoxConstraints(),
                              //           );
                              //         }),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).onTap(() {
                  final productSlug = product['slug'] ?? '';
                  print(
                    "Product tapped - Slug: $productSlug, ID: ${product['_id']}",
                  );

                  if (productSlug.isNotEmpty) {
                    Get.to(() => DetailProductScreen(productSlug: productSlug));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Product details not available'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getLoadingMessage() {
    if (widget.isPerishable) {
      return 'Loading perishable products...';
    } else if (widget.isBrandScreen) {
      return 'Loading ${widget.brandName} products...';
    } else if (widget.categorySlug != null) {
      return 'Loading ${widget.categoryName}...';
    } else {
      return 'Loading all products...';
    }
  }

  //// Add this method for quantity dialog
  // void _showEnquiryDialog(BuildContext context, dynamic product) {
  //   int quantity = 1;

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Enquire for ${product['productName']}'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Select quantity:'),
  //             SizedBox(height: 10),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.remove),
  //                   onPressed: () {
  //                     if (quantity > 1) {
  //                       quantity--;
  //                       (context as Element).markNeedsBuild();
  //                     }
  //                   },
  //                 ),
  //                 SizedBox(width: 20),
  //                 Text(
  //                   '$quantity',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(width: 20),
  //                 IconButton(
  //                   icon: Icon(Icons.add),
  //                   onPressed: () {
  //                     quantity++;
  //                     (context as Element).markNeedsBuild();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               await _createEnquiry(product['_id'], quantity);
  //             },
  //             child: Text('Submit Enquiry'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
          title: Text('Enquire for ${product['productName']}'),
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
                  product['_id'],
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
}
