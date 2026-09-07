import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/learn_more.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:velocity_x/velocity_x.dart';

class JitcoAbout extends StatelessWidget {
  final String? about1;
  final String? about2;
  final String aboutTitle;

  const JitcoAbout({
    super.key,
    this.about1 = '',
    this.about2 = '',
    required this.aboutTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          aboutTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        17.heightBox,
        Text(about1!, style: TextStyle(fontSize: 15)),
        10.heightBox,
        Text(about2!, style: TextStyle(fontSize: 15)),
        10.heightBox,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.orange.shade700,
          ),
          onPressed: () {
            Get.to(() => LearnMore(), transition: Transition.rightToLeft);
          },
          child: const Text(
            'Learn More',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class AboutImages extends StatelessWidget {
  final String aboutUsImage;
  final bool fitUse;
  const AboutImages({
    super.key,
    required this.aboutUsImage,
    required this.fitUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(aboutUsImage),
          fit: fitUse == true ? BoxFit.cover : null,
        ),
      ),
    );
  }
}

class TrustJitco extends StatelessWidget {
  final String underTitleTypes;
  final String underTypes;
  const TrustJitco({
    super.key,
    required this.underTitleTypes,
    required this.underTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          underTitleTypes,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(underTypes, style: TextStyle(fontSize: 15)),
        20.heightBox,
      ],
    );
  }
}
