// contract_model.dart
// class ContractModel {
//   final bool success;
//   final int total;
//   final int page;
//   final int limit;
//   final int totalPages;
//   final List<ContractProduct> data;

//   ContractModel({
//     required this.success,
//     required this.total,
//     required this.page,
//     required this.limit,
//     required this.totalPages,
//     required this.data,
//   });

//   factory ContractModel.fromJson(Map<String, dynamic> json) {
//     print('\n🔄 ContractModel.fromJson() called');
//     print('🔄 Input JSON keys: ${json.keys.toList()}');

//     List<ContractProduct> dataList = [];

//     // According to your screenshot, the products are in 'products' key
//     if (json.containsKey('products') && json['products'] is List) {
//       final productsList = json['products'] as List;
//       print('📋 Found "products" list with ${productsList.length} items');

//       for (int i = 0; i < productsList.length; i++) {
//         try {
//           final productJson = productsList[i] as Map<String, dynamic>;
//           print(
//             '   Parsing product $i: ${productJson['productName'] ?? 'Unnamed'}',
//           );
//           dataList.add(ContractProduct.fromJson(productJson));
//         } catch (e) {
//           print('   ❌ Error parsing product $i: $e');
//         }
//       }
//     } else {
//       print('⚠️ No "products" key found in response');
//       print('⚠️ Available keys: ${json.keys.toList()}');
//     }

//     // Get total from totalProducts (from your screenshot)
//     final totalProducts = json['totalProducts'];
//     final totalValue = json['total'];

//     print('📊 totalProducts from API: $totalProducts');
//     print('📊 total from API: $totalValue');

//     return ContractModel(
//       success: json['message'] == 'Successfully', // Based on screenshot
//       total: totalProducts ?? totalValue ?? dataList.length,
//       page: json['page'] ?? 1,
//       limit: json['limit'] ?? 10,
//       totalPages: json['totalPages'] ?? 1,
//       data: dataList,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'success': success,
//       'total': total,
//       'page': page,
//       'limit': limit,
//       'totalPages': totalPages,
//       'data': data.map((product) => product.toJson()).toList(),
//     };
//   }
// }

// class ContractProduct {
//   final String id;
//   final String name;
//   final String productCode;
//   final String? description;
//   final String? image;
//   final String category;
//   final String categoryId;
//   final double price;
//   final String? brand;
//   final String? unit;
//   final bool inStock;
//   final int? quantity;
//   final String? countryOrigin;
//   final double? getPercentage;
//   final double? productLength;
//   final double? productBreadth;
//   final double? productHeight;
//   final double? productWeight;

//   ContractProduct({
//     required this.id,
//     required this.name,
//     required this.productCode,
//     this.description,
//     this.image,
//     required this.category,
//     required this.categoryId,
//     required this.price,
//     this.brand,
//     this.unit,
//     required this.inStock,
//     this.quantity,
//     this.countryOrigin,
//     this.getPercentage,
//     this.productLength,
//     this.productBreadth,
//     this.productHeight,
//     this.productWeight,
//   });

//   factory ContractProduct.fromJson(Map<String, dynamic> json) {
//     print('   🔍 Parsing ContractProduct...');

//     // Extract category information
//     String categoryName = 'Uncategorized';
//     String categoryId = '';

//     if (json.containsKey('category')) {
//       if (json['category'] is String) {
//         categoryName = json['category'];
//       } else if (json['category'] is Map) {
//         final categoryMap = json['category'] as Map<String, dynamic>;
//         categoryName =
//             categoryMap['name'] ??
//             categoryMap['categoryName'] ??
//             'Uncategorized';
//         categoryId = categoryMap['_id'] ?? categoryMap['id'] ?? '';
//         print('   📁 Category map: $categoryMap');
//       }
//     }

//     // Determine price - check various possible fields
//     double finalPrice = 0.0;
//     final priceFields = ['price', 'unitPrice', 'sellingPrice', 'retailPrice'];

//     for (var field in priceFields) {
//       if (json.containsKey(field) && json[field] != null) {
//         finalPrice = json[field].toDouble();
//         print('   💰 Using $field: $finalPrice');
//         break;
//       }
//     }

//     // If no price found, check for contract-specific pricing
//     if (finalPrice == 0.0) {
//       final contractPrice = json['contractPrice'];
//       final boxPrice = json['boxPrice'];
//       final universalPrice = json['universalPrice'];

