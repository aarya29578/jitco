import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/circularButtonIndicator.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/expandable_tile.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/jitco_about.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/video_player_aboutUs.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/A_widgets/video_stack.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_player/video_player.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  int? expandedIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.orange.shade700,
        surfaceTintColor: Colors.orange.shade700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AutoPlayVideo(videoPath: aboutUsVideo),
              VideoStack(),
              30.heightBox,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FittedBox(
                    //   fit: BoxFit.cover,
                    //   child: SizedBox(
                    //     // width: double.infinity,
                    //     // height: 200,
                    //     child: AutoPlayVideo(
                    //       videoPath: "assets/videos/video_aboutUs.mp4",
                    //     ),
                    //   ),
                    // ),
                    10.heightBox,
                    JitcoAbout(
                      aboutTitle: aboutTitle1,
                      about1: aboutJitco1,
                      about2: aboutJitco_1,
                    ),
                    18.heightBox,
                    AboutImages(aboutUsImage: aboutUs[1], fitUse: true),
                    50.heightBox,
                    JitcoAbout(about1: aboutJitco2, aboutTitle: aboutTitle2),
                    18.heightBox,
                    AboutImages(aboutUsImage: aboutUs[0], fitUse: true),
                    60.heightBox,
                    Center(
                      child: Text(
                        trustTitleJitco,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // AboutImages(aboutUsImage: aboutUs[2]),
                    SizedBox(
                      height: 250,
                      child: AboutImages(
                        aboutUsImage: aboutUs[2],
                        fitUse: false,
                      ),
                    ),
                    10.heightBox,
                    TrustJitco(
                      underTitleTypes: underTitleTypes1,
                      underTypes: underTypes1,
                    ),
                    TrustJitco(
                      underTitleTypes: underTitleTypes2,
                      underTypes: underTypes2,
                    ),
                    TrustJitco(
                      underTitleTypes: underTitleTypes3,
                      underTypes: underTypes3,
                    ),
                    TrustJitco(
                      underTitleTypes: underTitleTypes4,
                      underTypes: underTypes4,
                    ),
                    40.heightBox,
                    Center(
                      child: Text(
                        empBussiness,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    8.heightBox,
                    Center(
                      child: Text(
                        subtitleEmpBussiness,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    15.heightBox,
                    //REUSABLE WIDGET
                    ProgressCircle(percentage: 90, percentageReal: 0.90),
                    Text(report90, textAlign: TextAlign.center),
                    15.heightBox,
                    ProgressCircle(percentage: 100, percentageReal: 0.99),
                    Text(experienced100, textAlign: TextAlign.center),
                    15.heightBox,
                    ProgressCircle(percentage: 94, percentageReal: 0.94),
                    Text(better94, textAlign: TextAlign.center),
                    60.heightBox,
                    Center(
                      child: Text(
                        tileTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    10.heightBox,
                    ExpandableTile(
                      title: tileTitle1,
                      description: tileDescription1,
                      keys: tileKeys1,
                      features: keysDetails1,
                      isExpanded: expandedIndex == 0,
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == 0 ? null : 0;
                        });
                      },
                    ),
                    ExpandableTile(
                      title: tileTitle2,
                      description: tileDescription2,
                      keys: tileKeys2,
                      features: keysDetails2,
                      isExpanded: expandedIndex == 1,
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == 1 ? null : 1;
                        });
                      },
                    ),
                    ExpandableTile(
                      title: tileTitle3,
                      description: tileDescription3,
                      keys: tileKeys3,
                      features: keysDetails3,
                      isExpanded: expandedIndex == 2,
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == 2 ? null : 2;
                        });
                      },
                    ),
                    ExpandableTile(
                      title: tileTitle4,
                      description: tileDescription4,
                      keys: tileKeys4,
                      features: keysDetails4,
                      isExpanded: expandedIndex == 3,
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == 3 ? null : 3;
                        });
                      },
                    ),
                    70.heightBox,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            rightsReserved,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            smartFood,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    30.heightBox,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
