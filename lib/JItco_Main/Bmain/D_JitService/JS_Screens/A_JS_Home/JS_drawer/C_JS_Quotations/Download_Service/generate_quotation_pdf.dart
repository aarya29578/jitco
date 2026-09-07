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

Future<void> generateQuotationPdf(context, detailQuotation) async {
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

  final item = detailQuotation.qItems?.first;

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
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "JITCO",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "One Platform. Every Food Service Need.",
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.Text(
                      "Delivered Just-In-Time.",
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),

                pw.Text(
                  "QUOTE",
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            pw.Divider(height: 30),

            /// QUOTE INFO
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                    ),
                    pw.Text("Quote No: ${detailQuotation.qNum}"),
                    pw.Text(
                      "Valid Until: ${DateFormat('dd/MM/yyyy').format(detailQuotation.qExpireDate)}",
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "SOURCE DETAIL:",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Services",
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PREPARED BY:",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "JITCO - info@jitco.in",
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            /// PRODUCT TABLE TITLE
            pw.Text(
              "PRODUCT DETAILS",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),

            pw.SizedBox(height: 10),

            /// PRODUCT TABLE
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                /// TABLE HEADER
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell("Description", isHeader: true),
                    _tableCell("Qty", isHeader: true),
                    _tableCell("Price", isHeader: true),
                    _tableCell("Total", isHeader: true),
                  ],
                ),

                /// TABLE DATA
                pw.TableRow(
                  children: [
                    _tableCell(item?.product?.productName ?? "Product"),
                    _tableCell("${item?.quantity ?? 0}"),
                    _tableCell("${item?.price ?? 0}"), //₹
                    _tableCell("${item?.total ?? 0}"),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            /// TOTAL SECTION
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _priceRow("Subtotal", "${item?.priceTotal ?? 0}"),

                    pw.SizedBox(height: 6),

                    _priceRow("Tax", "${item?.gstTotal ?? 0}"),

                    pw.Divider(),

                    _priceRow(
                      "Grand Total",
                      "${item?.total ?? 0}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            pw.Spacer(),

            /// SIGNATURES
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text("____________________"),
                    pw.SizedBox(height: 5),
                    pw.Text("Customer Signature"),
                  ],
                ),

                pw.Column(
                  children: [
                    pw.Text("____________________"),
                    pw.SizedBox(height: 5),
                    pw.Text("Date"),
                  ],
                ),
              ],
            ),

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
                    "Should you have any enquiries concerning this quote, contact us at info@jitco.in",
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

  // /// PREVIEW / PRINT / SHARE
  // await Printing.layoutPdf(
  //   onLayout: (PdfPageFormat format) async => pdf.save(),
  // );

  // /// SAVE FILE LOCALLY
  // final dir = await getApplicationDocumentsDirectory();
  // final file = File("${dir.path}/quotation_${detailQuotation.qNum}.pdf");

  // await file.writeAsBytes(await pdf.save());

  // ///FOR PDF PREVIEW
  // OpenFile.open(file.path);

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
  final file = File("${dir.path}/quotation_${detailQuotation.qNum}.pdf");

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
      pw.Text(title),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    ],
  );
}
