// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:jitco_app/screens/Home/Detail%20Product%20Screen/widgets/product_descip.dart';
// import 'package:jitco_app/screens/Home/Detail%20Product%20Screen/widgets/usage_appli.dart';
// import 'package:jitco_app/widgets/images.dart';
// import 'package:velocity_x/velocity_x.dart';

// class DetailProductScreen extends StatefulWidget {
//   const DetailProductScreen({super.key});

//   @override
//   State<DetailProductScreen> createState() => _DetailProductScreenState();
// }

// class _DetailProductScreenState extends State<DetailProductScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         body: SafeArea(
//           child: NestedScrollView(
//             headerSliverBuilder: (context, innerBoxIsScrolled) {
//               return [
//                 SliverToBoxAdapter(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: ClipRRect(
//                           child: Image.asset(
//                             cartDemo[0],
//                             height: 300,
//                             width: double.infinity,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 color: Colors.grey[350],
//                                 child: const Icon(Icons.error),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 20,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Alphonso Mango Pulp 850 gm Golden Crown',
//                               style: TextStyle(
//                                 fontSize: 25,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             10.heightBox,
//                             Text(
//                               'Golden Crown Alphonso Mango Pulp 850 gm – Smooth, Rich, and Naturally Sweet Mango Pulp Made from Premium Alphonso Mangoes, Ideal for Desserts, Beverages, and Cooking',
//                               style: TextStyle(fontSize: 15),
//                             ),
//                             10.heightBox,
//                             _brandSection(),
//                             10.heightBox,
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   'RS.200'.text
//                                       .size(25)
//                                       .fontWeight(FontWeight.bold)
//                                       .color(Colors.orange)
//                                       .make(),
//                                   'Exclusive of all taxes'.text.make(),
//                                   12.heightBox,
//                                   Row(
//                                     children: [
//                                       RatingBarIndicator(
//                                         rating: 3.0,
//                                         itemCount: 5,
//                                         itemSize: 20,
//                                         itemBuilder: (context, index) => Icon(
//                                           Icons.star,
//                                           color: Colors.amber,
//                                         ),
//                                       ),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         "4.4 (58 reviews)",
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             18.heightBox,
//                             const Divider(),
//                             12.heightBox,
//                             'Product Highlights'.text
//                                 .fontWeight(FontWeight.bold)
//                                 .size(20)
//                                 .make(),
//                             15.heightBox,
//                             ListView(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               children: [
//                                 _buildBulletPoint(
//                                   'Made from premium Alphonso mangoes',
//                                 ),
//                                 7.heightBox,
//                                 _buildBulletPoint('Smooth and rich texture'),
//                                 7.heightBox,
//                                 _buildBulletPoint(
//                                   'Naturally sweet with authentic mango flavor',
//                                 ),
//                               ],
//                             ),
//                             30.heightBox,
//                             'Keyword'.text
//                                 .fontWeight(FontWeight.bold)
//                                 .size(20)
//                                 .make(),
//                             15.heightBox,
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: [
//                                 _keyTitle(
//                                   'Alphonso mangoes',
//                                   Colors.orange.shade700,
//                                   Colors.white,
//                                 ),
//                                 _keyTitle(
//                                   'Smooth and rich',
//                                   Colors.orange.shade700,
//                                   Colors.white,
//                                 ),
//                                 _keyTitle(
//                                   'Mango flavor',
//                                   Colors.orange.shade700,
//                                   Colors.white,
//                                 ),
//                               ],
//                             ),
//                             30.heightBox,
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SliverPersistentHeader(
//                   delegate: _StickyTabBarDelegate(
//                     child: Container(
//                       color: Colors.white,
//                       child: TabBar(
//                         controller: _tabController,
//                         labelColor: Colors.deepOrangeAccent,
//                         unselectedLabelColor: Colors.grey,
//                         indicatorColor: Colors.deepOrangeAccent,
//                         indicatorWeight: 2.0,
//                         indicatorSize: TabBarIndicatorSize.tab,
//                         tabs: const [
//                           Tab(text: 'Product Description'),
//                           Tab(text: 'Usage & Applications'),
//                         ],
//                       ),
//                     ),
//                   ),
//                   pinned: true,
//                 ),
//               ];
//             },
//             body: TabBarView(
//               controller: _tabController,
//               children: [ProductDescip(), UsageAppli()],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBulletPoint(String productHighlights) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Text('• $productHighlights', style: TextStyle(fontSize: 15)),
//     );
//   }

//   Widget _keyTitle(String keywords, Color color, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: color,
//       ),
//       child: Text(
//         keywords,
//         style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
//       ),
//     );
//   }

//   Widget _brandSection() {
//     return Container(
//       height: 60,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(radius: 20, backgroundImage: AssetImage(cartDemo[0])),
//           10.widthBox,
//           _keyTitle('RAW Pressery', Colors.yellow.shade200, Colors.black54),
//           const Spacer(),
//           Flexible(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Veg'),
//                 10.widthBox,
//                 Image.asset(cartDemo[0], width: 27),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;

//   _StickyTabBarDelegate({required this.child});

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return child;
//   }

//   @override
//   double get maxExtent => 48;

//   @override
//   double get minExtent => 48;

//   @override
//   bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
//     return child != oldDelegate.child;
//   }
// }
