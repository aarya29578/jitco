import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/profile_controller.dart';
import 'package:jitco_app/JItco_Main/Authentication/login.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showCommonDialog(BuildContext context) {
  if (Platform.isIOS) {
    // iOS Cupertino Dialog
    showCupertinoDialog(
      // barrierDismissible: false,
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => safeBack(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text("Logout"),
            onPressed: () {
              _performLogout();
            },
          ),
        ],
      ),
    );
  } else {
    // Android Material Dialog
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Logout", style: TextStyle(fontWeight: FontWeight.w500)),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.black54)),
            onPressed: () => safeBack(context),
          ),
          TextButton(
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.deepOrangeAccent),
            ),
            onPressed: () {
              _performLogout();
            },
          ),
        ],
      ),
    );
  }
}

// Future<void> _performLogout() async {
//   final ApiService apiService = Get.find<ApiService>();
//   try {
//     await apiService.logout();
//     // Navigate to login screen and remove all previous routes
//     Get.offAll(() => Login());
//   } catch (e) {
//     print("Logout error: $e");
//     // Even if there's an error, clear local data and redirect to login
//     Get.offAll(() => Login());
//   }
// }

Future<void> _performLogout() async {
  final AuthController authController = Get.find<AuthController>();

  try {
    // Call logout on AuthController instead of ApiService
    await authController.logout();

    // Clear any other local data if needed
    // For example, if you have a CartController or ProfileController
    try {
      final profileController = Get.find<ProfileController>();
      profileController.clearSelection();
      profileController.contacts.clear();
      profileController.outlets.clear();
    } catch (e) {
      print("Error clearing profile data: $e");
    }

    // Navigate to login screen and remove all previous routes
    Get.offAll(() => Login());
  } catch (e) {
    print("Logout error: $e");

    // Fallback: Clear auth state manually and redirect
    try {
      // Clear SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('is_logged_in');

      // Reset AuthController state
      authController.authToken.value = '';
      authController.isLoggedIn.value = false;
    } catch (e2) {
      print("Error in fallback logout: $e2");
    }

    // Navigate to login screen
    Get.offAll(() => Login());
  }
}

void safeBack(BuildContext context) {
  if (Get.isDialogOpen == true ||
      Get.isBottomSheetOpen == true ||
      Get.isSnackbarOpen == true) {
    Get.back();
    return;
  }

  if (Navigator.of(context).canPop()) {
    Get.back();
  }
}

void showDeleteAccountDialog(BuildContext context) {
  // Close the bottom sheet first
  Get.back();

  // Wait for bottom sheet to close, then show dialog
  Future.delayed(const Duration(milliseconds: 300), () {
    final ctx = Get.context;
    if (ctx == null) return;

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: ctx,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: Text("Delete Account"),
          content: Text(
              "Are you sure you want to permanently delete your account? This action cannot be undone."),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _performDeleteAccount();
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Account",
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.red)),
          content: Text(
              "Are you sure you want to permanently delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              child:
                  Text("Cancel", style: TextStyle(color: Colors.black54)),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _performDeleteAccount();
              },
            ),
          ],
        ),
      );
    }
  });
}

Future<void> _performDeleteAccount() async {
  final AuthController authController = Get.find<AuthController>();
  final ApiServices apiService = Get.find<ApiServices>();

  // Get customer ID
  String customerId = authController.userId.value;
  if (customerId.isEmpty) {
    customerId = authController.customerId.value;
  }

  print('DEBUG DELETE: userId="${authController.userId.value}"');
  print('DEBUG DELETE: customerId="${authController.customerId.value}"');
  print('DEBUG DELETE: final ID for API="$customerId"');

  if (customerId.isEmpty) {
    print('DEBUG DELETE: ID is EMPTY, cannot call API');
    Get.snackbar(
      "Error",
      "Customer ID not found. Please log in again.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  // Show loading spinner
  Get.dialog(
    const Center(child: CircularProgressIndicator(color: Colors.red)),
    barrierDismissible: false,
  );

  try {
    print('DEBUG DELETE: Calling API now...');
    bool success = await apiService.deleteAccount(customerId);
    print('DEBUG DELETE: API returned success=$success');

    // Close loading spinner
    if (Get.isDialogOpen ?? false) Get.back();

    if (success) {
      Get.snackbar(
        "Account Deleted",
        "Your account has been deleted successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      _performLogout();
    } else {
      Get.snackbar(
        "Error",
        "Failed to delete account. Please try again later.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print("DEBUG DELETE: Exception=$e");
    if (Get.isDialogOpen ?? false) Get.back();
    Get.snackbar(
      "Error",
      "An unexpected error occurred.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

