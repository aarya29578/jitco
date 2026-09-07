import 'package:flutter/material.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/widgets/tabs_header.dart';
import 'package:jitco_app/A_Widgets/consts/list.dart';
import 'package:velocity_x/velocity_x.dart';

class UseAndAppli extends StatefulWidget {
  final Map<String, dynamic>? productData;
  const UseAndAppli({super.key, required this.productData});

  @override
  State<UseAndAppli> createState() => _UseAndAppliState();
}

class _UseAndAppliState extends State<UseAndAppli> {
  String _cleanHtmlText(String text) {
    // Simple HTML tag removal - you might need more sophisticated parsing
    return text
        .replaceAll('<p>', '\n')
        .replaceAll('</p>', '\n')
        .replaceAll('<br>', '\n')
        // Strong (bold) → remove
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        // Unordered list → remove container
        .replaceAll('<ul>', '')
        .replaceAll('</ul>', '')
        // List items → bullet points
        .replaceAll('<li>', '• ')
        .replaceAll('</li>', '\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (usageProductData.isNotEmpty)
              if (widget.productData != null)
                TabsHeader(tabsHeader: 'Usage / Application'),
              10.heightBox,
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _cleanHtmlText(widget.productData?['usage'] ?? ''),
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              30.heightBox,
            ],
          ),
        ),
      ),
    );
  }
}
