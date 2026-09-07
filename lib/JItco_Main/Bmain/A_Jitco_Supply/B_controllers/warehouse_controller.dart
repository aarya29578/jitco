// // // controllers/warehouse_controller.dart - Optimized version
// import 'package:get/get.dart';
// import 'package:jitco_app/controllers/auth_controllers.dart';
// import 'package:jitco_app/services/api_service.dart';

// class WarehouseController extends GetxController {
//   final ApiService apiService = Get.find<ApiService>();
//   final AuthController authController = Get.find<AuthController>();

//   RxString selectedWarehouseId = ''.obs;
//   RxString selectedWarehouseCity = ''.obs;
//   RxBool isLoadingWarehouse = false.obs;
//   RxString warehouseError = ''.obs;

//   // Store product prices by productSlug with warehouse-specific pricing
//   RxMap<String, double> warehousePrices = <String, double>{}.obs;
//   RxMap<String, double> warehouseGstPrices = <String, double>{}.obs;

//   // Debounce timer to prevent rapid updates
//   DateTime _lastWarehouseFetch = DateTime.now();
//   static const Duration _minFetchInterval = Duration(milliseconds: 500);

//   // Previous city to avoid duplicate fetches
//   String? _previousCity;

//   // Fetch warehouse ID by city with debouncing
//   Future<void> fetchWarehouseByCity(String cityName) async {
//     // Avoid duplicate fetches for same city
//     if (_previousCity == cityName) {
//       return;
//     }

//     // Debounce rapid fetches
//     final now = DateTime.now();
//     if (now.difference(_lastWarehouseFetch) < _minFetchInterval) {
//       print('Debouncing warehouse fetch for: $cityName');
//       return;
//     }

//     _previousCity = cityName;
//     _lastWarehouseFetch = now;

//     try {
//       isLoadingWarehouse.value = true;
//       warehouseError.value = '';
//       selectedWarehouseCity.value = cityName;

//       print('Fetching warehouse for city: $cityName');

//       final encodedCity = Uri.encodeComponent(cityName);
//       final response = await apiService.getWarehouseIdByCity(
//         encodedCity: encodedCity,
//       );

//       if (response['success'] == true && response['data'] != null) {
//         if (response['data'] is List && response['data'].isNotEmpty) {
//           final warehouse = response['data'][0];
//           selectedWarehouseId.value = warehouse['_id']?.toString() ?? '';
//           print('Warehouse found: ${selectedWarehouseId.value}');

//           // Clear old prices when warehouse changes
//           warehousePrices.clear();
//           warehouseGstPrices.clear();
//         } else {
//           warehouseError.value = 'No warehouse found for city: $cityName';
//           selectedWarehouseId.value = '';
//           print('No warehouse found');
//         }
//       } else {
//         warehouseError.value =
//             response['message'] ?? 'Failed to fetch warehouse';
//         selectedWarehouseId.value = '';
//         print('Warehouse API error: ${response['message']}');
//       }
//     } catch (e) {
//       warehouseError.value = 'Error fetching warehouse: $e';
//       selectedWarehouseId.value = '';
//       print('Warehouse fetch error: $e');
//     } finally {
//       // Delay setting loading to false to prevent rapid toggling
//       Future.delayed(Duration(milliseconds: 300), () {
//         isLoadingWarehouse.value = false;
//       });
//     }
//   }

//   // Fetch product details with warehouse-specific pricing
//   Future<void> fetchProductWithWarehousePricing({
//     required String productSlug,
//   }) async {
//     try {
//       if (selectedWarehouseId.value.isEmpty) {
//         print('No warehouse selected for product: $productSlug');
//         return;
//       }

//       print('Fetching warehouse price for: $productSlug');

//       final response = await apiService.detailedProducts(
//         productSlug: productSlug,
//         warehouseId: selectedWarehouseId.value,
//       );

//       if (response != null && response is Map<String, dynamic>) {
//         // Extract price and GST from response
//         final price = response['selling_price']?.toDouble();
//         final gstPrice = response['gst_price']?.toDouble();

//         if (price != null) {
//           warehousePrices[productSlug] = price;
//           print('Warehouse price for $productSlug: $price');
//         }

//         if (gstPrice != null) {
//           warehouseGstPrices[productSlug] = gstPrice;
//           print('Warehouse GST for $productSlug: $gstPrice');
//         }
//       }
//     } catch (e) {
//       print('Error fetching product pricing for $productSlug: $e');
//     }
//   }

//   // Get warehouse price for a product slug
//   double? getWarehousePrice(String productSlug) {
//     return warehousePrices[productSlug];
//   }

//   // Get warehouse GST for a product slug
//   double? getWarehouseGst(String productSlug) {
//     return warehouseGstPrices[productSlug];
//   }

//   // Check if warehouse pricing is available for a product
//   bool hasWarehousePrice(String productSlug) {
//     return warehousePrices.containsKey(productSlug);
//   }

//   // Clear all warehouse-specific data
//   void clearWarehouseData() {
//     selectedWarehouseId.value = '';
//     selectedWarehouseCity.value = '';
//     warehousePrices.clear();
//     warehouseGstPrices.clear();
//     warehouseError.value = '';
//     _previousCity = null;
//   }
// }
