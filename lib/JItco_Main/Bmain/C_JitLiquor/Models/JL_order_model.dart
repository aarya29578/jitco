// models/order_model.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/cart_model.dart';

class JlOrderModel {
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

  JlOrderModel({
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

  factory JlOrderModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    final productImages = (product?['productImage'] as List<dynamic>?) ?? [];

    String image = productImages.isNotEmpty
        ? productImages.first.toString()
        : '';

    return JlOrderModel(
      id: json['_id']?.toString(),
      productId: product?['_id']?.toString(),
      productName: product?['productName']?.toString() ?? '',
      productImage: image,
      productSlug: product?['slug']?.toString() ?? '',
      quantity: (json['quantity'] ?? 0).toInt(),
      price: (json['price'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      priceTotal: (json['priceTotal'] ?? 0).toDouble(),
      gstTotal: (json['gstTotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  // For UI display
  // double get pricePerItem => priceTotal! / quantity!; ///Future can be small bug
  double get pricePerItem =>
      (quantity ?? 1) == 0 ? 0 : (priceTotal ?? 0) / (quantity ?? 1);
  double get gstPerItem => gstTotal! / quantity!;
  double get totalPerItem => total! / quantity!;
}

class JlOrder {
  String id;
  String orderNumber;
  DateTime createdAt;
  DateTime updatedAt;
  String status; // 'Processing', etc.
  List<JlOrderModel> items;
  double totalAmount;
  double discount;
  double gst;
  double cess;
  double finalAmount;
  String paymentStatus;
  String paymentMethod;
  String billingAddress;
  String shippingAddress;

  JlOrder({
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
    required this.paymentStatus,
    required this.paymentMethod,
    required this.billingAddress,
    required this.shippingAddress,
  });

  factory JlOrder.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((item) => JlOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return JlOrder(
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
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? '',
      billingAddress: json['billingAddress']?.toString() ?? '',
      shippingAddress: json['shippingAddress']?.toString() ?? '',
    );
  }

  // Helper getters
  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  String get formattedTotal => '₹${finalAmount.toStringAsFixed(2)}';

  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity!);
  }

  // Get first item for preview
  JlOrderModel? get firstItem => items.isNotEmpty ? items[0] : null;
}
