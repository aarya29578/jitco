// category_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';

class JmCategoryController extends GetxController {
  final JMApiService _apiService = JMApiService();

  // Observables
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  final int limit = 20;
  String searchText = "";

  // Debounce for search
  Timer? _debounceTimer;

  @override
  void onInit() {
    fetchCategories(isInitial: true);
    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchCategories({
    bool isInitial = false,
    bool isLoadMore = false,
    String? search,
  }) async {
    try {
      // Cancel previous debounce timer
      _debounceTimer?.cancel();

      // If search is provided, update searchText and reset page
      if (search != null) {
        searchText = search;
        if (!isLoadMore) {
          currentPage = 1;
        }
      }

      // Set loading states
      if (isInitial) {
        isLoading.value = true;
      } else if (isLoadMore) {
        isLoadingMore.value = true;
      }

      final response = await _apiService.fetchCategories(
        page: currentPage,
        limit: limit,
        search: searchText,
      );

      if (response.success) {
        // Update pagination
        currentPage = response.currentPage;
        totalPages = response.totalPages;
        hasMore.value = response.hasMore;

        if (isLoadMore) {
          // Append new categories
          if (response.data != null) {
            categoryList.addAll(response.data!);
          }
        } else {
          // Replace categories
          categoryList.value = response.data ?? [];
        }
      } else {
        // Handle API error
        Get.snackbar("Error", "Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void onSearchChanged(String value) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Set up new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchText != value) {
        searchText = value;
        fetchCategories(isInitial: true);
      }
    });
  }

  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasMore.value) {
      currentPage++;
      await fetchCategories(isLoadMore: true);
    }
  }

  Future<void> refresh() async {
    currentPage = 1;
    await fetchCategories(isInitial: true);
  }
}
