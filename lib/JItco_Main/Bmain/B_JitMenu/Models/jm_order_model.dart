// import 'package:intl/intl.dart';
// // import 'package:jitco_app/screens/Bmain/Jitco%20Menu/Models/detail_menu_model.dart';

// /* ================= ORDERS RESPONSE ================= */

// class OrdersResponse {
//   bool? success;
//   int? total;
//   int? page;
//   int? limit;
//   int? totalPages;
//   List<OrderDetails>? orders;

//   OrdersResponse({
//     this.success,
//     this.total,
//     this.page,
//     this.limit,
//     this.totalPages,
//     this.orders,
//   });

//   factory OrdersResponse.fromJson(Map<String, dynamic> json) => OrdersResponse(
//     success: json["success"],
//     total: json["total"],
//     page: json["page"],
//     limit: json["limit"],
//     totalPages: json["totalPages"],
//     orders: json["orders"] == null
//         ? []
//         : List<OrderDetails>.from(
//             json["orders"].map((x) => OrderDetails.fromJson(x)),
//           ),
//   );

//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "total": total,
//     "page": page,
//     "limit": limit,
//     "totalPages": totalPages,
//     "orders": orders == null
//         ? []
//         : List<dynamic>.from(orders!.map((x) => x.toJson())),
//   };
// }

// /* ================= ORDER DETAILS ================= */

// class OrderDetails {
//   String? id;
//   String? orderNumber;
//   Customer? customer;
//   Company? company;
//   Outlet? outlet;
//   String? shippingAddress;
//   String? billingAddress;
//   List<OrderItem>? items;
//   double? totalAmount;
//   double? discount;
//   double? gst;
//   double? cess;
//   double? finalAmount;
//   String? paymentStatus;
//   String? paymentMethod;
//   String? orderStatus;
//   List<dynamic>? warehouse;
//   List<dynamic>? slot;
//   List<dynamic>? outwardRef;
//   String? createdBy;
//   String? notes;
//   String? pinCode;
//   bool? contracted;
//   List<dynamic>? statusList;
//   String? source;
//   List<dynamic>? progress;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;

//   OrderDetails({
//     this.id,
//     this.orderNumber,
//     this.customer,
//     this.company,
//     this.outlet,
//     this.shippingAddress,
//     this.billingAddress,
//     this.items,
//     this.totalAmount,
//     this.discount,
//     this.gst,
//     this.cess,
//     this.finalAmount,
//     this.paymentStatus,
//     this.paymentMethod,
//     this.orderStatus,
//     this.warehouse,
//     this.slot,
//     this.outwardRef,
//     this.createdBy,
//     this.notes,
//     this.pinCode,
//     this.contracted,
//     this.statusList,
//     this.source,
//     this.progress,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//   });

//   factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
//     id: json["_id"] ?? "",
//     orderNumber: json["orderNumber"] ?? "",
//     customer: json["customer"] == null
//         ? null
//         : Customer.fromJson(json["customer"]),
//     company: json["company"] == null ? null : Company.fromJson(json["company"]),
//     outlet: json["outlet"] == null ? null : Outlet.fromJson(json["outlet"]),
//     shippingAddress: json["shippingAddress"]?.toString(),
//     billingAddress: json["billingAddress"]?.toString(),
//     items: json["items"] == null
//         ? []
//         : List<OrderItem>.from(json["items"].map((x) => OrderItem.fromJson(x))),
//     totalAmount: json["totalAmount"]?.toDouble(),
//     discount: json["discount"]?.toDouble(),
//     gst: json["gst"]?.toDouble(),
//     cess: json["cess"]?.toDouble(),
//     finalAmount: json["finalAmount"]?.toDouble(),
//     paymentStatus: json["paymentStatus"],
//     paymentMethod: json["paymentMethod"],
//     orderStatus: json["orderStatus"],
//     warehouse: json["warehouse"] ?? [],
//     slot: json["slot"] ?? [],
//     outwardRef: json["outwardRef"] ?? [],
//     createdBy: json["createdBy"],
//     notes: json["notes"],
//     pinCode: json["pin_code"],
//     contracted: json["contracted"],
//     statusList: json["statusList"] ?? [],
//     source: json["source"],
//     progress: json["progress"] ?? [],
//     createdAt: json["createdAt"] == null
//         ? null
//         : DateTime.parse(json["createdAt"]),
//     updatedAt: json["updatedAt"] == null
//         ? null
//         : DateTime.parse(json["updatedAt"]),
//     v: json["__v"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "orderNumber": orderNumber,
//     "customer": customer?.toJson(),
//     "company": company?.toJson(),
//     "outlet": outlet?.toJson(),
//     "shippingAddress": shippingAddress,
//     "billingAddress": billingAddress,
//     "items": items == null
//         ? []
//         : List<dynamic>.from(items!.map((x) => x.toJson())),
//     "totalAmount": totalAmount,
//     "discount": discount,
//     "gst": gst,
//     "cess": cess,
//     "finalAmount": finalAmount,
//     "paymentStatus": paymentStatus,
//     "paymentMethod": paymentMethod,
//     "orderStatus": orderStatus,
//     "warehouse": warehouse,
//     "slot": slot,
//     "outwardRef": outwardRef,
//     "createdBy": createdBy,
//     "notes": notes,
//     "pin_code": pinCode,
//     "contracted": contracted,
//     "statusList": statusList,
//     "source": source,
//     "progress": progress,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//   };

