// screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/JM_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/All_JM_Menus/all_jm_menus.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/jm_price_calculation_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/widget/delivery_address.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/price_calculation_service.dart';
import 'package:jitco_app/A_Widgets/consts/list.dart';
import 'package:velocity_x/velocity_x.dart';

class JmMenuScreen extends StatefulWidget {
  const JmMenuScreen({super.key});

  @override
  State<JmMenuScreen> createState() => _JmMenuScreenState();
}

class _JmMenuScreenState extends State<JmMenuScreen> {
  final JmCartController jmCartController = Get.find<JmCartController>();
  final AuthController authController = Get.find<AuthController>();
  final ApiServices apiService = Get.find<ApiServices>();
  final JMApiService jmApiService = Get.find<JMApiService>();
  final JmPriceCalculationService priceService =
      Get.find<JmPriceCalculationService>();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController menuNameController = TextEditingController();
  final RxBool isDeliveryAddressSelected = false.obs;
  final RxString selectedCityName = ''.obs;
  RxString selectedWarehouseId = ''.obs;
  OutletModel? cityWarehouse;
  final RxBool isLoading = false.obs;
  String? selectedOutletId;
  String selectedBillingAddress = '';
  String selectedPaymentMethod = 'pay_now'; // Add this for JitMenu

  // Store fetched product details
  // final Map<String, Map<String, dynamic>> _productDetailsCache = {};
  // var _productDetailsCache = <String, Map<String, dynamic>>{}.obs;

  // @override
  // void initState() {
  //   super.initState();
  //   // Load current warehouse if exists
  //   // if (cartController.currentWarehouseId.value.isNotEmpty) {
  //   //   selectedWarehouseId.value = cartController.currentWarehouseId.value;
  //   // }

  //   // Initial warehouse
  //   // _fetchIdFromWarehouse();
  //   selectedWarehouseId.value = cartController.currentWarehouseId.value;

  //   ///LISTEN FOR WAREHOUSE CHANGES
  //   ever(cartController.currentWarehouseId, (String newWarehouseId) {
  //     if (newWarehouseId.isNotEmpty) {
  //       selectedWarehouseId.value = newWarehouseId;

  //       // Clear old cache
  //       _productDetailsCache.clear();

  //       // Fetch fresh prices immediately
  //       _fetchProductDetails();
  //     }
  //   });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _fetchProductDetails();
  //   });
  // }

