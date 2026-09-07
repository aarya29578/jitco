import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartcount.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_cartcontroller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class JlProductScreen extends StatefulWidget {
  final String? title;
  final String? categorySlugs;
  final String? categoryId;
  const JlProductScreen({
    super.key,
    this.title,
    this.categorySlugs,
    this.categoryId,
  });

  @override
  State<JlProductScreen> createState() => _JlProductScreenState();
}

class _JlProductScreenState extends State<JlProductScreen> {
  final ApiServices _apiService = Get.find<ApiServices>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // final JLAllProducts prodController = Get.put(JLAllProducts());

  bool screenLoading = true;

  OutletModel? cityWarehouse;
  String? _warehouseId;
  JLAllProductsController? prodController;

  // OutletModel? cityWarehouse;
  // String? _warehouseId;
  // ServiceController? controller;

  // @override
  // void initState() {
  //   // final tag = '${widget.categorySlugs}';
  //   super.initState();

  //   // prodController = Get.put(
  //   //   JLAllProductsController(categorySlugs: widget.categorySlugs),
  //   //   tag: tag, // optional but safer
  //   // );

  //   prodController = Get.put(
  //     JLAllProductsController(
  //       categorySlugs: widget.categorySlugs,
  //       categoryId: widget.categoryId,
  //     ),
  //     tag: widget.categorySlugs ?? 'all',
  //     permanent: false,
  //   );
  // }
  @override
  void initState() {
    super.initState();
    _initialize();
    final bottomNavController = Get.find<JlBottomNavController>();

    ever(bottomNavController.shouldFocusSearch, (value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });

        bottomNavController.shouldFocusSearch.value = false;
      }
    });
  }

  Future<void> _initialize() async {
    final tag = '${widget.categorySlugs}_${widget.categoryId}';

    await _fetchIdFromWarehouse(); //only wait here

    prodController = Get.put(
      JLAllProductsController(
        categorySlugs: widget.categorySlugs,
        categoryId: widget.categoryId,
        warehouseId: _warehouseId,
      ),
      tag: widget.categorySlugs ?? 'all',
      permanent: false,
    );

    // scrollController.addListener(_onScroll);

    setState(() {
      screenLoading = false; //UI unlock
    });
  }

  // void _onScroll() {
  //   if (scrollController.position.pixels >=
  //       scrollController.position.maxScrollExtent - 200) {
  //     controller?.loadMore();
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    Get.delete<JLAllProductsController>(tag: widget.categorySlugs ?? 'all');
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

              print('Warehouse model created with ID: ${cityWarehouse?.id}');
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

            print('Warehouse model created with ID: ${cityWarehouse?.id}');
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
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        title: Text(
          "${widget.title ?? "All Liquor"} Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // backgroundColor: Colors.orangeAccent.shade400,
        centerTitle: true,
        actions: [
          if (widget.title != null)
            JlCartBadgeIcon(
              isActive: true,
              activeColor: Colors.white,
              nonActiveColor: Colors.grey,
            ).onTap(() {
              Get.find<JlBottomNavController>().switchTab(4);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                // final navigator = Navigator.of(context);

                // if (navigator.canPop()) {
                //   navigator.pop();
                // }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navigator = Navigator.of(context);

                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                });
              });

              // final bottomNavState = context
              //     .findAncestorStateOfType<JlBottomNavBarState>();
              // if (bottomNavState != null) {
              //   bottomNavState.switchToTab(
              //     3,
              //   ); // Switch to Products tab (index 2)
              // }
            }),
          20.widthBox,
        ],
      ),
      backgroundColor: Colors.orange.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 15),
            // Center(
            //   child: Text(
            //     "All Liquor Products",
            //     style: TextStyle(
            //       fontSize: 22,
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 5),

            ///SEARCH BAR
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: TextField(
            //     onChanged: (value) {
            //       prodController.searchQuery.value = value;
            //     },
            //     decoration: InputDecoration(
            //       filled: true,
            //       fillColor: Colors.white,
            //       hintText: "Search products...",
            //       hintStyle: const TextStyle(color: Colors.grey),
            //       prefixIcon: const Icon(Icons.search, color: Colors.grey),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
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
            //       // controller: _searchController,
            //       // focusNode: _searchFocus,
            //       decoration: const InputDecoration(
            //         hintText: "Search liquor...",
            //         prefixIcon: Icon(Icons.search, color: Colors.orange),
            //         border: InputBorder.none,
            //         contentPadding: EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 15,
            //         ),
            //       ),
            //       onChanged: (value) =>
            //           prodController?.searchQuery.value = value,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: screenLoading
                  ? TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Search liquor...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // ✅ clean modern look
                        ),
                      ),
                    )
                  : Obx(
                      () => TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,

                          hintText: "Search liquor...",
                          hintStyle: const TextStyle(color: Colors.grey),

                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.orange,
                          ),

                          /// ✅ CANCEL BUTTON
                          suffixIcon:
                              prodController!.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    prodController!.searchQuery.value = "";
                                    _searchFocusNode.unfocus();
                                  },
                                )
                              : null,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide.none, // ✅ removes ugly border line
                          ),
                        ),

                        onChanged: (value) =>
                            prodController!.searchQuery.value = value,
                      ),
                    ),
            ),

            /// PRODUCT LIST
            Expanded(
              child: screenLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    ) //NORMAL WIDGET
                  : Obx(() {
                      final list = prodController?.productList;
                      if (prodController!.isLoading.value &&
                          prodController!.productList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (list!.isEmpty) {
                        return const Center(child: Text("No products found"));
                      }

                      return ListView.builder(
                        controller: prodController?.scrollController,
                        padding: EdgeInsets.zero,
                        itemCount:
                            list.length +
                            (prodController!.isMoreDataAvailable.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == list.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                          return _ProductCard(
                            product: list[index],
                            warehouseId: _warehouseId,
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

class _ProductCard extends StatefulWidget {
  final AllLiq product;
  final String? warehouseId;

  const _ProductCard({required this.product, this.warehouseId});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int selectedIndex = 0;
  final JlCartcontroller cartController = Get.find<JlCartcontroller>();

  String get _selectedVariant {
    final prices = widget.product.price ?? [];

    if (prices.isNotEmpty && selectedIndex < prices.length) {
      return prices[selectedIndex].size ?? 'Default';
    }

    return 'Default';
  }

  // void _handleCart(String? imageUrl, selectedIndex) {
  //   final prices = widget.product.price ?? [];
  //   final selectedPrice = prices.isNotEmpty
  //       ? prices[selectedIndex].price.toDouble()
  //       : 0.0;

  //   final variant = _selectedVariant;

  //   final cartItem = JlCartitem(
  //     id: widget.product.id ?? '',
  //     name: widget.product.productName ?? '',
  //     // image: (widget.product.image.isNotEmpty) ? widget.product.image[0] : '',
  //     image: imageUrl ?? '',
  //     price: selectedPrice,
  //     quantity: 1,
  //     categorySlug: widget.product.slug ?? '',
  //     uom: variant,
  //   );

  //   if (cartController.cartItems.any(
  //     (item) => item.id == cartItem.id && item.selectedVariant == variant,
  //   )) {
  //     cartController.removeFromCart(cartItem.id, variant);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${cartItem.name} removed from cart'),
  //         backgroundColor: Colors.red,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   } else {
  //     cartController.addToCart(cartItem);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${cartItem.name} added to cart'),
  //         backgroundColor: Colors.green,
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //   }

  //   setState(() {}); // Refresh button color/icon
  // }
  void _handleCart(String? imageUrl, selectedIndex) {
    final prices = widget.product.price ?? [];

    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex].price.toDouble()
        : 0.0;

    final variant = _selectedVariant;

    final cartItem = JlCartitem(
      id: widget.product.id ?? '',
      name: widget.product.productName ?? '',
      image: imageUrl ?? '',
      price: selectedPrice,
      quantity: 1,
      categorySlug: widget.product.slug ?? '',
      selectedVariant: variant, // ✅ VERY IMPORTANT
      uom: variant,
    );

    final exists = cartController.cartItems.any(
      (item) => item.id == cartItem.id && item.selectedVariant == variant,
    );

    if (exists) {
      cartController.removeFromCart(cartItem.id, variant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} ($variant) removed'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      cartController.addToCart(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} ($variant) added'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.product.price ?? [];
    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex].price.toDouble()
        : 0.0;

    // final isInCart = cartController.cartItems.any(
    //   (item) => item.id == widget.product.id,
    // );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Get.to(
              () => JlDetailScreen(
                slug: widget.product.slug,
                id: widget.product.id,
                warehouseId: widget.warehouseId,
              ),
            );
          },
          child: Container(
            // height: 210,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: _buildProductImage(widget.product.image),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.product.productShortDescription ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                if (prices.isNotEmpty)
                  SizedBox(
                    height: 32.5,
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              prices[index].size ?? "",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 5),
                Divider(color: Colors.grey.shade300, thickness: 2),
                SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "₹$selectedPrice",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: Obx(() {
                        // final isInCart = cartController.cartItems.any(
                        //   (item) => item.id == widget.product.id,
                        // );

                        final variant = _selectedVariant;

                        final isInCart = cartController.cartItems.any(
                          (item) =>
                              item.id == widget.product.id &&
                              item.selectedVariant == variant,
                        );
                        return ElevatedButton.icon(
                          onPressed: () =>
                              _handleCart(widget.product.image, selectedIndex),
                          icon: Icon(
                            isInCart
                                ? Icons.remove_shopping_cart
                                : Icons.add_shopping_cart,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            isInCart ? "Remove from Cart" : "Add to Cart",
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInCart
                                ? Colors.red
                                : Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    // null / empty / "null"
    if (imageUrl == null || imageUrl.trim().isEmpty || imageUrl == "null") {
      return const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,

      // broken url
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Colors.grey,
        );
      },

      // loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}