//   String get formattedDate => createdAt == null
//       ? "--"
//       : DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
// }

// /* ================= ORDER ITEM ================= */

// class OrderItem {
//   Product? product;
//   int? quantity;
//   double? price;
//   double? gst;
//   double? priceTotal;
//   double? gstTotal;
//   double? total;
//   String? id;

//   OrderItem({
//     this.product,
//     this.quantity,
//     this.price,
//     this.gst,
//     this.priceTotal,
//     this.gstTotal,
//     this.total,
//     this.id,
//   });

//   factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
//     product: json["product"] == null ? null : Product.fromJson(json["product"]),
//     quantity: json["quantity"],
//     price: json["price"]?.toDouble(),
//     gst: json["gst"]?.toDouble(),
//     priceTotal: json["priceTotal"]?.toDouble(),
//     gstTotal: json["gstTotal"]?.toDouble(),
//     total: json["total"]?.toDouble(),
//     id: json["_id"],
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

// /* ================= PRODUCT ================= */

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
//             json["price"].map((x) => ProductPrice.fromJson(x)),
//           ),
//     productImage: json["productImage"] == null
//         ? []
//         : List<String>.from(json["productImage"]),
//     productName: json["productName"] ?? "",
//     hasPrice: json["hasPrice"],
//     hasSequence: json["hasSequence"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "category": category?.toJson(),
//     "price": price == null
//         ? []
//         : List<dynamic>.from(price!.map((x) => x.toJson())),
//     "productImage": productImage,
//     "productName": productName,
//     "hasPrice": hasPrice,
//     "hasSequence": hasSequence,
//   };
// }

// /* ================= CATEGORY ================= */

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

//   Category.fromJson(Map<String, dynamic> json)
//     : id = json["_id"],
//       categoryName = json["categoryName"],
//       description = json["description"],
//       type = json["type"],
//       isActive = json["isActive"],
//       subCategory = json["subCategory"] ?? [],
//       image = json["image"],
//       show = json["show"],
//       sequence = json["sequence"],
//       primary = json["primary"],
//       createdAt = json["createdAt"] == null
//           ? null
//           : DateTime.parse(json["createdAt"]),
//       updatedAt = json["updatedAt"] == null
//           ? null
//           : DateTime.parse(json["updatedAt"]),
//       slug = json["slug"],
//       v = json["__v"],
//       brand = json["brand"];

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "categoryName": categoryName,
//     "description": description,
//     "type": type,
//     "isActive": isActive,
//     "subCategory": subCategory,
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

// /* ================= PRICE ================= */

// class ProductPrice {
//   String? size;
//   double? price;
//   String? id;

//   ProductPrice({this.size, this.price, this.id});

//   factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
//     size: json["size"],
//     price: json["price"]?.toDouble(),
//     id: json["_id"],
//   );

