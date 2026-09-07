import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Authentication/login.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final ApiServices authService = Get.find<ApiServices>();

  // Auth state variables
  var isLoading = false.obs;
  var error = ''.obs;
  var phoneNumber = ''.obs;
  var otp = ''.obs;
  var isNewUser = false.obs;

  // Authentication variables
  var authToken = ''.obs;
  var isLoggedIn = false.obs;

  // User Contract or not
  var hasContract = false.obs;
  var contractExpireDate = ''.obs;

  // Company data - ADD THESE NEW FIELDS
  var companyId = ''.obs;
  var companyName = ''.obs;
  var customerId = ''.obs;

  var city = 0.obs;
  var state = 0.obs;
  RxString userId = ''.obs;
  RxString outletId = ''.obs;
  RxString warehouseId = ''.obs;
  RxString selectedCity = ''.obs;

  final RxString cityName = ''.obs;

  // Add this flag to track if initialization is complete
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('AuthController initialized');
    initializeAuth();
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    try {
      print('Initializing auth state...');
      await loadAuthDataFromStorage();
      isInitialized.value = true;
      print('Auth initialization complete');
      print('   - isLoggedIn: ${isLoggedIn.value}');
      print('   - token exists: ${authToken.value.isNotEmpty}');
      print('   - companyId: ${companyId.value}');
      print('   - customerId: ${customerId.value}');
      print('   - StateId: ${state.value}');
    } catch (e) {
      print('Error initializing auth: $e');
      isInitialized.value = true;
    }
  }

  // Send OTP
  Future<bool> sendOtp(String phone) async {
    try {
      print('AuthController: Starting sendOtp');
      isLoading(true);
      error('');
      phoneNumber.value = phone;

      print('AuthController: Calling authService.sendOtp()');
      final response = await authService.sendOtp(phone);
      print('AuthController: API response received');

      if (response.success) {
        isNewUser.value = response.isNewUser;
        print('AuthController: OTP sent successfully');
        print('AuthController: isNewUser = ${isNewUser.value}');
        otp.value = response.otp ?? '';

        String otpMessage = 'OTP sent to $phone';
        if (response.otp != null) {
          otpMessage += '\nTest OTP: ${response.otp}';
        }

        // _showSafeSnackbar('Success', otpMessage);
        return true;
      } else {
        print('AuthController: OTP failed - ${response.message}');
        error(response.message);
        // _showSafeSnackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      print('AuthController: Error - $e');
      error(e.toString());
      // _showSafeSnackbar('Error', 'Failed to send OTP: $e');
      return false;
    } finally {
      print('AuthController: Finished sendOtp');
      isLoading(false);
    }
  }

  // Verify OTP - UPDATED with company data extraction
  Future<bool> verifyOtp(String enteredOtp) async {
    try {
      print('AuthController.verifyOtp() called');
      isLoading(true);
      error('');
      otp.value = enteredOtp;

      final response = await authService.verifyOtp(
        phoneNumber.value,
        enteredOtp,
      );

      print('Response received: success=${response.success}');

      if (response.success) {
        // IMPORTANT: Get token from response
        final token = response.token;
        final data = response.data;

        if (token != null && token.isNotEmpty) {
          print('Token received from API, length: ${token.length}');

          // Extract company and customer data
          String? extractedCompanyId;
          String? extractedCustomerId;
          String? extractedCompanyName;
          String? extractedUserId;
          String? contractExpireDate;
          int? extractedCity;
          int? extractedState;

          final outlet = response.data?['customer']?['outlet'];

          if (data != null) {
            print('Parsing response data for company info...');

            // Extract user ID
            if (data['customer'] != null && data['customer']['_id'] != null) {
              extractedUserId = data['customer']['_id'];
              print('User ID extracted: $extractedUserId');
            }

            // Extract customer ID
            if (data['customer'] != null && data['customer']['_id'] != null) {
              extractedCustomerId = data['customer']['_id'];
              print('Customer ID extracted: $extractedCustomerId');
            }

            // Extract company data
            if (data['customer'] != null &&
                data['customer']['company'] != null) {
              final companyData = data['customer']['company'];

              if (companyData['_id'] != null) {
                extractedCompanyId = companyData['_id'];
                print('Company ID extracted: $extractedCompanyId');
              }

              if (companyData['company_name'] != null) {
                extractedCompanyName = companyData['company_name'];
                print('Company Name extracted: $extractedCompanyName');
              }

              // Print all company data for debugging
              print('Full company data:');
              companyData.forEach((key, value) {
                print('   - $key: $value');
              });
            }
            if (outlet != null) {
              extractedCity = outlet['city'];
              extractedState = outlet['state'];

              print('City extracted: $extractedCity');
              print('State extracted: $extractedState');
            }
          }

          // Save all auth data to storage
          // await saveAuthDataToStorage(
          //   token: token,
          //   companyId: extractedCompanyId,
          //   customerId: extractedCustomerId,
          //   companyName: extractedCompanyName,
          // );

          final company = response.data?['customer']?['company'];

          await saveAuthDataToStorage(
            token: token,
            userId: extractedUserId,
            companyId: extractedCompanyId,
            customerId: extractedCustomerId,
            companyName: extractedCompanyName,

            // hasContract: response.data?['contract'] ?? false,
            // contractExpireDate: response.data?['contract_expire_date']
            //     ?.toString(),
            hasContract: company?['contract'] ?? false,
            contractExpireDate: company?['contract_expire_date']?.toString(),
            city: extractedCity,
            state: extractedState,
          );

          // await authService.fetchAndSaveCityName;

          // Update controller state
          authToken.value = token;
          isLoggedIn.value = true;
          userId.value = extractedUserId ?? '';

          if (extractedCompanyId != null) {
            companyId.value = extractedCompanyId;
          }

          if (extractedCustomerId != null) {
            customerId.value = extractedCustomerId;
          }

          if (extractedCompanyName != null) {
            companyName.value = extractedCompanyName;
          }

          await authService.fetchAndSaveCityName;

          // Verify save
          print('Auth data saved, verifying...');
          await _verifyAuthStorage();

          // Navigate to home screen
          print('Navigating to home...');
          Get.offAll(() => JitcoSupplyNavBar());

          // _showSafeSnackbar('Success', 'Login successful!');
          return true;
        } else {
          print('ERROR: Response.success but token is null or empty!');
          print('Response token: $token');
          error('Login failed: No token received');
          // _showSafeSnackbar('Error', 'Login failed: No token received');
          return false;
        }
      } else {
        print('OTP verification failed: ${response.message}');
        error(response.message);
        // _showSafeSnackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      print('Exception in verifyOtp: $e');
      error(e.toString());
      // _showSafeSnackbar('Error', 'Failed to verify OTP: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  // ========== STORAGE METHODS ==========

  // Save complete auth data to storage
  Future<void> saveAuthDataToStorage({
    required String token,
    String? userId,
    String? companyId,
    String? customerId,
    String? companyName,

    bool? hasContract,
    String? contractExpireDate,

    int? city,
    int? state,
  }) async {
    print('=== SAVING AUTH DATA ===');
    print('   - Token length: ${token.length}');
    print('   - User ID: $userId');
    print('   - Company ID: $companyId');
    print('   - Customer ID: $customerId');
    print('   - Company Name: $companyName');
    print('   - City: $city');

    // Decode and print JWT payload
    print('\nJWT PAYLOAD DECODED:');
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        String paddedPayload = payload;
        while (paddedPayload.length % 4 != 0) {
          paddedPayload += '=';
        }

        final decodedPayload = utf8.decode(base64Url.decode(paddedPayload));
        final payloadJson = json.decode(decodedPayload);

        print('   - User ID: ${payloadJson['id']}');
        print('   - User Type: ${payloadJson['type']}');
        print('   - Issued at (iat): ${payloadJson['iat']}');
        print('   - Expires at (exp): ${payloadJson['exp']}');

        if (payloadJson['iat'] != null) {
          final iatDate = DateTime.fromMillisecondsSinceEpoch(
            payloadJson['iat'] * 1000,
          );
          print('   - Issued date: $iatDate');
        }
        if (payloadJson['exp'] != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(
            payloadJson['exp'] * 1000,
          );
          print('   - Expiry date: $expDate');
          print(
            '   - Valid for: ${expDate.difference(DateTime.now()).inDays} days',
          );
        }
      } else {
        print('   - Not a valid JWT (${parts.length} parts)');
      }
    } catch (e) {
      print('   - JWT decode error: $e');
    }

    print('========================\n');

    final prefs = await SharedPreferences.getInstance();

    // Save token and login flag
    await prefs.setString('auth_token', token);
    await prefs.setBool('is_logged_in', true);

    // Save user ID - ADD THIS
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString('user_id', userId);
    }

    // Save company data
    if (companyId != null) {
      await prefs.setString('company_id', companyId);
    }

    if (customerId != null) {
      await prefs.setString('customer_id', customerId);
    }

    if (companyName != null) {
      await prefs.setString('company_name', companyName);
    }

    // Save contract data
    if (hasContract != null) {
      await prefs.setBool('contract', hasContract);
    }

    if (contractExpireDate != null) {
      await prefs.setString('contract_expire_date', contractExpireDate);
    }

    // Save city
    if (city != null) {
      await prefs.setInt('city', city); // Save city as integer
    }

    if (state != null) {
      await prefs.setInt('state', state);
    }

    // Save phone number for reference
    await prefs.setString('last_phone', phoneNumber.value);

    print('All auth data saved successfully');
  }

  // For backward compatibility - you can use this if your ApiService calls saveAuthData
  Future<void> saveAuthData({
    required String token,
    String? userId,
    String? companyId,
    String? customerId,
    String? companyName,

    bool? hasContract,
    String? contractExpireDate,

    int? city,
  }) async {
    print('Note: saveAuthData is calling saveAuthDataToStorage');
    await saveAuthDataToStorage(
      token: token,
      userId: userId,
      companyId: companyId,
      customerId: customerId,
      companyName: companyName,

      hasContract: hasContract,
      contractExpireDate: contractExpireDate,

      city: city,
    );
  }

  Future<void> loadAuthDataFromStorage() async {
    print('loadAuthDataFromStorage() called');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load basic auth data
      final token = prefs.getString('auth_token') ?? '';
      final loggedIn = prefs.getBool('is_logged_in') ?? false;

      // Load user data - ADD THIS
      final storedUserId = prefs.getString('user_id') ?? '';
      print('     - User ID: $storedUserId');

      // Load company data
      final storedCompanyId = prefs.getString('company_id') ?? '';
      final storedCustomerId = prefs.getString('customer_id') ?? '';
      final storedCompanyName = prefs.getString('company_name') ?? '';

      // Load contract data
      final storedHasContract = prefs.getBool('contract') ?? false;
      final storedContractExpireDate =
          prefs.getString('contract_expire_date') ?? '';

      // ✅ Load city ID
      final storedCityId = prefs.getInt('city') ?? 0;
      print('     - City ID: $storedCityId');

      final storedStateId = prefs.getInt('state') ?? 0;
      print('stored state id: $storedStateId');

      hasContract.value = storedHasContract;
      contractExpireDate.value = storedContractExpireDate;
      city.value = storedCityId; // ✅ Set the city value
      state.value = storedStateId; // ✅ Set the city value

      print('   - Retrieved from storage:');
      print('     - Token exists: ${token.isNotEmpty}');
      print('     - Token length: ${token.length}');
      print('     - Logged in flag: $loggedIn');
      print('     - Company ID: $storedCompanyId');
      print('     - Customer ID: $storedCustomerId');
      print('     - Company Name: $storedCompanyName');
      print('     - Has Contract: $storedHasContract');
      print('     - Contract Expiry: $storedContractExpireDate');
      print('     - City ID: $storedCityId'); // Added this
      print('     - State ID: $storedStateId'); // Added this

      if (token.isNotEmpty && loggedIn) {
        if (token.length > 10) {
          // Update controller state
          authToken.value = token;
          isLoggedIn.value = true;
          userId.value = storedUserId;
          companyId.value = storedCompanyId;
          customerId.value = storedCustomerId;
          companyName.value = storedCompanyName;

          print('All auth data loaded into controller successfully');

          // Print token snippet for debugging
          print(
            '   - Loaded token (first 20 chars): ${token.substring(0, min(20, token.length))}...',
          );
        } else {
          print('Token appears corrupted (too short), clearing...');
          await clearAuthData();
        }
      } else {
        print('No valid token found in storage');
        authToken.value = '';
        isLoggedIn.value = false;
        userId.value = '';
        companyId.value = '';
        customerId.value = '';
        companyName.value = '';
        city.value = 0; // ✅ Reset city
        state.value = 0;
      }
    } catch (e) {
      print('Error loading auth data from storage: $e');
      authToken.value = '';
      isLoggedIn.value = false;
      userId.value = '';
      companyId.value = '';
      customerId.value = '';
      companyName.value = '';
      city.value = 0; // ✅ Reset city on error
      state.value = 0;
    }
  }

  // For backward compatibility - if you have code calling loadTokenFromStorage
  Future<bool> loadTokenFromStorage() async {
    print('Note: loadTokenFromStorage is calling loadAuthDataFromStorage');
    await loadAuthDataFromStorage();
    return isLoggedIn.value && authToken.value.isNotEmpty;
  }

  // Helper to verify auth storage
  Future<void> _verifyAuthStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final storedToken = prefs.getString('auth_token') ?? '';
    final storedFlag = prefs.getBool('is_logged_in') ?? false;
    final storedCompanyId = prefs.getString('company_id') ?? '';
    final storedCustomerId = prefs.getString('customer_id') ?? '';

    print('Auth Storage Verification:');
    print(
      '   - Controller token: ${authToken.value.isNotEmpty ? "Set" : "Empty"}',
    );
    print('   - Stored token: ${storedToken.isNotEmpty ? "Set" : "Empty"}');
    print('   - Stored flag: $storedFlag');
    print('   - Tokens match: ${authToken.value == storedToken}');
    print('   - States match: ${isLoggedIn.value == storedFlag}');
    print('   - Company ID: $storedCompanyId');
    print('   - Customer ID: $storedCustomerId');
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    print('Clearing all auth data...');
    final prefs = await SharedPreferences.getInstance();

    // Clear token and login data
    await prefs.remove('auth_token');
    await prefs.remove('is_logged_in');
    await prefs.remove('last_phone');

    // Clear user data - ADD THIS
    await prefs.remove('user_id');

    // Clear company data
    await prefs.remove('company_id');
    await prefs.remove('customer_id');
    await prefs.remove('company_name');

    // Reset controller state
    authToken.value = '';
    isLoggedIn.value = false;
    userId.value = '';
    phoneNumber.value = '';
    otp.value = '';
    companyId.value = '';
    customerId.value = '';
    companyName.value = '';

    print('All auth data cleared');
  }

  // Logout method
  Future<void> logout() async {
    print('Logging out...');
    await clearAuthData();
    Get.offAll(() => Login());
  }

  // Clear errors
  void clearError() {
    error.value = '';
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    return isLoggedIn.value && authToken.value.isNotEmpty;
  }

  // Get token for API calls
  String? get token {
    return authToken.value.isNotEmpty ? authToken.value : null;
  }

  // Check if company data is available
  bool get hasCompanyData {
    return companyId.value.isNotEmpty;
  }

  // Method to get auth headers for API calls
  Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer ${authToken.value}',
      'Content-Type': 'application/json',
    };
  }

  // Method to get request body with company ID included
  Map<String, dynamic> addCompanyIdToRequestBody(Map<String, dynamic> data) {
    if (companyId.value.isNotEmpty) {
      return {...data, 'company_id': companyId.value};
    }
    return data;
  }

  // Add safe snackbar method
  // void _showSafeSnackbar(String title, String message) {
  //   try {
  //     if (Get.context != null) {
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         SnackBar(
  //           content: Text('$title: $message'),
  //           backgroundColor: title == 'Error' ? Colors.red : Colors.green,
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     } else {
  //       print('$title: $message');
  //     }
  //   } catch (e) {
  //     print('Error showing snackbar: $e');
  //     print('$title: $message');
  //   }
  // }

  // Debug method to print current auth state
  void printAuthState() {
    print('=== AUTH STATE ===');
    print('   - isLoggedIn: ${isLoggedIn.value}');
    print('   - Token exists: ${authToken.value.isNotEmpty}');
    print('   - User ID: ${userId.value}');
    print('   - Company ID: ${companyId.value}');
    print('   - Customer ID: ${customerId.value}');
    print('   - Company Name: ${companyName.value}');
    print('   - Phone: ${phoneNumber.value}');
    print('=================');
  }

  // ========== BACKWARD COMPATIBILITY METHODS ==========

  // Save token only (for backward compatibility)
  Future<void> saveTokenToStorage(String token) async {
    print(
      'Note: saveTokenToStorage is deprecated, use saveAuthDataToStorage instead',
    );
    await saveAuthDataToStorage(token: token);
  }

  // Debug token status (from your old code)
  Future<void> debugTokenStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final loggedIn = prefs.getBool('is_logged_in') ?? false;

      print('=== TOKEN DEBUG INFO ===');
      print('Token exists: ${token.isNotEmpty}');
      print('Token length: ${token.length}');
      print(
        'First 50 chars: ${token.length > 50 ? '${token.substring(0, 50)}...' : token}',
      );
      print('Is logged in (storage): $loggedIn');
      print('Is logged in (controller): ${isLoggedIn.value}');
      print('Token in controller: ${authToken.value.isNotEmpty}');
      print('=========================');
    } catch (e) {
      print('Error debugging token: $e');
    }
  }

  // Test token storage (from your old code)
  Future<void> testTokenStorage() async {
    print('=== TOKEN STORAGE TEST ===');

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('auth_token') ?? '';
    final storedFlag = prefs.getBool('is_logged_in') ?? false;

    print('Storage Check:');
    print('   - auth_token: ${storedToken.isNotEmpty ? "EXISTS" : "EMPTY"}');
    print('   - auth_token length: ${storedToken.length}');
    print('   - is_logged_in: $storedFlag');

    if (storedToken.isNotEmpty) {
      print(
        '   - Token preview: ${storedToken.substring(0, min(30, storedToken.length))}...',
      );
    }

    print('Controller Check:');
    print('   - authToken: ${authToken.value.isNotEmpty ? "EXISTS" : "EMPTY"}');
    print('   - authToken length: ${authToken.value.length}');
    print('   - isLoggedIn: ${isLoggedIn.value}');

    print('Comparison:');
    print('   - Tokens match: ${authToken.value == storedToken}');
    print('   - States match: ${isLoggedIn.value == storedFlag}');

    print('==========================');
  }
}
