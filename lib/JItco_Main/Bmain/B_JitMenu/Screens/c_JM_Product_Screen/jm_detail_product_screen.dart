import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:jitco_app/A_Widgets/Rating_bar/rating_detail.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/JM_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/JM_Enquiry/jm_enquiry_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Widgets/jm_cart_badge_icon.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/jitco_menu_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/product_descrip.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/use_and_appli.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class JMDetailProductScreen extends StatefulWidget {
  final String? warehouseId;
  final String productSlug;
  final String? productType;
  const JMDetailProductScreen({
    super.key,
    this.warehouseId,
    this.productSlug = "",
    this.productType,
  });

  @override
  State<JMDetailProductScreen> createState() => _JMDetailProductScreenState();
}

class _JMDetailProductScreenState extends State<JMDetailProductScreen>
    with SingleTickerProviderStateMixin {
  final jmApiService = Get.put(JMApiService);
  final AuthController authController = Get.find<AuthController>();
  final JmCartController _cartController = Get.find<JmCartController>();

  Map<String, dynamic>? productData;
  bool isLoading = true;
  int selectedIndex = 0;
  int selectedTabIndex = 0;
  int selected = 0;
  late TabController _tabController;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    try {
      final dio = Dio();
      String url =
          "$jitUrl/public/product/${widget.productSlug}?slug=true&source=JitMenu&user_id=${authController.userId.value}";

      if (widget.warehouseId != null && widget.warehouseId!.isNotEmpty) {
        url += "&warehouse=${widget.warehouseId}";
      }

      final response = await dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          productData = response.data['products'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = "Failed to load product details";
        });
      }
    } catch (e) {
      print("API ERROR: $e");
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  String get brandName => productData?['brand']?['name'] ?? 'Unknown Brand';

  String? getProductImage() {
    final images = productData?['productImage'];
    if (images is List &&
        images.isNotEmpty &&
        images[0] != null &&
        images[0].isNotEmpty) {
      return images[0];
    }
    return null;
  }

  String _getProductName() {
    return productData?['productName'] ?? 'Unknown Product';
  }

  String _getProductPrice() {
    return productData?['universalPrice']?.toString() ??
        productData?['mrp']?.toString() ??
        '0';
  }

  String _getProductGST() {
    return productData?['gstPercentage']?.toString() ?? '0';
  }

  String _getProductDescription() {
    return productData?['productShortDescription'] ??
        productData?['productLongDescription'] ??
        'No description available';
  }

  String _getBrandName() {
    return productData?['brand']?['name'] ?? 'Unknown Brand';
  }

  List<String> _getHighlights() {
    final highlights = productData?['highlights'] ?? '';
    if (highlights is String && highlights.isNotEmpty) {
      return highlights
          .replaceAll('<p>', '\n')
          .replaceAll('</p>', '\n')
          .split('\n');
    }
    return [];
  }

  List<String> _getKeywords() {
    final keywords = productData?['keywords'] ?? '';
    if (keywords is String && keywords.isNotEmpty) {
      return keywords.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  // bool get _isProductInCart {
  //   if (productData == null) return false;
  //   final productId = productData?['_id'] ?? '';
  //   return _cartController.cartItems.any((item) => item.id == productId);
  // }

  bool get _isProductInCart {
    if (productData == null) return false;

    final productId = productData?['_id'] ?? '';

    return _cartController.cartItems.any(
      (item) =>
          item.id == productId && item.selectedVariant == _selectedVariant,
    );
  }

  void _addToCart() {
    if (productData != null) {
      final productId = productData?['_id'] ?? '';
      final productName = _getProductName();
      final categorySlug = productData?['slug'] ?? '';
      final quantityPerBox = productData?['quantityPerBox'] ?? 1;
      final uom = productData?['uom'] ?? 'item';

      double itemPrice = 0.0;
      String? variantType = 'piece';

      // Calculate price based on selected variant
      final prices = productData?['price'] ?? [];
      if (prices.isNotEmpty && selectedIndex < prices.length) {
        itemPrice = (prices[selectedIndex]['price'] ?? 0).toDouble();
        variantType = prices[selectedIndex]['size']?.toString().toLowerCase();
      }

      double gstPercentage = double.tryParse(_getProductGST()) ?? 0.0;

      final cartItem = JmCartItem(
        id: productId,
        name: productName,
        image: getProductImage() ?? '',
        price: itemPrice,
        gstPercentage: gstPercentage,
        quantity: 1,
        categorySlug: categorySlug,
        // selectedVariant: prices.isNotEmpty && selectedIndex < prices.length
        //     ? prices[selectedIndex]['size']?.toString() ?? 'Default'
        //     : 'Default',
        selectedVariant: _selectedVariant,
        originalPrice: itemPrice,
        warehouseId: null,
        quantityPerBox: quantityPerBox,
        uom: uom,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add product to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String get _selectedVariant {
    final prices = productData?['price'] ?? [];

    if (prices.isNotEmpty && selectedIndex < prices.length) {
      return prices[selectedIndex]['size']?.toString() ?? 'Default';
    }

    return 'Default';
  }

  // void _removeFromCart() {
  //   if (productData != null) {
  //     final productId = productData?['_id'] ?? '';
  //     final productName = _getProductName();

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
    if (productData != null) {
      final productId = productData?['_id'] ?? '';
      final productName = _getProductName();
      final variant = _selectedVariant;

      _cartController.removeFromCart(productId, variant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName ($variant) removed from cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleCart() {
    if (_isProductInCart) {
      _removeFromCart();
    } else {
      _addToCart();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Loading product details...'),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.pop(context),
          // ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text('Error loading product'),
              SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchProductDetails,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final productName = productData?['productName'] ?? '';
    final description = productData?['productLongDescription'] ?? '';
    final prices = productData?['price'] ?? [];
    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    final bool showTabs =
        productData?['usp'] != null ||
        productData?['productLongDescription'] != null ||
        productData?['dietary'] != null ||
        productData?['vegNoneveg'] != null ||
        productData?['ingredients'] != null ||
        productData?['instructions'] != null ||
        productData?['usage'] != null;

    return DefaultTabController(
      length: showTabs ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(productName),
          centerTitle: false,
          backgroundColor: Colors.white,
          // surfaceTintColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProductContent()),
              if (showTabs)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.orange,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.orange,
                        indicatorWeight: 2,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        tabs: [
                          Tab(text: "Product Description"),
                          Tab(text: "Usage & Applications"),
                        ],
                      ),
                    ),
                  ),
                ),
            ];
          },
          body: showTabs
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    ProductDescrip(productData: productData),
                    UseAndAppli(productData: productData),
                  ],
                )
              : Container(),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: IntrinsicWidth(
              child: SizedBox(
                height: 50,
                child: selectedPrice > 0
                    ? Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isProductInCart
                                        ? Colors.red
                                        : Colors.orange.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _toggleCart,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isProductInCart
                                            ? Icons.remove_shopping_cart
                                            : Icons.shopping_cart,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _isProductInCart
                                            ? 'Remove from Menu'
                                            : 'Add to Menu',
                                        style: TextStyle(
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
                            if (_isProductInCart) ...[
                              SizedBox(width: 8),
                              SizedBox(
                                height: 70,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Get.to(
                                    //   () => JitcoMenuNavBar(initialIndex: 4),
                                    // );
                                    if (widget.productType == 'JitMenu') {
                                      Get.to(
                                        () => JitcoMenuNavBar(initialIndex: 4),
                                      );
                                    } else {
                                      Get.find<JmBottomNavController>()
                                          .switchTab(4);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            final navigator = Navigator.of(
                                              context,
                                            );

                                            if (navigator.canPop()) {
                                              navigator.pop();
                                            }
                                          });
                                      // Navigate to cart screen or other destination
                                      // Get.to(() => YourCartScreen());
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(10),
                                    ),
                                  ),
                                  child: JmCartBadgeIcon(
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
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: SizedBox(
                          height: 35,
                          width: 70,
                          child: Obx(() {
                            final jmEnquiryController =
                                Get.find<JmEnquiryController>();
                            final isInEnquiry = jmEnquiryController.enquiryItems
                                .any(
                                  (enquiry) =>
                                      enquiry.productId == productData?['_id'],
                                );

                            return TextButton(
                              onPressed: () async {
                                if (isInEnquiry) {
                                  // Navigate to enquiry screen
                                  Get.to(() => JmEnquiryScreen());
                                } else {
                                  // Show quantity dialog and create enquiry
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
                      ),
              ),
            ),
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
          title: Text('Enquire for ${product['productName']}'),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          content: Column(
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
                          borderSide: BorderSide(color: Colors.orange.shade700),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Future<void> _createEnquiry(String productId, int quantity, comments) async {
    try {
      final enquiryController = Get.find<JmEnquiryController>();
      await enquiryController.createEnquiry(
        context,
        productId,
        quantity,
        comments,
      );
    } catch (e) {
      print('Error creating enquiry: $e');

      Get.snackbar(
        "Error",
        "Failed to create enquiry",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildProductContent() {
    final productName = productData?['productName'] ?? '';
    final productId = productData?['id'] ?? '';
    final description = productData?['productLongDescription'] ?? '';
    final prices = productData?['price'] ?? [];
    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: getProductImage() != null
                ? Image.network(
                    getProductImage()!,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            productName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 6),
          child: Text(description),
        ),
        const SizedBox(height: 15),
        _brandSection(productData?['brand']?['image']),
        if (selectedPrice == 0) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12),
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
          const SizedBox(height: 10),
        ],
        if (prices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: ListView.builder(
                // physics: const NeverScrollableScrollPhysics(),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${prices[index]['size']} (₹${prices[index]['price']})',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (selectedPrice != 0) ...[
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "₹$selectedPrice",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text("Exclusive of all taxes"),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12),
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
        // Center(
        //   child: SizedBox(
        //     width: 300,
        //     child: ElevatedButton(
        //       onPressed: () {},
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.orangeAccent,
        //       ),
        //       child: const Text("Add to menu"),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 20),
        if (_getHighlights().isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Product Highlights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade50,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getHighlights().map((highlight) {
                    return Text('$highlight');
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
        if (_getKeywords().isNotEmpty) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Keywords',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getKeywords().take(5).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange.shade700,
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _brandSection(dynamic image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (image != null && image.isNotEmpty)
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(image))
          else
            const CircleAvatar(radius: 20, child: Icon(Icons.business)),
          const SizedBox(width: 10),
          Text(
            brandName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          size: 60,
          color: Colors.grey[400],
        ),
        SizedBox(height: 8),
        Text('No image available', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

// Custom delegate for sticky tab bar
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
