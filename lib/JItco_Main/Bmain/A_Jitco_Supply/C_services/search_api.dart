import 'package:dio/dio.dart';
import '../../Constants/constants.dart';

class SearchApi {
  final Dio _dio = Dio();
  static const String baseUrl = jitUrl;
  // final String publicBaseUrl = "https://api.jitco.in/api/v1";
  // final AuthController _authController = Get.find<AuthController>();

  /// Search products with support for both category and brand filtering
  Future<Map<String, dynamic>> searchProducts(
    String query,
    dynamic filterId, {
    String filterType = 'category',
    String? warehouseId,
    String? userId,
  }) async {
    // final userIds = _authController.userId.value;
    final encodedQuery = Uri.encodeQueryComponent(query.trim());
    const int page = 1;
    const int limit = 20; // Increased limit for better search results

    try {
      // Build base URL - using the search endpoint
      String url = "$baseUrl/public/product/search?";

      if (filterId == null) {
        url +=
            "user_id=$userId&query=$encodedQuery&page=$page&limit=$limit&source=Jitco";
      }

      // Add filter if provided
      if (filterId != null) {
        final idStr = filterId.toString().trim();
        if (idStr.isNotEmpty && idStr != 'null') {
          // Use the specified filter type (category or brand)
          url +=
              "query=$encodedQuery&page=$page&limit=$limit&$filterType=$idStr&user_id=$userId";

          // If it's a brand filter, add slug=true parameter if needed
          //https://jitco.salt-tech.com/api/v1/public/product/search?query=jhvdhjvw&page=1&limit=10

          if (filterType == 'brand') {
            url +=
                "query=$encodedQuery&page=$page&limit=$limit&slug=true&user_id=$userId";
          }
        }
      }
      // if (userId != null && userId.isNotEmpty) {
      //   url += "&user_id=$userId}";
      // }
      if (warehouseId != null && warehouseId.isNotEmpty) {
        url += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }

      print("SEARCH API CALL:");
      print("Query: '$query'");
      print("Filter ID: $filterId");
      print("Filter Type: $filterType");
      print("URL: $url");
      print(
        "User_id ************************>>>>>>>>>>>>>>>>>>>>>>>>>>>$userId",
      );

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      print('SEARCH RESPONSE STATUS: ${response.statusCode}');
      print('SEARCH RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200) {
        final body = response.data;

        // Handle different response structures
        List<dynamic> products = [];
        int totalProducts = 0;
        int totalPages = 1;

        if (body is Map<String, dynamic>) {
          // Check for different possible response formats
          if (body.containsKey('results')) {
            products = body['results'] ?? [];
          } else if (body.containsKey('products')) {
            products = body['products'] ?? [];
          } else if (body.containsKey('data')) {
            // If there's a data wrapper
            final data = body['data'];
            if (data is Map && data.containsKey('results')) {
              products = data['results'] ?? [];
            } else if (data is Map && data.containsKey('products')) {
              products = data['products'] ?? [];
            } else if (data is List) {
              products = data;
            }
          }

          // Get total counts
          totalProducts =
              body['total'] ?? body['totalProducts'] ?? products.length;
          totalPages = body['totalPages'] ?? 1;
        }

        print("SEARCH RESULTS:");
        print("Products found: ${products.length}");
        print("Total products: $totalProducts");
        print("Total pages: $totalPages");

        return {
          "products": products,
          "totalProducts": totalProducts,
          "totalPages": totalPages,
          "page": page,
        };
      } else {
        print("SEARCH API ERROR: ${response.statusCode}");
        print("Response body: ${response.data}");
        return {
          "products": [],
          "totalProducts": 0,
          "totalPages": 1,
          "page": page,
        };
      }
    } on DioException catch (e) {
      print("NETWORK ERROR: ${e.message}");
      print("Error type: ${e.type}");
      if (e.response != null) {
        print("Error response: ${e.response!.data}");
        print(" Error status: ${e.response!.statusCode}");
      }
      return {"products": [], "totalProducts": 0, "totalPages": 1, "page": 1};
    } catch (e, st) {
      print("UNEXPECTED SEARCH ERROR: $e");
      print("Stack trace: $st");
      return {"products": [], "totalProducts": 0, "totalPages": 1, "page": 1};
    }
  }

  /// Alternative method: Search using the main product endpoint with client-side filtering
  Future<Map<String, dynamic>> searchWithClientFiltering(
    String query,
    dynamic filterId, {
    String filterType = 'category',
  }) async {
    const int page = 1;
    const int limit = 50; // Higher limit for better client-side filtering

    try {
      String url;

      // Build URL based on filter type
      if (filterId != null && filterId.toString().trim().isNotEmpty) {
        if (filterType == 'brand') {
          url =
              "$baseUrl/public/product?brand=$filterId&slug=true&page=$page&limit=$limit";
        } else {
          url =
              "$baseUrl/public/product?category=$filterId&slug=true&page=$page&limit=$limit";
        }
      } else {
        url = "$baseUrl/public/product?page=$page&limit=$limit";
      }

      print("CLIENT-SIDE SEARCH URL: $url");

      final response = await _dio.get(
        url,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        List<dynamic> allProducts = body['products'] ?? [];

        // Client-side filtering by product name
        final filteredProducts = allProducts.where((product) {
          final productName =
              product['productName']?.toString().toLowerCase() ?? '';
          return productName.contains(query.toLowerCase());
        }).toList();

        print("CLIENT-SIDE SEARCH RESULTS:");
        print("Original products: ${allProducts.length}");
        print("Filtered products: ${filteredProducts.length}");
        print("Search query: '$query'");

        return {
          "products": filteredProducts,
          "totalProducts": filteredProducts.length,
          "totalPages": 1,
          "page": page,
        };
      } else {
        return {
          "products": [],
          "totalProducts": 0,
          "totalPages": 1,
          "page": page,
        };
      }
    } catch (e) {
      print("CLIENT-SIDE SEARCH ERROR: $e");
      return {"products": [], "totalProducts": 0, "totalPages": 1, "page": 1};
    }
  }
}
