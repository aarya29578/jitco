// class DetailMenuModel {
//   bool? success;
//   MenuDetails? menuDetails;

//   DetailMenuModel({this.success, this.menuDetails});

//   factory DetailMenuModel.fromJson(Map<String, dynamic> json) =>
//       DetailMenuModel(
//         success: json['success'],
//         menuDetails: json['menu'] == null
//             ? null
//             : MenuDetails.fromJson(json['menu']),
//       );

//   Map<String, dynamic> toJson() => {
//     'success': success,
//     'menu': menuDetails?.toJson(),
//   };
// }

// class Customer {
//   String? id;
//   int? phoneNumber;
//   String? type;
//   bool? loginAllowed;
//   bool? isActive;
//   bool? isPrimary;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? company;
//   String? outlet;
//   String? email;
//   String? fullName;

//   Customer({
//     this.id,
//     this.phoneNumber,
//     this.type,
//     this.loginAllowed,
//     this.isActive,
//     this.isPrimary,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.company,
//     this.outlet,
//     this.email,
//     this.fullName,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) => Customer(
//     id: json["_id"] ?? "",
//     phoneNumber: json["phone_number"] ?? "",
//     type: json["type"] ?? "",
//     loginAllowed: json["loginAllowed"],
//     isActive: json["isActive"],
//     isPrimary: json["isPrimary"],
//     createdAt: json["createdAt"] == null
//         ? null
//         : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null
//         ? null
//         : DateTime.parse(json["updatedAt"]),
//     v: json["__v"],
//     company: json["company"] ?? "",
//     outlet: json["outlet"] ?? "",
//     email: json["email"] ?? "",
//     fullName: json["full_name"] ?? "",
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "phone_number": phoneNumber,
//     "type": type,
//     "loginAllowed": loginAllowed,
//     "isActive": isActive,
//     "isPrimary": isPrimary,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//     "company": company,
//     "outlet": outlet,
//     "email": email,
//     "full_name": fullName,
//   };
// }

// class Company {
//   String? id;
//   String? companyName;
//   String? pan;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   bool? contract;
//   DateTime? contractExpireDate;
//   List<String>? businessType;
//   List<String>? cuisineType;
//   List<String>? digitalEngagement;
//   List<String>? financialMetrics;
//   List<String>? procurementPattern;
//   List<String>? relationshipStatus;
//   List<String>? supplyChainComplexity;

//   Company({
//     this.id,
//     this.companyName,
//     this.pan,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.contract,
//     this.contractExpireDate,
//     this.businessType,
//     this.cuisineType,
//     this.digitalEngagement,
//     this.financialMetrics,
//     this.procurementPattern,
//     this.relationshipStatus,
//     this.supplyChainComplexity,
//   });