//   Map<String, dynamic> toJson() => {"size": size, "price": price, "_id": id};
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
//     phoneNumber: json["phone_number"] ?? 0,
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
//   City? city;
//   String? fssaiNumber;
//   String? gst;
//   String? msmeNumber;
//   String? pinCode;
//   DateTime? registrationDate;
//   StateModel? state;
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
//     v: json["__v"],
//     address: json["address"] ?? "",
//     city: json["city"] == null ? null : City.fromJson(json["city"]),
//     fssaiNumber: json["fssai_number"] ?? "",
//     gst: json["gst"] ?? "",
//     msmeNumber: json["msme_number"] ?? "",
//     pinCode: json["pin_code"] ?? "",
//     registrationDate: json["registrationDate"] == null
//         ? null
//         : DateTime.parse(json["registrationDate"]),
//     state: json["state"] == null ? null : StateModel.fromJson(json["state"]),
//     deliveryRadius: json["delivery_radius"] ?? "",
//     isActive: json["isActive"],
//     locality: json["locality"] ?? "",
//     locationClassification: json["location_classification"],
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
//     "city": city?.toJson(),
//     "fssai_number": fssaiNumber,
//     "gst": gst,
//     "msme_number": msmeNumber,
//     "pin_code": pinCode,
//     "registrationDate": registrationDate?.toIso8601String(),
//     "state": state?.toJson(),
//     "delivery_radius": deliveryRadius,
//     "isActive": isActive,
//     "locality": locality,
//     "location_classification": locationClassification,
//     "warehouse_proximity": warehouseProximity,
//   };
// }

// class City {
//   int? id;
//   String? name;
//   int? state;
//   int? v;

//   City({this.id, this.name, this.state, this.v});

//   factory City.fromJson(Map<String, dynamic> json) => City(
//     id: json["_id"],
//     name: json["name"],
//     state: json["state"],
//     v: json["__v"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "name": name,
//     "state": state,
//     "__v": v,
//   };
// }

// /* ---------------- STATE ---------------- */

// class StateModel {
//   int? id;
//   String? name;
//   List<int>? cities;
//   int? country;
//   int? v;

//   StateModel({this.id, this.name, this.cities, this.country, this.v});

//   factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
//     id: json["_id"],
//     name: json["name"],
//     cities: json["cities"] == null ? [] : List<int>.from(json["cities"]),
//     country: json["country"],
//     v: json["__v"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "name": name,
//     "cities": cities,
//     "country": country,
//     "__v": v,
//   };
// }

import 'package:intl/intl.dart';

/* ================= CITY ================= */

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

/* ================= STATE ================= */

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

/* ================= CATEGORY ================= */

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
    : id = json["_id"],
      categoryName = json["categoryName"],
      description = json["description"],
      type = json["type"],
      isActive = json["isActive"],
      subCategory = json["subCategory"] ?? [],
      image = json["image"],
      show = json["show"],
      sequence = json["sequence"],
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

/* ================= PRICE ================= */

class ProductPrice {
  String? size;
  double? price;
  String? id;

  ProductPrice({this.size, this.price, this.id});

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
    size: json["size"],
    price: json["price"]?.toDouble(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {"size": size, "price": price, "_id": id};
}

/* ================= PRODUCT ================= */

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
    hasPrice: json["hasPrice"],
    hasSequence: json["hasSequence"],
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

/* ================= ORDER ITEM ================= */

class OrderItem {
  Product? product;
  int? quantity;
  double? price;
  double? gst;
  double? priceTotal;
  double? gstTotal;
  double? total;
  String? id;

