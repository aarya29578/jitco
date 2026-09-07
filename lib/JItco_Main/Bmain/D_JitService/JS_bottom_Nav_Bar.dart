import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_service_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_home_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/B_JS_Category/JS_category_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartcount.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/D_JS_Cart/Js_cart_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_cart_badge.dart';
import 'package:jitco_app/JItco_Main/jitco_main.dart';

///Method -1
// Import your existing screens

// class JsBottomNavBar extends StatefulWidget {
//   final int initialIndex;

//   const JsBottomNavBar({super.key, this.initialIndex = 0});

//   @override
//   State<JsBottomNavBar> createState() => _JsBottomNavBarState();
// }

// class _JsBottomNavBarState extends State<JsBottomNavBar> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     JsHomeScreen(),
//     JsCategoryScreen(),
//     JsServiceScreen(),
//     JsCartScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           selectedItemColor: Colors.deepOrangeAccent,
//           unselectedItemColor: Colors.grey,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
//           items: _buildNavItems(),
//         ),
//       ),
//     );
//   }

//   List<BottomNavigationBarItem> _buildNavItems() {
//     return [
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
//         icon: JsCartBadgeIcon(isActive: false, nonActiveColor: Colors.grey),
//         activeIcon: JsCartBadgeIcon(
//           isActive: true,
//           activeColor: Colors.deepOrangeAccent,
//         ),
//         label: 'Cart',
//       ),
//     ];
//   }
// }

// class JsBottomNavBar extends StatefulWidget {
//   final int initialIndex;

//   const JsBottomNavBar({super.key, this.initialIndex = 0});

//   @override
//   State<JsBottomNavBar> createState() => JsBottomNavBarState();
// }

// class JsBottomNavBarState extends State<JsBottomNavBar> {
//   // int _currentIndex = 0;
//   final JsBottomNavController navController = Get.put(JsBottomNavController());
//   DateTime? _lastBackPressTime; // Track last back press time

//   // Each tab has its own navigator
//   final List<GlobalKey<NavigatorState>> _navigatorKeys = [
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//   ];

//   // Make this method public (FOR HOMESCREEN SEARCH -> PRODUCTSCREEN)
//   void switchToTab(int index) {
//     setState(() {
//       navController.currentIndex.value = index;
//     });
//     // Pop to root of the selected tab
//     _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//   }

//   @override
//   void initState() {
//     super.initState();
//     navController.currentIndex.value = widget.initialIndex;
//   }

//   // Handle back button properly
//   // Future<bool> _onWillPop() async {
//   //   final currentNavigator =
//   //       _navigatorKeys[navController.currentIndex.value].currentState;

//   //   // If current tab has navigation stack, pop it
//   //   if (currentNavigator != null && currentNavigator.canPop()) {
//   //     currentNavigator.pop();
//   //     return false; // Don't exit app
//   //   }

//   //   // If on home tab, implement double tap to exit
//   //   if (navController.currentIndex.value == 0) {
//   //     final now = DateTime.now();

//   //     // Check if user pressed back twice within 2 seconds
//   //     if (_lastBackPressTime == null ||
//   //         now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
//   //       // First press - show warning
//   //       _lastBackPressTime = now;
//   //       _showExitWarning();
//   //       return false; // Don't exit app
//   //     }

//   //     // Second press within 2 seconds - exit app
//   //     return true; // Exit app
//   //   }

//   //   // If not on home tab, switch to home tab
//   //   setState(() {
//   //     navController.currentIndex.value = 0;
//   //   });
//   //   return false; // Don't exit app
//   // }
//   Future<bool> _onWillPop() async {
//     final navigator =
//         _navigatorKeys[navController.currentIndex.value].currentState;

//     /// ✅ Only pop if REALLY can pop
//     if (navigator != null && navigator.canPop()) {
//       navigator.pop();
//       return false;
//     }

//     /// ✅ If not on Home → switch to Home
//     if (navController.currentIndex.value != 0) {
//       navController.switchTab(0);
//       return false;
//     }

//     /// ✅ Double back to exit
//     final now = DateTime.now();