//   factory Company.fromJson(Map<String, dynamic> json) => Company(
//     id: json["_id"] ?? "",
//     companyName: json["company_name"] ?? "",
//     pan: json["PAN"] ?? "",
//     createdAt: json["createdAt"] == null
//         ? null
//         : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null
//         ? null
//         : DateTime.parse(json["updatedAt"]),
//     v: json["__v"] ?? "",
//     contract: json["contract"],
//     contractExpireDate: json["contract_expire_date"] == null
//         ? null
//         : DateTime.parse(json["contract_expire_date"]),
//     businessType: json["businessType"] == null
//         ? []
//         : List<String>.from(json["businessType"]!.map((x) => x)),
//     cuisineType: json["cuisineType"] == null
//         ? []
//         : List<String>.from(json["cuisineType"]!.map((x) => x)),
//     digitalEngagement: json["digitalEngagement"] == null
//         ? []
//         : List<String>.from(json["digitalEngagement"]!.map((x) => x)),
//     financialMetrics: json["financialMetrics"] == null
//         ? []
//         : List<String>.from(json["financialMetrics"]!.map((x) => x)),
//     procurementPattern: json["procurementPattern"] == null
//         ? []
//         : List<String>.from(json["procurementPattern"]!.map((x) => x)),
//     relationshipStatus: json["relationshipStatus"] == null
//         ? []
//         : List<String>.from(json["relationshipStatus"]!.map((x) => x)),
//     supplyChainComplexity: json["supplyChainComplexity"] == null
//         ? []
//         : List<String>.from(json["supplyChainComplexity"]!.map((x) => x)),
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "company_name": companyName,
//     "PAN": pan,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//     "contract": contract,
//     "contract_expire_date": contractExpireDate?.toIso8601String(),
//     "businessType": businessType == null
//         ? []
//         : List<dynamic>.from(businessType!.map((x) => x)),
//     "cuisineType": cuisineType == null
//         ? []
//         : List<dynamic>.from(cuisineType!.map((x) => x)),
//     "digitalEngagement": digitalEngagement == null
//         ? []
//         : List<dynamic>.from(digitalEngagement!.map((x) => x)),
//     "financialMetrics": financialMetrics == null
//         ? []
//         : List<dynamic>.from(financialMetrics!.map((x) => x)),
//     "procurementPattern": procurementPattern == null
//         ? []
//         : List<dynamic>.from(procurementPattern!.map((x) => x)),
//     "relationshipStatus": relationshipStatus == null
//         ? []
//         : List<dynamic>.from(relationshipStatus!.map((x) => x)),
//     "supplyChainComplexity": supplyChainComplexity == null
//         ? []
//         : List<dynamic>.from(supplyChainComplexity!.map((x) => x)),
//   };
// }

// class Outlet {
//   String? country;
//   String? id;
//   String? name;
//   String? company;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? address;
//   int? city;
//   String? fssaiNumber;
//   String? gst;
//   String? msmeNumber;
//   String? pinCode;
//   DateTime? registrationDate;
//   int? state;
//   String? deliveryRadius;
//   bool? isActive;
//   String? locality;
//   dynamic locationClassification;
//   String? warehouseProximity;

//   Outlet({
//     this.country,
//     this.id,
//     this.name,
//     this.company,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.address,
//     this.city,
//     this.fssaiNumber,
//     this.gst,
//     this.msmeNumber,
//     this.pinCode,
//     this.registrationDate,
//     this.state,
//     this.deliveryRadius,
//     this.isActive,
//     this.locality,
//     this.locationClassification,
//     this.warehouseProximity,
//   });

//   factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
//     country: json["country"] ?? "",
//     id: json["_id"] ?? "",
//     name: json["name"] ?? "",
//     company: json["company"] ?? "",
//     createdAt: json["createdAt"] == null
//         ? null
//         : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null
//         ? null
//         : DateTime.parse(json["updatedAt"]),
//     v: json["__v"] ?? "",
//     address: json["address"] ?? "",
//     city: json["city"] ?? "",
//     fssaiNumber: json["fssai_number"] ?? "",
//     gst: json["gst"] ?? "",
//     msmeNumber: json["msme_number"] ?? "",
//     pinCode: json["pin_code"] ?? "",
//     registrationDate: json["registrationDate"] == null
//         ? null
//         : DateTime.parse(json["registrationDate"]),
//     state: json["state"] ?? "",
//     deliveryRadius: json["delivery_radius"] ?? "",
//     isActive: json["isActive"],
//     locality: json["locality"] ?? "",
//     locationClassification: json["location_classification"] ?? "",
//     warehouseProximity: json["warehouse_proximity"] ?? "",
//   );

//   Map<String, dynamic> toJson() => {
//     "country": country,
//     "_id": id,
//     "name": name,
//     "company": company,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//     "address": address,
//     "city": city,
//     "fssai_number": fssaiNumber,
//     "gst": gst,
//     "msme_number": msmeNumber,
//     "pin_code": pinCode,
//     "registrationDate": registrationDate?.toIso8601String(),
//     "state": state,
//     "delivery_radius": deliveryRadius,
//     "isActive": isActive,
//     "locality": locality,
//     "location_classification": locationClassification,
//     "warehouse_proximity": warehouseProximity,
//   };
// }