  OrderItem({
    this.product,
    this.quantity,
    this.price,
    this.gst,
    this.priceTotal,
    this.gstTotal,
    this.total,
    this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    quantity: json["quantity"],
    price: json["price"]?.toDouble(),
    gst: json["gst"]?.toDouble(),
    priceTotal: json["priceTotal"]?.toDouble(),
    gstTotal: json["gstTotal"]?.toDouble(),
    total: json["total"]?.toDouble(),
    id: json["_id"],
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

/* ================= CUSTOMER ================= */

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

/* ================= COMPANY ================= */

class Company {
  String? id;
  String? companyName;
  String? pan;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? contract;
  DateTime? contractExpireDate;
  List<String>? businessType;
  List<String>? cuisineType;
  List<String>? digitalEngagement;
  List<String>? financialMetrics;
  List<String>? procurementPattern;
  List<String>? relationshipStatus;
  List<String>? supplyChainComplexity;

  Company({
    this.id,
    this.companyName,
    this.pan,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.contract,
    this.contractExpireDate,
    this.businessType,
    this.cuisineType,
    this.digitalEngagement,
    this.financialMetrics,
    this.procurementPattern,
    this.relationshipStatus,
    this.supplyChainComplexity,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["_id"] ?? "",
    companyName: json["company_name"] ?? "",
    pan: json["PAN"] ?? "",
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"] ?? "",
    contract: json["contract"],
    contractExpireDate: json["contract_expire_date"] == null
        ? null
        : DateTime.parse(json["contract_expire_date"]),
    businessType: json["businessType"] == null
        ? []
        : List<String>.from(json["businessType"]!.map((x) => x)),
    cuisineType: json["cuisineType"] == null
        ? []
        : List<String>.from(json["cuisineType"]!.map((x) => x)),
    digitalEngagement: json["digitalEngagement"] == null
        ? []
        : List<String>.from(json["digitalEngagement"]!.map((x) => x)),
    financialMetrics: json["financialMetrics"] == null
        ? []
        : List<String>.from(json["financialMetrics"]!.map((x) => x)),
    procurementPattern: json["procurementPattern"] == null
        ? []
        : List<String>.from(json["procurementPattern"]!.map((x) => x)),
    relationshipStatus: json["relationshipStatus"] == null
        ? []
        : List<String>.from(json["relationshipStatus"]!.map((x) => x)),
    supplyChainComplexity: json["supplyChainComplexity"] == null
        ? []
        : List<String>.from(json["supplyChainComplexity"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "company_name": companyName,
    "PAN": pan,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "contract": contract,
    "contract_expire_date": contractExpireDate?.toIso8601String(),
    "businessType": businessType == null
        ? []
        : List<dynamic>.from(businessType!.map((x) => x)),
    "cuisineType": cuisineType == null
        ? []
        : List<dynamic>.from(cuisineType!.map((x) => x)),
    "digitalEngagement": digitalEngagement == null
        ? []
        : List<dynamic>.from(digitalEngagement!.map((x) => x)),
    "financialMetrics": financialMetrics == null
        ? []
        : List<dynamic>.from(financialMetrics!.map((x) => x)),
    "procurementPattern": procurementPattern == null
        ? []
        : List<dynamic>.from(procurementPattern!.map((x) => x)),
    "relationshipStatus": relationshipStatus == null
        ? []
        : List<dynamic>.from(relationshipStatus!.map((x) => x)),
    "supplyChainComplexity": supplyChainComplexity == null
        ? []
        : List<dynamic>.from(supplyChainComplexity!.map((x) => x)),
  };
}

/* ================= OUTLET ================= */

class Outlet {
  String? country;
  String? id;
  String? name;
  String? company;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? address;
  dynamic city; // Can be int or City object
  String? fssaiNumber;
  String? gst;
  String? msmeNumber;
  String? pinCode;
  DateTime? registrationDate;
  dynamic state; // Can be int or StateModel object
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
    city: json["city"], // Accepts either int or City object
    fssaiNumber: json["fssai_number"] ?? "",
    gst: json["gst"] ?? "",
    msmeNumber: json["msme_number"] ?? "",
    pinCode: json["pin_code"] ?? "",
    registrationDate: json["registrationDate"] == null
        ? null
        : DateTime.parse(json["registrationDate"]),
    state: json["state"], // Accepts either int or StateModel object
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
    "city": city is City ? (city as City).toJson() : city,
    "fssai_number": fssaiNumber,
    "gst": gst,
    "msme_number": msmeNumber,
    "pin_code": pinCode,
    "registrationDate": registrationDate?.toIso8601String(),
    "state": state is StateModel ? (state as StateModel).toJson() : state,
    "delivery_radius": deliveryRadius,
    "isActive": isActive,
    "locality": locality,
    "location_classification": locationClassification,
    "warehouse_proximity": warehouseProximity,
  };

  // Helper methods for easier access
  int? get cityId {
    if (city is int) return city as int;
    if (city is City) return (city as City).id;
    return null;
  }

  int? get stateId {
    if (state is int) return state as int;
    if (state is StateModel) return (state as StateModel).id;
    return null;
  }
}

/* ================= ORDER DETAILS ================= */

class OrderDetails {
  String? id;
  String? orderNumber;
  Customer? customer;
  Company? company;
  Outlet? outlet;
  String? shippingAddress;
  String? billingAddress;
  List<OrderItem>? items;
  double? totalAmount;
  double? discount;
  double? gst;
  double? cess;
  double? finalAmount;
  String? paymentStatus;
  String? paymentMethod;
  String? orderStatus;
  List<dynamic>? warehouse;
  List<dynamic>? slot;
  List<dynamic>? outwardRef;
  String? createdBy;
  String? notes;
  String? pinCode;
  bool? contracted;
  List<dynamic>? statusList;
  String? source;
  List<dynamic>? progress;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  OrderDetails({
    this.id,
    this.orderNumber,
    this.customer,
    this.company,
    this.outlet,
    this.shippingAddress,
    this.billingAddress,
    this.items,
    this.totalAmount,
    this.discount,
    this.gst,
    this.cess,
    this.finalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.orderStatus,
    this.warehouse,
    this.slot,
    this.outwardRef,
    this.createdBy,
    this.notes,
    this.pinCode,
    this.contracted,
    this.statusList,
    this.source,
    this.progress,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
    id: json["_id"] ?? "",
    orderNumber: json["orderNumber"] ?? "",
    customer: json["customer"] == null
        ? null
        : Customer.fromJson(json["customer"]),
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
    outlet: json["outlet"] == null ? null : Outlet.fromJson(json["outlet"]),
    shippingAddress: json["shippingAddress"]?.toString(),
    billingAddress: json["billingAddress"]?.toString(),
    items: json["items"] == null
        ? []
        : List<OrderItem>.from(json["items"].map((x) => OrderItem.fromJson(x))),
    totalAmount: json["totalAmount"]?.toDouble(),
    discount: json["discount"]?.toDouble(),
    gst: json["gst"]?.toDouble(),
    cess: json["cess"]?.toDouble(),
    finalAmount: json["finalAmount"]?.toDouble(),
    paymentStatus: json["paymentStatus"],
    paymentMethod: json["paymentMethod"],
    orderStatus: json["orderStatus"],
    warehouse: json["warehouse"] ?? [],
    slot: json["slot"] ?? [],
    outwardRef: json["outwardRef"] ?? [],
    createdBy: json["createdBy"],
    notes: json["notes"],
    pinCode: json["pin_code"],
    contracted: json["contracted"],
    statusList: json["statusList"] ?? [],
    source: json["source"],
    progress: json["progress"] ?? [],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]).toLocal(),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]).toLocal(),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "orderNumber": orderNumber,
    "customer": customer?.toJson(),
    "company": company?.toJson(),
    "outlet": outlet?.toJson(),
    "shippingAddress": shippingAddress,
    "billingAddress": billingAddress,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "totalAmount": totalAmount,
    "discount": discount,
    "gst": gst,
    "cess": cess,
    "finalAmount": finalAmount,
    "paymentStatus": paymentStatus,
    "paymentMethod": paymentMethod,
    "orderStatus": orderStatus,
    "warehouse": warehouse,
    "slot": slot,
    "outwardRef": outwardRef,
    "createdBy": createdBy,
    "notes": notes,
    "pin_code": pinCode,
    "contracted": contracted,
    "statusList": statusList,
    "source": source,
    "progress": progress,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  String get formattedDate => createdAt == null
      ? "--"
      : DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
}

/* ================= ORDERS RESPONSE ================= */

class OrdersResponse {
  bool? success;
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  List<OrderDetails>? orders;

  OrdersResponse({
    this.success,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.orders,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => OrdersResponse(
    success: json["success"],
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    orders: json["orders"] == null
        ? []
        : List<OrderDetails>.from(
            json["orders"].map((x) => OrderDetails.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
    "orders": orders == null
        ? []
        : List<dynamic>.from(orders!.map((x) => x.toJson())),
  };
}
