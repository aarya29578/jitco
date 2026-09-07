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

///////////////////////////////////////////////////////////////////////////////
class CategorysModel {
  final String id;
  final String productName;
  final String productShortDescription;
  final String productLongDescription;
  final String slug;
  final List<String> productImage;
  final Map<String, dynamic> category;
  final dynamic brand; // ← dynamic to handle string or map
  final List<PriceModel> price;

  // Optional useful fields
  final String? countryOrigin;
  final String? productType;
  final String? vegNoneveg;

  CategorysModel({
    required this.id,
    required this.productName,
    required this.productShortDescription,
    this.productLongDescription = '',
    required this.slug,
    this.productImage = const [],
    this.category = const {},
    this.brand,
    this.price = const [],
    this.countryOrigin,
    this.productType,
    this.vegNoneveg,
  });

  factory CategorysModel.fromJson(Map<String, dynamic> json) {
    return CategorysModel(
      id: json['_id'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productShortDescription: json['productShortDescription'] as String? ?? '',
      productLongDescription: json['productLongDescription'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      productImage: List<String>.from(json['productImage'] as List? ?? []),
      category: json['category'] as Map<String, dynamic>? ?? {},
      brand: json['brand'], // keep dynamic – handle in UI if needed
      price:
          (json['price'] as List<dynamic>?)
              ?.map((e) => PriceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      countryOrigin: json['countryOrigin'] as String?,
      productType: json['productType'] as String?,
      vegNoneveg: json['vegNoneveg'] as String?,
    );
  }

  String get categorySlug => category['slug'] ?? '';
  String get categoryId => category['_id'] ?? '';

  String get firstImage =>
      productImage.isNotEmpty ? productImage.first : 'assets/placeholder.png';

  int get startingPrice => price.isNotEmpty ? price.first.price : 0;

  String get defaultSize => price.isNotEmpty ? price.first.size : '';
}

class PricesssModel {
  // ← fixed name (was PricessModel)
  final String id;
  final String size;
  final int price;

  PricesssModel({required this.id, required this.size, required this.price});

  factory PricesssModel.fromJson(Map<String, dynamic> json) {
    return PricesssModel(
      id: json['_id'] as String? ?? '',
      size: json['size'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0, // safe num → int
    );
  }
}

class BeerModel {
  // ← PascalCase recommended
  final String id;
  final String productName;
  final String productShortDescription;
  final String productLongDescription;
  final String slug;
  final List<String> productImage;
  final Map<String, dynamic> category;
  final dynamic brand; // ← dynamic: handles both String (ID) and Map<Object>
  final List<PriceVariant> price;
  final String? productType;
  final String? countryOrigin; // added – useful
  final String? vegNoneveg; // added

  BeerModel({
    required this.id,
    required this.productName,
    required this.productShortDescription,
    this.productLongDescription = '',
    required this.slug,
    this.productImage = const [],
    this.category = const {},
    this.brand,
    this.price = const [],
    this.productType,
    this.countryOrigin,
    this.vegNoneveg,
  });

  factory BeerModel.fromJson(Map<String, dynamic> json) {
    return BeerModel(
      id: json['_id'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Unknown Product',
      productShortDescription: json['productShortDescription'] as String? ?? '',
      productLongDescription: json['productLongDescription'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      productImage: List<String>.from(json['productImage'] as List? ?? []),
      category: json['category'] as Map<String, dynamic>? ?? {},
      brand: json['brand'], // ← keep dynamic (String or Map)
      price: (json['price'] as List<dynamic>? ?? [])
          .map((p) => PriceVariant.fromJson(p as Map<String, dynamic>))
          .toList(),
      productType: json['productType'] as String?,
      countryOrigin: json['countryOrigin'] as String?,
      vegNoneveg: json['vegNoneveg'] as String?,
    );
  }

  String get categorySlug => category['slug'] ?? '';
  String get categoryId => category['_id'] ?? '';

  // Helpers (same as yours, but safer)
  String get firstImage {
    return productImage.isNotEmpty
        ? productImage.first
        : 'assets/images/placeholder.png';
  }

  String get displayPrice {
    if (price.isEmpty) return 'N/A';
    final variant = price.first;
    return '₹${variant.price.toStringAsFixed(0)} ${variant.size.isNotEmpty ? '(${variant.size})' : ''}';
  }

  // Optional: get all prices as string (for detail page)
  String get allPrices {
    if (price.isEmpty) return 'Price not available';
    return price.map((v) => '₹${v.price} (${v.size})').join(' • ');
  }
}

class PriceVariant {
  final String id;
  final String size;
  final num price; // keep num – safe for int/double

  PriceVariant({required this.id, required this.size, required this.price});

  factory PriceVariant.fromJson(Map<String, dynamic> json) {
    return PriceVariant(
      id: json['_id'] as String? ?? '',
      size: json['size'] as String? ?? 'N/A',
      price: json['price'] as num? ?? 0,
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
      // slug: json['data']?['slug'] ?? '',
      slug: json['slug'] ?? '', // ✅ FIXED

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
    return All(
      id: json["_id"] ?? "",
      productName: json["productName"] ?? "",
      productShortDescription: json["productShortDescription"] ?? "",
      productLongDescription: json["productLongDescription"] ?? "",
      slug: json["slug"] ?? "",
      image: json['image'] ?? '',

      isActive: json["isActive"] ?? false,
      gstPercentage: json["gstPercentage"] ?? 0,
      price: (json["price"] as List? ?? [])
          .map((e) => PriceModel.fromJson(e))
          .toList(),
      category: CategoryModel.fromJson(json["category"] ?? {}),
      brand: BrandModel.fromJson(json["brand"] ?? {}),
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
  List<prices> price;

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
      slug: json['slug'] ?? '', // ✅ FIXED
      id: json['_id'] ?? '',
      productShortDescription: json['productShortDescription'] ?? '',
      productLongDescription: json["productLongDescription"] ?? "",

      productImage: json['productImage'] != null
          ? List<String>.from(json['productImage'])
          : [],
      price:
          (json['price'] as List<dynamic>?)
              ?.map((e) => prices.fromJson(e))
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

class AllLiq {
  final String id;
  final String productName;
  final String productShortDescription;
  final String productLongDescription;
  final String slug;
  final String image; // first image from productImage array
  final bool isActive;
  final double gstPercentage;
  final List<PricesModel> price;
  final CategorModel category; // renamed for clarity
  final dynamic brand; // can be String (ID) or Map

  AllLiq({
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

  factory AllLiq.fromJson(Map<String, dynamic> json) {
    // Extract first image safely
    final productImages = json['productImage'] as List<dynamic>? ?? [];
    final firstImage = productImages.isNotEmpty
        ? productImages.first as String
        : '';

    // Brand can be String or Map
    final brandValue = json['brand'];

    return AllLiq(
      id: json['_id'] as String? ?? '',
      productName:
          json['productName'] as String? ??
          json['slug'] as String? ??
          'Unnamed Product',
      productShortDescription: json['productShortDescription'] as String? ?? '',
      productLongDescription: json['productLongDescription'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      image: firstImage,
      isActive: json['isActive'] == true || json['isActive'] == 1,
      // gstPercentage is missing in most products → default 0
      gstPercentage: (json['gstPercentage'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as List<dynamic>? ?? [])
          .map((e) => PricesModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Category - safe parsing
      category: json['category'] is Map
          ? CategorModel.fromJson(json['category'] as Map<String, dynamic>)
          : CategorModel.empty(),
      // Brand - can be String or Map
      brand: brandValue,
    );
  }
}

// Simple price model (you can expand it if needed)
class PricesModel {
  final String size;
  final double price;
  final String? id;

  PricesModel({required this.size, required this.price, this.id});

  factory PricesModel.fromJson(Map<String, dynamic> json) {
    return PricesModel(
      size: json['size'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      id: json['_id'] as String?,
    );
  }
}

class CategorModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;

  CategorModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
  });

  factory CategorModel.fromJson(Map<String, dynamic> json) {
    return CategorModel(
      id: json['_id'] as String? ?? '',
      name: json['categoryName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }

  // ── Add this missing factory ───────────────────────────────
  factory CategorModel.empty() {
    return CategorModel(
      id: '',
      name: '',
      slug: '',
      description: null,
      image: null,
    );
  }
}

// Optional: helper method to get brand as string
extension AllLiqHelpers on AllLiq {
  String get brandId {
    if (brand is String) return brand as String;
    if (brand is Map) return (brand as Map)['id']?.toString() ?? '';
    return '';
  }
}

class Category {
  final String id;
  final String categoryName;
  final String description;
  final TypeInfo type;
  final bool isActive;
  final List<dynamic> subCategory;
  final String image;
  final bool show;
  final int? sequence;
  final bool primary;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String slug;
  final Brand? brand;
  final int sortSequence;

  Category({
    required this.id,
    required this.categoryName,
    required this.description,
    required this.type,
    required this.isActive,
    required this.subCategory,
    required this.image,
    required this.show,
    this.sequence,
    required this.primary,
    this.createdAt,
    this.updatedAt,
    required this.slug,
    this.brand,
    required this.sortSequence,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      categoryName: json['categoryName'] as String,
      description:
          json['description'] as String? ?? json['categoryName'] as String,
      type: TypeInfo.fromJson(json['type'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      subCategory: json['subCategory'] as List<dynamic>? ?? [],
      image: json['image'] as String? ?? '',
      show: json['show'] as bool? ?? true,
      sequence: json['sequence'] as int?,
      primary: json['primary'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      slug: json['slug'] as String,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      sortSequence: json['sortSequence'] as int? ?? 999999,
    );
  }
}

class TypeInfo {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool show;
  final bool isActive;

  TypeInfo({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.show,
    required this.isActive,
  });

  factory TypeInfo.fromJson(Map<String, dynamic> json) {
    return TypeInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      show: json['show'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String image;
  final bool isActive;
  final bool show;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String slug;

  Brand({
    required this.id,
    required this.name,
    required this.image,
    required this.isActive,
    required this.show,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.slug,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      show: json['show'] as bool? ?? true,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      slug: json['slug'] as String,
    );
  }
}

// Top-level response (jo API se aata hai)
class ProductResponse {
  final String message;
  final int totalProducts;
  final List<Product> products;

  ProductResponse({
    required this.message,
    required this.totalProducts,
    required this.products,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      message: json['message'] as String,
      totalProducts: json['totalProducts'] as int,
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

// Single product/service item (sabse zaroori fields hi rakhe)
class Product {
  final String id;
  final String name;
  final String? shortDescription;
  final String? image; // pehla image use kar lenge
  final String slug;
  final String? categoryName; // category se aata hai
  final int? gstPercentage;
  final List<PriceTier> prices; // multiple sizes wale prices
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    this.shortDescription,
    this.image,
    required this.slug,
    this.categoryName,
    this.gstPercentage,
    required this.prices,
    required this.isActive,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['price'] as List<dynamic>? ?? [];

    return Product(
      id: json['_id'] as String,
      name: json['productName'] as String? ?? 'Unnamed', // ← important match
      shortDescription: json['productShortDescription'] as String?,
      image: (json['productImage'] as List<dynamic>?)?.firstOrNull as String?,
      slug: json['slug'] as String? ?? '',
      categoryName:
          (json['category'] as Map<String, dynamic>?)?['categoryName']
              as String?,
      gstPercentage: (json["gstPercentage"] ?? 0),
      prices: pricesRaw
          .map((p) => PriceTier.fromJson(p as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// Simple price tier (size + price)
class PriceTier {
  final String size;
  final num price;

  PriceTier({required this.size, required this.price});

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(size: json['size'] as String, price: json['price'] as num);
  }
}
