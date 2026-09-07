import 'package:get/get.dart';
import 'package:dio/dio.dart';

class PerishablesController extends GetxController {
  var isLoading = true.obs;

  // original API data
  var categoryMap = <String, List<PerishItem>>{}.obs;

  // filtered data (search applied)
  var filteredMap = <String, List<PerishItem>>{}.obs;

  var searchText = "".obs;

  final Dio _dio = Dio();

  @override
  void onInit() {
    fetchPerishables();
    debounce(
      searchText,
      (_) => applySearch(),
      time: Duration(milliseconds: 300),
    );
    super.onInit();
  }

  Future<void> fetchPerishables() async {
    try {
      isLoading.value = true;

      final response = await _dio.get(
        "https://api.jitco.in/api/v1/public/product/category/type",
      );

      final dataList = response.data['data'] as List?;

      if (dataList != null && dataList.isNotEmpty) {
        categoryMap.clear();

        for (var data in dataList) {
          if (data['Stockable Products'] != null) {
            categoryMap['Stockable Products'] =
                (data['Stockable Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }

          if (data['Perishable Products'] != null) {
            categoryMap['Perishable Products'] =
                (data['Perishable Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }

          if (data['Retail Products'] != null) {
            categoryMap['Retail Products'] = (data['Retail Products'] as List)
                .map((e) => PerishItem.fromJson(e))
                .toList();
          }

          if (data['Non Food Products'] != null) {
            categoryMap['Non Food Products'] =
                (data['Non Food Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }
        }

        filteredMap.assignAll(categoryMap);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // GLOBAL SEARCH HERE
  void applySearch() {
    if (searchText.value.isEmpty) {
      filteredMap.assignAll(categoryMap);
      return;
    }

    final query = searchText.value.toLowerCase();
    final newMap = <String, List<PerishItem>>{};

    categoryMap.forEach((key, items) {
      final filteredItems = items.where((product) {
        return product.name!.toLowerCase().contains(query);
      }).toList();

      if (filteredItems.isNotEmpty) {
        newMap[key] = filteredItems;
      }
    });

    filteredMap.assignAll(newMap);
  }
}

class PerishItem {
  String? id;
  String? name;
  String? image;
  String? price;
  String? categoryId;
  String? categorySlug;

  PerishItem({
    this.id,
    this.name,
    this.image,
    this.price,
    this.categoryId,
    this.categorySlug,
  });

  factory PerishItem.fromJson(Map<String, dynamic> json) {
    return PerishItem(
      id: json['_id']?.toString(),
      name: json['categoryName'] ?? json['name'] ?? 'No name',
      image: json['image'] ?? json['img'] ?? '',
      price: json['price']?.toString() ?? '0',
      categoryId: json['categoryId']?.toString(),
      categorySlug: json['slug']?.toString(),
    );
  }
}
