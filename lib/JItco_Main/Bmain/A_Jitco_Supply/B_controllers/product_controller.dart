// //************************************NEW*********************** */
// import 'package:get/get.dart';
// import 'package:jitco_app/services/api_service.dart';
// import 'package:jitco_app/services/search_api.dart';

// class ProductSearchController extends GetxController {
//   List<dynamic> searchedProducts = [];
//   bool isLoading = false;

//   /// Search products (works for All products when id == null).
//   Future<void> searchProducts(String query, String? id) async {
//     final q = (query ?? '').trim();

//     // Empty query → clear results
//     if (q.isEmpty) {
//       searchedProducts = [];
//       update();
//       return;
//     }

//     isLoading = true;
//     update();

//     // Use SearchApi for both all-products and filtered searches
//     final data = await SearchApi().searchProducts(q, id);

//     // Guarantee non-null list
//     searchedProducts = data["products"] ?? [];

//     isLoading = false;
//     update();
//   }

//   /// Clear all search results
//   void clearSearch() {
//     searchedProducts = [];
//     update();
//   }
// }

//**********************************NEW********************** */
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/search_api.dart';

class ProductSearchController extends GetxController {
  List<dynamic> searchedProducts = [];
  bool isLoading = false;

  /// Search products with proper category/brand filtering
  Future<void> searchProducts(
    String query, {
    String? categoryId,
    String? brandId,
    String? warehouseId,
    String? userId,
  }) async {
    final q = (query ?? '').trim();

    // Empty query → clear results
    if (q.isEmpty) {
      searchedProducts = [];
      update();
      return;
    }

    isLoading = true;
    update();

    try {
      // Determine what to search within
      dynamic searchId;
      String filterType = 'category';

      if (brandId != null && brandId.isNotEmpty) {
        searchId = brandId;
        filterType = 'brand';
      } else if (categoryId != null && categoryId.isNotEmpty) {
        searchId = categoryId;
        filterType = 'category';
      } else {
        searchId = null;
      }

      print("🎯 STARTING SEARCH:");
      print("📝 Query: '$q'");
      print("🎯 Filter ID: $searchId");
      print("📊 Filter Type: $filterType");

      // Try the main search API first
      final data = await SearchApi().searchProducts(
        q,
        searchId,
        filterType: filterType,
        warehouseId: warehouseId,
        userId: userId,
      );

      // If no results from search API, try client-side filtering as fallback
      if (data["products"]?.isEmpty == true && q.isNotEmpty) {
        print("🔄 No results from search API, trying client-side filtering...");
        final clientSideData = await SearchApi().searchWithClientFiltering(
          q,
          searchId,
          filterType: filterType,
        );
        searchedProducts = clientSideData["products"] ?? [];
      } else {
        searchedProducts = data["products"] ?? [];
      }

      print("✅ SEARCH COMPLETED:");
      print("📊 Results found: ${searchedProducts.length}");
      print("🔍 Search query: '$q'");

      if (searchedProducts.isEmpty) {
        print("❌ No products found for query: '$q' with filter: $searchId");
      } else {
        // Print first few product names for verification
        for (
          int i = 0;
          i < (searchedProducts.length > 3 ? 3 : searchedProducts.length);
          i++
        ) {
          final product = searchedProducts[i];
          final name = product['productName'] ?? 'Unnamed Product';
          print("📦 Product ${i + 1}: $name");
        }
      }
    } catch (e) {
      print("💥 SEARCH ERROR: $e");
      searchedProducts = [];
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Clear all search results
  void clearSearch() {
    searchedProducts = [];
    update();
  }
}
