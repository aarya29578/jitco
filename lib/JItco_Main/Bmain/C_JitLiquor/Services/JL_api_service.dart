import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Liquior/categorymodel/categorymodel/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JlApiService extends GetxService {
  final Dio _dio = Dio();
  // final String jitUrl = "https://jitco.salt-tech.com/api/v1";

  /// Get saved token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> jlPostOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    try {
      final authController = Get.find<AuthController>();

      print('=== POST ORDER API CALL ===');
      print('URL: $jitUrl/orders/source=Liquor');
      print('Payload: $orderPayload');

      final response = await _dio.post(
        '$jitUrl/orders?source=Liquor',
        data: orderPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );

      print('=== POST ORDER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Order placed successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to place order',
          'data': response.data,
        };
      }
    } on DioException catch (e) {
      print('=== DIO EXCEPTION IN POST ORDER ===');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        Get.find<AuthController>().logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Order failed: ${e.message}',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> jlGetOrder({
    int page = 1,
    int limit = 20,
    String status = 'All',
  }) async {
    try {
      // Check if Dio is initialized
      // if (_dio == null) {
      //   print('Dio is not initialized. Calling init()...');
      //   await init();
      // }
      final AuthController authController = Get.find<AuthController>();
      final response = await _dio.get(
        '$jitUrl/orders?page=$page&limit=$limit&status=$status&source=Liquor',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print('get getOrder**************** $result');

        //the response structure here --
        return result;
      } else {
        print(" API Error: ${response.statusCode}");
        throw Exception('Failed to get getOrder: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Dio Error in getOrder: $e');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in getOrder: $e');
      throw Exception('Unexpected error from getOrder: $e');
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
}

// class CategoryController extends GetxController {
//   final Dio dio = Dio();

//   RxBool isLoading = false.obs;
//   RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

//   @override
//   void onInit() {
//     fetchCategories();
//     super.onInit();
//   }

//   Future<void> fetchCategories({int page = 1, int limit = 20}) async {
//     try {
//       isLoading.value = true;

//       final response = await dio.get(
//         "https://jitco.salt-tech.com/api/v1/public/product/category?page=$page&limit=$limit&source=JitMenu",
//       );

//       if (response.statusCode == 200) {
//         final List data = response.data['data'];
//         categoryList.value = data
//             .map((e) => CategoryModel.fromJson(e))
//             .toList();
//       }
//     } catch (e) {
//       print("API Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

class ProductsController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  late String categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"] ?? "";

    if (categorySlug.isEmpty) return;

    // FIRST CALL
    fetchProducts(categorySlug, reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts(categorySlug); // ✅ ONLY HERE
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts(String categorySlug, {bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    if (reset) {
      currentPage = 1;
      productList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/jitmenu/public/product",
        queryParameters: {
          "category": categorySlug,
          "page": currentPage,
          "limit": limit,
        },
      );

      final List list = response.data["products"] ?? [];

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(list.map((e) => ProductModel.fromJson(e)).toList());
        currentPage++;
      }
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class allproducts extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<All> productList = <All>[].obs;

  RxString searchQuery = "".obs; // 🔹 search query
  RxList<All> filteredList = <All>[].obs; // 🔹 filtered list

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();
  String? categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"];

    fetchProducts(reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts();
      }
    });

    // 🔹 search listener
    ever(searchQuery, (_) => _filterProducts());
  }

  void _filterProducts() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = productList
          .where((p) => p?.productName?.toLowerCase().contains(query) ?? false)
          .toList();
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    if (reset) {
      currentPage = 1;
      productList.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/jitmenu/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "sort": "latest",
          if (categorySlug != null && categorySlug!.isNotEmpty)
            "category": categorySlug,
        },
      );

      final List list = response.data["products"] ?? [];

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(list.map((e) => All.fromJson(e)).toList());
        currentPage++;
      }

      _filterProducts(); // 🔹 update filtered list
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class categoryfetch extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<CategoryModel> productList = <CategoryModel>[].obs;

  RxString searchQuery = "".obs; // 🔹 search query
  RxList<CategoryModel> filteredList =
      <CategoryModel>[].obs; // 🔹 filtered list

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();
  String? categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"];

    fetchProducts(reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts();
      }
    });

    // 🔹 search listener
    ever(searchQuery, (_) => _filterProducts());
  }

  void _filterProducts() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = productList
          .where((p) => p?.name?.toLowerCase().contains(query) ?? false)
          .toList();
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    if (reset) {
      currentPage = 1;
      productList.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/jitmenu/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "sort": "latest",
          if (categorySlug != null && categorySlug!.isNotEmpty)
            "category": categorySlug,
        },
      );

      final List list = response.data["products"] ?? [];

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(list.map((e) => CategoryModel.fromJson(e)).toList());
        currentPage++;
      }

      _filterProducts(); // 🔹 update filtered list
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class categoryliqfetch extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<liqourModel> productList = <liqourModel>[].obs;

  RxString searchQuery = "".obs; // 🔹 search query
  RxList<liqourModel> filteredList = <liqourModel>[].obs; // 🔹 filtered list

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();
  String? categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"];

    fetchProducts(reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts();
      }
    });

    // 🔹 search listener
    ever(searchQuery, (_) => _filterProducts());
  }

  void _filterProducts() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = productList
          .where((p) => p?.name?.toLowerCase().contains(query) ?? false)
          .toList();
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    if (reset) {
      currentPage = 1;
      productList.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/liquor/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "sort": "latest",
          if (categorySlug != null && categorySlug!.isNotEmpty)
            "category": categorySlug,
        },
      );

      final List list = response.data["products"] ?? [];

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(list.map((e) => liqourModel.fromJson(e)).toList());
        currentPage++;
      }

      _filterProducts(); // 🔹 update filtered list
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class WinesProductController extends GetxController {
  final String category;
  WinesProductController({required this.category});
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<CategorysModel> productLists = <CategorysModel>[].obs;

  RxString searchQuery = "".obs;
  RxList<CategorysModel> filteredList = <CategorysModel>[].obs;

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    fetchProducts(reset: true, category: category);

    scrollController.addListener(_onScroll);

    ever(searchQuery, (_) => _filterProducts());
  }

  // void _onScroll() {
  //   if (!scrollController.hasClients) return;

  //   final position = scrollController.position;
  //   // Trigger when near bottom (300px threshold for smoother feel)
  //   if (position.pixels >= position.maxScrollExtent - 300 &&
  //       !isLoading.value &&
  //       isMoreDataAvailable.value) {
  //     fetchProducts();
  //   }
  // }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // Load more only when user is very close to bottom
    final bool isNearBottom = position.pixels >= position.maxScrollExtent - 100;

    // Safety: only trigger after enough items are rendered
    final bool hasEnoughItems = productLists.length >= limit;

    if (isNearBottom &&
        hasEnoughItems &&
        !isLoading.value &&
        isMoreDataAvailable.value) {
      fetchProducts();
    }
  }

  void _filterProducts() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(productLists);
    } else {
      filteredList.assignAll(
        productLists
            .where((p) => (p.productName ?? '').toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  Future<void> fetchProducts({bool reset = false, String? category}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    double? oldOffset; // ← save current scroll position
    if (!reset && scrollController.hasClients) {
      oldOffset = scrollController.offset;
    }

    if (reset) {
      currentPage = 1;
      productLists.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    isLoading.value = true;

    try {
      final response = await dio.get(
        "$jitUrl/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "source": "Liquor",
          "category": category, // ← only wines, as you want
          "slug": "true",
          "sort": "latest",
        },
      );

      final List<dynamic> products = response.data["products"] ?? [];

      if (products.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        final newItems = products
            .map((e) => CategorysModel.fromJson(e))
            .toList();
        productLists.addAll(newItems);
        currentPage++;
      }

      _filterProducts(); // refresh filtered

      // ← Restore scroll position after rebuild (prevents jump to top)
      if (oldOffset != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(oldOffset!);
          }
        });
      }
    } catch (e, stack) {
      debugPrint("API ERROR: $e\n$stack");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll); // ← correct cleanup
    scrollController.dispose();
    super.onClose();
  }
}