// class MenuDetails {
//   String? mId;
//   String? mNumber;
//   Customer? customer;
//   String? companyId;
//   Outlet? outlet;
//   String? shipAddress;
//   String? billAddress;
//   List<MenuItem>? menuItems;
//   int? totalAmount;
//   int? gstMenu;
//   int? finalAmount;
//   String? menuStatus;
//   String? createdBy;
//   String? notesMenu;
//   String? pincode;
//   // List<StatusList>? statusLists;
//   String? source;
//   // List<MenuProgress>? menuProgress;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;

//   MenuDetails({
//     this.mId,
//     this.mNumber,
//     this.customer,
//     this.companyId,
//     this.outlet,
//     this.shipAddress,
//     this.billAddress,
//     this.menuItems,
//     this.totalAmount,
//     this.gstMenu,
//     this.finalAmount,
//     this.menuStatus,
//     this.createdBy,
//     this.notesMenu,
//     this.pincode,
//     // this.statusLists,
//     this.source,
//     // this.menuProgress,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//   });

//   factory MenuDetails.fromJson(Map<String, dynamic> json) => MenuDetails(
//     mId: json['_id'] ?? "",
//     mNumber: json['menuNumber'] ?? "",
//     customer: json['customer'] == null
//         ? null
//         : Customer.fromJson(json['customer']),
//     companyId: json['company'] ?? "",
//     outlet: json['outlet'] == null ? null : Outlet.fromJson(json['outlet']),
//     shipAddress: json['shippingAddress'] ?? "",
//     billAddress: json['billingAddress'] ?? "",
//     menuItems: json['items'] == null
//         ? []
//         : List<MenuItem>.from(json['items']!.map((x) => MenuItem.fromJson(x))),
//     totalAmount: json['totalAmount'] ?? 0,
//     gstMenu: json['gst'],
//     finalAmount: json['finalAmount'] ?? 0,
//     menuStatus: json['menuStatus'] ?? "",
//     createdBy: json['createdBy'] ?? "",
//     notesMenu: json['notes'] ?? "",
//     pincode: json['pin_code'] ?? "",
//     // statusLists: json['statusList'] == null
//     //     ? []
//     //     : List<StatusList>.from(
//     //         json['statusList']!.map(
//     //           (x) => StatusList.fromJson(json['statusList']),
//     //         ),
//     //       ),
//     source: json['source'] ?? "",

//     // menuProgress: json['progress'] == null
//     //     ? []
//     //     : List<MenuProgress>.from(
//     //         json['progress']!.map(
//     //           (x) => MenuProgress.fromJson(json['progress']),
//     //         ),
//     //       ),
//     createdAt: json['createdAt'] == null
//         ? null
//         : DateTime.parse(json['createdAt']),
//     updatedAt: json['updatedAt'] == null
//         ? null
//         : DateTime.parse(json['updatedAt']),
//     v: json['__v'],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": mId,
//     "menuNumber": mNumber,
//     "customer": customer?.toJson(),
//     "company": companyId,
//     "outlet": outlet?.toJson(),
//     "shippingAddress": shipAddress,
//     "billingAddress": billAddress,
//     "items": menuItems == null
//         ? []
//         : List<dynamic>.from(menuItems!.map((x) => x.toJson())),
//     "totalAmount": totalAmount,
//     "gst": gstMenu,
//     "finalAmount": finalAmount,
//     "menuStatus": menuStatus,
//     "createdBy": createdBy,
//     "notes": notesMenu,
//     "pin_code": pincode,
//     // "statusList": statusLists == null
//     //     ? []
//     //     : List<dynamic>.from(statusLists!.map((x) => x)),
//     "source": source,
//     // "progress": menuProgress == null
//     //     ? []
//     //     : List<dynamic>.from(menuProgress!.map((x) => x)),
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//   };
// }

