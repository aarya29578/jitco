import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/A_Widgets/Rating_bar/rating_detail.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/product_descrip.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/use_and_appli.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_cartcontroller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartcount.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:velocity_x/velocity_x.dart';

class JlDetailScreen extends StatefulWidget {
  final String slug;
  final String id;
  final String? warehouseId;
  final String? productType;

  const JlDetailScreen({
    super.key,
    required this.slug,
    required this.id,
    this.warehouseId,
    this.productType,
  });

  @override
  State<JlDetailScreen> createState() => _JlDetailScreenState();
}

class _JlDetailScreenState extends State<JlDetailScreen> {
  Map<String, dynamic>? productData;
  bool isLoading = true;
  int selectedIndex = 0;
  int selectedTabIndex = 0;

  final JlCartcontroller cartController = Get.find<JlCartcontroller>();

  @override
  void initState() {
    super.initState();
    fetchProductDetails(widget.slug, widget.id);
  }

  String get _selectedVariant {
    final prices = productData?['price'] ?? [];

    if (prices.isNotEmpty && selectedIndex < prices.length) {
      return prices[selectedIndex]['size']?.toString() ?? 'Basic';
    }

    return 'Basic';
  }

  Future<void> fetchProductDetails(String slug, String id) async {
    try {
      final dio = Dio();
      final authController = Get.find<AuthController>();
      final String currentUserId = authController.companyId.value;

      final response = await dio.get(
        '$jitUrl/public/product/$slug',
        queryParameters: {
          'slug': true,
          'source': 'Liquor',
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

  // void _addToCart() {

  //   if (productData == null) return;

  //   final prices = productData!['price'] as List<dynamic>? ?? [];
  //   final selectedPrice = prices.isNotEmpty
  //       ? prices[selectedIndex]['price'] ?? 0
  //       : 0;
  //   final selectedSize = prices[selectedIndex]['size'] ?? 'Basic';
  //   final cartItem = JlCartitem(
  //     id: productData!['_id'] ?? '',
  //     name: productData!['productName'] ?? '',
  //     image: (productData!['productImage'] as List).isNotEmpty
  //         ? productData!['productImage'][0]
  //         : '',
  //     price: selectedPrice.toDouble(),
  //     quantity: 1,
  //     categorySlug: productData!['slug'] ?? '',
  //     selectedVariant: prices.isNotEmpty
  //         ? prices[selectedIndex]['size']
  //         : '1 pc.',
  //     selectedSize: selectedSize,
  //   );

  //   if (cartController.cartItems.any((item) => item.id == cartItem.id)) {
  //     cartController.removeFromCart(cartItem.id);
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

  //   setState(() {}); // Update UI for button
  // }
  void _addToCart() {
    if (productData == null) return;

    final prices = productData!['price'] as List<dynamic>? ?? [];

    final variant = _selectedVariant;

    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    final cartItem = JlCartitem(
      id: productData!['_id'] ?? '',
      name: productData!['productName'] ?? '',
      image: (productData!['productImage'] as List).isNotEmpty
          ? productData!['productImage'][0]
          : '',
      price: selectedPrice.toDouble(),
      quantity: 1,
      categorySlug: productData!['slug'] ?? '',
      selectedVariant: variant, // ✅ FIX
      selectedSize: variant,
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

    final name = productData!['productName'] ?? '';
    final description = productData!['productLongDescription'] ?? '';
    final images = productData!['productImage'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images.first : null;
    final prices = productData!['price'] as List<dynamic>? ?? [];
    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    // final isInCart = cartController.cartItems.any(
    //   (item) => item.id == productData!['_id'],
    // );
    final variant = _selectedVariant;

    final isInCart = cartController.cartItems.any(
      (item) =>
          item.id == productData!['_id'] && item.selectedVariant == variant,
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(name),
    //     centerTitle: true,
    //     backgroundColor: Colors.white,
    //     foregroundColor: Colors.black,
    //     elevation: 0,
    //   ),
    //   backgroundColor: Colors.white,
    //   body: SingleChildScrollView(
    //     padding: const EdgeInsets.all(12),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         /// IMAGE
    //         Center(
    //           child: Container(
    //             height: 220,
    //             width: 300,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(20),
    //               color: Colors.grey.shade200,
    //             ),
    //             child: imageUrl != null
    //                 ? Image.network(imageUrl)
    //                 : const Icon(Icons.image_not_supported, size: 80),
    //           ),
    //         ),
    //         const SizedBox(height: 20),

    //         /// NAME
    //         Text(
    //           name,
    //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //         ),
    //         const SizedBox(height: 10),

    //         /// DESCRIPTION
    //         Text(description),
    //         const SizedBox(height: 20),

    //         /// BRAND
    //         _brandSection(productData?['brand']?['image']),

    //         const SizedBox(height: 15),

    //         /// PRICE SIZE LIST
    //         if (prices.isNotEmpty)
    //           SizedBox(
    //             height: 35,
    //             child: ListView.builder(
    //               scrollDirection: Axis.horizontal,
    //               itemCount: prices.length,
    //               itemBuilder: (context, index) {
    //                 final isSelected = index == selectedIndex;
    //                 return GestureDetector(
    //                   onTap: () => setState(() => selectedIndex = index),
    //                   child: Container(
    //                     margin: const EdgeInsets.only(right: 8),
    //                     padding: const EdgeInsets.symmetric(
    //                       horizontal: 12,
    //                       vertical: 6,
    //                     ),
    //                     decoration: BoxDecoration(
    //                       color: isSelected
    //                           ? Colors.orange
    //                           : Colors.grey.shade200,
    //                       borderRadius: BorderRadius.circular(12),
    //                     ),
    //                     child: Text(
    //                       prices[index]['size'] ?? '',
    //                       style: TextStyle(
    //                         color: isSelected ? Colors.white : Colors.black,
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               },
    //             ),
    //           ),

    //         const SizedBox(height: 10),

    //         /// SELECTED PRICE
    //         Text(
    //           "₹$selectedPrice",
    //           style: const TextStyle(
    //             fontSize: 18,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.orange,
    //           ),
    //         ),
    //         const Text("Exclusive of all taxes"),
    //         Padding(
    //           padding: const EdgeInsets.only(left: 0, top: 5),
    //           child: Row(
    //             children: [
    //               RatingBarIndicator(
    //                 rating: 4.4,
    //                 itemCount: 5,
    //                 itemSize: 20,
    //                 itemBuilder: (_, __) =>
    //                     const Icon(Icons.star, color: Colors.amber),
    //               ),
    //               const SizedBox(width: 8),
    //               const Text("4.4 (58 reviews)"),
    //             ],
    //           ),
    //         ),
    //         const SizedBox(height: 20),

    //         /// ADD TO CART BUTTON
    //         SizedBox(
    //           width: double.infinity,
    //           height: 45,
    //           child: ElevatedButton.icon(
    //             onPressed: _addToCart,
    //             icon: Icon(
    //               isInCart
    //                   ? Icons.remove_shopping_cart
    //                   : Icons.add_shopping_cart,
    //             ),
    //             label: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: isInCart ? Colors.red : Colors.orange,
    //             ),
    //           ),
    //         ),

    //         const SizedBox(height: 20),

    //         /// TABS
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //           children: [
    //             buildTab(text: "Product Description", index: 0),
    //             buildTab(text: "Usage & Applications", index: 1),
    //           ],
    //         ),
    //         const SizedBox(height: 10),

    //         // / TAB CONTENT
    //         Padding(
    //           padding: const EdgeInsets.all(5),

    //           child: Text(
    //             selectedTabIndex == 0
    //                 ? (productData!['productLongDescription'] ?? '')
    //                 : (productData!['usageAndApplications'] ?? 'No data'),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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

                      const SizedBox(height: 15),

                      /// PRICE OPTIONS
                      if (prices.isNotEmpty)
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

                      const SizedBox(height: 15),

                      /// PRICE
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
                          Tab(text: "Product Description"),
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
                // Product Description Tab - Pass the product data
                ProductDescrip(productData: productData),

                // Usage & Applications Tab - Pass the product data
                UseAndAppli(productData: productData),
              ],
            ),
          ),
        ),

        /// BOTTOM BAR (100% SAME AS PREVIOUS)
        bottomNavigationBar: Obx(() {
          final variant = _selectedVariant;

          final isInCart = cartController.cartItems.any(
            (item) =>
                item.id == productData!['_id'] &&
                item.selectedVariant == variant,
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
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
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
                          child: Text(
                            isInCart ? 'Remove from Cart' : 'Add to Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    if (isInCart) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Get.to(() => JlBottomNavBar(initialIndex: 4));

                            if (widget.productType == 'Liquor') {
                              Get.to(() => JlBottomNavBar(initialIndex: 4));
                            } else {
                              Get.find<JlBottomNavController>().switchTab(4);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                // final navigator = Navigator.of(context);

                                // if (navigator.canPop()) {
                                //   navigator.pop();
                                // }
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final navigator = Navigator.of(context);

                                  if (navigator.canPop()) {
                                    navigator.pop();
                                  }
                                });
                              });
                            }
                          },
                          child: JlCartBadgeIcon(
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

  // Widget _buildNewProductUI() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 20),
  //       /// IMAGE
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Container(
  //           height: 250,
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20),
  //             color: Colors.grey.shade200,
  //           ),
  //           child: imageUrl != null
  //               ? ClipRRect(
  //                   borderRadius: BorderRadius.circular(20),
  //                   child: Image.network(imageUrl, fit: BoxFit.cover),
  //                 )
  //               : const Icon(Icons.image_not_supported, size: 80),
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //       /// NAME
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Text(
  //           name,
  //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //       /// DESCRIPTION
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  //         child: Text(description),
  //       ),
  //       const SizedBox(height: 15),
  //       /// BRAND
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: _brandSection(productData?['brand']?['image']),
  //       ),
  //       const SizedBox(height: 15),
  //       /// PRICE OPTIONS
  //       if (prices.isNotEmpty)
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           child: SizedBox(
  //             height: 40,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: prices.length,
  //               itemBuilder: (context, index) {
  //                 final isSelected = index == selectedIndex;
  //                 return GestureDetector(
  //                   onTap: () => setState(() => selectedIndex = index),
  //                   child: Container(
  //                     margin: const EdgeInsets.only(right: 8),
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 14,
  //                       vertical: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? Colors.orange
  //                           : Colors.grey.shade200,
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Text(
  //                       '${prices[index]['size']} (₹${prices[index]['price']})',
  //                       style: TextStyle(
  //                         color: isSelected ? Colors.white : Colors.black,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //       const SizedBox(height: 15),
  //       /// PRICE
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Text(
  //           "₹$selectedPrice",
  //           style: const TextStyle(
  //             fontSize: 26,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.orange,
  //           ),
  //         ),
  //       ),
  //       const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16),
  //         child: Text("Exclusive of all taxes"),
  //       ),
  //       const SizedBox(height: 10),
  //       /// RATING
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Row(
  //           children: [
  //             RatingBarIndicator(
  //               rating: 4.4,
  //               itemCount: 5,
  //               itemSize: 20,
  //               itemBuilder: (_, __) =>
  //                   const Icon(Icons.star, color: Colors.amber),
  //             ),
  //             const SizedBox(width: 8),
  //             const Text("4.4 (58 reviews)"),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //     ],
  //   );
  // }
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
