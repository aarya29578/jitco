class JlCartitem {
  final String id;
  final String name;
  final String image;
  final double price;
  final double? gstPercentage;
  int quantity;
  final String? categorySlug;
  String? selectedVariant;
  final double? originalPrice;
  final String? warehouseId;
  final int? quantityPerBox;
  final String? uom;
  final String? variantType;
  final String? selectedSize;
  JlCartitem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.gstPercentage,
    this.quantity = 1,
    this.categorySlug,
    this.selectedVariant,
    this.originalPrice,
    this.warehouseId,
    this.quantityPerBox,
    this.uom,
    this.variantType,
    this.selectedSize,
  });

  // Convert percentage to decimal for calculations (5% -> 0.05)
  double get _gstDecimal => gstPercentage! / 100;

  double get totalPrice => price * quantity;

  // Tax for single item
  double get perPriceTax => price * _gstDecimal;

  // Tax for group item
  double get groupPerPriceTax => perPriceTax * quantity;

  double get totalPriceTax => totalPrice + groupPerPriceTax;

  // Helper method to update price based on warehouse
  JlCartitem copyWith({
    double? price,
    int? quantity,
    String? warehouseId,
    String? selectedVariant,
    int? quantityPerBox,
    String? uom,
    String? variantType,
    double? originalPrice,
  }) {
    return JlCartitem(
      id: id,
      name: name,
      image: image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categorySlug: categorySlug,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      gstPercentage: gstPercentage,
      originalPrice: originalPrice ?? this.originalPrice,
      warehouseId: warehouseId ?? this.warehouseId,
      quantityPerBox: quantityPerBox ?? this.quantityPerBox,
      uom: uom ?? this.uom,
      variantType: variantType ?? this.variantType,
    );
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'gstPercentage': gstPercentage,
      'quantity': quantity,
      'categorySlug': categorySlug,
      'selectedVariant': selectedVariant,
      'originalPrice': originalPrice,
      'warehouseId': warehouseId,
      'quantityPerBox': quantityPerBox,
      'uom': uom,
      'variantType': variantType,
    };
  }

  // Create from Map
  factory JlCartitem.fromMap(Map<String, dynamic> map) {
    return JlCartitem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (map['gstPercentage'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
      categorySlug: map['categorySlug'] ?? '',
      selectedVariant: map['selectedVariant'],
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      warehouseId: map['warehouseId'],
      quantityPerBox: map['quantityPerBox'] ?? 1,
      uom: map['uom'] ?? 'item',
      variantType: map['variantType'] ?? 'piece',
    );
  }
}
