import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../Constants/constants.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Map<String, dynamic>? productData;
  bool isLoading = true;
  int selectedIndex = 0;
  int selectedTabIndex = 0;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments?["id"];
    if (id != null) {
      fetchProductDetails(id);
    }
  }

  Future<void> fetchProductDetails(String id) async {
    try {
      final dio = Dio();
      final url =
          "$jitUrl/jitmenu/public/product/$id";

      final response = await dio.get(url);

      print("API STATUS: ${response.statusCode}");
      print("API DATA: ${response.data}");

      if (response.statusCode == 200) {
        setState(() {
          productData = response.data['data']; // ✅ IMPORTANT
          isLoading = false;
        });
      }
    } catch (e) {
      print("API ERROR: $e");
    }
  }

  String get brandName => productData?['brand']?['name'] ?? 'Unknown Brand';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final productName = productData?['productName'] ?? '';
    final description = productData?['productLongDescription'] ?? '';
    final prices = productData?['price'] ?? [];

    final selectedPrice = prices.isNotEmpty
        ? prices[selectedIndex]['price'] ?? 0
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// IMAGE
            Center(
              child: Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: productData?['image'] != null
                    ? Image.network(productData!['image'], fit: BoxFit.cover)
                    : Image.asset(
                        "lib/assets/images/Capture.png",
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 20),

            /// NAME
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// DESCRIPTION
            Padding(
              padding: const EdgeInsets.only(left: 18, top: 6),
              child: Text(description),
            ),

            const SizedBox(height: 15),

            /// BRAND
            _brandSection(productData?['brand']?['image']),

            /// PRICE SIZE LIST
            if (prices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            prices[index]['size'] ?? '',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            /// PRICE
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "₹$selectedPrice",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text("Exclusive of all taxes"),
            ),

            const SizedBox(height: 10),

            /// RATING
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  RatingBarIndicator(
                    rating: 4.4,
                    itemCount: 5,
                    itemSize: 20,
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: Colors.amber),
                  ),
                  const SizedBox(width: 8),
                  const Text("4.4 (58 reviews)"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// BUTTON
            Center(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                  ),
                  child: const Text("Add to menu"),
                ),
              ),
            ),
            const SizedBox(height: 20),
  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildTab(text: "Product Description", index: 0),
                SizedBox(width: 10),
                buildTab(text: "Usage & Applications", index: 1),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _brandSection(dynamic image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (image != null && image.isNotEmpty)
            CircleAvatar(radius: 25, backgroundImage: NetworkImage(image))
          else
            const CircleAvatar(radius: 20, child: Icon(Icons.business)),
          const SizedBox(width: 10),
          Text(
            brandName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildTab({required String text, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = index;
        });
      },
      child: Column(
        children: [
          Text(text, style: TextStyle(fontSize: 15, color: Colors.black)),
          SizedBox(height: 6),
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            height: 3,
            width: 160,
            decoration: BoxDecoration(
              color: selected == index ? Colors.orange : Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
