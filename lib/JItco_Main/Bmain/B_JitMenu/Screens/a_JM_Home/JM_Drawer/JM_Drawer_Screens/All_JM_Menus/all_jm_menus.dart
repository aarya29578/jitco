import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/all_menu_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_all_menus_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/All_JM_Menus/detail_jm_menu.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/a_JM_Your_Order/jm_order_confirm_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/price_calculation_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/D_Cart%20and%20summary/checkout_Screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/payment_webview.dart';
import 'package:velocity_x/velocity_x.dart';

class AllJmMenus extends StatefulWidget {
  const AllJmMenus({super.key});

  @override
  State<AllJmMenus> createState() => _AllJmMenusState();
}

class _AllJmMenusState extends State<AllJmMenus> {
  final AuthController authController = Get.find<AuthController>();
  final ApiServices apiService = Get.find<ApiServices>();
  final JMApiService jmApiService = Get.find<JMApiService>();
  final PriceCalculationService priceService =
      Get.find<PriceCalculationService>();
  // final JmCartController jmCartController = Get.find<JmCartController>();
  final AllMenuController _allMenuController = Get.put(AllMenuController());
  final ScrollController _scrollController = ScrollController();
  String? selectedOutletId;
  final RxBool isDeliveryAddressSelected = false.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _allMenuController.getAllMenu();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        _allMenuController.getAllMenu(loadMore: true);
      }
    });
  }

  // // Helper method to format address
  String _formatAddress(OutletModel outlet) {
    final addressParts = [
      outlet.address,
      outlet.cityName,
      outlet.stateName,
      outlet.pinCode != null ? '- ${outlet.pinCode}' : null,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return addressParts.join(', ');
  }

  String _getProductGST(productData) {
    return productData.gst?.toString() ?? '0';
  }

  // Calculate price for a cart item using the new logic
  double? _calculateItemPrice(MenuItem item) {
    final double cartPrice = item.price ?? 0;
    print("pricefromallJmMenus: $cartPrice");
    final productData = _allMenuController.menuDetail;
    print("productfromallJmMenus: $productData");
    if (productData.isEmpty) {
      // print('No product data found for item: ${item.name}');
      return item.price; // Fallback to existing price
    }

    print("**********************4343: $productData");

    return priceService.resolveProductPrice(
          productData: productData,
          // selectVariantUom: item.product.,
        ) ??
        cartPrice;
  }

  // Get GST percentage for a cart item
  String _getItemGST(Allmenu items) {
    final productData = items.id;
    if (productData == null) {
      return items.gst.toString();
    }

    return _getProductGST(items);
  }

  double get _calculatedTotalPrice {
    double total = 0;

    for (final item in _allMenuController.menuDetail) {
      // Always use the cart controller's cache for consistency
      final productData = _allMenuController.menuDetail;

      // Determine which price to use
      double finalPrice;

      if (isDeliveryAddressSelected.value && productData != null) {
        // Address is selected AND we have product data
        final locationPrice = priceService.resolveProductPrice(
          productData: productData,
          // selectVariantUom: item.selectedVariant,
        );
        finalPrice = locationPrice ?? item.price ?? 0;
      } else {
        // No address selected OR no product data - use cart price
        finalPrice = item.price ?? 0;
      }

      total += finalPrice * item.quantity!;
    }

    return total;
  }

  double get _calculatedTotalGST {
    double totalGST = 0;

    for (final item in _allMenuController.menuDetail) {
      final productData = _allMenuController.menuDetail;

      // Determine which price to use (same logic as above)
      double finalPrice;

      if (isDeliveryAddressSelected.value && productData != null) {
        final locationPrice = priceService.resolveProductPrice(
          productData: productData,
          // selectVariantUom: item.selectedVariant,
        );
        finalPrice = locationPrice ?? item.price ?? 0;
      } else {
        finalPrice = item.price ?? 0;
      }

      // Determine GST percentage
      double gstPercentage;

      if (productData != null && item.gst != null) {
        gstPercentage = item.gst!.toDouble();
      } else {
        gstPercentage = item.gst!;
      }

      // Calculate GST amount for this item
      final gstAmount = finalPrice * (gstPercentage / 100);
      totalGST += gstAmount * item.quantity!;
    }

    return totalGST;
  }

  double get _calculatedGrandTotal {
    return _calculatedTotalPrice + _calculatedTotalGST;
  }

  Future<void> _submitOrder(menus) async {
    print('=== STARTING ORDER SUBMISSION ===');
    authController.isLoading(true);

    try {
      // Validate outlet selection first
      // if (selectedOutletId == null || selectedOutletId!.isEmpty) {
      //   Get.snackbar(
      //     'Error',
      //     'Please select a delivery address',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   authController.isLoading(false);
      //   return;
      // }

      // 1. USE DEFAULT OUTLET DATA (Since UI doesn't have address selection here)
      print('=== USING OUTLET DATA ===');

      String outletId = '';
      String cityName = '';
      String shippingAddress = '';
      String billingAddress = '';

      // 2. GET PAYMENT METHOD
      print('=== FETCHING PAYMENT METHOD ===');
      String paymentMethod = 'COD'; // Default
      try {
        final contractResponse = await apiService.contractStatus();
        if (contractResponse['contracted'] == true) {
          paymentMethod = 'contractTerm';
        } else {
          paymentMethod = 'cod';
        }
      } catch (e) {
        print('Error fetching contract status: $e');
      }
      print('Payment Method: $paymentMethod');

      // 3. FETCH WAREHOUSE DATA
      print('=== USING WAREHOUSE DATA ===');
      String warehouseId = authController.warehouseId.value;

      print('Final Warehouse ID: $warehouseId');

      String menuNumber = menus.menuNumber;

      // 4. BUILD ORDER PAYLOAD
      final orderPayload = {
        "customer": authController.userId.value,
        "company": authController.companyId.value,
        "outlet": outletId, //as per selected outlet address(outletId) api[DONE]
        "warehouseId": warehouseId,
        "paymentMethod": paymentMethod, //[DONE]
        "shippingAddress":
            outletId, //as per selected outlet address(outletId) api[DONE]
        "billingAddress": billingAddress, //as per selected address city[DONE]
        "items": _allMenuController.menuDetail.map((item) {
          // Use the calculated prices instead of item.xxx
          final calculatedPrice = _calculateItemPrice(item) ?? item.price;
          final calculatedGSTPercentage =
              double.tryParse(_getItemGST(menus)) ?? item.gst;

          final priceTotal = calculatedPrice! * item.quantity!.toInt();
          final gstTotal = priceTotal * (calculatedGSTPercentage! / 100);
          final totalWithGST = priceTotal + gstTotal;
          return {
            "product": menus.id,
            "quantity": menus.quantity,
            "price": calculatedPrice, //
            "gst": item.gst,
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
        "menuStatus": "Processing",
        "notes": "Re-order from menu #$menuNumber",
        "source": "JitMenu",
      };

      print('FINAL ORDER PAYLOAD → $orderPayload');

      // 5. SUBMIT ORDER
      print('=== SUBMITTING ORDER TO API ===');
      try {
        final result = await jmApiService.postMenuOrder(orderPayload);
        print('=== ORDER API RESPONSE ===');
        print('Success: ${result['success']}');
        print('Message: ${result['message']}');

        if (result['success'] == true) {
          final responseData = result['data'];
          String? paymentUrl;

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
            if (paymentUrl == null && responseData.containsKey('data') && responseData['data'] is Map) {
              paymentUrl = findUrl(responseData['data']);
            }
            if (paymentUrl == null && responseData.containsKey('order') && responseData['order'] is Map) {
              paymentUrl = findUrl(responseData['order']);
            }
          }

          if (paymentUrl != null && paymentUrl.isNotEmpty) {
            print('PAYMENT URL FOUND: $paymentUrl');
            Get.to(
              () => PaymentWebView(
                paymentUrl: paymentUrl!,
                onPaymentSuccess: () {
                  Get.snackbar(
                    'Payment Successful',
                    'Your payment was completed successfully!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                  );
                  Get.off(() => JmOrderConfirmScreen());
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
            // Show success message
            Get.snackbar(
              'Success',
              result['message'] ?? 'Order placed successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );

            // Add a small delay to let user see the success message
            await Future.delayed(Duration(seconds: 1));

            Get.to(() => JmOrderConfirmScreen());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "All Menu's".text.size(20).make(),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          // final menus = _allMenuController.allMenuResponse.value.menus ?? [];
          final menus = _allMenuController.allMenus;
          if (_allMenuController.isLoading.value == true) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          print("Menuall: $menus");

          if (menus.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("No Menus found"),
                  15.heightBox,
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        // foregroundColor: Colors.orange.shade700,
                      ),
                      onPressed: () {
                        _allMenuController.getAllMenu();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.refresh),
                          3.widthBox,
                          const Text("Refresh"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _allMenuController.getAllMenu();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount:
                  menus.length +
                  (_allMenuController.isMoreLoading.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < menus.length) {
                  final menu = menus[index];

                  return
                  // Card(
                  //   color: Colors.white,
                  //   margin: const EdgeInsets.only(bottom: 10),
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 15,
                  //       vertical: 10,
                  //     ),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         menuDetails(
                  //           menu.menuName!.isEmpty ? "--" : menu.menuName,
                  //           menu.finalAmount?.toString() ?? "0",
                  //           16,
                  //           tailColor: Colors.orange.shade700,
                  //         ),
                  //         7.heightBox,
                  //         menuDetails(
                  //           "Company Name -",
                  //           menu.company?.companyName ?? "-",
                  //           14,
                  //         ),
                  //         3.heightBox,
                  //         menuDetails("Date -", "Jan 27, 2026", 14),
                  //         3.heightBox,
                  //         menuDetails(
                  //           "Total Items -",
                  //           menu.items?.length.toString() ?? "0",
                  //           14,
                  //         ),
                  //         15.heightBox,
                  //         Row(
                  //           children: [
                  //             Expanded(
                  //               child: menuBottons(
                  //                 "View",
                  //                 Colors.grey[200],
                  //                 Colors.black,
                  //               ),
                  //             ),
                  //             7.widthBox,
                  //             Expanded(
                  //               child: menuBottons(
                  //                 "Order Now",
                  //                 Colors.orange.shade700,
                  //                 Colors.white,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // );
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  menu.menuName?.isEmpty == true
                                      ? "--"
                                      : menu.menuName ?? "--",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "₹ ${menu.finalAmount?.toStringAsFixed(0) ?? "0"}",
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// COMPANY
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  menu.company?.companyName ?? "-",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// DATE + ITEMS
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                menu.createdAt == null
                                    ? "-"
                                    : "${menu.createdAt!.day}/${menu.createdAt!.month}/${menu.createdAt!.year}",
                                style: const TextStyle(color: Colors.black54),
                              ),

                              const Spacer(),

                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${menu.items?.length ?? 0} Items",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// BUTTONS
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 45,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.to(
                                        () => DetailJmMenu(menuId: menu.id),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    child: "View Details".text
                                        .color(Colors.orange.shade700)
                                        .make(),
                                  ),
                                ),
                              ),

                              // const SizedBox(width: 10),
                              // Expanded(
                              //   child: ElevatedButton(
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.orange.shade700,
                              //       foregroundColor: Colors.white,
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(10),
                              //       ),
                              //     ),
                              //     onPressed: () => {
                              //       // _submitOrder(menu),
                              //     },
                              //     child: const Text("Order Now"),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // bottom pagination loader
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }
              },
            ),

            // ListView.builder(
            //   controller: _scrollController,
            //   scrollDirection: Axis.vertical,
            //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            //   itemCount: menus.length,
            //   itemBuilder: (context, index) {
            //     final menu =
            //         _allMenuController.allMenuResponse.value.menus![index];
            //     return Card(
            //       color: Colors.white,
            //       margin: EdgeInsets.only(bottom: 10),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 15,
            //           vertical: 10,
            //         ),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             menuDetails(
            //               menu.menuName!.isEmpty ? "--" : menu.menuName,
            //               menu.finalAmount.toString(),
            //               16,
            //               tailColor: Colors.orange.shade700,
            //             ),
            //             7.heightBox,
            //             menuDetails(
            //               "Company Name -",
            //               menu.company!.companyName,
            //               14,
            //             ),
            //             3.heightBox,
            //             menuDetails("Date -", "Jan 27, 2026", 14),
            //             3.heightBox,
            //             menuDetails(
            //               "Total Items -",
            //               menu.items?.length.toString(),
            //               14,
            //             ),
            //             15.heightBox,
            //             Row(
            //               children: [
            //                 Expanded(
            //                   child: menuBottons(
            //                     "View",
            //                     Colors.grey[200],
            //                     Colors.black,
            //                   ),
            //                 ),
            //                 7.widthBox,
            //                 Expanded(
            //                   child: menuBottons(
            //                     "Order Now",
            //                     Colors.orange.shade700,
            //                     Colors.white,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // ),
          );
        }),
      ),
    );
  }
}

Widget _menuDetails(
  String? head,
  String? tail,
  double? size, {
  Color? tailColor = Colors.black,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(head!, style: TextStyle(fontSize: size!)),
      Text(
        tail!,
        style: TextStyle(fontSize: size!, color: tailColor!),
      ),
    ],
  );
}

Widget _menuBottons(String? buttonName, Color? backColor, foreColor) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: backColor,
      foregroundColor: foreColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    ),
    onPressed: () {},
    child: Text(buttonName!),
  );
}
