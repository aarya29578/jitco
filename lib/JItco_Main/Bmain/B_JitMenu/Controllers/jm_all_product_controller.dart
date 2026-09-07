// // lib/screens/Bmain/Jitco Menu/Controllers/jm_all_products_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/controllers/auth_controllers.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Models/categorymodel.dart';
// import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Services/api.dart';

// class AllProductsController extends GetxController {
//   final JMApiService _service = JMApiService();

//   // Data storage - for all products
//   final RxList<All> productList = <All>[].obs;
//   final RxList<All> searchedProducts = <All>[].obs;
//   final RxList<All> filteredList = <All>[].obs;

//   // State
//   final RxString warehouseId = ''.obs;

//   // Loading states
//   RxBool isLoading = false.obs;
//   RxBool isMoreDataAvailable = true.obs;
//   RxBool isSearching = false.obs;
//   RxBool isSearchMoreDataAvailable = true.obs;

//   // Search
//   RxString searchQuery = ''.obs;

//   // Pagination
//   int currentPage = 1;
//   int searchPage = 1;
//   final int limit = 20;

//   final ScrollController scrollController = ScrollController();

//   @override
//   void onInit() {
//     super.onInit();
//     print("AllProductsController initialized");
//     scrollController.addListener(_onScroll);

//     ever(searchQuery, (_) {
//       if (searchQuery.value.isNotEmpty) {
//         isSearching.value = true;
//         _searchProducts();
//       } else {
//         _filterProducts();
//       }
//     });
//   }

//   void initialize({required String warehouseId}) {
//     print("=== Initializing AllProductsController ===");

//     // Clear all previous data
//     productList.clear();
//     searchedProducts.clear();
//     filteredList.clear();

//     // Set new state
//     this.warehouseId.value = warehouseId;

//     // Reset pagination
//     currentPage = 1;
//     searchPage = 1;
//     isMoreDataAvailable.value = true;
//     isSearchMoreDataAvailable.value = true;

//     // Clear search
//     searchQuery.value = '';
//     isSearching.value = false;

//     // Fetch products
//     fetchProducts();
//   }

//   void _onScroll() {
//     if (scrollController.position.pixels >=
//             scrollController.position.maxScrollExtent &&
//         !isLoading.value) {
//       if (searchQuery.value.isNotEmpty) {
//         if (isSearchMoreDataAvailable.value && !isSearching.value) {
//           _searchProducts(loadMore: true);
//         }
//       } else {
//         if (isMoreDataAvailable.value) {
//           fetchProducts();
//         }
//       }
//     }
//   }

//   Future<void> fetchProducts() async {
//     if (warehouseId.value.isEmpty) {
//       print("Cannot fetch all products: missing warehouse");
//       return;
//     }

//     if (isLoading.value || !isMoreDataAvailable.value) {
//       return;
//     }

//     try {
//       isLoading.value = true;

//       print("Fetching ALL products - Page: $currentPage");

//       final auth = Get.find<AuthController>();

//       // IMPORTANT: No category slug passed for all products
//       final rawList = await _service.fetchProducts(
//         warehouseId: warehouseId.value,
//         page: currentPage,
//         limit: limit,
//         userId: auth.userId.toString(),
//         categorySlug: null, // Null for all products
//       );

//       print("Received ${rawList.length} ALL products");

//       if (rawList.isEmpty) {
//         isMoreDataAvailable.value = false;
//       } else {
//         final newProducts = rawList.map((e) => All.fromJson(e)).toList();
//         productList.addAll(newProducts);
//         _filterProducts();
//         currentPage++;
//       }
//     } catch (e) {
//       debugPrint("All Products API ERROR: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> _searchProducts({bool loadMore = false}) async {
//     if (warehouseId.value.isEmpty) {
//       return;
//     }

//     if (searchQuery.value.isEmpty) {
//       _filterProducts();
//       return;
//     }

//     if (!loadMore) {
//       searchPage = 1;
//       searchedProducts.clear();
//       isSearchMoreDataAvailable.value = true;
//     }

//     if (isSearching.value || !isSearchMoreDataAvailable.value) {
//       return;
//     }

//     try {
//       isSearching.value = true;

//       final auth = Get.find<AuthController>();

//       // IMPORTANT: No categoryId for all products search
//       final rawList = await _service.searchProducts(
//         query: searchQuery.value,
//         warehouseId: warehouseId.value,
//         userId: auth.userId.toString(),
//         page: searchPage,
//         limit: limit,
//         categoryId: null, // Null for all products
//       );

//       print("***rawlist:$rawList");

//       if (rawList.isEmpty) {
//         isSearchMoreDataAvailable.value = false;
//       } else {
//         final newProducts = rawList.map((e) => All.fromJson(e)).toList();
//         searchedProducts.addAll(newProducts);
//         _filterProducts();
//         searchPage++;
//       }
//     } catch (e) {
//       debugPrint("All Products Search API ERROR: $e");
//     } finally {
//       isSearching.value = false;
//     }
//   }

//   void _filterProducts() {
//     if (searchQuery.value.isEmpty) {
//       filteredList.value = List.from(productList);
//     } else {
//       filteredList.value = List.from(searchedProducts);
//     }
//   }

//   void clearSearch() {
//     searchQuery.value = '';
//     isSearching.value = false;
//     _filterProducts();
//   }

//   @override
//   void onClose() {
//     print("AllProductsController closing");
//     scrollController.dispose();
//     super.onClose();
//   }
// }

// lib/screens/Bmain/Jitco Menu/Controllers/jm_all_products_controller.dart
// lib/screens/Bmain/Jitco Menu/Controllers/jm_all_products_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

class AllProductsController extends GetxController {
  final JMApiService _service = JMApiService();

