import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';


// class details extends StatefulWidget {
//   final All? product;
//   // final ProductModel? products;

//   const details({super.key, this.product});

//   @override
//   State<details> createState() => _detailsState();
// }

// final args = Get.arguments as Map<String, dynamic>?;

// final product = args?["product"];
// final selectedPrice = args?["selectedPrice"];

// Map<String, dynamic>? productData;

// int selectedIndex = 0;
// bool isSelected = false;
// bool isselected = false;
// int selectedindex = 0;

// String _getBrandName() {
//   return productData?['brand']?['name'] ?? 'Unknown Brand';
// }

// String _getVegNonVeg() {
//   return productData?['vegNoneveg'] ?? 'Veg';
// }

// class _detailsState extends State<details> {
//   @override
//   Widget build(BuildContext context) {
//     final prices = widget.product!.price ?? [];
//     final selectedPrice = prices.isNotEmpty ? prices[selectedIndex].price : 0;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.product!.productName, style: TextStyle()),
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 35),
//                 Center(
//                   child: Container(
//                     height: 270,
//                     width: 300,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.asset(
//                         "lib/assets/images/Capture.png",
//                         height: 200,
//                         width: 200,
//                         fit: BoxFit.fitHeight,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Text(
//                     widget.product!.productName,
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 20),
//                   child: Text(
//                     widget.product!.productLongDescription,
//                     style: TextStyle(fontSize: 15, color: Colors.black),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Container(
//                     height: 30,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade200,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(child: Text("JITCO")),
//                   ),
//                 ),
//                 // Price and Rating Section
//                 if (prices.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8),
//                     child: SizedBox(
//                       height: 30,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: prices.length,
//                         itemBuilder: (context, index) {
//                           final isSelected = index == selectedIndex;
//                           return GestureDetector(
//                             onTap: () => setState(() => selectedIndex = index),
//                             child: Container(
//                               margin: const EdgeInsets.only(right: 8),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.orange
//                                     : Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 prices[index].size ?? "",
//                                 style: TextStyle(
//                                   color: isSelected
//                                       ? Colors.white
//                                       : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12),
//                   child: Text(
//                     "₹$selectedPrice",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12),
//                   child: Text(
//                     "Exclusive of all taxes",
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           SizedBox(width: 13),
//                           RatingBarIndicator(
//                             rating: 3.0,
//                             itemCount: 5,
//                             itemSize: 20,
//                             itemBuilder: (context, index) =>
//                                 Icon(Icons.star, color: Colors.amber),
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             "4.4 (58 reviews)",
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Text(
//                       //   "₹$selectedPrice",
//                       //   style: const TextStyle(
//                       //     fontSize: 18,
//                       //     fontWeight: FontWeight.bold,
//                       //     color: Colors.orange,
//                       //   ),
//                       // ),
//                       Container(
//                         width: 300,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orangeAccent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: const Text(
//                             "Add to menu",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     buildTab(text: "Product Description", index: 0),
//                     SizedBox(width: 10),
//                     buildTab(text: "Usage & Applications", index: 1),
//                   ],
//                 ),
//                 SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTab({required String text, required int index}) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedindex = index;
//         });
//       },
//       child: Column(
//         children: [
//           Text(text, style: TextStyle(fontSize: 15, color: Colors.black)),
//           SizedBox(height: 6),
//           AnimatedContainer(
//             duration: Duration(milliseconds: 100),
//             height: 3,
//             width: 160,
//             decoration: BoxDecoration(
//               color: selectedindex == index ? Colors.orange : Colors.grey,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget _keyTitle(String keywords, Color color, Color textColor) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(20),
//       color: color,
//     ),
//     child: Text(
//       keywords,
//       style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//     ),
//   );
// }

// Widget _brandSection(dynamic image) {
//   final BrandModel = productData?['brand']?['image'] ?? '';

//   return Container(
//     height: 60,
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         if (image.isNotEmpty)
//           CircleAvatar(radius: 20, backgroundImage: NetworkImage(image))
//         else
//           CircleAvatar(
//             radius: 20,
//             backgroundColor: Colors.grey,
//             child: Icon(Icons.business, color: Colors.white),
//           ),
//         SizedBox(height: 15),
//         _keyTitle(_getBrandName(), Colors.yellow.shade200, Colors.black54),
//         const Spacer(),
//         Flexible(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(_getVegNonVeg()),
//               SizedBox(
//                 width: 100,
//               ), // You can add veg/non-veg icon based on the value
//               _getVegNonVeg().toLowerCase() == 'veg'
//                   ? Icon(Icons.eco, color: Colors.green)
//                   : Icon(Icons.fastfood, color: Colors.red),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

