// import 'package:flutter/material.dart';
// import 'package:jitco_app/screens/Home/A_Home%20and%20Drawer/Home_Drawer/drawer_screens/D_About/B_learnMore_btn/contract_supplies.dart';
// import 'package:jitco_app/screens/Home/A_Home%20and%20Drawer/Home_Drawer/drawer_screens/D_About/B_learnMore_btn/procurement_screen.dart';

// class LearnMore extends StatefulWidget {
//   const LearnMore({super.key});

//   @override
//   State<LearnMore> createState() => _LearnMoreState();
// }

// class _LearnMoreState extends State<LearnMore>
//     with SingleTickerProviderStateMixin {
//   int selectedIndex = 0;
//   late TabController _tabController;

//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);
//     super.initState();
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
//         appBar: AppBar(
//           backgroundColor: Colors.orange.shade700,
//           title: const Text('Jitco - OnBoarding'),
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Padding(
//               //   padding: const EdgeInsets.only(bottom: 10),
//               //   child: Container(
//               //     color: Colors.orange.shade700,
//               //     padding: const EdgeInsets.all(15),
//               //     child: Column(
//               //       children: [
//               //         Text(
//               //           'JITCO Procurement Onboarding',
//               //           style: TextStyle(
//               //             fontSize: 20,
//               //             fontWeight: FontWeight.w400,
//               //           ),
//               //         ),
//               //         Text(
//               //           'Streamline your food service procurement — faster deliveries, fresher products, smarter supply.',
//               //           style: TextStyle(),
//               //           textAlign: TextAlign.center,
//               //         ),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               Container(
//                 // color: Colors.orange.shade700,
//                 child: TabBar(
//                   controller: _tabController,
//                   labelColor: Colors.orange.shade700,
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: Colors.orange.shade700,
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   tabs: [
//                     Tab(text: "Standard Procurement"),
//                     Tab(text: "Contracted Supplies"),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [ProcurementScreen(), ContractSupplies()],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