//     if (_lastBackPressTime == null ||
//         now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
//       _lastBackPressTime = now;
//       _showExitWarning();
//       return false;
//     }

//     return true;
//   }

//   void _showExitWarning() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Press back again to exit',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         duration: Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.all(20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _onTabTapped(int index) {
//     if (index == navController.currentIndex.value) {
//       // If tapping current tab, pop to root
//       _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//     } else {
//       setState(() {
//         navController.currentIndex.value = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Obx(
//         () => Scaffold(
//           body: IndexedStack(
//             index: navController.currentIndex.value,
//             children: [
//               // JsHomeScreen(),
//               // JsCategoryScreen(),
//               // JsServiceScreen(),
//               // JsCartScreen(),
//               _buildNavigator(0, JsHomeScreen()),
//               _buildNavigator(1, JsCategoryScreen()),
//               _buildNavigator(2, JsServiceScreen()),
//               _buildNavigator(3, JsCartScreen()),
//             ],
//           ),
//           bottomNavigationBar: _buildBottomNavigationBar(),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavigator(int index, Widget screen) {
//     return Navigator(
//       key: _navigatorKeys[index],
//       onGenerateRoute: (settings) {
//         return MaterialPageRoute(
//           builder: (context) => screen,
//           settings: settings,
//         );
//       },
//     );
//   }

//   // Widget _buildNavigator(int index, Widget screen) {
//   //   return Navigator(
//   //     key: _navigatorKeys[index],
//   //     onGenerateRoute: (settings) {
//   //       if (index == 2) {
//   //         // Products tab
//   //         return MaterialPageRoute(
//   //           builder: (context) => JMProductScreen(
//   //             // No parameters = All Products mode
//   //             categorySlug: null,
//   //             categoryName: null,
//   //             categoryId: null,
//   //             fromCategoryScreen: false, // Important: false for Products tab
//   //           ),
//   //           settings: settings,
//   //         );
//   //       }

//   //       return MaterialPageRoute(
//   //         builder: (context) => screen,
//   //         settings: settings,
//   //       );
//   //     },
//   //   );
//   // }

//   // BottomNavigationBar _buildBottomNavigationBar() {
//   //   return BottomNavigationBar(
//   //     currentIndex: navController.currentIndex.value,
//   //     onTap: _onTabTapped,
//   //     type: BottomNavigationBarType.fixed,
//   //     backgroundColor: Colors.white,
//   //     selectedItemColor: Colors.deepOrangeAccent,
//   //     unselectedItemColor: Colors.grey,
//   //     showSelectedLabels: true,
//   //     showUnselectedLabels: true,
//   //     selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//   //     elevation: 8,
//   //     items: [
//   //       BottomNavigationBarItem(
//   //         icon: Icon(Icons.home_outlined),
//   //         activeIcon: Icon(Icons.home),
//   //         label: 'Home',
//   //       ),
//   //       BottomNavigationBarItem(
//   //         icon: Icon(Icons.category_outlined),
//   //         activeIcon: Icon(Icons.category),
//   //         label: 'Categories',
//   //       ),
//   //       BottomNavigationBarItem(
//   //         icon: Icon(Icons.shopping_bag_outlined),
//   //         activeIcon: Icon(Icons.shopping_bag),
//   //         label: 'Services',
//   //       ),
//   //       BottomNavigationBarItem(
//   //         icon: JsCartBadgeIcon(isActive: false, nonActiveColor: Colors.grey),
//   //         activeIcon: JsCartBadgeIcon(
//   //           isActive: true,
//   //           activeColor: Colors.deepOrangeAccent,
//   //         ),
//   //         label: 'Cart',
//   //       ),
//   //     ],
//   //   );
//   // }
//   Widget _buildBottomNavigationBar() {
//     return Obx(
//       () => BottomNavigationBar(
//         // wrap this too
//         currentIndex: navController.currentIndex.value,
//         onTap: _onTabTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.deepOrangeAccent,
//         unselectedItemColor: Colors.grey,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category_outlined),
//             activeIcon: Icon(Icons.category),
//             label: 'Categories',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag_outlined),
//             activeIcon: Icon(Icons.shopping_bag),
//             label: 'Products',
//           ),
//           BottomNavigationBarItem(
//             icon: JsCartBadgeIcon(isActive: false),
//             activeIcon: JsCartBadgeIcon(isActive: true),
//             label: 'Cart',
//           ),
//         ],
//       ),
//     );
//   }
// }

