import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/D_About/about_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/E_Contact_Us/contact_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/F_Contracts/contract_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/B_Your_Enquiries/enquires_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/A_Your_Order/order_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/C_Profile_Settings/profile_settings.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/notification.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/promotion.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/dialog_logout.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';
import 'package:url_launcher/url_launcher.dart';


class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  final ApiServices _apiService = Get.find<ApiServices>();
  final AuthController authController = Get.find<AuthController>();
  String selectedMenu = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 30),

                    // -------- HEADER ----------
                    // Center(
                    //   child: Container(
                    //     //height: 100,
                    //     width: 140,
                    //     child: SvgPicture.asset("assets/logo.svg"),
                    //   ),
                    // ),

                    //SizedBox(height: 5),

                    // -------- GLASS PANEL + BOTTOM ITEMS MERGED --------
                    Container(
                      //margin: EdgeInsets.all(10),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.12),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          7.heightBox,
                          Center(
                            child: SafeArea(
                              child: Container(
                                // color: Colors.amber,
                                height: 65,
                                width: 180,
                                child: SvgPicture.asset("assets/logo.svg"),
                              ),
                            ),
                          ),
                          15.heightBox,
                          buildSectionTitle("Orders & Statements"),
                          buildMenuItem(
                            Icons.list_outlined,
                            "Your Orders",
                            "orders",
                            page: OrdersScreen(),
                          ),
                          buildMenuItem(
                            Icons.outbond_outlined,
                            "Your Enquiries",
                            "enquiries",
                            page: EnquiresScreen(),
                          ),

                          // Divider(color: Colors.white54),
                          buildSectionTitle("Others"),
                          buildMenuItem(
                            Icons.settings,
                            "Profile Settings",
                            "profile",
                            page: ProfileSettings(),
                          ),
                          // buildMenuItem(
                          //   Icons.notifications,
                          //   "Notifications",
                          //   "notify",
                          //   // NotificationScreen(),
                          // ),

                          // Divider(color: Colors.white54),
                          buildSectionTitle("Information"),
                          buildMenuItem(
                            Icons.account_box_outlined,
                            "About Us",
                            "about",
                            page: About(),
                          ),
                          buildMenuItem(
                            Icons.phone,
                            "Contact Us",
                            "contact",
                            page: Contact(),
                          ),

                          // Divider(color: Colors.white54),

                          // -------- MOVED BOTTOM TEXTS TO PANEL ----------
                          if (authController.hasContract != false) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildSectionTitle("More Options"),
                                // buildMenuItem(
                                //   Icons.local_offer_outlined,
                                //   "Promotions",
                                //   "promotions",
                                //   page: Promotion(),
                                // ),
                                buildMenuItem(
                                  Icons.lock_clock_outlined,
                                  "Contracts",
                                  "contracts",
                                  page: ContractScreen(),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),

          // -------- LOGOUT BUTTON ----------
          // Center(
          //   child: Container(
          //     height: 45,
          //     width: 300,
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Colors.deepOrange, Colors.orange.shade700],
          //       ),
          //       borderRadius: BorderRadius.circular(30),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black38,
          //           blurRadius: 10,
          //           offset: Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: TextButton(
          //       onPressed: () {},
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(Icons.logout, color: Colors.white),
          //           SizedBox(width: 8),
          //           Text(
          //             "LOG OUT",
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               letterSpacing: 1,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // const Divider(),
          // const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(height: 0.4, color: Colors.grey[400]),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => showCommonDialog(context),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.black),
                              SizedBox(width: 7),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 0.4, color: Colors.grey[400]),
                    15.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(
                          FontAwesomeIcons.facebook,
                          "https://www.facebook.com/jitco.inn",
                          Colors.blue.shade800,
                        ),
                        18.widthBox,
                        _buildSocialIcon(
                          FontAwesomeIcons.instagram,
                          "https://www.instagram.com/jitcoindia/",
                          Colors.pink,
                        ),
                        18.widthBox,
                        _buildSocialIcon(
                          FontAwesomeIcons.xTwitter,
                          "https://x.com/Jitco_in/",
                          Colors.black,
                        ),
                        18.widthBox,
                        _buildSocialIcon(
                          FontAwesomeIcons.linkedin,
                          "https://www.linkedin.com/company/jitcoindia/",
                          Colors.blue.shade700,
                        ),
                        18.widthBox,
                        _buildSocialIcon(
                          FontAwesomeIcons.youtube,
                          "https://www.youtube.com/@JITCO_IN",
                          Colors.red,
                        ),
                      ],
                    ),
                    12.heightBox,
                    Text(
                      rightsReserved,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    10.heightBox,
                  ],
                ),
              ),
            ],
          ),

          //Logout******
          // SizedBox(height: 0.4, child: Container(color: Colors.grey[400])),
          // Material(
          //   color: Colors.transparent,
          //   child: InkWell(
          //     onTap: () {
          //       showCommonDialog(context);
          //     },
          //     child: SafeArea(
          //       child: Container(
          //         // width: double.infinity,
          //         // padding: EdgeInsets.zero,
          //         // margin: EdgeInsets.zero,
          //         decoration: BoxDecoration(color: Colors.grey),
          //         height: 30,
          //         child: Row(
          //           // mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Icon(Icons.arrow_back, color: Colors.black),
          //             7.widthBox,
          //             const Text(
          //               'Logout',
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.w500,
          //                 color: Colors.black87,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---------- SECTION TITLE ----------
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 7),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------- MENU ITEM ----------
  // Widget buildMenuItem(IconData icon, String text, String key, Widget? pages) {
  //   final bool isSelected = selectedMenu == key;
  //   return GestureDetector(
  //     onTap: () => setState(() {
  //       selectedMenu = key;
  //       Navigator.pop(context);
  //       // Get.back();
  //       if (pages != null) {
  //         Get.to(() => pages, transition: Transition.cupertino);
  //       }
  //       // Get.to(() => pages!, transition: Transition.cupertino);
  //     }),
  //     child: AnimatedContainer(
  //       duration: Duration(milliseconds: 200),
  //       padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
  //       margin: EdgeInsets.only(bottom: 6),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? Colors.black.withOpacity(0.25)
  //             : Colors.transparent,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: isSelected ? Colors.white70 : Colors.black,
  //             size: 22,
  //           ),
  //           SizedBox(width: 12),
  //           Text(
  //             text,
  //             style: TextStyle(
  //               color: isSelected ? Colors.white70 : Colors.black,
  //               fontSize: 15,
  //               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildMenuItem(IconData icon, String text, String key, {Widget? page}) {
    final bool isSelected = selectedMenu == key;

    return GestureDetector(
      onTap: () => setState(() {
        selectedMenu = key;
        Navigator.pop(context);

        if (page != null) {
          Get.to(() => page, transition: Transition.cupertino);
        }
      }),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white70 : Colors.black),
            SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(dynamic icon, String url, Color color) {
    return InkWell(
      onTap: () async {
        try {
          final Uri uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint("Could not launch $url: $e");
        }
      },
      child: FaIcon(icon, color: color, size: 24),
    );
  }
}