//       if (contractPrice != null) {
//         finalPrice = contractPrice.toDouble();
//         print('   💰 Using contractPrice: $finalPrice');
//       } else if (boxPrice != null) {
//         finalPrice = boxPrice.toDouble();
//         print('   💰 Using boxPrice: $finalPrice');
//       } else if (universalPrice != null) {
//         finalPrice = universalPrice.toDouble();
//         print('   💰 Using universalPrice: $finalPrice');
//       }
//     }

//     return ContractProduct(
//       id: json['_id']?.toString() ?? '',
//       name:
//           json['productName']?.toString() ??
//           json['name']?.toString() ??
//           'Unnamed Product',
//       productCode: json['productCode']?.toString() ?? '',
//       description:
//           json['productShortDescription']?.toString() ??
//           json['productLongDescription']?.toString() ??
//           json['description']?.toString(),
//       image: json['productImage']?.toString() ?? json['imageUrl']?.toString(),
//       category: categoryName,
//       categoryId: categoryId,
//       price: finalPrice,
//       brand: json['brand']?['name'].toString(),
//       unit: json['unit']?.toString() ?? 'pcs',
//       inStock: json['inStock'] ?? true,
//       quantity: json['quantity'] ?? json['stockQuantity'],
//       countryOrigin: json['countryOrigin']?.toString(),
//       getPercentage: json['getPercentage']?.toDouble(),
//       productLength: json['productLength']?.toDouble(),
//       productBreadth: json['productBreadth']?.toDouble(),
//       productHeight: json['productHeight']?.toDouble(),
//       productWeight: json['productWeight']?.toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'productCode': productCode,
//       'description': description,
//       'image': image,
//       'category': category,
//       'categoryId': categoryId,
//       'price': price,
//       'brand': brand,
//       'unit': unit,
//       'inStock': inStock,
//       'quantity': quantity,
//       'countryOrigin': countryOrigin,
//       'getPercentage': getPercentage,
//       'productLength': productLength,
//       'productBreadth': productBreadth,
//       'productHeight': productHeight,
//       'productWeight': productWeight,
//     };
//   }
// }

class ContractModel {
  final bool success;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final List<ContractProduct> data;

  ContractModel({
    required this.success,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.data,
  });

  // factory ContractModel.fromJson(Map<String, dynamic> json) {
  //   print('\n🔄 ContractModel.fromJson() called');
  //   print('🔄 Input JSON keys: ${json.keys.toList()}');
  //   List<ContractProduct> dataList = [];
  //   // According to your screenshot, the products are in 'products' key
  //   if (json.containsKey('products') && json['products'] is List) {
  //     final productsList = json['products'] as List;
  //     print('📋 Found "products" list with ${productsList.length} items');
  //     for (int i = 0; i < productsList.length; i++) {
  //       try {
  //         final productJson = productsList[i] as Map<String, dynamic>;
  //         print(
  //           '   Parsing product $i: ${productJson['productName'] ?? 'Unnamed'}',
  //         );
  //         dataList.add(ContractProduct.fromJson(productJson));
  //       } catch (e) {
  //         print('   ❌ Error parsing product $i: $e');
  //       }
  //     }
  //   } else {
  //     print('⚠️ No "products" key found in response');
  //     print('⚠️ Available keys: ${json.keys.toList()}');
  //   }
  //   // Get total from totalProducts (from your screenshot)
  //   final totalProducts = json['totalProducts'];
  //   final totalValue = json['total'];
  //   print('📊 totalProducts from API: $totalProducts');
  //   print('📊 total from API: $totalValue');
  //   return ContractModel(
  //     success: json['message'] == 'Successfully', // Based on screenshot
  //     total: totalProducts ?? totalValue ?? dataList.length,
  //     page: json['page'] ?? 1,
  //     limit: json['limit'] ?? 10,
  //     totalPages: json['totalPages'] ?? 1,
  //     data: dataList,
  //   );
  // }

