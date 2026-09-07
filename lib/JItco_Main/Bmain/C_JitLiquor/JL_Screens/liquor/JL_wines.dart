// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/categorymodel.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartcontroller.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/liquor/JL_app_gradient.dart';

// class JlWines extends StatefulWidget {
//   final String category;
//   const JlWines({super.key, required this.category});

//   @override
//   State<JlWines> createState() => _JlWinesState();
// }

// class _JlWinesState extends State<JlWines> {
//   /// per-product size selection
//   final Map<String, int> selectedIndexMap = {};

//   // WinesProductController controller = Get.put(
//   //   WinesProductController(),
//   // );

//   WinesProductController? controller;

//   @override
//   void initState() {
//     super.initState();

//     controller = Get.put(
//       WinesProductController(category: widget.category),
//       tag: widget.category, // optional but safer
//     );
//   }

//   @override
//   void dispose() {
//     Get.delete<WinesProductController>(tag: widget.category);
//     super.dispose();
//   }

//   String getExploreText(String category) {
//     switch (category) {
//       case "spirits":
//         return "Explore Spirits";
//       case "wines":
//         return "Explore Wines";
//       case "beer":
//         return "Explore Beers";
//       default:
//         return "Explore";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final gradient = Theme.of(
//       context,
//     ).extension<JlAppGradient>()?.primaryGradient;

//     final cartController = Get.find<JlCartcontroller>();

