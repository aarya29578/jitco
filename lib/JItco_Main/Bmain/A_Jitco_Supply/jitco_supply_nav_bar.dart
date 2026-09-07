///method1
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/cart_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/home_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/B_Category/category_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
import 'package:jitco_app/JItco_Main/jitco_main.dart';

class JitcoSupplyNavBar extends StatefulWidget {
  final int initialIndex;

  const JitcoSupplyNavBar({super.key, this.initialIndex = 1});

  @override
  State<JitcoSupplyNavBar> createState() => JitcoSupplyNavBarState();
}

class JitcoSupplyNavBarState extends State<JitcoSupplyNavBar> {
  // int _currentIndex = 0;
  final BottomNavController bottomNavController = Get.put(
    BottomNavController(),
  );
  DateTime? _lastBackPressTime; // Track last back press time

  // Each tab has its own navigator
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Make this method public (FOR HOMESCREEN SEARCH -> PRODUCTSCREEN)
  // void switchToTab(int index) {
  //   setState(() {
  //     bottomNavController.currentIndex.value = index;
  //   });
  //   // Pop to root of the selected tab
  //   _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  // }
  void switchToTab(int index) {
    bottomNavController.switchTab(index);

    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   bottomNavController.currentIndex.value = widget.initialIndex;
  // }
  // @override
  // void initState() {
  //   super.initState();

  //   bottomNavController.currentIndex.value = widget.initialIndex == 0
  //       ? 1
  //       : widget.initialIndex;
  // }
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      bottomNavController.currentIndex.value = widget.initialIndex == 0
          ? 1
          : widget.initialIndex;
    });
  }

  // Handle back button properly
  // Future<bool> _onWillPop() async {
  //   final currentNavigator =
  //       _navigatorKeys[bottomNavController.currentIndex.value].currentState;

  //   // If current tab has navigation stack, pop it
  //   if (currentNavigator != null && currentNavigator.canPop()) {
  //     currentNavigator.pop();
  //     return false; // Don't exit app
  //   }

  //   // If on home tab, implement double tap to exit
  //   if (bottomNavController.currentIndex.value == 0) {
  //     final now = DateTime.now();

  //     // Check if user pressed back twice within 2 seconds
  //     if (_lastBackPressTime == null ||
  //         now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
  //       // First press - show warning
  //       _lastBackPressTime = now;
  //       _showExitWarning();
  //       return false; // Don't exit app
  //     }

  //     // Second press within 2 seconds - exit app
  //     return true; // Exit app
  //   }

  //   // If not on home tab, switch to home tab
  //   setState(() {
  //     bottomNavController.currentIndex.value = 0;
  //   });
  //   return false; // Don't exit app
  // }
  // Future<bool> _onWillPop() async {
  //   final navigator =
  //       _navigatorKeys[bottomNavController.currentIndex.value].currentState;

  //   /// ✅ Only pop if REALLY can pop
  //   if (navigator != null && navigator.canPop()) {
  //     navigator.pop();
  //     return false;
  //   }

  //   /// ✅ If not on Home → switch to Home
  //   if (bottomNavController.currentIndex.value != 0) {
  //     bottomNavController.switchTab(0);
  //     return false;
  //   }

  //   /// ✅ Double back to exit
  //   final now = DateTime.now();

  //   if (_lastBackPressTime == null ||
  //       now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
  //     _lastBackPressTime = now;
  //     _showExitWarning();
  //     return false;
  //   }

  //   return true;
  // }
  Future<bool> _onWillPop() async {
    final currentIndex = bottomNavController.currentIndex.value;
    final navigator = _navigatorKeys[currentIndex].currentState;

    /// If current tab has inner stack → pop it
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }

    /// If NOT Home → switch to Home
    if (currentIndex != 1) {
      bottomNavController.switchTab(1);
      return false;
    }

    /// If Home root → double back to exit
    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      _showExitWarning();
      return false;
    }

    return true; // Exit app
  }

  void _showExitWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Press again to Go Back',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // void _onTabTapped(int index) {
  //   if (index == bottomNavController.currentIndex.value) {
  //     // If tapping current tab, pop to root
  //     _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  //   } else {
  //     setState(() {
  //       bottomNavController.currentIndex.value = index;
  //     });
  //   }
  // }

  void _onTabTapped(int index) {
    /// If Home root → double back to exit
    final now = DateTime.now();

    /// If Logo tab clicked
    if (index == 0) {
      if (_lastBackPressTime == null ||
          now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
        _lastBackPressTime = now;
        _showExitWarning();
        return;
      }
      Navigator.pop(context);
      // Get.offAll(() => const JItcoMain(), transition: Transition.leftToRight);
      return;
    }

    if (index == bottomNavController.currentIndex.value) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      bottomNavController.currentIndex.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(
        () => Scaffold(
          body: IndexedStack(
            index: bottomNavController.currentIndex.value,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.amber,
                ),
              ), // index 0 → Logo tab (empty)
              _buildNavigator(1, HomeScreen()),
              _buildNavigator(2, CategoryScreen()),
              _buildNavigator(3, UniversalProductScreen()),
              _buildNavigator(4, CartScreen()),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget screen) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => screen,
          settings: settings,
        );
      },
    );
  }

  // BottomNavigationBar _buildBottomNavigationBar() {
  //   return BottomNavigationBar(
  //     currentIndex: bottomNavController.currentIndex.value,
  //     onTap: _onTabTapped,
  //     type: BottomNavigationBarType.fixed,
  //     backgroundColor: Colors.white,
  //     selectedItemColor: Colors.deepOrangeAccent,
  //     unselectedItemColor: Colors.grey,
  //     showSelectedLabels: true,
  //     showUnselectedLabels: true,
  //     selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
  //     elevation: 8,
  //     items: [
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home_outlined),
  //         activeIcon: Icon(Icons.home),
  //         label: 'Home',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.category_outlined),
  //         activeIcon: Icon(Icons.category),
  //         label: 'Categories',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.shopping_bag_outlined),
  //         activeIcon: Icon(Icons.shopping_bag),
  //         label: 'Products',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: CartBadgeIcon(isActive: false, nonActiveColor: Colors.grey),
  //         activeIcon: CartBadgeIcon(
  //           isActive: true,
  //           activeColor: Colors.deepOrangeAccent,
  //         ),
  //         label: 'Cart',
  //       ),
  //     ],
  //   );
  // }
  Widget _buildBottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        // wrap this too
        currentIndex: bottomNavController.currentIndex.value,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        // onTap: _onTabTapped,
        // type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(
          //     logo, // your svg path constant
          //     height: 20,
          //     // colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          //   ),
          //   activeIcon: SvgPicture.asset(
          //     logo,
          //     height: 20,
          //     // colorFilter: const ColorFilter.mode(
          //     //   Colors.deepOrangeAccent,
          //     //   BlendMode.srcIn,
          //     // ),
          //   ),
          //   label: 'Main',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_circle_left_outlined),
            activeIcon: Icon(Icons.arrow_circle_left_outlined),
            label: 'Go Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: CartBadgeIcon(isActive: false),
            activeIcon: CartBadgeIcon(isActive: true),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

