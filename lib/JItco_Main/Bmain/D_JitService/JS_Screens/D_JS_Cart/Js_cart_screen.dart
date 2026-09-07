import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/C_Product_Screen.dart/JL_detail_product_screen.dart/JL_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/C_JS_Product/JS_Detail_Product/Js_detail_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/D_JS_Cart/JS_checkout_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_price_calculation_services.dart';
import 'package:velocity_x/velocity_x.dart';

class JsCartScreen extends StatefulWidget {
  const JsCartScreen({super.key});

  @override
  State<JsCartScreen> createState() => _JsCartScreenState();
}

class _JsCartScreenState extends State<JsCartScreen> {
  final JsCartcontroller jsCartController = Get.find<JsCartcontroller>();
  final JlApiService apiService = Get.find<JlApiService>();
  final ApiServices _apiService = Get.find<ApiServices>();
  final JsPriceCalculationServices jlpriceService =
      Get.find<JsPriceCalculationServices>();

  // final Map<String, Map<String, dynamic>> _productDetailsCache = {};
  final RxBool _isLoadingProductDetails = false.obs;

  OutletModel? cityWarehouse;
  String? _warehouseId;

  // DateTime? selectedDateTime;
  @override
  void initState() {
    super.initState();
    _fetchIdFromWarehouse();
  }

  double _calculateItemPrice(JsCartitem item) {
    // if (jsCartController.currentWarehouseId.value.isEmpty) {
    //   return item.originalPrice ?? item.price;
    // }

    // // final productData = _productDetailsCache[item.id];

    // return jlpriceService.calculateItemPrice(
    //       productData: productData,
    //       item: item,
    //     ) ??
    //     (item.originalPrice ?? item.price);
    return item.originalPrice ?? item.price;
  }

  double get _grandTotal {
    double total = 0;
    for (var item in jsCartController.cartItems) {
      total += _calculateItemPrice(item) * item.quantity;
    }
    return total;
  }

  // Get GST percentage for a cart item
  String _getItemGST(JsCartitem item) {
    // If warehouse is not set, use item's GST
    if (jsCartController.currentWarehouseId.value.isEmpty) {
      return item.gstPercentage.toString();
    }

    final productData = jsCartController.productDetailsCache[item.id];

    print("productDataJS: $productData");

    return jlpriceService.getItemGST(
      productData: productData,
      item: item, // Pass the entire CartItem
    );
  }

  double _calculateItemGSTAmount(
    double? calculatedPrice,
    double gstPercentage,
  ) {
    if (calculatedPrice == null) return 0;
    return jlpriceService.calculateGSTAmount(calculatedPrice, gstPercentage);
  }

 double get _calculatedTotalGST {
  double totalGST = 0;

  for (var item in jsCartController.cartItems) {
    final price =
        _calculateItemPrice(item) ?? (item.originalPrice ?? item.price);

    final gstPercentage =
        double.tryParse(_getItemGST(item)) ??
        (item.gstPercentage ?? 0.0);

    totalGST += (price * (gstPercentage / 100)) * item.quantity;
  }

  return totalGST;
}

  double get _calculatedGrandTotal {
    return _grandTotal + _calculatedTotalGST;
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
    // print("jscartScreenproductdetails: $_productDetailsCache");
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Obx(() {
          if (jsCartController.isLoading.value ||
              _isLoadingProductDetails.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return Column(
            children: [
              _header(),
              Expanded(
                child: jsCartController.isCartEmpty
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
                '${jsCartController.totalItems} ${jsCartController.totalItems == 1 ? 'item' : 'items'} in your cart',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Total: "
            '₹${_calculatedGrandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                //   () => JsBottomNavBar(initialIndex: 0),
                //   transition: Transition.fadeIn,
                // );
                Get.find<JsBottomNavController>().switchTab(1);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(item) async {
    // final DateTime? date = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime.now(),
    //   lastDate: DateTime(2100),
    // );
    ///WITH COLOR THEME
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black, // Header + selected date
              onPrimary: Colors.white, // Text on header
              onSurface: Colors.black87, // Body text
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.orange),
            // dialogBackgroundColor: Colors.orange.shade700, // Background
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // final TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now(),
    // );

    // final TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now(),
    //   builder: (context, child) {
    //     return MediaQuery(
    //       data: MediaQuery.of(context).copyWith(
    //         alwaysUse24HourFormat: false, // ✅ FORCE 12h
    //       ),
    //       child: child!,
    //     );
    //   },
    // );
    ///WITH COLOR THEME
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.black, // Dial + header
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.orange,
              ),
              // dialogBackgroundColor: Colors.orange.shade700,
            ),
            child: child!,
          ),
        );
      },
    );

    if (time == null) return;

    // setState(() {
    //   final combined = DateTime(
    //     date.year,
    //     date.month,
    //     date.day,
    //     time.hour,
    //     time.minute,
    //   );

    //   jsCartController.setItemDeliveryDateTime(
    //     item.id,
    //     item.selectedVariant ?? "Default",
    //     combined,
    //   );
    // });

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    jsCartController.setItemDeliveryDateTime(
      item.id,
      item.selectedVariant ?? "Default",
      combined,
    );
  }

