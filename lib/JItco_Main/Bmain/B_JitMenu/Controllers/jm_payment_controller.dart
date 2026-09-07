import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';

class JmPaymentController extends GetxController {
  final ApiServices apiService = Get.find<ApiServices>();

  // Rx list
  final paymentOptions = <String>['Pay Now', 'Credit'].obs;

  // Selected value (Rx)
  var selectedPayment = 'Pay Now'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentOptions();
  }

  Future<void> fetchPaymentOptions() async {
    try {
      final response = await apiService.contractStatus();
      if (response['contracted'] == true) {
        if (!paymentOptions.contains('Contract Term')) {
          paymentOptions.add('Contract Term');
        }
        // Keep Contract Term as default if contracted
        selectedPayment.value = 'Contract Term';
      } else {
        selectedPayment.value = 'Pay Now';
      }
    } catch (e) {
      print('Error fetching contract status for payment options: $e');
    }
  }
}