class WinesLiqFetch extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxList<CategorysModel> list = <CategorysModel>[].obs;

  RxString searchQuery = "".obs;
  RxList<CategorysModel> filteredLists = <CategorysModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchCategories();

    // 🔥 Listen to search query changes
    debounce(
      searchQuery,
      (_) => applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/public/product?page=1&limit=20&source=Liquor&category=wines&slug=true",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final List products =
            response.data['products'] ??
            []; // ← changed from 'data' to 'products'

        list.value = products.map((e) => CategorysModel.fromJson(e)).toList();

        filteredLists.assignAll(list);
      }
    } catch (e, stack) {
      print("API Error: $e");
      print("Stack: $stack"); // helpful for debugging
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 Search logic
  void applySearch() {
    if (searchQuery.value.isEmpty) {
      filteredLists.assignAll(list);
    } else {
      filteredLists.assignAll(
        list.where(
          (item) => item.productName!.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        ),
      );
    }
  }
}

// class JLCategoryController extends GetxController {
//   final Dio dio = Dio();

//   RxBool isLoading = false.obs;
//   RxList<CategoryModel> liqourList = <CategoryModel>[].obs;

//   RxString searchQuery = "".obs;

//   @override
//   void onInit() {
//     super.onInit();

//     fetchCategories();