///Method2
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/consts/images.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/cart_screen.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/home_screen.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/B_Category/category_screen.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
// import 'package:jitco_app/JItco_Main/jitco_main.dart';

// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// class JitcoSupplyNavBar extends StatefulWidget {
//   final int initialIndex;

//   const JitcoSupplyNavBar({super.key, this.initialIndex = 0});

//   @override
//   State<JitcoSupplyNavBar> createState() => JitcoSupplyNavBarState();
// }

// class JitcoSupplyNavBarState extends State<JitcoSupplyNavBar> {
//   final BottomNavController bottomNavController = Get.put(
//     BottomNavController(),
//   );

//   DateTime? _lastBackPressTime;

//   final List<GlobalKey<NavigatorState>> _navigatorKeys = [
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     bottomNavController.currentIndex.value = widget.initialIndex;
//   }

//   void switchToTab(int index) {
//     bottomNavController.currentIndex.value = index;
//     _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//   }

//   Future<bool> _onWillPop() async {
//     final currentIndex = bottomNavController.currentIndex.value;
//     final navigator = _navigatorKeys[currentIndex].currentState;

//     if (navigator != null && navigator.canPop()) {
//       navigator.pop();
//       return false;
//     }

//     if (currentIndex != 0) {
//       bottomNavController.switchTab(0);
//       return false;
//     }

//     final now = DateTime.now();

//     if (_lastBackPressTime == null ||
//         now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
//       _lastBackPressTime = now;
//       _showExitWarning();
//       return false;
//     }

//     return true;
//   }

//   void _showExitWarning() {
//     final messenger = ScaffoldMessenger.of(context);

//     messenger.hideCurrentSnackBar(); // closes existing snackbar smoothly

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         elevation: 1,
//         // duration: Duration(seconds: 1),
//         content: const Text(
//           'JIT Supply - Press back again to exit',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.deepOrangeAccent,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _onTabTapped(int index) {
//     if (index == bottomNavController.currentIndex.value) {
//       _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//     } else {
//       bottomNavController.currentIndex.value = index;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Obx(
//         () => Scaffold(
//           // key: _scaffoldKey,
//           // extendBody: true, // IMPORTANT (helps notch rendering)
//           body: IndexedStack(
//             index: bottomNavController.currentIndex.value,
//             children: [
//               _buildNavigator(0, HomeScreen()),
//               _buildNavigator(1, CategoryScreen()),
//               _buildNavigator(2, UniversalProductScreen()),
//               _buildNavigator(3, CartScreen()),
//             ],
//           ),

