// screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/widget/delivery_address.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cartitem.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/JL_bottom_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_bottom_Nav_Bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_price_calculation_services.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/payment_webview.dart';
import 'package:velocity_x/velocity_x.dart';

class JsCheckoutScreen extends StatefulWidget {
  const JsCheckoutScreen({super.key});

  @override
  State<JsCheckoutScreen> createState() => _JsCheckoutScreenState();
}

class _JsCheckoutScreenState extends State<JsCheckoutScreen> {
  final JsCartcontroller jsCartController = Get.find<JsCartcontroller>();
  final AuthController authController = Get.find<AuthController>();
  final ApiServices apiService = Get.find<ApiServices>();
  final JsApiService jlApiService = Get.find<JsApiService>();
  final JsPriceCalculationServices priceService =
      Get.find<JsPriceCalculationServices>();
  final TextEditingController notesController = TextEditingController();
  // final TextEditingController menuNameController = TextEditingController();
  final RxBool isDeliveryAddressSelected = false.obs;
  final RxString selectedCityName = ''.obs;
  RxString selectedWarehouseId = ''.obs;
  OutletModel? cityWarehouse;
  final RxBool isLoading = false.obs;
  String? selectedOutletId;
  String? selectedAddressString;

  @override
  void initState() {
    super.initState();

    _clearSavedAddress();

    // Start with cart prices (from cart screen)
    // Don't automatically fetch product details on init
    // Wait until address is selected

    // Store original cart prices if not already stored
    for (var item in jsCartController.cartItems) {
      if (item.originalPrice == null) {
        // Ensure original price is preserved
        final index = jsCartController.cartItems.indexOf(item);
        jsCartController.cartItems[index] = item.copyWith(
          originalPrice: item.price,
        );
      }
    }
  }

  @override
  void dispose() {
    // Clear saved address when user leaves checkout screen
    _clearSavedAddress();
    super.dispose();
  }

  // Method to clear saved address
  void _clearSavedAddress() {
    try {
      final storage = GetStorage();
      storage.remove('selectedDeliveryAddress');

      // Also clear any cart-related warehouse data
      if (jsCartController.currentWarehouseId.value.isNotEmpty) {
        jsCartController.currentWarehouseId.value = '';
      }
    } catch (e) {
      print('Error clearing saved address: $e');
    }
  }

  // Get product GST percentage
  String _getProductGST(Map<String, dynamic> productData) {
    return productData['gstPercentage']?.toString() ?? '0';
  }

  // Calculate price for a cart item using the new logic
  // double? _calculateItemPrice(JsCartitem item) {
  //   final double cartPrice = item.originalPrice ?? item.price;
  //   final productData = jsCartController.productDetailsCache[item.id];
  //   print("***********jkcj***********: $productData");
  //   if (productData == null) {
  //     print('No product data found for item: ${item.name}');
  //     return item.price; // Fallback to existing price
  //   }

  //   return (isDeliveryAddressSelected.value)
  //       ? priceService.resolveProductPrice(
  //               productData: productData,
  //               selectVariantUom: item.selectedVariant,
  //             ) ??
  //             cartPrice
  //       : cartPrice;
  // }

  double _calculateItemPrice(JsCartitem item) {
    /// ALWAYS trust cart price first
    final cartPrice = item.price;

    /// Cache only modifies price IF EXISTS
    final productData = jsCartController.productDetailsCache[item.id];

    if (isDeliveryAddressSelected.value && productData != null) {
      final resolvedPrice = priceService.resolveProductPrice(
        productData: productData,
        selectVariantUom: item.selectedVariant,
      );

      if (resolvedPrice != null && resolvedPrice > 0) {
        return resolvedPrice;
      }
    }

    return cartPrice;
  }

  // Get GST percentage for a cart item
  // String _getItemGST(JsCartitem item) {
  //   final productData = jsCartController.productDetailsCache[item.id];
  //   if (productData == null) {
  //     return item.gstPercentage.toString();
  //   }

  //   return _getProductGST(productData);
  // }

