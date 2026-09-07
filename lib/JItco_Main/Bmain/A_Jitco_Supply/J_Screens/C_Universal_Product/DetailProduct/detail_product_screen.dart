import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/B_Your_Enquiries/enquires_screen.dart';
import 'package:jitco_app/A_Widgets/Rating_bar/rating_detail.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/product_descrip.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/tabs/use_and_appli.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/A_Widgets/consts/list.dart';
import 'package:velocity_x/velocity_x.dart';

class DetailProductScreen extends StatefulWidget {
  final String productSlug;
  final String? productType;

  const DetailProductScreen({
    super.key,
    required this.productSlug,
    this.productType,
  });

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();
  int selectedIndex = 0;
  late TabController _tabController;

  final ApiServices _apiService = Get.find<ApiServices>();
  final CartController _cartController = Get.find<CartController>();
  Map<String, dynamic>? productData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  OutletModel? cityWarehouse;
  String? _warehouseId;

  late int selectedUomIndex =
      _cartController.selectedUomIndex; // 0 = piece, 1 = pack

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchIdFromWarehouse();
      await _fetchProductDetails();
    });
    // _fetchIdFromWarehouse();
    // _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      print("Fetching product details for slug: ${widget.productSlug}");
      final result = await _apiService.detailedProducts(
        productSlug: widget.productSlug,
        warehouseId: _warehouseId,
        userId: _authController.userId.value,
      );

      print("API Response: $result");

      // Fix: Handle the response structure properly
      Map<String, dynamic>? productDataFromApi;

      if (result is Map<String, dynamic>) {
        // Check if the product data is in the 'products' key
        if (result.containsKey('products') && result['products'] != null) {
          productDataFromApi = result['products'];
        }
        // If no 'products' key, use the entire result as product data
        else {
          productDataFromApi = result;
        }
      }

      if (mounted) {
        setState(() {
          productData = productDataFromApi;
          isLoading = false;
        });
      }
      print("Product data loaded successfully: ${productData != null}");
    } catch (e) {
      print("Error fetching product details: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  // Helper methods to get product data
  String _getProductImage() {
    if (productData?['productImage'] != null &&
        productData?['productImage'] is List &&
        productData?['productImage'].isNotEmpty) {
      return productData!['productImage'][0];
    }
    return '';
  }

  String _getProductName() {
    return productData?['productName'] ?? 'Unknown Product';
  }

  String _getProductPrice() {
    return productData?['universalPrice']?.toString() ??
        productData?['mrp']?.toString() ??
        '0';
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
          print('❌ No outlets found for user');
          return;
        }

        // 2. Convert first outlet to OutletModel
        print('🔄 Creating OutletModel from first outlet...');
        final outlet = OutletModel.fromJson(outlets[0]);

        // 3. Get city name directly from OutletModel
        final cityName = outlet.cityName;
        print('📍 City name from OutletModel: "$cityName"');

        if (cityName == null || cityName.isEmpty) {
          print('❌ City name is null or empty in OutletModel');
          return;
        }

        // 4. Call warehouse API with city name
        print('📡 Calling warehouse API with city: "$cityName"...');
        final result = await _apiService.getWarehouseIdByCity(
          page: 1,
          limit: 1,
          encodedCity: cityName,
        );

        // 5. Process warehouse response - FIXED HERE
        print('📊 Warehouse API response: ${result}');

        if (result['data'] != null) {
          // Check if data is a List or a single object
          if (result['data'] is List) {
            final warehouseList = result['data'] as List;

            if (warehouseList.isNotEmpty) {
              print('✅ Warehouse data found in list!');
              final warehouseData = warehouseList[0];
              final warehouseId = warehouseData['_id'];

              print('🏭 Warehouse _id: $warehouseId');

              // Store the warehouse ID
              setState(() {
                _warehouseId = warehouseId;
                cityWarehouse = OutletModel.fromJson(warehouseData);
              });

              print('✅ Warehouse model created with ID: ${cityWarehouse!.id}');
            } else {
              print('❌ No warehouses found for city: $cityName');
            }
          }
          // Handle if data is a single object (not a list)
          else if (result['data'] is Map) {
            print('✅ Warehouse data found as single object!');
            final warehouseData = result['data'] as Map<String, dynamic>;
            final warehouseId = warehouseData['_id'];

            print('🏭 Warehouse _id: $warehouseId');

            // Store the warehouse ID
            setState(() {
              _warehouseId = warehouseId;
              cityWarehouse = OutletModel.fromJson(warehouseData);
            });

            print('✅ Warehouse model created with ID: ${cityWarehouse!.id}');
          } else {
            print(
              '❌ Invalid warehouse data format: ${result['data'].runtimeType}',
            );
          }
        } else {
          print('❌ No data in warehouse response');
        }
      } else {
        print('❌ Failed to fetch outlets: ${outletResponse['message']}');
      }
    } catch (e) {
      print('❌ Error in _fetchIdFromWarehouse: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      print('🏁 END: _fetchIdFromWarehouse() completed');
    }
  }

  double? getProductPrice() {
    print('CALCULATING PRICE FOR: ${productData?['productName']}');

    final double contractPrice = (productData?['contractPrice'] ?? 0)
        .toDouble();
    final double boxPrice = (productData?['boxPrice'] ?? 0).toDouble();
    final double universalPrice = (productData?['universalPrice'] ?? 0)
        .toDouble();
    final int quantityPerBox = productData?['quantityPerBox'] ?? 1;

    final bool soldAsBox = productData?['soldAsBox'] == true;

    print('   soldAsBox: $soldAsBox');
    print('   contractPrice: $contractPrice');
    print('   boxPrice: $boxPrice');
    print('   universalPrice: $universalPrice');
    print('   quantityPerBox: $quantityPerBox');

    if (soldAsBox) {
      if (contractPrice > 0) {
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
      if (contractPrice > 0) {
        if (selectedUomIndex == 1) {
          print(
            'Using contract single price: ${contractPrice * quantityPerBox}',
          );
          return contractPrice * quantityPerBox;
        }
        print('Using contract single price: $contractPrice');
        return contractPrice;
      }
      if (boxPrice > 0) {
        if (selectedUomIndex == 1) {
          print("boxPrice467: $selectedUomIndex");
          print("boxPrice467: $boxPrice");
          return boxPrice;
        }
        // print('USING BOX PRICE: $boxPrice');
        // return boxPrice;
      }

      if (universalPrice > 0) {
        print('USING UNIVERSAL SINGLE PRICE: $universalPrice');
        if (selectedUomIndex == 1) {
          print(
            'Using universal box price: ${universalPrice * quantityPerBox}',
          );
          return universalPrice * quantityPerBox;
        }
        print('Using universal single price: $universalPrice');
        return universalPrice; //else
      }

      print('NO PRICE FOUND (SINGLE)');
      return null;
    }
  }

  double? cartProductPrice() {
    if (selectedUomIndex == 0) {
      print("detail: $selectedUomIndex");
      return getProductPrice();
    } else {
      print("detail2: $selectedUomIndex");
      return getProductPrice()! * productData?['quantityPerBox'];
    }
  }

  String _getProductGST() {
    return productData?['gstPercentage']?.toString() ?? '0';
  }

  String _getProductDescription() {
    return productData?['productShortDescription'] ??
        productData?['productLongDescription'] ??
        'No description available';
  }

  String _getBrandName() {
    return productData?['brand']?['name'] ?? 'Unknown Brand';
  }

  String _getVegNonVeg() {
    return productData?['vegNoneveg'] ?? 'Veg';
  }

  List<String> _getHighlights() {
    final highlights = productData?['highlights'] ?? '';
    if (highlights is String && highlights.isNotEmpty) {
      // Simple parsing - you might need more sophisticated parsing based on your HTML structure
      return highlights
          .replaceAll('<p>', '\n')
          .replaceAll('</p>', '\n')
          .split('\n');
    }
    return [];
  }

  List<String> _getKeywords() {
    final keywords = productData?['keywords'] ?? '';
    if (keywords is String && keywords.isNotEmpty) {
      return keywords.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  // Check if product is in cart
  bool get _isProductInCart {
    if (productData == null) return false;

    final productId = productData?['_id'] ?? '';
    return _cartController.cartItems.any((item) => item.id == productId);
  }

  void _addToCart() {
    if (productData != null) {
      final productId = productData?['_id'] ?? '';
      final productName = _getProductName();
      final categorySlug = productData?['slug'] ?? '';
      final quantityPerBox = productData?['quantityPerBox'] ?? 1;
      final uom = productData?['uom'] ?? 'item';
      final boxPrice = (productData?['boxPrice'] ?? 0).toDouble();
      final contractPrice = (productData?['contractPrice'] ?? 0).toDouble();
      final universalPrice = (productData?['universalPrice'] ?? 0).toDouble();
      final bool hasContract = contractPrice > 0;
      final bool soldAsBox = productData?['soldAsBox'] == true;

      // Calculate price based on selected UOM
      double itemPrice = 0.0;
      String? variantType = selectedUomIndex == 1 ? 'pack' : 'piece';

      // Get the selected variant text
      String selectedVariant = selectedUomIndex == 1
          ? 'Full pack'
          : 'Single piece';

      // Calculate price based on selected variant
      if (variantType == 'pack') {
        // For pack, use box price or calculate from contract/universal
        if (boxPrice > 0) {
          itemPrice = boxPrice;
        } else if (hasContract && contractPrice > 0) {
          itemPrice = contractPrice * quantityPerBox;
        } else if (universalPrice > 0) {
          itemPrice = universalPrice * quantityPerBox;
        } else {
          // Fallback to getProductPrice() for pack
          itemPrice = getProductPrice() ?? 0.0;
        }
      } else {
        // For piece, use contract or universal price
        if (hasContract && contractPrice > 0) {
          itemPrice = contractPrice;
        } else {
          itemPrice = universalPrice;
        }
      }

      double gstPercentage = double.tryParse(_getProductGST()) ?? 0.0;

      print('Adding to cart:');
      print('  Product: $productName');
      print('  Selected Variant: $selectedVariant');
      print('  Variant Type: $variantType');
      print('  Price: $itemPrice');
      print('  Box Price: $boxPrice');
      print('  Contract Price: $contractPrice');
      print('  Universal Price: $universalPrice');
      print('  Quantity Per Box: $quantityPerBox');
      print('  UOM: $uom');
      print('  Has Contract: $hasContract');
      print('  Sold As Box: $soldAsBox');

      // Create cart item with variant type
      final cartItem = CartItem(
        id: productId,
        name: productName,
        image: _getProductImage(),
        price: getProductPrice() ?? 0.0,
        gstPercentage: gstPercentage,
        quantity: 1,
        categorySlug: categorySlug,
        selectedVariant: selectedVariant,
        originalPrice: itemPrice,
        warehouseId: null,
        quantityPerBox: quantityPerBox,
        uom: uom,
        variantType: variantType, // ADD THIS
      );

      // Add to cart using the controller
      _cartController.addToCart(cartItem);

      // Update UI
      setState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName added to cart'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      print(
        'Added to cart: $productName - $selectedVariant - Price: $itemPrice - Variant Type: $variantType',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add product to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove from cart function
  void _removeFromCart() {
    if (productData != null) {
      final productId = productData?['_id'] ?? '';
      final productName = _getProductName();

      // Remove from cart using the controller
      _cartController.removeFromCart(productId);

      // Update UI
      setState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productName removed from cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      print('Removed from cart: $productName');
    }
  }

  bool get showUomOptions {
    final qty = productData?['quantityPerBox'];
    final boxPrice = productData?['boxPrice'] ?? 0;
    final universalPrice = productData?['universalPrice'] ?? 0;
    final contractPrice = productData?['contractPrice'] ?? 0;

    return qty != null &&
        qty > 0 &&
        (boxPrice > 0 || universalPrice > 0 || contractPrice > 0);
  }

  double get unitPrice {
    return (productData?['contractPrice'] ??
            productData?['universalPrice'] ??
            0)
        .toDouble();
  }

  double get boxPrice {
    return (productData?['boxPrice'] ?? 0).toDouble();
  }

  bool get soldAsBox => productData?['soldAsBox'] == true;

  // Toggle cart function
  void _toggleCart() {
    if (_isProductInCart) {
      _removeFromCart();
    } else {
      _addToCart();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = getProductPrice();
    final bool isContract = (productData?['contractPrice'] ?? 0) > 0;

    final int qty = productData?['quantityPerBox'] ?? 1;

    // Single piece price
    final double displayPrice = isContract
        ? (productData?['contractPrice'] ?? 0).toDouble()
        : (productData?['universalPrice'] ?? 0).toDouble();

    // Box / Pack price
    final double displayBoxPrice = () {
      final bool soldAsBox = productData?['soldAsBox'] ?? false;
      final double contractPrice = (productData?['contractPrice'] ?? 0)
          .toDouble();
      final double boxPrice = (productData?['boxPrice'] ?? 0).toDouble();

      if (soldAsBox) {
        // Rule 2 & 3
        return isContract ? contractPrice * qty : boxPrice;
      } else {
        // Rule 4 & 5
        return isContract ? contractPrice * qty : boxPrice;
      }
    }();
    final bool showUomOptions =
        (productData?['quantityPerBox'] ?? 0) > 0 &&
        ((productData?['soldAsBox'] ?? false) ||
            (productData?['boxPrice'] ?? 0) > 0 ||
            isContract);

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Loading product details...'),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text('Error loading product'),
              SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProductDetails,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: false,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
                // Product Image
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      child: _getProductImage().isNotEmpty
                          ? Image.network(
                              _getProductImage(),
                              height: 300,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: Colors.grey[350],
                                  child: Icon(Icons.error, size: 50),
                                );
                              },
                            )
                          : Container(
                              height: 300,
                              color: Colors.grey[350],
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                    ),
                  ),
                ),

                // Product Details
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Product Title
                      Text(
                        _getProductName(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      10.heightBox,
                      Text(
                        _getProductDescription(),
                        style: TextStyle(fontSize: 15),
                      ),
                      10.heightBox,
                      _brandSection(),
                      10.heightBox,

                      // Price and Rating Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (getProductPrice() != null) ...[
                              '₹${getProductPrice()}'.text
                                  .size(25)
                                  .fontWeight(FontWeight.bold)
                                  .color(Colors.orange)
                                  .make(),
                              'Exclusive of all taxes'.text.make(),
                              10.heightBox,
                            ],
                            // Row(
                            //   children: [
                            //     RatingBarIndicator(
                            //       rating: 3.0,
                            //       itemCount: 5,
                            //       itemSize: 20,
                            //       itemBuilder: (context, index) =>
                            //           Icon(Icons.star, color: Colors.amber),
                            //     ),
                            //     SizedBox(width: 8),
                            //     Text(
                            //       "4.4 (58 reviews)",
                            //       style: TextStyle(fontSize: 16),
                            //     ),
                            //   ],
                            // ),
                            RatingDetail(),
                          ],
                        ),
                      ),
                      7.heightBox,

                      /// Option Selection
                      // SizedBox(
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text('Select option:'),
                      //       8.heightBox,
                      //       Row(
                      //         children: [
                      //           Expanded(
                      //             child: _buildOption(
                      //               index: 0,
                      //               title: "Single piece",
                      //               price: "₹${getProductPrice()}",
                      //               subTitle: "",
                      //             ),
                      //           ),
                      //           SizedBox(width: 12),
                      //           Expanded(
                      //             child: _buildOption(
                      //               index: 1,
                      //               title: "Full pack",
                      //               price:
                      //                   "₹${productData?['boxPrice']?.toString() ?? '0'}",
                      //               subTitle:
                      //                   "₹${productData?['quantityPerBox']?.toString() ?? '0'} ${productData?['uom']?.toString() ?? 'item'} at ₹${getProductPrice()}/btl",
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      if (showUomOptions)
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select option:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              8.heightBox,

                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    /// SINGLE PIECE
                                    if (!(productData?['soldAsBox'] ?? false))
                                      Expanded(
                                        child: _buildOption(
                                          index: 0,
                                          isSelected: selectedUomIndex == 0,
                                          title: "Single piece",
                                          price:
                                              "₹${displayPrice.toStringAsFixed(0)}",
                                          subTitle: "",
                                          onTap: () {
                                            setState(
                                              () => selectedUomIndex = 0,
                                            );
                                          },
                                        ),
                                      ),

                                    if (!(productData?['soldAsBox'] ?? false))
                                      const SizedBox(width: 12),

                                    /// FULL PACK
                                    Expanded(
                                      child: _buildOption(
                                        index: 1,
                                        isSelected: selectedUomIndex == 1,
                                        title: "Full pack",
                                        price:
                                            "₹${displayBoxPrice.toStringAsFixed(0)}",
                                        subTitle:
                                            "${productData?['quantityPerBox']} ${productData?['uom']} at "
                                            "₹${displayPrice.toStringAsFixed(0)}/${productData?['uom']?.toLowerCase()}",
                                        onTap: () {
                                          setState(() => selectedUomIndex = 1);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // if (showUomOptions)
                      //   SizedBox(
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         const Text(
                      //           'Select option:',
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //         8.heightBox,

                      //         IntrinsicHeight(
                      //           // KEY LINE
                      //           child: Row(
                      //             crossAxisAlignment:
                      //                 CrossAxisAlignment.stretch,
                      //             children: [
                      //               /// SINGLE PIECE
                      //               if (!soldAsBox)
                      //                 Expanded(
                      //                   child: _buildOption(
                      //                     index: 0,
                      //                     isSelected: selectedUomIndex == 0,
                      //                     title: "Single piece",
                      //                     price:
                      //                         "₹${unitPrice.toStringAsFixed(0)}",
                      //                     subTitle: "",
                      //                     onTap: () {
                      //                       setState(
                      //                         () => selectedUomIndex = 0,
                      //                       );
                      //                     },
                      //                   ),
                      //                 ),

                      //               if (!soldAsBox) const SizedBox(width: 12),

                      //               /// FULL PACK
                      //               Expanded(
                      //                 child: _buildOption(
                      //                   index: 1,
                      //                   isSelected: selectedUomIndex == 1,
                      //                   title: "Full pack",
                      //                   price:
                      //                       "₹${boxPrice.toStringAsFixed(0)}",
                      //                   subTitle:
                      //                       "${productData?['quantityPerBox']} ${productData?['uom']} at "
                      //                       "₹${unitPrice.toStringAsFixed(0)}/${productData?['uom']?.toLowerCase()}",
                      //                   onTap: () {
                      //                     setState(() => selectedUomIndex = 1);
                      //                   },
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      18.heightBox,
                      if (_getHighlights().isNotEmpty) const Divider(),
                      12.heightBox,

                      // Product Highlights
                      if (_getHighlights().isNotEmpty) ...[
                        'Product Highlights'.text
                            .fontWeight(FontWeight.bold)
                            .size(20)
                            .make(),
                        15.heightBox,
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue.shade50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _getHighlights().map((highlight) {
                                return _buildBulletPoint(highlight);
                              }).toList(),
                            ),
                          ),
                        ),
                        30.heightBox,
                      ],

                      // Keywords
                      if (_getKeywords().isNotEmpty) ...[
                        'Keywords'.text
                            .fontWeight(FontWeight.bold)
                            .size(20)
                            .make(),
                        15.heightBox,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _getKeywords().take(5).map((keyword) {
                            return _keyTitle(
                              keyword,
                              Colors.orange.shade700,
                              Colors.white,
                            );
                          }).toList(),
                        ),
                        30.heightBox,
                      ],
                    ]),
                  ),
                ),

                // Tab Bar
                if (productData?['usp'] != null ||
                    productData?['productLongDescription'] != null ||
                    productData?['dietary'] != null ||
                    productData?['vegNoneveg'] != null ||
                    productData?['ingredients'] != null ||
                    productData?['instructions'] != null ||
                    productData?['usage'] != null)
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _StickyTabBarDelegate(
                      child: Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.orange,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.orange,
                          indicatorWeight: 2,
                          indicator: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                          tabs: [
                            // if (descripProductData.isNotEmpty)
                            const Tab(text: "Product Description"),
                            // if (usageProductData.isNotEmpty)
                            Tab(text: "Usage & Applications"),
                          ],
                        ),
                      ),
                    ),
                  ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Product Description Tab - Pass the product data
                ProductDescrip(productData: productData),

                // Usage & Applications Tab - Pass the product data
                UseAndAppli(productData: productData),
              ],
            ),
          ),
        ),
      ),

      // Bottom Add to Cart / Remove from Cart Button
      // bottomNavigationBar: SafeArea(
      //   child: Container(
      //     padding: EdgeInsets.all(16),
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black12,
      //           blurRadius: 8,
      //           offset: Offset(0, -2),
      //         ),
      //       ],
      //     ),
      //     child: SizedBox(
      //       height: 50,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           ElevatedButton(
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: _isProductInCart
      //                   ? Colors.red
      //                   : Colors.orange.shade700,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10),
      //               ),
      //             ),
      //             onPressed: _toggleCart,
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Icon(
      //                   _isProductInCart
      //                       ? Icons.remove_shopping_cart
      //                       : Icons.shopping_cart,
      //                   color: Colors.white,
      //                 ),
      //                 SizedBox(width: 8),
      //                 Text(
      //                   _isProductInCart ? 'Remove from Cart' : 'Add to Cart',
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 16,
      //                     fontWeight: FontWeight.w600,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //           // const Spacer(),
      //           if (_isProductInCart)
      //             OutlinedButton(
      //               onPressed: () {},
      //               child: Icon(Icons.car_crash),
      //             ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(13),
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
          child: IntrinsicWidth(
            child: SizedBox(
              height: 50,
              child: price != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          // Make first button expandable
                          child: SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isProductInCart
                                    ? Colors.red
                                    : Colors.orange.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _toggleCart,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isProductInCart
                                        ? Icons.remove_shopping_cart
                                        : Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _isProductInCart
                                        ? 'Remove from Cart'
                                        : 'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_isProductInCart) ...[
                          SizedBox(width: 8),
                          SizedBox(
                            height: 70,
                            child:
                                // CartBadgeIcon(isActive: true),
                                OutlinedButton(
                                  onPressed: () {
                                    // Get.to(
                                    //   () => JitcoSupplyNavBar(initialIndex: 4),
                                    // );
                                    if (widget.productType == 'Jitco') {
                                      Get.to(
                                        () =>
                                            JitcoSupplyNavBar(initialIndex: 4),
                                      );
                                    } else {
                                      Get.find<BottomNavController>().switchTab(
                                        4,
                                      );
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            final navigator = Navigator.of(
                                              context,
                                            );

                                            if (navigator.canPop()) {
                                              navigator.pop();
                                            }
                                          });
                                      // final bottomNavState = context
                                      //     .findAncestorStateOfType<BottomNavItemState>();
                                      // if (bottomNavState != null) {
                                      //   bottomNavState.switchToTab(
                                      //     1,
                                      //   ); // Switch to Products tab (index 2)
                                      // }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(10),
                                    ),
                                  ),
                                  child: CartBadgeIcon(
                                    isActive: true,
                                    iconSize: 24,
                                    activeColor: Colors.grey,
                                    nonActiveColor: Colors.grey,
                                  ),
                                ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: SizedBox(
                        height: 35,
                        width: 70,
                        child: Obx(() {
                          final enquiryController =
                              Get.find<EnquiryController>();
                          final isInEnquiry = enquiryController.enquiryItems
                              .any(
                                (enquiry) =>
                                    enquiry.productId == productData?['_id'],
                              );

                          return TextButton(
                            onPressed: () async {
                              if (isInEnquiry) {
                                // Navigate to enquiry screen
                                Get.to(() => EnquiresScreen());
                              } else {
                                // Show quantity dialog and create enquiry
                                _showEnquiryDialog(context, productData);
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: isInEnquiry
                                  ? Colors.blue.shade200
                                  : Colors.blue.shade500,
                              padding: EdgeInsets.all(4),
                            ),
                            child: Text(
                              isInEnquiry ? 'View Enquire' : 'Enquire Now',
                              style: TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEnquiryDialog(BuildContext context, dynamic product) {
    final RxInt quantity = 1.obs;
    final TextEditingController controller = TextEditingController(text: '1');
    final TextEditingController commentController = TextEditingController();

    // Sync controller with RxInt
    ever(quantity, (value) {
      if (controller.text != value.toString()) {
        controller.text = value.toString();
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      }
    });

    showDialog(
      // barrierColor: Colors.transparent,
      //To prevent the dialog from closing when tapping outside
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Enquire for ${product['productName']}'),
          titleTextStyle: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set quantity:'),
                const SizedBox(height: 10),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: controller,
                            cursorColor: Colors.orange.shade700,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              final q = int.tryParse(value) ?? 1;
                              quantity.value = q < 1 ? 1 : q;
                            },
                          ),
                        ),
                      ),
                      20.heightBox,

                      const Text('Notes(Optional):'),
                      const SizedBox(height: 10),

                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Additional comments...",
                          hintStyle: TextStyle(color: Colors.grey),
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
                            borderSide: BorderSide(
                              color: Colors.orange.shade700,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createEnquiry(
                  product['_id'],
                  quantity.value,
                  commentController.text.trim(),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange.shade700,
              ),
              child: const Text('Submit Enquiry'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEnquiry(
    String productId,
    int quantity,
    String? comments,
  ) async {
    try {
      final enquiryController = Get.find<EnquiryController>();
      await enquiryController.createEnquiry(
        context,
        productId,
        quantity,
        comments,
      );
    } catch (e) {
      print('Error creating enquiry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create enquiry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOption({
    required int index,
    required bool isSelected,
    required String title,
    required String price,
    required String subTitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 2,
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
          color: isSelected ? Colors.orange.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.orange.shade700 : Colors.black,
                    ),
                  ),
                  if (subTitle.isNotEmpty) ...[
                    4.heightBox,
                    Text(
                      subTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String productHighlights) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text('$productHighlights', style: TextStyle(fontSize: 15)), //•
    );
  }

  Widget _keyTitle(String keywords, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Text(
        keywords,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _brandSection() {
    final brandImage = productData?['brand']?['image'] ?? '';

    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (brandImage.isNotEmpty)
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(brandImage))
          else
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.business, color: Colors.white),
            ),
          10.widthBox,
          _keyTitle(_getBrandName(), Colors.yellow.shade200, Colors.black54),
          const Spacer(),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getVegNonVeg()),
                10.widthBox,
                // You can add veg/non-veg icon based on the value
                _getVegNonVeg().toLowerCase() == 'veg'
                    ? Icon(Icons.eco, color: Colors.green)
                    : Icon(Icons.fastfood, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
