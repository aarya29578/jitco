// lib/screens/Bmain/Jitco Menu/Controllers/jm_category_products_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

class CategoryProductsController extends GetxController {
  final JMApiService _service = JMApiService();

  // Data storage - specific to category
  final RxList<All> productList = <All>[].obs;
  final RxList<All> searchedProducts = <All>[].obs;
  final RxList<All> filteredList = <All>[].obs;

  // State
  final RxString warehouseId = ''.obs;
  final RxString categorySlug = ''.obs;
  final RxString categoryId = ''.obs;
  final RxString categoryName = ''.obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxBool isSearching = false.obs;
  RxBool isSearchMoreDataAvailable = true.obs;

  // Search
  RxString searchQuery = ''.obs;

  // Pagination
  int currentPage = 1;
  int searchPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  // @override
  // void onInit() {
  //   super.onInit();
  //   print("CategoryProductsController initialized");
  //   scrollController.addListener(_onScroll);

  //   ever(searchQuery, (_) {
  //     if (searchQuery.value.isNotEmpty) {
  //       isSearching.value = true;
  //       _searchProducts();
  //     } else {
  //       _filterProducts();
  //     }
  //   });
  // }

  @override
  void onInit() {
    super.onInit();
    print("CategoryProductsController initialized");
    scrollController.addListener(_onScroll);

    // Use debounce instead of immediate search
    debounce(searchQuery, (String query) {
      if (query.isNotEmpty) {
        print("Search query changed to: '$query'");
        _performSearch(query);
      } else {
        print("Search query cleared");
        _filterProducts();
      }
    }, time: Duration(milliseconds: 500));
  }

  void _performSearch(String query) {
    print("_performSearch called for: '$query'");

    if (isSearching.value) {
      print("Already searching, will retry in 1 second...");
      // Retry after 1 second if still searching
      Future.delayed(Duration(seconds: 1), () {
        if (isSearching.value) {
          print("Still searching, forcing reset...");
          isSearching.value = false;
          _searchProducts();
        }
      });
      return;
    }

    // Clear previous search data
    searchedProducts.clear();
    filteredList.clear();
    searchPage = 1;
    isSearchMoreDataAvailable.value = true;

    // Trigger search
    _searchProducts();
  }

  // void initialize({
  //   required String warehouseId,
  //   required String categorySlug,
  //   required String categoryId,
  //   required String categoryName,
  // }) {
  //   print("=== Initializing CategoryProductsController ===");
  //   print("Category: $categoryName, Slug: $categorySlug");

  //   // Clear all previous data
  //   productList.clear();
  //   searchedProducts.clear();
  //   filteredList.clear();

  //   // Set new state
  //   this.warehouseId.value = warehouseId;
  //   this.categorySlug.value = categorySlug;
  //   this.categoryId.value = categoryId;
  //   this.categoryName.value = categoryName;

  //   // Reset pagination
  //   currentPage = 1;
  //   searchPage = 1;
  //   isMoreDataAvailable.value = true;
  //   isSearchMoreDataAvailable.value = true;

  //   // Clear search
  //   searchQuery.value = '';
  //   isSearching.value = false;