  double _getItemGST(JsCartitem item) {
    final cartGST = item.gstPercentage ?? 0.0;

    final productData = jsCartController.productDetailsCache[item.id];

    if (productData != null && productData['gstPercentage'] != null) {
      return double.tryParse(productData['gstPercentage'].toString()) ??
          cartGST;
    }

    return cartGST;
  }

  // double get _calculatedTotalPrice {
  //   double total = 0;

  //   for (final item in jsCartController.cartItems) {
  //     // Always use the cart controller's cache for consistency
  //     final productData = jsCartController.productDetailsCache[item.id];

  //     // Determine which price to use
  //     double finalPrice;

  //     if (isDeliveryAddressSelected.value && productData != null) {
  //       // Address is selected AND we have product data
  //       final locationPrice = priceService.resolveProductPrice(
  //         productData: productData,
  //         selectVariantUom: item.selectedVariant,
  //       );
  //       finalPrice = locationPrice ?? item.price;
  //     } else {
  //       // No address selected OR no product data - use cart price
  //       finalPrice = item.price;
  //     }

  //     total += finalPrice * item.quantity;
  //   }

  //   return total;
  // }

  double get _calculatedTotalPrice {
    return jsCartController.cartItems.fold(
      0,
      (sum, item) => sum + (_calculateItemPrice(item) * item.quantity),
    );
  }

  // double get _calculatedTotalGST {
  //   double totalGST = 0;

  //   for (final item in jsCartController.cartItems) {
  //     final productData = jsCartController.productDetailsCache[item.id];

  //     // Determine which price to use (same logic as above)
  //     double finalPrice;

  //     if (isDeliveryAddressSelected.value && productData != null) {
  //       final locationPrice = priceService.resolveProductPrice(
  //         productData: productData,
  //         selectVariantUom: item.selectedVariant,
  //       );
  //       finalPrice = locationPrice ?? item.price;
  //     } else {
  //       finalPrice = item.price;
  //     }

  //     // Determine GST percentage
  //     double gstPercentage;

  //     if (productData != null && productData['gstPercentage'] != null) {
  //       gstPercentage =
  //           double.tryParse(productData['gstPercentage'].toString()) ??
  //           item.gstPercentage ??
  //           0.0;
  //     } else {
  //       gstPercentage = item.gstPercentage ?? 0.0;
  //     }

  //     // Calculate GST amount for this item
  //     final gstAmount = finalPrice * (gstPercentage / 100);
  //     totalGST += gstAmount * item.quantity;
  //   }

  //   return totalGST;
  // }

  double get _calculatedTotalGST {
    return jsCartController.cartItems.fold(0, (sum, item) {
      final price = _calculateItemPrice(item);
      final gst = _getItemGST(item);

      final gstAmount = price * (gst / 100);

      return sum + (gstAmount * item.quantity);
    });
  }

  double get _calculatedGrandTotal {
    return _calculatedTotalPrice + _calculatedTotalGST;
  }

  String _formatSlotDate(DateTime? dt) =>
      dt == null ? "No Date" : DateFormat('dd/MM/yyyy').format(dt);

