import 'package:get/get.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Models/JL_order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';

class JsOrderController extends GetxController {
  final JsApiService _apiService = Get.find<JsApiService>();

  RxList<JsOrder> orders = <JsOrder>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalOrders = 0.obs;
  RxString currentStatus = 'All'.obs;

  // Load orders from API
  Future<void> loadOrders({int page = 1, String status = 'All'}) async {
    try {
      isLoading.value = true;

      final response = await _apiService.jsGetOrder(
        page: page,
        limit: 20,
        status: status,
      );

      if (response['success'] == true) {
        final ordersData = response['orders'] as List<dynamic>;

        final newOrders = ordersData
            .map((json) => JsOrder.fromJson(json as Map<String, dynamic>))
            .toList();

        // final ordersData = response['orders'] as List<dynamic>? ?? [];

        // final newOrders = ordersData
        //     .where((e) => e != null && e is Map<String, dynamic>)
        //     .map((e) => Order.fromJson(e))
        //     .toList();

        print("responseOrders$ordersData");

        print("getOrders$newOrders");

        if (page == 1) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        currentPage.value = response['page'] ?? 1;
        totalPages.value = response['totalPages'] ?? 1;
        totalOrders.value = response['total'] ?? 0;
        currentStatus.value = status;
      }
    } catch (e) {
      print('Error loading orders: $e');
      Get.snackbar(
        'Error',
        'Failed to load orders: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(page: 1, status: currentStatus.value);
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await loadOrders(
        page: currentPage.value + 1,
        status: currentStatus.value,
      );
    }
  }

  // Change status filter
  Future<void> changeStatus(String status) async {
    await loadOrders(page: 1, status: status);
  }

  // Get order by ID
  JsOrder? getOrderById(String id) {
    return orders.firstWhereOrNull((order) => order.id == id);
  }
}
