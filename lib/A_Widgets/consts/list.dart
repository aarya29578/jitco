final List<String> cartTitle = ['Subtotal:', 'GST:', 'Total:'];
final List<String> cartsubtitle = ['₹780', '₹8.70(5%)', '₹788.70'];

Map<String, dynamic>? productData;
final List<String> allProductData =
    [
          productData?['usp'],
          productData?['productLongDescription'],
          productData?['dietary'],
          productData?['vegNoneveg'],
          productData?['ingredients'],
          productData?['instructions'],
          productData?['usage'],
        ]
        .whereType<String>() // removes nulls
        .where((e) => e.trim().isNotEmpty)
        .toList();
final List<String> descripProductData =
    [
          productData?['usp'],
          productData?['productLongDescription'],
          productData?['dietary'],
          productData?['vegNoneveg'],
          productData?['ingredients'],
          productData?['instructions'],
        ]
        .whereType<String>() // removes nulls
        .where((e) => e.trim().isNotEmpty)
        .toList();
final List<String> usageProductData = [productData?['usage']]
    .whereType<String>() // removes nulls
    .where((e) => e.trim().isNotEmpty)
    .toList();
