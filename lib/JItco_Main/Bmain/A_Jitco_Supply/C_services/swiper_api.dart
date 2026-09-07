// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/ads.dart';

// class SliderApiService {
//   static Future<List<Ads>> getSliderAds() async {
//     final url = Uri.parse(
//       "https://api.jitco.in/api/v1/public/ads?source=Jitco",
//     );

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = advertise.fromJson(jsonDecode(response.body));
//       return data.ads ?? [];
//     } else {
//       throw Exception("Failed to load ads");
//     }
//   }
// }
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/ads.dart';
import 'package:jitco_app/JItco_Main/Bmain/Constants/constants.dart';

class SliderApiService {
  static Future<List<Ads>> getSliderAds() async {
    final url = Uri.parse("$jitUrl/public/ads?source=Jitco");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = Advertise.fromJson(jsonDecode(response.body));
      return data.ads ?? [];
    } else {
      throw Exception("Failed to load ads");
    }
  }
}