  // factory ContractModel.fromJson(Map<String, dynamic> json) {
  //   print('\n🔄 ContractModel.fromJson() called');
  //   print('🔄 Input JSON keys: ${json.keys.toList()}');
  //   List<ContractProduct> dataList = [];
  //   // FIRST: Check if this is a search API response
  //   if (json.containsKey('results') && json['results'] is List) {
  //     print('🔍 Found "results" key (searchContractProducts API)');
  //     final resultsList = json['results'] as List;
  //     print('📊 Search API returned ${resultsList.length} results');
  //     for (int i = 0; i < resultsList.length; i++) {
  //       try {
  //         final productJson = resultsList[i] as Map<String, dynamic>;
  //         print(
  //           '   🔍 Parsing search result $i: ${productJson['name'] ?? 'Unnamed'}',
  //         );
  //         dataList.add(ContractProduct.fromJson(productJson));
  //       } catch (e) {
  //         print('   ❌ Error parsing search result $i: $e');
  //       }
  //     }
  //   }
  //   // SECOND: Check if this is a regular contract API response
  //   else if (json.containsKey('products') && json['products'] is List) {
  //     print('📦 Found "products" key (getContractData API)');
  //     final productsList = json['products'] as List;
  //     print('📊 Contract API returned ${productsList.length} products');
  //     for (int i = 0; i < productsList.length; i++) {
  //       try {
  //         final productJson = productsList[i] as Map<String, dynamic>;
  //         print(
  //           '   📦 Parsing contract product $i: ${productJson['productName'] ?? 'Unnamed'}',
  //         );
  //         dataList.add(ContractProduct.fromJson(productJson));
  //       } catch (e) {
  //         print('   ❌ Error parsing contract product $i: $e');
  //       }
  //     }
  //   } else {
  //     print('⚠️ No "results" or "products" key found in response');
  //     print('⚠️ Available keys: ${json.keys.toList()}');
  //   }
  //   // Get totals from different possible keys
  //   final totalProducts = json['totalProducts'];
  //   final totalValue = json['total'];
  //   final totalResults = json['totalResults'];
  //   print('📊 totalProducts from API: $totalProducts');
  //   print('📊 total from API: $totalValue');
  //   print('📊 totalResults from API: $totalResults');
  //   // Decide which total to use
  //   int finalTotal;
  //   if (totalResults != null) {
  //     // Search API uses totalResults
  //     finalTotal = totalResults;
  //   } else if (totalProducts != null) {
  //     // Contract API uses totalProducts
  //     finalTotal = totalProducts;
  //   } else if (totalValue != null) {
  //     // Fallback to total
  //     finalTotal = totalValue;
  //   } else {
  //     // Default to data list length
  //     finalTotal = dataList.length;
  //   }
  //   return ContractModel(
  //     success:
  //         json['success'] ??
  //         (json['message']?.toString().contains('Success') ?? true),
  //     total: finalTotal,
  //     page: json['page'] ?? 1,
  //     limit: json['limit'] ?? 10,
  //     totalPages: json['totalPages'] ?? 1,
  //     data: dataList,
  //   );
  // }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    print('\n🔄 ContractModel.fromJson() called');
    print('🔄 Input JSON keys: ${json.keys.toList()}');

    List<ContractProduct> dataList = [];

    // Handle search API response
    if (json.containsKey('results') && json['results'] is List) {
      print('🔍 Found "results" key (searchContractProducts API)');
      final resultsList = json['results'] as List;
      print('📊 Search API returned ${resultsList.length} results');

      for (int i = 0; i < resultsList.length; i++) {
        try {
          final productJson = resultsList[i] as Map<String, dynamic>;
          print(
            '   🔍 Parsing search result $i: ${productJson['productName'] ?? productJson['name'] ?? 'Unnamed'}',
          );
          dataList.add(ContractProduct.fromJson(productJson));
        } catch (e, stackTrace) {
          print('   ❌ Error parsing search result $i: $e');
          print('   Stack trace: $stackTrace');
          // Log the problematic JSON for debugging
          if (resultsList[i] is Map) {
            print('   Problematic JSON: ${resultsList[i]}');
          }
        }
      }
    }
    // Handle regular contract API response
    else if (json.containsKey('products') && json['products'] is List) {
      print('📦 Found "products" key (getContractData API)');
      final productsList = json['products'] as List;
      print('📊 Contract API returned ${productsList.length} products');

      for (int i = 0; i < productsList.length; i++) {
        try {
          final productJson = productsList[i] as Map<String, dynamic>;
          print(
            '   📦 Parsing contract product $i: ${productJson['productName'] ?? 'Unnamed'}',
          );
          dataList.add(ContractProduct.fromJson(productJson));
        } catch (e) {
          print('   ❌ Error parsing contract product $i: $e');
        }
      }
    } else {
      print('⚠️ No "results" or "products" key found in response');
      print('⚠️ Available keys: ${json.keys.toList()}');
    }

