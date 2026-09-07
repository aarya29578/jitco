import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/state_city_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_drop_down.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_user.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/B_JS_Enquiries/JS_enquires_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_Detail_Product/Js_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_price_calculation_services.dart';
import 'package:velocity_x/velocity_x.dart';

class JsServiceScreen extends StatefulWidget {
  final String? title;
  final String? categorySlug;
  final String? categoryId;
  final bool? slug;
  final String? warehouseId;

  const JsServiceScreen({
    super.key,
    this.title,
    this.categorySlug,
    this.categoryId,
    this.slug,
    this.warehouseId,
  });

  @override
  State<JsServiceScreen> createState() => _JsServiceScreenState();
}

class _JsServiceScreenState extends State<JsServiceScreen> {
  // final ServiceController controller = Get.put(ServiceController());
  final ApiServices _apiService = Get.find<ApiServices>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool screenLoading = true;

  OutletModel? cityWarehouse;
  String? _warehouseId;
  ServiceController? controller;

  // ServiceController? controller;

  // @override
  // void initState() async {
  //   final tag = '${widget.categorySlug}_${widget.slug}';
  //   super.initState();
  //   await _fetchIdFromWarehouse();
  //   // _initialize();
  //   controller = Get.put(
  //     ServiceController(
  //       categorySlug: widget.categorySlug,
  //       slug: widget.slug,
  //       categoryId: widget.categoryId,
  //       warehouseId: _warehouseId,
  //     ),
  //     tag: tag,
  //   );

  //   scrollController.addListener(_onScroll);
  // }

