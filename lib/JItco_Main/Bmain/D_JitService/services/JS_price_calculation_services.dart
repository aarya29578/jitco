import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';

class JsPriceCalculationServices extends GetxService {
  static JsPriceCalculationServices get to => Get.find();

  // Calculate product price based on variant type, contract, box, and universal prices
  double? calculateProductPrice({
    required Map<String, dynamic> productData,
    String? variantType, // 'piece' or 'pack'
    String? selectedVariant,
  }) {
    print('=== CALCULATING PRICE ===');
    print('Product: ${productData['productName']}');
    print('Variant Type: $variantType');
    print('Selected Variant: $selectedVariant');

    final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
    final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (productData['universalPrice'] ?? 0)
        .toDouble();
    final int quantityPerBox = productData['quantityPerBox'] ?? 1;
    final bool soldAsBox = productData['soldAsBox'] == true;
    final bool hasContract = productData['hasContract'] == true;

    print('   soldAsBox: $soldAsBox');
    print('   hasContract: $hasContract');
    print('   contractPrice: $contractPrice');
    print('   boxPrice: $boxPrice');
    print('   universalPrice: $universalPrice');
    print('   quantityPerBox: $quantityPerBox');

    // First, check for variant-specific pricing
    if (selectedVariant != null) {
      final variants = productData['variants'] as List?;
      if (variants != null && variants.isNotEmpty) {
        for (var variant in variants) {
          if (variant['variant'] == selectedVariant) {
            final variantPrice =
                variant['price']?.toDouble() ?? variant['mrp']?.toDouble();
            if (variantPrice != null && variantPrice > 0) {
              print('✅ USING VARIANT PRICE: $variantPrice');
              return variantPrice;
            }
          }
        }
      }
    }

    // Determine which price to use based on variant type
    if (variantType == 'pack' || selectedVariant == 'Full pack') {
      // User selected pack variant
      print('📦 CALCULATING FOR PACK VARIANT');

      if (hasContract && contractPrice > 0) {
        final price = contractPrice * quantityPerBox;
        print(
          '✅ USING CONTRACT BOX PRICE: $price (contract: $contractPrice × qty: $quantityPerBox)',
        );
        return price;
      }

      if (boxPrice > 0) {
        print('✅ USING BOX PRICE: $boxPrice');
        return boxPrice;
      }

      if (universalPrice > 0) {
        final price = universalPrice * quantityPerBox;
        print(
          '✅ USING UNIVERSAL PRICE (BOX): $price (universal: $universalPrice × qty: $quantityPerBox)',
        );
        return price;
      }

      print('❌ NO PRICE FOUND FOR PACK');
      return null;
    } else {
      // User selected piece variant or default
      print('🛒 CALCULATING FOR PIECE VARIANT');

      if (hasContract && contractPrice > 0) {
        print('✅ USING CONTRACT SINGLE PRICE: $contractPrice');
        return contractPrice;
      }

      if (universalPrice > 0) {
        print('✅ USING UNIVERSAL SINGLE PRICE: $universalPrice');
        return universalPrice;
      }

      print('❌ NO PRICE FOUND FOR PIECE');
      return null;
    }
  }

  // double? resolveProductPrice({required Map<String, dynamic>? productData}) {
  //   if (productData == null) return null;

  //   final warehouseId = CartController().currentWarehouseId.value;

  //   final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
  //   final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
  //   final double universalPrice = (productData['universalPrice'] ?? 0)
  //       .toDouble();
  //   final int quantityPerBox = productData['quantityPerBox'] ?? 1;

  //   final bool soldAsBox = productData['soldAsBox'] == true;
  //   print('product********************************************: $productData');
  //   if (soldAsBox) {
  //     print(
  //       'contractPrice********************************************: $contractPrice',
  //     );
  //     if (contractPrice > 0) {
  //       return contractPrice * quantityPerBox;
  //     }
  //     if (boxPrice > 0) {
  //       return boxPrice;
  //     }
  //     if (universalPrice > 0) {
  //       return universalPrice;
  //     }
  //     return null;
  //   } else {
  //     if (contractPrice > 0) {
  //       return contractPrice;
  //     }
  //     if (universalPrice > 0) {
  //       return universalPrice;
  //     }
  //     return null;
  //   }
  // }

  // double? resolveProductPrice({required Map<String, dynamic>? productData}) {
  //   final CartController cartController = Get.find<CartController>();
  //   if (productData == null) return null;

  //   // ADD THIS LINE HERE (MANDATORY)
  //   final warehouseId = cartController.currentWarehouseId.value;