  //   // Fetch products
  //   fetchProducts();
  // }
  void initialize({
    String? warehouseId,
    required String categorySlug,
    required String categoryId,
    required String categoryName,
  }) {
    print("=== Initializing CategoryProductsController ===");
    print("Category: $categoryName, Slug: $categorySlug");
    print("Warehouse ID: $warehouseId"); // Add this debug print

    // Clear all previous data
    productList.clear();
    searchedProducts.clear();
    filteredList.clear();

    // Set new state
    this.warehouseId.value = warehouseId ?? '';
    this.categorySlug.value = categorySlug;
    this.categoryId.value = categoryId;
    this.categoryName.value = categoryName;

    // Reset pagination
    currentPage = 1;
    searchPage = 1;
    isMoreDataAvailable.value = true;
    isSearchMoreDataAvailable.value = true;

    // Clear search
    searchQuery.value = '';
    isSearching.value = false;

    // Fetch products - NOW warehouseId is set
    fetchProducts();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent &&
        !isLoading.value) {
      if (searchQuery.value.isNotEmpty) {
        if (isSearchMoreDataAvailable.value && !isSearching.value) {
          _searchProducts(loadMore: true);
        }
      } else {
        if (isMoreDataAvailable.value) {
          fetchProducts();
        }
      }
    }
  }

  Future<void> fetchProducts() async {
    // if (warehouseId.value.isEmpty || categorySlug.value.isEmpty) {
    //   print("Cannot fetch category products: missing warehouse or category");
    //   return;
    // }

    if (isLoading.value || !isMoreDataAvailable.value) {
      print("🚀 fetchProducts CALLED");
      print("isLoading: ${isLoading.value}");
      print("isMoreDataAvailable: ${isMoreDataAvailable.value}");
      return;
    }

    try {
      isLoading.value = true;

      print(
        "Fetching category products - Page: $currentPage, Category: ${categoryName.value}",
      );

      final auth = Get.find<AuthController>();

      final rawList = await _service.fetchProducts(
        warehouseId: warehouseId.value != '' ? warehouseId.value : null,
        page: currentPage,
        limit: limit,
        userId: auth.userId.toString(),
        categorySlug: categorySlug.value, // Always pass category slug
      );

      print("Received ${rawList.length} category products");

      if (rawList.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        final newProducts = rawList.map((e) => All.fromJson(e)).toList();
        productList.addAll(newProducts);
        _filterProducts();
        currentPage++;
      }
    } catch (e) {
      debugPrint("Category Products API ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> _searchProducts({bool loadMore = false}) async {
  //   if (warehouseId.value.isEmpty || categorySlug.value.isEmpty) {
  //     return;
  //   }

  //   if (searchQuery.value.isEmpty) {
  //     _filterProducts();
  //     return;
  //   }

  //   if (!loadMore) {
  //     searchPage = 1;
  //     searchedProducts.clear();
  //     isSearchMoreDataAvailable.value = true;
  //   }

  //   if (isSearching.value || !isSearchMoreDataAvailable.value) {
  //     return;
  //   }

  //   try {
  //     isSearching.value = true;

  //     final auth = Get.find<AuthController>();

  //     final rawList = await _service.searchProducts(
  //       query: searchQuery.value,
  //       warehouseId: warehouseId.value,
  //       userId: auth.userId.toString(),
  //       page: searchPage,
  //       limit: limit,
  //       categoryId: categoryId.value,
  //     );

  //     if (rawList.isEmpty) {
  //       isSearchMoreDataAvailable.value = false;
  //     } else {
  //       final newProducts = rawList.map((e) => All.fromJson(e)).toList();
  //       searchedProducts.addAll(newProducts);
  //       _filterProducts();
  //       searchPage++;
  //     }
  //   } catch (e) {
  //     debugPrint("Category Search API ERROR: $e");
  //   } finally {
  //     isSearching.value = false;
  //   }
  // }

  // Update the _searchProducts method in CategoryProductsController
  // Update the _searchProducts method in CategoryProductsController
  Future<void> _searchProducts({bool loadMore = false}) async {
    print("🔍 === _searchProducts called ===");
    print("Warehouse ID: ${warehouseId.value}");
    print("Search Query: '${searchQuery.value}'");
    print("Load More: $loadMore");
    print("isSearching before: ${isSearching.value}");

    // if (warehouseId.value.isEmpty || categorySlug.value.isEmpty) {
    //   print("⚠️ Cannot search: warehouseId or categorySlug is empty");
    //   return;
    // }

    if (searchQuery.value.isEmpty) {
      print("Search query is empty, filtering products...");
      _filterProducts();
      return;
    }

    if (!loadMore) {
      searchPage = 1;
      searchedProducts.clear();
      isSearchMoreDataAvailable.value = true;
      print("🔄 Starting new search, page reset to 1");
    }

    // Check if already searching - IMPORTANT: Add a timeout check
    if (isSearching.value) {
      print("⚠️ Already searching, but checking if it's stuck...");

      // If it's been searching for too long (e.g., > 10 seconds), reset it
      // You can add a timestamp check here if needed
      // For now, just log and return
      return;
    }

    if (!isSearchMoreDataAvailable.value) {
      print("No more search data available");
      return;
    }

    try {
      isSearching.value = true;
      print("✅ Search started for: '${searchQuery.value}'");

      final auth = Get.find<AuthController>();

      print("📡 Calling search API with:");
      print("  Query: ${searchQuery.value}");
      print("  Warehouse: ${warehouseId.value}");
      print("  Category ID: ${categoryId.value}");
      print("  Page: $searchPage");

      final rawList = await _service.searchProducts(
        query: searchQuery.value,
        warehouseId: warehouseId.value,
        userId: auth.userId.toString(),
        page: searchPage,
        limit: limit,
        categoryId: categoryId.value,
      );

      print("✅ Search API returned ${rawList.length} items");

      if (rawList.isEmpty) {
        print("No search results found");
        isSearchMoreDataAvailable.value = false;
      } else {
        print("🔄 Parsing ${rawList.length} search results...");

        final List<All> newProducts = [];

        for (var item in rawList) {
          try {
            if (item is Map<String, dynamic>) {
              final product = All.fromJson(item);
              if (product.id.isNotEmpty && product.id != "error") {
                newProducts.add(product);
              } else {
                print("⚠️ Skipping invalid product");
              }
            } else {
              print("⚠️ Item is not a Map: ${item.runtimeType}");
            }
          } catch (e, stackTrace) {
            print("❌ Error parsing search result:");
            print("  Error: $e");
            print("  Stack trace: $stackTrace");
            print("  Problematic item: $item");
          }
        }

        print("✅ Successfully parsed ${newProducts.length} products");
        searchedProducts.addAll(newProducts);
        _filterProducts();
        searchPage++;
      }
    } catch (e, stackTrace) {
      print("❌ Search API ERROR:");
      print("  Error: $e");
      print("  Stack trace: $stackTrace");
      debugPrint("Category Search API ERROR: $e");

      // Even on error, update filtered list
      _filterProducts();
    } finally {
      // ALWAYS set isSearching to false in finally block
      isSearching.value = false;
      print("🏁 Search completed - isSearching set to false");
    }
  }

  void _filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = List.from(searchedProducts);
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    _filterProducts();
  }

  @override
  void onClose() {
    print("CategoryProductsController closing");
    scrollController.dispose();
    super.onClose();
  }
}
