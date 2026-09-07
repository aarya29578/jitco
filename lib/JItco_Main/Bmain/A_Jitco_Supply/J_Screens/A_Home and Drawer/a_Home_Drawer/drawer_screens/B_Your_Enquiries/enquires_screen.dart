import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/enquiry_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/B_Your_Enquiries/Equiry_widgets/enquiry_detail.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:velocity_x/velocity_x.dart';

class EnquiresScreen extends StatefulWidget {
  const EnquiresScreen({super.key});

  @override
  State<EnquiresScreen> createState() => _EnquiresScreenState();
}

class _EnquiresScreenState extends State<EnquiresScreen> {
  final EnquiryController enquiryController = Get.find<EnquiryController>();

  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      enquiryController.refreshEnquiries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Enquires'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: enquiryController.refreshEnquiries,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          child: Obx(() {
            if (enquiryController.isLoading.value &&
                enquiryController.enquiryItems.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            if (enquiryController.hasError.value &&
                enquiryController.enquiryItems.isEmpty) {
              return _errorWidget();
            }

            if (enquiryController.enquiryItems.isEmpty) {
              return _noEquires();
            }

            return RefreshIndicator(
              onRefresh: enquiryController.refreshEnquiries,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: _buildEnquiryList(),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEnquiryList() {
    final groupedEnquiries = enquiryController.getEnquiriesByDate();
    final dates = groupedEnquiries.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort dates descending

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final date in dates) ...[
          Text(
            date,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          10.heightBox,
          _listEnquiryProducts(groupedEnquiries[date]!, date),
          20.heightBox,
        ],
        if (enquiryController.isLoading.value &&
            enquiryController.enquiryItems.isNotEmpty)
          Center(child: CircularProgressIndicator()),
        if (enquiryController.hasMore.value)
          Center(
            child: TextButton(
              onPressed: enquiryController.loadMoreEnquiries,
              child: Text('Load More'),
            ),
          ),
      ],
    );
  }

  Widget _listEnquiryProducts(List<EnquiryModel> enquiries, getDate) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: enquiries.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final enquiry = enquiries[index];
        return Card(
          elevation: 1,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  highlightColor: Colors.grey[200],
                  focusColor: Colors.grey[100],
                  onTap: () {
                    showProductDetails(context, enquiry, getDate);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: enquiry.productImage?.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  enquiry.productImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      10.widthBox,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            7.heightBox,
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 155,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      enquiry.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      enquiry.formattedDate,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            2.heightBox,
                            Row(
                              children: [
                                Text(
                                  'Qty: ${enquiry.productQuantity}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                20.widthBox,
                                Text(
                                  enquiry.productStatus.isEmpty
                                      ? 'Pending'
                                      : enquiry.productStatus,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _getStatusColor(
                                      enquiry.productStatus,
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
                ),
              ),
              if (enquiry.isClosed || enquiry.hasStockAvailable)
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: Column(
                    children: [
                      if (enquiry.comment?.isNotEmpty == true)
                        Column(
                          children: [
                            Text(
                              '${enquiry.comment}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            15.heightBox,
                          ],
                        ),
                    ],
                  ),
                ),
              // Show actions if stock is available
              if (enquiry.hasStockAvailable)
                if (enquiry.productPrice > 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 3,
                      bottom: 7,
                    ),
                    child: Column(
                      children: [
                        // if (enquiry.comment?.isNotEmpty == true)
                        //   Column(
                        //     children: [
                        //       Text(
                        //         '${enquiry.comment}',
                        //         style: TextStyle(color: Colors.grey[600]),
                        //       ),
                        //       15.heightBox,
                        //     ],
                        //   ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (enquiry.productPrice > 0)
                              Text(
                                '₹${enquiry.productPrice}',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            // ElevatedButton(
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.orange.shade700,
                            //     foregroundColor: Colors.white,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadiusGeometry.circular(
                            //         8,
                            //       ),
                            //     ),
                            //   ),
                            //   onPressed: () {
                            //     // Navigate to add to cart or contract section
                            //     _addToCartFromEnquiry(enquiry);
                            //   },
                            //   child: Text('Add to Cart'),
                            // ),
                            Container(
                              decoration: BoxDecoration(
                                // color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: SizedBox(
                                height: 40,
                                width: 110,
                                child: Obx(() {
                                  final cartController =
                                      Get.find<CartController>();
                                  final isInCart = cartController.cartItems.any(
                                    (item) => item.id == enquiry.productId,
                                  );

                                  return ElevatedButton(
                                    onPressed: () {
                                      if (isInCart) {
                                        cartController.removeFromCart(
                                          enquiry.productId,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${enquiry.productName} removed from cart',
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        _addToCart(
                                          enquiry.productId,
                                          enquiry.productName,
                                          enquiry.productImage,
                                          enquiry.productPrice.toString(),
                                          enquiry.productGst.toString(),
                                          enquiry.slug,
                                        );
                                        print(
                                          'enquiry???????????????????????????**************************: ${enquiry.slug}',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: isInCart
                                          ? Colors.red
                                          : Colors.orange.shade700,
                                      padding: EdgeInsets.all(4),
                                    ),
                                    child: Text(
                                      isInCart ? 'Remove' : 'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    // constraints: BoxConstraints(),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'stock availability':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'converted to order':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  // void _addToCartFromEnquiry(EnquiryModel enquiry) {
  //   // Implement add to cart logic here
  //   // Get.snackbar(
  //   //   'Coming Soon',
  //   //   'Add to cart functionality for enquiries',
  //   //   snackPosition: SnackPosition.BOTTOM,
  //   // );
  //   _addToCart(
  //     enquiry.productId,
  //     enquiry.productName,
  //     enquiry.productImage,
  //     enquiry.productPrice.toString(),
  //     enquiry.productGst.toString(),
  //   );
  // }

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

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 20),
          Text('Error loading enquiries', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text(
            enquiryController.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: enquiryController.refreshEnquiries,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _noEquires() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_very_dissatisfied,
              size: 90,
              color: Colors.grey,
            ),
            10.heightBox,
            const Text('No enquires found', style: TextStyle(fontSize: 18)),
            5.heightBox,
            const Text(
              'You Dont have any enquires yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            15.heightBox,
            ElevatedButton(
              onPressed: enquiryController.refreshEnquiries,
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