  //   final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
  //   final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
  //   final double universalPrice = (productData['universalPrice'] ?? 0)
  //       .toDouble();
  //   final int quantityPerBox = productData['quantityPerBox'] ?? 1;

  //   final bool soldAsBox = productData['soldAsBox'] == true;

  //   //Debug (optional but useful)
  //   print('Price calc for warehouse: $warehouseId');

  //   if (soldAsBox) {
  //     if (contractPrice > 0) {
  //       print('object: ${contractPrice * quantityPerBox}');
  //       return contractPrice * quantityPerBox;
  //     }
  //     if (boxPrice > 0) {
  //       print('object*: $boxPrice');
  //       return boxPrice;
  //     }
  //     if (universalPrice > 0) {
  //       print('object**: $universalPrice');
  //       return universalPrice;
  //     }
  //     return null;
  //   } else {
  //     if (contractPrice > 0) {
  //       print('elseobject: ${contractPrice * quantityPerBox}');
  //       return contractPrice;
  //     }
  //     if (universalPrice > 0) {
  //       print('elseobject**: $universalPrice');
  //       return universalPrice;
  //     }
  //     return null;
  //   }
  // }

  double? resolveProductPrice({
    required Map<String, dynamic>? productData,
    String? selectVariantUom,
  }) {
    // REMOVE this line - don't depend on CartController for warehouse ID
    // final CartController cartController = Get.find<CartController>();

    if (productData == null) return null;

    // Get warehouse ID from the product data itself if available
    // Or pass it as a parameter
    final double contractPrice = (productData['contractPrice'] ?? 0).toDouble();
    final double boxPrice = (productData['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (productData['universalPrice'] ?? 0)
        .toDouble();
    final int quantityPerBox = productData['quantityPerBox'] ?? 1;
    final bool soldAsBox = productData['soldAsBox'] == true;

    final CartController _cartController = Get.find<CartController>();
    late int selectedUomIndex =
        _cartController.selectedUomIndex; // 0 = piece, 1 = pack

    print('object24: $selectedUomIndex');
    print('object43: $selectVariantUom');

    print('Price calculation data:');
    print('  soldAsBox: $soldAsBox');
    print('  contractPrice: $contractPrice');
    print('  boxPrice: $boxPrice');
    print('  universalPrice: $universalPrice');
    print('  quantityPerBox: $quantityPerBox');

    if (soldAsBox) {
      if (contractPrice > 0) {
        final price = contractPrice * quantityPerBox;
        print('Using contract box price: $price');
        return price;
      }
      if (boxPrice > 0) {
        print('Using box price: $boxPrice');
        return boxPrice;
      }
      if (universalPrice > 0) {
        print('Using universal price (box): $universalPrice');
        return universalPrice;
      }
      print('No price found for box item');
      return null;
    } else {
      if (contractPrice > 0) {
        if (selectedUomIndex == 1 || selectVariantUom == 'Full pack') {
          print(
            'Using contract single price: ${contractPrice * quantityPerBox}',
          );
          return contractPrice * quantityPerBox;
        }
        print('Using contract single price: $contractPrice');
        return contractPrice;
      }
      if (boxPrice > 0) {
        print('Using box price: $boxPrice');
        if (selectedUomIndex == 1 || selectVariantUom == 'Full pack') {
          print(
            'Using contract single price: ${contractPrice * quantityPerBox}',
          );
          return boxPrice;
        }
        // return boxPrice;
      }
      if (universalPrice > 0) {
        if (selectedUomIndex == 1 || selectVariantUom == 'Full pack') {
          print(
            'Using universal box price: ${universalPrice * quantityPerBox}',
          );
          return universalPrice * quantityPerBox;
        }
        print('Using universal single price: $universalPrice');
        return universalPrice; //else
      }
      print('No price found for single item');
      return null;
    }
  }

  // double? resolveProductPrice({
  //   required Map<String, dynamic>? productData,
  //   // required bool isLogin,
  // }) {
  //   if (productData == null) return 0;

  //   final double? contractPrice = productData['contractPrice']?.toDouble();
  //   final double? price = productData['price']?.toDouble();
  //   final double? universalPrice = productData['universalPrice']?.toDouble();
  //   final double? boxPrice = productData['boxPrice']?.toDouble();

  //   final int quantityPerBox = productData['quantityPerBox'] ?? 1;
  //   final bool soldAsBox = productData['soldAsBox'] == true;

  //   // ===== Display Price (single unit) =====
  //   double displayPrice;

  //   if (contractPrice != null && contractPrice > 0) {
  //     displayPrice = contractPrice;
  //     print('display contract price: $displayPrice');
  //   } else if (price != null && price > 0) {
  //     displayPrice = price;
  //     print('b: $displayPrice');
  //   } else if (universalPrice != null && universalPrice > 0) {
  //     displayPrice = universalPrice;
  //     print('c: $displayPrice'); //using 234.0 in pune
  //   } else {
  //     displayPrice = 0;
  //     print('d: $displayPrice');
  //   }

  //   // ===== Box Price Logic =====
  //   if (soldAsBox) {
  //     if (contractPrice != null && contractPrice > 0) {
  //       print('soldAsBox contract price: ${contractPrice * quantityPerBox}');
  //       return contractPrice * quantityPerBox;
  //     } else if (boxPrice != null && boxPrice > 0) {
  //       print('soldAsBox boxPrice: $displayPrice');
  //       return boxPrice;
  //     } else {
  //       print('soldAsBox else: ${displayPrice * quantityPerBox}');
  //       return displayPrice * quantityPerBox;
  //     }
  //   }
  //   print('d: $displayPrice');

  //   return displayPrice;
  // }

  // Get product GST percentage
  String getProductGST(Map<String, dynamic> productData) {
    return productData['gstPercentage']?.toString() ?? '0';
  }

  // Calculate GST amount
  double calculateGSTAmount(double price, double gstPercentage) {
    return price * (gstPercentage / 100);
  }

  // Calculate price for a cart item
  double? calculateItemPrice({
    required Map<String, dynamic>? productData,
    required JsCartitem
    item, // Pass the entire CartItem instead of individual fields
  }) {
    if (productData == null) {
      print('No product data found, using item price: ${item.price}');
      return item.originalPrice ?? item.price;
    }

    // Use the item's variantType to determine price calculation
    final calculatedPrice = calculateProductPrice(
      productData: productData,
      variantType: item.variantType,
      selectedVariant: item.selectedVariant,
    );

    if (calculatedPrice != null) {
      print('Calculated price: $calculatedPrice (Item price: ${item.price})');
      return calculatedPrice;
    } else {
      print('Could not calculate price, using item price: ${item.price}');
      return item.originalPrice ?? item.price;
    }
  }

  // Get GST percentage for a cart item
  String getItemGST({
    required Map<String, dynamic>? productData,
    required JsCartitem item,
  }) {
    if (productData == null) {
      return item.gstPercentage.toString();
    }

    return getProductGST(productData);
  }

  // Calculate GST for a cart item
  double calculateItemGSTAmount({
    required Map<String, dynamic>? productData,
    required JsCartitem item,
  }) {
    final price =
        calculateItemPrice(productData: productData, item: item) ?? item.price;
    final gstPercentage =
        double.tryParse(getItemGST(productData: productData, item: item)) ??
        item.gstPercentage;
    return price * (gstPercentage! / 100);
  }

  // Calculate total with GST for a cart item
  double calculateItemTotalWithGST({
    required Map<String, dynamic>? productData,
    required JsCartitem item,
  }) {
    final price =
        calculateItemPrice(productData: productData, item: item) ?? item.price;
    final gstAmount = calculateItemGSTAmount(
      productData: productData,
      item: item,
    );
    return (price + gstAmount) * item.quantity;
  }

  // Calculate all totals using product data cache
  Map<String, double> calculateCartTotals({
    required List<JsCartitem> cartItems,
    required Map<String, Map<String, dynamic>> productDetailsCache,
  }) {
    double totalPrice = 0;
    double totalGST = 0;

    print('=== CALCULATING CART TOTALS ===');
    print('Items in cart: ${cartItems.length}');

    for (var item in cartItems) {
      final productData = productDetailsCache[item.id];
      final price =
          calculateItemPrice(productData: productData, item: item) ??
          item.price;

      final gstPercentage =
          double.tryParse(getItemGST(productData: productData, item: item)) ??
          item.gstPercentage;

      final gstAmount = price * (gstPercentage! / 100);
      final itemTotalPrice = price * item.quantity;
      final itemTotalGST = gstAmount * item.quantity;

      print('  Item: ${item.name}');
      print('    Price: $price × ${item.quantity} = $itemTotalPrice');
      print(
        '    GST: ${gstPercentage}% = $gstAmount × ${item.quantity} = $itemTotalGST',
      );
      print('    Variant: ${item.selectedVariant} (${item.variantType})');

      totalPrice += itemTotalPrice;
      totalGST += itemTotalGST;
    }

    final grandTotal = totalPrice + totalGST;

    print('  Subtotal: $totalPrice');
    print('  Total GST: $totalGST');
    print('  Grand Total: $grandTotal');
    print('=== END CALCULATION ===');

    return {
      'totalPrice': totalPrice,
      'totalGST': totalGST,
      'grandTotal': grandTotal,
    };
  }
}
