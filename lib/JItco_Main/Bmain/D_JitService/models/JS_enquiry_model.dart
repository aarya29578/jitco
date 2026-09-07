class JsEnquiryModel {
  String? id;
  String productId;
  String productName;
  String productStatus;
  int productQuantity;
  String productComment;
  String slug;
  int productPrice;
  int? productGst;
  String? createdAt;
  String? updatedAt;
  String? productImage;
  String? comment;
  List<dynamic>? progress;

  JsEnquiryModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.productStatus,
    required this.productQuantity,
    required this.productComment,
    required this.productPrice,
    required this.slug,
    this.productGst,
    this.createdAt,
    this.updatedAt,
    this.productImage,
    this.comment,
    this.progress,
  });

  factory JsEnquiryModel.fromJson(Map<String, dynamic> json) {
    // Extract product image if available
    String productImage = '';
    if (json['product']?['productImage'] != null &&
        json['product']?['productImage'] is List &&
        json['product']?['productImage'].isNotEmpty) {
      productImage = json['product']?['productImage'][0] ?? '';
    }

    // Get comment from various possible fields
    String comment =
        json['comment'] ??
        (json['comments'] is List && json['comments'].isNotEmpty
            ? json['comments'][0] ?? ''
            : '');

    // Helper for safe number parsing
    num parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val;
      return num.tryParse(val.toString()) ?? 0;
    }

    return JsEnquiryModel(
      id: json['_id'],
      productId: json['product']?['_id'] ?? '',
      productName: json['product']?['productName'] ?? '',
      productStatus: json['status'] ?? '',
      productQuantity: parseNum(json['quantity']).toInt(),
      productComment: comment,
      slug: json['product']?['slug'] ?? '',
      productPrice: parseNum(json['product']?['universalPrice']).toInt(),
      productGst: parseNum(json['product']?['gstPercentage']).toInt(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      productImage: productImage,
      comment: comment,
      progress: json['progress'],
    );
  }

  // Get formatted date
  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt!);
      return '${_formatTime(date)}';
    } catch (e) {
      return '';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Check if enquiry has stock available
  bool get hasStockAvailable {
    return productStatus == 'Stock Availability';
  }

  // Check if enquiry is closed
  bool get isClosed {
    return productStatus == 'Closed';
  }
}
