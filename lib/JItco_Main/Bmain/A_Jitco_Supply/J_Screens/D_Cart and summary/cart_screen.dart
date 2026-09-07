import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/checkout_Screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/cart_storage_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/price_calculation_service.dart';
import 'package:velocity_x/velocity_x.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find<CartController>();
  final AuthController authController = Get.find<AuthController>();
  final ApiServices apiService = Get.find<ApiServices>();
  final PriceCalculationService priceService =
      Get.find<PriceCalculationService>();
  // final CartStorageService _cartStorageService = Get.find<CartStorageService>();
  bool _isReturningFromCheckout = false;

  // Store fetched product details
  final Map<String, Map<String, dynamic>> _productDetailsCache = {};
  final RxBool _isLoadingProductDetails = false.obs;

  @override
  void initState() {
    super.initState();
    // _cartStorageService.totalNumberOfProducts;
    // Listen for navigation changes using GetX navigation observer pattern
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReturnFromCheckout();
    });

    // Load product details if warehouse is already set
    if (cartController.currentWarehouseId.value.isNotEmpty) {
      _loadProductDetailsForCurrentWarehouse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check when screen becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkReturnFromCheckout();
    });
  }

  void _checkReturnFromCheckout() {
    // Check navigation history
    if (Get.previousRoute == '/checkout' && Get.currentRoute == '/cart') {
      if (!_isReturningFromCheckout) {
        _isReturningFromCheckout = true;
        _restorePricesOnReturn();
      }
    } else {
      _isReturningFromCheckout = false;
    }
  }

  void _restorePricesOnReturn() {
    // Small delay to ensure screen is built
    Future.delayed(Duration(milliseconds: 500), () {
      if (cartController.hasPriceChanges) {
        cartController.restoreOriginalPrices();
        // Clear cached product details when restoring prices
        _productDetailsCache.clear();
        Get.snackbar(
          'Prices Restored',
          'Cart prices have been restored to original',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    });
  }

  // Load product details for current warehouse
  Future<void> _loadProductDetailsForCurrentWarehouse() async {
    if (cartController.currentWarehouseId.value.isEmpty ||
        cartController.cartItems.isEmpty) {
      print("ItemLength****: ${cartController.cartItems.length}");
      return;
    }

    _isLoadingProductDetails(true);

    try {
      for (var item in cartController.cartItems) {
        if (item.categorySlug != null &&
            !_productDetailsCache.containsKey(item.id)) {
          try {
            final productDetails = await apiService.detailedProducts(
              productSlug: item.categorySlug!,
              warehouseId: cartController.currentWarehouseId.value,
              userId: authController.userId.value,
            );

            if (productDetails is Map && productDetails.isNotEmpty) {
              _productDetailsCache[item.id] = productDetails;
            }
          } catch (e) {
            print('Error fetching product details for ${item.name}: $e');
          }
        }
      }
    } finally {
      _isLoadingProductDetails(false);
    }
  }

  // int get totalNumberOfProducts {
  //   int total = 0;
  //   for (var item in cartController.cartItems) {
  //     total += item.quantity;
  //   }
  //   print("Total>>>>>: $total");
  //   return total;
  // }

  // Calculate all totals using new logic(summary)
  double get _calculatedTotalPrice {
    double total = 0;
    for (var item in cartController.cartItems) {
      final price =
          _calculateItemPrice(item) ?? (item.originalPrice ?? item.price);
      total += price * item.quantity;
    }
    return total;
  }

  double get _calculatedTotalGST {
    double totalGST = 0;
    for (var item in cartController.cartItems) {
      final price =
          _calculateItemPrice(item) ?? (item.originalPrice ?? item.price);
      final gstPercentage =
          double.tryParse(_getItemGST(item)) ?? item.gstPercentage;
      totalGST += (price * (gstPercentage / 100)) * item.quantity;
    }
    return totalGST;
  }

  double get _calculatedGrandTotal {
    return _calculatedTotalPrice + _calculatedTotalGST;
  }

  /////using
  // double? _calculateItemPrice(CartItem item) {
  //   // If warehouse not set OR product data missing
  //   if (cartController.currentWarehouseId.value.isEmpty ||
  //       !_productDetailsCache.containsKey(item.id)) {
  //     return item.originalPrice ?? item.price;
  //   }

  //   final productData = _productDetailsCache[item.id]!;

  //   final int quantityPerBox = productData['quantityPerBox'] ?? 1;
  //   final bool soldAsBox = productData['soldAsBox'] == true;

  //   final double unitPrice =
  //       double.tryParse(productData['unitPrice']?.toString() ?? '') ??
  //       item.originalPrice ??
  //       item.price;

  //   final double boxPrice =
  //       double.tryParse(productData['boxPrice']?.toString() ?? '') ??
  //       (unitPrice * quantityPerBox);

  //   final bool isPackSelected =
  //       item.selectedVariant?.toLowerCase().contains('pack') == true;

  //   if (soldAsBox && boxPrice > 0) return boxPrice;
  //   if (isPackSelected && boxPrice > 0) return boxPrice;

  //   return unitPrice;
  // }
  double _calculateItemPrice(CartItem item) {
    // final productData = _productDetailsCache[item.id];
    // final quantityPerBox =
    //     productData?['quantityPerBox'] ?? 0; //${productData?['quantityPerBox']}
    // // ALWAYS return original price in cart screen
    // if (cartController.selectedUomIndex == 0) {
    //   return item.originalPrice ?? item.price;
    // } else {
    //   item.originalPrice ?? item.price * quantityPerBox;
    // }
    return item.originalPrice ?? item.price;
  }

  ///Using
  // Get GST percentage for a cart item
  String _getItemGST(CartItem item) {
    // If warehouse is not set, use item's GST
    if (cartController.currentWarehouseId.value.isEmpty) {
      return item.gstPercentage.toString();
    }

    final productData = cartController.productDetailsCache[item.id];

    return priceService.getItemGST(
      productData: productData,
      item: item, // Pass the entire CartItem
    );
  }

  ///using
  // Calculate GST amount for a cart item
  // double _calculateItemGSTAmount(CartItem item) {
  //   final productData = cartController.productDetailsCache[item.id];

  //   return priceService.calculateItemGSTAmount(
  //     productData: productData,
  //     item: item, // Pass the entire CartItem
  //   );
  // }
  double _calculateItemGSTAmount(
    double? calculatedPrice,
    double gstPercentage,
  ) {
    return priceService.calculateGSTAmount(calculatedPrice!, gstPercentage);
    ;
  }

  ///using
  // Calculate total price including GST for a cart item
  // double _calculateItemTotalWithGST(CartItem item) {
  //   final productData = cartController.productDetailsCache[item.id];

  //   return priceService.calculateItemTotalWithGST(
  //     productData: productData,
  //     item: item, // Pass the entire CartItem
  //   );
  // }
  // double _calculateItemTotalWithGST(CartItem item) {
  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Obx(() {
          // Show loading indicator while cart is loading from storage
          if (cartController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Loading your cart...',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Show loading indicator while fetching product details
          if (_isLoadingProductDetails.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Updating prices...',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with price update indicator
              _buildHeader(),
              // Cart Content
              Expanded(
                child: cartController.isCartEmpty
                    ? _beforeCartItem()
                    : _afterCartItem(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final hasChanges = cartController.hasPriceChanges;
      final warehouseId = cartController.currentWarehouseId;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 25),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Shopping Cart',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cartController.totalItems} ${cartController.totalItems == 1 ? 'item' : 'items'} in your cart',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ₹${_calculatedGrandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // if (hasChanges)
                    //   Text(
                    //     'Location-based pricing',
                    //     style: TextStyle(
                    //       color: Colors.orange.shade700,
                    //       fontSize: 10,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          ),
          // if (hasChanges && warehouseId.value.isNotEmpty)
          //   Container(
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //     color: Colors.orange.shade50,
          //     child: Row(
          //       children: [
          //         Icon(
          //           Icons.location_on,
          //           size: 16,
          //           color: Colors.orange.shade700,
          //         ),
          //         SizedBox(width: 8),
          //         Expanded(
          //           child: Text(
          //             'Prices are based on selected delivery location',
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.orange.shade800,
          //             ),
          //           ),
          //         ),
          //         IconButton(
          //           onPressed: () {
          //             cartController.restoreOriginalPrices();
          //             _productDetailsCache.clear();
          //           },
          //           icon: Icon(
          //             Icons.restore,
          //             size: 16,
          //             color: Colors.orange.shade700,
          //           ),
          //           padding: EdgeInsets.zero,
          //           constraints: BoxConstraints(),
          //           tooltip: 'Restore original prices',
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      );
    });
  }

  Widget _beforeCartItem() {
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
                //   () => JitcoSupplyNavBar(initialIndex: 0),
                //   transition: Transition.fadeIn,
                // );
                Get.find<BottomNavController>().switchTab(1);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _afterCartItem() {
    return Padding(
      padding: const EdgeInsets.only(right: 7, left: 7, top: 10),
      child: Column(
        children: [
          // Cart Items List
          Expanded(child: _buildCartItemsList()),
          // Order Summary
          // _buildOrderSummary(),
          // Checkout Button
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: TextStyle(color: Colors.grey[700])),
                Text(
                  '₹${_calculatedTotalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('GST:', style: TextStyle(color: Colors.grey[700])),
                Text(
                  '₹${_calculatedTotalGST.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₹${_calculatedGrandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            if (cartController.hasPriceChanges)
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
      ),
    );
  }

  Widget _buildCartItemsList() {
    return Obx(
      () => Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return _buildCartItemNew(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCartItemNew(CartItem item) {
  //   final calculatedPrice =
  //       _calculateItemPrice(item) ?? (item.originalPrice ?? item.price);
  //   final calculatedGST = _getItemGST(item);
  //   final gstPercentage = double.tryParse(calculatedGST) ?? item.gstPercentage;
  //   final gstAmount = calculatedPrice * (gstPercentage / 100);
  //   final totalWithGST = calculatedPrice + gstAmount;
  //   final hasPriceChanged =
  //       item.originalPrice != null && calculatedPrice != item.originalPrice;
  //   final priceChangePercent = hasPriceChanged
  //       ? ((calculatedPrice - item.originalPrice!) / item.originalPrice! * 100)
  //       : 0.0;
  //   return Card(
  //     elevation: 1,
  //     color: Colors.white,
  //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
  //     child: Padding(
  //       padding: EdgeInsets.all(12),
  //       child: Column(
  //         children: [
  //           // First Row: Image, Name, Delete Button
  //           Row(
  //             children: [
  //               // Image
  //               Container(
  //                 width: 80,
  //                 height: 80,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   color: Colors.grey[200],
  //                 ),
  //                 child: item.image.isNotEmpty
  //                     ? Container(
  //                         padding: const EdgeInsets.all(3),
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[100],
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         child: Image.network(
  //                           item.image,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Icon(
  //                               Icons.image_not_supported,
  //                               color: Colors.grey,
  //                             );
  //                           },
  //                         ),
  //                       )
  //                     : Icon(Icons.image_not_supported, color: Colors.grey),
  //               ),
  //               SizedBox(width: 10),
  //               // Product name and prices
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     AutoSizeText(
  //                       item.name,
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     SizedBox(height: 4),
  //                     // Show original price if it's different
  //                     if (hasPriceChanged && item.originalPrice != null)
  //                       Row(
  //                         children: [
  //                           Text(
  //                             'Original: ',
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: Colors.grey[600],
  //                             ),
  //                           ),
  //                           Text(
  //                             '₹${item.originalPrice!.toStringAsFixed(2)}',
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: Colors.grey[600],
  //                               decoration: TextDecoration.lineThrough,
  //                             ),
  //                           ),
  //                           SizedBox(width: 8),
  //                           Container(
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: 4,
  //                               vertical: 1,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: priceChangePercent > 0
  //                                   ? Colors.red.shade100
  //                                   : Colors.green.shade100,
  //                               borderRadius: BorderRadius.circular(3),
  //                             ),
  //                             child: Text(
  //                               '${priceChangePercent > 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%',
  //                               style: TextStyle(
  //                                 fontSize: 9,
  //                                 color: priceChangePercent > 0
  //                                     ? Colors.red.shade800
  //                                     : Colors.green.shade800,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     // Current price
  //                     // Text(
  //                     //   'Price: ₹${calculatedPrice.toStringAsFixed(2)}',
  //                     //   style: TextStyle(
  //                     //     fontSize: 12,
  //                     //     color: hasPriceChanged
  //                     //         ? (priceChangePercent > 0
  //                     //               ? Colors.red.shade700
  //                     //               : Colors.green.shade700)
  //                     //         : Colors.grey[600],
  //                     //     fontWeight: hasPriceChanged
  //                     //         ? FontWeight.bold
  //                     //         : FontWeight.normal,
  //                     //   ),
  //                     // ),
  //                     // SizedBox(height: 2),
  //                     Text(
  //                       'GST: ${gstPercentage.toStringAsFixed(1)}% (₹${gstAmount.toStringAsFixed(2)})',
  //                       style: TextStyle(color: Colors.grey[600], fontSize: 11),
  //                     ),
  //                     SizedBox(height: 2),
  //                     Text(
  //                       'Price: ₹${(calculatedPrice * item.quantity).toStringAsFixed(2)}',
  //                       style: TextStyle(
  //                         color: Colors.green.shade700,
  //                         fontSize: 13,
  //                       ),
  //                     ),
  //                     // if (item.warehouseId != null &&
  //                     //     item.warehouseId!.isNotEmpty)
  //                     //   Container(
  //                     //     margin: EdgeInsets.only(top: 2),
  //                     //     child: Text(
  //                     //       'Warehouse: ${item.warehouseId!.substring(0, 8)}...',
  //                     //       style: TextStyle(
  //                     //         fontSize: 10,
  //                     //         color: Colors.blue.shade600,
  //                     //       ),
  //                     //     ),
  //                     //   ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(width: 10),
  //               // Delete btn
  //               IconButton(
  //                 onPressed: () => _showDeleteDialog(item),
  //                 icon: Icon(Icons.delete_outline, color: Colors.red),
  //                 padding: EdgeInsets.zero,
  //                 constraints: BoxConstraints(),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 10),
  //           Row(children: [Text('Select UOM:')]),
  //           SizedBox(height: 10),

  //           // Second Row: Quantity controls
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Total: ₹${(totalWithGST * item.quantity).toStringAsFixed(2)}',
  //                     style: TextStyle(
  //                       color: Colors.green.shade700,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               // Quantity section
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Qty: ',
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   SizedBox(width: 5),
  //                   Container(
  //                     width: 50,
  //                     height: 27,
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.grey),
  //                       borderRadius: BorderRadius.circular(5),
  //                     ),
  //                     child: TextFormField(
  //                       cursorColor: Colors.orange.shade700,
  //                       initialValue: item.quantity.toString(),
  //                       keyboardType: TextInputType.number,
  //                       textAlign: TextAlign.center,
  //                       decoration: InputDecoration(
  //                         border: InputBorder.none,
  //                         contentPadding: EdgeInsets.symmetric(horizontal: 8),
  //                         isDense: true,
  //                       ),
  //                       style: TextStyle(fontSize: 15, color: Colors.black),
  //                       onChanged: (value) {
  //                         if (value.isNotEmpty) {
  //                           int newQty = int.tryParse(value) ?? 1;
  //                           if (newQty > 0) {
  //                             cartController.updateQuantity(item.id, newQty);
  //                           } else if (newQty == 0) {
  //                             _showDeleteDialog(item);
  //                           }
  //                         } else {
  //                           // Handle empty input - set to default quantity
  //                           cartController.updateQuantity(item.id, 1);
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  // ).onTap(() {
  //   final productSlug = item.categorySlug ?? '';
  //   print("Product tapped - Slug: $productSlug, ID: ${item.id}");

  //   if (productSlug.isNotEmpty) {
  //     Get.to(() => DetailProductScreen(productSlug: productSlug));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Product details not available'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // });
  // }

  Widget _buildCartItemNew(CartItem item) {
    // Use PriceCalculationService for calculations
    // Use the service methods that pass the entire CartItem
    final calculatedPrice = _calculateItemPrice(item);
    final calculatedGST = _getItemGST(item);
    final gstPercentage = double.tryParse(calculatedGST) ?? item.gstPercentage;
    final gstAmount = _calculateItemGSTAmount(calculatedPrice, gstPercentage);
    final totalWithGST =
        _calculateItemPrice(item) +
        _calculateItemGSTAmount(calculatedPrice, gstPercentage);

    final hasPriceChanged =
        item.originalPrice != null && calculatedPrice != item.originalPrice;
    final priceChangePercent = hasPriceChanged
        ? ((calculatedPrice - item.originalPrice!) / item.originalPrice! * 100)
        : 0.0;

    // Get product data from cache to check UOM options
    final productData = _productDetailsCache[item.id];
    final quantityPerBox =
        productData?['quantityPerBox'] ?? 0; //${productData?['quantityPerBox']}
    final uom = productData?['uom'] ?? 'item';
    final soldAsBox = productData?['soldAsBox'] == true;

    // Check if UOM options should be shown
    final showUomOptions = quantityPerBox > 0;

    // Determine current UOM from selectedVariant
    String currentUom = ''.obs(); // default
    if (item.selectedVariant != null) {
      if (item.selectedVariant!.toLowerCase().contains('pack') ||
          item.selectedVariant == 'Full pack') {
        currentUom = 'pack';
      } else {
        currentUom = 'piece';
      }
    }

    return Card(
      elevation: 1,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // First Row: Image, Name, Delete Button
            Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: item.image.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.network(
                            item.image,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.image_not_supported, color: Colors.grey),
                ),
                SizedBox(width: 10),
                // Product name and prices
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Show original price if it's different (optional)
                      // if (hasPriceChanged && item.originalPrice != null)
                      //   Row(
                      //     children: [
                      //       Text(
                      //         'Original: ',
                      //         style: TextStyle(
                      //           fontSize: 11,
                      //           color: Colors.grey[600],
                      //         ),
                      //       ),
                      //       Text(
                      //         '₹${item.originalPrice!.toStringAsFixed(2)}',
                      //         style: TextStyle(
                      //           fontSize: 11,
                      //           color: Colors.grey[600],
                      //           decoration: TextDecoration.lineThrough,
                      //         ),
                      //       ),
                      //       SizedBox(width: 8),
                      //       Container(
                      //         padding: EdgeInsets.symmetric(
                      //           horizontal: 4,
                      //           vertical: 1,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: priceChangePercent > 0
                      //               ? Colors.red.shade100
                      //               : Colors.green.shade100,
                      //           borderRadius: BorderRadius.circular(3),
                      //         ),
                      //         child: Text(
                      //           '${priceChangePercent > 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%',
                      //           style: TextStyle(
                      //             fontSize: 9,
                      //             color: priceChangePercent > 0
                      //                 ? Colors.red.shade800
                      //                 : Colors.green.shade800,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      Text(
                        'GST: ${gstPercentage.toStringAsFixed(1)}% (₹${(gstAmount).toStringAsFixed(2)})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Price: ₹${(calculatedPrice * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                // Delete btn
                IconButton(
                  onPressed: () => _showDeleteDialog(item),
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 10),

            // UOM Selection Row - Always show dropdown if quantityPerBox > 0
            // if (quantityPerBox > 0)
            //   Container(
            //     margin: EdgeInsets.symmetric(vertical: 8),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Unit of Measure:',
            //           style: TextStyle(
            //             fontSize: 13,
            //             fontWeight: FontWeight.w600,
            //             color: Colors.grey[800],
            //           ),
            //         ),
            //         SizedBox(height: 6),
            //         Container(
            //           height: 40,
            //           padding: EdgeInsets.symmetric(horizontal: 12),
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.grey[400]!, width: 1),
            //             borderRadius: BorderRadius.circular(8),
            //             color: Colors.white,
            //           ),
            //           child: DropdownButton<String>(
            //             isExpanded: true,
            //             value: currentUom,
            //             icon: Icon(
            //               Icons.arrow_drop_down,
            //               color: Colors.grey[700],
            //             ),
            //             iconSize: 24,
            //             elevation: 2,
            //             style: TextStyle(fontSize: 14, color: Colors.black),
            //             underline: Container(height: 0),
            //             onChanged: (String? newValue) {
            //               if (newValue != null) {
            //                 // _updateItemUOM(item, newValue);
            //               }
            //             },
            //             items: <String>['piece', 'pack']
            //                 .map<DropdownMenuItem<String>>((String value) {
            //                   return DropdownMenuItem<String>(
            //                     value: value,
            //                     child: Text(
            //                       value == 'piece'
            //                           ? 'Single piece (1 pc.)'
            //                           : 'Full pack ($quantityPerBox ${uom.toLowerCase()})',
            //                       style: TextStyle(fontSize: 14),
            //                     ),
            //                   );
            //                 })
            //                 .toList(),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),

            // For soldAsBox products or when no UOM options, show a static display
            // if (showUomOptions)
            Row(
              children: [
                Text(
                  'UOM:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cartController.selectedUomIndex == 1
                        // soldAsBox
                        ? 'Full pack... ($quantityPerBox ${uom.toLowerCase()})'
                        : (item.selectedVariant ?? '1 pc.'),
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Second Row: Quantity controls and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: ₹${(totalWithGST * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentUom == 'pack' && quantityPerBox > 0)
                      Text(
                        '($quantityPerBox ${uom.toLowerCase()} per pack)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
                // Quantity section
                Row(
                  children: [
                    Text(
                      'Qty: ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      width: 50,
                      height: 27,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextFormField(
                        cursorColor: Colors.orange.shade700,
                        initialValue: item.quantity.toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            int newQty = int.tryParse(value) ?? 1;
                            if (newQty > 0) {
                              cartController.updateQuantity(
                                context,
                                item.id,
                                newQty,
                              );
                            } else if (newQty == 0) {
                              _showDeleteDialog(item);
                            }
                          } else {
                            // Handle empty input - set to default quantity
                            cartController.updateQuantity(context, item.id, 1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).onTap(() {
      final productSlug = item.categorySlug ?? '';
      print("Product tapped - Slug: $productSlug, ID: ${item.id}");

      if (productSlug.isNotEmpty) {
        Get.to(() => DetailProductScreen(productSlug: productSlug));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product details not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // Widget _buildCartItemNew(CartItem item) {
  //   final calculatedPrice =
  //       _calculateItemPrice(item) ?? (item.originalPrice ?? item.price);
  //   final calculatedGST = _getItemGST(item);
  //   final gstPercentage = double.tryParse(calculatedGST) ?? item.gstPercentage;
  //   final gstAmount = calculatedPrice * (gstPercentage / 100);
  //   final totalWithGST = calculatedPrice + gstAmount;

  //   final hasPriceChanged =
  //       item.originalPrice != null && calculatedPrice != item.originalPrice;
  //   final priceChangePercent = hasPriceChanged
  //       ? ((calculatedPrice - item.originalPrice!) / item.originalPrice! * 100)
  //       : 0.0;

  //   // Get product data from cache to check UOM options
  //   final productData = _productDetailsCache[item.id];
  //   final quantityPerBox = productData?['quantityPerBox'] ?? 0;
  //   final uom = productData?['uom'] ?? 'item';
  //   final soldAsBox = productData?['soldAsBox'] == true;

  //   // Check if UOM options should be shown
  //   final showUomOptions = quantityPerBox > 0;

  //   // Determine current UOM from selectedVariant
  //   String currentUom = 'piece'; // default
  //   if (item.selectedVariant != null) {
  //     if (item.selectedVariant!.toLowerCase().contains('pack') ||
  //         item.selectedVariant == 'Full pack') {
  //       currentUom = 'pack';
  //     } else {
  //       currentUom = 'piece';
  //     }
  //   }

  //   return Card(
  //     elevation: 1,
  //     color: Colors.white,
  //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
  //     child: Padding(
  //       padding: EdgeInsets.all(12),
  //       child: Column(
  //         children: [
  //           // First Row: Image, Name, Delete Button (keep existing)
  //           Row(
  //             children: [
  //               // Image
  //               Container(
  //                 width: 80,
  //                 height: 80,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   color: Colors.grey[200],
  //                 ),
  //                 child: item.image.isNotEmpty
  //                     ? Container(
  //                         padding: const EdgeInsets.all(3),
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[100],
  //                           borderRadius: BorderRadius.circular(20),
  //                         ),
  //                         child: Image.network(
  //                           item.image,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             return Icon(
  //                               Icons.image_not_supported,
  //                               color: Colors.grey,
  //                             );
  //                           },
  //                         ),
  //                       )
  //                     : Icon(Icons.image_not_supported, color: Colors.grey),
  //               ),
  //               SizedBox(width: 10),
  //               // Product name and prices
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     AutoSizeText(
  //                       item.name,
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     SizedBox(height: 4),
  //                     // Show original price if it's different
  //                     // if (hasPriceChanged && item.originalPrice != null)
  //                     //   Row(
  //                     //     children: [
  //                     //       Text(
  //                     //         'Original: ',
  //                     //         style: TextStyle(
  //                     //           fontSize: 11,
  //                     //           color: Colors.grey[600],
  //                     //         ),
  //                     //       ),
  //                     //       Text(
  //                     //         '₹${item.originalPrice!.toStringAsFixed(2)}',
  //                     //         style: TextStyle(
  //                     //           fontSize: 11,
  //                     //           color: Colors.grey[600],
  //                     //           decoration: TextDecoration.lineThrough,
  //                     //         ),
  //                     //       ),
  //                     //       SizedBox(width: 8),
  //                     //       Container(
  //                     //         padding: EdgeInsets.symmetric(
  //                     //           horizontal: 4,
  //                     //           vertical: 1,
  //                     //         ),
  //                     //         decoration: BoxDecoration(
  //                     //           color: priceChangePercent > 0
  //                     //               ? Colors.red.shade100
  //                     //               : Colors.green.shade100,
  //                     //           borderRadius: BorderRadius.circular(3),
  //                     //         ),
  //                     //         child: Text(
  //                     //           '${priceChangePercent > 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(1)}%',
  //                     //           style: TextStyle(
  //                     //             fontSize: 9,
  //                     //             color: priceChangePercent > 0
  //                     //                 ? Colors.red.shade800
  //                     //                 : Colors.green.shade800,
  //                     //             fontWeight: FontWeight.bold,
  //                     //           ),
  //                     //         ),
  //                     //       ),
  //                     //     ],
  //                     //   ),
  //                     // Current price
  //                     Text(
  //                       'GST: ${gstPercentage.toStringAsFixed(1)}% (₹${gstAmount.toStringAsFixed(2)})',
  //                       style: TextStyle(color: Colors.grey[600], fontSize: 11),
  //                     ),
  //                     SizedBox(height: 2),
  //                     Text(
  //                       'Price: ₹${(calculatedPrice * item.quantity).toStringAsFixed(2)}',
  //                       style: TextStyle(
  //                         color: Colors.green.shade700,
  //                         fontSize: 13,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(width: 10),
  //               // Delete btn
  //               IconButton(
  //                 onPressed: () => _showDeleteDialog(item),
  //                 icon: Icon(Icons.delete_outline, color: Colors.red),
  //                 padding: EdgeInsets.zero,
  //                 constraints: BoxConstraints(),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 10),

  //           // UOM Selection Row - Only show dropdown if options exist
  //           // if (showUomOptions)
  //           //   Row(
  //           //     children: [
  //           //       Text(
  //           //         'Select UOM:',
  //           //         style: TextStyle(
  //           //           fontSize: 13,
  //           //           fontWeight: FontWeight.w500,
  //           //           color: Colors.grey[700],
  //           //         ),
  //           //       ),
  //           //       SizedBox(width: 10),
  //           //       Container(
  //           //         decoration: BoxDecoration(
  //           //           border: Border.all(color: Colors.grey[300]!),
  //           //           borderRadius: BorderRadius.circular(6),
  //           //         ),
  //           //         padding: EdgeInsets.symmetric(horizontal: 8),
  //           //         child: DropdownButtonHideUnderline(
  //           //           child: DropdownButton<String>(
  //           //             value: currentUom,
  //           //             icon: Icon(
  //           //               Icons.arrow_drop_down,
  //           //               color: Colors.grey[600],
  //           //             ),
  //           //             iconSize: 20,
  //           //             elevation: 2,
  //           //             style: TextStyle(fontSize: 13, color: Colors.black),
  //           //             onChanged: (String? newValue) {
  //           //               if (newValue != null) {
  //           //                 // Update the cart item with new UOM selection
  //           //                 _updateItemUOM(item, newValue);
  //           //               }
  //           //             },
  //           //             items: <String>['piece', 'pack']
  //           //                 .map<DropdownMenuItem<String>>((String value) {
  //           //                   return DropdownMenuItem<String>(
  //           //                     value: value,
  //           //                     child: Container(
  //           //                       padding: EdgeInsets.symmetric(vertical: 4),
  //           //                       child: Text(
  //           //                         value == 'piece'
  //           //                             ? '1 pc.'
  //           //                             : '1 pack ($quantityPerBox ${uom.toLowerCase()})',
  //           //                         style: TextStyle(fontSize: 13),
  //           //                       ),
  //           //                     ),
  //           //                   );
  //           //                 })
  //           //                 .toList(),
  //           //           ),
  //           //         ),
  //           //       ),
  //           //     ],
  //           //   ),

  //           // UOM Selection Row - Only show dropdown if options exist
  //           // UOM Selection Row - Always show dropdown if quantityPerBox > 0
  //           if (quantityPerBox > 0)
  //             Container(
  //               margin: EdgeInsets.symmetric(vertical: 8),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Unit of Measure:',
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.grey[800],
  //                     ),
  //                   ),
  //                   SizedBox(height: 6),
  //                   Container(
  //                     height: 40,
  //                     padding: EdgeInsets.symmetric(horizontal: 12),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.grey[400]!, width: 1),
  //                       borderRadius: BorderRadius.circular(8),
  //                       color: Colors.white,
  //                     ),
  //                     child: DropdownButton<String>(
  //                       isExpanded: true,
  //                       value: currentUom,
  //                       icon: Icon(
  //                         Icons.arrow_drop_down,
  //                         color: Colors.grey[700],
  //                       ),
  //                       iconSize: 24,
  //                       elevation: 2,
  //                       style: TextStyle(fontSize: 14, color: Colors.black),
  //                       underline: Container(height: 0),
  //                       onChanged: (String? newValue) {
  //                         if (newValue != null) {
  //                           _updateItemUOM(item, newValue);
  //                         }
  //                       },
  //                       items: <String>['piece', 'pack']
  //                           .map<DropdownMenuItem<String>>((String value) {
  //                             return DropdownMenuItem<String>(
  //                               value: value,
  //                               child: Text(
  //                                 value == 'piece'
  //                                     ? 'Single piece (1 pc.)'
  //                                     : 'Full pack ($quantityPerBox ${uom.toLowerCase()})',
  //                                 style: TextStyle(fontSize: 14),
  //                               ),
  //                             );
  //                           })
  //                           .toList(),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //           // For soldAsBox products or when no UOM options, show a static display
  //           if (!showUomOptions)
  //             Row(
  //               children: [
  //                 Text(
  //                   'UOM:',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.grey[700],
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[100],
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   child: Text(
  //                     soldAsBox
  //                         ? '1 pack ($quantityPerBox ${uom.toLowerCase()})'
  //                         : (item.selectedVariant ?? '1 pc.'),
  //                     style: TextStyle(fontSize: 13, color: Colors.grey[700]),
  //                   ),
  //                 ),
  //               ],
  //             ),

  //           SizedBox(height: 10),

  //           // Second Row: Quantity controls and Total (keep existing)
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Total: ₹${(totalWithGST * item.quantity).toStringAsFixed(2)}',
  //                     style: TextStyle(
  //                       color: Colors.green.shade700,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   if (currentUom == 'pack' && quantityPerBox > 0)
  //                     Text(
  //                       '($quantityPerBox ${uom.toLowerCase()} per pack)',
  //                       style: TextStyle(fontSize: 11, color: Colors.grey[600]),
  //                     ),
  //                 ],
  //               ),
  //               // Quantity section
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Qty: ',
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   SizedBox(width: 5),
  //                   Container(
  //                     width: 50,
  //                     height: 27,
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.grey),
  //                       borderRadius: BorderRadius.circular(5),
  //                     ),
  //                     child: TextFormField(
  //                       cursorColor: Colors.orange.shade700,
  //                       initialValue: item.quantity.toString(),
  //                       keyboardType: TextInputType.number,
  //                       textAlign: TextAlign.center,
  //                       decoration: InputDecoration(
  //                         border: InputBorder.none,
  //                         contentPadding: EdgeInsets.symmetric(horizontal: 8),
  //                         isDense: true,
  //                       ),
  //                       style: TextStyle(fontSize: 15, color: Colors.black),
  //                       onChanged: (value) {
  //                         if (value.isNotEmpty) {
  //                           int newQty = int.tryParse(value) ?? 1;
  //                           if (newQty > 0) {
  //                             cartController.updateQuantity(item.id, newQty);
  //                           } else if (newQty == 0) {
  //                             _showDeleteDialog(item);
  //                           }
  //                         } else {
  //                           // Handle empty input - set to default quantity
  //                           cartController.updateQuantity(item.id, 1);
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).onTap(() {
  //     final productSlug = item.categorySlug ?? '';
  //     print("Product tapped - Slug: $productSlug, ID: ${item.id}");

  //     if (productSlug.isNotEmpty) {
  //       Get.to(() => DetailProductScreen(productSlug: productSlug));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Product details not available'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   });
  // }

  Widget _buildCheckoutButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Obx(() {
        return ElevatedButton(
          onPressed: cartController.isCartEmpty
              ? null
              : () {
                  // Reset the flag before navigating to checkout
                  _isReturningFromCheckout = false;
                  Get.to(() => CheckoutScreen());
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Proceed to Checkout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(CartItem item) {
    showDialog(
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
                cartController.removeFromCart(item.id);
                // Remove from cache
                _productDetailsCache.remove(item.id);
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
