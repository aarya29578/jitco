import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_quotation_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/C_JS_Quotations/JS_detail_quotation.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/enums.dart';
import 'package:velocity_x/velocity_x.dart';

class JsQuotation extends StatefulWidget {
  const JsQuotation({super.key});

  @override
  State<JsQuotation> createState() => _JsQuotationState();
}

class _JsQuotationState extends State<JsQuotation> {
  final JsQuotationController _jsQuotationController = Get.put(
    JsQuotationController(),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _jsQuotationController.getAllQuotation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation'),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _jsQuotationController.getAllQuotation();
            },
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _jsQuotationController.getAllQuotation(),
          child: Obx(() {
            if (_jsQuotationController.jsQuotationLoading.value ==
                PageState.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              );
            }

            if (_jsQuotationController.jsQuotationLoading.value ==
                PageState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Something went wrong"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _jsQuotationController.getAllQuotation();
                      },
                      label: const Text("Try again"),
                    ),
                  ],
                ),
              );
            }

            final quotationList =
                _jsQuotationController.jsQuotationData.value.quote ?? [];

            if (quotationList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("No Quotations found!"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _jsQuotationController.getAllQuotation();
                      },
                      label: const Text("Refresh"),
                    ),
                  ],
                ),
              );
            }

            // return ListView.builder(
            //   padding: const EdgeInsets.all(10),
            //   itemCount: quotationList.length,
            //   itemBuilder: (context, index) {
            //     final quote = quotationList[index];
            //     return Card(
            //       color: Colors.white,
            //       child: Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             // Text(quote.qItems?[index].product?.productName ?? ''),
            //             Container(
            //               padding: const EdgeInsets.symmetric(
            //                 horizontal: 10,
            //                 vertical: 5,
            //               ),
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(20),
            //                 color: Colors.orange.shade400,
            //               ),
            //               child: Text(quote.qNum ?? 'Number not found!'),
            //             ),
            //             Text(
            //               quote.qItems != null && quote.qItems!.isNotEmpty
            //                   ? quote.qItems!.first.product?.productName ?? ''
            //                   : '',
            //             ),
            //             const SizedBox(height: 20),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Qty: ${quote.qQuantity ?? 0}'),
            //                 Text('Amount: ₹${quote.qPrice ?? 0}'),
            //                 // Text(quote.qQuantity?.toString() ?? ''),
            //               ],
            //             ),
            //             Text(
            //               'Expire at: ${quote.qExpireDate != null ? DateFormat('dd MMM yyyy').format(quote.qExpireDate!) : ''}',
            //               style: TextStyle(decoration: TextDecoration.underline),
            //             ),
            //             10.heightBox,
            //             Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: SizedBox(
            //                 height: 45,
            //                 width: double.infinity,
            //                 child: OutlinedButton(
            //                   style: OutlinedButton.styleFrom(
            //                     shadowColor: Colors.orange,
            //                     foregroundColor: Colors.orange.shade700,
            //                     overlayColor: Colors.orange.shade700,
            //                   ),
            //                   onPressed: () {},
            //                   child: const Text("View Details"),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // );
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: quotationList.length,
              itemBuilder: (context, index) {
                final quote = quotationList[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with quote number and status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.orange.shade50,
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                quote.qNum ?? 'QUOTE',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // // Add status indicator if available
                            // Container(
                            //   width: 8,
                            //   height: 8,
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.circle,
                            //     color: Colors.green.shade500,
                            //   ),
                            // ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Product name with icon
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                quote.qItems != null && quote.qItems!.isNotEmpty
                                    ? quote
                                              .qItems!
                                              .first
                                              .product
                                              ?.productName ??
                                          'Product not specified'
                                    : 'No products',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Quantity and amount row with better styling
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoChip(
                                icon: null,
                                // icon: Icons.format_list_numbered,
                                label: 'Qty: ${quote.qQuantity ?? 0}',
                                color: Colors.blue,
                              ),
                              _buildInfoChip(
                                icon: Icons.currency_rupee,
                                label:
                                    'Amount: ${_formatPrice(quote.qPrice ?? 0)}',
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Expiry date with icon
                        if (quote.qExpireDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Expires on: ${DateFormat('dd MMM yyyy').format(quote.qExpireDate!)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // View Details button with improved styling
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              // Add your navigation logic here
                              Get.to(
                                () => JsDetailQuotation(quoteId: quote.qId),
                                transition: Transition.rightToLeft,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                              side: BorderSide(
                                color: Colors.orange.shade200,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // Helper method for info chips
  Widget _buildInfoChip({
    required IconData? icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // Helper method to format price
  String _formatPrice(num price) {
    return price.toStringAsFixed(2);
  }
}
