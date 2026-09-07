// lib/screens/Bmain/Jitco Menu/Screens/JM_Product_Screen/jm_all_products_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/JM_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/JM_Enquiry/jm_enquiry_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_all_product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/c_JM_Product_Screen/jm_detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:velocity_x/velocity_x.dart';

class JMAllProductsScreen extends StatefulWidget {
  const JMAllProductsScreen({super.key});

  @override
  State<JMAllProductsScreen> createState() => _JMAllProductsScreenState();
}

class _JMAllProductsScreenState extends State<JMAllProductsScreen> {
  // Use AllProductsController for all products
  final AllProductsController controller = Get.put(
    AllProductsController(),
    tag: 'all_products',
  );
  final ApiServices apiServices = Get.find<ApiServices>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDebounce;
  bool _isSearching = false;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  @override
  void initState() {
    super.initState();
    print("=== JMAllProductsScreen initState ===");

    _initializeScreen();
  }

  void _initializeScreen() async {
    await _fetchIdFromWarehouse();
    print("api hitting from the all prtoduct screen");

    // if (_warehouseId != null && _warehouseId!.isNotEmpty) {
    print("warehouse is not empty or null");
    controller.initialize(warehouseId: _warehouseId);
    // }

    final bottomNavController = Get.find<JmBottomNavController>();

    ever(bottomNavController.shouldFocusSearch, (value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });

        bottomNavController.shouldFocusSearch.value = false;
      }
    });
  }

  // void _initializeScreen() async {
  //   final id = await _fetchIdFromWarehouse();

  //   print("IdfromInitialize:$id");

  //   if (id != null && id.isNotEmpty) {
  //     controller.initialize(warehouseId: id);
  //   } else {
  //     print("Warehouse id not found");
  //   }
  // }

  Future<void> _fetchIdFromWarehouse() async {
    // Future<String?> _fetchIdFromWarehouse() async {
    try {
      final outletResponse = await apiServices.getUserOutlet();

      if (outletResponse['success'] == true && outletResponse['data'] is List) {
        final outlets = outletResponse['data'] as List;

        if (outlets.isEmpty) return;

        final outlet = OutletModel.fromJson(outlets[0]);
        final cityName = outlet.cityName;

        if (cityName == null || cityName.isEmpty) return;

        final result = await apiServices.getWarehouseIdByCity(
          page: 1,
          limit: 1,
          encodedCity: cityName,
        );

        if (result['data'] != null) {
          if (result['data'] is List) {
            final warehouseList = result['data'] as List;
            if (warehouseList.isNotEmpty) {
              final warehouseData = warehouseList[0];
              final warehouseId = warehouseData['_id'];
              print("wareHouseIdfromif:$warehouseId");

              // setState(() {
              //   _warehouseId = warehouseId;
              //   print("wareHouseIdfromsetstate1:$warehouseId");
              //   cityWarehouse = OutletModel.fromJson(warehouseData);
              // });
              _warehouseId = warehouseId;
              cityWarehouse = OutletModel.fromJson(warehouseData);
              return warehouseId;
            }
          } else if (result['data'] is Map) {
            final warehouseData = result['data'] as Map<String, dynamic>;
            final warehouseId = warehouseData['_id'];
            print("wareHouseIdfromelse:$warehouseId");

            // setState(() {
            //   _warehouseId = warehouseId;
            //   print("wareHouseIdfromsetstate2:$warehouseId");
            //   cityWarehouse = OutletModel.fromJson(warehouseData);
            // });
            _warehouseId = warehouseId;
            cityWarehouse = OutletModel.fromJson(warehouseData);
            return warehouseId;
          }
        }
      }
    } catch (e) {
      print('Error in _fetchIdFromWarehouse: $e');
    }
  }

  // void _onSearchChanged(String value) {
  //   _searchDebounce?.cancel();

  //   final query = value.trim();

  //   if (query.isEmpty) {
  //     setState(() {
  //       _isSearching = false;
  //     });
  //     controller.clearSearch();
  //     return;
  //   }

  //   _searchDebounce = Timer(const Duration(milliseconds: 500), () {
  //     setState(() {
  //       _isSearching = true;
  //     });
  //     controller.searchQuery.value = query;
  //   });
  // }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    final query = value.trim();

    print("Search text changed to: '$query'");

    if (query.isEmpty) {
      print("Query is empty, clearing search");
      setState(() {
        _isSearching = false;
      });
      controller.clearSearch();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      print("Debounce timer completed, starting search for: '$query'");

      setState(() {
        _isSearching = true;
      });

      controller.warehouseId.value = _warehouseId; // nullable now
      controller.searchQuery.value = query;
    });

    // _searchDebounce = Timer(const Duration(milliseconds: 500), () {
    //   print("Debounce timer completed, starting search for: '$query'");
    //   setState(() {
    //     _isSearching = true;
    //   });

    //   // Make sure controller has warehouseId
    //   if (_warehouseId != null && _warehouseId!.isNotEmpty ||
    //       _warehouseId == null && _warehouseId!.isEmpty) {
    //     // if (controller.warehouseId.value.isEmpty) {
    //     print("Setting warehouseId on controller: $_warehouseId");
    //     controller.warehouseId.value = _warehouseId!;
    //     // }

    //     print("Setting search query to: '$query'");
    //     controller.searchQuery.value = query;

    //     // Don't force call _performSearch - let the ever() listener handle it
    //   } else {
    //     print("WARNING: warehouseId is not available yet!");
    //     setState(() {
    //       _isSearching = false;
    //     });
    //   }
    // });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    controller.clearSearch();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add this for debugging:
    print("Controller state - searchQuery: '${controller.searchQuery.value}'");
    print("Controller state - isSearching: ${controller.isSearching.value}");
    print("Controller state - filteredList: ${controller.filteredList.length}");
    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        title: Text(
          "All Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
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
                  focusNode: _searchFocusNode,
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

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _isSearching
                    ? "Searching for \"${_searchController.text}\""
                    : "All available products",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),

            // Main content
            Expanded(
              child: Obx(() {
                final filteredList = controller.filteredList;
                final isLoading = controller.isLoading.value;
                final isSearching = controller.isSearching.value;

                if (isLoading && filteredList.isEmpty && !_isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (_isSearching && isSearching && filteredList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                if (_isSearching && !isSearching && filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.white60),
                        SizedBox(height: 16),
                        Text(
                          'No products found for "${_searchController.text}"',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'in all categories',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
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

                if (filteredList.isEmpty && !isLoading && !_isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.white60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return _buildProductList(filteredList);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(List<All> products) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        return false;
      },
      child: ListView.builder(
        controller: controller.scrollController,
        itemCount:
            products.length +
            ((_isSearching
                    ? controller.isSearchMoreDataAvailable.value
                    : controller.isMoreDataAvailable.value)
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child:
                    (_isSearching
                        ? controller.isSearching.value
                        : controller.isLoading.value)
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : SizedBox.shrink(),
              ),
            );
          }

          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Get.to(
                () => JMDetailProductScreen(
                  productSlug: product.slug,
                  warehouseId: _warehouseId,
                ),
                // arguments: {"id": product.id},
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final All product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int selectedIndex = 0;
  final JmCartController _cartController = Get.find<JmCartController>();

  // Map<String, dynamic>? productData;
  // int selectedIndex = 0;

  // String _getProductName() {
  //   return productData?['productName'] ?? 'Unknown Product';
  // }

  // String? getProductImage() {
  //   final images = productData?['productImage'];
  //   if (images is List &&
  //       images.isNotEmpty &&
  //       images[0] != null &&
  //       images[0].isNotEmpty) {
  //     return images[0];
  //   }
  //   return null;
  // }

  String _getProductGST() {
    return widget.product.gstPercentage.toString();
  }

  // bool get _isProductInCart {
  //   // if (widget.product == null) return false;
  //   final productId = widget.product.id;

  //   return _cartController.cartItems.any((item) => item.id == productId);
  // }
  bool get _isProductInCart {
    final productId = widget.product.id;
    final prices = widget.product.price;

    final variant = prices.isNotEmpty
        ? prices[selectedIndex].size.toString()
        : 'Default';

    return _cartController.cartItems.any(
      (item) => item.id == productId && item.selectedVariant == variant,
    );
  }

  void _addToCart() {
    if (widget.product != null) {
      final productId = widget.product.id;
      final productName = widget.product.productName;
      final categorySlug = widget.product.slug;
      // final quantityPerBox = productData?['quantityPerBox'] ?? 1;
      // final uom = productData?['uom'] ?? 'item';

      double itemPrice = 0.0;
      String? variantType = 'piece';

      // Calculate price based on selected variant
      final prices = widget.product.price;
      if (prices.isNotEmpty && selectedIndex < prices.length) {
        itemPrice = (prices[selectedIndex].price).toDouble();
        variantType = prices[selectedIndex].size.toString().toLowerCase();
      }

      double gstPercentage = double.tryParse(_getProductGST()) ?? 0.0;

      final cartItem = JmCartItem(
        id: productId,
        name: productName,
        image: widget.product.image,
        price: itemPrice,
        gstPercentage: gstPercentage,
        quantity: 1,
        categorySlug: categorySlug,
        selectedVariant: prices.isNotEmpty && selectedIndex < prices.length
            ? prices[selectedIndex].size.toString()
            : 'Default',
        originalPrice: itemPrice,
        warehouseId: null,
        // quantityPerBox: quantityPerBox,
        // uom: uom,
        variantType: variantType,
      );

      _cartController.addToCart(cartItem);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName added to cart'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Unable to add product to cart'),
    //       backgroundColor: Colors.red,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
  }

  // void _removeFromCart() {
  //   if (widget.product != null) {
  //     final productId = widget.product.id;
  //     final productName = widget.product.productName;

  //     _cartController.removeFromCart(productId);
  //     setState(() {});

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('$productName removed from cart'),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }
  void _removeFromCart() {
    final prices = widget.product.price;

    final variant = prices.isNotEmpty
        ? prices[selectedIndex].size.toString()
        : 'Default';

    final productId = widget.product.id;
    final productName = widget.product.productName;

    _cartController.removeFromCart(productId, variant);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName ($variant) removed from cart'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleCart() {
    if (_isProductInCart) {
      _removeFromCart();
    } else {
      _addToCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.product.price;
    final selectedPrice = prices.isNotEmpty ? prices[selectedIndex].price : 0;
    final variant = prices.isNotEmpty
        ? prices[selectedIndex].size.toString()
        : 'Default';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        // height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.product.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.image, //************************* */
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.image, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.category.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            15.heightBox,

            if (prices.isNotEmpty && prices.length > 1)
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          prices[index].size ?? "Size",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            10.heightBox,
            if (selectedPrice != 0) const Divider(),
            5.heightBox,

            if (selectedPrice != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹$selectedPrice",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: Obx(() {
                      // final isInCart = _cartController.cartItems.any(
                      //   (item) => item.id == widget.product.id,
                      // );
                      final isInCart = _cartController.cartItems.any(
                        (item) =>
                            item.id == widget.product.id &&
                            item.selectedVariant == variant,
                      );

                      return ElevatedButton.icon(
                        onPressed: () {
                          // isInCart ? _removeFromCart() : _addToCart();
                          isInCart
                              ? _cartController.removeFromCart(
                                  widget.product.id,
                                  variant,
                                )
                              : _addToCart();
                        },
                        icon: Icon(
                          isInCart
                              ? Icons.remove_shopping_cart
                              : Icons.add_shopping_cart,
                          size: 18,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isProductInCart
                              ? Colors.red
                              : Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        label: Text(isInCart ? "Remove" : "Add to menu"),
                      );
                    }),
                  ),
                ],
              ),
            ],
            if (selectedPrice == 0) const Divider(),
            5.heightBox,
            if (selectedPrice == 0) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                ),
                child: SizedBox(
                  height: 35,
                  width: 70,
                  child: Obx(() {
                    final jmEnquiryController = Get.find<JmEnquiryController>();
                    final isInEnquiry = jmEnquiryController.enquiryItems.any(
                      (enquiry) => enquiry.productId == widget.product.id,
                    );

                    return TextButton(
                      onPressed: () async {
                        if (isInEnquiry) {
                          // Navigate to enquiry screen
                          Get.to(() => JmEnquiryScreen());
                        } else {
                          // Show quantity dialog and create enquiry
                          _showEnquiryDialog(context, widget.product);
                        }
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: isInEnquiry
                            ? Colors.blue.shade200
                            : Colors.blue.shade500,
                        padding: EdgeInsets.all(4),
                      ),
                      child: Text(
                        isInEnquiry ? 'View Enquire' : 'Enquire Now',
                        style: TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEnquiryDialog(BuildContext context, dynamic product) {
    final RxInt quantity = 1.obs;
    final TextEditingController controller = TextEditingController(text: '1');
    final TextEditingController commentsController = TextEditingController();

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
          title: Text('Enquire for ${product.productName}'),
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
                        controller: commentsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Notes....",
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
                  commentsController.text.trim(),
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
      final jmEnquiryController = Get.find<JmEnquiryController>();
      await jmEnquiryController.createEnquiry(
        context,
        productId,
        quantity,
        comments ?? "",
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
