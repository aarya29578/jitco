import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Screens/a_JM_Home/JM_Drawer/JM_Drawer_Screens/a_JM_Your_Order/Download_Service/generateJMOrderPDF.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

class JmOrderDetailScreen extends StatefulWidget {
  final String orderId; // Now accepting orderId instead of Order object
  final Order? initialOrder; // Optional initial data for immediate display

  const JmOrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<JmOrderDetailScreen> createState() => _JmOrderDetailScreenState();
}

class _JmOrderDetailScreenState extends State<JmOrderDetailScreen> {
  final ApiServices _apiService = Get.find<ApiServices>();
  late Order _order;
  late OrderProgress _progress;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Use initial data if provided, otherwise use empty order
    _order = widget.initialOrder ?? _createEmptyOrder();

    // Fetch fresh data
    _fetchOrderDetails();
  }

  Order _createEmptyOrder() {
    return Order(
      id: widget.orderId,
      orderNumber: 'Loading...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'Loading',
      items: [],
      totalAmount: 0,
      discount: 0,
      gst: 0,
      cess: 0,
      finalAmount: 0,
      paymentStatus: 'Loading',
      paymentMethod: '',
      billingAddress: '',
      shippingAddress: '',
    );
  }

  Future<void> _fetchOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final response = await _apiService.getOrderDetail(
        orderId: widget.orderId,
        source: "JitMenu",
      );

      if (response['success'] == true && response['order'] != null) {
        final orderData = response['order'] as Map<String, dynamic>;
        setState(() {
          _order = Order.fromJson(orderData);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to load order details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshOrder() async {
    await _fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: "Order Details".text.color(Colors.black87).make(),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showBasicDialog(context, () {
                generateJmOrderPdf(context, _order, "JitMenu");
              });
            },
            icon: Icon(
              Icons.download_outlined,
              color: _isLoading ? Colors.grey : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && widget.initialOrder == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.orange.shade700),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            20.heightBox,
            "Failed to load order".text.size(16).color(Colors.grey[700]).make(),
            10.heightBox,
            _errorMessage.text.size(14).color(Colors.grey[500]).make(),
            20.heightBox,
            ElevatedButton(
              onPressed: _fetchOrderDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
              ),
              child: "Retry".text.white.make(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshOrder,
      color: Colors.orange.shade700,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show loading overlay if still loading with initial data
              if (_isLoading && widget.initialOrder != null)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: Colors.orange.shade700,
                  ),
                ),

              // Order Info Card
              Card(
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
                                child: "Order #${_order.orderNumber}".text
                                    .size(15)
                                    .fontWeight(FontWeight.w600)
                                    .make(),
                              ),
                              4.heightBox,
                              "Date: ${_order.formattedDate}".text
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
                              color: _getStatusColor(_order.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _order.status
                                .toUpperCase()
                                .text
                                .size(12)
                                .white
                                .make(),
                          ),
                        ],
                      ),
                      8.heightBox,
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          4.widthBox,
                          "${_order.paymentStatus} - ${_order.paymentMethod}"
                              .text
                              .size(12)
                              .color(Colors.grey[600])
                              .make(),
                        ],
                      ),
                      if (_order.comment != null &&
                          _order.comment!.isNotEmpty) ...[
                        20.heightBox,
                        const Text(
                          'Order Status Information:',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        3.heightBox,
                        // Container(child: Text(_progress.comments ?? '')),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.shade500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _order.comment ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children:
                          //   _order.progress!
                          //       .map(
                          //         (p) => Text(
                          //           p.comments ?? '',
                          //           style: const TextStyle(
                          //             fontSize: 13,
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.w400,
                          //           ),
                          //         ),
                          //       )
                          //       .toList(),
                          // ),
                        ),
                        20.heightBox,
                        const Text(
                          'Order Placed On:',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.shade500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _order.formattedDateUpdate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: _order.progress!
                          //       .map(
                          //         (p) => Text(
                          //           _order.progress?[0].formattedDate ??
                          //               '',
                          //           style: const TextStyle(
                          //             fontSize: 13,
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.w400,
                          //           ),
                          //         ),
                          //       )
                          //       .toList(),
                          // ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              16.heightBox,

              // Delivery Info
              _buildDeliveryInfo(),

              16.heightBox,

              // Items List
              "Order Items (${_order.totalItemsCount})".text
                  .size(16)
                  .fontWeight(FontWeight.w500)
                  .make(),

              12.heightBox,

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: _order.items.isEmpty
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
                          itemCount: _order.items.length,
                          itemBuilder: (context, index) {
                            final item = _order.items[index];
                            return _buildOrderItem(item, index);
                          },
                        ),
                ),
              ),

              16.heightBox,

              // Payment Information
              _buildPaymentInfo(),

              16.heightBox,

              // Price Breakdown
              _buildPriceBreakdown(),

              16.heightBox,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, int index) {
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
                child: item.productImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
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
                    item.productName!.text
                        .size(14)
                        .fontWeight(FontWeight.w500)
                        .make()
                        .onTap(() {
                          if (item.productSlug!.isNotEmpty) {
                            Get.to(
                              () => DetailProductScreen(
                                productSlug: item.productSlug!,
                              ),
                            );
                          }
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
                        "GST: ${item.gst}%".text
                            .size(12)
                            .color(Colors.grey[600])
                            .make(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          20.heightBox,
          // if (index < _order.items.length - 1) 20.heightBox,

          // Price Column
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "₹${item.total!.toStringAsFixed(2)}".text
                  .size(16)
                  .fontWeight(FontWeight.w600)
                  .color(Colors.orange.shade700)
                  .make(),
              2.heightBox,
              "₹${item.priceTotal!.toStringAsFixed(2)} + ₹${item.gstTotal!.toStringAsFixed(2)} GST"
                  .text
                  .size(10)
                  .color(Colors.grey[600])
                  .make(),
            ],
          ),
          if (index < _order.items.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(color: Colors.grey[300]),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Order Summary".text.size(16).fontWeight(FontWeight.w500).make(),

            12.heightBox,

            _buildPriceRow(
              'Subtotal:',
              '₹${_order.totalAmount.toStringAsFixed(2)}',
            ),
            if (_order.discount > 0)
              _buildPriceRow(
                'Discount:',
                '- ₹${_order.discount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            _buildPriceRow('GST:', '₹${_order.gst.toStringAsFixed(2)}'),
            _buildPriceRow('Shipping:', '₹0.00'),
            // if (_order.cess > 0)
            //   _buildPriceRow('Cess:', '₹${_order.cess.toStringAsFixed(2)}'),
            const Divider(thickness: 1),
            _buildPriceRow(
              'Total Amount:',
              '₹${_order.finalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
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
                Icon(
                  Icons.location_on,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                8.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Shipping Address".text
                          .size(12)
                          .color(Colors.grey)
                          .make(),
                      4.heightBox,
                      _order.shippingAddress.isNotEmpty
                          ? _order.shippingAddress.text.size(14).make()
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
                Icon(
                  Icons.location_on,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                8.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Billing Address".text.size(12).color(Colors.grey).make(),
                      4.heightBox,
                      _order.billingAddress.isNotEmpty
                          ? _order.billingAddress.text.size(14).make()
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
              children: [
                Icon(Icons.payment, color: Colors.orange.shade700, size: 20),
                8.widthBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "Payment Method".text.size(12).color(Colors.grey).make(),
                      4.heightBox,
                      "${_order.paymentMethod} (${_order.paymentStatus})".text
                          .size(14)
                          .make(),
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

  Widget _buildPaymentInfo() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Payment Information'.text
                .size(16)
                .fontWeight(FontWeight.w500)
                .make(),
            12.heightBox,
            if (_order.notes.isNotEmpty) ...[
              'Notes:'.text.fontWeight(FontWeight.w500).make(),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(_order.notes),
              ),
              7.heightBox,
            ],
            'Status:'.text.fontWeight(FontWeight.w500).make(),
            5.heightBox,
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(_order.paymentStatus),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _order.paymentStatus.text.make(),
                ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.yellow.shade100;
      case 'failed':
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
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
}
