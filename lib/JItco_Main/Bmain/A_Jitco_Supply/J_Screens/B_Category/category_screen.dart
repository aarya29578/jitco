import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/PostModel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/C_Universal_Product/universal_product_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // final AuthController _authController = Get.find<AuthController>();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;

  List<CategoryData> displayedCategories = [];

  int _currentPage = 1;
  static const int _limit = 20;
  int _totalPages = 1;
  bool isLoadingInitial = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  String _searchText = "";

  final ApiServices _apiService = Get.find<ApiServices>();

  @override
  void initState() {
    super.initState();
    fetchProducts(isInitial: true);
    _scrollController.addListener(_onScroll);
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoadingMore) {
        _currentPage++;
        fetchProducts(isInitial: false);
      }
    }
  }

  Future<void> fetchProducts({required bool isInitial}) async {
    if (!hasMore && !isInitial) return;

    if (isInitial) {
      if (mounted) setState(() => isLoadingInitial = true);
    } else {
      if (mounted) setState(() => isLoadingMore = true);
    }

    try {
      final result = await _apiService.fetchProductCategories(
        page: _currentPage,
        limit: _limit,
        search: _searchText,
      );

      if (mounted) {
        setState(() {
          _totalPages = (result.totalPages ?? 1).toInt();
          // _totalPages = int.tryParse(result.totalPages?.toString() ?? '1') ?? 1;

          if (result.data != null) {
            if (isInitial) {
              displayedCategories = result.data!;
            } else {
              displayedCategories.addAll(result.data!);
            }
          }

          hasMore = _currentPage < _totalPages;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      // You can show a snackbar or dialog for error handling
    }

    if (mounted) {
      setState(() {
        isLoadingInitial = false;
        isLoadingMore = false;
      });
    }
  }

  void _onCategoryTap(CategoryData category) {
    Get.to(
      () => UniversalProductScreen(
        id: category.id,
        categorySlug: category.slug,
        categoryName: category.categoryName,
        isBrandScreen: false, // This is a category screen, not brand
      ),
      transition: Transition.rightToLeft,
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => UniversalProductScreen(
    //       id: category.id,
    //       categorySlug: category.slug,
    //       categoryName: category.categoryName,
    //       isBrandScreen: false, // This is a category screen, not brand
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.orange.shade700,
      appBar: AppBar(
        surfaceTintColor: Colors.orange.shade700,
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        title: const Text(
          "Explore Our Categories",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              10.heightBox,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                // child: TextField(
                //   controller: _searchController,
                //   focusNode: _searchFocus,
                //   decoration: const InputDecoration(
                //     hintText: "Search categories...",
                //     prefixIcon: Icon(Icons.search, color: Colors.orange),
                //     border: InputBorder.none,
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 15,
                //     ),
                //   ),
                //   onChanged: (value) {
                //     if (!_searchFocus.hasFocus) {
                //       _searchFocus.requestFocus();
                //     }

                //     if (_debounce?.isActive ?? false) _debounce!.cancel();

                //     _debounce = Timer(const Duration(milliseconds: 350), () {
                //       _searchText = value;
                //       _currentPage = 1;
                //       displayedCategories.clear();
                //       fetchProducts(isInitial: true);
                //     });
                //   },
                // ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,

                  decoration: InputDecoration(
                    hintText: "Search categories...",
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    /// CANCEL BUTTON
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear(); // Clear UI instantly

                              _searchText = ""; // Reset search state
                              _currentPage = 1;
                              displayedCategories.clear();

                              fetchProducts(isInitial: true); //Reload full list

                              setState(() {}); // Rebuild to hide icon
                            },
                          )
                        : null,
                  ),

                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();

                    setState(() {}); // Rebuild → show/hide cancel icon

                    _debounce = Timer(const Duration(milliseconds: 350), () {
                      _searchText = value;
                      _currentPage = 1;
                      displayedCategories.clear();
                      fetchProducts(isInitial: true);
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: isLoadingInitial
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                    : displayedCategories.isEmpty
                    ? const Center(
                        child: Text(
                          "No categories found!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount:
                            displayedCategories.length +
                            (isLoadingMore ? 1 : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                        itemBuilder: (context, index) {
                          if (index == displayedCategories.length) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            );
                          }

                          final category = displayedCategories[index];

                          return GestureDetector(
                            onTap: () => _onCategoryTap(category),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      category.image ?? "",
                                      height: 90,
                                      width: 90,
                                      // fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Center(
                                      child: Text(
                                        category.categoryName ?? "No Name",
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
