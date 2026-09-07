// models/order_model.dart
import 'package:intl/intl.dart';

class OrderItem {
  String? id;
  String? productId;
  String? productName;
  String? productImage;
  String? productSlug;
  int? quantity;
  double? price;
  double? gst;
  double? priceTotal;
  double? gstTotal;
  double? total;
  String? slotDate;
  String? slotTime;

  OrderItem({
    this.id,
    this.productId,
    this.productName,
    this.productImage,
    this.productSlug,
    this.quantity,
    this.price,
    this.gst,
    this.priceTotal,
    this.gstTotal,
    this.total,
    this.slotDate,
    this.slotTime,
  });

  // factory OrderItem.fromJson(Map<String, dynamic> json) {
  //   final product = json['product'] as Map<String, dynamic>;
  //   final category = product['category'] as Map<String, dynamic>;
  //   final productImages = product['productImage'] as List<dynamic>;

  //   String image = productImages.isNotEmpty ? productImages[0] : '';

  //   return OrderItem(
  //     id: json['_id'] ?? '',
  //     productId: product['_id'] ?? '',
  //     productName: product['productName'] ?? '',
  //     productImage: image,
  //     productSlug: json['slug'] ?? '',
  //     quantity: (json['quantity'] ?? 0).toInt(),
  //     price: (json['price'] ?? 0).toDouble(),
  //     gst: (json['gst'] ?? 0).toDouble(),
  //     priceTotal: (json['priceTotal'] ?? 0).toDouble(),
  //     gstTotal: (json['gstTotal'] ?? 0).toDouble(),
  //     total: (json['total'] ?? 0).toDouble(),
  //   );
  // }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    final productImages = (product?['productImage'] as List<dynamic>?) ?? [];

    String image = productImages.isNotEmpty
        ? productImages.first.toString()
        : '';

    return OrderItem(
      id: json['_id']?.toString(),
      productId: product?['_id']?.toString(),
      productName: product?['productName']?.toString() ?? '',
      // productImage: image,
      productImage:
          json['product']?['productImage'] != null &&
              (json['product']['productImage'] as List).isNotEmpty
          ? json['product']['productImage'][0]
          : '',
      productSlug: product?['slug']?.toString() ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      price: (json['price'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      priceTotal: (json['priceTotal'] ?? 0).toDouble(),
      gstTotal: (json['gstTotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      slotDate: json['slot_date'],
      slotTime: json['slot_time'],
    );
  }

  // For UI display
  // double get pricePerItem => priceTotal! / quantity!; ///Future can be small bug
  double get pricePerItem =>
      (quantity ?? 1) == 0 ? 0 : (priceTotal ?? 0) / (quantity ?? 1);
  double get gstPerItem => gstTotal! / quantity!;
  double get totalPerItem => total! / quantity!;
}

class OrderProgress {
  String? comments;
  String? statusList;
  DateTime? date;
  String? pId;
  OrderProgress({this.comments, this.statusList, this.date, this.pId});

  factory OrderProgress.fromJson(Map<String, dynamic> json) {
    return OrderProgress(
      comments: json['comments'] ?? '',
      // date: json['date'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date']).toLocal()
          : null,
      pId: json['_id'] ?? '',
      statusList: json['statusList'] ?? '',
    );
  }
  String get formattedDate {
    if (date == null) return '';
    return DateFormat('MMMM dd, yyyy \'at\' hh:mm a').format(date!);
  }
}

class Order {
  String id;
  String orderNumber;
  DateTime createdAt;
  DateTime updatedAt;
  String status; // 'Processing', etc.
  List<OrderItem> items;
  double totalAmount;
  double discount;
  double gst;
  double cess;
  double finalAmount;
  String notes;
  String paymentStatus;
  String paymentMethod;
  String billingAddress;
  String shippingAddress;
  List<OrderProgress>? progress;
  String? comment;
  Outlet? outlet;

  Order({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.discount,
    required this.gst,
    required this.cess,
    required this.finalAmount,
    this.notes = '',
    required this.paymentStatus,
    required this.paymentMethod,
    required this.billingAddress,
    required this.shippingAddress,
    this.progress,
    this.comment,
    this.outlet,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // final items = (json['items'] as List<dynamic>)
    //     .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
    //     .toList();

    final items =
        (json['items'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return Order(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ).toLocal(),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ).toLocal(),

      status: json['orderStatus'] ?? 'Processing',
      items: items,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      cess: (json['cess'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      progress: (json['progress'] as List<dynamic>?)
          ?.map((e) => OrderProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? '',
      billingAddress: json['billingAddress']?.toString() ?? '',
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      comment: json['comment'],
      // outlet: Outlet.fromJson(json['outlet']),
      outlet: json['outlet'] is Map<String, dynamic>
          ? Outlet.fromJson(json['outlet'])
          : null,
    );
  }

  // Helper getters
  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  String get formattedDateUpdate {
    return DateFormat('MMMM dd, yyyy \'at\' hh:mm a').format(updatedAt);
  }

  String get formattedTotal => '₹${finalAmount.toStringAsFixed(2)}';

  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity!);
  }

  // Get first item for preview
  OrderItem? get firstItem => items.isNotEmpty ? items[0] : null;
}

class Outlet {
  String? id;
  String? name;
  String? address;
  String? country;
  String? pinCode;
  CityModel? city;
  StateModel? state;

  Outlet({
    this.id,
    this.name,
    this.address,
    this.country,
    this.pinCode,
    this.city,
    this.state,
  });

  factory Outlet.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Outlet();

    return Outlet(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pinCode: json['pin_code']?.toString() ?? '',
      // city: CityModel.fromJson(json['city']),
      // state: StateModel.fromJson(json['state']),
      city: json['city'] is Map<String, dynamic>
          ? CityModel.fromJson(json['city'])
          : null,

      state: json['state'] is Map<String, dynamic>
          ? StateModel.fromJson(json['state'])
          : null,
    );
  }
}

class StateModel {
  int? id;
  String? name;

  StateModel({this.id, this.name});

  factory StateModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StateModel();

    return StateModel(
      id: json['_id'] is int
          ? json['_id']
          : int.tryParse(json['_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
    );
  }
}

class CityModel {
  int? id;
  String? name;

  CityModel({this.id, this.name});

  factory CityModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CityModel();

    return CityModel(
      id: json['_id'] is int
          ? json['_id']
          : int.tryParse(json['_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
    );
  }
}
