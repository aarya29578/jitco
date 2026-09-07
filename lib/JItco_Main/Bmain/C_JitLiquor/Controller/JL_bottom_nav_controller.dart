import 'package:get/get.dart';

class JlBottomNavController extends GetxController {
  var currentIndex = 0.obs;

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
