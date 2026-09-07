import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

// class JmOrderController extends GetxController {
//   final JMApiService _apiService = Get.find<JMApiService>();

//   RxList<OrdersResponse> orders = <OrdersResponse>[].obs;
//   RxBool isLoading = false.obs;
//   RxInt currentPage = 1.obs;
//   RxInt totalPages = 1.obs;
//   RxInt totalOrders = 0.obs;
//   RxString currentStatus = 'All'.obs;

//   // Load orders from API
//   Future<void> loadOrders({int page = 1, String status = 'All'}) async {
//     try {
//       isLoading.value = true;

//       final response = await _apiService.getJmOrders(
//         page: page,
//         limit: 20,
//         // status: status,
//       );

//       if (response.success == true) {
//         final ordersData = response.orders as List<dynamic>;

//         print("Orderjmfromcontrolller:$ordersData");

//         final newOrders = ordersData
//             .map(
//               (json) => OrdersResponse.fromJson(json as Map<String, dynamic>),
//             )
//             .toList();

//         // final ordersData = response['orders'] as List<dynamic>? ?? [];

//         // final newOrders = ordersData
//         //     .where((e) => e != null && e is Map<String, dynamic>)
//         //     .map((e) => Order.fromJson(e))
//         //     .toList();

//         print("responseOrders$ordersData");

//         print("getOrders$newOrders");

//         if (page == 1) {
//           orders.value = newOrders;
//         } else {
//           orders.addAll(newOrders);
//         }

//         currentPage.value = response.page ?? 1;
//         totalPages.value = response.totalPages ?? 1;
//         totalOrders.value = response.total ?? 0;
//         currentStatus.value = status;
//       }
//     } catch (e) {
//       print('Error loading orders: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to load orders: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Refresh orders
//   Future<void> refreshOrders() async {
//     await loadOrders(page: 1, status: currentStatus.value);
//   }

//   // Load more orders (pagination)
//   Future<void> loadMoreOrders() async {
//     if (currentPage.value < totalPages.value && !isLoading.value) {
//       await loadOrders(
//         page: currentPage.value + 1,
//         status: currentStatus.value,
//       );
//     }
//   }

//   // Change status filter
//   Future<void> changeStatus(String status) async {
//     await loadOrders(page: 1, status: status);
//   }

//   // Get order by ID
//   // Order? getOrderById(String id) {
//   //   return orders.firstWhereOrNull((OrdersResponse) => OrdersResponse.id == id);
//   // }
// }

class JmOrderController extends GetxController {
  final JMApiService _apiService = Get.find<JMApiService>();

  RxList<OrderDetails> orders = <OrderDetails>[].obs;

  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalOrders = 0.obs;
  RxString currentStatus = 'All'.obs;

  Future<void> loadOrders({int page = 1, String status = 'All'}) async {
    try {
      isLoading.value = true;

      final response = await _apiService.getJmOrders(
        page: page,
        limit: 20,
        status: status,
      );

      if (response.success == true) {
        final newOrders = response.orders ?? [];

        if (page == 1) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        currentPage.value = response.page ?? 1;
        totalPages.value = response.totalPages ?? 1;
        totalOrders.value = response.total ?? 0;
        currentStatus.value = status;
      }
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders(page: 1, status: currentStatus.value);
  }

  Future<void> loadMoreOrders() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await loadOrders(
        page: currentPage.value + 1,
        status: currentStatus.value,
      );
    }
  }

  Future<void> changeStatus(String status) async {
    await loadOrders(page: 1, status: status);
  }
}
