// // Model
// class CartItem {
//   final String id;
//   final String name;
//   final String image;
//   final double price;
//   final double gstPercentage;
//   int quantity;
//   final String? categorySlug;
//   String? selectedVariant;
//   final double? originalPrice; // Store original price
//   final String? warehouseId;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//     required this.gstPercentage,
//     this.quantity = 1,
//     this.categorySlug,
//     this.selectedVariant,
//     this.originalPrice,
//     this.warehouseId,
//   });

//   // Convert percentage to decimal for calculations (5% -> 0.05)
//   double get _gstDecimal => gstPercentage / 100;

//   double get totalPrice => price * quantity;

//   // Tax for single item
//   double get perPriceTax => price * _gstDecimal;

//   // Tax for group item
//   double get groupPerPriceTax => perPriceTax * quantity;

//   double get totalPriceTax => totalPrice + groupPerPriceTax;

//   // Helper method to update price based on warehouse
//   CartItem copyWith({double? price, String? warehouseId}) {
//     return CartItem(
//       id: id,
//       name: name,
//       image: image,
//       price: price ?? this.price,
//       quantity: quantity,
//       categorySlug: categorySlug,
//       selectedVariant: selectedVariant,
//       gstPercentage: gstPercentage,
//       originalPrice: originalPrice ?? this.price,
//       warehouseId: warehouseId ?? this.warehouseId,
//     );
//   }

//   // Convert to Map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'image': image,
//       'price': price,
//       'gstPercentage': gstPercentage,
//       'quantity': quantity,
//       'categorySlug': categorySlug,
//       'selectedVariant': selectedVariant,
//       'originalPrice': originalPrice,
//       'warehouseId': warehouseId,
//     };
//   }

//   // Create from Map
//   factory CartItem.fromMap(Map<String, dynamic> map) {
//     return CartItem(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       image: map['image'] ?? '',
//       price: (map['price'] as num).toDouble(),
//       gstPercentage: (map['gstPercentage'] as num).toDouble(),
//       quantity: map['quantity'] ?? 1,
//       categorySlug: map['categorySlug'] ?? '',
//       selectedVariant: map['selectedVariant'],
//       originalPrice: map['originalPrice'] is int
//           ? (map['originalPrice'] as int).toDouble()
//           : map['originalPrice'] ?? map['price'],
//       warehouseId: map['warehouseId'],
//     );
//   }
// }

// Model
// class CartItem {
//   final String id;
//   final String name;
//   final String image;
//   final double price;
//   final double gstPercentage;
//   int quantity;
//   final String? categorySlug;
//   String? selectedVariant;
//   final double? originalPrice; // Store original price
//   final String? warehouseId;
//   final int? quantityPerBox; // ADD THIS
//   final String? uom; // ADD THIS
//   final String selectedUom;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.price,
//     required this.gstPercentage,
//     this.quantity = 1,
//     this.categorySlug,
//     this.selectedVariant,
//     this.originalPrice,
//     this.warehouseId,
//     this.quantityPerBox, // ADD THIS
//     this.uom, // ADD THIS
//     this.selectedUom = 'piece',
//   });

//   // Convert percentage to decimal for calculations (5% -> 0.05)
//   double get _gstDecimal => gstPercentage / 100;

//   double get totalPrice => price * quantity;

//   // Tax for single item
//   double get perPriceTax => price * _gstDecimal;

//   // Tax for group item
//   double get groupPerPriceTax => perPriceTax * quantity;

//   double get totalPriceTax => totalPrice + groupPerPriceTax;

//   // Helper method to update price based on warehouse
//   CartItem copyWith({
//     double? price,
//     String? warehouseId,
//     String? selectedVariant,
//     int? quantityPerBox,
//     String? uom,
//   }) {
//     return CartItem(
//       id: id,
//       name: name,
//       image: image,
//       price: price ?? this.price,
//       quantity: quantity,
//       categorySlug: categorySlug,
//       selectedVariant: selectedVariant ?? this.selectedVariant,
//       gstPercentage: gstPercentage,
//       originalPrice: originalPrice ?? this.price,
//       warehouseId: warehouseId ?? this.warehouseId,
//       quantityPerBox: quantityPerBox ?? this.quantityPerBox,
//       uom: uom ?? this.uom,
//     );
//   }

//   // Convert to Map for storage
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'image': image,
//       'price': price,
//       'gstPercentage': gstPercentage,
//       'quantity': quantity,
//       'categorySlug': categorySlug,
//       'selectedVariant': selectedVariant,
//       'originalPrice': originalPrice,
//       'warehouseId': warehouseId,
//       'quantityPerBox': quantityPerBox, // ADD THIS
//       'uom': uom, // ADD THIS
//     };
//   }

//   // Create from Map
//   factory CartItem.fromMap(Map<String, dynamic> map) {
//     return CartItem(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       image: map['image'] ?? '',
//       price: (map['price'] as num).toDouble(),
//       gstPercentage: (map['gstPercentage'] as num).toDouble(),
//       quantity: map['quantity'] ?? 1,
//       categorySlug: map['categorySlug'] ?? '',
//       selectedVariant: map['selectedVariant'],
//       originalPrice: map['originalPrice'] is int
//           ? (map['originalPrice'] as int).toDouble()
//           : map['originalPrice'] ?? map['price'],
//       warehouseId: map['warehouseId'],
//       quantityPerBox: map['quantityPerBox'] ?? 1, // ADD THIS
//       uom: map['uom'] ?? 'item', // ADD THIS
//     );
//   }
// }

class CartItem {
  final String id;
  final String name;
  final String image;
  double price;
  final double gstPercentage;
  final bool soldAsBox;
  int quantity;
  final String? categorySlug;
  String? selectedVariant;
  final double? originalPrice;
  final String? warehouseId;
  final int? quantityPerBox;
  final String? uom;
  final String? variantType;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    this.price = 0.0,
    required this.gstPercentage,
    this.soldAsBox = false,
    this.quantity = 1,
    this.categorySlug,
    this.selectedVariant,
    this.originalPrice,
    this.warehouseId,
    this.quantityPerBox,
    this.uom,
    this.variantType,
  });

  // Convert percentage to decimal for calculations (5% -> 0.05)
  double get _gstDecimal => gstPercentage / 100;

  double get totalPrice => price * quantity;

  // Tax for single item
  double get perPriceTax => price * _gstDecimal;

  // Tax for group item
  double get groupPerPriceTax => perPriceTax * quantity;

  double get totalPriceTax => totalPrice + groupPerPriceTax;

  // Helper method to update price based on warehouse
  CartItem copyWith({
    double? price,
    int? quantity,
    String? warehouseId,
    String? selectedVariant,
    int? quantityPerBox,
    String? uom,
    String? variantType,
    double? originalPrice,
  }) {
    return CartItem(
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
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
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
