import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/detail_menu_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

// class DetailMenuController extends GetxController {
//   Rx<DetailMenuModel> detailMenuResponse = DetailMenuModel().obs;
//   final JMApiService _jmApiService = Get.find<JMApiService>();
//   RxBool isLoading = false.obs;

//   RxInt quantity = 0.obs;

//   Future getDetailMenu({String? menuId}) async {
//     try {
//       isLoading.value = true;
//       final response = await _jmApiService.getDetailMenu(menuId: menuId);
//       print("allMenuResponsefromcontrolller1: $response");
//       print("allMenuResponsefromcontrolller2: ${response.success}");
//       if (response.success == true) {
//         detailMenuResponse.value = response;
//         // isLoading.value = false;
//       }
//     } catch (e) {
//       throw Exception(
//         'An error occurred while fetching all menu from controller: $e',
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

class DetailMenuController extends GetxController {
  Rx<DetailMenuModel> detailMenuResponse = DetailMenuModel().obs;

  final JMApiService _jmApiService = Get.find<JMApiService>();
  RxBool isLoading = false.obs;

  void deleteItem(int index) {
    final items = detailMenuResponse.value.menuDetails?.menuItems;

    if (items == null || index >= items.length) return;

    // Remove item
    items.removeAt(index);

    // Remove qty
    quantities.remove(index);

    // Re-index quantities (important!)
    final newMap = <int, int>{};
    for (int i = 0; i < items.length; i++) {
      newMap[i] = quantities[i] ?? 1;
    }

    quantities.value = newMap;

    // Refresh GetX
    detailMenuResponse.refresh();
  }

  /// qty per index
  RxMap<int, int> quantities = <int, int>{}.obs;

  void setQuantity(int index, int qty) {
    if (qty < 1) qty = 1;
    quantities[index] = qty;
  }

  int getQty(int index) {
    return quantities[index] ?? 1;
  }

  double priceTotal(MenuItem item, int index) {
    final qty = getQty(index);
    return (item.price ?? 0) * qty;
  }

  double gstTotal(MenuItem item, int index) {
    final pt = priceTotal(item, index);
    final gst = item.gst ?? 0;
    return pt * gst / 100;
  }

  double finalTotal(MenuItem item, int index) {
    return priceTotal(item, index) + gstTotal(item, index);
  }

  Future getDetailMenu({String? menuId}) async {
    try {
      isLoading.value = true;

      final response = await _jmApiService.getDetailMenu(menuId: menuId);

      if (response.success == true) {
        detailMenuResponse.value = response;

        /// initialize qty = 1 for each item
        final items = response.menuDetails?.menuItems ?? [];
        for (int i = 0; i < items.length; i++) {
          quantities[i] = items[i].quantity ?? 1;
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to load menu details",
          backgroundColor: Color(0xFFFF5252),
          colorText: Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      print("Error fetching menu detail: $e");
      Get.snackbar(
        "Error",
        "An error occurred while fetching menu details",
        backgroundColor: Color(0xFFFF5252),
        colorText: Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  double menuSubTotal() {
    double sum = 0;

    final items = detailMenuResponse.value.menuDetails?.menuItems ?? [];

    for (int i = 0; i < items.length; i++) {
      sum += priceTotal(items[i], i);
    }

    return sum;
  }

  double menuGstTotal() {
    double sum = 0;

    final items = detailMenuResponse.value.menuDetails?.menuItems ?? [];

    for (int i = 0; i < items.length; i++) {
      sum += gstTotal(items[i], i);
    }

    return sum;
  }

  double menuFinalTotal() {
    return menuSubTotal() + menuGstTotal();
  }
}
