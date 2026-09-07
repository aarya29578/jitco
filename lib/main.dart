import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/bottom_tab_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_home_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_order_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/JL_Screens/D_Cart_Screen.dart/JL_cart_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Controller/JL_cartcontroller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_order_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_payment_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/jm_price_calculation_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/Jm_category_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_category_product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_all_product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/order_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/payment_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/product_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/profile_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_price_calcultaion_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_enquiry_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/JS_order_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_bottom_nav_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/Controller/Js_cart_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/JS_Screens/D_JS_Cart/Js_cart_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_price_calculation_services.dart';
import 'package:jitco_app/JItco_Main/splash_screen.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/price_calculation_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/search_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    ///Lock app to Portrait only
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,

    ///Lock app to Landscape only
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Initialize services
  await Get.putAsync(() => ApiServices().init());
  Get.put(BottomNavController());
  Get.put(JMApiService());
  Get.put(PriceCalculationService());
  Get.put(JmPriceCalculationService());
  await GetStorage.init(); // for local storage
  Get.put(CartController());
  Get.put(JmCartController());
  Get.put(JlCartcontroller());
  Get.put(OrderController());
  Get.put(JmOrderController());
  Get.put(SearchApi());
  Get.put(ProductSearchController());
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(EnquiryController());
  Get.put(JmEnquiryController());
  Get.put(PaymentController());
  Get.put(JmPaymentController());

  // Get.put(WarehouseController());
  Get.put(JmCategoryController());
  Get.put(JmHomeCategoryController());
  Get.put(CategoryProductsController());
  Get.put(AllProductsController());

  ///...JL
  Get.lazyPut(() => JlCartcontroller());
  Get.put(() => JlCartcontroller());
  Get.put(JLCategoryController());
  Get.put(JlApiService());
  Get.put(JlPriceCalculationService());
  Get.put(JlPriceCalculationServices());
  Get.put(JlOrderController());
  Get.put(JlBottomNavController());

  ///...JS
  Get.put(JsApiService());
  Get.put(JsCartcontroller());
  Get.put(JsBottomNavController());
  Get.put(JsPriceCalculationServices());
  Get.put(JsEnquiryController());
  Get.put(JsOrderController());
  // Load token from storage
  await Get.find<AuthController>().loadTokenFromStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
      ),
      home: SplashScreen(),
    );
  }
}