  @override
  void initState() {
    super.initState();
    _initialize();

    final bottomNavController = Get.find<JsBottomNavController>();

    ever(bottomNavController.shouldFocusSearch, (value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });

        bottomNavController.shouldFocusSearch.value = false;
      }
    });
  }

  // Future<void> _initialize() async {
  //   final tag = '${widget.categorySlug}_${widget.slug}';

  //   await _fetchIdFromWarehouse(); // Runs first

  //   controller = Get.put(
  //     ServiceController(
  //       categorySlug: widget.categorySlug,
  //       slug: widget.slug,
  //       categoryId: widget.categoryId,
  //       warehouseId: _warehouseId,
  //     ),
  //     tag: tag,
  //   );

  //   scrollController.addListener(_onScroll);
  // }
  Future<void> _initialize() async {
    final tag = '${widget.categorySlug}_${widget.slug}';

    await _fetchIdFromWarehouse(); //only wait here

    controller = Get.put(
      ServiceController(
        categorySlug: widget.categorySlug,
        slug: widget.slug,
        categoryId: widget.categoryId,
        warehouseId: _warehouseId,
      ),
      tag: tag,
    );

    scrollController.addListener(_onScroll);

    setState(() {
      screenLoading = false; //UI unlock
    });
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      controller?.loadMore();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    scrollController.dispose();
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
      backgroundColor: Colors.orange.shade700,
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        title: Text(
          widget.title != null
              ? 'Explore ${widget.title}'
              : "Explore All Services",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (widget.title != null)
            JsCartBadgeIcon(
              isActive: true,
              activeColor: Colors.white,
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final navigator = Navigator.of(context);

                if (navigator.canPop()) {
                  navigator.pop();
                }
              });
            }),
          20.widthBox,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 16),
            // SafeArea(
            //   top: true,
            //   bottom: false,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 20),
            //     child: Text(
            //       widget.title != null
            //           ? 'Explore ${widget.title}'
            //           : "Explore Our Services",
            //       // style: GoogleFonts.merienda(
            //       //   fontSize: 20,
            //       //   color: Colors.white,
            //       //   fontWeight: FontWeight.bold,
            //       // ),
            //       style: TextStyle(
            //         fontSize: 22,
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            // Search bar
            // Padding(
            //   padding: const EdgeInsets.all(12.0),
            //   child: TextField(
            //     onChanged: (value) => controller.searchQuery.value = value,
            //     decoration: InputDecoration(
            //       filled: true,
            //       fillColor: Colors.white,
            //       hintText: "Search services...",
            //       hintStyle: const TextStyle(color: Colors.grey),
            //       prefixIcon: const Icon(Icons.search, color: Colors.grey),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(10),
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
            //         hintText: "Search categories...",
            //         prefixIcon: Icon(Icons.search, color: Colors.orange),
            //         border: InputBorder.none,
            //         contentPadding: EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 15,
            //         ),
            //       ),
            //       onChanged: (value) => controller?.searchQuery.value = value,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: screenLoading
                  ? const SizedBox()
                  : Obx(
                      () => Container(
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
                          controller: _searchController, // KEY FIX
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: "Search services...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.orange,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),

                            suffixIcon: controller!.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear(); // CLEAR UI
                                      controller!.searchQuery.value =
                                          ""; // CLEAR STATE
                                    },
                                  )
                                : null,
                          ),

                          onChanged: (value) =>
                              controller!.searchQuery.value = value,
                        ),
                      ),
                    ),
            ),

            // Product grid
            // Expanded(
            //   child: Obx(() {
            //     if (controller!.isLoading.value) {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //     if (controller!.liqourList.isEmpty &&
            //         !controller!.isLoading.value) {
            //       return const Center(
            //         child: Text(
            //           "No services found",
            //           style: TextStyle(fontSize: 18, color: Colors.white70),
            //         ),
            //       );
            //     }
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 5),
            //       child: GridView.builder(
            //         controller: scrollController,
            //         padding: const EdgeInsets.all(8),
            //         gridDelegate:
            //             const SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 1,
            //               childAspectRatio: 1.60, // better card proportion
            //               crossAxisSpacing: 12,
            //               mainAxisSpacing: 12,
            //             ),
            //         // itemCount: controller?.filteredList.length,
            //         itemCount:
            //             controller!.liqourList.length +
            //             (controller!.isLoadingMore.value ? 1 : 0),
            //         itemBuilder: (context, index) {
            //           if (index >= controller!.liqourList.length) {
            //             return const Center(
            //               child: Padding(
            //                 padding: EdgeInsets.all(16),
            //                 child: CircularProgressIndicator(),
            //               ),
            //             );
            //           }
            //           final item = controller?.liqourList[index];
            //           return _ProductCard(product: item);
            //         },
            //       ),
            //     );
            //   }),
            // ),
            Expanded(
              child: screenLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    ) //NORMAL WIDGET
                  : Obx(() {
                      final c = controller!; // safe

                      if (c.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (c.liqourList.isEmpty) {
                        return const Center(
                          child: Text(
                            "No services found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio:
                                    1.60, // better card proportion
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          controller: scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount:
                              c.liqourList.length +
                              (c.isLoadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= c.liqourList.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final item = c.liqourList[index];
                            return _ProductCard(
                              product: item,
                              warehouseId: _warehouseId,
                            );
                          },
                        ),
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
  final Product? product;
  final String? warehouseId;

  const _ProductCard({this.product, this.warehouseId});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int selectedIndex = 0;
  int selectedUomIndex = 0; // 0 for piece, 1 for pack

  final JsCartcontroller cartController = Get.find<JsCartcontroller>();
  final JsPriceCalculationServices priceService =
      Get.find<JsPriceCalculationServices>();

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ApiServices apiService = Get.find<ApiServices>();

  List<StateModel> countries = [];
  List<CityModel> cities = [];

  StateModel? selectedState;
  CityModel? selectedCity;

  bool loadingCountries = true;
  bool loadingCities = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  @override
  void dispose() {
    phoneController.dispose();
    jobTitleController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadCountries() async {
    try {
      countries = await apiService.fetchStates();
      setState(() {
        loadingCountries = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        loadingCountries = false;
      });
    }
  }

  Future<void> loadCities(
    int stateId,
    void Function(void Function()) sheetSetState,
  ) async {
    sheetSetState(() {
      loadingCities = true;
      selectedCity = null;
    });

    try {
      final fetchedCities = await apiService.fetchCities(stateId);

      sheetSetState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      print('Error loading cities: $e');

      sheetSetState(() {
        cities = [];
      });
    } finally {
      sheetSetState(() {
        loadingCities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.product?.prices ?? [];

    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex].price.toDouble()
        : 0.0;

    final isInCart = cartController.cartItems.any(
      (item) => item.id == widget.product?.id,
    );

    return GestureDetector(
      onTap: () {
        Get.to(
          () => JsDetailScreen(
            slug: widget.product!.slug,
            id: widget.product!.id,
            warehouseId: widget.warehouseId,
          ),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              // offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            // ClipRRect(
            //   borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(16),
            //   ),
            //   child: SizedBox(
            //     height: 110,
            //     width: double.infinity,
            //     child: _buildProductImage(widget.product.image),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: _buildProductImage(widget.product?.image),
                        ),
                      ),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product?.name ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.product?.categoryName ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  12.heightBox,

                  // Price variants
                  if (prices.isNotEmpty)
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: prices.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = index == selectedIndex;
                          return GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Chip(
                              label: Text(
                                prices[index].size,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade200,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 10),

                  if (selectedPrice == 0)
                    // SizedBox(
                    //   height: 40,
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     onPressed: _handleAddRemoveCart,
                    //     icon: Icon(
                    //       isInCart
                    //           ? Icons.remove_shopping_cart
                    //           : Icons.add_shopping_cart,
                    //       size: 18,
                    //     ),
                    //     label: Text(
                    //       isInCart ? "Remove from Cart" : "Add to Cart",
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: isInCart
                    //           ? Colors.red
                    //           : Colors.orangeAccent,
                    //       foregroundColor: Colors.white,
                    //       padding: const EdgeInsets.symmetric(horizontal: 12),
                    //       minimumSize: const Size(100, 36),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: SizedBox(
                        height: 35,
                        width: 70,
                        child: Obx(() {
                          final jsEnquiryController =
                              Get.find<JsEnquiryController>();
                          final isInEnquiry = jsEnquiryController.jlEnquiryItems
                              .any(
                                (enquiry) =>
                                    enquiry.productId == widget.product?.id,
                              );

                          return TextButton(
                            onPressed: () async {
                              if (isInEnquiry) {
                                // Navigate to enquiry screen
                                Get.to(() => JsEnquiresScreen());
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
                  // Price + Cart button
                  if (selectedPrice != 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${selectedPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 200,
                          child: Obx(() {
                            final selectedVariant = prices.isNotEmpty
                                ? prices[selectedIndex].size
                                : 'Default';

                            final isInCart = cartController.cartItems.any(
                              (item) =>
                                  item.id == widget.product?.id &&
                                  item.selectedVariant == selectedVariant,
                            );

                            return ElevatedButton.icon(
                              onPressed: _handleAddRemoveCart,
                              icon: Icon(
                                isInCart
                                    ? Icons.remove_shopping_cart
                                    : Icons.add_shopping_cart,
                                size: 18,
                              ),
                              label: Text(
                                isInCart ? "Remove from Cart" : "Add to Cart",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart
                                    ? Colors.red
                                    : Colors.orange.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                minimumSize: const Size(100, 36),
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
          ],
        ),
      ),
    );
  }

  // void _showEnquiryBottomSheet(BuildContext context, dynamic product) {
  //   // final RxInt quantity = 1.obs;
  //   final TextEditingController controller = TextEditingController(text: '1');
  //   final TextEditingController commentController = TextEditingController();

  //   // ever(quantity, (value) {
  //   //   if (controller.text != value.toString()) {
  //   //     controller.text = value.toString();
  //   //     controller.selection = TextSelection.fromPosition(
  //   //       TextPosition(offset: controller.text.length),
  //   //     );
  //   //   }
  //   // });

  //   int quantity = 1;

  //   showModalBottomSheet(
  //     context: context,
  //     // isDismissible: false, // same as barrierDismissible: false
  //     // enableDrag: false, // prevents swipe down closing
  //     isScrollControlled: true, // allows full-screen height
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, bottomSheetSetState) {
  //           return Scaffold(
  //             body: SafeArea(
  //               child: Padding(
  //                 padding: EdgeInsets.only(
  //                   left: 20,
  //                   right: 20,
  //                   top: 20,
  //                   // bottom: MediaQuery.of(context).viewInsets.bottom + 20,
  //                 ),
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       30.heightBox,

  //                       Padding(
  //                         padding: const EdgeInsets.all(2),
  //                         child: Row(
  //                           children: [
  //                             Icon(
  //                               Icons.arrow_back,
  //                               textDirection: TextDirection.ltr,
  //                             ).onTap(() {
  //                               Get.back();
  //                             }),
  //                             30.widthBox,
  //                             Center(
  //                               child: const Text(
  //                                 "Enquire Form",
  //                                 style: TextStyle(
  //                                   color: Colors.black87,
  //                                   fontSize: 20,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                                 textAlign: TextAlign.center,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),

  //                       /// Title
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 5,
  //                           vertical: 20,
  //                         ),
  //                         child: Text(
  //                           'Product Name: ${product.name}',
  //                           style: const TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),

  //                       // const SizedBox(height: 20),

  //                       /// Quantity
  //                       const Text(
  //                         'Set quantity *',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black54,
  //                         ),
  //                         textAlign: TextAlign.start,
  //                       ),
  //                       const SizedBox(height: 10),

  //                       Container(
  //                         width: double.infinity,
  //                         height: 50,
  //                         decoration: BoxDecoration(
  //                           border: Border.all(color: Colors.grey),
  //                           borderRadius: BorderRadius.circular(6),
  //                         ),
  //                         child: Center(
  //                           child: Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 10,
  //                             ),
  //                             child: TextFormField(
  //                               controller: controller,
  //                               cursorColor: Colors.orange,
  //                               keyboardType: TextInputType.number,
  //                               textAlign: TextAlign.start,
  //                               decoration: const InputDecoration(
  //                                 border: InputBorder.none,
  //                                 isDense: true,
  //                                 contentPadding: EdgeInsets.zero,
  //                               ),
  //                               // onChanged: (value) {
  //                               //   final q = int.tryParse(value) ?? 1;
  //                               //   quantity.value = q < 1 ? 1 : q;
  //                               // },
  //                               onChanged: (value) {
  //                                 final q = int.tryParse(value) ?? 1;
  //                                 quantity = q < 1 ? 1 : q;
  //                               },
  //                             ),
  //                           ),
  //                         ),
  //                       ),

  //                       const SizedBox(height: 20),

  //                       /// Message
  //                       const Align(
  //                         alignment: Alignment.centerLeft,
  //                         child: Text(
  //                           'Message',
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black54,
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 10),

  //                       TextField(
  //                         controller: commentController,
  //                         maxLines: 3,
  //                         decoration: InputDecoration(
  //                           hintText: "Additional comments...",
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                             borderSide: BorderSide(color: Colors.orange),
  //                           ),
  //                         ),
  //                       ),

  //                       const SizedBox(height: 10),

  //                       FormUnknownUser(
  //                         formTitle: 'Job Title *',
  //                         controller: jobTitleController,
  //                         // keyboardType: TextInputType.none,
  //                       ),
  //                       FormUnknownUser(
  //                         formTitle: 'Email *',
  //                         controller: emailController,
  //                         keyboardType: TextInputType.emailAddress,
  //                       ),

  //                       // FormUnknownUser(
  //                       //   formTitle: 'Phone *',
  //                       //   controller: phoneController,
  //                       //   keyboardType: TextInputType.phone,
  //                       // ),
  //                       const SizedBox(height: 10),

  //                       /// Quantity
  //                       const Text(
  //                         'Phone *',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.black54,
  //                         ),
  //                         textAlign: TextAlign.start,
  //                       ),
  //                       const SizedBox(height: 10),
  //                       TextFormField(
  //                         controller: phoneController,
  //                         maxLength: 10,
  //                         keyboardType: TextInputType.phone,
  //                         decoration: InputDecoration(
  //                           counterText: '',
  //                           // labelText: 'Enter your mobile number',
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           labelStyle: TextStyle(color: Colors.grey),
  //                           floatingLabelStyle: TextStyle(
  //                             color: Colors.deepOrangeAccent,
  //                           ),
  //                           // hintText: 'Ex. 1234567890',
  //                           prefixText: '+91 ',
  //                           hintStyle: TextStyle(color: Colors.grey),
  //                           // border: OutlineInputBorder(),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderSide: BorderSide(
  //                               color: Colors.deepOrangeAccent,
  //                               width: 2,
  //                             ),
  //                           ),
  //                         ),
  //                         // validator: (value) {
  //                         //   if (value == null || value.isEmpty) {
  //                         //     return 'Please enter your phone number';
  //                         //   }
  //                         //   if (value.length != 10) {
  //                         //     return 'Please enter a valid 10-digit number';
  //                         //   }
  //                         //   return null;
  //                         // },
  //                       ),

  //                       const SizedBox(height: 10),

  //                       // FormUnknownDropdown<StateModel>(
  //                       //   title: "State *",
  //                       //   hint: loadingCountries
  //                       //       ? "Loading states..."
  //                       //       : "Select State",
  //                       //   items: countries,
  //                       //   displayItem: (country) => country.name,
  //                       //   selectedValue: selectedState,
  //                       //   onChanged: loadingCountries
  //                       //       ? null
  //                       //       : (StateModel? newCountry) {
  //                       //           bottomSheetSetState(() {
  //                       //             selectedState = newCountry;
  //                       //             selectedCity =
  //                       //                 null; // Reset city when state changes
  //                       //             if (newCountry != null) {
  //                       //               loadCities(
  //                       //                 newCountry.id,
  //                       //                 bottomSheetSetState,
  //                       //               );
  //                       //             } else {
  //                       //               cities = [];
  //                       //             }
  //                       //           });
  //                       //         },
  //                       // ),
  //                       // 20.heightBox,

  //                       // // City Dropdown
  //                       // FormUnknownDropdown<CityModel>(
  //                       //   // key: ValueKey(cities.length),
  //                       //   // key: ValueKey(selectedState?.id),
  //                       //   title: "City *",
  //                       //   hint: loadingCities
  //                       //       ? "Loading cities..."
  //                       //       : selectedState == null
  //                       //       ? "Select state first"
  //                       //       : "Select City",
  //                       //   items: cities,
  //                       //   displayItem: (city) => city.name,
  //                       //   selectedValue: selectedCity,
  //                       //   enabled:
  //                       //       !loadingCities &&
  //                       //       selectedState != null &&
  //                       //       cities.isNotEmpty,
  //                       //   onChanged: (CityModel? newCity) {
  //                       //     bottomSheetSetState(() {
  //                       //       selectedCity = newCity;
  //                       //     });
  //                       //   },
  //                       // ),
  //                       const SizedBox(height: 25),

  //                       /// Buttons
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(context),
  //                             child: const Text('Cancel'),
  //                           ),
  //                           10.widthBox,
  //                           Expanded(
  //                             child: SizedBox(
  //                               width: double.infinity,
  //                               height: 50,
  //                               child: ElevatedButton(
  //                                 style: ElevatedButton.styleFrom(
  //                                   foregroundColor: Colors.white,
  //                                   backgroundColor: Colors.orange,
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                   ),
  //                                 ),
  //                                 onPressed: () async {
  //                                   // Navigator.pop(context);

  //                                   if (quantity == 0 ||
  //                                       product.id == null ||
  //                                       jobTitleController.text
  //                                           .trim()
  //                                           .isEmpty ||
  //                                       phoneController.text.trim().isEmpty ||
  //                                       emailController.text.trim().isEmpty ||
  //                                       selectedState?.name == null ||
  //                                       selectedCity?.name == null) {
  //                                     // ScaffoldMessenger.of(context);
  //                                     // Get.snackbar(
  //                                     //   "Please fill the required",
  //                                     //   "Data saved successfully",
  //                                     // );
  //                                     // Get.closeAllSnackbars();

  //                                     ScaffoldMessenger.of(
  //                                       context,
  //                                     ).showSnackBar(
  //                                       SnackBar(
  //                                         content: Text(
  //                                           "Please fill required (*) fields",
  //                                           style: TextStyle(
  //                                             color: Colors.white,
  //                                           ),
  //                                         ),
  //                                         backgroundColor: Colors.black87,
  //                                         behavior: SnackBarBehavior.floating,
  //                                         margin: EdgeInsets.all(12),
  //                                         shape: RoundedRectangleBorder(
  //                                           borderRadius: BorderRadius.circular(
  //                                             8,
  //                                           ),
  //                                         ),
  //                                         duration: Duration(seconds: 2),
  //                                       ),
  //                                     );

  //                                     return;
  //                                   }
  //                                   await _createEnquiry(
  //                                     product.id,
  //                                     quantity,
  //                                     commentController.text.trim(),
  //                                     jobTitleController.text.trim(),
  //                                     emailController.text.trim(),
  //                                     phoneController.text.trim(),
  //                                     selectedState?.name ?? '',
  //                                     selectedCity?.name ?? '',
  //                                   );
  //                                   Navigator.pop(context);
  //                                 },
  //                                 child: const Text('Submit Enquiry'),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       10.heightBox,
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
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
      final enquiryController = Get.find<JsEnquiryController>();
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

  // Future<void> loadCities(int stateId) async {
  //   final ApiServices apiService = Get.find<ApiServices>();
  //   setState(() {
  //     loadingCities = true;
  //     selectedCity = null; // Reset selected city when state changes
  //   });

  //   try {
  //     cities = await apiService.fetchCities(stateId);
  //   } catch (e) {
  //     print('Error loading cities: $e');
  //     cities = [];
  //   } finally {
  //     setState(() {
  //       loadingCities = false;
  //     });
  //   }
  // }

  // Future<void> _createEnquiry(
  //   String productId,
  //   int quantity,
  //   String? comments,
  //   String? phoneNumber,
  //   String? emailId,
  //   String? jobTitle,
  //   String? selectedState,
  //   String? selectedCity,
  // ) async {
  //   try {
  //     final enquiryController = Get.find<JsEnquiryController>();
  //     await enquiryController.createEnquiry(
  //       productId,
  //       quantity,
  //       comments,
  //       // phoneNumber,
  //       // emailId,
  //       // jobTitle,
  //       // selectedState,
  //       // selectedCity,
  //     );
  //   } catch (e) {
  //     print('Error creating enquiry: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to create enquiry: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
  String _getProductGST() {
    return widget.product!.gstPercentage.toString();
  }

  void _handleAddRemoveCart() {
    final prices = widget.product?.prices;
    final selectedPrice = prices!.isNotEmpty
        ? prices[selectedIndex].price.toDouble()
        : 0.0;

    final variant = prices.isNotEmpty ? prices[selectedIndex].size : 'Default';

    double gstPercentage = double.tryParse(_getProductGST()) ?? 0.0;

    final cartItem = JsCartitem(
      id: widget.product!.id,
      name: widget.product!.name,
      image: widget.product?.image ?? '',
      price: selectedPrice,
      gstPercentage: gstPercentage,
      quantity: 1,
      categorySlug: widget.product?.slug,
      selectedVariant: variant,
    );

    // if (cartController.cartItems.any((item) => item.id == cartItem.id)) {
    //   cartController.removeFromCart(cartItem.id, variant);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${cartItem.name} removed'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // } else {
    //   cartController.addToCart(cartItem);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${cartItem.name} added'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // }

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

  Widget _buildProductImage(String? url) {
    if (url == null || url.trim().isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}
