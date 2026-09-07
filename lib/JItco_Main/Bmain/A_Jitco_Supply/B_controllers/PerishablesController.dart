import 'package:get/get.dart';
import 'package:dio/dio.dart';

class PerishablesController extends GetxController {
  var isLoading = true.obs;

  // key = category name, value = list of products
  var categoryMap = <String, List<PerishItem>>{}.obs;

  final Dio _dio = Dio();

  @override
  void onInit() {
    fetchPerishables();
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
        // Clear old data
        categoryMap.clear();

        // Loop through all data objects
        for (var data in dataList) {
          // Stockable
          if (data['Stockable Products'] != null) {
            categoryMap['Stockable Products'] =
                (data['Stockable Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }

          // Perishable
          if (data['Perishable Products'] != null) {
            categoryMap['Perishable Products'] =
                (data['Perishable Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }

          // Retail
          if (data['Retail Products'] != null) {
            categoryMap['Retail Products'] = (data['Retail Products'] as List)
                .map((e) => PerishItem.fromJson(e))
                .toList();
          }

          // Non Food
          if (data['Non Food Products'] != null) {
            categoryMap['Non Food Products'] =
                (data['Non Food Products'] as List)
                    .map((e) => PerishItem.fromJson(e))
                    .toList();
          }
        }

        // Debug
        categoryMap.forEach((key, value) {
          print("$key count: ${value.length}");
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

//  class PerishItem {
//   String? name;
//   String? image;
//   String? price;

//   PerishItem({this.name, this.image, this.price});

//   factory PerishItem.fromJson(Map<String, dynamic> json) {
//     return PerishItem(
//       name: json['categoryName'] ?? json['name'] ?? 'No name',
//       image: json['image'] ?? json['img'] ?? '',
//       price: json['price']?.toString() ?? '0',
//     );
//   }

//   get id => null;

//   get slug => null;

//   get categoryId => null;
// }
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

      // VERY IMPORTANT FOR FILTERING
      categoryId: json['categoryId']?.toString(),
      categorySlug: json['slug']?.toString(),
    );
  }

  get slug => null;
}
