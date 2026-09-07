import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/detail_menu_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_payment_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/detail_menu_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/a_JM_Your_Order/jm_order_confirm_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Widgets/jm_order_dialog.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/payment_webview.dart';
import 'package:velocity_x/velocity_x.dart';

class DetailJmMenu extends StatefulWidget {
  final String? menuId;
  final DetailMenuModel? detailMenuModel;
  const DetailJmMenu({super.key, required this.menuId, this.detailMenuModel});

  @override
  State<DetailJmMenu> createState() => _DetailJmMenuState();
}

class _DetailJmMenuState extends State<DetailJmMenu> {
  final ApiServices _apiService = Get.find<ApiServices>();
  final JMApiService _jmApiService = Get.find<JMApiService>();
  final TextEditingController _notesController = TextEditingController();
  final DetailMenuController _detailMenuController = Get.put(
    DetailMenuController(),
  );
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _detailMenuController.getDetailMenu(menuId: widget.menuId);
  }

  // Helper method to format address
  String _formatAddress(OutletModel outlet) {
    final addressParts = [
      outlet.name,
      outlet.address,
      outlet.cityName,
      outlet.stateName,
      outlet.pinCode != null ? '- ${outlet.pinCode}' : null,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return addressParts.join(', ');
  }

  Future<void> _submitOrder(MenuDetails menus) async {
    print('=== STARTING ORDER SUBMISSION ===');
    _authController.isLoading(true);

    try {
      // Validate menu data
      if (menus.menuItems == null || menus.menuItems!.isEmpty) {
        Get.snackbar(
          'Error',
          'No items in the menu',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _authController.isLoading(false);
        return;
      }

      // 1. USE MENU OUTLET DATA
      print('=== USING MENU OUTLET DATA ===');
      String outletId = menus.outlet?.id ?? '';
      String cityName = menus.outlet?.city?.name ?? '';
      String shippingAddress = menus.shipAddress ?? '';
      String billingAddress = menus.billAddress ?? '';

      print('Selected Outlet ID: $outletId');
      print('City name: $cityName');
      print('Shipping Address: $shippingAddress');

      if (outletId.isEmpty) {
        Get.snackbar(
          'Error',
          'Could not find delivery address in menu',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _authController.isLoading(false);
        return;
      }

      // 2. GET PAYMENT METHOD
      // print('=== FETCHING PAYMENT METHOD ===');
      // String paymentMethod = 'COD'; // Default
      // try {
      //   final contractResponse = await _apiService.contractStatus();
      //   if (contractResponse['contracted'] == true) {
      //     paymentMethod = 'contractTerm';
      //   } else {
      //     paymentMethod = 'cod';
      //   }
      // } catch (e) {
      //   print('Error fetching contract status: $e');
      // }
      // print('Payment Method: $paymentMethod');
      print('=== FETCHING PAYMENT METHOD ===');
      String paymentMethod = 'contractTerm'; // Default
      try {
        final JmPaymentController jmPaymentController =
            Get.find<JmPaymentController>();
        // final contractResponse = await _apiService.contractStatus();
        if (jmPaymentController.selectedPayment.value == 'Pay Now') {
          paymentMethod = 'pay_now';
        } else if (jmPaymentController.selectedPayment.value == 'Credit') {
          paymentMethod = 'credit';
        }
      } catch (e) {
        print('Error fetching contract status: $e');
      }
      print('Payment Method: $paymentMethod');

      // 3. FETCH WAREHOUSE DATA
      print('=== USING DEFAULT WAREHOUSE DATA ===');
      String warehouseId = _authController.warehouseId.value; // Default

      print('Final Warehouse ID: $warehouseId');

      String menuNumber = menus.mNumber ?? '';

      // 4. BUILD ORDER PAYLOAD
      final orderPayload = {
        "customer": _authController.userId.value,
        "company": _authController.companyId.value,
        "outlet": outletId,
        "warehouseId": warehouseId.isEmpty ? null : warehouseId,
        "paymentMethod": paymentMethod,
        // "shippingAddress": shippingAddress,
        // "billingAddress": billingAddress,
        "shippingAddress": menus.shipAddress,
        "billingAddress": menus.billAddress,
        "items": menus.menuItems!.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          // Use controller methods that consider updated quantities
          final priceTotal = _detailMenuController.priceTotal(item, index);
          final gstTotal = _detailMenuController.gstTotal(item, index);
          final finalTotal = _detailMenuController.finalTotal(item, index);

          return {
            "product": item.product?.id ?? '',
            "quantity": _detailMenuController.getQty(index),
            "price": item.price ?? 0,
            "gst": item.gst ?? 0,
            "priceTotal": priceTotal.toStringAsFixed(2),
            "gstTotal": gstTotal.toStringAsFixed(2),
            "total": finalTotal.toStringAsFixed(2),
          };
        }).toList(),
        "totalAmount": _detailMenuController.menuSubTotal().toStringAsFixed(2),
        "gst": _detailMenuController.menuGstTotal().toStringAsFixed(2),
        "finalAmount": _detailMenuController.menuFinalTotal().toStringAsFixed(
          2,
        ),
        "discount": 0,
        "paymentStatus": "PENDING",
        "menuStatus": "Processing",
        "notes":
            "Re-order from menu #$menuNumber: ${_notesController.text.trim().isNotEmpty ? _notesController.text.trim() : "No Notes from User"}",
        "source": "JitMenu",
      };

      print('FINAL ORDER PAYLOAD → $orderPayload');

      // 5. SUBMIT ORDER
      print('=== SUBMITTING ORDER TO API ===');
      try {
        final result = await _jmApiService.postMenuOrder(orderPayload);
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

            // Navigate to confirmation
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
      _authController.isLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              _detailMenuController.getDetailMenu(menuId: widget.menuId);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_detailMenuController.isLoading.value == true) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final menuDetail =
              _detailMenuController.detailMenuResponse.value.menuDetails;

          if (menuDetail == null) {
            return const Text("no details found about Menu");
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: "Menu #${menuDetail.mNumber ?? "--"}".text
                                      .size(15)
                                      .fontWeight(FontWeight.w600)
                                      .make(),
                                ),
                                4.heightBox,
                                "Created: ${menuDetail.createdAt != null ? menuDetail.formattedDate : "--"}".text
                                    .size(12)
                                    .color(Colors.grey[600])
                                    .make(),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: (menuDetail.menuStatus ?? "Unknown")
                                  .toUpperCase()
                                  .text
                                  .size(12)
                                  .orange700
                                  .make(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                10.heightBox,

                _buildDeliveryInfo(menuDetail),

                10.heightBox,

                _buildNotesPlusMenunameSection(
                  "Notes (Optional)",
                  "Add any special instructions....",
                  _notesController,
                ),

                10.heightBox,
                _dropdownConst(),

                16.heightBox,

                "Menu Items (${menuDetail.menuItems?.length})".text
                    .size(16)
                    .fontWeight(FontWeight.w500)
                    .make(),

                12.heightBox,

                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: menuDetail.menuItems!.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                10.heightBox,
                                "No items found".text
                                    .color(Colors.grey[500])
                                    .make(),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: menuDetail.menuItems?.length,
                            itemBuilder: (context, index) {
                              final item = menuDetail.menuItems?[index];
                              return _buildOrderItem(
                                item,
                                index,
                                menuDetail.menuItems?.length ?? 0,
                                context,
                                _detailMenuController,
                              );
                            },
                          ),
                  ),
                ),

                _buildPriceBreakdown(menuDetail, _detailMenuController),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              // onPressed: () {
              //   _submitOrder(menuDetail);
              // },
              onPressed: () {
                final menuDetail =
                    _detailMenuController.detailMenuResponse.value.menuDetails;

                if (menuDetail == null) {
                  Get.snackbar(
                    'Error',
                    'Menu not loaded yet',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                showOrderDialog(context, () => _submitOrder(menuDetail));

                // _submitOrder(menuDetail);
              },

              child: const Text(
                "Order Now",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildOrderItem(
  MenuItem? item,
  int index,
  int totalItems,
  context,
  DetailMenuController controller,
) {
  return Container(
    // color: Colors.amber,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: item!.product!.productImage!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product!.productImage![0],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
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
            12.widthBox,
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  item.product!.productName!.text
                      .size(14)
                      .fontWeight(FontWeight.w500)
                      .make()
                      .onTap(() {
                        // if (item.productSlug!.isNotEmpty) {
                        //   Get.to(
                        //     () => DetailProductScreen(
                        //       productSlug: item.productSlug!,
                        //     ),
                        //   );
                        // }
                      }),
                  4.heightBox,
                  "Quantity: ${item.quantity}".text
                      .size(12)
                      .color(Colors.grey[600])
                      .make(),
                  4.heightBox,
                  Row(
                    children: [
                      "Price: ₹${item.price!.toStringAsFixed(2)}".text
                          .size(12)
                          .color(Colors.grey[600])
                          .make(),
                      8.widthBox,
                      "GST: ₹${item.gstTotal}".text
                          .size(12)
                          .color(Colors.grey[600])
                          .make(),
                    ],
                  ),
                  // Obx(() {
                  //   return Row(
                  //     children: [
                  //       "Price: ₹${controller.priceTotal(item, index).toStringAsFixed(2)}"
                  //           .text
                  //           .size(12)
                  //           .color(Colors.grey[600])
                  //           .make(),
                  //       8.widthBox,
                  //       "GST: ₹${controller.gstTotal(item, index).toStringAsFixed(2)}"
                  //           .text
                  //           .size(12)
                  //           .color(Colors.grey[600])
                  //           .make(),
                  //     ],
                  //   );
                  // }),
                ],
              ),
            ),
          ],
        ),

        20.heightBox,
        // if (index < _order.items.length - 1) 20.heightBox,

        // Price Column
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // "₹${item.total!.toStringAsFixed(2)}".text
                    //     .size(16)
                    //     .fontWeight(FontWeight.w600)
                    //     .color(Colors.orange.shade700)
                    //     .make(),
                    Obx(() {
                      return "₹${controller.finalTotal(item, index).toStringAsFixed(2)}"
                          .text
                          .size(16)
                          .fontWeight(FontWeight.w600)
                          .color(Colors.orange.shade700)
                          .make();
                    }),
                    "(${item.gst}%)".text
                        .size(12)
                        .color(Colors.grey[600])
                        .make(),
                  ],
                ),
                2.heightBox,
                // "₹${item.priceTotal!.toStringAsFixed(2)} + ₹${item.gstTotal!.toStringAsFixed(2)} GST"
                //     .text
                //     .size(10)
                //     .color(Colors.grey[600])
                //     .make(),
                Obx(() {
                  return "₹${controller.priceTotal(item, index).toStringAsFixed(2)} + ₹${controller.gstTotal(item, index).toStringAsFixed(2)} GST"
                      .text
                      .size(10)
                      .color(Colors.grey[600])
                      .make();
                }),
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qty: ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 5),
                Container(
                  width: 50,
                  height: 27,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Obx(() {
                    return TextFormField(
                      cursorColor: Colors.orange.shade700,
                      initialValue: controller.getQty(index).toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      onChanged: (value) {
                        controller.setQuantity(index, int.tryParse(value) ?? 1);
                      },
                    );
                  }),
                ),
                IconButton(
                  onPressed: () {
                    controller.deleteItem(index);
                    floatingSnackBar(
                      message: '1 item deleted from this list',
                      context: context,
                    );
                  },
                  style: IconButton.styleFrom(
                    iconSize: 20,
                    foregroundColor: Colors.red,
                  ),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
        if (index < totalItems - 1)
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Divider(color: Colors.grey[300]),
          ),
      ],
    ),
  );
}

