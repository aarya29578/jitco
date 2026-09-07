import 'package:flutter/material.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/widgets/tabs_header.dart';
import 'package:jitco_app/A_Widgets/consts/list.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDescripService extends StatefulWidget {
  final Map<String, dynamic>? productData;
  const ProductDescripService({super.key, required this.productData});

  @override
  State<ProductDescripService> createState() => _ProductDescripServiceState();
}

class _ProductDescripServiceState extends State<ProductDescripService> {
  // Helper methods to extract product data
  String _getUSP() {
    return widget.productData?['usp'] ??
        widget.productData?['productLongDescription'] ??
        'No product information available';
  }

  List<String> _getDietaryInfo() {
    final dietary = widget.productData?['dietary'];
    if (dietary is List) {
      return dietary.cast<String>().toList();
    }
    // Fallback to veg/non-veg information
    final vegNonVeg = widget.productData?['vegNoneveg'] ?? 'Veg';
    return [vegNonVeg];
  }

  String _getIngredients() {
    return widget.productData?['ingredients'] ??
        'No ingredients information available';
  }

  String _getStorageInstructions() {
    return widget.productData?['instructions'] ??
        'No storage instructions available';
  }

  String _cleanHtmlText(String text) {
    // Simple HTML tag removal - you might need more sophisticated parsing
    return text
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('<p>', '\n')
        .replaceAll('</p>', '.\n')
        .replaceAll('<br>', '\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productData == null && descripProductData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No product data available',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      //physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product USP
            if (_getUSP().isNotEmpty &&
                _getUSP() != 'No information available') ...[
              TabsHeader(tabsHeader: 'What we Offer'),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _cleanHtmlText(_getUSP()),
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              30.heightBox,
            ],

            // Dietary Information
            if (_getDietaryInfo().isNotEmpty) ...[
              TabsHeader(tabsHeader: 'Dietary Information'),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getDietaryInfo().map((dietary) {
                    return _buildDietaryTick(deitaryInfo: dietary);
                  }).toList(),
                ),
              ),
              30.heightBox,
            ],

            // Ingredients / Composition
            if (_getIngredients().isNotEmpty &&
                _getIngredients() != 'No information available') ...[
              TabsHeader(tabsHeader: 'Why choose Us'),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _cleanHtmlText(_getIngredients()),
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              30.heightBox,
            ],

            // Storage Instructions
            if (_getStorageInstructions().isNotEmpty &&
                _getStorageInstructions() != 'No information available') ...[
              TabsHeader(tabsHeader: 'Professional Support Service'),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _cleanHtmlText(_getStorageInstructions()),
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              30.heightBox,
            ],

            // Product Specifications
            // TabsHeader(tabsHeader: 'Product Specifications'),
            // 10.heightBox,
            // _buildProductSpecifications(),
            // 50.heightBox,
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryTick({String? deitaryInfo}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          4.widthBox,
          Text(
            deitaryInfo!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSpecifications() {
    //NOT USING NOW - BUT IMPORTANT
    final product = widget.productData;
    if (product == null) return SizedBox();

    final specifications = [
      _buildSpecItem('Product Code', product['productCode']),
      _buildSpecItem('Country of Origin', product['countryOrigin']),
      _buildSpecItem('Weight', '${product['productWeight']}g'),
      _buildSpecItem(
        'Dimensions',
        '${product['productLength']}x${product['productBreadth']}x${product['productHeight']} cm',
      ),
      _buildSpecItem('HSN Code', product['hsn']),
      _buildSpecItem('GST Percentage', '${product['gstPercentage']}%'),
      _buildSpecItem('Shelf Life', product['shelfLife']),
      _buildSpecItem('Return Window', '${product['returnWindow']} days'),
      _buildSpecItem(
        'Returnable',
        product['returnable'] == true ? 'Yes' : 'No',
      ),
      _buildSpecItem(
        'Cancellable',
        product['cancellable'] == true ? 'Yes' : 'No',
      ),
      _buildSpecItem('COD Available', product['cod'] == true ? 'Yes' : 'No'),
    ].where((item) => item != null).toList();

    return Column(
      //children: specifications,
    );
  }

  Widget? _buildSpecItem(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.toString(),
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
