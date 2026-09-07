class ProductSearchResponse {
  String? message;
  String? query;
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  List<SearchedProduct>? results;

  ProductSearchResponse({
    this.message,
    this.query,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.results,
  });

  ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    query = json['query'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];

    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((e) => SearchedProduct.fromJson(e))
          .toList();
    }
  }
}


class SearchedProduct {
  String? id;
  String? productCode;
  String? productName;
  String? productShortDescription;
  String? productLongDescription;
  String? countryOrigin;
  int? gstPercentage;
  Category? category;

  double? mrp;
  double? purchasePrice;
  double? universalPrice;

  String? uom;
  int? uomValue;

  List<String>? productImage;

  bool? returnable;
  bool? cancellable;
  bool? cod;
  bool? isActive;

  String? brand;
  String? slug;
  String? productType;

  SearchedProduct({
    this.id,
    this.productCode,
    this.productName,
    this.productShortDescription,
    this.productLongDescription,
    this.countryOrigin,
    this.gstPercentage,
    this.category,
    this.mrp,
    this.purchasePrice,
    this.universalPrice,
    this.uom,
    this.uomValue,
    this.productImage,
    this.returnable,
    this.cancellable,
    this.cod,
    this.isActive,
    this.brand,
    this.slug,
    this.productType,
  });

  SearchedProduct.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    productCode = json['productCode'];
    productName = json['productName'];
    productShortDescription = json['productShortDescription'];
    productLongDescription = json['productLongDescription'];
    countryOrigin = json['countryOrigin'];
    gstPercentage = json['gstPercentage'];

    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;

    mrp = (json['mrp'] as num?)?.toDouble();
    purchasePrice = (json['purchasePrice'] as num?)?.toDouble();
    universalPrice = (json['universalPrice'] as num?)?.toDouble();

    uom = json['uom'];
    uomValue = json['uomValue'];

    productImage = (json['productImage'] as List?)?.cast<String>();

    returnable = json['returnable'];
    cancellable = json['cancellable'];
    cod = json['cod'];
    isActive = json['isActive'];

    brand = json['brand'];
    slug = json['slug'];
    productType = json['productType'];
  }
}

class Category {
  String? id;
  String? categoryName;
  String? description;
  String? image;
  bool? isActive;
  bool? show;
  int? sequence;
  String? slug;

  Category({
    this.id,
    this.categoryName,
    this.description,
    this.image,
    this.isActive,
    this.show,
    this.sequence,
    this.slug,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    categoryName = json['categoryName'];
    description = json['description'];
    image = json['image'];
    isActive = json['isActive'];
    show = json['show'];
    sequence = json['sequence'];
    slug = json['slug'];
  }
}