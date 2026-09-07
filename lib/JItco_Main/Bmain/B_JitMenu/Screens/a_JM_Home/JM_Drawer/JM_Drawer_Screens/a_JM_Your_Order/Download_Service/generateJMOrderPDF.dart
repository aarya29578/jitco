import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

Future<void> generateJmOrderPdf(
  context,
  orderDetails,
  String? whichSource,
) async {
  /// REQUEST PERMISSION
  // var status = await Permission.storage.request();
  var status = await Permission.manageExternalStorage.request();

  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Storage permission required")),
    );
    return;
  }

  final pdf = pw.Document();

  final item = orderDetails.items?.first;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),

      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            /// HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Order Invoice",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Order #${orderDetails.orderNumber}",
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),

                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Date: ${orderDetails.formattedDate}",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _getStatusColor(orderDetails.status),
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        orderDetails.status,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.Divider(height: 30),

            pw.SizedBox(height: 20),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        // border: pw.Border.all(color: PdfColors.black),
                      ),
                      width: 180,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Shipping Address",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),

                          orderDetails.outlet?.name != null ||
                                  orderDetails.outlet?.address != null ||
                                  orderDetails.outlet?.state?.name != null ||
                                  orderDetails.outlet?.city?.name != null ||
                                  orderDetails.outlet?.country != null ||
                                  orderDetails.outlet?.pinCode != null
                              ? pw.Text(
                                  '${orderDetails.outlet?.name ?? ''} , ${orderDetails.outlet?.address ?? ''}, ${orderDetails.outlet?.state?.name ?? ''}, ${orderDetails.outlet?.city?.name ?? ''}, ${orderDetails.outlet?.country ?? ''} - ${orderDetails.outlet?.pinCode ?? ''}',
                                )
                              : orderDetails.shippingAddress.isNotEmpty
                              ? orderDetails.shippingAddress.text
                                    .size(14)
                                    .make()
                              : pw.Text(
                                  "Not specified",
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.normal,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 2),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        // border: pw.Border.all(color: PdfColors.black),
                      ),
                      width: 180,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Payment Information",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            "Status: ${orderDetails.paymentStatus}",
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.normal,
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 2),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Container(
                      // padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        // border: pw.Border.all(color: PdfColors.black),
                      ),
                      width: 180,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Order Summary",
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          _priceRow(
                            "Subtotal:",
                            "Rs.${(orderDetails?.totalAmount ?? 0.00).toStringAsFixed(2)}",
                          ),

                          pw.SizedBox(height: 6),

                          _priceRow(
                            "GST:",
                            "Rs.${(orderDetails?.gst ?? 0.00).toStringAsFixed(2)}",
                          ),
                          pw.SizedBox(height: 6),

                          _priceRow("Shipping:", "0.00"),

                          pw.Divider(),

                          _priceRow(
                            "Grand Total",
                            "Rs.${(orderDetails?.finalAmount ?? 0).toStringAsFixed(2)}",
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            /// PRODUCT TABLE TITLE
            pw.Text(
              "${whichSource == 'JitService' ? 'Orders' : ' Order'} ${whichSource == 'JitService' ? '' : 'items'}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),

            pw.SizedBox(height: 10),

            /// PRODUCT TABLE
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                ///Services and Items
                0: pw.FlexColumnWidth(whichSource == 'JitService' ? 3 : 4),

                ///Slot or Qty
                1: pw.FlexColumnWidth(whichSource == 'JitService' ? 2 : 1),

                ///Qty or Price
                2: pw.FlexColumnWidth(whichSource == 'JitService' ? 1 : 2),

                ///Price or Gst
                3: pw.FlexColumnWidth(whichSource == 'JitService' ? 2 : 1),

                ///GST or GstTotal
                4: pw.FlexColumnWidth(whichSource == 'JitService' ? 1 : 2),
                5: const pw.FlexColumnWidth(2),
                if (whichSource == 'JitService') 6: const pw.FlexColumnWidth(2),
              },
              children: [
                /// TABLE HEADER
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell(
                      whichSource == 'JitService' ? 'Services' : 'Items',
                      isHeader: true,
                    ),
                    if (whichSource == 'JitService')
                      _tableCell("Slot", isHeader: true),
                    _tableCell("Qty", isHeader: true),
                    _tableCell("Price", isHeader: true),
                    _tableCell("GST", isHeader: true),
                    _tableCell("GST Total", isHeader: true),
                    _tableCell("Total", isHeader: true),
                  ],
                ),

                /// TABLE DATA
                ...orderDetails.items?.map(
                  (item) => pw.TableRow(
                    children: [
                      _tableCell(item?.productName ?? "Product"),
                      if (whichSource == 'JitService')
                        _tableCell(
                          "${item?.slotDate ?? 'No Date'} && ${item.slotTime ?? 'No Time'}",
                        ),
                      _tableCell("${item?.quantity ?? 0}"),
                      _tableCell("Rs.${item?.price ?? 0}"), //₹
                      _tableCell("${item?.gst ?? 0}%"),
                      _tableCell("Rs.${item?.gstTotal ?? 0}"),
                      _tableCell("Rs.${item?.total ?? 0}"),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            pw.Spacer(),

            pw.SizedBox(height: 25),

            /// FOOTER
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "THANK YOU FOR YOUR BUSINESS!",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "For any questions, please contact our support team.",
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        );
      },
    ),
  );

  /// GET DOCUMENTS PATH
  final documentsPath = await ExternalPath.getExternalStoragePublicDirectory(
    ExternalPath.DIRECTORY_DOCUMENTS,
  );

  /// CREATE JITCO FOLDER
  final dir = Directory("$documentsPath/Jitco");

  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  /// FILE PATH
  final file = File(
    "${dir.path}/${whichSource}_${orderDetails.orderNumber}.pdf",
  );

  await file.writeAsBytes(await pdf.save());

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text("Saved in ${file.path}")));

  await Future.delayed(Duration(seconds: 1));

  ///help to refresh the internal storage media
  await MediaScanner.loadMedia(path: file.path);

  ///FOR PDF PREVIEW
  OpenFile.open(file.path);
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
    case 'processing':
      return PdfColors.orange;
    case 'confirmed':
      return PdfColors.blue;
    case 'shipped':
      return PdfColors.purple;
    case 'delivered':
      return PdfColors.green;
    case 'cancelled':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}

/// TABLE CELL WIDGET
pw.Widget _tableCell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: 11,
      ),
    ),
  );
}

/// PRICE ROW
pw.Widget _priceRow(String title, String value, {bool isBold = false}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    ],
  );
}
