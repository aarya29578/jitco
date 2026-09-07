import 'dart:math';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Authentication/login.dart';
import 'package:jitco_app/JItco_Main/jitco_main.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/after_splash_issue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('SplashScreen: Initializing app...');

    try {
      // Wait a bit for UI to show
      await Future.delayed(Duration(milliseconds: 500));

      // Initialize services
      await _initializeServices();

      // Check auth and navigate
      await _checkAuthAndNavigate();
    } catch (e) {
      print('SplashScreen initialization error: $e');
      // Fallback to login on error
      Get.off(() => Login());
    }
  }

  Future<void> _initializeServices() async {
    print('Initializing services...');

    // Make sure AuthController is initialized
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }

    // Make sure ApiService is initialized
    if (!Get.isRegistered<ApiServices>()) {
      await Get.putAsync(() => ApiServices().init());
    }

    print('Services initialized');
  }

  Future<void> _checkAuthAndNavigate() async {
    print('Checking authentication status...');

    try {
      final authController = Get.find<AuthController>();

      // First, check SharedPreferences directly for debugging
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token') ?? '';
      final storedLoggedIn = prefs.getBool('is_logged_in') ?? false;

      print('Direct Storage Check:');
      print('  - auth_token exists: ${storedToken.isNotEmpty}');
      print('  - auth_token length: ${storedToken.length}');
      print('  - is_logged_in: $storedLoggedIn');

      if (storedToken.isNotEmpty) {
        print(
          '  - Token first 20 chars: ${storedToken.substring(0, min(20, storedToken.length))}...',
        );
      }

      // Now load token via AuthController
      await authController.loadTokenFromStorage();

      print('AuthController State After Load:');
      print('  - isLoggedIn.value: ${authController.isLoggedIn.value}');
      print('  - authToken empty: ${authController.authToken.value.isEmpty}');
      print('  - authToken length: ${authController.authToken.value.length}');

      // Wait a bit more for smooth transition
      await Future.delayed(Duration(seconds: 1));

      // Navigate based on auth status
      if (authController.isLoggedIn.value &&
          authController.authToken.value.isNotEmpty) {
        print('User is logged in, navigating to home...');

        // Optional: Test token validity before navigation
        try {
          final apiService = Get.find<ApiServices>();
          final testResult = await apiService.getUserContact();

          if (testResult['success'] == true) {
            print('Token is valid, proceeding to home');
            Get.off(() => JItcoMain());
          } else {
            print('Token is invalid, redirecting to login');
            Get.off(() => Login());
          }
        } catch (e) {
          print('Token test failed: $e');
          // On error, still try to go to home (token might be valid)
          Get.off(() => JItcoMain());
        }

        ////////FOR SERVER AND NETWORK ISSUE FINDER OR SCREEN
        // try {
        //   final apiService = Get.find<ApiServices>();
        //   final testResult = await apiService.getUserContact();

        //   if (testResult['success'] == true) {
        //     Get.off(() => JItcoMain());
        //   } else {
        //     Get.off(() => Login());
        //   }
        // } on DioException catch (e) {
        //   // NETWORK ERROR
        //   if (e.error is SocketException ||
        //       e.type == DioExceptionType.connectionTimeout ||
        //       e.type == DioExceptionType.receiveTimeout) {
        //     Get.off(() => NetworkIssueScreen());
        //     return;
        //   }

        //   // SERVER ERROR
        //   final status = e.response?.statusCode ?? 0;
        //   if (status >= 500) {
        //     Get.off(() => ServerIssueScreen());
        //     return;
        //   }

        //   // Anything else → login
        //   Get.off(() => Login());
        // } catch (e) {
        //   Get.off(() => Login());
        // }
      } else {
        print('User is not logged in, navigating to login...');
        Get.off(() => Login());
      }
    } catch (e) {
      print('Auth check error: $e');
      Get.off(() => Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/logo.svg',
              width: 120,
              height: 120,
              // Add placeholder if needed
              placeholderBuilder: (context) =>
                  Container(width: 120, height: 120, color: Colors.grey[200]),
            ),

            SizedBox(height: 20),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 2,
            ),

            SizedBox(height: 15),

            // Loading text
            Text(
              'Loading...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