// class MenuItem {
//   Product? product;
//   int? quantity;
//   double? price;
//   double? gst;
//   double? priceTotal;
//   double? gstTotal;
//   double? total;
//   String? id;

//   MenuItem({
//     this.product,
//     this.quantity,
//     this.price,
//     this.gst,
//     this.priceTotal,
//     this.gstTotal,
//     this.total,
//     this.id,
//   });

//   factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
//     product: json["product"] == null ? null : Product.fromJson(json["product"]),
//     quantity: json["quantity"] ?? "",
//     price: json["price"]?.toDouble(),
//     gst: json["gst"]?.toDouble(),
//     priceTotal: json["priceTotal"]?.toDouble(),
//     gstTotal: json["gstTotal"]?.toDouble(),
//     total: json["total"]?.toDouble(),
//     id: json["_id"] ?? "",
//   );

//   Map<String, dynamic> toJson() => {
//     "product": product?.toJson(),
//     "quantity": quantity,
//     "price": price,
//     "gst": gst,
//     "priceTotal": priceTotal,
//     "gstTotal": gstTotal,
//     "total": total,
//     "_id": id,
//   };
// }

// class Product {
//   String? id;
//   Category? category;
//   List<ProductPrice>? price;
//   List<String>? productImage;
//   String? productName;
//   int? hasPrice;
//   int? hasSequence;

//   Product({
//     this.id,
//     this.category,
//     this.price,
//     this.productImage,
//     this.productName,
//     this.hasPrice,
//     this.hasSequence,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) => Product(
//     id: json["_id"] ?? "",
//     category: json["category"] == null
//         ? null
//         : Category.fromJson(json["category"]),
//     price: json["price"] == null
//         ? []
//         : List<ProductPrice>.from(
//             json["price"]!.map((x) => ProductPrice.fromJson(x)),
//           ),
//     productImage: json["productImage"] == null
//         ? []
//         : List<String>.from(json["productImage"]!.map((x) => x)),
//     productName: json["productName"] ?? "",
//     hasPrice: json["hasPrice"] ?? "",
//     hasSequence: json["hasSequence"] ?? "",
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "category": category?.toJson(),
//     "price": price == null
//         ? []
//         : List<dynamic>.from(price!.map((x) => x.toJson())),
//     "productImage": productImage == null
//         ? []
//         : List<dynamic>.from(productImage!.map((x) => x)),
//     "productName": productName,
//     "hasPrice": hasPrice,
//     "hasSequence": hasSequence,
//   };
// }

// class Category {
//   String? id;
//   String? categoryName;
//   String? description;
//   String? type;
//   bool? isActive;
//   List<dynamic>? subCategory;
//   String? image;
//   bool? show;
//   int? sequence;
//   bool? primary;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   String? slug;
//   int? v;
//   String? brand;

//   Category({
//     this.id,
//     this.categoryName,
//     this.description,
//     this.type,
//     this.isActive,
//     this.subCategory,
//     this.image,
//     this.show,
//     this.sequence,
//     this.primary,
//     this.createdAt,
//     this.updatedAt,
//     this.slug,
//     this.v,
//     this.brand,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//     id: json["_id"] ?? "",
//     categoryName: json["categoryName"] ?? "",
//     description: json["description"] ?? "",
//     type: json["type"] ?? "",
//     isActive: json["isActive"],
//     subCategory: json["subCategory"] == null
//         ? []
//         : List<dynamic>.from(json["subCategory"]!.map((x) => x)),
//     image: json["image"] ?? "",
//     show: json["show"],
//     sequence: json["sequence"] ?? "",
//     primary: json["primary"],
//     createdAt: json["createdAt"] == null
//         ? null
//         : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null
//         ? null
//         : DateTime.parse(json["updatedAt"]),
//     slug: json["slug"],
//     v: json["__v"],
//     brand: json["brand"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "categoryName": categoryName,
//     "description": description,
//     "type": type,
//     "isActive": isActive,
//     "subCategory": subCategory == null
//         ? []
//         : List<dynamic>.from(subCategory!.map((x) => x)),
//     "image": image,
//     "show": show,
//     "sequence": sequence,
//     "primary": primary,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "slug": slug,
//     "__v": v,
//     "brand": brand,
//   };
// }