  @override
  void initState() {
    super.initState();

    _clearSavedAddress();

    // Start with cart prices (from cart screen)
    // Don't automatically fetch product details on init
    // Wait until address is selected

    // Store original cart prices if not already stored
    for (var item in jmCartController.cartItems) {
      if (item.originalPrice == null) {
        // Ensure original price is preserved
        final index = jmCartController.cartItems.indexOf(item);
        jmCartController.cartItems[index] = item.copyWith(
          originalPrice: item.price,
        );
      }
    }

    // Listen for address selection to fetch location prices
    // ever(isDeliveryAddressSelected, (isSelected) {
    //   if (isSelected && selectedWarehouseId.value.isNotEmpty) {
    //     // Address selected, fetch location-based prices
    //     _fetchProductDetailsForAddress();
    //   } else if (!isSelected) {
    //     // Address deselected, clear cache to revert to cart prices
    //     _productDetailsCache.clear();
    //     setState(() {});
    //   }
    // });
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
      if (jmCartController.currentWarehouseId.value.isNotEmpty) {
        jmCartController.currentWarehouseId.value = '';
      }
    } catch (e) {
      print('Error clearing saved address: $e');
    }
  }

  // Future<void> _fetchProductDetailsForAddress() async {
  //   if (!isDeliveryAddressSelected.value || selectedWarehouseId.value.isEmpty) {
  //     return;
  //   }

  //   print(
  //     "Api is hitting from _fetchProductDetailsForAddress******************",
  //   );

  //   isLoading(true);

  //   try {
  //     // Clear old cache when fetching for new address
  //     _productDetailsCache.clear();

  //     for (var item in cartController.cartItems) {
  //       if (item.categorySlug != null) {
  //         try {
  //           final productDetails = await apiService.detailedProducts(
  //             productSlug: item.categorySlug!,
  //             warehouseId: selectedWarehouseId.value,
  //             userId: authController.userId.value,
  //           );

  //           if (productDetails is Map && productDetails.isNotEmpty) {
  //             _productDetailsCache[item.id] = productDetails;

  //             // Calculate and update price for this item
  //             final resolvedPrice = priceService.resolveProductPrice(
  //               productData: productDetails,
  //             );

  //             if (resolvedPrice != null && resolvedPrice > 0) {
  //               // Update item with location-based price
  //               final index = cartController.cartItems.indexOf(item);
  //               cartController.cartItems[index] = item.copyWith(
  //                 price: resolvedPrice,
  //                 originalPrice: item.originalPrice ?? item.price,
  //                 warehouseId: selectedWarehouseId.value,
  //               );
  //             }
  //           }
  //         } catch (e) {
  //           print('Error fetching product details for ${item.name}: $e');
  //         }
  //       }
  //     }

  //     // Refresh cart controller
  //     cartController.cartItems.refresh();
  //   } finally {
  //     isLoading(false);
  //     setState(() {});
  //   }
  // }

  // Calculate product price based on contract, box, and universal prices
  double? _calculateProductPrice({
    required Map<String, dynamic> productData,
    bool isVariant = false,
    String? selectedVariant,
  }) {
    print('CALCULATING PRICE FOR: ${productData['productName']}');

    final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
    final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (productData['universalPrice'] ?? 0)
        .toDouble();
    final int quantityPerBox = productData['quantityPerBox'] ?? 1;
    final bool soldAsBox = productData['soldAsBox'] == true;
    final bool hasContract = productData['hasContract'] == true;

    print('   soldAsBox: $soldAsBox');
    print('   contractPrice: $contractPrice');
    print('   boxPrice: $boxPrice');
    print('   universalPrice: $universalPrice');
    print('   quantityPerBox: $quantityPerBox');
    print('   hasContract: $hasContract');

    // Check for variant pricing if applicable
    if (isVariant && selectedVariant != null) {
      final variants = productData['variants'] as List?;
      if (variants != null) {
        for (var variant in variants) {
          if (variant['variant'] == selectedVariant) {
            final variantPrice =
                variant['price']?.toDouble() ?? variant['mrp']?.toDouble();
            if (variantPrice != null && variantPrice > 0) {
              print('USING VARIANT PRICE: $variantPrice');
              return variantPrice;
            }
          }
        }
      }
    }

    if (soldAsBox) {
      if (hasContract && contractPrice > 0) {
        final price = contractPrice * quantityPerBox;
        print('USING CONTRACT BOX PRICE: $price');
        return price;
      }

      if (boxPrice > 0) {
        print('USING BOX PRICE: $boxPrice');
        return boxPrice;
      }

      if (universalPrice > 0) {
        print('USING UNIVERSAL PRICE (BOX): $universalPrice');
        return universalPrice;
      }

      print('NO PRICE FOUND (BOX)');
      return null;
    } else {
      if (hasContract && contractPrice > 0) {
        print('USING CONTRACT SINGLE PRICE: $contractPrice');
        return contractPrice;
      }

      if (universalPrice > 0) {
        print('USING UNIVERSAL SINGLE PRICE: $universalPrice');
        return universalPrice;
      }

      print('NO PRICE FOUND (SINGLE)');
      return null;
    }
  }

  // Get product GST percentage
  String _getProductGST(Map<String, dynamic> productData) {
    return productData['gstPercentage']?.toString() ?? '0';
  }

  // Calculate GST amount
  // double _calculateGSTAmount(double price, double gstPercentage) {
  //   return price * (gstPercentage / 100);
  // }

  // Fetch product details for all cart items
  // Future<void> _fetchProductDetails() async {
  //   isLoading(true);

  //   // if (isDeliveryAddressSelected.value && selectedWarehouseId.value.isEmpty) {
  //   //   return;
  //   // }

  //   print("Api is hitting from _fetchProductDetails******************");

  //   try {
  //     for (var item in cartController.cartItems) {
  //       if (item.categorySlug != null &&
  //           !_productDetailsCache.containsKey(item.id)) {
  //         try {
  //           final productDetails = await apiService.detailedProducts(
  //             productSlug: item.categorySlug!,
  //             warehouseId: selectedWarehouseId.value.isEmpty
  //                 ? null
  //                 : selectedWarehouseId.value,
  //             userId: authController.userId.value,
  //           );

  //           if (productDetails is Map && productDetails.isNotEmpty) {
  //             _productDetailsCache[item.id] = productDetails;
  //           }
  //         } catch (e) {
  //           print('Error fetching product details for ${item.name}: $e');
  //         }
  //       }
  //     }
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Future<void> _fetchProductDetails() async {
  //   isLoading(true);

  //   try {
  //     for (var item in cartController.cartItems) {
  //       if (item.categorySlug != null &&
  //           !_productDetailsCache.containsKey(item.id)) {
  //         try {
  //           final productDetails = await apiService.detailedProducts(
  //             productSlug: item.categorySlug!,
  //             warehouseId: selectedWarehouseId.value.isEmpty
  //                 ? null
  //                 : selectedWarehouseId.value,
  //             userId: authController.userId.value,
  //           );

  //           if (productDetails is Map && productDetails.isNotEmpty) {
  //             _productDetailsCache[item.id] = productDetails;

  //             // Update the item price directly
  //             item.price =
  //                 priceService.resolveProductPrice(
  //                   productData: productDetails,
  //                 ) ??
  //                 item.price;
  //           }
  //         } catch (e) {
  //           print('Error fetching product details for ${item.name}: $e');
  //         }
  //       }
  //     }

  //     // Trigger UI update
  //     cartController.refresh(); // If using GetX
  //     setState(() {}); // Optional if inside StatefulWidget
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Calculate price for a cart item using the new logic
  double? _calculateItemPrice(JmCartItem item) {
    final double cartPrice = item.originalPrice ?? item.price;
    final productData = jmCartController.productDetailsCache[item.id];
    if (productData == null) {
      print('No product data found for item: ${item.name}');
      return item.price; // Fallback to existing price
    }

    print("**********************: $productData");

    return (isDeliveryAddressSelected.value)
        ? priceService.resolveProductPrice(
                productData: productData,
                selectVariantUom: item.selectedVariant,
              ) ??
              cartPrice
        : cartPrice;
  }

  // Get GST percentage for a cart item
  String _getItemGST(JmCartItem item) {
    final productData = jmCartController.productDetailsCache[item.id];
    if (productData == null) {
      return item.gstPercentage.toString();
    }

    return _getProductGST(productData);
  }

  // Calculate GST amount for a cart item
  double _calculateItemGSTAmount(JmCartItem item) {
    final price = _calculateItemPrice(item) ?? item.price;
    final gstPercentage =
        double.tryParse(_getItemGST(item)) ?? item.gstPercentage;
    return price * (gstPercentage / 100);
  }

  // Calculate total price including GST for a cart item
  double _calculateItemTotalWithGST(JmCartItem item) {
    final price = _calculateItemPrice(item) ?? item.price;
    final gstPercentage =
        double.tryParse(_getItemGST(item)) ?? item.gstPercentage;
    return price + (price * (gstPercentage / 100));
  }
  //******************************************************************* */
  // // Calculate all totals using new logic
  // double get _calculatedTotalPrice {
  //   double total = 0;
  //   for (var item in cartController.cartItems) {
  //     final price = _calculateItemPrice(item) ?? item.price;
  //     total += price * item.quantity;
  //   }
  //   return total;
  // }

  // double get _calculatedTotalGST {
  //   double totalGST = 0;
  //   for (var item in cartController.cartItems) {
  //     final price = _calculateItemPrice(item) ?? item.price;
  //     final gstPercentage =
  //         double.tryParse(_getItemGST(item)) ?? item.gstPercentage;
  //     totalGST += (price * (gstPercentage / 100)) * item.quantity;
  //   }
  //   return totalGST;
  // }

  // double get _calculatedGrandTotal {
  //   return _calculatedTotalPrice + _calculatedTotalGST;
  // }

  // Add these getters to your widget class
  // double get _calculatedTotalPrice {
  //   double total = 0;

  //   for (final item in cartController.cartItems) {
  //     final productData = cartController.productDetailsCache[item.id];
  //     final double cartPrice = item.originalPrice ?? item.price;

  //     final double calculatedPrice = (isDeliveryAddressSelected.value)
  //         ? priceService.resolveProductPrice(productData: productData) ??
  //               cartPrice
  //         : cartPrice;

  //     total += calculatedPrice * item.quantity;
  //   }

  //   return total;
  // }

  // double get _calculatedTotalGST {
  //   double totalGST = 0;

  //   for (final item in cartController.cartItems) {
  //     final productData = cartController.productDetailsCache[item.id];
  //     final double cartPrice = item.originalPrice ?? item.price;

  //     final double calculatedPrice = (isDeliveryAddressSelected.value)
  //         ? priceService.resolveProductPrice(productData: productData) ??
  //               cartPrice
  //         : cartPrice;

  //     final calculatedGST = priceService.getItemGST(
  //       productData: productData,
  //       item: item,
  //     );

  //     final gstPercentage =
  //         double.tryParse(calculatedGST) ?? item.gstPercentage;
  //     final gstAmount = priceService.calculateGSTAmount(
  //       calculatedPrice,
  //       gstPercentage,
  //     );

  //     totalGST += gstAmount * item.quantity;
  //   }

  //   return totalGST;
  // }
  double get _calculatedTotalPrice {
    double total = 0;

    for (final item in jmCartController.cartItems) {
      // Always use the cart controller's cache for consistency
      final productData = jmCartController.productDetailsCache[item.id];

      // Determine which price to use
      double finalPrice;

      if (isDeliveryAddressSelected.value && productData != null) {
        // Address is selected AND we have product data
        final locationPrice = priceService.resolveProductPrice(
          productData: productData,
          selectVariantUom: item.selectedVariant,
        );
        finalPrice = locationPrice ?? item.price;
      } else {
        // No address selected OR no product data - use cart price
        finalPrice = item.price;
      }

      total += finalPrice * item.quantity;
    }

    return total;
  }

  double get _calculatedTotalGST {
    double totalGST = 0;

    for (final item in jmCartController.cartItems) {
      final productData = jmCartController.productDetailsCache[item.id];

      // Determine which price to use (same logic as above)
      double finalPrice;

      if (isDeliveryAddressSelected.value && productData != null) {
        final locationPrice = priceService.resolveProductPrice(
          productData: productData,
          selectVariantUom: item.selectedVariant,
        );
        finalPrice = locationPrice ?? item.price;
      } else {
        finalPrice = item.price;
      }

      // Determine GST percentage
      double gstPercentage;

      if (productData != null && productData['gstPercentage'] != null) {
        gstPercentage =
            double.tryParse(productData['gstPercentage'].toString()) ??
            item.gstPercentage;
      } else {
        gstPercentage = item.gstPercentage;
      }

      // Calculate GST amount for this item
      final gstAmount = finalPrice * (gstPercentage / 100);
      totalGST += gstAmount * item.quantity;
    }

    return totalGST;
  }

  double get _calculatedGrandTotal {
    return _calculatedTotalPrice + _calculatedTotalGST;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              "Your Menu".text.color(Colors.black87).make(),
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
                      jmCartController.cartItems.isNotEmpty) {
                    jmCartController.checkPriceUpdate(cityName);
                    setState(() {});
                  }
                },
                onOutletSelected: (outletId) {
                  selectedOutletId = outletId;
                },
                onAddressStringSelected: (address) {
                  selectedBillingAddress = address;
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

              _buildNotesPlusMenunameSection(
                "Menu Name (Optional)",
                "You can give your Menu name...",
                menuNameController,
              ),

              20.heightBox,

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
      bottomNavigationBar: _buildPlaceOrderButton(),
    );
  }

  double getItemDisplayPrice(JmCartItem item) {
    // Always return the cart price initially
    // This comes from the cart screen where item was added
    final cartPrice = item.originalPrice ?? item.price;

    // Only calculate location-based price if:
    // 1. Delivery address is selected (user has chosen a shipping address)
    // 2. We have product details fetched for the selected warehouse
    // 3. The price calculation service can resolve a price
    if (isDeliveryAddressSelected.value &&
        jmCartController.productDetailsCache.containsKey(item.id)) {
      final productData = jmCartController.productDetailsCache[item.id]!;

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
                    '${jmCartController.totalItems} items',
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
                itemCount: jmCartController.cartItems.length,
                itemBuilder: (context, index) {
                  late int selectedUomIndex = jmCartController.selectedUomIndex;
                  print('1: $selectedUomIndex');
                  final item = jmCartController.cartItems[index];
                  final productData =
                      jmCartController.productDetailsCache[item.id];

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
                    productData: jmCartController.productDetailsCache[item.id],
                    item: item,
                  );
                  final gstPercentage =
                      double.tryParse(calculatedGST) ?? item.gstPercentage;
                  final gstAmount = priceService.calculateGSTAmount(
                    calculatedPrice,
                    gstPercentage,
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
                                      '${item.selectedVariant ?? "1 pc."}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'GST: ${gstPercentage.toStringAsFixed(1)}% (₹${(gstAmount * item.quantity).toStringAsFixed(2)})',
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
              "Payment Method *".text
                  .size(18)
                  .fontWeight(FontWeight.w400)
                  .make(),
              12.heightBox,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: apiService.contractStatus(),
                  builder: (context, snapshot) {
                    bool isContracted = false;
                    if (snapshot.hasData && snapshot.data != null) {
                      isContracted = snapshot.data!['contracted'] == true;
                    }
                    
                    // Build items based on contract status
                    List<DropdownMenuItem<String>> items = [
                      const DropdownMenuItem(
                        value: 'pay_now',
                        child: Text('Pay Now'),
                      ),
                      const DropdownMenuItem(
                        value: 'credit',
                        child: Text('Credit'),
                      ),
                    ];

                    if (isContracted) {
                      items.add(
                        const DropdownMenuItem(
                          value: 'contract_term',
                          child: Text('Contract Term'),
                        ),
                      );
                    } else if (selectedPaymentMethod == 'contract_term') {
                       // Safety: if state somehow has contract_term but user is not contracted
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         if (mounted) {
                           setState(() {
                             selectedPaymentMethod = 'pay_now';
                           });
                         }
                       });
                    }

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPaymentMethod,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade700),
                        items: items,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedPaymentMethod = newValue;
                            });
                          }
                        },
                      ),
                    );
                  }
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
                _buildPriceRow('Items:', '${jmCartController.totalItems}'),
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
                if (jmCartController.hasPriceChanges)
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
        // Get.snackbar(
        //   'Error',
        //   'Please select a delivery address',
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a delivery address'),
            backgroundColor: Colors.red,
          ),
        );
        authController.isLoading(false);
        return;
      }

      // 1. FETCH OUTLET DATA
      print('=== USING PRE-SELECTED OUTLET DATA ===');

      String outletId = selectedOutletId ?? '';
      String cityName = selectedCityName.value;
      String address = selectedBillingAddress;

      print('Selected Outlet ID: $outletId');
      print('City name: $cityName');
      print('Billing Address: $address');

      if (outletId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not find selected delivery address'),
            backgroundColor: Colors.red,
          ),
        );
        authController.isLoading(false);
        return;
      }

      // 2. GET PAYMENT METHOD
      print('=== SETTING PAYMENT METHOD ===');
      String paymentMethod = selectedPaymentMethod;
      print('Payment Method: $paymentMethod');

      // 3. FETCH WAREHOUSE DATA BASED ON SELECTED CITY
      print('=== USING PRE-SELECTED WAREHOUSE DATA ===');
      String warehouseId = jmCartController.currentWarehouseId.value;
      
      if (warehouseId.isEmpty) {
         warehouseId = authController.warehouseId.value;
      }
      print('Final Warehouse ID: $warehouseId');

      // 4. BUILD ORDER PAYLOAD
      final orderPayload = {
        "customer": authController.userId.value,
        "company": authController.companyId.value,
        "outlet": outletId, //as per selected outlet address(outletId) api[DONE]
        "warehouseId": warehouseId,
        "paymentMethod": paymentMethod, //[DONE]
        "shippingAddress":
            outletId, //as per selected outlet address(outletId) api[DONE]
        "billingAddress": address, //as per selected address city[DONE]
        "items": jmCartController.cartItems.map((item) {
          // Use the calculated prices instead of item.xxx
          final calculatedPrice = _calculateItemPrice(item) ?? item.price;
          final calculatedGSTPercentage =
              double.tryParse(_getItemGST(item)) ?? item.gstPercentage;

          final priceTotal = calculatedPrice * item.quantity;
          final gstTotal = priceTotal * (calculatedGSTPercentage / 100);
          final totalWithGST = priceTotal + gstTotal;
          return {
            "product": item.id,
            "quantity": item.quantity,
            "price": calculatedPrice, //
            "gst": item.gstPercentage,
            "priceTotal": priceTotal,
            "gstTotal": gstTotal.toStringAsFixed(2),
            "total": totalWithGST.toStringAsFixed(2),
          };
        }).toList(),
        "totalAmount": _calculatedTotalPrice.toStringAsFixed(2),
        "gst": _calculatedTotalGST.toStringAsFixed(2),
        "finalAmount": _calculatedGrandTotal.toStringAsFixed(2),
        "discount": 0,
        "paymentStatus": "PENDING",
        "orderStatus": "Processing",
        "menuName": menuNameController.text.trim(),
        "notes": notesController.text.trim(),
      };

      print('FINAL ORDER PAYLOAD → $orderPayload');

      // 5. SUBMIT ORDER
      print('=== SUBMITTING ORDER TO API ===');
      try {
        final result = await jmApiService.submitMenu(orderPayload);
        print('=== ORDER API RESPONSE ===');
        print('Success: ${result['success']}');
        print('Message: ${result['message']}');

        if (result['success'] == true) {
          // Show success message
          Get.snackbar(
            'Success',
            result['message'] ?? 'Order created successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );

          // Clear cart and navigate to confirmation
          jmCartController.clearCart();

          // Add a small delay to let user see the success message
          await Future.delayed(Duration(seconds: 1));

          // Get.to(() => OrderConfirmationScreen());
          Get.off(() => AllJmMenus());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Succesfully created a menu'),
              backgroundColor: Colors.green,
            ),
          );
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
                      if (jmCartController.cartItems.isEmpty) {
                        // _showSnackbar(
                        //   title: 'Error',
                        //   message: 'Your cart is empty',
                        //   backgroundColor: Colors.red,
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your cart is empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final confirmed = await Get.dialog<bool>(
                        AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Confirm Menu"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Are you sure you want to make this Menu?",
                              ),
                              if (jmCartController.hasPriceChanges) ...[
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
            // Get.off(() => JitcoSupplyNavBar(initialIndex: 1));
            Get.find<JmBottomNavController>().switchTab(1);
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
              "Menu Created Successfully!".text
                  .size(26)
                  .fontWeight(FontWeight.bold)
                  .make(),
              13.heightBox,
              "Your menu has been created successfully.".text
                  .size(15)
                  .color(Colors.grey[700])
                  .align(TextAlign.center)
                  .make(),
              40.heightBox,
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => JitcoSupplyNavBar(initialIndex: 1));
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