//     // ✅ API SEARCH
//     debounce(
//       searchQuery,
//       (_) => fetchCategories(),
//       time: const Duration(milliseconds: 400),
//     );
//   }

//   Future<void> fetchCategories() async {
//     try {
//       isLoading.value = true;

//       final response = await dio.get(
//         "https://jitco.salt-tech.com/api/v1/public/product/category",
//         queryParameters: {
//           "page": 1,
//           "limit": 20,
//           "source": "Liquor",
//           if (searchQuery.value.isNotEmpty)
//             "search": searchQuery.value, // ✅ FIXED
//         },
//         options: Options(
//           headers: {"Content-Type": "application/json"},
//         ),
//       );

//       if (response.statusCode == 200) {
//         final List data = response.data['data'];

//         liqourList.value =
//             data.map((e) => CategoryModel.fromJson(e)).toList();
//       }
//     } catch (e) {
//       print("API Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

class JLCategoryController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isMoreDataAvailable = true.obs;

  RxList<CategoryModel> liqourList = <CategoryModel>[].obs;

  RxString searchQuery = "".obs;

  int page = 1;
  final int limit = 20;

  @override
  void onInit() {
    super.onInit();

    fetchCategories(reset: true);

    // ✅ SEARCH + PAGINATION RESET
    debounce(
      searchQuery,
      (_) => fetchCategories(reset: true),
      time: const Duration(milliseconds: 400),
    );
  }

  Future<void> fetchCategories({bool reset = false}) async {
    try {
      if (reset) {
        page = 1;
        isMoreDataAvailable.value = true;
        isLoading.value = true;
      } else {
        if (!isMoreDataAvailable.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      }

      final response = await dio.get(
        "$jitUrl/public/product/category",
        queryParameters: {
          "page": page,
          "limit": limit,
          "source": "Liquor",
          if (searchQuery.value.isNotEmpty) "search": searchQuery.value,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];

        final newList = data.map((e) => CategoryModel.fromJson(e)).toList();

        if (reset) {
          liqourList.assignAll(newList);
        } else {
          liqourList.addAll(newList);
        }

        // ✅ CHECK MORE DATA
        if (newList.length < limit) {
          isMoreDataAvailable.value = false;
        } else {
          page++;
        }
      }
    } catch (e) {
      print("API Error: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ✅ CALL THIS FROM SCROLL
  void loadMore() {
    fetchCategories();
  }
}

class LiquorController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;

  /// 🔥 Products list
  RxList<CategorysModel> liqourList = <CategorysModel>[].obs;
  RxList<CategorysModel> filteredList = <CategorysModel>[].obs;

  RxString searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();

    /// 🔍 debounce search
    debounce(
      searchQuery,
      (_) => applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  /// 🧠 FETCH PRODUCTS
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      /////////////////https://jitco.salt-tech.com/api/v1/public/product?page=1&limit=20&source=Liquor&category=spirits&slug=true

      final response = await dio.get(
        "$jitUrl/public/product",
        queryParameters: {
          "page": 1,
          "limit": 20,
          "source": "Liquor",
          "category": "spirits",
          "slug": true,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final List data = response.data['products']; // ✅ IMPORTANT

        liqourList.value = data.map((e) => CategorysModel.fromJson(e)).toList();

        /// initially show all
        filteredList.assignAll(liqourList);
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔍 SEARCH PRODUCTS
  void applySearch() {
    if (searchQuery.value.isEmpty) {
      filteredList.assignAll(liqourList);
    } else {
      filteredList.assignAll(
        liqourList.where(
          (item) => item.productName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        ),
      );
    }
  }
}

class liqproController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<liqModel> liqList = <liqModel>[].obs;

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  late String categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"] ?? "";

    if (categorySlug.isEmpty) return;

    // FIRST CALL
    fetchProducts(categorySlug, reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts(categorySlug); // ✅ ONLY HERE
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts(String categorySlug, {bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage = 1;
      liqList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "source": "Liquor",
          "user_id": "68107ebd454e265270c26caa", // assign correct user id
          "category": categorySlug,
          "slug": true,
        },
      );

      debugPrint("API RESPONSE 👉 ${response.data}");

      final List products = response.data["products"] ?? [];

      if (products.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        liqList.addAll(products.map((e) => liqModel.fromJson(e)).toList());
        currentPage++;
      }
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class JLAllProductsController extends GetxController {
  final String? categorySlugs;
  final String? categoryId;
  final String? warehouseId;

  JLAllProductsController({
    this.categorySlugs,
    this.categoryId,
    this.warehouseId,
  });
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;

  RxList<AllLiq> productList = <AllLiq>[].obs;
  RxString searchQuery = "".obs;

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();
  final AuthController _authcontroller = Get.find<AuthController>();
  String? categorySlug;
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();

    // final args = Get.arguments as Map<String, dynamic>?;
    // categorySlug = args?["categorySlug"];

    fetchProducts(reset: true);

    /// PAGINATION – only when NOT searching
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels >=
    //           scrollController.position.maxScrollExtent &&
    //       !isLoading.value &&
    //       isMoreDataAvailable.value &&
    //       searchQuery.value.isEmpty) {
    //     fetchProducts();
    //   }
    // });

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;

      final position = scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 200 &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts();
      }
    });

    /// SEARCH LISTENER
    // ever(searchQuery, (_) {
    //   fetchProducts(reset: true);
    // });

    debounce(
      searchQuery,
      (_) => fetchProducts(reset: true),
      time: const Duration(milliseconds: 400),
    );
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value) return;
    if (!isMoreDataAvailable.value && !reset) return;

    final int requestId = ++_requestId;

    if (reset) {
      currentPage = 1;
      productList.clear();
      isMoreDataAvailable.value = true;
    }

    print("PAGE: $currentPage");
    print("SEARCH: ${searchQuery.value}");
    print("LIST LENGTH: ${productList.length}");

    try {
      isLoading.value = true;

      final bool isSearching = searchQuery.value.isNotEmpty;

      final response = await dio.get(
        isSearching
            ? "$jitUrl/public/product/search"
            : "$jitUrl/public/product",
        queryParameters: isSearching
            ? {
                "query": searchQuery.value,
                "page": currentPage,
                "limit": limit,
                "source": "Liquor",
                if (categoryId != null) "category": categoryId,
                if (_authcontroller.userId != null)
                  "user_id": _authcontroller.userId,
                if (warehouseId != null) "warehouse": warehouseId,
              }
            : {
                "page": currentPage,
                "limit": limit,
                "source": "Liquor",
                "user_id": _authcontroller.userId,
                // "category": categorySlug,
                if (categorySlugs != null) "category": categorySlugs,
                if (_authcontroller.userId != null)
                  "user_id": _authcontroller.userId,
                if (warehouseId != null) "warehouse": warehouseId,
                "slug": true,
              },
      );

      if (requestId != _requestId) return;

      // CRITICAL FIX: Check if response.data is Map
      if (response.data is! Map<String, dynamic>) {
        debugPrint("❌ Invalid response format (not JSON): ${response.data}");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Type: ${response.data.runtimeType}");
        isMoreDataAvailable.value = false;
        return;
      }

      final Map<String, dynamic> json = response.data;

      final List list = isSearching
          ? (json["results"] as List? ?? [])
          : (json["products"] as List? ?? []);
      print("l");

      // if (list.isEmpty) {
      //   isMoreDataAvailable.value = false;
      // } else {
      //   productList.addAll(
      //     list.map((e) => AllLiq.fromJson(e as Map<String, dynamic>)).toList(),
      //   );
      //   currentPage++;
      // }

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(
          list.map((e) => AllLiq.fromJson(e as Map<String, dynamic>)).toList(),
        );

        // CRITICAL FIX from infinite loading
        if (list.length < limit) {
          isMoreDataAvailable.value = false;
        } else {
          currentPage++;
        }
      }
    } catch (e, stackTrace) {
      debugPrint("❌ API ERROR: $e");
      debugPrint("Stack: $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }
}

class categorysliqfetch extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<liqourModel> productList = <liqourModel>[].obs;

  RxString searchQuery = "".obs; // 🔹 search query
  RxList<liqourModel> filteredList = <liqourModel>[].obs; // 🔹 filtered list

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();
  String? categorySlug;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    categorySlug = args?["categorySlug"];

    fetchProducts(reset: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoading.value &&
          isMoreDataAvailable.value) {
        fetchProducts();
      }
    });

    // 🔹 search listener
    ever(searchQuery, (_) => _filterProducts());
  }

  void _filterProducts() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredList.value = List.from(productList);
    } else {
      filteredList.value = productList
          .where((p) => p?.name?.toLowerCase().contains(query) ?? false)
          .toList();
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    if (reset) {
      currentPage = 1;
      productList.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/liquor/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "sort": "latest",
          if (categorySlug != null && categorySlug!.isNotEmpty)
            "category": categorySlug,
        },
      );

      final List list = response.data["products"] ?? [];

      if (list.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        productList.addAll(list.map((e) => liqourModel.fromJson(e)).toList());
        currentPage++;
      }

      _filterProducts(); // 🔹 update filtered list
    } catch (e) {
      debugPrint("❌ API ERROR $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class beerProductController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  RxList<BeerModel> productLists = <BeerModel>[].obs;

  RxString searchQuery = "".obs;
  RxList<BeerModel> filteredList = <BeerModel>[].obs;

  int currentPage = 1;
  final int limit = 20;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    fetchProducts(reset: true);

    scrollController.addListener(_onScroll);

    ever(searchQuery, (_) => _filterProducts());
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    // Trigger when near bottom (300px threshold for smoother feel)
    if (position.pixels >= position.maxScrollExtent - 300 &&
        !isLoading.value &&
        isMoreDataAvailable.value) {
      fetchProducts();
    }
  }

  void _filterProducts() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredList.assignAll(productLists);
    } else {
      filteredList.assignAll(
        productLists
            .where((p) => (p.productName ?? '').toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (isLoading.value || !isMoreDataAvailable.value) return;

    double? oldOffset; // ← save current scroll position
    if (!reset && scrollController.hasClients) {
      oldOffset = scrollController.offset;
    }

    if (reset) {
      currentPage = 1;
      productLists.clear();
      filteredList.clear();
      isMoreDataAvailable.value = true;
    }

    isLoading.value = true;

    try {
      final response = await dio.get(
        "$jitUrl/public/product",
        queryParameters: {
          "page": currentPage,
          "limit": limit,
          "source": "Liquor",
          "category": "beer", // ← only beers, as you want
          "slug": "true",
          "sort": "latest",
        },
      );

      final List<dynamic> products = response.data["products"] ?? [];

      if (products.isEmpty) {
        isMoreDataAvailable.value = false;
      } else {
        final newItems = products.map((e) => BeerModel.fromJson(e)).toList();
        productLists.addAll(newItems as Iterable<BeerModel>);
        currentPage++;
      }

      _filterProducts(); // refresh filtered

      // ← Restore scroll position after rebuild (prevents jump to top)
      if (oldOffset != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(oldOffset!);
          }
        });
      }
    } catch (e, stack) {
      debugPrint("API ERROR: $e\n$stack");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll); // ← correct cleanup
    scrollController.dispose();
    super.onClose();
  }
}

