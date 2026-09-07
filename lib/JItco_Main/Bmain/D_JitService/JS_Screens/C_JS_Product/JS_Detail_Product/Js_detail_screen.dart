import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/A_Widgets/Rating_bar/rating_detail.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/state_city_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_drop_down.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_user.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/product_descrip.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/use_and_appli.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/B_JS_Enquiries/JS_enquires_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_Detail_Product/tabs/product_descrip_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_Detail_Product/tabs/use_and_appli_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:velocity_x/velocity_x.dart';

class JsDetailScreen extends StatefulWidget {
  final String slug;
  final String id;
  final String? warehouseId;
  final String? productType;

  const JsDetailScreen({
    super.key,
    required this.slug,
    required this.id,
    this.warehouseId,
    this.productType,
  });

  @override
  State<JsDetailScreen> createState() => _JsDetailScreenState();
}

class _JsDetailScreenState extends State<JsDetailScreen> {
  final ApiServices apiService = Get.find<ApiServices>();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  Map<String, dynamic>? productData;
  bool isLoading = true;
  int selectedIndex = 0;
  int selectedTabIndex = 0;

  final JsCartcontroller cartController = Get.find<JsCartcontroller>();

  List<StateModel> countries = [];
  List<CityModel> cities = [];

  StateModel? selectedCountry;
  CityModel? selectedCity;

  bool loadingCountries = true;
  bool loadingCities = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchProductDetails(widget.slug, widget.id);
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