Widget _buildPriceBreakdown(
  menuDetail,
  DetailMenuController detailMenuController,
) {
  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: "Menu Summary".text
                .size(16)
                .fontWeight(FontWeight.w500)
                .make(),
          ),

          12.heightBox,

          _buildPriceRow(
            'Subtotal:',
            // '₹${menuDetail.totalAmount.toStringAsFixed(2)}',
            '₹${detailMenuController.menuSubTotal().toStringAsFixed(2)}',
          ),
          // if (menuDetail.discount > 0)
          //   _buildPriceRow(
          //     'Discount:',
          //     '- ₹${menuDetail.discount.toStringAsFixed(2)}',
          //     isDiscount: true,
          //   ),
          // _buildPriceRow('GST:', '₹${menuDetail.gstMenu.toStringAsFixed(2)}'),
          _buildPriceRow(
            'GST:',
            '₹${detailMenuController.menuGstTotal().toStringAsFixed(2)}',
          ),
          _buildPriceRow('Shipping:', '₹0.00'),
          // if (_order.cess > 0)
          //   _buildPriceRow('Cess:', '₹${_order.cess.toStringAsFixed(2)}'),
          const Divider(thickness: 1),
          // _buildPriceRow(
          //   'Total Amount:',
          //   '₹${menuDetail.finalAmount.toStringAsFixed(2)}',
          //   isTotal: true,
          // ),
          _buildPriceRow(
            'Total Amount:',
            '₹${detailMenuController.menuFinalTotal().toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    ),
  );
}

