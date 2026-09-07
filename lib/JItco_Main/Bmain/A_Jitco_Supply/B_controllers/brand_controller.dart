import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/PostModel.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/brand.dart';
import '../../../../A_model_data_summa/brand_data.dart'; // <-- your model file

// class BrandController extends GetxController {
//   var isLoading = true.obs;
//   var brandList = <CategoryData>[].obs;

//   final dio = Dio();

//   get selectedBrandSlug => null;

//   @override
//   void onInit() {
//     fetchBrands();
//     super.onInit();
//   }

//   Future<void> fetchBrands() async {
//     try {
//       isLoading(true);

//       final response = await dio.get(
//         "https://api.jitco.in/api/v1/public/brand?source=Jitco",
//       );

//       if (response.statusCode == 200) {
//         final postModel = PostModel.fromJson(response.data);

//         brandList.value = postModel.data ?? [];
//       }
//     } catch (e) {
//       print("Brand API Error: $e");
//     } finally {
//       isLoading(false);
//     }
//   }
// }

class BrandController extends GetxController {
  var isLoading = true.obs;

  /// ✅ USE Brand instead of CategoryData
  var brandList = <Brand>[].obs;

  final dio = Dio();

  String? selectedBrandSlug;

  @override
  void onInit() {
    fetchBrands();
    super.onInit();
  }

  Future<void> fetchBrands() async {
    try {
      isLoading(true);

      final response = await dio.get(
        "https://api.jitco.in/api/v1/public/brand?source=Jitco",
      );

      if (response.statusCode == 200) {
        /// ✅ Parse correct model
        final brandResponse = BrandResponse.fromJson(response.data);

        brandList.value = brandResponse.data ?? [];
      }
    } catch (e) {
      print("Brand API Error: $e");
    } finally {
      isLoading(false);
    }
  }
}
