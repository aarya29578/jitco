class Advertise {
  bool? success;
  List<Ads>? ads;

  Advertise({this.success, this.ads});

  Advertise.fromJson(Map<String, dynamic> json) {
    success = json['success'];

    if (json['ads'] != null) {
      ads = (json['ads'] as List).map((v) => Ads.fromJson(v)).toList();
    } else if (json['data'] != null) {
      ads = (json['data'] as List).map((v) => Ads.fromJson(v)).toList();
    }
  }
}

class Ads {
  String? sId;
  String? title;
  String? image;
  String? targetUrl;
  List<String>? placement;
  String? startDate;
  String? endDate;
  bool? isActive;
  Brand? brand;
  Category? category;
  Product? product;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Ads({
    this.sId,
    this.title,
    this.image,
    this.targetUrl,
    this.placement,
    this.startDate,
    this.endDate,
    this.isActive,
    this.brand,
    this.category,
    this.product,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Ads.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    image = json['image'];
    targetUrl = json['target_url'];

    placement = json['placement'] != null
        ? List<String>.from(json['placement'])
        : [];

    startDate = json['start_date'];
    endDate = json['end_date'];
    isActive = json['isActive'];

    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }
}

class Brand {
  String? id;
  String? name;
  String? image;
  String? slug;

  Brand({this.id, this.name, this.image, this.slug});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    image = json['image'];
    slug = json['slug'];
  }
}

class Category {
  String? id;
  String? name;
  String? slug;

  Category({this.id, this.name, this.slug});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    slug = json['slug'];
  }
}

class Product {
  String? id;
  String? name;
  String? slug;

  Product({this.id, this.name, this.slug});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['productName'];
    slug = json['slug'];
  }
}
