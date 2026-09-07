class CategoryResponse {
  final bool success;
  final List<CategoryModel>? data;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final int total;

  CategoryResponse({
    required this.success,
    this.data,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    required this.total,
  });
}

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String slug;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['categoryName'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
class liqourModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String slug;

  liqourModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.slug,
  });

  factory liqourModel.fromJson(Map<String, dynamic> json) {
    return liqourModel(
      id: json['_id'] ?? '',
      name: json['categoryName'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

///////////////////////////PRODUCT MODEL/////////////////////////////////

class ProductModel {
  String productName;
  String id;
  String slug;
  String productShortDescription;
  String productLongDescription;
  List<String> productImage;
  List<Price> price;

  ProductModel({
    required this.productName,
    required this.productShortDescription,
    required this.productImage,
    required this.price,
    required this.id,
    required this.slug,
    required this.productLongDescription,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productName: json['productName'] ?? '',
      slug: json['data']?['slug'] ?? '',
      id: json['_id'] ?? '',
      productShortDescription: json['productShortDescription'] ?? '',
      productLongDescription: json["productLongDescription"] ?? "",

      productImage: json['productImage'] != null
          ? List<String>.from(json['productImage'])
          : [],
      price:
          (json['price'] as List<dynamic>?)
              ?.map((e) => Price.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Price {
  String size;
  int price;

  Price({required this.size, required this.price});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      size: json['size'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

// class All {
//   final String id;
//   final String productName;
//   final String productShortDescription;
//   final String productLongDescription;
//   final String slug;
//   final String image;
//   final bool isActive;
//   final int gstPercentage;
//   final List<PriceModel> price;
//   final CategoryModel category;
//   final BrandModel brand;

//   All({
//     required this.id,
//     required this.productName,
//     required this.productShortDescription,
//     required this.productLongDescription,
//     required this.slug,
//     required this.image,
//     required this.isActive,
//     required this.gstPercentage,
//     required this.price,
//     required this.category,
//     required this.brand,
//   });

//   factory All.fromJson(Map<String, dynamic> json) {
//     // String? getProductImage() {
//     //   final images = json['productImage'];
//     //   if (images is List &&
//     //       images.isNotEmpty &&
//     //       images[0] != null &&
//     //       images[0].isNotEmpty) {
//     //     return images[0];
//     //   }
//     //   return null;
//     // }

//     return All(
//       id: json["_id"] ?? "",
//       productName: json["productName"] ?? "",
//       productShortDescription: json["productShortDescription"] ?? "",
//       productLongDescription: json["productLongDescription"] ?? "",
//       slug: json["slug"] ?? "",
//       image: json["image"] ?? "",

//       isActive: json["isActive"] ?? false,
//       gstPercentage: json["gstPercentage"] ?? 0,
//       price: (json["price"] as List? ?? [])
//           .map((e) => PriceModel.fromJson(e))
//           .toList(),
//       category: CategoryModel.fromJson(json["category"] ?? {}),
//       brand: BrandModel.fromJson(json["brand"] ?? {}),
//     );
//   }
// }

class All {
  final String id;
  final String productName;
  final String productShortDescription;
  final String productLongDescription;
  final String slug;
  final String image;
  final bool isActive;
  final int gstPercentage;
  final List<PriceModel> price;
  final CategoryModel category;
  final BrandModel brand;

  All({
    required this.id,
    required this.productName,
    required this.productShortDescription,
    required this.productLongDescription,
    required this.slug,
    required this.image,
    required this.isActive,
    required this.gstPercentage,
    required this.price,
    required this.category,
    required this.brand,
  });

  factory All.fromJson(Map<String, dynamic> json) {
    print("🔄 Parsing All from JSON:");
    print("  ID: ${json["_id"]}");
    print("  Name: ${json["productName"]}");

    // Handle image - API has productImage array, not image field
    String productImage = "";
    if (json['productImage'] is List &&
        (json['productImage'] as List).isNotEmpty) {
      final firstImage = json['productImage'][0];
      if (firstImage != null && firstImage is String) {
        productImage = firstImage;
      }
    }

    // Handle category safely - it could be a map or string
    CategoryModel categoryModel;
    try {
      final categoryData = json["category"];
      print("  Category type: ${categoryData.runtimeType}");
      print("  Category value: $categoryData");

      if (categoryData is Map<String, dynamic>) {
        categoryModel = CategoryModel.fromJson(categoryData);
      } else if (categoryData is String && categoryData.isNotEmpty) {
        // If category is just an ID string, create minimal category
        categoryModel = CategoryModel(
          id: categoryData,
          name: '',
          description: '',
          image: '',
          slug: '',
        );
      } else {
        // Default empty category
        categoryModel = CategoryModel(
          id: '',
          name: '',
          description: '',
          image: '',
          slug: '',
        );
      }
    } catch (e) {
      print("❌ Error parsing category: $e");
      categoryModel = CategoryModel(
        id: '',
        name: '',
        description: '',
        image: '',
        slug: '',
      );
    }

    // Handle brand safely
    BrandModel brandModel;
    try {
      final brandData = json["brand"];
      print("  Brand type: ${brandData.runtimeType}");
      print("  Brand value: $brandData");

      if (brandData is Map<String, dynamic>) {
        brandModel = BrandModel.fromJson(brandData);
      } else if (brandData is String && brandData.isNotEmpty) {
        // If brand is just an ID string
        brandModel = BrandModel(id: brandData, name: '', image: '', slug: '');
      } else {
        brandModel = BrandModel(id: '', name: '', image: '', slug: '');
      }
    } catch (e) {
      print("❌ Error parsing brand: $e");
      brandModel = BrandModel(id: '', name: '', image: '', slug: '');
    }

    // Handle price array
    List<PriceModel> prices = [];
    try {
      if (json["price"] is List) {
        for (var priceItem in (json["price"] as List)) {
          if (priceItem is Map<String, dynamic>) {
            try {
              prices.add(PriceModel.fromJson(priceItem));
            } catch (e) {
              print("Error parsing price item: $e");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error parsing prices: $e");
    }

    return All(
      id: json["_id"]?.toString() ?? "",
      productName: json["productName"]?.toString() ?? "",
      productShortDescription:
          json["productShortDescription"]?.toString() ?? "",
      productLongDescription: json["productLongDescription"]?.toString() ?? "",
      slug: json["slug"]?.toString() ?? "",
      image: productImage, // Use the extracted image
      isActive:
          json["isActive"] == true ||
          json["isActive"] == 1 ||
          json["isActive"] == "true",
      gstPercentage: (json["gstPercentage"] is int)
          ? json["gstPercentage"]
          : (json["gstPercentage"] is double)
          ? (json["gstPercentage"] as double).toInt()
          : int.tryParse(json["gstPercentage"]?.toString() ?? "0") ?? 0,
      price: prices,
      category: categoryModel,
      brand: brandModel,
    );
  }
}

// lib/screens/Bmain/Jitco Menu/Models/search_response_model.dart
class SearchResponseModel {
  final String message;
  final String query;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final List<All> results;

  SearchResponseModel({
    required this.message,
    required this.query,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.results,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      message: json['message'] ?? '',
      query: json['query'] ?? '',
      total: json['total']?.toInt() ?? 0,
      page: json['page']?.toInt() ?? 1,
      limit: json['limit']?.toInt() ?? 20,
      totalPages: json['totalPages']?.toInt() ?? 1,
      results: json['products'] is List
          ? (json['products'] as List)
                .map<All>((item) => All.fromJson(item))
                .toList()
          : [],
    );
  }
}

class PriceModel {
  final String size;
  final int price;

  PriceModel({required this.size, required this.price});

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(size: json["size"] ?? "", price: json["price"] ?? 0);
  }
}

class BrandModel {
  final String id;
  final String name;
  final String image;
  final String slug;

  BrandModel({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      image: json["image"] ?? "",
      slug: json["slug"] ?? "",
    );
  }
}

class liqModel {
  String productName;
  String id;
  String slug;
  String productShortDescription;
  String productLongDescription;
  List<String> productImage;
  List<Price> price;

  liqModel({
    required this.productName,
    required this.productShortDescription,
    required this.productImage,
    required this.price,
    required this.id,
    required this.slug,
    required this.productLongDescription,
  });

  factory liqModel.fromJson(Map<String, dynamic> json) {
    return liqModel(
      productName: json['productName'] ?? '',
      slug: json['data']?['slug'] ?? '',
      id: json['_id'] ?? '',
      productShortDescription: json['productShortDescription'] ?? '',
      productLongDescription: json["productLongDescription"] ?? "",

      productImage: json['productImage'] != null
          ? List<String>.from(json['productImage'])
          : [],
      price:
          (json['price'] as List<dynamic>?)
              ?.map((e) => Price.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class prices {
  String size;
  int price;

  prices({required this.size, required this.price});

  factory prices.fromJson(Map<String, dynamic> json) {
    return prices(
      size: json['size'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

class allliq {
  final String id;
  final String productName;
  final String productShortDescription;
  final String productLongDescription;
  final String slug;
  final String image;
  final bool isActive;
  final double gstPercentage;
  final List<PricesModel> price;
  final liqourModel category;
  final BrandModel brand;

  allliq({
    required this.id,
    required this.productName,
    required this.productShortDescription,
    required this.productLongDescription,
    required this.slug,
    required this.image,
    required this.isActive,
    required this.gstPercentage,
    required this.price,
    required this.category,
    required this.brand,
  });

  factory allliq.fromJson(Map<String, dynamic> json) {
    return allliq(
      id: json["_id"] ?? "",
      productName: json["productName"] ?? "",
      productShortDescription: json["productShortDescription"] ?? "",
      productLongDescription: json["productLongDescription"] ?? "",
      slug: json["slug"] ?? "",
      image: json["image"] ?? "",
      isActive: json["isActive"] == true || json["isActive"] == 1,
      gstPercentage: (json["gstPercentage"] ?? 0).toDouble(),
      price: (json["price"] as List? ?? [])
          .map((e) => PricesModel.fromJson(e))
          .toList(),
      category: liqourModel.fromJson(json["category"] ?? {}),
      brand: BrandModel.fromJson(json["brand"] ?? {}),
    );
  }
}

class PricesModel {
  final String size;
  final double price;

  PricesModel({required this.size, required this.price});

  factory PricesModel.fromJson(Map<String, dynamic> json) {
    return PricesModel(
      size: json["size"] ?? "",
      price: (json["price"] ?? 0).toDouble(),
    );
  }
}
