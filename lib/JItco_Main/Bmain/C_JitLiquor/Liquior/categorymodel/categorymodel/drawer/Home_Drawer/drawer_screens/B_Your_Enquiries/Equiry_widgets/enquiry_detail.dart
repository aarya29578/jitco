import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

Widget _textHead({String? enquiryHead}) {
  return Text(
    enquiryHead!,
    style: TextStyle(color: Colors.grey[500], fontSize: 14),
  );
}

void showProductDetails(BuildContext context, enquiry, getDate) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Enquiry Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Navigator.pop(context);
                          Get.back();
                        },
                        icon: Icon(Icons.cancel, size: 25),
                      ),
                    ],
                  ),
                  // Price or any other details
                  Text(
                    "$getDate at ${enquiry.formattedDate}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textHead(enquiryHead: 'Product Name:'),
                            // Description
                            Flexible(
                              child: Text(
                                enquiry.productName,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            10.heightBox,
                            Row(
                              children: [
                                _textHead(enquiryHead: 'Quantity:'),
                                5.widthBox,
                                Text(
                                  enquiry.productQuantity.toString(),
                                  style: TextStyle(fontSize: 16),
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
              SizedBox(height: 20),

              if (enquiry.comment?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textHead(enquiryHead: 'Comment:'),
                    3.heightBox,
                    Text(
                      '${enquiry.comment}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    15.heightBox,
                  ],
                ),
              // Close Button
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () => Navigator.pop(context),
              //     child: Text("Close"),
              //   ),
              // ),
            ],
          ),
        ),
      );
    },
  );
}
