import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_order_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/categorymodel.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/detail_menu_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Models/jm_all_menus_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JMApiService extends GetxService {
  // final Dio _dio = Dio();
  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (status) => true, // ✅ MAGIC LINE
    ),
  );
  // final String jitUrl = "https://jitco.salt-tech.com/api/v1";

  /// Get saved token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<CategoryResponse> fetchCategories({
    int page = 1,
    int limit = 20,
    String search = '',
    String source = 'JitMenu',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'source': source,
      };

      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '$jitUrl/public/product/category',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Parse pagination info
        final pagination = data['pagination'] as Map<String, dynamic>?;
        final totalPages = (pagination?['totalPages'] ?? 1) as int;
        final currentPage = (pagination?['currentPage'] ?? page) as int;

        // Parse categories
        final List<dynamic> categoryData = data['data'] as List<dynamic>? ?? [];
        final categories = categoryData
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return CategoryResponse(
          success: data['success'] as bool? ?? false,
          data: categories,
          currentPage: currentPage,
          totalPages: totalPages,
          hasMore: currentPage < totalPages,
          total: data['total'] as int? ?? 0,
        );
      }

      throw Exception('Failed to fetch categories: ${response.statusCode}');
    } catch (e) {
      print('Category API Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> searchProducts({
    required String query,
    String? warehouseId,
    required String userId,
    required int page,
    required int limit,
    String? categoryId,
  }) async {
    try {
      print("Search API called - Query: '$query', Page: $page, Limit: $limit");

      final response = await _dio.get(
        "$jitUrl/public/product/search",
        queryParameters: {
          "query": query,
          "page": page,
          "limit": limit,
          "source": "JitMenu",
          if (warehouseId != null && warehouseId.isNotEmpty)
            "warehouse": warehouseId,
          "user_id": userId,
          if (categoryId != null && categoryId.isNotEmpty)
            "category": categoryId,
        },
      );

      print("Search API response received");
      print("Response status: ${response.statusCode}");

      // Debug the response structure
      print("Response data type: ${response.data.runtimeType}");

      if (response.data is Map) {
        final Map<String, dynamic> data = response.data;
        print("Response keys: ${data.keys}");

        // Check for products in various possible keys
        if (data.containsKey('products')) {
          print(
            "Found 'products' key with ${data['products'] is List ? data['products'].length : 'non-list'} items",
          );
          return data['products'] ?? [];
        } else if (data.containsKey('results')) {
          print(
            "Found 'results' key with ${data['results'] is List ? data['results'].length : 'non-list'} items",
          );
          return data['results'] ?? [];
        } else if (data.containsKey('data')) {
          print(
            "Found 'data' key with ${data['data'] is List ? data['data'].length : 'non-list'} items",
          );
          return data['data'] ?? [];
        } else {
          print("No expected key found in response. Returning empty list.");
          // Try to find any list in the response
          for (final key in data.keys) {
            if (data[key] is List) {
              print("Found list in key '$key' with ${data[key].length} items");
              return data[key];
            }
          }
          return [];
        }
      } else if (response.data is List) {
        print("Response is directly a list with ${response.data.length} items");
        return response.data;
      } else {
        print("Unexpected response type: ${response.data.runtimeType}");
        return [];
      }
    } catch (e) {
      print("Search API Error: $e");
      return [];
    }
  }

  // Keep existing method for fetching products
  Future<List<dynamic>> fetchProducts({
    String? warehouseId,
    required int page,
    required int limit,
    required String userId,
    String? categorySlug,
  }) async {
    print("Fetching products with categorySlug: $categorySlug");
    final response = await _dio.get(
      "$jitUrl/public/product",
      queryParameters: {
        "page": page,
        "limit": limit,
        "source": "JitMenu",
        if (warehouseId != null) "warehouse": warehouseId,
        "user_id": userId,
        if (categorySlug != null && categorySlug.isNotEmpty)
          "category": categorySlug,
        "slug": true,
      },
    );
    return response.data["products"] ?? [];
  }

  Future<Map<String, dynamic>> submitMenu(
    Map<String, dynamic> submitMenuPayload,
  ) async {
    try {
      // if (_dio == null) {
      //   await init();
      // }

      final authController = Get.find<AuthController>();

      print('=== POST ORDER API CALL ===');
      print('URL: $jitUrl/orders');
      print('Payload: $submitMenuPayload');

      final response = await _dio.post(
        '$jitUrl/menu?source=JitMenu',
        data: submitMenuPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );

      print('=== POST ORDER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Menu is created successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to place order',
          'data': response.data,
        };
      }
    } on DioException catch (e) {
      print('=== DIO EXCEPTION IN POST ORDER ===');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        Get.find<AuthController>().logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Order failed: ${e.message}',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'data': null,
      };
    }
  }

  Future<JmAllMenusModel> getAllMenu({int? page = 1, int? limit = 10}) async {
    final authController = Get.find<AuthController>();
    try {
      final response = await _dio.get(
        "$jitUrl/menu",
        queryParameters: {
          "page": page,
          "limit": limit,
          "status": "All",
          "source": "JitMenu",
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      if (response.statusCode == 200) {
        print("All Menues1: ${response}");
        print("All Menues2: ${response.data}");
        return JmAllMenusModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load all menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching all menu: $e');
    }
  }

  Future<DetailMenuModel> getDetailMenu({String? menuId}) async {
    final authController = Get.find<AuthController>();
    try {
      final response = await _dio.get(
        "$jitUrl/menu/$menuId",
        queryParameters: {"source": "JitMenu"},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      if (response.statusCode == 200) {
        print("All Menues1: ${response}");
        print("All Menues2: ${response.data}");
        return DetailMenuModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load detail menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching detail menu: $e');
    }
  }

  Future<OrdersResponse> getJmOrders({
    int? page = 1,
    int? limit = 10,
    String status = 'All',
  }) async {
    final authController = Get.find<AuthController>();
    try {
      final response = await _dio.get(
        "$jitUrl/orders",
        queryParameters: {
          "page": page,
          "limit": limit,
          "source": "JitMenu",
          "status": status,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      if (response.statusCode == 200) {
        print("All Menues1: ${response}");
        print("All Menues2: ${response.data}");
        return OrdersResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load detail menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching detail menu: $e');
    }
  }

  Future<Map<String, dynamic>> postMenuOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    try {
      // if (_dio == null) {
      //   await init();
      // }

      final authController = Get.find<AuthController>();

      print('=== POST ORDER API CALL ===');
      print('URL: $jitUrl/orders');
      print('Payload: $orderPayload');

      final response = await _dio.post(
        '$jitUrl/orders?source=JitMenu',
        data: orderPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );

      print('=== POST ORDER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data?['message'] ?? 'Order created successfully!',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to place order',
          'data': response.data,
        };
      }
    } on DioException catch (e) {
      print('=== DIO EXCEPTION IN POST ORDER ===');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        Get.find<AuthController>().logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Order failed: ${e.message}',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> getEnqueryMenuData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final response = await _dio.get(
        '$jitUrl/product/enquire',
        queryParameters: {'page': page, 'limit': limit, 'source': 'JitMenu'},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print('get query Result**************** $result');
        return result;
      } else {
        print(" API Error: ${response.statusCode}");
        throw Exception('Failed to get enquery: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getEnqueryData: $e');
      throw Exception('unexpected error: $e');
    }
  }

  // Future<Map<String, dynamic>> postEnqueryData(
  //   String? productId,
  //   int? quantity,
  //   String? comments,
  // ) async {
  //   try {
  //     final authController = Get.find<AuthController>();
  //     // Get company ID from AuthController if available
  //     String? companyId;
  //     try {
  //       final authController = Get.find<AuthController>();
  //       companyId = authController.companyId.value;
  //     } catch (e) {
  //       print('AuthController not found: $e');
  //       // Try to get company ID from storage as fallback
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       companyId = prefs.getString('companyId');
  //     }

  //     if (companyId == null || companyId.isEmpty) {
  //       throw Exception('Company ID not found. Please login again.');
  //     }

  //     final response = await _dio.post(
  //       '$baseUrl/product/enquire?source=JitMenu',
  //       options: Options(
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer ${authController.authToken.value}',
  //         },
  //       ),
  //       data: jsonEncode({
  //         'company': companyId,
  //         'product': productId,
  //         'quantity': quantity ?? 1,
  //         'progress': [
  //           {'comments': comments, 'statusList': 'From Customer'},
  //         ],
  //         'status': '',
  //       }),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final result = response.data;
  //       print('post query Result**************** $result');
  //       return result;
  //     } else {
  //       print(" API Error: ${response.statusCode}");
  //       throw Exception('Failed to post enquery: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in postEnqueryData: $e');
  //     throw Exception('unexpected error: $e');
  //   }
  // }
  Future<Map<String, dynamic>> postEnqueryData(
    String? productId,
    int? quantity,
    String? comments,
  ) async {
    try {
      final authController = Get.find<AuthController>();

      String? companyId;
      try {
        companyId = authController.companyId.value;
      } catch (e) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        companyId = prefs.getString('companyId');
      }

      if (companyId == null || companyId.isEmpty) {
        return {
          'status': 'error',
          'message': 'Company ID not found. Please login again.',
        };
      }

      print('========= JM ENQUIRY REQUEST =========');
      print('Company: $companyId');
      print('Product: $productId');
      print('Quantity: $quantity');
      print('Comments: $comments');
      print('======================================');

      final response = await _dio.post(
        '$jitUrl/product/enquire',
        queryParameters: {'source': 'JitMenu'},

        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),

        // ✅ FIX 1 — REMOVE jsonEncode()
        data: {
          'company': companyId,
          'product': productId,
          'quantity': quantity ?? 1,
          'source': 'JitMenu',
          "device_source": "mobile"
           // Explicitly send source in body
          'progress': [
            {'comments': comments, 'statusList': 'From Customer'},
          ],
          'status': '',
        },
      );

      print('========= JM ENQUIRY RESPONSE =========');
      print('STATUS CODE: ${response.statusCode}');
      print('DATA: ${response.data}');
      print('=======================================');

      // ✅ NORMALIZE STATUS FOR UI CONSISTENCY
      Map<String, dynamic> data;
      try {
        if (response.data is String) {
          data = jsonDecode(response.data);
        } else if (response.data is Map) {
          data = Map<String, dynamic>.from(response.data);
        } else {
          data = {};
        }
      } catch (e) {
        data = {};
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          data['success'] == true) {
        data['status'] = 'success';
      }
      return data;
    }
    // ✅ FIX 2 — HANDLE BACKEND ERROR CLEANLY
    on DioException catch (e) {
      print('========= JM DIO ERROR =========');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('================================');

      return {
        'status': 'error',
        'message': e.response?.data?['message'] ?? 'Server validation failed',
      };
    } catch (e) {
      print('Unexpected Error: $e');

      return {'status': 'error', 'message': 'Unexpected error occurred'};
    }
  }
}