    // Parse totals - handle both String and int types
    final totalProducts = json['totalProducts'];
    final totalValue = json['total'];
    final totalResults = json['totalResults'];

    // Convert to int if they're strings
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.tryParse(value) ?? 0;
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    print(
      '📊 totalProducts from API: $totalProducts (type: ${totalProducts.runtimeType})',
    );
    print('📊 total from API: $totalValue (type: ${totalValue.runtimeType})');
    print(
      '📊 totalResults from API: $totalResults (type: ${totalResults.runtimeType})',
    );

    // Decide which total to use
    int finalTotal;

    if (totalResults != null) {
      finalTotal = parseToInt(totalResults);
    } else if (totalProducts != null) {
      finalTotal = parseToInt(totalProducts);
    } else if (totalValue != null) {
      finalTotal = parseToInt(totalValue);
    } else {
      finalTotal = dataList.length;
    }

    // Parse other numeric fields
    final page = parseToInt(json['page']);
    final limit = parseToInt(json['limit']);
    final totalPages = parseToInt(json['totalPages'] ?? json['totalpages']);

    print(
      '📊 Parsed values - page: $page, limit: $limit, totalPages: $totalPages, total: $finalTotal',
    );

    return ContractModel(
      success:
          json['success'] ??
          (json['message']?.toString().contains('Search') ?? true),
      total: finalTotal,
      page: page,
      limit: limit,
      totalPages: totalPages,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'data': data.map((product) => product.toJson()).toList(),
    };
  }
}

class ContractProduct {
  final String id;
  final String name;
  final String productCode;
  final String? description;
  final List<String> productImages;
  final String category;
  final String categoryId;
  final double price;
  final String slug;
  // final String? brand;
  final String? unit;
  final bool inStock;
  final int? quantity;
  final String? countryOrigin;
  final double? gstPercentage;
  final double? productLength;
  final double? productBreadth;
  final double? productHeight;
  final double? productWeight;

  final bool soldAsBox;
  final int quantityPerBox;

  ContractProduct({
    required this.id,
    required this.name,
    required this.productCode,
    this.description,
    required this.productImages,
    required this.category,
    required this.categoryId,
    required this.price,
    required this.slug,
    // this.brand,
    this.unit,
    required this.inStock,
    this.quantity,
    this.countryOrigin,
    this.gstPercentage,
    this.productLength,
    this.productBreadth,
    this.productHeight,
    this.productWeight,

    required this.soldAsBox,
    required this.quantityPerBox,
  });

