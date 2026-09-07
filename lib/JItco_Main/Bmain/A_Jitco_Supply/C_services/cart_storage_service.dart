// services/cart_storage_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';

class CartStorageService {
  final _storage = GetStorage();
  final String _cartKey = 'supply_cart_items';

  // Save cart items to storage
  void saveCartItems(List<CartItem> cartItems) {
    final List<Map<String, dynamic>> itemsMap = cartItems
        .map((item) => item.toMap())
        .toList();
    _storage.write(_cartKey, itemsMap);
  }

  // Load cart items from storage
  List<CartItem> getCartItems() {
    final items = _storage.read<List>(_cartKey);
    if (items != null) {
      return items
          .map((itemMap) => CartItem.fromMap(itemMap.cast<String, dynamic>()))
          .toList();
    }
    print("ItemLength****: ${items!.length}");
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
}
