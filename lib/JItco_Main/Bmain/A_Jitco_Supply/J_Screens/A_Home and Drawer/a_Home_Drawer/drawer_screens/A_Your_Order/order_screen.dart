import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/order_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/A_Your_Order/order_detail_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  all,
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.all:
        return "All Orders";
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
      case OrderStatus.returned:
        return "Returned";
    }
  }

  String get apiStatus {
    switch (this) {
      case OrderStatus.all:
        return 'All';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return "Returned";
    }
  }

  static OrderStatus? fromString(String? status) {
    if (status == null) return OrderStatus.all;
    final statusLower = status.toLowerCase();

    // Map API status to enum
    if (statusLower == 'processing' || statusLower == 'pending') {
      return OrderStatus.pending;
    }
    if (statusLower == 'all') return OrderStatus.all;

    for (var value in OrderStatus.values) {
      if (value.name == statusLower) {
        return value;
      }
    }
    return OrderStatus.all;
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderController orderController = Get.find<OrderController>();
  OrderStatus? selectedStatus = OrderStatus.all;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.loadOrders();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!orderController.isLoading.value &&
          orderController.currentPage.value <
              orderController.totalPages.value) {
        orderController.loadMoreOrders();
      }
    }
  }

  List<Order> get filteredOrders {
    if (selectedStatus == OrderStatus.all) {
      return orderController.orders;
    }

    return orderController.orders.where((order) {
      final orderStatus = order.status.toLowerCase();
      final selectedStatusName = selectedStatus!.name;

      // Handle API status mapping
      if (selectedStatusName == 'pending' && orderStatus == 'processing') {
        return true;
      }
      return orderStatus == selectedStatusName;
    }).toList();
  }

  void _applyFilter(OrderStatus status) {
    setState(() {
      selectedStatus = status;
    });

    // Map OrderStatus to API status string
    String statusString = status == OrderStatus.all ? 'All' : status.apiStatus;

    orderController.changeStatus(statusString);
  }

  void _showBottomSheetFilter() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    "Filter Orders".text
                        .size(20)
                        .fontWeight(FontWeight.bold)
                        .make(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300]),
                10.heightBox,
                "Order Status".text.size(16).fontWeight(FontWeight.w500).make(),
                10.heightBox,
                ...OrderStatus.values.map((status) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Radio<OrderStatus>(
                      value: status,
                      groupValue: selectedStatus,
                      onChanged: (OrderStatus? value) {
                        if (value != null) {
                          _applyFilter(value);
                          Navigator.pop(context);
                        }
                      },
                      activeColor: Colors.orange.shade700,
                    ),
                    title: Text(status.label),
                    onTap: () {
                      _applyFilter(status);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(
    String productId,
    String productName,
    productImage,
    String productPrice,
    String productGst,
    String productSlug,
    // dynamic product,
  ) {
    final CartController cartController = Get.find<CartController>();

    final cartItem = CartItem(
      id: productId,
      name: productName,
      image: productImage,
      price: double.tryParse(productPrice) ?? 0.0,
      gstPercentage: double.tryParse(productGst) ?? 0.0,
      quantity: 1,
      categorySlug: productSlug,
      selectedVariant: '1 pc.', // Default variant
    );

    cartController.addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName added to cart'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: "My Orders".text.color(Colors.black87).make(),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          // // Refresh button
          // IconButton(
          //   onPressed: () => orderController.refreshOrders(),
          //   icon: Obx(
          //     () => Icon(
          //       Icons.refresh,
          //       color: orderController.isLoading.value
          //           ? Colors.grey
          //           : Colors.orange.shade700,
          //     ),
          //   ),
          // ),
          // Filter button
          InkWell(
            onTap: _showBottomSheetFilter,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  6.widthBox,
                  Text(
                    selectedStatus!.label,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  4.widthBox,
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          10.widthBox,
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final orders = filteredOrders;
          final isLoading = orderController.isLoading.value;
          final hasMore =
              orderController.currentPage.value <
              orderController.totalPages.value;

          if (isLoading && orders.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: Colors.orange.shade700),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderController.refreshOrders(),
            color: Colors.orange.shade700,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filter indicator
                if (selectedStatus != OrderStatus.all)
                  SliverToBoxAdapter(
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_alt,
                                    color: Colors.orange.shade700,
                                    size: 18,
                                  ),
                                  8.widthBox,
                                  "Filtered by: ${selectedStatus!.label}".text
                                      .size(14)
                                      .color(Colors.grey[700])
                                      .make(),
                                  8.widthBox,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: "${orders.length} orders".text
                                        .size(12)
                                        .color(Colors.orange.shade800)
                                        .make(),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _applyFilter(OrderStatus.all);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                    size: 18,
                                  ),
                                  4.widthBox,
                                  "Clear".text
                                      .color(Colors.orange.shade700)
                                      .make(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Orders list or empty state
                if (orders.isEmpty)
                  SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        20.heightBox,
                        "No Orders Found".text
                            .size(18)
                            .color(Colors.grey[600])
                            .make(),
                        10.heightBox,
                        if (selectedStatus != OrderStatus.all)
                          "No ${selectedStatus!.label.toLowerCase()} orders"
                              .text
                              .color(Colors.grey[500])
                              .make()
                        else
                          "Your orders will appear here".text
                              .color(Colors.grey[500])
                              .make(),
                        20.heightBox,
                        if (selectedStatus != OrderStatus.all)
                          OutlinedButton(
                            onPressed: () {
                              _applyFilter(OrderStatus.all);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.orange.shade700),
                            ),
                            child: "View All Orders".text
                                .color(Colors.orange.shade700)
                                .make(),
                          ),
                        20.heightBox,
                        ElevatedButton(
                          onPressed: () => orderController.refreshOrders(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                          ),
                          child: "Refresh".text.white.make(),
                        ),
                      ],
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == orders.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.orange.shade700,
                                  )
                                : Container(),
                          ),
                        );
                      }
                      final order = orders[index];
                      return _buildOrderCard(order);
                    }, childCount: orders.length + (hasMore ? 1 : 0)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: "Order #${order.orderNumber}".text
                          .size(20)
                          .overflow(TextOverflow.ellipsis)
                          .maxLines(1)
                          .fontWeight(FontWeight.w600)
                          .make(),
                    ),
                    4.heightBox,
                    order.formattedDate.text
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
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: order.status.toUpperCase().text.size(10).white.make(),
                ),
              ],
            ),

            12.heightBox,
            const Divider(color: Colors.grey),

            // Order items preview (show first 2 items)
            if (order.items.isNotEmpty) ...[
              ...order.items
                  .take(2)
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
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
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
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
                            : Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                      ),
                      title: item.productName!.text.size(14).make(),
                      subtitle: "Qty: ${item.quantity}".text
                          .size(12)
                          .color(Colors.grey)
                          .make(),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          "₹${item.total!.toStringAsFixed(2)}".text
                              .size(14)
                              .fontWeight(FontWeight.w500)
                              .make(),
                          1.heightBox,
                          "(GST: ₹${item.gstTotal!.toStringAsFixed(2)})".text
                              .size(12)
                              .color(Colors.orange.shade700)
                              .make(),
                        ],
                      ),
                    ),
                  )
                  .toList(),

              // Show "more items" indicator
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: "+${order.items.length - 2} more items".text
                      .size(12)
                      .color(Colors.orange.shade700)
                      .make(),
                ),

              12.heightBox,
              const Divider(color: Colors.grey),
            ],

            // Order summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Total Items: ${order.totalItemsCount}".text
                        .size(12)
                        .color(Colors.grey[600])
                        .make(),
                    "Payment: ${order.paymentStatus}".text
                        .size(12)
                        .color(Colors.grey[600])
                        .make(),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    order.formattedTotal.text
                        .size(18)
                        .fontWeight(FontWeight.w600)
                        .color(Colors.orange.shade700)
                        .make(),
                    "Total: ₹${order.totalAmount.toStringAsFixed(2)} + Tax: ₹${(order.gst + order.cess).toStringAsFixed(2)}"
                        .text
                        .size(10)
                        .color(Colors.grey[600])
                        .make(),
                  ],
                ),
              ],
            ),

            12.heightBox,
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(
                          () => OrderDetailScreen(
                            orderId: order.id,
                            whichSource: 'JitSupply',
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange.shade700),
                      ),
                      child: "View Details".text
                          .color(Colors.orange.shade700)
                          .make(),
                    ),
                  ),
                ),
                // 12.widthBox,
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       _reorder(order);
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.orange.shade700,
                //     ),
                //     child: "Add to Cart".text.white.make(),
                //   ),
                // ),

                // Container(
                //   decoration: BoxDecoration(
                //     // color: Colors.deepOrangeAccent,
                //     borderRadius: BorderRadius.circular(1),
                //   ),
                //   child: SizedBox(
                //     height: 40,
                //     width: 110,
                //     child: Obx(() {
                //       final cartController = Get.find<CartController>();
                //       final isInCart = cartController.cartItems.any(
                //         (item) => item.id == order.i,
                //       );
                //       return ElevatedButton(
                //         onPressed: () {
                //           if (isInCart) {
                //             cartController.removeFromCart(enquiry.productId);
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               SnackBar(
                //                 content: Text(
                //                   '${enquiry.productName} removed from cart',
                //                 ),
                //                 backgroundColor: Colors.red,
                //                 duration: Duration(seconds: 2),
                //               ),
                //             );
                //           } else {
                //             _addToCart(
                //               enquiry.productId,
                //               enquiry.productName,
                //               enquiry.productImage,
                //               enquiry.productPrice.toString(),
                //               enquiry.productGst.toString(),
                //               enquiry.slug,
                //             );
                //             print(
                //               'enquiry???????????????????????????**************************: ${enquiry.slug}',
                //             );
                //           }
                //         },
                //         style: ElevatedButton.styleFrom(
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           backgroundColor: isInCart
                //               ? Colors.red
                //               : Colors.orange.shade700,
                //           padding: EdgeInsets.all(4),
                //         ),
                //         child: Text(
                //           isInCart ? 'Remove' : 'Add to Cart',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontWeight: FontWeight.w700,
                //           ),
                //         ),
                //         // constraints: BoxConstraints(),
                //       );
                //     }),
                //   ),
                // ),
              ],
            ),
          ],
        ),
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

  void _reorder(Order order) {
    // TODO: Implement reorder logic
    Get.snackbar(
      'Reorder',
      'Adding ${order.totalItemsCount} items to cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