///Method -2
// class JsBottomNavBar extends StatefulWidget {
//   final int initialIndex;

//   const JsBottomNavBar({super.key, this.initialIndex = 0});

//   @override
//   State<JsBottomNavBar> createState() => JsBottomNavBarState();
// }

// class JsBottomNavBarState extends State<JsBottomNavBar> {
//   final JsBottomNavController navController = Get.put(JsBottomNavController());

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
//     navController.currentIndex.value = widget.initialIndex;
//   }

//   void switchToTab(int index) {
//     navController.currentIndex.value = index;
//     _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//   }

//   Future<bool> _onWillPop() async {
//     final index = navController.currentIndex.value;
//     final navigator = _navigatorKeys[index].currentState;

//     if (navigator != null && navigator.canPop()) {
//       navigator.pop();
//       return false;
//     }

//     if (index != 0) {
//       navController.switchTab(0);
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
//         content: const Text(
//           'JIT Service - Press back again to exit',
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
//     if (index == navController.currentIndex.value) {
//       _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
//     } else {
//       navController.currentIndex.value = index;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Obx(
//         () => Scaffold(
//           body: IndexedStack(
//             index: navController.currentIndex.value,
//             children: [
//               _buildNavigator(0, JsHomeScreen()),
//               _buildNavigator(1, JsCategoryScreen()),
//               _buildNavigator(2, JsServiceScreen()),
//               _buildNavigator(3, JsCartScreen()),
//             ],
//           ),

//           /// ✅ CENTER FLOATING BUTTON
//           floatingActionButton: SizedBox(
//             height: 80,
//             width: 80,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   height: 68,
//                   width: 68,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Get.offAll(
//                       () => const JItcoMain(),
//                       transition: Transition.leftToRight,
//                     );
//                   },
//                   child: Container(
//                     height: 55,
//                     width: 55,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Center(child: SvgPicture.asset(logo, height: 19)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,

//           /// ✅ BOTTOM APP BAR
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
//                   const SizedBox(width: 40),
//                   _buildNavItem(
//                     index: 2,
//                     icon: Icons.design_services_outlined,
//                     activeIcon: Icons.design_services,
//                     label: "Services",
//                   ),
//                   _buildNavItemCart(index: 3, label: "Cart"),
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
//     final isSelected = navController.currentIndex.value == index;

//     return Expanded(
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
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
//     final isSelected = navController.currentIndex.value == index;

//     return Expanded(
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _onTabTapped(index),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               JsCartBadgeIcon(
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

class JsBottomNavBar extends StatefulWidget {
  final int initialIndex;

  const JsBottomNavBar({super.key, this.initialIndex = 1});

  @override
  State<JsBottomNavBar> createState() => JsBottomNavBarState();
}

class JsBottomNavBarState extends State<JsBottomNavBar> {
  // int _currentIndex = 0;
  final JsBottomNavController bottomNavController = Get.put(
    JsBottomNavController(),
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
  void switchToTab(int index) {
    setState(() {
      bottomNavController.currentIndex.value = index;
    });
    // Pop to root of the selected tab
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   bottomNavController.currentIndex.value = widget.initialIndex;
  // }
  @override
  void initState() {
    super.initState();

    bottomNavController.currentIndex.value = widget.initialIndex == 0
        ? 1
        : widget.initialIndex;
  }

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
              _buildNavigator(1, JsHomeScreen()),
              _buildNavigator(2, JsCategoryScreen()),
              _buildNavigator(3, JsServiceScreen()),
              _buildNavigator(4, JsCartScreen()),
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
            icon: JsCartBadgeIcon(isActive: false),
            activeIcon: JsCartBadgeIcon(isActive: true),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}
