import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/detailpage.dart';

class productpagee extends StatelessWidget {
  final allproducts prodController = Get.put(allproducts());

  productpagee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JIT MENU"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 45,
              width: 350,
              child: TextField(
                onChanged: (value) => prodController.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 PRODUCT LIST
          Expanded(
            child: Obx(() {
              if (prodController.isLoading.value &&
                  prodController.productList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = prodController.filteredList;

              return ListView.builder(
                controller: prodController.scrollController,
                itemCount:
                    list.length +
                    (prodController.isMoreDataAvailable.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == list.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text("")),
                    );
                  }

                  return GestureDetector(
                    // onTap: () {
                    //   Get.to(() => Details(product: list[index], ));
                    // },
                    child: _ProductCard(product: list[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final All product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prices = widget.product.price ?? [];
    final selectedPrice = prices.isNotEmpty ? prices[selectedIndex].price : 0;
    TextEditingController searchcontroller = TextEditingController();
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // print("CLICKED PRODUCT: ${product.productName}");
            // print("ID PASSED: ${product.id}");

            Get.to(
              () => const Details(),
              arguments: {
                "id": widget.product.id, // ✅ ONLY ID
              },
            );
          },

          child: Container(
            height: 230,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "lib/assets/images/Capture.png",
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.product.productShortDescription ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (prices.isNotEmpty)
                  SizedBox(
                    height: 36,
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
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              prices[index].size ?? "",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "₹$selectedPrice",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 230,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Add to menu",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
