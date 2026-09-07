import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_all_menus_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

class AllMenuController extends GetxController {
  Rx<JmAllMenusModel> allMenuResponse = JmAllMenusModel().obs;
  final JMApiService _jmApiService = Get.find<JMApiService>();
  RxBool isLoading = false.obs;

  RxBool isMoreLoading = false.obs; // for loading more at bottom
  RxInt currentPage = 1.obs;
  int totalPages = 1;

  RxList<Allmenu> allMenus = <Allmenu>[].obs;
  RxList<MenuItem> menuDetail = <MenuItem>[].obs;

  ///Without pagination
  // Future getAllMenu() async {
  //   try {
  //     isLoading.value = true;
  //     final response = await _jmApiService.getAllMenu(page: 1, limit: 10);
  //     print("allMenuResponsefromcontrolller1: $response");
  //     print("allMenuResponsefromcontrolller2: ${response.success}");
  //     if (response.success == true) {
  //       allMenuResponse.value = response;
  //       // isLoading.value = false;
  //     }
  //   } catch (e) {
  //     throw Exception(
  //       'An error occurred while fetching all menu from controller: $e',
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  ///With Pagination
  Future getAllMenu({bool loadMore = false}) async {
    if (isLoading.value || isMoreLoading.value) return;

    if (loadMore) {
      if (currentPage.value >= totalPages) return;
      isMoreLoading(true);
    } else {
      currentPage.value = 1;
      allMenus.clear();
      isLoading(true);
    }

    try {
      final response = await _jmApiService.getAllMenu(
        page: currentPage.value,
        limit: 10,
      );

      totalPages = response.totalPages ?? 1;

      if (response.menus != null && response.menus!.isNotEmpty) {
        allMenus.addAll(response.menus!);

        if (loadMore) currentPage.value++;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }
}