  Future<void> loadCities(int stateId) async {
    setState(() {
      loadingCities = true;
      selectedCity = null; // Reset selected city when state changes
    });

    try {
      cities = await apiService.fetchCities(stateId);
    } catch (e) {
      print('Error loading cities: $e');
      cities = [];
    } finally {
      setState(() {
        loadingCities = false;
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchProductDetails(widget.slug, widget.id);
  // }

  Future<void> fetchProductDetails(String slug, String id) async {
    try {
      final dio = Dio();
      final authController = Get.find<AuthController>();
      final String currentUserId = authController.companyId.value;

      final response = await dio.get(
        '$jitUrl/public/product/$slug',
        queryParameters: {
          'slug': true,
          'source': 'Services',
          'user_id': currentUserId.isNotEmpty
              ? currentUserId
              : '68107ebd454e265270c26caa', // Fallback only if absolutely needed
          if (widget.warehouseId != null) 'warehouse': '${widget.warehouseId}',
        },
        options: Options(validateStatus: (_) => true),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data['products'] != null) {
        setState(() {
          productData = response.data['products'];
          isLoading = false;
        });
      } else {
        debugPrint('❌ API FAILED => ${response.data}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ API ERROR => $e');
      setState(() => isLoading = false);
    }
  }

  void _addToCart() {
    if (productData == null) return;

    final prices = productData!['price'] as List<dynamic>? ?? [];

    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    final selectedVariant = prices.isNotEmpty
        ? prices[selectedIndex]['size']
        : 'Basic';

    final cartItem = JsCartitem(
      id: productData!['_id'] ?? '',
      name: productData!['productName'] ?? '',
      image: (productData!['productImage'] as List).isNotEmpty
          ? productData!['productImage'][0]
          : '',
      price: selectedPrice.toDouble(),
      quantity: 1,
      categorySlug: productData!['slug'] ?? '',
      selectedVariant: selectedVariant,
      selectedSize: selectedVariant,
    );

    final isInCart = cartController.cartItems.any(
      (item) =>
          item.id == cartItem.id && item.selectedVariant == selectedVariant,
    );

    if (isInCart) {
      cartController.removeFromCart(cartItem.id, selectedVariant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} removed from cart'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      cartController.addToCart(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (productData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SafeArea(
            child: Text('Product not found', style: TextStyle(fontSize: 15)),
          ),
        ),
      );
    }

    final name = productData?['productName'] ?? '';
    final description = productData?['productLongDescription'] ?? '';
    final images = productData?['productImage'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final prices = productData?['price'] as List<dynamic>? ?? [];
    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    // final isInCart = cartController.cartItems.any(
    //   (item) => item.id == productData!['_id'],
    // );
    // final prices = productData?['price'] as List<dynamic>? ?? [];

    final selectedVariant = prices.isNotEmpty
        ? prices[selectedIndex]['size']
        : null;

    final isInCart = cartController.cartItems.any(
      (item) =>
          item.id == productData!['_id'] &&
          item.selectedVariant == selectedVariant,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(name),
        //   centerTitle: false,
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black,
        //   elevation: 0,
        // ),
        // backgroundColor: Colors.white,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: false,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),

                /// PRODUCT CONTENT
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 20),

                      /// IMAGE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade200,
                          ),
                          child: imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    imageUrl,
                                    // fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported, size: 80),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NAME
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// DESCRIPTION
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 16,
                      //     vertical: 6,
                      //   ),
                      //   child: Text(description),
                      // ),
                      const SizedBox(height: 15),

                      /// BRAND
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _brandSection(productData?['brand']?['image']),
                            5.widthBox,
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.yellow.shade200,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                productData?['brand']?['name'],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// PRICE OPTIONS
                      if (prices.isNotEmpty && selectedPrice != 0) ...[
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: prices.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == selectedIndex;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedIndex = index),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${prices[index]['size']} (₹${prices[index]['price']})',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 15),

                      /// PRICE
                      if (selectedPrice != 0) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "₹$selectedPrice",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Exclusive of all taxes"),
                        ),
                      ],

                      const SizedBox(height: 10),

                      /// RATING
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            // Row(
                            //   children: [
                            //     RatingBarIndicator(
                            //       rating: 4.4,
                            //       itemCount: 5,
                            //       itemSize: 20,
                            //       itemBuilder: (_, __) =>
                            //           const Icon(Icons.star, color: Colors.amber),
                            //     ),
                            //     const SizedBox(width: 8),
                            //     const Text("4.4 (58 reviews)"),
                            //   ],
                            // ),
                            RatingDetail(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                /// STICKY TABS (SAME AS OLD)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      color: Colors.white,
                      child: const TabBar(
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.orange,
                        indicatorWeight: 2,
                        tabs: [
                          Tab(text: "Service Description"),
                          Tab(text: "Usage & Applications"),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },

            /// TAB CONTENT (SAME AS OLD)
            body: TabBarView(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: Text(productData?['productLongDescription'] ?? ''),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: Text(
                //     productData?['usageAndApplications'] ?? 'No data',
                //   ),
                // ),
                ProductDescripService(productData: productData),
                UseAndAppliService(productData: productData),
              ],
            ),
          ),
        ),

        /// BOTTOM BAR (100% SAME AS PREVIOUS)
        bottomNavigationBar: Obx(() {
          final prices = productData?['price'] as List<dynamic>? ?? [];

          final selectedVariant = prices.isNotEmpty
              ? prices[selectedIndex]['size']
              : null;

          final isInCart = cartController.cartItems.any(
            (item) =>
                item.id == productData!['_id'] &&
                item.selectedVariant == selectedVariant,
          );
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedPrice == 0)
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Obx(() {
                        final jsEnquiryController =
                            Get.find<JsEnquiryController>();
                        final isInEnquiry = jsEnquiryController.jlEnquiryItems
                            .any(
                              (enquiry) =>
                                  enquiry.productId == productData?['_id'],
                            );

                        return TextButton(
                          onPressed: () async {
                            if (isInEnquiry) {
                              // Navigate to enquiry screen
                              Get.to(() => JsEnquiresScreen());
                            } else {
                              /// Show quantity dialog and create enquiry
                              _showEnquiryDialog(context, productData);
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
                  if (selectedPrice != 0)
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart
                                      ? Colors.red
                                      : Colors.orange.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _addToCart,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isInCart
                                          ? Icons.remove_shopping_cart
                                          : Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isInCart
                                          ? 'Remove from Cart'
                                          : 'Add to Cart',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (isInCart) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Get.to(() => JsBottomNavBar(initialIndex: 4));
                                  if (widget.productType == 'Services') {
                                    Get.to(
                                      () => JsBottomNavBar(initialIndex: 4),
                                    );
                                  } else {
                                    Get.find<JsBottomNavController>().switchTab(
                                      4,
                                    );
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          final navigator = Navigator.of(
                                            context,
                                          );

                                          if (navigator.canPop()) {
                                            navigator.pop();
                                          }
                                        });
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: JsCartBadgeIcon(
                                  isActive: true,
                                  iconSize: 24,
                                  activeColor: Colors.grey,
                                  nonActiveColor: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _brandSection(dynamic image) {
    return Row(
      children: [
        if (image != null && image.isNotEmpty)
          CircleAvatar(radius: 25, backgroundImage: NetworkImage(image))
        else
          const CircleAvatar(radius: 25, child: Icon(Icons.business)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget buildTab({required String text, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 3,
            width: 160,
            decoration: BoxDecoration(
              color: selectedTabIndex == index ? Colors.orange : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
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

  //   Future<void> _createEnquiry(
  //     String productId,
  //     int quantity,
  //     String? comments,
  //     String? phoneNumber,
  //     String? emailId,
  //     String? jobTitle,
  //     String? selectedState,
  //     String? selectedCity,
  //   ) async {
  //     try {
  //       final enquiryController = Get.find<JsEnquiryController>();
  //       await enquiryController.createEnquiry(
  //         productId,
  //         quantity,
  //         comments,
  //         phoneNumber,
  //         emailId,
  //         jobTitle,
  //         selectedState,
  //         selectedCity,
  //       );
  //     } catch (e) {
  //       print('Error creating enquiry: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to create enquiry: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
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
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
