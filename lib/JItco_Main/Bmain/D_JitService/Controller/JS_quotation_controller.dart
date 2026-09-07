import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_detail_quotation_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_quatation_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/enums.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';

class JsQuotationController extends GetxController {
  Rx<PageState> jsQuotationLoading = PageState.loading.obs;
  Rx<PageState> jsDetailQuotationLoading = PageState.loading.obs;
  Rx<JsQuatationModel> jsQuotationData = JsQuatationModel().obs;
  Rx<JsDetailQuotationModel> jsDetailQuotationData =
      JsDetailQuotationModel().obs;
  final JsApiService _jsApiService = Get.find<JsApiService>();

  Future<void> getAllQuotation() async {
    try {
      jsQuotationLoading.value = PageState.loading;
      await Future.delayed(const Duration(seconds: 1));

      final response = await _jsApiService.jsGetQuotation();
      if (response.status == true) {
        jsQuotationData.value = response;
        jsQuotationLoading.value = PageState.stable;
      } else {
        print("All Quotation API returned success = false");
        jsQuotationLoading.value = PageState.error;
      }
    } catch (e) {
      jsQuotationLoading.value = PageState.error;
      print('All Quotation throw catch: $e');
      throw e;
    }
  }

  Future<void> getDetailQuotation(String? quoteId) async {
    try {
      jsDetailQuotationLoading.value = PageState.loading;
      await Future.delayed(Duration(seconds: 1));

      final response = await _jsApiService.jsGetDetailQuotation(quoteId);

      if (response.status == true) {
        jsDetailQuotationData.value = response;
        jsDetailQuotationLoading.value = PageState.stable;
      } else {
        print("Detail Quotation API returned success = false");
        jsDetailQuotationLoading.value = PageState.error;
      }
    } catch (e) {
      jsDetailQuotationLoading.value = PageState.error;
      print('Detail Quotation throw catch: $e');
    }
  }
}
