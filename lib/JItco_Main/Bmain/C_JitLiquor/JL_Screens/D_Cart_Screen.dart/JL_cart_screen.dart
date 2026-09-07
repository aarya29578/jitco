import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_checkout_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_cartcontroller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:velocity_x/velocity_x.dart';

class JlCartScreen extends StatefulWidget {
  const JlCartScreen({super.key});

  @override
  State<JlCartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<JlCartScreen> {
  final JlCartcontroller jlCartController = Get.find<JlCartcontroller>();
  final JlApiService apiService = Get.find<JlApiService>();
  final ApiServices _apiService = Get.find<ApiServices>();
  final JlPriceCalculationService jlpriceService =
      Get.find<JlPriceCalculationService>();

  final Map<String, Map<String, dynamic>> _productDetailsCache = {};
  final RxBool _isLoadingProductDetails = false.obs;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  // DateTime? selectedDateTime;
  @override
  void initState() {
    super.initState();
    _fetchIdFromWarehouse();
  }

  double _calculateItemPrice(JlCartitem item) {
    if (jlCartController.currentWarehouseId.value.isEmpty) {
      return item.originalPrice ?? item.price;
    }

    final productData = _productDetailsCache[item.id];

    return jlpriceService.calculateItemPrice(
          productData: productData,
          item: item,
        ) ??
        (item.originalPrice ?? item.price);
  }

  double get _grandTotal {
    double total = 0;
    for (var item in jlCartController.cartItems) {
      total += _calculateItemPrice(item) * item.quantity;
    }
    return total;
  }

  Future<void> _fetchIdFromWarehouse() async {
    try {
      print('START: _fetchIdFromWarehouse() called');

      // 1. Fetch outlets
      print('Fetching user outlets...');
      final outletResponse = await _apiService.getUserOutlet();

      if (outletResponse['success'] == true && outletResponse['data'] is List) {
        final outlets = outletResponse['data'] as List;

        if (outlets.isEmpty) {
          print('No outlets found for user');
          return;
        }

        // 2. Convert first outlet to OutletModel
        print('Creating OutletModel from first outlet...');
        final outlet = OutletModel.fromJson(outlets[0]);

        // 3. Get city name directly from OutletModel
        final cityName = outlet.cityName;
        print('City name from OutletModel: "$cityName"');

        if (cityName == null || cityName.isEmpty) {
          print('City name is null or empty in OutletModel');
          return;
        }

        // 4. Call warehouse API with city name
        print('Calling warehouse API with city: "$cityName"...');
        final result = await _apiService.getWarehouseIdByCity(
          page: 1,
          limit: 1,
          encodedCity: cityName,
        );

        // 5. Process warehouse response - FIXED HERE
        print('Warehouse API response: ${result}');

        if (result['data'] != null) {
          // Check if data is a List or a single object
          if (result['data'] is List) {
            final warehouseList = result['data'] as List;

            if (warehouseList.isNotEmpty) {
              print('Warehouse data found in list!');
              final warehouseData = warehouseList[0];
              final warehouseId = warehouseData['_id'];

              print('Warehouse _id: $warehouseId');

              // Store the warehouse ID
              setState(() {
                _warehouseId = warehouseId;
                cityWarehouse = OutletModel.fromJson(warehouseData);
              });

              print('Warehouse model created with ID: ${cityWarehouse?.id}');
            } else {
              print('No warehouses found for city: $cityName');
            }
          }
          // Handle if data is a single object (not a list)
          else if (result['data'] is Map) {
            print('Warehouse data found as single object!');
            final warehouseData = result['data'] as Map<String, dynamic>;
            final warehouseId = warehouseData['_id'];

            print('Warehouse _id: $warehouseId');

            // Store the warehouse ID
            setState(() {
              _warehouseId = warehouseId;
              cityWarehouse = OutletModel.fromJson(warehouseData);
            });

            print('Warehouse model created with ID: ${cityWarehouse?.id}');
          } else {
            print(
              'Invalid warehouse data format: ${result['data'].runtimeType}',
            );
          }
        } else {
          print('No data in warehouse response');
        }
      } else {
        print('Failed to fetch outlets: ${outletResponse['message']}');
      }
    } catch (e) {
      print('Error in _fetchIdFromWarehouse: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      print('END: _fetchIdFromWarehouse() completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Obx(() {
          if (jlCartController.isLoading.value ||
              _isLoadingProductDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return Column(
            children: [
              _header(),
              Expanded(
                child: jlCartController.isCartEmpty
                    ? _emptyCart()
                    : _cartList(),
              ),
              // _checkoutButton(),
            ],
          );
        }),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Shopping Cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${jlCartController.totalItems} ${jlCartController.totalItems == 1 ? 'item' : 'items'} in your cart',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Total: "
            '₹${_grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY CART =================
  Widget _emptyCart() {
    return Center(
      child: Container(
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Colors.grey[700],
            ),
            7.heightBox,
            Text(
              'Your cart is empty',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            3.heightBox,
            Text(
              'Start adding some items to your cart',
              style: TextStyle(color: Colors.black38),
            ),
            20.heightBox,
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Get.offAll(
                //   () => JlBottomNavBar(initialIndex: 0),
                //   transition: Transition.fadeIn,
                // );
                Get.find<JlBottomNavController>().switchTab(1);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CART LIST =================
  Widget _cartList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: jlCartController.cartItems.length,
            itemBuilder: (_, index) {
              final item = jlCartController.cartItems[index];
              final price = _calculateItemPrice(item);
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => JlDetailScreen(
                      id: item.id,
                      warehouseId: _warehouseId,
                      slug: item.categorySlug!,
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2, // slightly more elevation like in screenshot
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main row: Image + Details + Delete
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      height: 90,
                                      width: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 90,
                                              width: 90,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      height: 90,
                                      width: 90,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // Name, GST, Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name
                                  Text(
                                    item.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      "Package: ${item.uom ?? 'Basic'}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  // GST line
                                  // Text(
                                  //   "GST: 5.0% (₹${(item.price * 0.05).toStringAsFixed(2)})",
                                  //   style: TextStyle(
                                  //     fontSize: 13,
                                  //     color: Colors.grey.shade700,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 2),

                                  // Base Price (green)
                                  Text(
                                    "Price: ₹${item.price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // UOM
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8,
                                  //     vertical: 4,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.grey.shade100,
                                  //     borderRadius: BorderRadius.circular(6),
                                  //     border: Border.all(color: Colors.grey.shade300),
                                  //   ),
                                  //   child: Text(
                                  //     "UOM: ${item.uom ?? 'Basic'}",
                                  //     style: const TextStyle(
                                  //       fontSize: 12,
                                  //       color: Colors.black87,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                            // Delete Icon
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 26,
                              ),
                              onPressed: () => _showDeleteDialog(item),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),

                        // const SizedBox(height: 20),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 8,
                        //     vertical: 4,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey.shade100,
                        //     borderRadius: BorderRadius.circular(6),
                        //     border: Border.all(color: Colors.grey.shade300),
                        //   ),
                        //   child: Text(
                        //     "Package: ${item.uom ?? 'Basic'}",
                        //     style: const TextStyle(
                        //       fontSize: 12,
                        //       color: Colors.black87,
                        //     ),
                        //   ),
                        // ),
                        // // Bottom row: Item Total + Quantity
                        const SizedBox(height: 13),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Item Total
                            Text(
                              "Total: ₹${(price * item.quantity).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),

                            // Quantity
                            Row(
                              children: [
                                const Text(
                                  "Qty: ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: TextFormField(
                                      initialValue: item.quantity.toString(),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 15),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                      onChanged: (val) {
                                        final qty = int.tryParse(val) ?? 1;
                                        if (qty > 0) {
                                          jlCartController.updateQuantity(
                                            context,
                                            item.id,
                                            qty,
                                            item.selectedVariant ?? 'Basic',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _checkoutButton(),
      ],
    );
  }

  void _showDeleteDialog(JlCartitem item) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Remove Item'),
          content: Text(
            'Are you sure you want to remove ${item.name} from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                jlCartController.removeFromCart(
                  item.id,
                  item.selectedVariant ?? 'Basic',
                );
                // Remove from cache
                _productDetailsCache.remove(item.id);
                Navigator.of(context).pop();
                Get.snackbar(
                  'Removed',
                  '${item.name} (${item.selectedVariant})  removed from cart',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 80,
      width: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }

  // ================= CHECKOUT =================
  Widget _checkoutButton() {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Get.to(() => JlCheckoutScreen()),

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
          child: const Text(
            'Proceed to Checkout',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // void _deleteItem(JlCartitem item) {
  //   jlCartController.removeFromCart(item.id);
  //   _productDetailsCache.remove(item.id);
  // }
}

// ================= PRICE SERVICE =================
class JlPriceCalculationService extends GetxService {
  double? calculateProductPrice({
    required Map<String, dynamic> productData,
    String? variantType,
    String? selectedVariant,
  }) {
    final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
    final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (productData['universalPrice'] ?? 0)
        .toDouble();
    final int quantityPerBox = productData['quantityPerBox'] ?? 1;
    final bool hasContract = productData['hasContract'] == true;

    if (variantType == 'pack') {
      if (hasContract && contractPrice > 0) {
        return contractPrice * quantityPerBox;
      }
      if (boxPrice > 0) return boxPrice;
      return universalPrice * quantityPerBox;
    } else {
      if (hasContract && contractPrice > 0) return contractPrice;
      return universalPrice;
    }
  }

  double? calculateItemPrice({
    required Map<String, dynamic>? productData,
    required JlCartitem item,
  }) {
    if (productData == null) return item.originalPrice ?? item.price;

    return calculateProductPrice(
          productData: productData,
          variantType: item.variantType,
          selectedVariant: item.selectedVariant,
        ) ??
        item.originalPrice ??
        item.price;
  }
}