  // Data storage - for all products
  final RxList<All> productList = <All>[].obs;
  final RxList<All> searchedProducts = <All>[].obs;
  final RxList<All> filteredList = <All>[].obs;

  // State
  // final RxString warehouseId = ''.obs;
  final RxnString warehouseId = RxnString(); // nullable reactive string

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxBool isSearching = false.obs;
  RxBool isSearchMoreDataAvailable = true.obs;

  // Search
  RxString searchQuery = ''.obs;
  Timer? _searchDebounce;

  // Pagination
  int currentPage = 1;
  int searchPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    print("AllProductsController initialized");
    scrollController.addListener(_onScroll);

    // Listen for search query changes with debounce
    ever(searchQuery, (String query) {
      _debounceSearch(query);
    });
  }

  void _debounceSearch(String query) {
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      // Clear search immediately
      clearSearch();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    print("=== _performSearch called ===");
    print("Query: '$query'");
    print("Warehouse ID: ${warehouseId.value}");

    // if (warehouseId.value.isEmpty) {
    //   print("Cannot search: warehouseId is empty");
    //   return;
    // }

    if (isSearching.value) {
      print("Already searching, skipping...");
      return;
    }

    // Clear previous search data
    searchedProducts.clear();
    filteredList.clear();
    searchPage = 1;
    isSearchMoreDataAvailable.value = true;

    print("Calling _searchProducts()");
    _searchProducts();
  }

  void initialize({String? warehouseId}) {
    print("=== Initializing AllProductsController ===");

    // Cancel any pending search
    _searchDebounce?.cancel();

    // Clear all previous data
    productList.clear();
    searchedProducts.clear();
    filteredList.clear();

    // Set new state
    this.warehouseId.value = warehouseId;

    // Reset pagination
    currentPage = 1;
    searchPage = 1;
    isMoreDataAvailable.value = true;
    isSearchMoreDataAvailable.value = true;

    // Clear search
    searchQuery.value = '';
    isSearching.value = false;

    // Fetch products
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
    // if (warehouseId.value.isEmpty) {
    //   print("Cannot fetch all products: missing warehouse");
    //   return;
    // }

    if (isLoading.value || !isMoreDataAvailable.value) {
      return;
    }

    try {
      isLoading.value = true;

      print("Fetching ALL products - Page: $currentPage");

      final auth = Get.find<AuthController>();

      // IMPORTANT: No category slug passed for all products
      final rawList = await _service.fetchProducts(
        warehouseId: warehouseId.value,
        page: currentPage,
        limit: limit,
        userId: auth.userId.toString(),
        categorySlug: null, // Null for all products
      );

      print("Received ${rawList.length} ALL products");

      if (rawList.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        final newProducts = rawList.map((e) => All.fromJson(e)).toList();
        productList.addAll(newProducts);
        _filterProducts();
        currentPage++;
      }
    } catch (e) {
      debugPrint("All Products API ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _searchProducts({bool loadMore = false}) async {
    print("=== _searchProducts called ===");
    print("Warehouse ID: ${warehouseId.value}");
    print("Search Query: '${searchQuery.value}'");
    print("Load More: $loadMore");
    print("isSearching before: ${isSearching.value}");

    // if (warehouseId.value.isEmpty) {
    //   print("ERROR: warehouseId is empty, cannot search!");
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
      print("Starting new search, page reset to 1");
    }

    if (isSearching.value) {
      print("Already searching, aborting new search request");
      return;
    }

    if (!isSearchMoreDataAvailable.value) {
      print("No more search data available");
      return;
    }

    try {
      isSearching.value = true;
      print("Search started - isSearching set to true");

      final auth = Get.find<AuthController>();
      final userId = auth.userId.toString();

      print("User ID: $userId");
      print("Searching for '${searchQuery.value}' - Page: $searchPage");

      // IMPORTANT: No categoryId for all products search
      print("Calling _service.searchProducts()...");
      final rawList = await _service.searchProducts(
        query: searchQuery.value,
        warehouseId: warehouseId.value,
        userId: userId,
        page: searchPage,
        limit: limit,
        categoryId: null, // Null for all products
      );

      print("=== Search API Response ===");
      print("Raw list type: ${rawList.runtimeType}");
      print("Raw list length: ${rawList.length}");
      print("Raw list content: $rawList");

      if (rawList.isEmpty) {
        print("No search results found");
        isSearchMoreDataAvailable.value = false;
      } else {
        print("Found ${rawList.length} search results");
        final newProducts = rawList.map((e) => All.fromJson(e)).toList();
        searchedProducts.addAll(newProducts);
        print("Added ${newProducts.length} new products to searchedProducts");
        searchPage++;
      }

      // Always update filtered list, even on empty results
      _filterProducts();
    } catch (e, stackTrace) {
      print("=== Search API ERROR ===");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      debugPrint("All Products Search API ERROR: $e");

      // Even on error, we need to update filtered list
      _filterProducts();
    } finally {
      isSearching.value = false;
      print("Search completed - isSearching set to false");
    }
  }

  void _filterProducts() {
    print("=== _filterProducts called ===");
    print("Search Query: '${searchQuery.value}'");
    print("Product list length: ${productList.length}");
    print("Searched products length: ${searchedProducts.length}");

    if (searchQuery.value.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = List.from(searchedProducts);
    }

    print("Filtered list now has ${filteredList.length} items");
  }

  void clearSearch() {
    print("=== clearSearch called ===");
    _searchDebounce?.cancel();
    searchQuery.value = '';
    isSearching.value = false;
    _filterProducts();
  }

  @override
  void onClose() {
    print("AllProductsController closing");
    _searchDebounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
