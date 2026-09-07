import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;
  final navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

  var shouldFocusSearch = false.obs;

  void switchTab(int index) {
    print("SWITCHING TAB TO: $index");
    currentIndex.value = index;
  }

  void openProductSearch() {
    shouldFocusSearch.value = true;
    currentIndex.value = 3; // Products tab index
  }
}
