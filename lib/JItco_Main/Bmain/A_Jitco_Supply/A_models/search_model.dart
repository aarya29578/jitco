class Products {
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  List<Product>? results;

  Products({this.total, this.page, this.limit, this.totalPages, this.results});

  Products.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];

    if (json['results'] != null) {
      results = (json['results'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['results'] = results?.map((e) => e.toJson()).toList();
    return data;
  }
}

class Product {
  String? id;
  String? productCode;
  String? productName;
  String? productShortDescription;
  String? productLongDescription;
  String? countryOrigin;
  int? gstPercentage;
  Category? category;
  int? productLength;
  int? productBreadth;
  int? productHeight;
  int? productWeight;
  int? returnWindow;
  String? instructions;
  String? hsn;
  String? vegNoneveg;
  bool? returnable;
  bool? cancellable;
  bool? cod;
  String? fulfilmentOption;
  String? sku;
  List<String>? productImage;
  String? warehouse;
  String? slot;
  int? mrp;
  int? purchasePrice;
  int? universalPrice;
  String? uom;
  int? uomValue;
  List<dynamic>? cuisine;
  int? quantityPerBox;
  String? batchNumber;
  dynamic manufacturedDate;
  dynamic expiryDate;
  int? quantity;
  bool? promoted;
  String? brand;
  int? boxPrice;
  int? sequence;
  String? shelfLife;
  bool? isActive;
  int? cessPercentage;
  String? slug;
  String? ingredients;
  String? usage;
  String? keywords;
  String? usp;
  List<String>? dietary;
  String? highlights;
  List<dynamic>? frequentlyBought;
  List<dynamic>? otherProducts;
  List<dynamic>? substituteProducts;
  bool? soldAsBox;
  String? manufacturerName;

  Product({
    this.id,
    this.productCode,
    this.productName,
    this.productShortDescription,
    this.productLongDescription,
    this.countryOrigin,
    this.gstPercentage,
    this.category,
    this.productLength,
    this.productBreadth,
    this.productHeight,
    this.productWeight,
    this.returnWindow,
    this.instructions,
    this.hsn,
    this.vegNoneveg,
    this.returnable,
    this.cancellable,
    this.cod,
    this.fulfilmentOption,
    this.sku,
    this.productImage,
    this.warehouse,
    this.slot,
    this.mrp,
    this.purchasePrice,
    this.universalPrice,
    this.uom,
    this.uomValue,
    this.cuisine,
    this.quantityPerBox,
    this.batchNumber,
    this.manufacturedDate,
    this.expiryDate,
    this.quantity,
    this.promoted,
    this.brand,
    this.boxPrice,
    this.sequence,
    this.shelfLife,
    this.isActive,
    this.cessPercentage,
    this.slug,
    this.ingredients,
    this.usage,
    this.keywords,
    this.usp,
    this.dietary,
    this.highlights,
    this.frequentlyBought,
    this.otherProducts,
    this.substituteProducts,
    this.soldAsBox,
    this.manufacturerName,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    productCode = json['productCode'];
    productName = json['productName'];
    productShortDescription = json['productShortDescription'];
    productLongDescription = json['productLongDescription'];
    countryOrigin = json['countryOrigin'];
    gstPercentage = json['gstPercentage'];
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;

    productLength = json['productLength'];
    productBreadth = json['productBreadth'];
    productHeight = json['productHeight'];
    productWeight = json['productWeight'];
    returnWindow = json['returnWindow'];
    instructions = json['instructions'];
    hsn = json['hsn'];
    vegNoneveg = json['vegNoneveg'];
    returnable = json['returnable'];
    cancellable = json['cancellable'];
    cod = json['cod'];
    fulfilmentOption = json['fulfilmentOption'];
    sku = json['sku'];

    productImage = json['productImage'] != null
        ? List<String>.from(json['productImage'])
        : null;

    warehouse = json['warehouse'];
    slot = json['slot'];
    mrp = json['mrp'];
    purchasePrice = json['purchasePrice'];
    universalPrice = json['universalPrice'];
    uom = json['uom'];
    uomValue = json['uomValue'];

    cuisine = json['cuisine'];

    quantityPerBox = json['quantityPerBox'];
    batchNumber = json['batchNumber'];
    manufacturedDate = json['manufacturedDate'];
    expiryDate = json['expiryDate'];
    quantity = json['quantity'];
    promoted = json['promoted'];
    brand = json['brand'];
    boxPrice = json['boxPrice'];
    sequence = json['sequence'];
    shelfLife = json['shelfLife'];
    isActive = json['isActive'];
    cessPercentage = json['cessPercentage'];
    slug = json['slug'];
    ingredients = json['ingredients'];
    usage = json['usage'];
    keywords = json['keywords'];
    usp = json['usp'];

    dietary = json['dietary'] != null
        ? List<String>.from(json['dietary'])
        : null;

    highlights = json['highlights'];

    frequentlyBought = json['frequentlyBought'];
    otherProducts = json['otherProducts'];
    substituteProducts = json['substituteProducts'];

    soldAsBox = json['soldAsBox'];
    manufacturerName = json['ManufacturerName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['_id'] = id;
    data['productCode'] = productCode;
    data['productName'] = productName;
    data['productShortDescription'] = productShortDescription;
    data['productLongDescription'] = productLongDescription;
    data['countryOrigin'] = countryOrigin;
    data['gstPercentage'] = gstPercentage;

    data['category'] = category?.toJson();

    data['productLength'] = productLength;
    data['productBreadth'] = productBreadth;
    data['productHeight'] = productHeight;
    data['productWeight'] = productWeight;
    data['returnWindow'] = returnWindow;
    data['instructions'] = instructions;
    data['hsn'] = hsn;
    data['vegNoneveg'] = vegNoneveg;
    data['returnable'] = returnable;
    data['cancellable'] = cancellable;
    data['cod'] = cod;
    data['fulfilmentOption'] = fulfilmentOption;
    data['sku'] = sku;

    data['productImage'] = productImage;
    data['warehouse'] = warehouse;
    data['slot'] = slot;
    data['mrp'] = mrp;
    data['purchasePrice'] = purchasePrice;
    data['universalPrice'] = universalPrice;
    data['uom'] = uom;
    data['uomValue'] = uomValue;

    data['cuisine'] = cuisine;
    data['quantityPerBox'] = quantityPerBox;
    data['batchNumber'] = batchNumber;
    data['manufacturedDate'] = manufacturedDate;
    data['expiryDate'] = expiryDate;
    data['quantity'] = quantity;
    data['promoted'] = promoted;
    data['brand'] = brand;
    data['boxPrice'] = boxPrice;
    data['sequence'] = sequence;
    data['shelfLife'] = shelfLife;
    data['isActive'] = isActive;
    data['cessPercentage'] = cessPercentage;
    data['slug'] = slug;
    data['ingredients'] = ingredients;
    data['usage'] = usage;
    data['keywords'] = keywords;
    data['usp'] = usp;
    data['dietary'] = dietary;
    data['highlights'] = highlights;

    data['frequentlyBought'] = frequentlyBought;
    data['otherProducts'] = otherProducts;
    data['substituteProducts'] = substituteProducts;

    data['soldAsBox'] = soldAsBox;
    data['ManufacturerName'] = manufacturerName;

    return data;
  }
}

class Category {
  String? id;
  String? categoryName;
  String? description;
  bool? isActive;
  List<dynamic>? subCategory;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? v;
  bool? show;
  int? sequence;
  String? type;
  String? slug;

  Category({
    this.id,
    this.categoryName,
    this.description,
    this.isActive,
    this.subCategory,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.show,
    this.sequence,
    this.type,
    this.slug,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    categoryName = json['categoryName'];
    description = json['description'];
    isActive = json['isActive'];
    subCategory = json['subCategory'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    show = json['show'];
    sequence = json['sequence'];
    type = json['type'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['_id'] = id;
    data['categoryName'] = categoryName;
    data['description'] = description;
    data['isActive'] = isActive;
    data['subCategory'] = subCategory;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    data['show'] = show;
    data['sequence'] = sequence;
    data['type'] = type;
    data['slug'] = slug;

    return data;
  }
}
