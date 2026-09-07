// lib/controllers/payment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';

class PaymentController extends GetxController {
  final RxBool isContracted = false.obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxnString contractStatusText = RxnString();

  // Initialize your API service
  final ApiServices _apiService = Get.find<ApiServices>();
  @override
  void onInit() {
    super.onInit();
    fetchContractStatus();
  }

  Future<void> fetchContractStatus() async {
    try {
      isLoading(true);
      error(null);

      // Call your API
      final response = await _apiService.contractStatus();

      // Update the contract status
      isContracted(response['contracted'] as bool);

      // Update the display text
      contractStatusText.value = isContracted.value
          ? "Credit Cycle as per Contract Term"
          : "Cash on Delivery";
    } catch (e) {
      error(e.toString());
      contractStatusText.value = "Error loading payment method";
      print('Error fetching contract status: $e');
    } finally {
      isLoading(false);
    }
  }

  // Get the icon based on contract status
  IconData getPaymentIcon() {
    return isContracted.value ? Icons.description : Icons.local_atm;
  }

  // Get the payment method text
  String getPaymentMethodText() {
    if (isLoading.value) return "Loading...";
    if (error.value != null) return "Error loading";
    return isContracted.value
        ? "Credit Cycle as per Contract Term"
        : "Cash on Delivery";
  }
}
