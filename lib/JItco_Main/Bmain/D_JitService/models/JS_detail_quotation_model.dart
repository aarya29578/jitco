class JsDetailQuotationModel {
  final bool? status;
  final Quote? quote;

  JsDetailQuotationModel({this.status, this.quote});

  factory JsDetailQuotationModel.fromJson(Map<String, dynamic> json) {
    return JsDetailQuotationModel(
      status: json['status'] ?? false,
      quote: json['quote'] != null ? Quote.fromJson(json['quote']) : null,
    );
  }
}

class Quote {
  final String? qId;
  final String? qNum;
  final DateTime? qExpireDate;
  final double? qTaxRate;
  final double? qPrice;
  final int? qQuantity;
  final Company? qCompany;
  final Outlet? qOutlet;
  final User? qUser;
  final List<QuoteItems>? qItems;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quote({
    this.qId,
    this.qNum,
    this.qExpireDate,
    this.qTaxRate,
    this.qPrice,
    this.qQuantity,
    this.qCompany,
    this.qOutlet,
    this.qUser,
    this.qItems,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      qId: json['_id'] ?? '',
      qNum: json['quoteNo'] ?? '',
      qExpireDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'])
          : null,
      // qTaxRate: json['taxRate'] ?? 0.0,
      // qPrice: json['price'] ?? 0.0,
      qTaxRate: (json['taxRate'] ?? 0).toDouble(),
      qPrice: (json['price'] ?? 0).toDouble(),
      qQuantity: json['quantity'] ?? 0,

      ///for map
      // qCompany: Company.fromJson(json['company'] ?? {}),
      qCompany: json['company'] != null
          ? Company.fromJson(json['company'])
          : null,
      qOutlet: json['outlet'] != null ? Outlet.fromJson(json['outlet']) : null,

      // qUser: User.fromJson(json['user'] ?? {}),
      qUser: json['user'] != null ? User.fromJson(json['user']) : null,

      ///for list
      qItems:
          (json['items'] as List<dynamic>?)
              ?.map((e) => QuoteItems.fromJson(e))
              .toList() ??
          [],
      source: json['source'] ?? '',

      ///dateTime
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class Company {
  final String? cId;
  final String? cCompanyName;
  final String? cPAN;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? cContract;
  final DateTime? cContractExpireDate;

  Company({
    this.cId,
    this.cCompanyName,
    this.cPAN,
    this.createdAt,
    this.updatedAt,
    this.cContract,
    this.cContractExpireDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      cId: json['_id'] ?? '',
      cCompanyName: json['company_name'] ?? '',
      cPAN: json['PAN'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      cContract: json['contract'] ?? false,
      cContractExpireDate: json['contract_expire_date'] != null
          ? DateTime.parse(json['contract_expire_date'])
          : null,
    );
  }
}

class Outlet {
  final String? country;
  final String? id;
  final String? name;
  final String? address;
  final String? pinCode;
  final int? state;
  final int? city;

  Outlet({
    this.country,
    this.id,
    this.name,
    this.address,
    this.pinCode,
    this.state,
    this.city,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      country: json['country'] ?? '',
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      pinCode: json['pin_code'] ?? '',
      state: json['state'] ?? 0,
      city: json['city'] ?? 0,
    );
  }
}

class User {
  final String? id;
  final String? fullName;
  final String? email;
  final int? phone;

  User({this.id, this.fullName, this.email, this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? 0,
    );
  }
}

class QuoteItems {
  final Product? product;
  final String? id;
  final int? quantity;
  final double? price;
  final double? priceTotal;
  final double? gst;
  final double? gstTotal;
  final double? total;

  QuoteItems({
    this.id,
    this.product,
    this.quantity,
    this.price,
    this.priceTotal,
    this.gst,
    this.gstTotal,
    this.total,
  });

  factory QuoteItems.fromJson(Map<String, dynamic> json) {
    return QuoteItems(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      priceTotal: (json['priceTotal'] ?? 0).toDouble(),
      gst: json['gst'] != null ? (json['gst']).toDouble() : null,
      gstTotal: json['gstTotal'] != null ? (json['gstTotal']).toDouble() : null,
      total: json['total'] != null ? (json['total']).toDouble() : null,
    );
  }
}

class Product {
  final String? id;
  final String? productName;
  final String? productCode;
  final String? productShortDescription;
  final List<String>? productImage;
  final String? uom;
  final int? quantityPerBox;
  final bool? soldAsBox;
  final String? slug;
  final int? universalPrice;

  Product({
    this.id,
    this.productName,
    this.productCode,
    this.productShortDescription,
    this.productImage,
    this.uom,
    this.quantityPerBox,
    this.soldAsBox,
    this.slug,
    this.universalPrice,
  });

  // factory Product.fromJson(Map<String, dynamic> json) {
  //   return Product(
  //     id: json['_id'] ?? '',
  //     productName: json['productName'] ?? '',
  //     productCode: json['productCode'] ?? '',
  //     productShortDescription: json['productShortDescription'] ?? '',
  //     productImage:
  //         (json['productImage'] as List<dynamic>?)?.cast<String>() ?? [],
  //     uom: json['uom'] ?? '',
  //   );
  // }
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      productCode: json['productCode'] ?? '',
      productShortDescription: json['productShortDescription'] ?? '',
      productImage:
          (json['productImage'] as List<dynamic>?)?.cast<String>() ?? [],
      uom: json['uom'] ?? '',
      quantityPerBox: json['quantityPerBox'] ?? 0,
      soldAsBox: json['soldAsBox'] ?? false,
      slug: json['slug'] ?? '',
      universalPrice: json['universalPrice'] ?? 0,
    );
  }
}
