import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/A_model_data_summa/card_product_data.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/ads.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/b_Home_Brands/home_brands.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/cart_badge.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/c_Home_Products/home_products.dart';
import 'package:jitco_app/A_Widgets/consts/images.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/swiper_api.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Widgets/Js_consts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home and Drawer/a_Home_Drawer/drawer_screens/promotion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _buzzerController;
  late Animation<double> _buzzerAnimation;

  List<Ads> adsList = [];
  bool isLoading = true;

  List<Map<String, String>> imageList = [
    {
      "image": 'assets/J_supply/J_supply1.png',
      "title": 'You can find everything -',
      "subtitle": 'You Need. ',
      "jitco": 'JITCO Supply',
    },
    {
      "image": 'assets/J_supply/J_supply2.png',
      "title": 'You can find everything -',
      "subtitle": 'You Need. ',
      "jitco": 'JITCO Supply',
    },
    {
      "image": 'assets/J_supply/J_supply3.png',
      "title": 'You can find everything -',
      "subtitle": 'You Need. ',
      "jitco": 'JITCO Supply',
    },
    {
      "image": 'assets/J_supply/J_supply4.png',
      "title": 'You can find everything -',
      "subtitle": 'You Need. ',
      "jitco": 'JITCO Supply',
    },
  ];

  @override
  void initState() {
    super.initState();
    //post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
    });
    loadAds();
    _initBuzzer();
  }

  void _initBuzzer() {
    _buzzerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _buzzerAnimation = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _buzzerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buzzerController.dispose();
    super.dispose();
  }


  loadAds() async {
    try {
      adsList = await SliderApiService.getSliderAds();
    } catch (e) {
      print("Slider Load Error: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.amber,
      drawer: Drawer(
        shape: Border(),
        backgroundColor: Colors.white,
        child: DrawerHome(),
      ),

      body: CustomScrollView(
        slivers: [
          // ----------------------------- APPBAR -----------------------------
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: SvgPicture.asset('assets/logo.svg', width: 75),
            actions: [
              CartBadgeIcon(
                isActive: true,
                activeColor: Colors.grey,
                nonActiveColor: Colors.grey,
              ).onTap(() {
                // Get.to(() => BottomNavItem(initialIndex: 3));
                final bottomNavState = context
                    .findAncestorStateOfType<JitcoSupplyNavBarState>();
                if (bottomNavState != null) {
                  bottomNavState.switchToTab(
                    4,
                  ); // Switch to Products tab (index 2)
                }
              }),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _buzzerAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _buzzerAnimation.value,
                    child: IconButton(
                      onPressed: () {
                        Get.to(() => const Promotion());
                      },
                      icon: const Icon(
                        Icons.campaign_outlined,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  // Get.to(() => BottomNavItem(initialIndex: 2));
                  // final bottomNavState = context
                  //     .findAncestorStateOfType<JitcoSupplyNavBarState>();
                  // if (bottomNavState != null) {
                  //   bottomNavState.switchToTab(
                  //     3,
                  //   ); // Switch to Products tab (index 2)
                  // }
                  Get.find<BottomNavController>().openProductSearch();
                },
                icon: Icon(Icons.search, size: 23),
              ),
              7.widthBox,
            ],
          ),

          SliverToBoxAdapter(child: 22.heightBox),

          // ----------------------------- SWIPER SECTION -----------------------------
          // SliverToBoxAdapter(
          //   child: isLoading
          //       ? const Center(child: CircularProgressIndicator())
          //       : adsList.isEmpty
          //       ? "No Banners Found".text.makeCentered()
          //       : VxSwiper.builder(
          //           aspectRatio: 20 / 9,
          //           autoPlay: true,
          //           autoPlayInterval: const Duration(seconds: 3),
          //           height: 180,
          //           enlargeCenterPage: true,
          //           itemCount: adsList.length,
          //           itemBuilder: (context, index) {
          //             return Container(
          //               margin: const EdgeInsets.symmetric(horizontal: 4),
          //               child:
          //                   ClipRRect(
          //                     borderRadius: BorderRadius.circular(12),
          //                     child: Image.network(
          //                       adsList[index].image ?? "",
          //                       fit: BoxFit.cover,
          //                       width: double.infinity,
          //                       errorBuilder: (c, o, e) =>
          //                           const Icon(Icons.error),
          //                     ),
          //                   ).onTap(() {
          //                     Get.snackbar(
          //                       adsList[index].title ?? "Banner",
          //                       "You clicked on banner",
          //                     );
          //                   }),
          //             );
          //           },
          //         ),
          // ),
          SliverToBoxAdapter(
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180,
                aspectRatio: 20 / 9,
                enlargeCenterPage: true,
                autoPlay: false,
                autoPlayInterval: Duration(seconds: 3),
              ),
              items: imageList.map((item) {
                return Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(item['image']!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    item['subtitle']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    item['jitco']!,
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SliverToBoxAdapter(child: 16.heightBox),
          SliverToBoxAdapter(child: HomeBrands()),
          SliverToBoxAdapter(child: SafeArea(child: HomeProducts())),
        ],
      ),
    );
  }
}
