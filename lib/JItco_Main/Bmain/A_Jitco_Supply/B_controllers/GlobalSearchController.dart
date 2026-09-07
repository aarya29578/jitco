// import 'dart:async';
// import 'package:get/get.dart';

// class GlobalSearchController extends GetxController {
//   final searchText = "".obs;

//   Timer? _debounce;

//   // Call this whenever text changes
//   void onSearchChanged(String text, Function(String) onSearchCallback) {
//     searchText.value = text;

//     if (_debounce?.isActive ?? false) {
//       _debounce!.cancel();
//     }

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       onSearchCallback(text);
//     });
//   }

//   @override
//   void onClose() {
//     _debounce?.cancel();
//     super.onClose();
//   }
// }
