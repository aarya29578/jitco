import 'package:flutter/material.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/B_learnMore_btn/procure_contract.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';

class ContractSupplies extends StatelessWidget {
  const ContractSupplies({super.key});

  @override
  Widget build(BuildContext context) {
    return ProcureContract(title: contractTitle, subtitle: contractSubtitle);
  }
}
