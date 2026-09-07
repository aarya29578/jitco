// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/enquiry_model.dart';
// import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
// import 'package:jitco_app/JItco_Main/Bmain/C_JitLiquor/Services/JL_api_service.dart';
// import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_enquiry_model.dart';
// import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';

// class JsEnquiryController extends GetxController {
//   var jlEnquiryItems = <JsEnquiryModel>[].obs;
//   var isLoading = false.obs;
//   var hasError = false.obs;
//   String errorMessage = '';

//   int currentPage = 1;
//   int totalPages = 1;
//   int totalProducts = 0;
//   var hasMore = true.obs;

//   final JsApiService _apiService = Get.find<JsApiService>();

//   @override
//   void onInit() {
//     super.onInit();
//     fetchEnquiries();
//   }

//   Future<void> fetchEnquiries({bool loadMore = false}) async {
//     try {
//       if (!loadMore) {
//         isLoading.value = true;
//         currentPage = 1;
//         hasError.value = false;
//       }

//       final response = await _apiService.getEnqueryData(
//         page: currentPage,
//         limit: 10,
//       );

//       if (response['status'] == 'success') {
//         // final List<dynamic> enquiryData = response['data'] ?? [];

//         // final List<EnquiryModel> enquiries = enquiryData.map((data) {
//         //   return EnquiryModel.fromJson(data);
//         // }).toList();

//         final List<dynamic> enquiryData = response['data'] ?? [];

//         //Filter out null items first
//         final List<Map<String, dynamic>> validData = enquiryData
//             .where((item) => item != null)
//             .cast<Map<String, dynamic>>()
//             .toList();

//         //Convert only valid maps to models
//         final List<JsEnquiryModel> enquiries = validData
//             .map((json) => JsEnquiryModel.fromJson(json))
//             .toList();

//         if (loadMore) {
//           jlEnquiryItems.addAll(enquiries);
//         } else {
//           jlEnquiryItems.value = enquiries;
//         }

//         totalPages = response['totalPages'] ?? 1;
//         totalProducts = response['totalProducts'] ?? 0;
//         currentPage = response['page'] ?? 1;
//         hasMore.value = currentPage < totalPages;

//         print('Fetched ${enquiries.length} enquiries, Total: $totalProducts');
//       } else {
//         throw Exception('Failed to fetch enquiries');
//       }
//     } catch (e) {
//       print('Error fetching enquiries: $e');
//       hasError.value = true;
//       errorMessage = e.toString();

