// *****************************************NEW***********************************************//
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/auth_models.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/contract_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/state_city_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/PostModel.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';
import 'package:jitco_app/JItco_Main/api_exceptions.dart';
import 'package:jitco_app/main_search/main_search_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class ApiServices extends GetxService {
  // final Dio _dio = Dio();
  // static const String jitUrl = 'https://jitco.salt-tech.com/api/v1';
  // // static const String publicBaseUrl = 'https://api.jitco.in/api/v1';

  // Dio instance
  // late Dio _dio;
  // Dio? _dio;
  Dio _dio = Dio(
    BaseOptions(
      validateStatus: (status) => true, // ✅ MAGIC LINE
    ),
  );

  // Initialize service
  Future<ApiServices> init() async {
    // Initialize Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: jitUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('API Request: ${options.method} ${options.path}');
          if (options.data != null) {
            print('Request Data: ${options.data}');
          }
          if (options.headers['Authorization'] != null) {
            print('Auth Header: ${options.headers['Authorization']}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'API Response: ${response.statusCode} ${response.statusMessage}',
          );
          return handler.next(response);
        },

        onError: (error, handler) {
          print('API Error: ${error.type} - ${error.message}');
          if (error.response != null) {
            print('Error Response: ${error.response?.statusCode}');
            print('Error Data: ${error.response?.data}');
          }
          return handler.next(error);
        },

        ////FOR SERVER AND NETWORK ISSUE FINDER OR SCREEN
        // onError: (error, handler) {
        //   print('API Error: ${error.type} - ${error.message}');

        //   if (error.error is SocketException ||
        //       error.type == DioExceptionType.connectionTimeout ||
        //       error.type == DioExceptionType.receiveTimeout) {
        //     handler.reject(
        //       DioException(
        //         requestOptions: error.requestOptions,
        //         error: NetworkException(),
        //       ),
        //     );
        //     return;
        //   }

        //   if (error.response != null) {
        //     final status = error.response?.statusCode ?? 0;

        //     if (status >= 500) {
        //       handler.reject(
        //         DioException(
        //           requestOptions: error.requestOptions,
        //           error: ServerException(),
        //         ),
        //       );
        //       return;
        //     }
        //   }

        //   handler.next(error);
        // },
      ),
    );
    return this;
  }

  // Future<void> ping() async {
  //   await _dio!.get("$baseUrl"); // or any small endpoint
  // }

  /// Send OTP to phone number
  Future<OtpResponse> sendOtp(String phoneNumber) async {
    try {
      print('Sending OTP to: $phoneNumber');

      final response = await _dio.post(
        '/customer/auth/send-otp',
        data: jsonEncode(LoginRequest(phoneNumber: phoneNumber).toJson()),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
        return OtpResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('OTP send error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete Customer Account
  Future<bool> deleteAccount(String customerId) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value || authController.authToken.value.isEmpty) {
        return false;
      }
      
      final url = '$jitUrl/customer/$customerId';
      print('DEBUG: Deleting account with URL: $url');
      
      final response = await _dio.delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );

      print('DEBUG: Delete API Response Status: ${response.statusCode}');
      print('DEBUG: Delete API Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Account deleted successfully');
        return true;
      } else {
        print('Failed to delete account: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  /// Verify OTP
  // Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
  //   try {
  //     print('Verifying OTP for: $phoneNumber');
  //     final requestBody = {'phone_number': phoneNumber, 'otp': otp};
  //     final response = await _dio.post(
  //       '/customer/auth/verify-otp',
  //       data: jsonEncode(requestBody),
  //       options: Options(headers: {'Content-Type': 'application/json'}),
  //     );
  //     if (response.statusCode == 200) {
  //       final authResponse = AuthResponse.fromJson(response.data);
  //       if (authResponse.success && authResponse.token != null) {
  //         print('OTP verified, saving auth data');
  //         // Get AuthController and save auth data
  //         final authController = Get.find<AuthController>();
  //         await authController.saveTokenToStorage(authResponse.token!);
  //         authController.authToken.value = authResponse.token!;
  //         authController.isLoggedIn.value = true;
  //       }
  //       return authResponse;
  //     } else {
  //       throw Exception(
  //         'Failed to verify OTP: ${response.statusCode} - ${response.data}',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     print('OTP verification error: ${e.message}');
  //     throw Exception('Network error: ${e.message}');
  //   }
  // }
  Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      print('Verifying OTP for: $phoneNumber');
      final requestBody = {'phone_number': phoneNumber, 'otp': otp};

      final response = await _dio.post(
        '/customer/auth/verify-otp',
        data: jsonEncode(requestBody),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        // if (authResponse.success && authResponse.token != null) {
        //   print('OTP verified, saving auth data');
        //   // Extract company ID from response
        //   String? companyId;
        //   if (authResponse.data != null) {
        //     // Navigate through the nested structure
        //     final customerData = authResponse.data?['customer'];
        //     if (customerData != null && customerData['company'] != null) {
        //       companyId = customerData['company']['_id'];
        //       print('Company ID extracted: $companyId');
        //     }
        //   }
        //   // Get AuthController and save auth data
        //   final authController = Get.find<AuthController>();
        //   await authController.saveAuthData(
        //     token: authResponse.token!,
        //     companyId: companyId, // Save company ID
        //   );
        //   authController.authToken.value = authResponse.token!;
        //   authController.companyId.value =
        //       companyId ?? ''; // Store in controller
        //   authController.isLoggedIn.value = true;
        // }

        if (authResponse.success && authResponse.token != null) {
          final authController = Get.find<AuthController>();

          bool contract = false;
          String? userId;
          String? contractExpireDate;
          String? companyId;
          int city = 0;
          int state = 0;

          final customer = authResponse.data?['customer'];
          final userIds = customer?['_id'];
          final company = customer?['company'];
          final cityWareHouse = customer?['outlet'];

          if (customer != null) {
            userId = userIds;
            print('????????????????>>>>>>>>>>>>>$userIds');
          }
          if (company != null) {
            companyId = company['_id'];
            contract = company['contract'] ?? false;
            contractExpireDate = company['contract_expire_date'];
          }

          if (cityWareHouse != null &&
              cityWareHouse?['city'] != null &&
              cityWareHouse?['state'] != null) {
            city = cityWareHouse?['city'] as int;
            state = cityWareHouse?['state'] as int;
          }

          await authController.saveAuthData(
            token: authResponse.token!,
            companyId: companyId,
            hasContract: contract,
            contractExpireDate: contractExpireDate,
            city: city,
          );

          authController.authToken.value = authResponse.token!;
          authController.userId.value = userId.toString();
          authController.companyId.value = companyId ?? '';
          authController.hasContract.value = contract;
          authController.contractExpireDate.value = contractExpireDate ?? '';
          authController.city.value = city;
          authController.state.value = state;
          authController.isLoggedIn.value = true;
        }

        return authResponse;
      } else {
        throw Exception(
          'Failed to verify OTP: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      print('OTP verification error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> getWarehouseCityName() async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final stateId = authController.state.value; //USE STATE ID

      if (stateId == 0) {
        throw Exception('State ID not available');
      }

      final apiUrl = "$jitUrl/public/city/$stateId";
      final response = await _dio!.get(apiUrl);

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to get WarehouseCityName');
      }
    } catch (e) {
      print('Error getWarehouseCityName: $e');
      rethrow;
    }
  }

  Future<void> fetchAndSaveCityName() async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final int cityId = authController.city.value; // already saved earlier

      if (cityId == 0) {
        print('City ID not found');
        return;
      }

      final apiService = Get.find<ApiServices>();
      final response = await apiService.getWarehouseCityName();

      final List cities = response['data']?['cities'] ?? [];

      final matchedCity = cities.firstWhere(
        (c) => c['_id'] == cityId,
        orElse: () => null,
      );

      if (matchedCity != null) {
        authController.cityName.value = matchedCity['name'] ?? '';

        // (optional) persist it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('city_name', authController.cityName.value);

        print('City name saved: ${authController.cityName.value}');
      } else {
        print('City not found for cityId: $cityId');
      }
    } catch (e) {
      print('Error fetching city name: $e');
    }
  }

  /// Add this method to ApiService class, after your existing methods
  Future<String?> refreshToken() async {
    try {
      print('Attempting to refresh token...');

      // Get the refresh token from storage
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token found');
        return null;
      }

      print('Refresh token found, calling refresh endpoint');

      final response = await _dio!.post(
        '$jitUrl/customer/auth/refresh-token', // Adjust endpoint if needed
        data: jsonEncode({'refresh_token': refreshToken}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        print('Token refreshed successfully');

        // Update AuthController
        final authController = Get.find<AuthController>();
        authController.authToken.value = newAccessToken;

        // Save new tokens to storage
        await prefs.setString('auth_token', newAccessToken);
        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
        }

        return newAccessToken;
      }

      print('Token refresh failed with status: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('Token refresh error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error refreshing token: $e');
      return null;
    }
  }

  /// Get headers with auth token from AuthController
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

  Future<Map<String, dynamic>> getUserContact() async {
    try {
      final authController = Get.find<AuthController>();
      // Check if user is logged in
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        print('getUserContact: User not logged in');
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      // Get company ID
      final companyId = authController.companyId.value;
      if (companyId.isEmpty) {
        print('getUserContact: Company ID not available');
        return {
          'success': false,
          'message': 'Company data not available',
          'data': null,
        };
      }
      print('Fetching user contacts for company: $companyId');
      final response = await _dio!.get(
        '$jitUrl/customer/contacts',
        queryParameters: {
          'company': companyId, // ADD THIS
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      print('Contacts fetched successfully - Status: ${response.statusCode}');
      // DEBUG: Print the raw response structure
      print('Raw response data type: ${response.data.runtimeType}');
      print('Raw response data: ${response.data}');
      // Handle different response structures
      dynamic responseData = response.data;

      // If response is a Map, extract data appropriately
      if (responseData is Map) {
        print('Response is a Map');
        print('Keys in response: ${responseData.keys.join(', ')}');
        // Look for 'data' key
        if (responseData.containsKey('data')) {
          print('Found "data" key in response');
          responseData = responseData['data'];
        } else if (responseData.containsKey('contacts')) {
          print('Found "contacts" key in response');
          responseData = responseData['contacts'];
        } else {
          // If no specific key, try to find any list
          for (var key in responseData.keys) {
            if (responseData[key] is List) {
              print('Found list in key "$key"');
              responseData = responseData[key];
              break;
            }
          }
        }
      }
      // ADD THIS VARIABLE DECLARATION
      // Ensure we return a List (even if empty)
      final List<dynamic> contactList = responseData is List
          ? responseData
          : [];

      print('Final contact list length: ${contactList.length}');
      if (contactList.isNotEmpty) {
        print('First contact item structure:');
        if (contactList[0] is Map) {
          print('Keys: ${(contactList[0] as Map).keys.join(', ')}');
        }
      }
      return {
        'success': response.statusCode == 200,
        'message': 'Contacts fetched successfully',
        'data': contactList, // Now this variable is defined
      };
    } on DioException catch (e) {
      // Handle unauthorized (401) error
      if (e.response?.statusCode == 401) {
        print('Session expired, logging out');
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      print('Error fetching contacts: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to fetch contacts',
        'data': null,
      };
    } catch (e) {
      print('Network error fetching contacts: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> postUserContact(
    Map<String, dynamic> contactData,
  ) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        print('postUserContact: User not logged in');
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      // Get company ID
      final companyId = authController.companyId.value;
      if (companyId.isEmpty) {
        print('postUserContact: Company ID not available');
        return {
          'success': false,
          'message': 'Company data not available',
          'data': null,
        };
      }
      // Add company ID to contact data
      final enrichedContactData = {
        ...contactData,
        'company': companyId, // ADD THIS
      };
      print('Creating new contact for company: $companyId');
      print('Contact data: $enrichedContactData');

      final response = await _dio!.post(
        '$jitUrl/customer/contacts',
        data: enrichedContactData, // Use enriched data
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      print('Contact created successfully');
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': response.data?['message'] ?? 'Contact created successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Session expired, logging out');
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      print('Error creating contact: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to create contact',
        'data': null,
      };
    } catch (e) {
      print('Network error creating contact: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> updateUserContact(
    Map<String, dynamic> contactData, {
    required String contactId, // Required contact ID parameter
  }) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      // Use contact ID directly in the URL
      final response = await _dio!.patch(
        '$jitUrl/customer/contacts/$contactId', // Just use contact ID
        data: contactData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      return {
        'success': response.statusCode == 200,
        'message': response.data?['message'] ?? 'Contact updated successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      // Print debug info
      print('Dio Error updating contact:');
      print('   URL: $jitUrl/contacts/$contactId');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('   Headers: ${e.response?.headers}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to update contact',
        'data': null,
      };
    } catch (e) {
      print('General Error updating contact: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  /// Delete a user contact
  Future<Map<String, dynamic>> deleteUserContact(String contactId) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      final response = await _dio!.delete(
        '$jitUrl/customer/contacts/$contactId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      return {
        'success': response.statusCode == 200,
        'message': response.data?['message'] ?? 'Contact deleted successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to delete contact',
        'data': null,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  Future<Map<String, dynamic>> getUserOutlet() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        print('getUserOutlet: User not logged in');
        return {'success': false, 'message': 'User not logged in', 'data': []};
      }
      // Get company ID
      final companyId = authController.companyId.value;
      if (companyId.isEmpty) {
        print('getUserOutlet: Company ID not available');
        return {
          'success': false,
          'message': 'Company data not available',
          'data': [],
        };
      }
      print('Fetching user outlets for company: $companyId');
      final response = await _dio!.get(
        '$jitUrl/customer/outlet',
        queryParameters: {
          'company': companyId, // ADD THIS
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      print('Outlets fetched successfully');
      print('Raw response:');
      print(response.data);
      print('Response type: ${response.data.runtimeType}');
      // Handle the response - keep it simple
      if (response.statusCode == 200) {
        // Try to extract data from the response
        dynamic responseData = response.data;
        List<dynamic> outletData = [];
        if (responseData is Map) {
          // Convert to Map<String, dynamic>
          final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
            responseData,
          );
          // Check different possible formats
          if (responseMap.containsKey('data') && responseMap['data'] is List) {
            outletData = responseMap['data'] as List;
          } else if (responseMap.containsKey('outlets') &&
              responseMap['outlets'] is List) {
            outletData = responseMap['outlets'] as List;
          } else if (responseMap.isNotEmpty &&
              responseMap.values.first is List) {
            // If the first value is a list, use it
            for (var value in responseMap.values) {
              if (value is List) {
                outletData = value;
                break;
              }
            }
          }
          return {
            'success': true,
            'message':
                responseMap['message']?.toString() ??
                'Outlets fetched successfully',
            'data': outletData,
          };
        } else if (responseData is List) {
          // Direct list response
          return {
            'success': true,
            'message': 'Outlets fetched successfully',
            'data': responseData,
          };
        }
      }
      return {
        'success': false,
        'message': 'Invalid response format',
        'data': [],
      };
    } on DioException catch (e) {
      print('DioException fetching outlets: ${e.message}');
      if (e.response?.statusCode == 401) {
        print('Session expired, logging out');
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': [],
        };
      }
      // Extract error message
      String errorMessage = 'Failed to fetch outlets';
      if (e.response?.data != null) {
        try {
          if (e.response!.data is Map<String, dynamic>) {
            errorMessage =
                (e.response!.data as Map<String, dynamic>)['message']
                    ?.toString() ??
                errorMessage;
          } else if (e.response!.data is Map) {
            final errorData = Map<String, dynamic>.from(
              e.response!.data as Map,
            );
            errorMessage = errorData['message']?.toString() ?? errorMessage;
          }
        } catch (_) {
          errorMessage = e.message ?? errorMessage;
        }
      }

      return {'success': false, 'message': errorMessage, 'data': []};
    } catch (e) {
      print('Network error fetching outlets: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> postUserOutlet(
    Map<String, dynamic> outletData,
  ) async {
    try {
      final authController = Get.find<AuthController>();
      // Check authentication first
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        print('=== AUTHENTICATION CHECK FAILED ===');
        print('Is logged in: ${authController.isLoggedIn.value}');
        print('Auth token empty: ${authController.authToken.value.isEmpty}');
        return {
          'success': false,
          'message': 'User not logged in. Please login first.',
          'data': null,
        };
      }
      // Get company ID
      final companyId = authController.companyId.value;
      if (companyId.isEmpty) {
        print('postUserOutlet: Company ID not available');
        return {
          'success': false,
          'message': 'Company data not available',
          'data': null,
        };
      }
      // Add company ID to outlet data
      final enrichedOutletData = {
        ...outletData,
        'company': companyId, // ADD THIS
      };
      print('=== POST USER OUTLET API CALL ===');
      print('Company ID: $companyId');
      print('URL: $jitUrl/customer/outlet');
      print('Enriched Data: $enrichedOutletData');
      final response = await _dio!.post(
        '$jitUrl/customer/outlet',
        data: enrichedOutletData, // Use enriched data
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      print('=== POST OUTLET RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': response.data?['message'] ?? 'Outlet created successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      print('=== DIO EXCEPTION IN POST OUTLET ===');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        print('Session expired, logging out');
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      return {
        'success': false,
        'message':
            e.response?.data?['message'] ??
            'Failed to create outlet: ${e.message}',
        'data': null,
      };
    } catch (e) {
      print('=== GENERAL EXCEPTION IN POST OUTLET ===');
      print('Error: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  /// In ApiService - fix the updateUserOutlet method
  Future<Map<String, dynamic>> updateUserOutlet(
    String? outletId, // Add outletId parameter
    Map<String, dynamic> outletData,
  ) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      // Use outletId in the URL instead of customerId
      final response = await _dio!.patch(
        '$jitUrl/customer/outlet/$outletId', // Changed to outletId
        data: outletData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      return {
        'success': response.statusCode == 200,
        'message': response.data?['message'] ?? 'Outlet updated successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to update outlet',
        'data': null,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  /// Delete an outlet
  Future<Map<String, dynamic>> deleteUserOutlet(String outletId) async {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }
      final response = await _dio!.delete(
        '$jitUrl/customer/outlet/$outletId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authController.authToken.value}',
          },
        ),
      );
      return {
        'success': response.statusCode == 200,
        'message': response.data?['message'] ?? 'Outlet deleted successfully',
        'data': response.data,
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to delete outlet',
        'data': null,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  // ==================== STATE AND CITY API ====================
  // GET COUNTRIES (STATES)
  Future<List<StateModel>> fetchStates() async {
    try {
      print('Fetching countries/states...');
      final response = await _dio!.get(
        '/public/state',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data['data']['countries'];
      print('Fetched ${data.length} countries/states');
      return List<StateModel>.from(data.map((e) => StateModel.fromJson(e)));
    } catch (e) {
      print('Error fetching countries: $e');
      rethrow;
    }
  }

  // GET CITIES OF SELECTED STATE
  Future<List<CityModel>> fetchCities(int stateId) async {
    try {
      print('Fetching cities for state ID: $stateId');
      final response = await _dio!.get('/public/city/$stateId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data'] != null && data['data']['cities'] != null) {
          List<CityModel> cities = (data['data']['cities'] as List)
              .map((json) => CityModel.fromJson(json))
              .toList();
          print('Fetched ${cities.length} cities');
          return cities;
        } else {
          print('No cities found for state ID: $stateId');
          return [];
        }
      } else {
        throw Exception('Failed to fetch cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      rethrow;
    }
  }

  // ==================== COMPANY DETAILS API ====================

  Future<Map<String, dynamic>> saveCompanyDetails(
    Map<String, dynamic> companyData,
  ) async {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value ||
          authController.authToken.value.isEmpty) {
        return {
          'success': false,
          'message': 'User not logged in',
          'data': null,
        };
      }

      final response = await _dio!.post(
        '/customer/company',
        data: jsonEncode(companyData),
        options: Options(headers: getAuthHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Company Details Saved Successfully',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to save Company Details ${response.statusCode} - ${response.data}',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final authController = Get.find<AuthController>();
        authController.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }
      return {'success': false, 'message': 'Network error ${e.message}'};
    }
  }

  /// Fetch all products
  Future<Map<String, dynamic>> fetchAllProducts({
    int page = 1,
    int limit = 20,
    String? warehouseId,
    String? userId,
    // required String userToken,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();

      // RESOLVE WAREHOUSE ID FROM PRIMARY OUTLET
      if (warehouseId == null || warehouseId.isEmpty) {
        final String? profileWarehouseId = await _resolveWarehouseIdFromOutlet();
        if (profileWarehouseId != null && profileWarehouseId.isNotEmpty) {
          warehouseId = profileWarehouseId;
        }
      }

      String apiUrl = "$jitUrl/product?page=$page&limit=$limit&source=Jitco";

      if (warehouseId != null && warehouseId.isNotEmpty) {
        apiUrl += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }
      if (userId != null && userId.isNotEmpty) {
        apiUrl += "&user_id=${Uri.encodeComponent(userId)}";
      }

      print("Fetching all products...");
      print("Page: $page");
      print("Limit: $limit");
      print("Full URL: $apiUrl");

      final response = await _dio!.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      print("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = response.data;
        print("Products found: ${jsonData['products']?.length ?? 0}");
        print("Total products: ${jsonData['totalProducts'] ?? 0}");
        return jsonData;
      } else {
        print("API Error: ${response.statusCode}");
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  // Fetch products by category
  Future<Map<String, dynamic>> fetchProductsByCategory({
    required String categorySlug,
    int page = 1,
    int limit = 20,
    String? warehouseId,
    String? userId,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();

      // RESOLVE WAREHOUSE ID FROM PRIMARY OUTLET
      if (warehouseId == null || warehouseId.isEmpty) {
        final String? profileWarehouseId = await _resolveWarehouseIdFromOutlet();
        if (profileWarehouseId != null && profileWarehouseId.isNotEmpty) {
          warehouseId = profileWarehouseId;
        }
      }

      String apiUrl =
          "$jitUrl/product?category=$categorySlug&slug=true&page=$page&limit=$limit&source=Jitco";

      if (warehouseId != null && warehouseId.isNotEmpty) {
        apiUrl += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }
      if (userId != null && userId.isNotEmpty) {
        apiUrl += "&user_id=${Uri.encodeComponent(userId)}";
      }
      print("Fetching products by category: $categorySlug");
      print("Page: $page");
      print("Limit: $limit");
      print("Full URL: $apiUrl");
      final response = await _dio!.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );
      print("Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = response.data;
        print("Products found: ${jsonData['products']?.length ?? 0}");
        print("Total products: ${jsonData['totalProducts'] ?? 0}");

        return jsonData;
      } else {
        print("API Error: ${response.statusCode}");
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  // Fetch detailed product view
  Future<Map<String, dynamic>> detailedProducts({
    required String productSlug,
    String? warehouseId,
    String? userId,
  }) async {
    final AuthController authController = Get.find<AuthController>();

    // Automatically resolve warehouseId if not provided
    if (warehouseId == null || warehouseId.isEmpty) {
      warehouseId = await _resolveWarehouseIdFromOutlet();
    }

    String apiUrl = "$jitUrl/product/$productSlug?slug=true&source=Jitco";

    if (warehouseId != null && warehouseId.isNotEmpty) {
      apiUrl += "&warehouse=${Uri.encodeComponent(warehouseId)}";
    }
    if (userId != null && userId.isNotEmpty) {
      apiUrl += "&user_id=$userId";
    }
    try {
      print("Fetching detailed product: $productSlug");
      final response = await _dio!.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = response.data;
        print("Product details fetched");

        if (jsonData is Map && jsonData.containsKey('products')) {
          return jsonData['products'];
        } else if (jsonData is Map && jsonData.containsKey('product')) {
          return jsonData['product'];
        } else {
          return jsonData;
        }
      } else {
        print("API Error: ${response.statusCode}");
        throw Exception(
          'Failed to load product details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print("Network Error: ${e.message}");
      if (e.response != null && e.response!.statusCode == 201) {
        final jsonData = e.response!.data;
        if (jsonData is Map && jsonData.containsKey('products')) {
          return jsonData['products'];
        } else if (jsonData is Map && jsonData.containsKey('product')) {
          return jsonData['product'];
        } else {
          return jsonData;
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Fetch products by brand
  Future<Map<String, dynamic>> fetchProductsByBrand({
    required String? brandSlug,
    required int page,
    required int limit,
    String? warehouseId,
    String? userId,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();

      // Automatically resolve warehouseId if not provided
      if (warehouseId == null || warehouseId.isEmpty) {
        warehouseId = await _resolveWarehouseIdFromOutlet();
      }

      String apiUrl =
          "$jitUrl/product?page=$page&limit=$limit&brand=$brandSlug&slug=true&source=Jitco";

      if (warehouseId != null && warehouseId.isNotEmpty) {
        apiUrl += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }
      if (userId != null && userId.isNotEmpty) {
        apiUrl += "&user_id=${Uri.encodeComponent(userId)}";
      }
      print("Fetching products by brand: $brandSlug");
      final response = await _dio!.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );
      if (response.statusCode == 200) {
        final result = response.data;
        final products = result['products'] ?? [];
        final totalProducts = result['totalProducts'] ?? products.length;
        final totalPages = result['totalPages'] ?? 1;
        print("Fetched ${products.length} products for brand");
        return {
          'products': products,
          'totalProducts': totalProducts,
          'totalPages': totalPages,
        };
      } else {
        print("API Error: ${response.statusCode}");
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  // Fetch perishables
  Future<Map<String, dynamic>> fetchPerishables({
    required String? homeProductSlug,
    required int page,
    required int limit,
    required String search,
    String? warehouseId,
    String? userId,
  }) async {
    try {
      final AuthController authController = Get.find<AuthController>();

      // Automatically resolve warehouseId if not provided
      if (warehouseId == null || warehouseId.isEmpty) {
        warehouseId = await _resolveWarehouseIdFromOutlet();
      }

      final Map<String, dynamic> queryParams = {
        'slug': 'true',
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (homeProductSlug != null && homeProductSlug.isNotEmpty) {
        queryParams['category'] = homeProductSlug;
      }
      String apiUrl = "$jitUrl/product";
      if (warehouseId != null && warehouseId.isNotEmpty) {
        apiUrl += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }
      print("Fetching perishable products...");
      final response = await _dio!.get(
        apiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final result = response.data;
        final products = result['products'] ?? [];
        final totalProducts = result['totalProducts'] ?? 0;
        final totalPages = result['totalPages'] ?? 1;
        if (products is! List) {
          throw Exception('Products data is not in expected format');
        }
        print("Fetched ${products.length} perishable products");
        return {
          'products': products,
          'totalProducts': totalProducts,
          'totalPages': totalPages,
        };
      } else {
        print("API Error: ${response.statusCode}");
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print("Unexpected Error: $e");
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to check if user is logged in
  bool get isLoggedIn {
    try {
      final authController = Get.find<AuthController>();
      return authController.isLoggedIn.value;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Helper method to get auth token
  String get authToken {
    try {
      final authController = Get.find<AuthController>();
      return authController.authToken.value;
    } catch (e) {
      print('Error getting auth token: $e');
      return '';
    }
  }

  // ==================== Drawer API ====================
  //Drawer - get Enquery
  Future<Map<String, dynamic>> getEnqueryData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio!.get(
        '$jitUrl/product/enquire',
        queryParameters: {'page': page, 'limit': limit, 'source': 'Jitco'},
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

  //     final response = await _dio!.post(
  //       '$baseUrl/product/enquire?source=Jitco',
  //       options: Options(headers: getAuthHeaders()),
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
      String? companyId;

      try {
        final authController = Get.find<AuthController>();
        companyId = authController.companyId.value;
      } catch (e) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        companyId = prefs.getString('companyId');
      }

      // ✅ DO NOT THROW → RETURN CLEAN ERROR
      if (companyId == null || companyId.isEmpty) {
        return {
          'status': 'error',
          'message': 'Company ID not found. Please login again.',
        };
      }

      print('========= ENQUIRY REQUEST =========');
      print('Company: $companyId');
      print('Product: $productId');
      print('Quantity: $quantity');
      print('Comments: $comments');
      print('===================================');

      final response = await _dio.post(
        '$jitUrl/product/enquire',
        queryParameters: {'source': 'Jitco'},

        options: Options(headers: getAuthHeaders()),

        // ✅ FIX 1 — REMOVE jsonEncode()
        data: {
          'company': companyId,
          'product': productId,
          'quantity': quantity ?? 1,
          'source': 'Jitco', // Explicitly send source in body
          'progress': [
            {'comments': comments, 'statusList': 'From Customer'},
          ],
          'status': '',
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
    // ✅ FIX 2 — HANDLE DIO ERRORS CORRECTLY
    on DioException catch (e) {
      print('========= DIO ERROR =========');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('==============================');

      return {
        'status': 'error',
        'message': e.response?.data?['message'] ?? 'Server validation failed',
      };
    } catch (e) {
      print('Unexpected Error: $e');

      return {'status': 'error', 'message': 'Unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> getWarehouseIdByCity({
    int page = 1,
    int limit = 10,
    String? encodedCity,
  }) async {
    final AuthController authController = Get.find<AuthController>();
    try {
      final response = await _dio!.get(
        '$jitUrl/public/warehouse/$encodedCity',
        queryParameters: {
          'page': page,
          'limit': limit,
          'source': 'Jitco',
          'contract': authController.hasContract.value,
          'user_id': authController.customerId.value,
        },
        options: Options(headers: getAuthHeaders()),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print('get contract Result**************** $result');
        return result;
      } else {
        print(" API Error: ${response.statusCode}");
        throw Exception('Failed to get enquery: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getContractData: $e');
      throw Exception('unexpected error: $e');
    }
  }

  /// Helper to resolve warehouse ID from user's first outlet city
  Future<String?> _resolveWarehouseIdFromOutlet() async {
    try {
      final authController = Get.find<AuthController>();

      print('🏗️ Resolving Warehouse ID from profile outlet city...');
      
      // 1. Fetch outlets
      final response = await getUserOutlet();
      if (response['success'] == true && response['data'] is List) {
        final List outlets = response['data'];
        if (outlets.isNotEmpty) {
          // Use the first outlet as the primary/profile outlet
          final outlet = OutletModel.fromJson(outlets[0]);
          final cityName = outlet.cityName?.trim();
          
          if (cityName != null && cityName.isNotEmpty) {
            print('🏗️ PRIMARY OUTLET CITY FOUND: "$cityName"');
            
            // Fetch warehouse by city - increased limit to find best match
            final warehouseResponse = await getWarehouseIdByCity(
              encodedCity: cityName,
              limit: 10,
            );
            
            if (warehouseResponse['data'] != null) {
              final data = warehouseResponse['data'];
              List warehouses = [];
              if (data is List) {
                warehouses = data;
              } else if (data is Map) {
                // If it returns a single object instead of a list
                warehouses = [data];
              }
              
              String? resolvedId;
              print('🏗️ Found ${warehouses.length} warehouses for city "$cityName"');
              
              // Try to find exact name match or best match
              for (var w in warehouses) {
                final wName = w['name']?.toString() ?? '';
                print('   - Checking Warehouse: "$wName" (ID: ${w['_id']})');
                if (wName.toLowerCase().contains(cityName.toLowerCase())) {
                  resolvedId = w['_id']?.toString();
                  print('   ✅ Match found!');
                  break;
                }
              }
              
              // Fallback to first if no name match
              if (resolvedId == null && warehouses.isNotEmpty) {
                resolvedId = warehouses[0]['_id']?.toString();
                print('   ⚠️ No direct name match, falling back to first result');
              }
              
              if (resolvedId != null) {
                print('🏗️ FINAL RESOLVED WAREHOUSE ID: $resolvedId');
                authController.warehouseId.value = resolvedId;
                return resolvedId;
              }
            } else {
               print('🏗️ No warehouse data returned for city "$cityName"');
            }
          } else {
            print('🏗️ Primary outlet has no city name');
          }
        } else {
          print('🏗️ User has no outlets');
        }
      }
    } catch (e) {
      print('❌ Error resolving warehouseId from outlet: $e');
    }
    return null;
  }

  Future<ContractModel> getContractData({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? warehouseId,
  }) async {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isLoggedIn.value) {
        throw Exception('User not logged in');
      }

      // RESOLVE WAREHOUSE ID FROM PRIMARY OUTLET
      // Only resolve if caller didn't already provide one
      // (the screen resolves via _fetchIdFromWarehouse and passes _warehouseId directly)
      if (warehouseId == null || warehouseId.isEmpty) {
        print('🏭 Warehouse ID is null, resolving from profile outlet...');
        final String? profileWarehouseId = await _resolveWarehouseIdFromOutlet();
        if (profileWarehouseId != null && profileWarehouseId.isNotEmpty) {
          warehouseId = profileWarehouseId;
          print('🏭 Resolved warehouse from profile: $warehouseId');
        } else {
          print('🏭 Could not resolve warehouse from profile, using default if any');
        }
      } else {
        print('🏭 Using warehouseId provided by UI: $warehouseId');
      }

      String apiUrl =
          '$jitUrl/product/contracted/${authController.companyId.value}';

      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'source': 'Jitco',
        'contract': authController.hasContract.toString(),
        'user_id': authController.customerId.value,
      };

      if (warehouseId != null && warehouseId.isNotEmpty) {
        queryParams['warehouse'] = warehouseId;
      }

      // get category id for filtering the contract products
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        queryParams['category'] = categoryId;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      print('🌐 REQUEST PARAMS: $queryParams');
      print('Company ID: ${authController.companyId.value}');
      print(
        '🔑 Auth Token: ${authController.authToken.value.isNotEmpty ? "Present" : "Missing"}',
      );
      print('Query Params: $queryParams');

      final response = await _dio!.get(
        apiUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      print('API Response: ${response.statusCode} ${response.statusMessage}');

      if (response.statusCode == 200) {
        // The response.data should already be parsed by Dio
        final Map<String, dynamic> responseData = response.data;

        print('Contract data fetched successfully');
        print('Full response structure:');
        print('   Type: ${responseData.runtimeType}');
        print('   Keys: ${responseData.keys.toList()}');

        // Log all fields from your screenshot structure
        print('\nResponse details:');
        print('   message: "${responseData['message']}"');
        print('   page: ${responseData['page']}');
        print('   limit: ${responseData['limit']}');
        print('   totalPages: ${responseData['totalPages']}');
        print('   totalProducts: ${responseData['totalProducts']}');

        // Check products list
        if (responseData.containsKey('products') &&
            responseData['products'] is List) {
          final productsList = responseData['products'] as List;
          print('   products list length: ${productsList.length}');

          if (productsList.isNotEmpty) {
            final firstProduct = productsList[0] as Map<String, dynamic>;
            print('\nFirst product structure:');
            print('   Type: ${firstProduct.runtimeType}');
            print('   Keys: ${firstProduct.keys.toList()}');

            // Log important fields from first product
            print('   _id: ${firstProduct['_id']}');
            print('   productCode: ${firstProduct['productCode']}');
            print('   productName: ${firstProduct['productName']}');
            print('   category type: ${firstProduct['category']?.runtimeType}');

            // Check category structure
            if (firstProduct['category'] is Map) {
              final categoryMap = firstProduct['category'] as Map;
              print('   category keys: ${categoryMap.keys.toList()}');
            }
          }
        }

        // Parse the response using ContractModel
        final contractModel = ContractModel.fromJson(responseData);

        print('\nContractModel parsed successfully');
        print('Total products in model: ${contractModel.data.length}');
        print('Success flag: ${contractModel.success}');
        print('Total: ${contractModel.total}');
        print('Page: ${contractModel.page}');
        print('Limit: ${contractModel.limit}');
        print('Total Pages: ${contractModel.totalPages}');

        if (contractModel.data.isNotEmpty) {
          print('\nFirst ContractProduct details:');
          final firstContractProduct = contractModel.data[0];
          print('   ID: ${firstContractProduct.id}');
          print('   Name: ${firstContractProduct.name}');
          print('   Category: ${firstContractProduct.category}');
          print('   Category ID: ${firstContractProduct.categoryId}');
          print('   Price: ${firstContractProduct.price}');
          print('   In Stock: ${firstContractProduct.inStock}');
        }

        return contractModel;
      } else {
        print('Contract API Error: ${response.statusCode}');
        print('Error response: ${response.data}');
        throw Exception('Failed to get contract data: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getContractData: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');

      // More specific error handling
      if (e is DioException) {
        print('Dio Error: ${e.message}');
        print('Dio Response: ${e.response?.data}');
      }

      rethrow;
    }
  }

  Future<ContractModel> searchContractProducts({
    required String query,
    dynamic categoryId,
    int page = 1,
    int limit = 20,
    String? warehouseId,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query.trim());

    try {
      final AuthController authController = Get.find<AuthController>();

      // RESOLVE WAREHOUSE ID FROM PRIMARY OUTLET
      if (warehouseId == null || warehouseId.isEmpty) {
        final String? profileWarehouseId = await _resolveWarehouseIdFromOutlet();
        if (profileWarehouseId != null && profileWarehouseId.isNotEmpty) {
          warehouseId = profileWarehouseId;
        }
      }

      // Build base URL - using the search endpoint
      String url =
          "$jitUrl/public/product/search?page=$page&limit=$limit&contract=${authController.hasContract}&user_id=${authController.userId}&query=$encodedQuery&company=${authController.customerId}";

      if (warehouseId != null && warehouseId.isNotEmpty) {
        url += "&warehouse=${Uri.encodeComponent(warehouseId)}";
      }

      // Add category filter if provided
      if (categoryId != null) {
        final idStr = categoryId.toString().trim();
        if (idStr.isNotEmpty && idStr != 'null' && idStr != 'all') {
          url += "&category=$categoryId";
          print("Added category filter: $categoryId");
        }
      }

      print(" SEARCH API CALL:");
      print("   Query: '$query'");
      print("   Encoded Query: '$encodedQuery'");
      print("   Category ID: $categoryId");
      print("   URL: $url");
      print("   Has Contract: ${authController.hasContract}");
      print("   User ID: ${authController.userId}");
      print("   Customer ID: ${authController.customerId}");

      final response = await _dio!.get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      print('SEARCH RESPONSE STATUS: ${response.statusCode}');
      print('SEARCH RESPONSE DATA TYPE: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        final body = response.data;

        // Log the response structure
        if (body is Map) {
          print('SEARCH RESPONSE KEYS: ${body.keys.toList()}');

          if (body.containsKey('results')) {
            final results = body['results'] as List?;
            print(' Found ${results?.length ?? 0} results');
          }
        }

        // Parse the response using ContractModel
        return ContractModel.fromJson(body);
      } else {
        print("SEARCH API ERROR: ${response.statusCode}");
        print("Response body: ${response.data}");
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("NETWORK ERROR: ${e.message}");
      print("Error type: ${e.type}");
      if (e.response != null) {
        print("Error response: ${e.response!.data}");
        print("Error status: ${e.response!.statusCode}");
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, st) {
      print("UNEXPECTED SEARCH ERROR: $e");
      print("Stack trace: $st");
      rethrow;
    }
  }

  // Fetch product categories
  Future<PostModel> fetchProductCategories({
    int page = 1,
    int? limit,
    String search = "",
  }) async {
    final authController = Get.find<AuthController>();
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'source': 'Jitco',
      };

      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (limit != null) {
        queryParams['limit'] = limit;
      }

      print('📡 Fetching product categories (page: $page, limit: $limit)...');

      final response = await _dio!.get(
        "$jitUrl/product/category",
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      print('📡 Category response status: ${response.statusCode}');
      print('📊 Category response.data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Decode response - handle both String (raw JSON) and Map
        Map<String, dynamic> data;
        if (response.data is String) {
          print('⚠️ Response is raw String, decoding JSON...');
          data = jsonDecode(response.data as String) as Map<String, dynamic>;
        } else if (response.data is Map) {
          data = Map<String, dynamic>.from(response.data as Map);
        } else {
          throw Exception('Unexpected response type: ${response.data.runtimeType}');
        }

        print('📊 Category response keys: ${data.keys.toList()}');

        // Get category list — API uses 'data' key
        List<dynamic>? rawList;
        if (data['data'] is List) {
          rawList = data['data'] as List;
        } else if (data['categories'] is List) {
          rawList = data['categories'] as List;
        }

        print('📋 Raw category list length: ${rawList?.length ?? 'null'}');


        final categoryList = rawList
            ?.whereType<Map>()
            .map((e) => CategoryData.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        print('✅ Categories parsed: ${categoryList?.length ?? 0} items');

        int? parseIntSafe(dynamic v) =>
            v == null ? null : (v is int ? v : int.tryParse(v.toString()));

        return PostModel(
          success: data['success'],
          total: parseIntSafe(data['total'] ?? data['totalProducts']),
          page: parseIntSafe(data['page']),
          limit: parseIntSafe(data['limit']),
          totalPages: parseIntSafe(data['totalPages']),
          data: categoryList,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching categories: ${e.message}');
      print('   Response: ${e.response?.data}');
      rethrow;
    } catch (e, stack) {
      print('❌ Unexpected error in fetchProductCategories: $e');
      print('   Stack: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> contractStatus() async {
    try {
      // Check if Dio is initialized
      if (_dio == null) {
        print('Dio is not initialized. Calling init()...');
        await init();
      }
      final AuthController authController = Get.find<AuthController>();
      final response = await _dio!.get(
        '$jitUrl/customer/checkContractedStatus',
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${authController.authToken.value}",
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print('get contract status**************** $result');

        // Validate the response structure
        if (result is Map<String, dynamic> &&
            result.containsKey('status') &&
            result.containsKey('contracted')) {
          return result;
        } else {
          throw Exception('Invalid response structure: $result');
        }
      } else {
        print(" API Error: ${response.statusCode}");
        throw Exception(
          'Failed to get contract status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Dio Error in contractStatus: $e');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in contractStatus: $e');
      throw Exception('Unexpected error from contractStatus: $e');
    }
  }

  Future<Map<String, dynamic>> postOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    try {
      if (_dio == null) {
        await init();
      }

      final authController = Get.find<AuthController>();

      print('=== POST ORDER API CALL ===');
      print('URL: $jitUrl/orders');
      print('Payload: $orderPayload');

      final response = await _dio!.post(
        '$jitUrl/orders?source=Jitco',
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

  Future<Map<String, dynamic>> getOrder({
    int page = 1,
    int limit = 20,
    String status = 'All',
  }) async {
    try {
      // Check if Dio is initialized
      if (_dio == null) {
        print('Dio is not initialized. Calling init()...');
        await init();
      }
      final AuthController authController = Get.find<AuthController>();
      final response = await _dio!.get(
        '$jitUrl/orders?page=$page&limit=$limit&status=$status&source=Jitco',
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

  Future<Map<String, dynamic>> getOrderDetail({
    String orderId = '',
    String? source,
  }) async {
    try {
      // Check if Dio is initialized
      // if (_dio == null) {
      //   print('Dio is not initialized. Calling init()...');
      //   await init();
      // }
      final AuthController authController = Get.find<AuthController>();
      final response = await _dio.get(
        '$jitUrl/orders/$orderId?source=$source',
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

  Future<ProductSearchResponse?> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? warehouseId,
  }) async {
    try {
      // RESOLVE WAREHOUSE ID FROM PRIMARY OUTLET
      if (warehouseId == null || warehouseId.isEmpty) {
        warehouseId = await _resolveWarehouseIdFromOutlet();
      }

      final response = await _dio.get(
        "$jitUrl/public/product/search",
        queryParameters: {
          "query": query,
          "page": page,
          "limit": limit,
          "source": "all",
          if (warehouseId != null && warehouseId.isNotEmpty) "warehouse": warehouseId,
        },
      );

      if (response.statusCode == 200) {
        return ProductSearchResponse.fromJson(response.data);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