//           ///Method1
//           // CENTER PREMIUM BUTTON
//           // floatingActionButton: FloatingActionButton(
//           //   elevation: 1,
//           //   backgroundColor: Colors.white,
//           //   onPressed: () {
//           //     Get.offAll(() => const JItcoMain());
//           //   },
//           //   child: SvgPicture.asset(logo, height: 18),
//           // ),
//           // floatingActionButtonLocation:
//           //     FloatingActionButtonLocation.endContained,

//           ///Method2
//           // floatingActionButton: SizedBox(
//           //   height: 80,
//           //   width: 80,
//           //   child: Stack(
//           //     alignment: Alignment.center,
//           //     children: [
//           //       // BACK SOFT GREY CIRCLE (like image shadow background)
//           //       Container(
//           //         height: 68,
//           //         width: 68,
//           //         decoration: BoxDecoration(
//           //           shape: BoxShape.circle,
//           //           color: Colors.white,
//           //         ),
//           //       ),

//           //       // FRONT WHITE BUTTON
//           //       GestureDetector(
//           //         onTap: () {
//           //           Get.offAll(
//           //             () => const JItcoMain(),
//           //             transition: Transition.leftToRight,
//           //           );
//           //         },
//           //         child: Container(
//           //           height: 55,
//           //           width: 55,
//           //           decoration: BoxDecoration(
//           //             shape: BoxShape.circle,
//           //             color: Colors.white,
//           //             boxShadow: [
//           //               BoxShadow(
//           //                 color: Colors.black.withOpacity(0.15),
//           //                 blurRadius: 10,
//           //                 offset: const Offset(0, 4),
//           //               ),
//           //             ],
//           //           ),
//           //           child: Center(child: SvgPicture.asset(logo, height: 19)),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // floatingActionButtonLocation:
//           //     FloatingActionButtonLocation.endContained,

//           ///Method3
//           floatingActionButton: Builder(
//             builder: (context) {
//               // final isDrawerOpen =
//               //     _scaffoldKey.currentState?.isDrawerOpen ?? false;

//               // if (isDrawerOpen) return const SizedBox(); // hide FAB

//               return SizedBox(
//                 height: 80,
//                 width: 80,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       height: 78,
//                       width: 78,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Get.offAll(() => const JItcoMain());
//                       },
//                       child: Container(
//                         height: 65,
//                         width: 65,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.15),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: SvgPicture.asset(logo, height: 19),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.endContained,
//           bottomNavigationBar: BottomAppBar(
//             color: Colors.white,
//             shape: const CircularNotchedRectangle(),
//             notchMargin: 2,
//             child: SizedBox(
//               height: 50,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildNavItem(
//                     index: 0,
//                     icon: Icons.home_outlined,
//                     activeIcon: Icons.home,
//                     label: "Home",
//                   ),
//                   _buildNavItem(
//                     index: 1,
//                     icon: Icons.category_outlined,
//                     activeIcon: Icons.category,
//                     label: "Category",
//                   ),
//                   _buildNavItem(
//                     index: 2,
//                     icon: Icons.shopping_bag_outlined,
//                     activeIcon: Icons.shopping_bag,
//                     label: "Products",
//                   ),
//                   _buildNavItemCart(index: 3, label: "Cart"),
//                   const SizedBox(width: 80), // space for center FAB
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavigator(int index, Widget screen) {
//     return Navigator(
//       key: _navigatorKeys[index],
//       onGenerateRoute: (settings) {
//         return MaterialPageRoute(builder: (_) => screen, settings: settings);
//       },
//     );
//   }

//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required IconData activeIcon,
//     required String label,
//   }) {
//     final isSelected = bottomNavController.currentIndex.value == index;

//     return Expanded(
//       child: Material(
//         color: Colors.transparent, // IMPORTANT
//         borderRadius: BorderRadius.circular(10),
//         child: InkWell(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           focusColor: Colors.transparent,
//           overlayColor: WidgetStateProperty.all(Colors.transparent),
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _onTabTapped(index),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   isSelected ? activeIcon : icon,
//                   color: isSelected ? Colors.deepOrangeAccent : Colors.grey,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: isSelected ? Colors.deepOrangeAccent : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItemCart({required int index, required String label}) {
//     final isSelected = bottomNavController.currentIndex.value == index;

//     return Expanded(
//       child: Material(
//         color: Colors.transparent, // IMPORTANT
//         borderRadius: BorderRadius.circular(10),
//         child: InkWell(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           focusColor: Colors.transparent,
//           overlayColor: WidgetStateProperty.all(Colors.transparent),
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _onTabTapped(index),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CartBadgeIcon(
//                 isActive: isSelected,
//                 activeColor: Colors.deepOrangeAccent,
//                 nonActiveColor: Colors.grey,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected ? Colors.deepOrangeAccent : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
