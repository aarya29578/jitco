import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_price_calculation_services.dart';

class CartStorageService {
  final _storage = GetStorage();
  final String _cartKey = 'cart_services';
  final String _slotKey = 'delivery_slots';

  // Save cart items to storage
  void saveCartItems(List<JsCartitem> cartItems) {
    final List<Map<String, dynamic>> itemsMap = cartItems
        .map((item) => item.toMap())
        .toList();
    _storage.write(_cartKey, itemsMap);
  }

  // Load cart items from storage
  List<JsCartitem> getCartItems() {
    final items = _storage.read<List>(_cartKey);
    if (items != null) {
      return items
          .map((itemMap) => JsCartitem.fromMap(itemMap.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  // Clear cart storage
  void clearCartStorage() {
    _storage.remove(_cartKey);
  }

  // Save warehouse ID separately
  void saveWarehouseId(String warehouseId) {
    _storage.write('current_warehouse_id', warehouseId);
  }

  // Get warehouse ID
  String? getWarehouseId() {
    return _storage.read('current_warehouse_id');
  }

  // Clear warehouse ID
  void clearWarehouseId() {
    _storage.remove('current_warehouse_id');
  }

  void saveDeliverySlot(DateTime? dateTime) {
    if (dateTime == null) {
      _storage.remove(_slotKey);
    } else {
      _storage.write(_slotKey, dateTime.toIso8601String());
    }
  }

  DateTime? getDeliverySlot() {
    final slot = _storage.read<String>(_slotKey);
    if (slot != null) {
      return DateTime.tryParse(slot);
    }
    return null;
  }
}

// controllers/cart_controller.dart
class JsCartcontroller extends GetxController {
  var cartItems = <JsCartitem>[].obs;
  var isLoading = false.obs;
  var isUpdatingPrices = false.obs;
  // var currentWarehouseId = RxString('');
  RxString currentWarehouseId = ''.obs;
  final CartStorageService _storageService = CartStorageService();
  final ApiServices _apiService = Get.find<ApiServices>();
  // var productDetailsCache = <String, Map<String, dynamic>>{}.obs;
  var productDetailsCache = <String, Map<String, dynamic>>{}.obs;
  int selectedUomIndex = 0.obs();

  // var deliveryDate = Rx<DateTime?>(null);
  // var deliveryTime = Rx<TimeOfDay?>(null);

  // final Rxn<DateTime> selectedDeliveryDateTime = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadCartFromStorage();
    // Load saved warehouse ID
    final savedWarehouseId = _storageService.getWarehouseId();
    if (savedWarehouseId != null) {
      currentWarehouseId.value = savedWarehouseId;
    }

    // final savedSlot = _storageService.getDeliverySlot();
    // if (savedSlot != null) {
    //   selectedDeliveryDateTime.value = savedSlot;
    // }
  }

  void setItemSlot(String productId, DateTime slot) {
    final index = cartItems.indexWhere((e) => e.id == productId);

    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(slotDateTime: slot);

      cartItems.refresh(); // ✅ VERY IMPORTANT
    }
  }

  // Load cart from storage when app starts
  void loadCartFromStorage() {
    try {
      isLoading(true);
      final storedItems = _storageService.getCartItems();
      cartItems.assignAll(storedItems);
      print('Loaded ${cartItems.length} items from storage');
    } catch (e) {
      print('Error loading cart from storage: $e');
    } finally {
      isLoading(false);
    }
  }

  // Save cart to storage
  void _saveCartToStorage() {
    try {
      _storageService.saveCartItems(cartItems);
      print('Saved ${cartItems.length} items to storage');
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  int get totalNumberOfProducts {
    int total = 0;
    for (var item in cartItems) {
      total += item.quantity;
    }
    print("Total>>>>>: $total");
    return total;
  }

  // Check and show price update dialog
  Future<void> checkPriceUpdate(String cityName) async {
    try {
      // Get warehouse ID from city
      final warehouseResponse = await _apiService.getWarehouseIdByCity(
        encodedCity: cityName,
      );

      if (warehouseResponse['data'] != null) {
        String warehouseId = '';

        if (warehouseResponse['data'] is List) {
          final warehouseList = warehouseResponse['data'] as List;
          if (warehouseList.isNotEmpty) {
            warehouseId = warehouseList[0]['_id'] ?? '';
          }
        } else if (warehouseResponse['data'] is Map) {
          warehouseId = warehouseResponse['data']['_id'] ?? '';
        }
      }
    } catch (e) {
      print('Error checking price update: $e');
      Get.snackbar(
        'Error',
        'Failed to check price updates: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateCartPrices(
    String warehouseId,
    String userId,
    String cityName,
  ) async {
    try {
      final JsPriceCalculationServices priceService =
          Get.find<JsPriceCalculationServices>();
      print("api is running from Cart item for warehouse: $warehouseId");
      isUpdatingPrices(true);

      // Clear cache ONCE before starting
      productDetailsCache.clear();

      List<String> updatedItems = [];
      List<String> failedItems = [];

      // Process items sequentially to avoid race conditions
      for (var i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        try {
          print('Processing item ${i + 1}/${cartItems.length}: ${item.name}');

          // IMPORTANT: Set warehouse ID BEFORE fetching
          currentWarehouseId.value = warehouseId;

          // Fetch updated product details with warehouse ID
          final productDetails = await _apiService.detailedProducts(
            productSlug: item.categorySlug ?? '',
            warehouseId: warehouseId,
            userId: userId,
          );

          // Extract new price from response
          if (productDetails is Map && productDetails.isNotEmpty) {
            // Store in cache
            productDetailsCache[item.id] = productDetails;

            // Calculate price using the resolveProductPrice function
            double newPrice =
                priceService.resolveProductPrice(productData: productDetails) ??
                item.price;

            // Only update if price has changed
            if (newPrice != item.price) {
              // Store original price if not already stored
              final originalPrice = item.originalPrice ?? item.price;

              cartItems[i] = JsCartitem(
                id: item.id,
                name: item.name,
                image: item.image,
                price: newPrice,
                gstPercentage: item.gstPercentage,
                quantity: item.quantity,
                categorySlug: item.categorySlug,
                selectedVariant: item.selectedVariant,
                originalPrice: originalPrice,
                warehouseId: warehouseId,
              );
              updatedItems.add(item.name);

              print(
                'Price updated for ${item.name}: $originalPrice → $newPrice',
              );
            } else {
              // Price same, just update warehouse ID
              cartItems[i] = item.copyWith(warehouseId: warehouseId);
            }
          } else {
            failedItems.add(item.name);
            print('No product details found for ${item.name}');
          }
        } catch (e) {
          print('Error updating price for item ${item.name}: $e');
          failedItems.add(item.name);
        }
      }

      // IMPORTANT: Update warehouse ID after all items processed
      currentWarehouseId.value = warehouseId;
      _storageService.saveWarehouseId(warehouseId);

      // Refresh UI
      // cartItems.refresh();
      // _saveCartToStorage();

      // Show appropriate message
      if (updatedItems.isNotEmpty) {
        Get.snackbar(
          'Prices Updated',
          '${updatedItems.length} item${updatedItems.length > 1 ? 's' : ''} updated for $cityName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else if (failedItems.isNotEmpty) {
        Get.snackbar(
          'Partial Update',
          'Updated warehouse but some prices could not be fetched',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'No Price Changes',
          'Prices remain the same for $cityName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating cart prices: $e');
      Get.snackbar(
        'Update Failed',
        'Failed to update prices: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingPrices(false);
    }
  }

  // Restore original prices
  void restoreOriginalPrices() {
    bool changesMade = false;

    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      if (item.originalPrice != null && item.originalPrice != item.price) {
        cartItems[i] = item.copyWith(
          price: item.originalPrice!,
          warehouseId: null,
        );
        changesMade = true;
      }
    }

    if (changesMade) {
      cartItems.refresh();
      _saveCartToStorage();
      currentWarehouseId.value = '';
      _storageService.clearWarehouseId();

      Get.snackbar(
        'Prices Restored',
        'Cart prices have been restored to original',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  // void addToCart(JsCartitem newItem) {
  //   final index = cartItems.indexWhere(
  //     (item) =>
  //         item.id == newItem.id &&
  //         item.selectedVariant == newItem.selectedVariant,
  //   );

  //   if (index != -1) {
  //     final existingItem = cartItems[index];

  //     cartItems[index] = existingItem.copyWith(
  //       quantity: existingItem.quantity + newItem.quantity,
  //     );
  //   } else {
  //     cartItems.add(newItem.copyWith(originalPrice: newItem.price));
  //   }

  //   _saveCartToStorage();
  // }
  void addToCart(JsCartitem newItem, {Map<String, dynamic>? productDetails}) {
    final index = cartItems.indexWhere(
      (item) =>
          item.id == newItem.id &&
          item.selectedVariant == newItem.selectedVariant,
    );

    if (index != -1) {
      final existingItem = cartItems[index];
      cartItems[index] = existingItem.copyWith(
        quantity: existingItem.quantity + newItem.quantity,
      );
    } else {
      cartItems.add(newItem.copyWith(originalPrice: newItem.price));
    }

    // Store product details if provided
    if (productDetails != null) {
      addProductDetailsToCache(newItem.id, productDetails);
    }

    _saveCartToStorage();
    cartItems.refresh(); // Force UI update
    update(); // Additional GetX update
  }

  // Remove item from cart
  void removeFromCart(String itemId, String? variant) {
    cartItems.removeWhere(
      (item) => item.id == itemId && item.selectedVariant == variant,
    );

    _saveCartToStorage();

    Get.snackbar(
      'Removed',
      'Item removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Update item quantity
  void updateQuantity(context, String itemId, int newQuantity, String variant) {
    const int maxQty = 10000;
    if (newQuantity > maxQty) {
      // Get.snackbar(
      //   "Limit Reached",
      //   "Maximum quantity allowed is $maxQty",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      final messenger = ScaffoldMessenger.of(context);

      messenger.hideCurrentSnackBar(); // closes current snackbar

      messenger.showSnackBar(
        SnackBar(
          content: Text("Maximum quantity allowed is $maxQty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (newQuantity <= 0) {
      removeFromCart(itemId, variant);
      return;
    }

    final itemIndex = cartItems.indexWhere(
      (item) => item.id == itemId && item.selectedVariant == variant,
    );
    if (itemIndex != -1) {
      cartItems[itemIndex].quantity = newQuantity;
      cartItems.refresh();
      _saveCartToStorage();
    }
  }

  // Update item variant
  void updateVariant(String itemId, String variant) {
    final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      cartItems[itemIndex].selectedVariant = variant;
      cartItems.refresh();
      _saveCartToStorage();
    }
  }

  // Clear entire cart
  void clearCart() {
    cartItems.clear();
    currentWarehouseId.value = '';
    _storageService.clearCartStorage();
    _storageService.clearWarehouseId();
  }

  // Add this method to update product details cache immediately
  void addProductDetailsToCache(
    String productId,
    Map<String, dynamic> details,
  ) {
    productDetailsCache[productId] = details;
    productDetailsCache.refresh(); // Force refresh observable
    update(); // Trigger GetX update
  }

  // Add this method to get product details from cache
  Map<String, dynamic>? getProductDetailsFromCache(String productId) {
    return productDetailsCache[productId];
  }

  // Add this method to your CartController class
  void updateCartItem(String itemId, JsCartitem updatedItem) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      cartItems[index] = updatedItem;
      _saveCartToStorage();
      update();
    }
  }

  // Check if cart is empty
  bool get isCartEmpty => cartItems.isEmpty;

  // Get item count for a specific product
  int getItemQuantity(String productId) {
    final item = cartItems.firstWhereOrNull((item) => item.id == productId);
    return item?.quantity ?? 0;
  }

  // Get total items count
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

 // Get total price
double get totalPrice {
  for (final item in cartItems) {
    print('========== CART PRICE DEBUG ==========');
    print('Product: ${item.name}');
    print('item.price: ${item.price}');
    print('item.quantity: ${item.quantity}');
    print('item.gstPercentage: ${item.gstPercentage}');
    print('item.totalPrice: ${item.totalPrice}');
    print('item.perPriceTax: ${item.perPriceTax}');
    print('item.groupPerPriceTax: ${item.groupPerPriceTax}');
    print('======================================');
  }

  return cartItems.fold(
    0,
    (sum, item) => sum + item.totalPrice,
  );
}

// Get total GST price for group product
double get totalPerPriceTax =>
    cartItems.fold(0, (sum, item) => sum + item.groupPerPriceTax);

// Get grand total
double get grandTotal {
  final result = totalPrice + totalPerPriceTax;

  print('******** GRAND TOTAL DEBUG ********');
  print('totalPrice = $totalPrice');
  print('totalPerPriceTax = $totalPerPriceTax');
  print('grandTotal = $result');
  print('***********************************');

  return result;
}



  // Check if any prices have been changed
  bool get hasPriceChanges => cartItems.any(
    (item) => item.originalPrice != null && item.originalPrice != item.price,
  );

  // Check if specific item has price change
  bool hasItemPriceChanged(String itemId) {
    final item = cartItems.firstWhereOrNull((item) => item.id == itemId);
    return item != null &&
        item.originalPrice != null &&
        item.originalPrice != item.price;
  }

  // Get price change percentage for item
  double? getItemPriceChangePercent(String itemId) {
    final item = cartItems.firstWhereOrNull((item) => item.id == itemId);
    if (item == null || item.originalPrice == null || item.originalPrice == 0) {
      return null;
    }
    return ((item.price - item.originalPrice!) / item.originalPrice!) * 100;
  }

  // Check if warehouse is set
  bool get hasWarehouse => currentWarehouseId.value.isNotEmpty;

  // Get warehouse display
  String get warehouseDisplay {
    if (currentWarehouseId.value.isEmpty) return 'Not set';
    return '${currentWarehouseId.value.substring(0, 8)}...';
  }

  // Add these methods
  // void setDeliveryDate(DateTime date) {
  //   deliveryDate.value = date;
  // }

  // void setDeliveryTime(TimeOfDay time) {
  //   deliveryTime.value = time;
  // }

  void setItemDeliveryDateTime(String itemId, String variant, DateTime dt) {
    final index = cartItems.indexWhere(
      (i) => i.id == itemId && i.selectedVariant == variant,
    );

    if (index != -1) {
      cartItems[index].deliveryDateTime = dt;

      cartItems.refresh(); // VERY IMPORTANT
      _saveCartToStorage();
    }
  }

  // void setDeliveryDateTime(DateTime dateTime) {
  //   selectedDeliveryDateTime.value = dateTime;
  //   _storageService.saveDeliverySlot(dateTime); //Persist
  // }

  // Optional: Combine date and time into DateTime
  // DateTime? getDeliveryDateTime() {
  //   if (deliveryDate.value == null || deliveryTime.value == null) {
  //     return null;
  //   }
  //   return DateTime(
  //     deliveryDate.value!.year,
  //     deliveryDate.value!.month,
  //     deliveryDate.value!.day,
  //     deliveryTime.value!.hour,
  //     deliveryTime.value!.minute,
  //   );
  // }
}