  // factory ContractProduct.fromJson(Map<String, dynamic> json) {
  //   print('   🔍 Parsing ContractProduct...');
  //   // Extract category information
  //   String categoryName = 'Uncategorized';
  //   String categoryId = '';
  //   final bool soldAsBox = json['soldAsBox'] == true;
  //   final int quantityPerBox = json['quantityPerBox'] ?? 1;
  //   if (json.containsKey('category')) {
  //     if (json['category'] is String) {
  //       categoryName = json['category'];
  //     } else if (json['category'] is Map) {
  //       final categoryMap = json['category'] as Map<String, dynamic>;
  //       categoryName =
  //           categoryMap['name'] ??
  //           categoryMap['categoryName'] ??
  //           'Uncategorized';
  //       categoryId = categoryMap['_id'] ?? categoryMap['id'] ?? '';
  //       print('   📁 Category map: $categoryMap');
  //     }
  //   }
  //   // Handle productImages - it's a List from your screenshot
  //   List<String> images = [];
  //   if (json.containsKey('productImage') && json['productImage'] is List) {
  //     final imageList = json['productImage'] as List;
  //     print('   📸 Found productImage list with ${imageList.length} items');
  //     for (var item in imageList) {
  //       if (item != null && item.toString().isNotEmpty) {
  //         images.add(item.toString());
  //         print('   📸 Image URL: $item');
  //       }
  //     }
  //   }
  //   // Fallback for single image
  //   else if (json.containsKey('image') && json['image'] is String) {
  //     images.add(json['image'].toString());
  //     print('   📸 Using single image field: ${json['image']}');
  //   } else if (json.containsKey('imageUrl') && json['imageUrl'] is String) {
  //     images.add(json['imageUrl'].toString());
  //     print('   📸 Using imageUrl field: ${json['imageUrl']}');
  //   }
  //   // Fallback for list in different key
  //   else if (json.containsKey('images') && json['images'] is List) {
  //     final imageList = json['images'] as List;
  //     for (var item in imageList) {
  //       if (item != null && item.toString().isNotEmpty) {
  //         images.add(item.toString());
  //       }
  //     }
  //   }
  //   // Determine price - check various possible fields
  //   double finalPrice = 0.0;
  //   final priceFields = ['price', 'unitPrice', 'sellingPrice', 'retailPrice'];
  //   for (var field in priceFields) {
  //     if (json.containsKey(field) && json[field] != null) {
  //       finalPrice = json[field].toDouble();
  //       print('   💰 Using $field: $finalPrice');
  //       break;
  //     }
  //   }
  //   // If no price found, check for contract-specific pricing
  //   if (finalPrice == 0.0) {
  //     final double contractPrice = (json['contractPrice'] ?? 0).toDouble();
  //     final double boxPrice = (json['boxPrice'] ?? 0).toDouble();
  //     final double universalPrice = (json['universalPrice'] ?? 0).toDouble();
  //     // final int quantityPerBox = json['quantityPerBox'] ?? 1;
  //     // final bool soldAsBox = json['soldAsBox'] == true;
  //     if (soldAsBox) {
  //       if (contractPrice > 0) {
  //         finalPrice = contractPrice * quantityPerBox;
  //         print('💰 USING CONTRACT BOX PRICE: $finalPrice');
  //       } else if (boxPrice > 0) {
  //         finalPrice = boxPrice;
  //         print('💰 USING BOX PRICE: $finalPrice');
  //       } else if (universalPrice > 0) {
  //         finalPrice = universalPrice;
  //         print('💰 USING UNIVERSAL BOX PRICE: $finalPrice');
  //       }
  //     } else {
  //       if (contractPrice > 0) {
  //         finalPrice = contractPrice;
  //         print('💰 USING CONTRACT SINGLE PRICE: $finalPrice');
  //       } else if (universalPrice > 0) {
  //         finalPrice = universalPrice;
  //         print('💰 USING UNIVERSAL SINGLE PRICE: $finalPrice');
  //       }
  //     }
  //     if (finalPrice == 0.0) {
  //       print('⚠️ NO PRICE FOUND FOR PRODUCT');
  //     }
  //   }
  //   // final bool soldAsBox = json['soldAsBox'] == true;
  //   // final int quantityPerBox = json['quantityPerBox'] ?? 1;
  // return ContractProduct(
  //   id: json['_id']?.toString() ?? '',
  //   name:
  //       json['productName']?.toString() ??
  //       json['name']?.toString() ??
  //       'Unnamed Product',
  //   productCode: json['productCode']?.toString() ?? '',
  //   description:
  //       json['productShortDescription']?.toString() ??
  //       json['productLongDescription']?.toString() ??
  //       json['description']?.toString(),
  //   productImages: images,
  //   category: categoryName,
  //   categoryId: categoryId,
  //   price: finalPrice,
  //   brand: json['brand']?['name']?.toString(),
  //   slug: json['slug'],
  //   unit: json['unit']?.toString() ?? 'pcs',
  //   inStock: json['inStock'] ?? true,
  //   quantity: json['quantity'] ?? json['stockQuantity'],
  //   countryOrigin: json['countryOrigin']?.toString(),
  //   gstPercentage: json['gstPercentage']?.toDouble(),
  //   productLength: json['productLength']?.toDouble(),
  //   productBreadth: json['productBreadth']?.toDouble(),
  //   productHeight: json['productHeight']?.toDouble(),
  //   productWeight: json['productWeight']?.toDouble(),
  //   soldAsBox: soldAsBox,
  //   quantityPerBox: quantityPerBox,
  // );
  // }

