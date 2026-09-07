import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/PostModel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/dialog_logout.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/C_Profile_Settings/profile_settings.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/b_JM_Category/jm_category_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/c_JM_Product_Screen/jm_detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/jitco_menu_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_Detail_Product/Js_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_service_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/grid_item.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/jitco_about.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/about_screen.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/main_search/main_search_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class JItcoMain extends StatefulWidget {
  const JItcoMain({super.key});

  @override
  State<JItcoMain> createState() => _JItcoMainState();
}

class _JItcoMainState extends State<JItcoMain> with RouteAware {
  final ApiServices _apiService = Get.find<ApiServices>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final JmCategoryController jmCategoryController = Get.put(
    JmCategoryController(),
  );
  final JlCategoryController jlCategoryController = Get.put(
    JlCategoryController(),
  );

  final JLCategoryController _jlCategoryController = Get.put(
    JLCategoryController(),
  );

  List<SearchedProduct> searchResults = [];
  Timer? _debounce;
  int page = 1;
  bool isSearchLoadingMore = false;
  bool hasSearchMore = true;
  bool isSearching = false;
  bool showResults = false;
  bool isFetching = false;

  List<CategoryData> displayedCategories = [];

  OutletModel? cityWarehouse;
  String? _warehouseId;

  bool _isSearching = false;
  int _currentPage = 1;
  static const int _limit = 20;
  int _totalPages = 1;
  bool isLoadingInitial = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  void _clearSearch() {
    _debounce?.cancel(); // stop pending calls

    _searchController.clear();

    setState(() {
      searchResults.clear();
      showResults = false;
      isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(isInitial: true);

    _scrollController.addListener(_onScroll);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {});
      }
    });
    _fetchIdFromWarehouse();

    _searchScrollController.addListener(() {
      if (_searchScrollController.position.pixels >=
              _searchScrollController.position.maxScrollExtent - 50 &&
          !isSearchLoadingMore &&
          !isFetching &&
          hasSearchMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    isFetching = true; // lock immediately

    await _searchProducts(_searchController.text, isLoadMore: true);

    isFetching = false; // unlock
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoadingMore) {
        _currentPage++;
        fetchProducts(isInitial: false);
      }
    }
  }

  Future<void> fetchProducts({required bool isInitial}) async {
    if (!hasMore && !isInitial) return;

    if (isInitial) {
      if (mounted) setState(() => isLoadingInitial = true);
    } else {
      if (mounted) setState(() => isLoadingMore = true);
    }

    try {
      final result = await _apiService.fetchProductCategories(
        page: _currentPage,
        limit: _limit,
        search: '',
      );

      if (mounted) {
        setState(() {
          _totalPages = (result.totalPages ?? 1).toInt();
          // _totalPages = int.tryParse(result.totalPages?.toString() ?? '1') ?? 1;

          if (result.data != null) {
            if (isInitial) {
              displayedCategories = result.data!;
            } else {
              displayedCategories.addAll(result.data!);
            }
          }

          hasMore = _currentPage < _totalPages;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      // You can show a snackbar or dialog for error handling
    }

    if (mounted) {
      setState(() {
        isLoadingInitial = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _searchProducts(String value, {bool isLoadMore = false}) async {
    if (!isLoadMore) {
      // only reset for new search
      page = 1;
      hasSearchMore = true;
      searchResults.clear();
    }

    setState(() {
      isSearchLoadingMore = true;
    });

    final res = await _apiService.searchProducts(
      query: value,
      page: page,
      limit: 20,
    );

    if (res != null) {
      setState(() {
        if (isLoadMore) {
          searchResults.addAll(res.results ?? []);
        } else {
          searchResults = res.results ?? [];
        }

        hasSearchMore = (res.results?.length ?? 0) >= 20;

        if (hasSearchMore) {
          page++; // now works correctly
        }
      });
    }

    setState(() {
      isSearchLoadingMore = false;
    });
  }

  void _onCategoryJITSupply(CategoryData category) {
    Get.to(
      () => UniversalProductScreen(
        id: category.id,
        categorySlug: category.slug,
        categoryName: category.categoryName,
        isBrandScreen: false, // This is a category screen, not brand
      ),
      transition: Transition.rightToLeft,
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => UniversalProductScreen(
    //       id: category.id,
    //       categorySlug: category.slug,
    //       categoryName: category.categoryName,
    //       isBrandScreen: false, // This is a category screen, not brand
    //     ),
    //   ),
    // );
  }

  void _onCategoryJITMenu(CategoryModel category) {
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

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // IMPORTANT: handle empty immediately
    if (value.trim().isEmpty) {
      setState(() {
        searchResults.clear();
        showResults = false;
        isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        showResults = true;
        isSearching = true;
      });

      _searchProducts(value).then((_) {
        setState(() => isSearching = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("JIT: $displayedCategories");
    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  10.heightBox,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// LEFT SIDE (Avatar)
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  _showProfileMenu(context);
                                },
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey.shade100,
                                  child:
                                      // Text(
                                      //   "A",
                                      //   style: TextStyle(
                                      //     color: Colors.black,
                                      //     fontSize: 20,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      Icon(
                                        Icons.account_circle,
                                        size: 29,
                                        // color: Colors.orange.shade700,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        /// CENTER (Logo)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              logo,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "One Platform. Every\nFood Service Need.\nDelivered Just-In-Time.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildMainCard(
                          context,
                          itemList[0],
                          const Color(0xFF008DFF),
                          Icons.business_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildMainCard(
                          context,
                          itemList[1],
                          const Color(0xFFFF8A00),
                          Icons.restaurant_menu_rounded,
                        ),
                        const SizedBox(height: 10),
                        _buildMainCard(
                          context,
                          itemList[2],
                          const Color(0xFF4A4B57),
                          Icons.build_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Text(
                  //     'Crafted with ❤️ in India | Delivered Just-In-Time',
                  //     style: TextStyle(
                  //       fontFamily: "Inter",
                  //       fontSize: 18,
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                ],
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(fontFamily: "Inter", fontSize: 20),
                          children: [
                            TextSpan(
                              text: "Discover ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: "Everything Jitco",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Your one-stop platform for all JITCO services. Search across thousands of products and services.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: "Search products...",
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.orange,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(70),
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.grey,
                                          ),
                                          onPressed: _clearSearch,
                                        )
                                      : null,
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                            // const SizedBox(width: 5),
                            // SizedBox(
                            //   height: double.infinity,
                            //   child: ElevatedButton(
                            //     onPressed: () {},
                            //     style: ElevatedButton.styleFrom(
                            //       foregroundColor: Colors.white,
                            //       backgroundColor: Colors.orange.shade700,
                            //     ),
                            //     child: const Text("Search"),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      if (showResults)
                        Container(
                          height: searchResults.isEmpty ? 80 : 300,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: isSearching
                              ? const Center(child: CircularProgressIndicator())
                              : searchResults.isEmpty
                              ? Center(child: const Text("No products found"))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: _searchScrollController,
                                  // itemCount: searchResults.length > 5
                                  //     ? 5
                                  //     : searchResults.length,
                                  itemCount:
                                      searchResults.length +
                                      (isSearchLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == searchResults.length) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    final product = searchResults[index];

                                    return ListTile(
                                      leading: Image.network(
                                        product.productImage?.isNotEmpty == true
                                            ? product.productImage!.first
                                            : "",
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      ),
                                      title: Text(
                                        product.productName ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: TextButton(
                                        onPressed: () {
                                          if (product.productType == 'Jitco') {
                                            Get.to(
                                              () => DetailProductScreen(
                                                productSlug: product.slug ?? '',
                                                productType:
                                                    product.productType,
                                              ),
                                            );
                                          }
                                          if (product.productType ==
                                              'JitMenu') {
                                            Get.to(
                                              () => JMDetailProductScreen(
                                                productSlug: product.slug ?? '',
                                                warehouseId: _warehouseId,
                                                productType:
                                                    product.productType,
                                              ),
                                              // arguments: {"id": product.id},
                                            );
                                          }
                                          if (product.productType == 'Liquor') {
                                            Get.to(
                                              () => JlDetailScreen(
                                                slug: product.slug ?? '',
                                                id: product.id ?? '',
                                                productType:
                                                    product.productType,
                                                warehouseId: _warehouseId,
                                              ),
                                            );
                                          }
                                          if (product.productType ==
                                              'Services') {
                                            Get.to(
                                              () => JsDetailScreen(
                                                slug: product.slug ?? '',
                                                id: product.id ?? '',
                                                warehouseId: _warehouseId,
                                                productType:
                                                    product.productType,
                                              ),
                                              transition:
                                                  Transition.rightToLeft,
                                            );
                                          }
                                          // Navigate to details page
                                        },
                                        child: const Text("View"),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      const SizedBox(height: 40),
                      sourceHead(
                        "JIT Supply",
                        "Start Ordering Smarter",
                        Colors.blue,
                        () {
                          Get.to(() => JitcoSupplyNavBar(initialIndex: 2));
                        },
                      ),
                      const SizedBox(height: 20),
                      isLoadingInitial
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            )
                          : displayedCategories.isEmpty
                          ? const Center(
                              child: Text(
                                "No categories found!",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : GridView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 20),
                              // itemCount:
                              //     displayedCategories.length +
                              //     (isLoadingMore ? 1 : 0),
                              itemCount:
                                  (displayedCategories.length > 4
                                      ? 4
                                      : displayedCategories.length) +
                                  (isLoadingMore ? 1 : 0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.1,
                                  ),
                              itemBuilder: (context, index) {
                                if (index == displayedCategories.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  );
                                }

                                final category = displayedCategories[index];

                                return GestureDetector(
                                  onTap: () => _onCategoryJITSupply(category),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            category.image ?? "",
                                            height: 90,
                                            width: 90,
                                            // fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
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
                                              category.categoryName ??
                                                  "No Name",
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
                      const SizedBox(height: 25),
                      sourceHead(
                        "JIT Menu",
                        "Optimize Your Menu",
                        Colors.orange,
                        () {
                          Get.to(() => JitcoMenuNavBar(initialIndex: 2));
                        },
                      ),
                      const SizedBox(height: 20),
                      // Categories Grid
                      Obx(() {
                        if (jmCategoryController.isLoading.value &&
                            jmCategoryController.categoryList.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          );
                        }

                        if (jmCategoryController.categoryList.isEmpty) {
                          return const Center(
                            child: Text(
                              "No categories found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
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
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 20),
                            // itemCount:
                            //     controller.categoryList.length +
                            //     (controller.isLoadingMore.value ? 1 : 0),
                            itemCount:
                                min(
                                  4,
                                  jmCategoryController.categoryList.length,
                                ) +
                                (jmCategoryController.isLoadingMore.value
                                    ? 1
                                    : 0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                ),
                            itemBuilder: (context, index) {
                              // Loading indicator for load more
                              if (index ==
                                  jmCategoryController.categoryList.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  ),
                                );
                              }

                              final category =
                                  jmCategoryController.categoryList[index];
                              return GestureDetector(
                                onTap: () => _onCategoryJITMenu(category),
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
                      /*
                      const SizedBox(height: 25),
                      sourceHead(
                        "JIT Liquor",
                        "Explore Liquor Brands",
                        Colors.grey,
                        () {
                          Get.to(() => JlBottomNavBar(initialIndex: 2));
                        },
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        if (_jlCategoryController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        ///TRY SHIMMER IN THIS
                        // if (controller.isLoading.value) {
                        //   return GridView.builder(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 12,
                        //       vertical: 8,
                        //     ),
                        //     gridDelegate:
                        //         const SliverGridDelegateWithFixedCrossAxisCount(
                        //           crossAxisCount: 2,
                        //           crossAxisSpacing: 8,
                        //           mainAxisSpacing: 8,
                        //           childAspectRatio: 1.1,
                        //         ),
                        //     itemCount: 6, // number of skeleton items
                        //     itemBuilder: (_, __) => const CategorySkeletonItem(),
                        //   );
                        // }
                        if (_jlCategoryController.liqourList.isEmpty) {
                          return const Center(
                            child: Text(
                              "No Categories found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.1,
                              ),
                          // itemCount: controller.filteredList.length,
                          // itemCount: controller.liqourList.length,
                          // itemCount:
                          //     _jlCategoryController.liqourList.length +
                          //     (_jlCategoryController.isLoadingMore.value
                          //         ? 1
                          //         : 0),
                          itemCount:
                              min(4, _jlCategoryController.liqourList.length) +
                              (_jlCategoryController.isLoadingMore.value
                                  ? 1
                                  : 0),

                          ///TRY SHIMMER IN THIS
                          // itemCount:
                          //     controller.liqourList.length +
                          //     (controller.isLoadingMore.value ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index >=
                                _jlCategoryController.liqourList.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            final item =
                                _jlCategoryController.liqourList[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => JlProductScreen(
                                    title: _jlCategoryController
                                        .liqourList[index]
                                        .name,
                                    categorySlugs: _jlCategoryController
                                        .liqourList[index]
                                        .slug,
                                    categoryId: _jlCategoryController
                                        .liqourList[index]
                                        .id,
                                    // id: controller.filteredList[index].id,
                                  ),
                                );
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (_) => JlProductScreen(
                                //       categorySlugs: controller.liqourList[index].slug,
                                //       categoryId: controller.liqourList[index].id,
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
                                        height: 100,
                                        width: 100,
                                        // fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
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
                          },
                        );
                      }),
                      */
                      const SizedBox(height: 25),
                      sourceHead(
                        "JIT Service",
                        "Find Verified Services",
                        Colors.green,
                        () {
                          Get.to(() => JsBottomNavBar(initialIndex: 2));
                        },
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        if (jmCategoryController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final list = jlCategoryController.liqourList;

                        if (list.isEmpty) {
                          return const Center(
                            child: Text(
                              "No categories available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          // itemCount: list.length, // ← dynamic & correct
                          itemCount: list.length > 4 ? 4 : list.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.1,
                              ),
                          itemBuilder: (context, index) {
                            final item = list[index]; // safe now

                            return GestureDetector(
                              onTap: () {
                                debugPrint("CATEGORY SLUG  ${item.slug}");
                                Get.to(
                                  () => JsServiceScreen(
                                    title: "Our Services",
                                    categorySlug: item.slug,
                                    categoryId: item.id,
                                    slug: true,
                                    warehouseId: _warehouseId,
                                  ),
                                  arguments: {"categorySlug": item.slug},
                                  transition: Transition.rightToLeft,
                                );
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (_) => JsServiceScreen(
                                //       title: "Our Services",
                                //       categorySlug: item.slug,
                                //       categoryId: item.id,
                                //       slug: true,
                                //       warehouseId: _warehouseId,
                                //     ),
                                //   ),
                                // );

                                ///NAVIGATOR ANIMATION- WORKING
                                // Navigator.of(context).push(
                                //   PageRouteBuilder(
                                //     pageBuilder: (_, animation, __) => JsServiceScreen(
                                //       title: item.categoryName,
                                //       categorySlug: item.slug,
                                //       categoryId: item.id,
                                //       slug: true,
                                //       warehouseId: _warehouseId,
                                //     ),
                                //     transitionsBuilder: (_, animation, __, child) {
                                //       final offsetAnimation = Tween(
                                //         begin: const Offset(1.0, 0.0), // Right → Left
                                //         end: Offset.zero,
                                //       ).animate(animation);
                                //       return SlideTransition(
                                //         position: offsetAnimation,
                                //         child: child,
                                //       );
                                //     },
                                //   ),
                                // );
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                                bottom: Radius.circular(20),
                                              ),
                                          child: Image.network(
                                            item.image.isNotEmpty
                                                ? item.image
                                                : "",
                                            height: 100,
                                            width: 100,
                                            // fit: BoxFit.fitHeight,
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  );
                                                },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 90,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                      // 10.heightBox,
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Text(
                                                item.categoryName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // const SizedBox(height: 4),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 40),
                      Container(height: 0.4, color: Colors.grey[400]),
                      25.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(
                            FontAwesomeIcons.facebook,
                            "https://www.facebook.com/jitco.inn",
                            Colors.blue.shade800,
                          ),
                          18.widthBox,
                          _buildSocialIcon(
                            FontAwesomeIcons.instagram,
                            "https://www.instagram.com/jitcoindia/",
                            Colors.pink,
                          ),
                          18.widthBox,
                          _buildSocialIcon(
                            FontAwesomeIcons.xTwitter,
                            "https://x.com/Jitco_in/",
                            Colors.black,
                          ),
                          18.widthBox,
                          _buildSocialIcon(
                            FontAwesomeIcons.linkedin,
                            "https://www.linkedin.com/company/jitcoindia/",
                            Colors.blue.shade700,
                          ),
                          18.widthBox,
                          _buildSocialIcon(
                            FontAwesomeIcons.youtube,
                            "https://www.youtube.com/@JITCO_IN",
                            Colors.red,
                          ),
                        ],
                      ),
                      12.heightBox,
                      Text(
                        rightsReserved,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      20.heightBox,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Profile Settings"),
                  onTap: () {
                    // Get.back();
                    Navigator.pop(context);
                    Get.to(
                      () => ProfileSettings(),
                      transition: Transition.downToUp,
                    );
                  },
                ),

                ListTile(
                  leading: Icon(Icons.account_box_outlined),
                  title: Text("About Us"),
                  onTap: () {
                    // Get.back();
                    Navigator.pop(context);
                    Get.to(() => About(), transition: Transition.downToUp);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text("Delete Account", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    showDeleteAccountDialog(context);
                  },
                ),

                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // Get.back();
                    // Navigator.pop(context);
                    showCommonDialog(context);
                  },
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget sourceHead(
    String? title,
    String? subTitle,
    Color? color,
    VoidCallback onPress,
  ) {
    return SizedBox(
      child: Column(
        children: [
          // ListTile(
          //   leading: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: Colors.blue,
          //     ),
          //     padding: const EdgeInsets.all(15),
          //     child: Icon(
          //       Icons.inventory_2,
          //       color: Colors.white,
          //       size: 16,
          //     ),
          //   ),
          //   title: const Text("JIT Supply"),
          //   subtitle: const Text("Start Ordering Smarter"),
          //   trailing: ElevatedButton(
          //     onPressed: () {},
          //     style: ElevatedButton.styleFrom(
          //       foregroundColor: Colors.white,
          //       backgroundColor: Colors.blue,
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         const Text("View All"),
          //         const SizedBox(width: 5),
          //         const Icon(Icons.arrow_forward_ios),
          //       ],
          //     ),
          //   ),
          // ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color,
                ),
                child: Icon(Icons.inventory, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title!, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(subTitle!, style: TextStyle(fontSize: 12)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  onPress();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    const Text("View"),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(dynamic icon, String url, Color color) {
    return InkWell(
      onTap: () async {
        try {
          final Uri uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("Could not launch $url: $e");
        }
      },
      child: FaIcon(icon, color: color, size: 24),
    );
  }

  Widget _buildMainCard(BuildContext context, GridItem item, Color iconBg, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => item.route(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutQuart;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Row(
                children: [
                   // 1. Brand Icon Section
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  // 2. Text Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3. Photo Section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item.imagePath,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1.2,
              width: double.infinity,
              color: Colors.grey.shade100,
            ),
            // 4. Footer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "Tap to explore",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
