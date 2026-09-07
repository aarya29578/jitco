import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/A_JS_Home/JS_drawer/C_JS_Quotations/JS_detail_quotation.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_detail_quotation_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_quatation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JsApiService extends GetxService {
  // final Dio _dio = Dio();
  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (status) => true, // ✅ MAGIC LINE
    ),
  );

  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value ||
        authController.authToken.value.isEmpty) {
      return {'Content-Type': 'application/json'};
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authController.authToken.value}',
    };
  }

  Future<Map<String, dynamic>> getEnqueryData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$jitUrl/product/enquire',
        queryParameters: {'page': page, 'limit': limit, 'source': 'Services'},
        options: Options(headers: getAuthHeaders()),
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

  //Drawer - post Enquery
  // Future<Map<String, dynamic>> postEnqueryData(
  //   String? productId,
  //   int? quantity,
  //   String? comments,
  //   // String? jobTitle,
  //   // String? emailId,
  //   // String? phoneNumber,
  //   // String? selectedState,
  //   // String? selectedCity,
  // ) async {
  //   try {
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
  //       '$baseUrl/product/enquire',
  //       options: Options(headers: getAuthHeaders()),
  //       data: jsonEncode({
  //         'company': companyId,
  //         'product': productId,
  //         'progress': [
  //           {'comments': comments, 'statusList': 'From Customer'},
  //         ],
  //         'quantity': quantity ?? 1,
  //         // 'phone': phoneNumber,
  //         // 'email': emailId,
  //         // 'jobTitle': jobTitle,
  //         // 'state': selectedState,
  //         // 'city': selectedCity,
  //       }),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final result = response.data;
  //       print('post query Result**************** $result');
  //       return result;
  //     } else if (response.statusCode == 400 && response.data) {
  //       return response.;
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
      String? companyId;

      try {
        final authController = Get.find<AuthController>();
        companyId = authController.companyId.value;
      } catch (e) {
        print('AuthController not found: $e');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        companyId = prefs.getString('companyId');
      }

      if (companyId == null || companyId.isEmpty) {
        throw Exception('Company ID not found. Please login again.');
      }

      print('========= ENQUIRY REQUEST =========');
      print('Company ID: $companyId');
      print('Product ID: $productId');
      print('Quantity: $quantity');
      print('Comments: $comments');
      print('===================================');

      final response = await _dio.post(
        '$jitUrl/product/enquire',
        queryParameters: {'source': 'Services'},
        options: Options(headers: getAuthHeaders()),

        // ✅ FIX 1 — REMOVE jsonEncode()
        data: {
          'company': companyId,
          'product': productId,
          'source': 'Services', // Explicitly send source in body
          'progress': [
            {'comments': comments, 'statusList': 'From Customer'},
          ],
          'quantity': quantity ?? 1,
        },
      );

      print('========= ENQUIRY RESPONSE =========');
      print('STATUS CODE: ${response.statusCode}');
      print('DATA: ${response.data}');
      print('====================================');

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
    // ✅ FIX 2 — HANDLE DIO ERROR PROPERLY
    on DioException catch (e) {
      print('========= DIO ERROR =========');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('RESPONSE DATA: ${e.response?.data}');
      print('=============================');

      return {
        'status': 'error',
        'message': e.response?.data?['message'] ?? 'Server validation failed',
      };
    } catch (e) {
      print('Unexpected Error: $e');

      return {'status': 'error', 'message': 'Unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> jsPostOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    try {
      final authController = Get.find<AuthController>();

      print('=== POST ORDER API CALL ===');
      print('URL: $jitUrl/orders/source=Services');
      print('Payload: $orderPayload');

      final response = await _dio.post(
        '$jitUrl/orders?source=Services',
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
          'message': response.data?['message'] ?? 'Order placed successfully',
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

  Future<Map<String, dynamic>> jsGetOrder({
    int page = 1,
    int limit = 20,
    String status = 'All',
  }) async {
    try {
      // Check if Dio is initialized
      // if (_dio == null) {
      //   print('Dio is not initialized. Calling init()...');
      //   await init();
      // }
      final AuthController authController = Get.find<AuthController>();
      final response = await _dio.get(
        '$jitUrl/orders?page=$page&limit=$limit&status=$status&source=Services',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print('get getOrder**************** $result');

        //the response structure here --
        return result;
      } else {
        print(" API Error: ${response.statusCode}");
        throw Exception('Failed to get getOrder: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Dio Error in getOrder: $e');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in getOrder: $e');
      throw Exception('Unexpected error from getOrder: $e');
    }
  }

  Future<JsQuatationModel> jsGetQuotation() async {
    try {
      final response = await _dio.get(
        '$jitUrl/product/quotation',
        queryParameters: {"source": "Services"},
        options: Options(headers: getAuthHeaders()),
      );

      if (response.statusCode == 200) {
        return JsQuatationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load quotation');
      }
    } catch (e) {
      throw Exception('jsGetQuotation Error: $e');
    }
  }

  Future<JsDetailQuotationModel> jsGetDetailQuotation(String? quoteId) async {
    try {
      final response = await _dio.get(
        '$jitUrl//product/quotation/$quoteId',
        options: Options(headers: getAuthHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return JsDetailQuotationModel.fromJson(response.data);
      } else {
        throw Exception("Failed load detail quotation");
      }
    } catch (e) {
      throw Exception("JsDetailQuotation Error: $e");
    }
  }
}
