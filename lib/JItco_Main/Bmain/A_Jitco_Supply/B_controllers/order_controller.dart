// // controllers/order_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:jitco_app/models/order_model.dart';
// import 'package:jitco_app/models/cart_model.dart';
// import 'package:uuid/uuid.dart';

// class OrderController extends GetxController {
//   var orders = <Order>[].obs;
//   final GetStorage _storage = GetStorage();
//   final String _storageKey = 'orders';
//   final Uuid _uuid = Uuid();

//   @override
//   void onInit() {
//     super.onInit();
//     loadOrders();
//   }

//   // Load orders from storage
//   void loadOrders() {
//     try {
//       final storedOrders = _storage.read<List>(_storageKey);
//       if (storedOrders != null) {
//         orders.assignAll(
//           storedOrders.map((order) => Order.fromMap(order)).toList(),
//         );
//         print('Loaded ${orders.length} orders from storage');
//       }
//     } catch (e) {
//       print('Error loading orders: $e');
//     }
//   }

//   // Save orders to storage
//   void _saveOrders() {
//     try {
//       _storage.write(
//         _storageKey,
//         orders.map((order) => order.toMap()).toList(),
//       );
//     } catch (e) {
//       print('Error saving orders: $e');
//     }
//   }

//   // Create a new order
//   Order createOrder({
//     required List<CartItem> items,
//     required String address,
//     required String paymentMethod,
//     required double subtotal,
//     required double tax,
//     required double total,
//   }) {
//     return Order(
//       id: _uuid.v4(),
//       items: List.from(items), // Create a copy of items
//       address: address,
//       paymentMethod: paymentMethod,
//       subtotal: subtotal,
//       tax: tax,
//       total: total,
//       orderDate: DateTime.now(),
//       status: 'confirmed',
//     );
//   }

//   // Add an order
//   void addOrder(Order order) {
//     orders.insert(0, order); // Add at beginning for latest first
//     _saveOrders();

//     Get.snackbar(
//       'Order Placed',
//       'Order #${order.id.substring(0, 8)} has been placed successfully!',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   // Get order by ID
//   Order? getOrderById(String id) {
//     return orders.firstWhereOrNull((order) => order.id == id);
//   }

//   // Get all orders sorted by date (newest first)
//   List<Order> get allOrders =>
//       orders.toList()..sort((a, b) => b.orderDate.compareTo(a.orderDate));

//   // Get order count
//   int get orderCount => orders.length;

//   // Clear all orders (for testing)
//   void clearAllOrders() {
//     orders.clear();
//     _saveOrders();
//   }
// }

// controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';

class OrderController extends GetxController {
  final ApiServices _apiService = Get.find<ApiServices>();

  RxList<Order> orders = <Order>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalOrders = 0.obs;
  RxString currentStatus = 'All'.obs;

  // Load orders from API
  Future<void> loadOrders({int page = 1, String status = 'All'}) async {
    try {
      isLoading.value = true;

      final response = await _apiService.getOrder(
        page: page,
        limit: 20,
        status: status,
      );

      if (response['success'] == true) {
        final ordersData = response['orders'] as List<dynamic>;

        final newOrders = ordersData
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
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
  Order? getOrderById(String id) {
    return orders.firstWhereOrNull((order) => order.id == id);
  }
}