  String _formatSlotTime(DateTime? dt) =>
      dt == null ? "No Time" : DateFormat('hh:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              "Checkout".text.color(Colors.black87).make(),
              if (isDeliveryAddressSelected.value == true)
                Container(
                  margin: EdgeInsets.only(left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Location Pricing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {
        //     Get.back();
        //   },
        // ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Loading product details...',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              _buildProductsOrderSection(),

              20.heightBox,

              // Delivery Address Section
              DeliveryAddressSection(
                selectedValue: (isSelected) {
                  isDeliveryAddressSelected.value = isSelected;
                  if (isSelected) {
                    // Fetch fresh product details when address is selected
                    // _fetchProductDetails();

                    setState(() {});
                  }
                },
                onCitySelected: (cityName) {
                  selectedCityName.value = cityName;
                  if (cityName.isNotEmpty &&
                      jsCartController.cartItems.isNotEmpty) {
                    jsCartController.checkPriceUpdate(cityName);
                    setState(() {});
                  }
                },
                onOutletSelected: (outletId) {
                  selectedOutletId = outletId;
                  setState(() {});
                },
                onAddressStringSelected: (address) {
                  selectedAddressString = address;
                },
              ),

              20.heightBox,

              // Notes Section
              _buildNotesPlusMenunameSection(
                "Notes (Optional)",
                "Add any special instructions or notes for your menu...",
                notesController,
              ),

              20.heightBox,

              // _buildNotesPlusMenunameSection(
              //   "Menu Name (Optional)",
              //   "You can give your Menu name...",
              //   menuNameController,
              // ),

              // 20.heightBox,

              // Payment Method Section
              _buildPaymentMethodSection(),

              20.heightBox,

              // Price Breakdown Section
              _buildPriceBreakdownSection(),

              20.heightBox,
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => jsCartController.cartItems.isEmpty
            ? const SizedBox.shrink()
            : _buildPlaceOrderButton(),
      ),
    );
  }

  double getItemDisplayPrice(JlCartitem item) {
    // Always return the cart price initially
    // This comes from the cart screen where item was added
    final cartPrice = item.originalPrice ?? item.price;

    // Only calculate location-based price if:
    // 1. Delivery address is selected (user has chosen a shipping address)
    // 2. We have product details fetched for the selected warehouse
    // 3. The price calculation service can resolve a price
    if (isDeliveryAddressSelected.value &&
        jsCartController.productDetailsCache.containsKey(item.id)) {
      final productData = jsCartController.productDetailsCache[item.id]!;

      // Try to get location-based price
      final resolvedPrice = priceService.resolveProductPrice(
        productData: productData,
      );

      // If we got a valid price, use it
      if (resolvedPrice != null && resolvedPrice > 0) {
        return resolvedPrice;
      }
    }

    // Otherwise, use the original cart price
    return cartPrice;
  }

  // double getItemDisplayPrice(CartItem item) {
  //   // Always show cart price as default
  //   final cartPrice = item.originalPrice ?? item.price;

  //   // Only calculate location-based price if address is selected
  //   final productData = _productDetailsCache[item.id];
  //   if (productData == null || !isDeliveryAddressSelected.value) {
  //     return cartPrice;
  //   }

  //   // Resolve price from service for selected warehouse/address
  //   final resolvedPrice = priceService.resolveProductPrice(
  //     productData: productData,
  //   );
  //   return resolvedPrice ?? cartPrice;
  // }

  // Update the _buildProductsOrderSection method:
  Widget _buildProductsOrderSection() {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                "Products Ordering".text
                    .size(18)
                    .fontWeight(FontWeight.w400)
                    .make(),
                Spacer(),
                Obx(
                  () => Text(
                    '${jsCartController.totalItems} items',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            16.heightBox,
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jsCartController.cartItems.length,
                itemBuilder: (context, index) {
                  late int selectedUomIndex = jsCartController.selectedUomIndex;
                  print('1: $selectedUomIndex');
                  final item = jsCartController.cartItems[index];
                  final productData =
                      jsCartController.productDetailsCache[item.id];

                  final double cartPrice = item.originalPrice ?? item.price;

                  final test = priceService.resolveProductPrice(
                    productData: productData,
                  );

                  print(
                    'test********************************************: $test',
                  );

                  final double calculatedPrice =
                      (isDeliveryAddressSelected.value)
                      ? priceService.resolveProductPrice(
                              productData: productData,
                              selectVariantUom: item.selectedVariant,
                            ) ??
                            cartPrice
                      : cartPrice;

                  print(
                    'calculatedPrice********************************************: $calculatedPrice',
                  );
                  print(
                    'cartPrice********************************************: $cartPrice',
                  );
                  // final double calculatedPrice = getItemDisplayPrice(item);
                  final calculatedGST = priceService.getItemGST(
                    productData: jsCartController.productDetailsCache[item.id],
                    item: item,
                  );
                  final gstPercentage =
                      double.tryParse(calculatedGST) ?? item.gstPercentage;
                  final gstAmount = priceService.calculateGSTAmount(
                    calculatedPrice,
                    gstPercentage ?? 0.0,
                  );
                  final totalWithGST = calculatedPrice + gstAmount;
                  return Card(
                    color: Colors.grey[100],
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          /// First Row (Image + Name + Price info)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: item.image.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.network(
                                          item.image,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                              ),

                              const SizedBox(width: 12),

                              // Name + price details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${item.uom ?? "1 pc."}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'GST: ${gstPercentage!.toStringAsFixed(1)}% (₹${(gstAmount * item.quantity).toStringAsFixed(2)})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Price: ₹${(calculatedPrice * item.quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (item.deliveryDateTime != null) ...[
                            const SizedBox(height: 4),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date: ${_formatSlotDate(item.deliveryDateTime)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                Text(
                                  'Time: ${_formatSlotTime(item.deliveryDateTime)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 4),

                            Text(
                              'Delivery Slot Not Selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          /// Second Row (Qty + Grand Total)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total: ₹${(totalWithGST * item.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesPlusMenunameSection(
    String? title,
    String? hintText,
    controller,
  ) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              title!.text.size(18).fontWeight(FontWeight.w400).make(),
              12.heightBox,
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade700),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  "Payment Method *".text
                      .size(18)
                      .fontWeight(FontWeight.w400)
                      .make(),
                ],
              ),
              12.heightBox,
              SizedBox(
                height: 24,
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    8.widthBox,
                    Expanded(
                      child: Text(
                        "Pay Now",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            "Order Summary".text.size(18).fontWeight(FontWeight.w400).make(),
            16.heightBox,
            Column(
              children: [
                _buildPriceRow('Items:', '${jsCartController.totalItems}'),
                _buildPriceRow(
                  'Subtotal:',
                  '₹${_calculatedTotalPrice.toStringAsFixed(2)}',
                ),
                _buildPriceRow(
                  'GST:',
                  '₹${_calculatedTotalGST.toStringAsFixed(2)}',
                ),
                Divider(thickness: 1),
                _buildPriceRow(
                  'Total Amount:',
                  '₹${_calculatedGrandTotal.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                if (jsCartController.hasPriceChanges)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Prices based on selected delivery location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.grey : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? Colors.orange.shade700 : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // Safe snackbar method
  void _showSnackbar({
    required String title,
    required String message,
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        duration: duration,
        margin: EdgeInsets.all(10),
        borderRadius: 8,
      );
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }

  Future<void> _submitOrder() async {
    print('=== STARTING ORDER SUBMISSION ===');
    authController.isLoading(true);

    try {
      // Validate outlet selection first
      if (selectedOutletId == null || selectedOutletId!.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a delivery address',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        authController.isLoading(false);
        return;
      }

      // 1. USE CACHED OUTLET DATA
      print('=== USING CACHED OUTLET DATA ===');
      String outletId = selectedOutletId ?? '';
      String billingAddress = selectedAddressString ?? '';
      String shippingAddress = selectedOutletId ?? '';
      
      print('Selected Outlet ID: $outletId');
      print('Billing Address: $billingAddress');

      if (outletId.isEmpty) {
        Get.snackbar(
          'Error',
          'Could not find selected delivery address',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. GET PAYMENT METHOD
      print('=== SETTING PAYMENT METHOD ===');
      String paymentMethod = 'pay_now';
      print('Payment Method: $paymentMethod');

      // 3. GET WAREHOUSE DATA
      print('=== USING CACHED WAREHOUSE DATA ===');
      String warehouseId = jsCartController.currentWarehouseId.value;
      if (warehouseId.isEmpty) warehouseId = authController.warehouseId.value;
      print('Final Warehouse ID: $warehouseId');

      // final hasMissingSlots = jsCartController.cartItems.any(
      //   (item) => item.deliveryDateTime == null,
      // );

      // if (hasMissingSlots) {
      //   Get.snackbar(
      //     'Slot Required',
      //     'Please select delivery slot for all items',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }

      // 4. BUILD ORDER PAYLOAD
      final orderPayload = {
        "customer": authController.userId.value,
        "company": authController.companyId.value,
        "outlet": outletId, //as per selected outlet address(outletId) api[DONE]
        // "warehouseId": warehouseId,
        "warehouseId": warehouseId.isNotEmpty
            ? warehouseId
            : authController.warehouseId.value,

        "paymentMethod": paymentMethod, //[DONE]
        "shippingAddress":
            outletId, //as per selected outlet address(outletId) api[DONE]
        "billingAddress": billingAddress, //as per selected address city[DONE]
        "items": jsCartController.cartItems.map((item) {
          // Use the calculated prices instead of item.xxx
          // final calculatedPrice = _calculateItemPrice(item) ?? item.price;
          // final calculatedGSTPercentage =
          //     double.tryParse(_getItemGST(item)) ?? item.gstPercentage;
          // final priceTotal = calculatedPrice * item.quantity;
          // final gstTotal = priceTotal * (calculatedGSTPercentage! / 100);
          // final totalWithGST = priceTotal + gstTotal;

          final calculatedPrice = _calculateItemPrice(item);
          final calculatedPriceTotal =
              _calculateItemPrice(item) * item.quantity;
          final gstPercentage = _getItemGST(item);
          final gstAmount = priceService.calculateGSTAmount(
            calculatedPrice,
            gstPercentage,
          );
          // final calculatedGST = _getItemGST(item);
          final calculatedGST = gstAmount * item.quantity;

          final totalWithGST = calculatedPrice + gstAmount;
          final totalWithGSTs = totalWithGST * item.quantity;

          return {
            "product": item.id,
            "quantity": item.quantity,
            "price": calculatedPrice, //
            "gst": item.gstPercentage ?? 0.0,
            "priceTotal": calculatedPriceTotal,
            "gstTotal": calculatedGST,
            "total": totalWithGSTs.toStringAsFixed(2),
            // "slot_date": item.deliveryDateTime != null
            //     ? _formatSlotDate(item.deliveryDateTime)
            //     : "",

            // "slot_time": item.deliveryDateTime != null
            //     ? _formatSlotTime(item.deliveryDateTime)
            //     : "",
            "slot_date": _formatSlotDate(item.deliveryDateTime).isNotEmpty
                ? _formatSlotDate(item.deliveryDateTime)
                : "",
            "slot_time": _formatSlotTime(item.deliveryDateTime).isNotEmpty
                ? _formatSlotTime(item.deliveryDateTime)
                : "",
            // "slot_date": DateFormat(
            //   'yyyy-MM-dd',
            // ).format(item.deliveryDateTime!),
            // "slot_time": DateFormat('hh:mm a').format(item.deliveryDateTime!),
          };
        }).toList(),
        "totalAmount": _calculatedTotalPrice.toStringAsFixed(2),
        "gst": _calculatedTotalGST.toStringAsFixed(2),
        "finalAmount": _calculatedGrandTotal.toStringAsFixed(2),
        "discount": 0,
        "paymentStatus": "PENDING",
        "orderStatus": "Processing",
        // "menu": menuNameController.text.trim(),
        "notes": notesController.text.trim(),
      };

      print('FINAL ORDER PAYLOAD → $orderPayload');

      // 5. SUBMIT ORDER
      print('=== SUBMITTING ORDER TO API ===');
      try {
        final result = await jlApiService.jsPostOrder(orderPayload);
        print('=== ORDER API RESPONSE ===');
        print('Success: ${result['success']}');
        print('Message: ${result['message']}');

        if (result['success'] == true) {
          // Check if the response contains a payment URL
          final responseData = result['data'];
          String? paymentUrl;

          // Helper to find URL in a map
          String? findUrl(Map map) {
            final keysToCheck = ['url', 'payment_url', 'paymentUrl', 'paymentLink', 'link'];
            for (var key in keysToCheck) {
              if (map.containsKey(key) && map[key] != null && map[key].toString().isNotEmpty) {
                return map[key].toString();
              }
            }
            return null;
          }

          if (responseData != null && responseData is Map) {
            paymentUrl = findUrl(responseData);
            // Check if nested inside 'data'
            if (paymentUrl == null && responseData.containsKey('data') && responseData['data'] is Map) {
              paymentUrl = findUrl(responseData['data']);
            }
            // Check if nested inside 'order'
            if (paymentUrl == null && responseData.containsKey('order') && responseData['order'] is Map) {
              paymentUrl = findUrl(responseData['order']);
            }
          }

          if (paymentUrl != null && paymentUrl.isNotEmpty) {
            // Payment URL found — open WebView for online payment
            print('PAYMENT URL FOUND: $paymentUrl');
            Get.to(
              () => PaymentWebView(
                paymentUrl: paymentUrl!,
                onPaymentSuccess: () {
                  jsCartController.clearCart();
                  Get.snackbar(
                    'Payment Successful',
                    'Your payment was completed successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                  Get.off(() => OrderConfirmationScreen());
                },
                onPaymentFailure: () {
                  Get.snackbar(
                    'Payment Failed',
                    'Your payment was not completed. Please try again.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: Duration(seconds: 4),
                  );
                },
              ),
            );
          } else {
            // No payment URL — COD / contract order, go to confirmation
            jsCartController.clearCart();
            await Future.delayed(Duration(seconds: 1));
            Get.off(() => OrderConfirmationScreen());
          }
        } else {
          Get.snackbar(
            'Order Failed',
            result['message'] ?? 'Something went wrong',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
          );
        }
      } catch (e) {
        print('=== ORDER SUBMISSION ERROR ===');
        print('Error: $e');
        Get.snackbar(
          'Network Error',
          'Failed to place order. Please check your connection and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('=== GENERAL ERROR ===');
      print('Error: $e');
      Get.snackbar(
        'System Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      authController.isLoading(false);
    }
  }

  // Helper method to format address
  String _formatAddress(OutletModel outlet) {
    final addressParts = [
      outlet.address,
      outlet.cityName,
      outlet.stateName,
      outlet.pinCode != null ? '- ${outlet.pinCode}' : null,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return addressParts.join(', ');
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Obx(() {
            // if (isDeliveryAddressSelected.value == false) {
            //   return ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.grey,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: const Text('Submit'),
            //   );
            // }
            return ElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () async {
                      // Validate delivery address first
                      if (!isDeliveryAddressSelected.value) {
                        // _showSnackbar(
                        //   title: 'Delivery Address Required',
                        //   message:
                        //       'Please select a delivery address to place your order',
                        //   backgroundColor: Colors.red,
                        //   duration: Duration(seconds: 3),
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select a delivery address to place your order',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Validate cart is not empty
                      if (jsCartController.cartItems.isEmpty) {
                        _showSnackbar(
                          title: 'Error',
                          message: 'Your cart is empty',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      final confirmed = await Get.dialog<bool>(
                        AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Confirm Order"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Are you sure you want to place this order?",
                              ),
                              if (jsCartController.hasPriceChanges) ...[
                                8.heightBox,
                                Text(
                                  "Note: Using location-based pricing",
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              if (notesController.text.isNotEmpty) ...[
                                8.heightBox,
                                Text(
                                  "Notes: ${notesController.text}",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submitOrder();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    final navigator = Navigator.of(context);

                                    if (navigator.canPop()) {
                                      navigator.pop();
                                    }
                                  });
                                });
                                // Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                      );

                      // if (confirmed == true) {
                      //   await _submitOrder(); // API will hit here
                      // }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isDeliveryAddressSelected.value
                    ? Colors.grey
                    : Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authController.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),
        ),
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // Get.off(() => JsBottomNavBar());
            Get.find<JsBottomNavController>().switchTab(1);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final navigator = Navigator.of(context);

                if (navigator.canPop()) {
                  navigator.pop();
                }
              });
            });
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              30.heightBox,
              "Order Placed Successfully!".text
                  .size(26)
                  .fontWeight(FontWeight.bold)
                  .make(),
              13.heightBox,
              "Thank you for your purchase. Your order has been confirmed.".text
                  .size(15)
                  .color(Colors.grey[700])
                  .align(TextAlign.center)
                  .make(),
              40.heightBox,
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Get.off(() => JsBottomNavBar());
                    Get.find<JsBottomNavController>().switchTab(1);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final navigator = Navigator.of(context);

                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Continue Shopping"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
