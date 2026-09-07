import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_quotation_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/C_JS_Quotations/Download_Service/generate_quotation_pdf.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_detail_quotation_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_quatation_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/Js_cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/enums.dart';
import 'package:velocity_x/velocity_x.dart';

class JsDetailQuotation extends StatefulWidget {
  final String? quoteId;
  const JsDetailQuotation({super.key, this.quoteId});

  @override
  State<JsDetailQuotation> createState() => _JsDetailQuotationState();
}

class _JsDetailQuotationState extends State<JsDetailQuotation> {
  final JsQuotationController _jsQuotationController =
      Get.find<JsQuotationController>();
  final JsCartcontroller cartcontroller = Get.find<JsCartcontroller>();

  @override
  void initState() {
    super.initState();
    _jsQuotationController.getDetailQuotation(widget.quoteId);
  }

  void _showBasicDialog(BuildContext context, VoidCallback onPress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20),
          ),
          title: const Text('Download PDF'),
          content: const Text('Would you want download this quotation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPress();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _handleAddRemoveCart({
    String? productId,
    String? productName,
    productImage,
    dynamic productPrice,
    double? gstPercentage,
    int? quantity,
    String? productSlug,
    String? variant,
  }) {
    // final prices = widget.product?.prices;
    // final selectedPrice = prices!.isNotEmpty
    //     ? prices[selectedIndex].price.toDouble()
    //     : 0.0;

    // final variant = prices.isNotEmpty ? prices[selectedIndex].size : 'Default';

    // double gstPercentage = double.tryParse(_getProductGST()) ?? 0.0;

    final cartItem = JsCartitem(
      id: productId ?? '',
      name: productName ?? '',
      image: productImage ?? '',
      price: productPrice ?? 0.0,
      gstPercentage: gstPercentage,
      quantity: quantity ?? 1,
      categorySlug: productSlug,
      selectedVariant: variant,
    );

    // if (cartController.cartItems.any((item) => item.id == cartItem.id)) {
    //   cartController.removeFromCart(cartItem.id, variant);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${cartItem.name} removed'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // } else {
    //   cartController.addToCart(cartItem);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('${cartItem.name} added'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // }

    final exists = cartcontroller.cartItems.any(
      (item) => item.id == cartItem.id && item.selectedVariant == variant,
    );

    if (exists) {
      cartcontroller.removeFromCart(cartItem.id, variant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} removed'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      cartcontroller.addToCart(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.name} added'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quotation Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_jsQuotationController.jsDetailQuotationLoading.value ==
              PageState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
                strokeWidth: 3,
              ),
            );
          }

          if (_jsQuotationController.jsDetailQuotationLoading.value ==
              PageState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Something went wrong",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Unable to load quotation details",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _jsQuotationController.getDetailQuotation(widget.quoteId);
                    },
                    label: const Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          final detailQuotation =
              _jsQuotationController.jsDetailQuotationData.value.quote;

          if (detailQuotation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No Quotation Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The requested quotation details are not available",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _jsQuotationController.getDetailQuotation(widget.quoteId);
                    },
                    label: const Text("Refresh"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade700, Colors.orange.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Quote Number Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            detailQuotation.qNum ?? 'Quote Number',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Expiry Date
                        if (detailQuotation.qExpireDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.event_available_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Expires on: ${DateFormat('dd MMM yyyy').format(detailQuotation.qExpireDate!)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              label: "Grand Total",
                              value:
                                  "${_formatPrice(detailQuotation.qItems?.first.total ?? 0)}",
                              icon: Icons.currency_rupee,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildStatCard(
                              label: "Total Items",
                              value: (detailQuotation.qQuantity ?? 0)
                                  .toString(),
                              icon: Icons.shopping_bag_outlined,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _buildStatCard(
                              label: "Tax Rate",
                              value: "${detailQuotation.qTaxRate ?? 0} %",
                              icon: null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Items Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: detailQuotation.qItems == null
                          ? _buildEmptyState()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.orange.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Items in this Quotation",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: detailQuotation.qItems!.length,
                                  itemBuilder: (context, index) {
                                    final item = detailQuotation.qItems?[index];
                                    return _buildOrderItem(
                                      item!,
                                      index,
                                      detailQuotation.qItems!.length,
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Price Breakdown Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _buildPriceBreakdown(detailQuotation),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final product = detailQuotation.qItems?.first.product;

                          final exists = cartcontroller.cartItems.any(
                            (item) =>
                                item.id == product?.id &&
                                item.selectedVariant == product?.uom,
                          );
                          return OutlinedButton.icon(
                            onPressed: () {
                              final product =
                                  detailQuotation.qItems?.first.product;
                              final gstPercent = detailQuotation.qTaxRate ?? 0;
                              int quantity = detailQuotation.qQuantity ?? 1;
                              double price =
                                  detailQuotation.qItems?.first.price ?? 0;
                              double gstTotal =
                                  detailQuotation.qItems?.first.gstTotal ?? 0;
                              double grandTotal =
                                  detailQuotation.qItems?.first.total ?? 0;

                              print('priceQuatation: $price');
                              // Add share functionality
                              _handleAddRemoveCart(
                                productId: product?.id ?? '',
                                productName: product?.productName ?? '',
                                productImage:
                                    product?.productImage?.first ?? '',
                                quantity: quantity,
                                gstPercentage: gstPercent.toDouble(),
                                productPrice: price,
                                productSlug: product?.slug,
                                variant: product?.uom ?? "Basic",
                              );

                              if (exists == false) {
                                Get.find<JsBottomNavController>().switchTab(4);

                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final navigator = Navigator.of(context);

                                  if (navigator.canPop()) {
                                    navigator.pop(); // quotation detail
                                  }
                                  if (navigator.canPop()) {
                                    navigator.pop(); // back to quotation list
                                  }
                                });
                              }

                              // final messenger = ScaffoldMessenger.of(context);
                              // messenger
                              //     .hideCurrentSnackBar(); // closes current snackbar
                              // messenger.showSnackBar(
                              //   SnackBar(
                              //     content: Text(
                              //       "This product is added to your cart",
                              //     ),
                              //     backgroundColor: Colors.red,
                              //   ),
                              // );
                              // ScaffoldMessenger.of(context)
                              //   ..hideCurrentSnackBar()
                              //   ..showSnackBar(
                              //     SnackBar(
                              //       content: Text(
                              //         "This product is added to your cart",
                              //       ),
                              //       backgroundColor: Colors.green,
                              //     ),
                              //   );
                            },
                            icon: const Icon(Icons.trolley, size: 18),
                            label: Text(
                              exists ? "Remove from Cart" : "Covert to Order",
                            ),
                            // label: const Text(
                            //   exists ? "Remove from Cart" : "Covert to Order",
                            // ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: exists
                                  ? Colors.white
                                  : Colors.white,
                              backgroundColor: exists
                                  ? Colors.red
                                  : Colors.orange.shade700,
                              side: BorderSide(color: Colors.white, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showBasicDialog(context, () {
                              // Add download functionality
                              final detailQuotation = _jsQuotationController
                                  .jsDetailQuotationData
                                  .value
                                  .quote;

                              generateQuotationPdf(context, detailQuotation);
                            });
                          },
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text("Download PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to format price
  String _formatPrice(num price) {
    return price.toStringAsFixed(2);
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData? icon,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 1),
            ],
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "No items found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "This quotation has no items added",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildOrderItem(QuoteItems item, int index, int totalLength) {
    final product = item.product;

    final exists = cartcontroller.cartItems.any((e) => e.id == product?.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      product?.productImage != null &&
                          product!.productImage!.isNotEmpty
                      ? Image.network(
                          product.productImage!.first,
                          // fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 30,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.productName ?? "Product name not found",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Quantity and Price Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // const Icon(
                          //   Icons.format_list_numbered,
                          //   size: 14,
                          //   color: Colors.blue,
                          // ),
                          // const SizedBox(width: 4),
                          Text(
                            "Qty: ${item.quantity ?? 0}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Price and GST Row
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "₹${(item.price ?? 0).toStringAsFixed(2)}/per",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "GST: ${item.gst ?? 0}%",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Total Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade100, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Item Total:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      "₹${(item.total ?? 0).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Includes ₹${(item.gstTotal ?? 0).toStringAsFixed(2)} GST",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          if (index < totalLength - 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(
                color: Colors.grey.shade200,
                thickness: 1,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(detailQuotation) {
    int quantity = detailQuotation.qQuantity;
    double subtotal = detailQuotation.qItems?.first.priceTotal ?? 0;
    double gstTotal = detailQuotation.qItems?.first.gstTotal ?? 0;
    double grandTotal = detailQuotation.qItems?.first.total ?? 0;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_outlined,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Order Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Qty:', '${quantity}'),
                  const SizedBox(height: 12),
                  _buildPriceRow(
                    'Subtotal:',
                    '₹${subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow('GST:', '₹${gstTotal.toStringAsFixed(2)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(thickness: 1),
                  ),
                  _buildPriceRow(
                    'Grand Total',
                    '₹${grandTotal.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
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
                : Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 15,
          ),
        ),
      ],
    );
  }
}
