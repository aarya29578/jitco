import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/ads.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/swiper_api.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/DetailProduct/detail_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class Promotion extends StatefulWidget {
  const Promotion({super.key});

  @override
  State<Promotion> createState() => _PromotionState();
}

class _PromotionState extends State<Promotion> {
  List<Ads> adsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  loadAds() async {
    setState(() => isLoading = true);
    try {
      adsList = await SliderApiService.getSliderAds();
    } catch (e) {
      print("Slider Load Error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _handleClick(Ads ad) async {
    try {
      // 1. Check targetUrl
      if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) {
        final Uri url = Uri.parse(ad.targetUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          print("Could not launch $url");
        }
        return;
      }

      // 2. Navigate based on entity
      if (ad.product != null && ad.product!.slug != null) {
        Get.to(() => DetailProductScreen(productSlug: ad.product!.slug!));
      } else if (ad.category != null && ad.category!.slug != null) {
        Get.to(() => UniversalProductScreen(
              categorySlug: ad.category!.slug,
              categoryName: ad.category!.name,
            ));
      } else if (ad.brand != null && ad.brand!.slug != null) {
        Get.to(() => UniversalProductScreen(
              brandSlug: ad.brand!.slug,
              brandName: ad.brand!.name,
              isBrandScreen: true,
            ));
      } else {
        print("No navigation target found for ad");
      }
    } catch (e) {
      print("Error handling ad click: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: "Promotions".text.semiBold.black.make(),
      ),
      body: RefreshIndicator(
        onRefresh: () => loadAds(),
        color: Colors.orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Hot Deals & Promotions"
                        .text
                        .size(28)
                        .bold
                        .color(Colors.grey[800])
                        .make(),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Featured Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          "Featured"
                              .text
                              .size(22)
                              .bold
                              .color(Colors.grey[800])
                              .make(),
                          const Icon(Icons.star, color: Colors.orange, size: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        _buildShimmerLoading()
                      else if (adsList.isEmpty)
                        _buildEmptyState()
                      else
                        _buildAdsList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final ad = adsList[index];
        return _buildBannerCard(ad);
      },
    );
  }

  Widget _buildBannerCard(Ads ad) {
    return InkWell(
      onTap: () => _handleClick(ad),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                ad.image ?? "",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ad.title != null && ad.title!.isNotEmpty)
                    ad.title!.text.bold.size(16).color(Colors.grey[800]).make(),
                  if (ad.brand != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: "By ${ad.brand!.name}".text.size(12).color(Colors.grey[600]).make(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: "Currently no available offers"
          .text
          .white
          .semiBold
          .size(14)
          .make(),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
