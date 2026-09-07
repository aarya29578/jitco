import 'package:flutter/widgets.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/jitco_menu_nav_bar.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';

class GridItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final Widget Function() route;

  GridItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.route,
  });
}

// Create a list of items
List<GridItem> itemList = [
  GridItem(
    title: "Start Ordering Smarter",
    subtitle: "JIT Supply",
    imagePath: jitcoMain[0],
    route: () => JitcoSupplyNavBar(),
  ),
  GridItem(
    title: "Optimize Your Menu",
    subtitle: "JIT Menu",
    imagePath: jitcoMain[1],
    route: () => JitcoMenuNavBar(),
  ),
  /*
  GridItem(
    title: "Explore Liquor Brands",
    subtitle: "JIT Liquor",
    imagePath: jitcoMain[2],
    // route: JitLiquor(),
    route: () => JlBottomNavBar(),
  ),
  */
  GridItem(
    title: "Find Verified Services",
    subtitle: "JIT Service",
    imagePath: jitcoMain[3],
    // route: JitService(),
    route: () => JsBottomNavBar(),
  ),
];