class beerLiqFetch extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxList<BeerModel> list = <BeerModel>[].obs;

  RxString searchQuery = "".obs;
  RxList<BeerModel> filteredLists = <BeerModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    fetchCategories();

    // 🔥 Listen to search query changes
    debounce(
      searchQuery,
      (_) => applySearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      final response = await dio.get(
        "$jitUrl/public/product?page=1&limit=20&source=Liquor&category=beer&slug=true",
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final List products =
            response.data['products'] ??
            []; // ← changed from 'data' to 'products'

        list.value = products.map((e) => BeerModel.fromJson(e)).toList();

        filteredLists.assignAll(list);
      }
    } catch (e, stack) {
      print("API Error: $e");
      print("Stack: $stack"); // helpful for debugging
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 Search logic
  void applySearch() {
    if (searchQuery.value.isEmpty) {
      filteredLists.assignAll(list);
    } else {
      filteredLists.assignAll(
        list.where(
          (item) => item.productName!.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        ),
      );
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////
///

// class servicesss extends GetxController {
//   final Dio dio = Dio();

//   RxBool isLoading = false.obs;

//   /// 🔥 Products list
//   RxList<Category> liqourList = <Category>[].obs;
//   RxList<Category> filteredList = <Category>[].obs;

//   RxString searchQuery = "".obs;

//   @override
//   void onInit() {
//     super.onInit();

//     fetchProducts();

//     /// 🔍 debounce search
//     debounce(
//       searchQuery,
//       (_) => applySearch(),
//       time: const Duration(milliseconds: 300),
//     );
//   }

//   Future<void> fetchProducts() async {
//     try {
//       isLoading.value = true;

//       final response = await dio.get(
//         "https://jitco.salt-tech.com/api/v1/public/product/category",
//         queryParameters: {"page": 1, "limit": 20, "source": "Services"},
//       );

//       debugPrint("API RESPONSE 👉 ${response.data}");

//       if (response.statusCode == 200) {
//         // ────────────────────────────────────────
//         //     ↓↓↓  THIS IS THE ONLY CHANGE NEEDED  ↓↓↓
//         final List data =
//             response.data['data'] ?? []; // ← use 'data' instead of 'categories'
//         // ────────────────────────────────────────

//         liqourList.assignAll(
//           data
//               .map((e) => Category.fromJson(e as Map<String, dynamic>))
//               .toList(),
//         );

//         debugPrint("Parsed ${liqourList.length} categories");
//       } else {
//         debugPrint(
//           "API failed: ${response.statusCode} - ${response.statusMessage}",
//         );
//       }
//     } catch (e, stack) {
//       debugPrint("❌ API Error: $e");
//       debugPrint("Stack: $stack");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void applySearch() {
//     if (searchQuery.value.isEmpty) {
//       filteredList.assignAll(liqourList);
//     } else {
//       filteredList.assignAll(
//         liqourList.where(
//           (item) => item.categoryName.toLowerCase().contains(
//             searchQuery.value.toLowerCase(),
//           ),
//         ),
//       );
//     }
//   }
// }
class JlCategoryController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<Category> liqourList = <Category>[].obs;

  RxString searchQuery = "".obs;

  int page = 1;
  final int limit = 20;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();

    debounce(
      searchQuery,
      (_) => onSearchChanged(),
      time: const Duration(milliseconds: 400),
    );
  }

  /// 🔍 When search text changes
  void onSearchChanged() {
    page = 1;
    hasMore = true;
    liqourList.clear();

    fetchProducts();
  }

  /// 🚀 Main API
  Future<void> fetchProducts({bool loadMore = false}) async {
    if (!hasMore) return;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final response = await dio.get(
        "$jitUrl/public/product/category",
        queryParameters: {
          "page": page,
          "limit": limit,
          "source": "Services",
          if (searchQuery.value.isNotEmpty) "search": searchQuery.value,

          /// ✅ SEARCH PARAM
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];

        final parsedList = data.map((e) => Category.fromJson(e)).toList();

        if (parsedList.length < limit) {
          hasMore = false;
        }

        liqourList.addAll(parsedList);

        page++;

        /// ✅ increment only after success
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// 📜 Pagination trigger
  void loadMore() {
    if (!isLoadingMore.value && hasMore) {
      fetchProducts(loadMore: true);
    }
  }
}

class JlHomeCategoryController extends GetxController {
  final Dio dio = Dio();

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<Category> liqourList = <Category>[].obs;

  RxString searchQuery = "".obs;

  int page = 1;
  final int limit = 20;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();

    debounce(
      searchQuery,
      (_) => onSearchChanged(),
      time: const Duration(milliseconds: 400),
    );
  }

  /// 🔍 When search text changes
  void onSearchChanged() {
    page = 1;
    hasMore = true;
    liqourList.clear();

    fetchProducts();
  }

  /// 🚀 Main API
  Future<void> fetchProducts({bool loadMore = false}) async {
    if (!hasMore) return;

    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final response = await dio.get(
        "$jitUrl/public/product/category",
        queryParameters: {
          "page": page,
          "limit": limit,
          "source": "Services",
          if (searchQuery.value.isNotEmpty) "search": searchQuery.value,

          /// ✅ SEARCH PARAM
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];

        final parsedList = data.map((e) => Category.fromJson(e)).toList();

        if (parsedList.length < limit) {
          hasMore = false;
        }

        liqourList.addAll(parsedList);

        page++;

        /// ✅ increment only after success
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// 📜 Pagination trigger
  void loadMore() {
    if (!isLoadingMore.value && hasMore) {
      fetchProducts(loadMore: true);
    }
  }
}

// class ServiceController extends GetxController {
//   bool? slug;
//   String? categorySlug;

//   ServiceController({this.slug, this.categorySlug});
//   final Dio dio = Dio();

//   var isLoading = false.obs;
//   var liqourList = <Product>[].obs;
//   var filteredList = <Product>[].obs;
//   var searchQuery = "".obs;
//   @override
//   void onInit() {
//     super.onInit();
//     searchQuery.value = ""; // ← force reset
//     ever(searchQuery, (_) => applySearch()); // or keep debounce
//     fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     try {
//       isLoading(true);
//       print("===== START FETCH =====");

//       final response = await dio.get(
//         "https://jitco.salt-tech.com/api/v1/public/product",
//         queryParameters: {
//           "page": 1,
//           "limit": 20,
//           "source": "Services",
//           if (categorySlug != null) "category": categorySlug,
//           if (categorySlug != null) "slug": slug,
//         },
//       );

//       print("Status code: ${response.statusCode}");
//       print(
//         "Response has 'products': ${(response.data as Map?)?.containsKey('products') ?? false}",
//       );

//       if (response.statusCode == 200) {
//         final data = response.data as Map<String, dynamic>;
//         final productsRaw = data['products'] as List<dynamic>? ?? [];

//         print("Raw products count from API: ${productsRaw.length}");

//         final parsed = productsRaw
//             .map((e) {
//               try {
//                 return Product.fromJson(e as Map<String, dynamic>);
//               } catch (err) {
//                 print("Parse error for one item: $err");
//                 return null;
//               }
//             })
//             .whereType<Product>()
//             .toList();

//         print("Successfully parsed: ${parsed.length} products");

//         liqourList.assignAll(parsed);
//         filteredList.assignAll(parsed);

//         if (parsed.isNotEmpty) {
//           print("First name: ${parsed.first.name}");
//           print("First slug: ${parsed.first.slug}");
//         }
//       }
//     } catch (e, st) {
//       print("Fetch crashed: $e");
//       print(st);
//     } finally {
//       isLoading(false);
//       print("Fetch ended. liqourList length = ${liqourList.length}");
//       print("filteredList length = ${filteredList.length}");
//     }
//   }

//   void applySearch() {
//     if (searchQuery.value.trim().isEmpty) {
//       filteredList.assignAll(liqourList);
//     } else {
//       final q = searchQuery.value.toLowerCase().trim();
//       filteredList.assignAll(
//         liqourList.where((p) => p.name.toLowerCase().contains(q)).toList(),
//       );
//     }
//   }
// }
class ServiceController extends GetxController {
  bool? slug;
  String? categorySlug;
  String? categoryId;
  String? warehouseId;

  ServiceController({
    this.slug,
    this.categorySlug,
    this.categoryId,
    this.warehouseId,
  });

  final Dio dio = Dio();

  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  var liqourList = <Product>[].obs;

  var searchQuery = "".obs;

  int page = 1;
  final int limit = 10;

  bool hasMore = true;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();

    debounce(
      searchQuery,
      (_) => _onSearchChanged(),
      time: const Duration(milliseconds: 400),
    );

    fetchProducts();
  }

  /// 🔍 When search changes
  void _onSearchChanged() {
    page = 1;
    hasMore = true;
    liqourList.clear();

    fetchProducts();
  }

  /// 🚀 Main Fetch Logic
  Future<void> fetchProducts({bool loadMore = false}) async {
    String? userId = _authController.userId.toString();
    if (!hasMore) return;

    try {
      if (loadMore) {
        isLoadingMore(true);
      } else {
        isLoading(true);
      }

      Response response;

      if (isSearching) {
        /// SEARCH API
        response = await dio.get(
          "$jitUrl/public/product/search",
          queryParameters: {
            "query": searchQuery.value,
            "page": page,
            "limit": limit,
            "source": "Services",
            // if (categorySlug != null) "category": categorySlug,
            if (categoryId != null) "category": categoryId,
            if (categoryId != null) "slug": slug,
            if (warehouseId != null) "warehouse": warehouseId,
            if (userId != null) "user_id": userId,
          },
        );
      } else {
        /// ✅ NORMAL API
        response = await dio.get(
          "$jitUrl/public/product",
          queryParameters: {
            "page": page,
            "limit": limit,
            "source": "Services",
            if (categorySlug != null) "category": categorySlug,
            // if (categoryId != null) "category": categoryId,
            if (categorySlug != null) "slug": slug,
            if (warehouseId != null) "warehouse": warehouseId,
            if (userId != null) "user_id": userId,
          },
        );
      }

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final List rawProducts = isSearching
            ? (data['results'] ?? [])
            : (data['products'] ?? []);

        final parsed = rawProducts.map((e) => Product.fromJson(e)).toList();

        if (parsed.length < limit) {
          hasMore = false;
        }

        liqourList.addAll(parsed);

        page++;
      }
    } catch (e) {
      print("❌ Fetch Error: $e");
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  /// 📜 Pagination Trigger
  void loadMore() {
    if (!isLoadingMore.value && hasMore) {
      fetchProducts(loadMore: true);
    }
  }
}
