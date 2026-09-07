import 'package:flutter/material.dart';

class TabsHeader extends StatelessWidget {
  final String tabsHeader;
  const TabsHeader({super.key, required this.tabsHeader});

  @override
  Widget build(BuildContext context) {
    return Text(
      tabsHeader,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
    );
  }
}