//     return Scaffold(
//       backgroundColor: Colors.orange.shade700,
//       body: SafeArea(
//         child: Container(
//           // decoration: BoxDecoration(gradient: gradient),
//           child: Column(
//             children: [
//               const SizedBox(height: 15),
//               Text(
//                 getExploreText(widget.category),
//                 // style: GoogleFonts.merienda(
//                 //   fontSize: 20,
//                 //   color: Colors.white,
//                 //   fontWeight: FontWeight.bold,
//                 // ),
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               /// SEARCH
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: TextField(
//                   onChanged: (v) => controller?.searchQuery.value = v,
//                   decoration: InputDecoration(
//                     hintText: "Search wines...",
//                     prefixIcon: const Icon(Icons.search, color: Colors.orange),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),

//               /// LIST
//               Expanded(
//                 child: Obx(() {
//                   if (controller!.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (controller!.filteredList.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         "No wines found",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   }

//                   return
//                   // ListView.builder(
//                   //   controller: controller?.scrollController,
//                   //   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   //   // itemCount: controller?.filteredList.length,
//                   //   itemCount:
//                   //       controller!.filteredList.length +
//                   //       (controller!.isMoreDataAvailable.value ? 1 : 0),
//                   //   itemBuilder: (context, index) {
//                   //     if (index == controller!.filteredList.length) {
//                   //       return const Padding(
//                   //         padding: EdgeInsets.all(16),
//                   //         child: Center(
//                   //           child: CircularProgressIndicator(
//                   //             color: Colors.white,
//                   //           ),
//                   //         ),
//                   //       );
//                   //     }
//                   //     final item = controller?.filteredList[index];
//                   //     final prices = item?.price;
//                   //     selectedIndexMap[item!.id] ??= 0;
//                   //     final selectedIndex = selectedIndexMap[item.id]!;
//                   //     final selectedPrice = prices!.isNotEmpty
//                   //         ? prices[selectedIndex].price
//                   //         : 0;
//                   //     final isInCart = cartController.cartItems.any(
//                   //       (c) => c.id == item.id,
//                   //     );
//                   //     return GestureDetector(
//                   //       onTap: () {
//                   //         Get.to(
//                   //           () => Winesdetail(slug: item.slug, id: item.id),
//                   //         );
//                   //       },
//                   //       child: buildWineCard(
//                   //         item: item,
//                   //         prices: prices,
//                   //         selectedIndex: selectedIndex,
//                   //         selectedPrice: selectedPrice,
//                   //         isInCart: isInCart,
//                   //         onSizeTap: (i) {
//                   //           setState(() {
//                   //             selectedIndexMap[item.id] = i;
//                   //           });
//                   //         },
//                   //         onCartTap: () {
//                   //           if (isInCart) {
//                   //             cartController.removeFromCart(item.id);
//                   //           } else {
//                   //             cartController.addToCart(
//                   //               JlCartitem(
//                   //                 id: item.id,
//                   //                 name: item.productName,
//                   //                 image: item.firstImage,
//                   //                 price: selectedPrice.toDouble(),
//                   //                 quantity: 1,
//                   //                 categorySlug: item.slug,
//                   //                 selectedVariant: prices[selectedIndex].size,
//                   //               ),
//                   //             );
//                   //           }
//                   //         },
//                   //       ),
//                   //     );
//                   //   },
//                   // );
//                   ListView.builder(
//                     controller: controller!.scrollController,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     itemCount:
//                         controller!.filteredList.length +
//                         (controller!.isMoreDataAvailable.value ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       // ✅ BOTTOM LOADER — must be FIRST
//                       if (index == controller!.filteredList.length) {
//                         if (controller!.isLoading.value) {
//                           return const Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                             ),
//                           );
//                         } else {
//                           return const SizedBox.shrink(); // no loader when not loading
//                         }
//                       }

//                       final item = controller!.filteredList[index];
//                       final prices = item.price;

//                       selectedIndexMap[item.id] ??= 0;
//                       final selectedIndex = selectedIndexMap[item.id]!;
//                       final selectedPrice = prices.isNotEmpty
//                           ? prices[selectedIndex].price
//                           : 0;

//                       final isInCart = cartController.cartItems.any(
//                         (c) => c.id == item.id,
//                       );

//                       return GestureDetector(
//                         onTap: () {
//                           Get.to(
//                             () => Winesdetail(slug: item.slug, id: item.id),
//                           );
//                         },
//                         child: buildWineCard(
//                           item: item,
//                           prices: prices,
//                           selectedIndex: selectedIndex,
//                           selectedPrice: selectedPrice,
//                           isInCart: isInCart,
//                           onSizeTap: (i) {
//                             setState(() {
//                               selectedIndexMap[item.id] = i;
//                             });
//                           },
//                           onCartTap: () {
//                             if (isInCart) {
//                               cartController.removeFromCart(item.id);
//                             } else {
//                               cartController.addToCart(
//                                 JlCartitem(
//                                   id: item.id,
//                                   name: item.productName,
//                                   image: item.firstImage,
//                                   price: selectedPrice.toDouble(),
//                                   quantity: 1,
//                                   categorySlug: item.slug,
//                                   selectedVariant: prices[selectedIndex].size,
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildWineCard({
//     required CategorysModel item,
//     required List<PriceModel> prices,
//     required int selectedIndex,
//     required int selectedPrice,
//     required bool isInCart,
//     required Function(int) onSizeTap,
//     required VoidCallback onCartTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TOP ROW
//           Row(
//             children: [
//               Container(
//                 height: 60,
//                 width: 70,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   color: Colors.grey.shade200,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: Image.network(
//                     item.firstImage,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) =>
//                         const Icon(Icons.broken_image),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.productName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item.productShortDescription,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           /// SIZE SELECTOR
//           if (prices.isNotEmpty)
//             SizedBox(
//               height: 34,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: prices.length,
//                 itemBuilder: (_, i) {
//                   final isSelected = i == selectedIndex;
//                   return GestureDetector(
//                     onTap: () => onSizeTap(i),
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 8),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Colors.orange
//                             : Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         prices[i].size,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//           const SizedBox(height: 10),
//           const Divider(),

//           /// PRICE + BUTTON
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "₹$selectedPrice",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//               SizedBox(
//                 height: 40,
//                 width: 200,
//                 child: ElevatedButton.icon(
//                   onPressed: onCartTap,
//                   icon: Icon(
//                     isInCart
//                         ? Icons.remove_shopping_cart
//                         : Icons.add_shopping_cart,
//                     size: 16,
//                   ),
//                   label: Text(isInCart ? "Remove from cart" : "Add to cart"),
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: isInCart
//                         ? Colors.red
//                         : Colors.orange.shade700,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Winesdetail extends StatefulWidget {
//   final String slug;
//   final String id;

//   const Winesdetail({super.key, required this.slug, required this.id});

//   @override
//   State<Winesdetail> createState() => _WinesdetailState();
// }

// class _WinesdetailState extends State<Winesdetail> {
//   Map<String, dynamic>? productData;
//   bool isLoading = true;
//   int selectedIndex = 0;
//   int selectedTabIndex = 0;

//   final JlCartcontroller cartController = Get.find<JlCartcontroller>();

//   @override
//   void initState() {
//     super.initState();
//     fetchProductDetails(widget.slug, widget.id);
//   }

//   Future<void> fetchProductDetails(String slug, String id) async {
//     try {
//       final dio = Dio();
//       final response = await dio.get(
//         'https://jitco.salt-tech.com/api/v1/public/product/$slug',
//         queryParameters: {
//           'slug': true,
//           'source': 'Liquor',
//           'user_id': '68107ebd454e265270c26caa',
//         },
//         options: Options(validateStatus: (_) => true),
//       );

//       if ((response.statusCode == 200 || response.statusCode == 201) &&
//           response.data != null &&
//           response.data['products'] != null) {
//         setState(() {
//           productData = response.data['products'];
//           isLoading = false;
//         });
//       } else {
//         debugPrint('❌ API FAILED => ${response.data}');
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       debugPrint('❌ API ERROR => $e');
//       setState(() => isLoading = false);
//     }
//   }

//   void _addToCart() {
//     if (productData == null) return;

//     final prices = productData!['price'] as List<dynamic>? ?? [];
//     final selectedPrice = prices.isNotEmpty
//         ? prices[selectedIndex]['price'] ?? 0
//         : 0;

//     final cartItem = JlCartitem(
//       id: productData!['_id'] ?? '',
//       name: productData!['productName'] ?? '',
//       image: (productData!['productImage'] as List).isNotEmpty
//           ? productData!['productImage'][0]
//           : '',
//       price: selectedPrice.toDouble(),
//       quantity: 1,
//       categorySlug: productData!['slug'] ?? '',
//       selectedVariant: prices.isNotEmpty
//           ? prices[selectedIndex]['size']
//           : '1 pc.',
//     );

//     if (cartController.cartItems.any((item) => item.id == cartItem.id)) {
//       cartController.removeFromCart(cartItem.id);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${cartItem.name} removed from cart'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } else {
//       cartController.addToCart(cartItem);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${cartItem.name} added to cart'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }

//     setState(() {}); // Update UI for button
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (productData == null) {
//       return const Scaffold(body: Center(child: Text('Product not found')));
//     }

//     final name = productData!['productName'] ?? '';
//     final description = productData!['productLongDescription'] ?? '';
//     final images = productData!['productImage'] as List? ?? [];
//     final imageUrl = images.isNotEmpty ? images.first : null;
//     final prices = productData!['price'] as List<dynamic>? ?? [];
//     final selectedPrice = prices.isNotEmpty
//         ? prices[selectedIndex]['price'] ?? 0
//         : 0;

//     final isInCart = cartController.cartItems.any(
//       (item) => item.id == productData!['_id'],
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(name),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// IMAGE
//             Center(
//               child: Container(
//                 height: 220,
//                 width: 300,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.grey.shade200,
//                 ),
//                 child: imageUrl != null
//                     ? Image.network(imageUrl)
//                     : const Icon(Icons.image_not_supported, size: 80),
//               ),
//             ),
//             const SizedBox(height: 20),

//             /// NAME
//             Text(
//               name,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             /// DESCRIPTION
//             Text(description),
//             const SizedBox(height: 20),

//             /// BRAND
//             _brandSection(productData?['brand']?['image']),

//             const SizedBox(height: 15),

//             /// PRICE SIZE LIST
//             if (prices.isNotEmpty)
//               SizedBox(
//                 height: 35,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: prices.length,
//                   itemBuilder: (context, index) {
//                     final isSelected = index == selectedIndex;
//                     return GestureDetector(
//                       onTap: () => setState(() => selectedIndex = index),
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 8),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.orange
//                               : Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           prices[index]['size'] ?? '',
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//             const SizedBox(height: 10),

//             /// SELECTED PRICE
//             Text(
//               "₹$selectedPrice",
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//             const Text("Exclusive of all taxes"),
//             Padding(
//               padding: const EdgeInsets.only(left: 0, top: 5),
//               child: Row(
//                 children: [
//                   RatingBarIndicator(
//                     rating: 4.4,
//                     itemCount: 5,
//                     itemSize: 20,
//                     itemBuilder: (_, __) =>
//                         const Icon(Icons.star, color: Colors.amber),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text("4.4 (58 reviews)"),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             /// ADD TO CART BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 45,
//               child: ElevatedButton.icon(
//                 onPressed: _addToCart,
//                 icon: Icon(
//                   isInCart
//                       ? Icons.remove_shopping_cart
//                       : Icons.add_shopping_cart,
//                 ),
//                 label: Text(isInCart ? 'Remove from Cart' : 'Add to Cart'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isInCart ? Colors.red : Colors.orange,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// TABS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 buildTab(text: "Product Description", index: 0),
//                 buildTab(text: "Usage & Applications", index: 1),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // / TAB CONTENT
//             Padding(
//               padding: const EdgeInsets.all(5),

//               child: Text(
//                 selectedTabIndex == 0
//                     ? (productData!['productLongDescription'] ?? '')
//                     : (productData!['usageAndApplications'] ?? 'No data'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _brandSection(dynamic image) {
//     return Row(
//       children: [
//         if (image != null && image.isNotEmpty)
//           CircleAvatar(radius: 25, backgroundImage: NetworkImage(image))
//         else
//           const CircleAvatar(radius: 25, child: Icon(Icons.business)),
//         const SizedBox(width: 10),
//       ],
//     );
//   }

//   Widget buildTab({required String text, required int index}) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedTabIndex = index;
//         });
//       },
//       child: Column(
//         children: [
//           Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
//           const SizedBox(height: 6),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 100),
//             height: 3,
//             width: 160,
//             decoration: BoxDecoration(
//               color: selectedTabIndex == index ? Colors.orange : Colors.grey,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