// class ProductPrice {
//   String? size;
//   double? price;
//   String? id;

//   ProductPrice({this.size, this.price, this.id});

//   factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
//     size: json["size"] ?? "",
//     price: json["price"]?.toDouble(),
//     id: json["_id"] ?? "",
//   );

//   Map<String, dynamic> toJson() => {"size": size, "price": price, "_id": id};
// }

// class StatusList {}

// class MenuProgress {}

import 'package:intl/intl.dart';

class DetailMenuModel {
  bool? success;
  MenuDetails? menuDetails;

  DetailMenuModel({this.success, this.menuDetails});

  factory DetailMenuModel.fromJson(Map<String, dynamic> json) =>
      DetailMenuModel(
        success: json['success'],
        menuDetails: (json['menu'] ?? json['data']) == null
            ? null
            : MenuDetails.fromJson(json['menu'] ?? json['data']),
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'menu': menuDetails?.toJson(),
  };
}

/* ---------------- CUSTOMER ---------------- */

class Customer {
  String? id;
  int? phoneNumber;
  String? type;
  bool? loginAllowed;
  bool? isActive;
  bool? isPrimary;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? company;
  String? outlet;
  String? email;
  String? fullName;

  Customer({
    this.id,
    this.phoneNumber,
    this.type,
    this.loginAllowed,
    this.isActive,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.company,
    this.outlet,
    this.email,
    this.fullName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["_id"] ?? "",
    phoneNumber: json["phone_number"] ?? 0,
    type: json["type"] ?? "",
    loginAllowed: json["loginAllowed"],
    isActive: json["isActive"],
    isPrimary: json["isPrimary"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    company: json["company"] ?? "",
    outlet: json["outlet"] ?? "",
    email: json["email"] ?? "",
    fullName: json["full_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phone_number": phoneNumber,
    "type": type,
    "loginAllowed": loginAllowed,
    "isActive": isActive,
    "isPrimary": isPrimary,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "company": company,
    "outlet": outlet,
    "email": email,
    "full_name": fullName,
  };
}

/* ---------------- CITY ---------------- */

class City {
  int? id;
  String? name;
  int? state;
  int? v;

  City({this.id, this.name, this.state, this.v});

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json["_id"],
    name: json["name"],
    state: json["state"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "state": state,
    "__v": v,
  };
}

/* ---------------- STATE ---------------- */

class StateModel {
  int? id;
  String? name;
  List<int>? cities;
  int? country;
  int? v;

  StateModel({this.id, this.name, this.cities, this.country, this.v});

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
    id: json["_id"],
    name: json["name"],
    cities: json["cities"] == null ? [] : List<int>.from(json["cities"]),
    country: json["country"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "cities": cities,
    "country": country,
    "__v": v,
  };
}

/* ---------------- OUTLET ---------------- */

class Outlet {
  String? country;
  String? id;
  String? name;
  String? company;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? address;
  City? city;
  String? fssaiNumber;
  String? gst;
  String? msmeNumber;
  String? pinCode;
  DateTime? registrationDate;
  StateModel? state;
  String? deliveryRadius;
  bool? isActive;
  String? locality;
  dynamic locationClassification;
  String? warehouseProximity;

  Outlet({
    this.country,
    this.id,
    this.name,
    this.company,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.address,
    this.city,
    this.fssaiNumber,
    this.gst,
    this.msmeNumber,
    this.pinCode,
    this.registrationDate,
    this.state,
    this.deliveryRadius,
    this.isActive,
    this.locality,
    this.locationClassification,
    this.warehouseProximity,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) => Outlet(
    country: json["country"] ?? "",
    id: json["_id"] ?? "",
    name: json["name"] ?? "",
    company: json["company"] ?? "",
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    address: json["address"] ?? "",
    city: json["city"] == null ? null : City.fromJson(json["city"]),
    fssaiNumber: json["fssai_number"] ?? "",
    gst: json["gst"] ?? "",
    msmeNumber: json["msme_number"] ?? "",
    pinCode: json["pin_code"] ?? "",
    registrationDate: json["registrationDate"] == null
        ? null
        : DateTime.parse(json["registrationDate"]),
    state: json["state"] == null ? null : StateModel.fromJson(json["state"]),
    deliveryRadius: json["delivery_radius"] ?? "",
    isActive: json["isActive"],
    locality: json["locality"] ?? "",
    locationClassification: json["location_classification"],
    warehouseProximity: json["warehouse_proximity"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "country": country,
    "_id": id,
    "name": name,
    "company": company,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "address": address,
    "city": city?.toJson(),
    "fssai_number": fssaiNumber,
    "gst": gst,
    "msme_number": msmeNumber,
    "pin_code": pinCode,
    "registrationDate": registrationDate?.toIso8601String(),
    "state": state?.toJson(),
    "delivery_radius": deliveryRadius,
    "isActive": isActive,
    "locality": locality,
    "location_classification": locationClassification,
    "warehouse_proximity": warehouseProximity,
  };
}

/* ---------------- MENU DETAILS ---------------- */

class MenuDetails {
  String? mId;
  String? mNumber;
  Customer? customer;
  String? companyId;
  Outlet? outlet;
  String? shipAddress;
  String? billAddress;
  List<MenuItem>? menuItems;
  double? totalAmount;
  double? gstMenu;
  double? finalAmount;
  String? menuStatus;
  String? createdBy;
  String? notesMenu;
  String? pincode;
  // List<StatusList>? statusLists;
  String? source;
  // List<MenuProgress>? menuProgress;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  MenuDetails({
    this.mId,
    this.mNumber,
    this.customer,
    this.companyId,
    this.outlet,
    this.shipAddress,
    this.billAddress,
    this.menuItems,
    this.totalAmount,
    this.gstMenu,
    this.finalAmount,
    this.menuStatus,
    this.createdBy,
    this.notesMenu,
    this.pincode,
    // this.statusLists,
    this.source,
    // this.menuProgress,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory MenuDetails.fromJson(Map<String, dynamic> json) => MenuDetails(
    mId: json['_id'] ?? "",
    mNumber: json['menuNumber'] ?? "",
    customer: json['customer'] == null
        ? null
        : Customer.fromJson(json['customer']),
    companyId: json['company'] ?? "",
    outlet: json['outlet'] == null ? null : Outlet.fromJson(json['outlet']),
    shipAddress: json['shippingAddress'] ?? "",
    billAddress: json['billingAddress'] ?? "",
    menuItems: json['items'] == null
        ? []
        : List<MenuItem>.from(json['items'].map((x) => MenuItem.fromJson(x))),
    totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
    gstMenu: json['gst']?.toDouble(),
    finalAmount: json['finalAmount']?.toDouble() ?? 0.0,
    menuStatus: json['menuStatus'] ?? "",
    createdBy: json['createdBy'] ?? "",
    notesMenu: json['notes'] ?? "",
    pincode: json['pin_code'] ?? "",
    source: json['source'] ?? "",
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt']),
    v: json['__v'],
  );

  Map<String, dynamic> toJson() => {
    "_id": mId,
    "menuNumber": mNumber,
    "customer": customer?.toJson(),
    "company": companyId,
    "outlet": outlet?.toJson(),
    "shippingAddress": shipAddress,
    "billingAddress": billAddress,
    "items": menuItems == null
        ? []
        : List<dynamic>.from(menuItems!.map((x) => x.toJson())),
    "totalAmount": totalAmount,
    "gst": gstMenu,
    "finalAmount": finalAmount,
    "menuStatus": menuStatus,
    "createdBy": createdBy,
    "notes": notesMenu,
    "pin_code": pincode,
    // "statusList": statusLists,
    "source": source,
    // "progress": menuProgress,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  // Helper getters
  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
  }
}

/* ---------------- MENU ITEM ---------------- */

class MenuItem {
  Product? product;
  int? quantity;
  double? price;
  double? gst;
  double? priceTotal;
  double? gstTotal;
  double? total;
  String? id;

  MenuItem({
    this.product,
    this.quantity,
    this.price,
    this.gst,
    this.priceTotal,
    this.gstTotal,
    this.total,
    this.id,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    quantity: json["quantity"] ?? 0,
    price: json["price"]?.toDouble(),
    gst: json["gst"]?.toDouble(),
    priceTotal: json["priceTotal"]?.toDouble(),
    gstTotal: json["gstTotal"]?.toDouble(),
    total: json["total"]?.toDouble(),
    id: json["_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "product": product?.toJson(),
    "quantity": quantity,
    "price": price,
    "gst": gst,
    "priceTotal": priceTotal,
    "gstTotal": gstTotal,
    "total": total,
    "_id": id,
  };
}

/* ---------------- PRODUCT / CATEGORY / PRICE ---------------- */

class Product {
  String? id;
  Category? category;
  List<ProductPrice>? price;
  List<String>? productImage;
  String? productName;
  int? hasPrice;
  int? hasSequence;

  Product({
    this.id,
    this.category,
    this.price,
    this.productImage,
    this.productName,
    this.hasPrice,
    this.hasSequence,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"] ?? "",
    category: json["category"] == null
        ? null
        : Category.fromJson(json["category"]),
    price: json["price"] == null
        ? []
        : List<ProductPrice>.from(
            json["price"].map((x) => ProductPrice.fromJson(x)),
          ),
    productImage: json["productImage"] == null
        ? []
        : List<String>.from(json["productImage"]),
    productName: json["productName"] ?? "",
    hasPrice: json["hasPrice"] ?? 0,
    hasSequence: json["hasSequence"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "category": category?.toJson(),
    "price": price == null
        ? []
        : List<dynamic>.from(price!.map((x) => x.toJson())),
    "productImage": productImage,
    "productName": productName,
    "hasPrice": hasPrice,
    "hasSequence": hasSequence,
  };
}

class Category {
  String? id;
  String? categoryName;
  String? description;
  String? type;
  bool? isActive;
  List<dynamic>? subCategory;
  String? image;
  bool? show;
  int? sequence;
  bool? primary;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? slug;
  int? v;
  String? brand;

  Category.fromJson(Map<String, dynamic> json)
    : id = json["_id"] ?? "",
      categoryName = json["categoryName"] ?? "",
      description = json["description"] ?? "",
      type = json["type"] ?? "",
      isActive = json["isActive"],
      subCategory = json["subCategory"] ?? [],
      image = json["image"] ?? "",
      show = json["show"],
      sequence = json["sequence"] ?? 0,
      primary = json["primary"],
      createdAt = json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
      updatedAt = json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
      slug = json["slug"],
      v = json["__v"],
      brand = json["brand"];

  Map<String, dynamic> toJson() => {
    "_id": id,
    "categoryName": categoryName,
    "description": description,
    "type": type,
    "isActive": isActive,
    "subCategory": subCategory,
    "image": image,
    "show": show,
    "sequence": sequence,
    "primary": primary,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "slug": slug,
    "__v": v,
    "brand": brand,
  };
}

class ProductPrice {
  String? size;
  double? price;
  String? id;

  ProductPrice({this.size, this.price, this.id});

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
    size: json["size"] ?? "",
    price: json["price"]?.toDouble(),
    id: json["_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {"size": size, "price": price, "_id": id};
}