  // ================= CART LIST =================
  Widget _cartList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: jsCartController.cartItems.length,
            itemBuilder: (_, index) {
              final item = jsCartController.cartItems[index];
              final dt = item.deliveryDateTime;
              final calculatedGST = _getItemGST(item);
              final calculatedPrice = _calculateItemPrice(item);
              final gstPercentage =
                  double.tryParse(calculatedGST) ?? (item.gstPercentage ?? 0);
              final gstAmount = _calculateItemGSTAmount(
                calculatedPrice,
                gstPercentage ?? 0,
              );
              final price = _calculateItemPrice(item) ?? 0;
              print("item:$item");
              print("dt:$dt");
              print("calculatedGST:$calculatedGST");
              print("calculatedPrice:$calculatedPrice");
              print("gstPercentage:$gstPercentage");
              print("gstAmount:$gstAmount");
              print("price:$price");
              return KeyedSubtree(
                key: ValueKey(item.id),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => JsDetailScreen(
                        id: item.id,
                        warehouseId: _warehouseId,
                        slug: item.categorySlug ?? '',
                      ),
                      transition: Transition.rightToLeft,
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
                                        "Package: ${item.selectedVariant ?? 'Basic'}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    Text(
                                      'GST: ${gstPercentage.toStringAsFixed(1)}% (₹${(gstAmount).toStringAsFixed(2)})/per',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // Base Price (green)
                                    Text(
                                      "Price: ₹${item.price * item.quantity}",
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
                          /// DATE & TIME SELECTION
                          10.heightBox,

                          ///Date and Time
                          const Text("Set Slot (Optional):"),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              // horizontal: 16,
                              vertical: 8,
                            ),
                            child: InkWell(
                              onTap: () => _pickDateTime(item),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        // selectedDateTime == null
                                        //     ? "Select Delivery Date & Time"
                                        //     :
                                        //       //"${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} "
                                        //       "${TimeOfDay.fromDateTime(selectedDateTime!).format(context)}"
                                        //           "${DateFormat('dd/MM/yyyy hh:mm a').format(selectedDateTime!)}",
                                        dt == null
                                            ? "Select Delivery Date & Time"
                                            : DateFormat(
                                                'dd/MM/yyyy  hh:mm a',
                                              ).format(dt),

                                        style: TextStyle(
                                          fontSize: 14,
                                          color: dt == null
                                              ? Colors.grey.shade600
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Item Total
                              Text(
                                "Total: ₹${(gstAmount * item.quantity + price * item.quantity).toStringAsFixed(2)}",
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
                                            jsCartController.updateQuantity(
                                              context,
                                              item.id,
                                              qty,
                                              item.selectedVariant ?? 'Default',
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
                ),
              );
            },
          ),
        ),
        _checkoutButton(),
      ],
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => Get.to(
          () => JsCheckoutScreen(),
          transition: Transition.rightToLeft,
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.orange.shade700,
        ),
        child: const Text(
          'Proceed to Checkout',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  // void _deleteItem(JsCartitem item) {
  //   jsCartController.removeFromCart(item.id);
  //   _productDetailsCache.remove(item.id);
  // }

  void _showDeleteDialog(JsCartitem item) {
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
                jsCartController.removeFromCart(
                  item.id,
                  item.selectedVariant ?? "Default",
                );
                // Remove from cache
                // _productDetailsCache.remove(item.id);
                Navigator.of(context).pop();
                Get.snackbar(
                  'Removed',
                  '${item.name} removed from cart',
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
}