Widget _buildPriceRow(
  String label,
  String amount, {
  bool isTotal = false,
  bool isDiscount = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isDiscount
                ? Colors.green
                : isTotal
                ? Colors.orange.shade700
                : Colors.grey[700],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDeliveryInfo(menuDetail) {
  return Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "Delivery Information".text
              .size(16)
              .fontWeight(FontWeight.w500)
              .make(),

          12.heightBox,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.orange.shade700, size: 20),
              8.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Shipping Address".text.size(12).color(Colors.grey).make(),
                    4.heightBox,
                    (menuDetail.shipAddress ?? "").toString().isNotEmpty
                        ? (menuDetail.shipAddress ?? "")
                              .toString()
                              .text
                              .size(14)
                              .make()
                        : "Not specified".text
                              .size(14)
                              .color(Colors.grey[500])
                              .make(),
                  ],
                ),
              ),
            ],
          ),
          12.heightBox,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.orange.shade700, size: 20),
              8.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Billing Address".text.size(12).color(Colors.grey).make(),
                    4.heightBox,
                    (menuDetail.billAddress).toString().isNotEmpty
                        ? (menuDetail.billAddress)
                              .toString()
                              .text
                              .size(14)
                              .make()
                        : "Not specified".text
                              .size(14)
                              .color(Colors.grey[500])
                              .make(),
                  ],
                ),
              ),
            ],
          ),
          12.heightBox,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.note, color: Colors.orange.shade700, size: 20),
              8.widthBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Menu notes".text.size(12).color(Colors.grey).make(),
                    4.heightBox,
                    (menuDetail.notesMenu).toString().isNotEmpty
                        ? (menuDetail.notesMenu).toString().text.size(14).make()
                        : "Not specified".text
                              .size(14)
                              .color(Colors.grey[500])
                              .make(),
                  ],
                ),
              ),
            ],
          ),

          // 12.heightBox,

          // Row(
          //   children: [
          //     Icon(Icons.payment, color: Colors.orange.shade700, size: 20),
          //     8.widthBox,
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           "Payment Method".text.size(12).color(Colors.grey).make(),
          //           4.heightBox,
          //           "${menuDetail.paymentMethod} (${menuDetail.paymentStatus})"
          //               .text
          //               .size(14)
          //               .make(),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
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

Widget _dropdownConst() {
  final JmPaymentController jmPaymentController =
      Get.find<JmPaymentController>();
  return Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          "Payment Method".text.size(18).fontWeight(FontWeight.w400).make(),
          12.heightBox,
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Obx(() {
                return DropdownButton<String>(
                  value: jmPaymentController.selectedPayment.value,
                  isExpanded: true,
                  underline: const SizedBox(),

                  items: jmPaymentController.paymentOptions.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                    );
                  }).toList(),

                  onChanged: (val) {
                    if (val != null) {
                      jmPaymentController.selectedPayment.value = val;
                    }
                  },
                );
              }),
            ),
          ),
        ],
      ),
    ),
  );
}