//       if (!loadMore) {
//         jlEnquiryItems.clear();
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> createEnquiry(
//     context,
//     String productId,
//     int quantity,
//     String? comments,
//     // String? phoneNumber,
//     // String? emailId,
//     // String? jobTitle,
//     // String? selectedState,
//     // String? selectedCity,
//   ) async {
//     try {
//       isLoading.value = true;
//       hasError.value = false;

//       final response = await _apiService.postEnqueryData(
//         productId,
//         quantity,
//         comments,
//         // phoneNumber,
//         // emailId,
//         // jobTitle,
//         // selectedState,
//         // selectedCity,
//       );

//       final statusCode = response['error']?['statusCode'];

//       if (response['status'] == 'success') {
//         // Refresh the list to show the new enquiry
//         await fetchEnquiries();

//         // Get.snackbar(
//         //   'Success',
//         //   'Enquiry created successfully',
//         //   snackPosition: SnackPosition.BOTTOM,
//         //   backgroundColor: Colors.green,
//         //   colorText: Colors.white,
//         // );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Enquiry created successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else if (response['status'] == 'error' && statusCode == 400 ||
//           statusCode == '400') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response['message']),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         throw Exception(response['message'] ?? 'Failed to create enquiry');
//       }
//     } catch (e) {
//       print('Error creating enquiry: $e');
//       hasError.value = true;
//       errorMessage = e.toString();

//       // Get.snackbar(
//       //   'Error',
//       //   'Failed to create enquiry: ${e.toString()}',
//       //   snackPosition: SnackPosition.BOTTOM,
//       //   backgroundColor: Colors.red,
//       //   colorText: Colors.white,
//       // );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to create enquiry:'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadMoreEnquiries() async {
//     if (hasMore.value && !isLoading.value) {
//       currentPage++;
//       await fetchEnquiries(loadMore: true);
//     }
//   }

//   Future<void> refreshEnquiries() async {
//     await fetchEnquiries();
//   }

//   // Group enquiries by date
//   Map<String, List<JsEnquiryModel>> getEnquiriesByDate() {
//     final Map<String, List<JsEnquiryModel>> grouped = {};

//     for (final enquiry in jlEnquiryItems) {
//       // Assuming you have createdAt date in the model
//       // You might need to parse the date and format it
//       final date = _formatDate(enquiry.createdAt ?? DateTime.now().toString());
//       if (!grouped.containsKey(date)) {
//         grouped[date] = [];
//       }
//       grouped[date]!.add(enquiry);
//     }

//     return grouped;
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${_getWeekday(date)}, ${date.day} ${_getMonth(date)}, ${date.year}';
//     } catch (e) {
//       return 'Unknown Date';
//     }
//   }

//   String _getWeekday(DateTime date) {
//     final weekdays = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday',
//     ];
//     return weekdays[date.weekday - 1];
//   }

//   String _getMonth(DateTime date) {
//     final months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return months[date.month - 1];
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/models/JS_enquiry_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/D_JitService/services/JS_api_service.dart';

class JsEnquiryController extends GetxController {
  var jlEnquiryItems = <JsEnquiryModel>[].obs;

  var isLoading = false.obs;
  var hasError = false.obs;
  var hasMore = true.obs;

  String errorMessage = '';

  int currentPage = 1;
  int totalPages = 1;
  int totalProducts = 0;

  final JsApiService _apiService = Get.find<JsApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchEnquiries();
  }

  /// ✅ FETCH ENQUIRIES
  Future<void> fetchEnquiries({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        hasError.value = false;
        currentPage = 1;
        hasMore.value = true;
      }

      final response = await _apiService.getEnqueryData(
        page: currentPage,
        limit: 10,
      );

      final status = response['status'];
      final success = response['success'];
      final bool isSuccess = (status == 'success' || success == true);
      
      final message = isSuccess
          ? response['message'] ?? 'Successfully fetched enquiries'
          : response['message'] ?? 'Failed to load enquiries';

      if (isSuccess) {
        final List<dynamic> enquiryData = response['data'] ?? [];

        final List<JsEnquiryModel> enquiries = enquiryData
            .where((item) => item != null)
            .map((json) => JsEnquiryModel.fromJson(json))
            .toList();

        if (loadMore) {
          jlEnquiryItems.addAll(enquiries);
        } else {
          jlEnquiryItems.value = enquiries;
        }

        totalPages = response['totalPages'] ?? 1;
        totalProducts = response['totalProducts'] ?? 0;
        currentPage = response['page'] ?? 1;

        /// ✅ Stop pagination when API returns empty list
        if (enquiries.isEmpty) {
          hasMore.value = false;
        } else {
          hasMore.value = currentPage < totalPages;
        }
      } else {
        hasError.value = true;
        errorMessage = message;

        if (!loadMore) {
          jlEnquiryItems.clear();
        }
      }
    } catch (e) {
      print('Fetch Enquiry Error: $e');

      hasError.value = true;
      errorMessage = 'Network error occurred';

      if (!loadMore) {
        jlEnquiryItems.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ LOAD MORE
  Future<void> loadMoreEnquiries() async {
    if (!hasMore.value || isLoading.value) return;

    currentPage++;
    await fetchEnquiries(loadMore: true);
  }

  /// ✅ REFRESH
  Future<void> refreshEnquiries() async {
    await fetchEnquiries();
  }

  /// ✅ CREATE ENQUIRY
  Future<void> createEnquiry(
    BuildContext context,
    String productId,
    int quantity,
    String? comments,
  ) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await _apiService.postEnqueryData(
        productId,
        quantity,
        comments,
      );

      final status = response['status'];
      final success = response['success'];
      
      final bool isSuccess = (status == 'success' || success == true);
      final message = isSuccess
          ? response['message'] ?? 'Successfully added to enquiry'
          : response['message'] ?? 'Something went wrong';

      print('Create Enquiry Response: $response');
      print('Is Success: $isSuccess');

      if (isSuccess) {
        try {
          await fetchEnquiries();
        } catch (refreshError) {
          print('Error refreshing enquiries after success: $refreshError');
          // Don't show error to user if the creation itself succeeded
        }
        _showMessage(context, message, Colors.green);
      } else {
        _showMessage(context, message, Colors.red);
      }
    } catch (e) {
      print('Create Enquiry Crash: $e');

      hasError.value = true;
      errorMessage = 'Failed to create enquiry. ${e.toString()}';

      _showMessage(context, errorMessage, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ SNACKBAR
  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  /// ✅ GROUP BY DATE
  Map<String, List<JsEnquiryModel>> getEnquiriesByDate() {
    final Map<String, List<JsEnquiryModel>> grouped = {};

    for (final enquiry in jlEnquiryItems) {
      final date = _formatDate(enquiry.createdAt ?? DateTime.now().toString());

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(enquiry);
    }

    return grouped;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${_getWeekday(date)}, ${date.day} ${_getMonth(date)}, ${date.year}';
    } catch (e) {
      return 'Unknown Date';
    }
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }
}