  factory ContractProduct.fromJson(Map<String, dynamic> json) {
    print('   🔍 Parsing ContractProduct...');
    print('   📋 JSON keys: ${json.keys.toList()}');

    // Extract category information
    String categoryName = 'Uncategorized';
    String categoryId = '';

    // SAFELY parse boolean and int values
    final bool soldAsBox =
        json['soldAsBox'] == true || json['soldAsBox'] == 'true';

    // SAFELY parse quantityPerBox - handle both String and int
    int quantityPerBox = 1;
    if (json['quantityPerBox'] != null) {
      if (json['quantityPerBox'] is int) {
        quantityPerBox = json['quantityPerBox'];
      } else if (json['quantityPerBox'] is String) {
        quantityPerBox = int.tryParse(json['quantityPerBox']) ?? 1;
      } else if (json['quantityPerBox'] is num) {
        quantityPerBox = (json['quantityPerBox'] as num).toInt();
      }
    }

    if (json.containsKey('category')) {
      if (json['category'] is String) {
        categoryName = json['category'];
      } else if (json['category'] is Map) {
        final categoryMap = json['category'] as Map<String, dynamic>;
        categoryName =
            categoryMap['name'] ??
            categoryMap['categoryName'] ??
            'Uncategorized';
        categoryId =
            categoryMap['_id']?.toString() ??
            categoryMap['id']?.toString() ??
            '';
        print('   📁 Category map: $categoryMap');
      }
    }

    // Handle productImages - it's a List from your screenshot
    List<String> images = [];

    if (json.containsKey('productImage') && json['productImage'] is List) {
      final imageList = json['productImage'] as List;
      print('   📸 Found productImage list with ${imageList.length} items');

      for (var item in imageList) {
        if (item != null && item.toString().isNotEmpty) {
          images.add(item.toString());
          print('   📸 Image URL: $item');
        }
      }
    }
    // Fallback for search API - might have 'image' as String
    else if (json.containsKey('image') && json['image'] != null) {
      final image = json['image'].toString();
      if (image.isNotEmpty) {
        images.add(image);
        print('   📸 Using single image field: $image');
      }
    }
    // Fallback for list in different key
    else if (json.containsKey('images') && json['images'] is List) {
      final imageList = json['images'] as List;
      for (var item in imageList) {
        if (item != null && item.toString().isNotEmpty) {
          images.add(item.toString());
        }
      }
    }

    // Determine price - check various possible fields
    double finalPrice = 0.0;

    // Helper function to safely parse double
    // double safeParseDouble(dynamic value) {
    //   if (value == null) return 0.0;
    //   if (value is double) return value;
    //   if (value is int) return value.toDouble();
    //   if (value is String) {
    //     return double.tryParse(value) ?? 0.0;
    //   }
    //   return 0.0;
    // }

    // // Check price fields in order of priority
    // final priceFields = [
    //   'price',
    //   'unitPrice',
    //   'sellingPrice',
    //   'retailPrice',
    //   'universalPrice',
    //   'boxPrice',
    //   'contractPrice',
    // ];

    // for (var field in priceFields) {
    //   if (json.containsKey(field) && json[field] != null) {
    //     finalPrice = safeParseDouble(json[field]);
    //     if (finalPrice > 0) {
    //       print('   💰 Using $field: $finalPrice');
    //       break;
    //     }
    //   }
    // }

    // If no price found in regular fields, check for contract-specific pricing
    if (finalPrice == 0.0) {
      // final double contractPrice = safeParseDouble(json['contractPrice']);
      // final double boxPrice = safeParseDouble(json['boxPrice']);
      // final double universalPrice = safeParseDouble(json['universalPrice']);

      final double contractPrice = (json['contractPrice'] ?? 0).toDouble();
      final double boxPrice = (json['boxPrice'] ?? 0).toDouble();
      final double universalPrice = (json['universalPrice'] ?? 0).toDouble();

      if (soldAsBox) {
        if (contractPrice > 0) {
          finalPrice = contractPrice * quantityPerBox;
          print('💰 USING CONTRACT BOX PRICE: $finalPrice');
        } else if (boxPrice > 0) {
          finalPrice = boxPrice;
          print('💰 USING BOX PRICE: $finalPrice');
        } else if (universalPrice > 0) {
          finalPrice = universalPrice;
          print('💰 USING UNIVERSAL BOX PRICE: $finalPrice');
        }
      } else {
        if (contractPrice > 0) {
          finalPrice = contractPrice;
          print('💰 USING CONTRACT SINGLE PRICE: $finalPrice');
        } else if (universalPrice > 0) {
          finalPrice = universalPrice;
          print('💰 USING UNIVERSAL SINGLE PRICE: $finalPrice');
        }
      }

      if (finalPrice == 0.0) {
        print('⚠️ NO PRICE FOUND FOR PRODUCT');
      }
    }

    // SAFELY parse other numeric fields
    double safeParseProductDimension(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // return ContractProduct(
    //   id: json['_id']?.toString() ?? '',
    //   name:
    //       json['productName']?.toString() ??
    //       json['name']?.toString() ??
    //       'Unnamed Product',
    //   productCode: json['productCode']?.toString() ?? '',
    //   description:
    //       json['productShortDescription']?.toString() ??
    //       json['productLongDescription']?.toString() ??
    //       json['description']?.toString(),
    //   productImages: images,
    //   category: categoryName,
    //   categoryId: categoryId,
    //   price: finalPrice,
    //   brand: (json['brand'] is Map ? json['brand']['name'] : json['brand'])
    //       ?.toString(),
    //   slug: json['slug'].toString(),
    //   unit: json['unit']?.toString() ?? 'pcs',
    //   inStock:
    //       json['inStock'] == true ||
    //       json['inStock'] == 'true' ||
    //       json['stock'] == true,
    //   quantity: json['quantity'] != null
    //       ? (json['quantity'] is int
    //             ? json['quantity']
    //             : json['quantity'] is String
    //             ? int.tryParse(json['quantity'])
    //             : (json['quantity'] as num?)?.toInt())
    //       : json['stockQuantity'],
    //   countryOrigin: json['countryOrigin']?.toString(),
    //   gstPercentage: safeParseDouble(json['gstPercentage'] ?? json['gst']),
    //   productLength: safeParseProductDimension(json['productLength']),
    //   productBreadth: safeParseProductDimension(json['productBreadth']),
    //   productHeight: safeParseProductDimension(json['productHeight']),
    //   productWeight: safeParseProductDimension(json['productWeight']),
    //   soldAsBox: soldAsBox,
    //   quantityPerBox: quantityPerBox,
    // );
    return ContractProduct(
      id: json['_id']?.toString() ?? '',
      name:
          json['productName']?.toString() ??
          json['name']?.toString() ??
          'Unnamed Product',
      productCode: json['productCode']?.toString() ?? '',
      description:
          json['productShortDescription']?.toString() ??
          json['productLongDescription']?.toString() ??
          json['description']?.toString(),
      productImages: images,
      category: categoryName,
      categoryId: categoryId,
      price: finalPrice,
      // brand: json['brand']?['name']?.toString(),
      slug: json['slug'],
      unit: json['unit']?.toString() ?? 'pcs',
      inStock: json['inStock'] ?? true,
      quantity: json['quantity'] ?? json['stockQuantity'],
      countryOrigin: json['countryOrigin']?.toString(),
      gstPercentage: json['gstPercentage']?.toDouble(),
      productLength: json['productLength']?.toDouble(),
      productBreadth: json['productBreadth']?.toDouble(),
      productHeight: json['productHeight']?.toDouble(),
      productWeight: json['productWeight']?.toDouble(),
      soldAsBox: soldAsBox,
      quantityPerBox: quantityPerBox,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'productCode': productCode,
      'description': description,
      'productImages': productImages,
      'category': category,
      'categoryId': categoryId,
      'price': price,
      // 'brand': brand,
      'unit': unit,
      'inStock': inStock,
      'quantity': quantity,
      'countryOrigin': countryOrigin,
      'gstPercentage': gstPercentage,
      'productLength': productLength,
      'productBreadth': productBreadth,
      'productHeight': productHeight,
      'productWeight': productWeight,
    };
  }

  // Helper getter for first image (for backward compatibility)
  String? get firstImage =>
      productImages.isNotEmpty ? productImages.first : null;

  // Helper getter for main image display
  String? get displayImage =>
      productImages.isNotEmpty ? productImages.first : null;

  // Helper getter for thumbnail
  String? get thumbnail =>
      productImages.isNotEmpty ? productImages.first : null;

  // Helper to check if has images
  bool get hasImages => productImages.isNotEmpty;
}
