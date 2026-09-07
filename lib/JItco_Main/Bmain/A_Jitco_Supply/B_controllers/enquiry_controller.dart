import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/enquiry_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';

class EnquiryController extends GetxController {
  var enquiryItems = <EnquiryModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  String errorMessage = '';

  int currentPage = 1;
  int totalPages = 1;
  int totalProducts = 0;
  var hasMore = true.obs;

  final ApiServices _apiService = Get.find<ApiServices>();

  @override
  void onInit() {
    super.onInit();
    fetchEnquiries();
  }

  Future<void> fetchEnquiries({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage = 1;
        hasError.value = false;
      }

      final response = await _apiService.getEnqueryData(
        page: currentPage,
        limit: 10,
      );

      if (response['status'] == 'success') {
        // final List<dynamic> enquiryData = response['data'] ?? [];

        // final List<EnquiryModel> enquiries = enquiryData.map((data) {
        //   return EnquiryModel.fromJson(data);
        // }).toList();

        final List<dynamic> enquiryData = response['data'] ?? [];

        //Filter out null items first
        final List<Map<String, dynamic>> validData = enquiryData
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .toList();

        //Convert only valid maps to models
        final List<EnquiryModel> enquiries = validData
            .map((json) => EnquiryModel.fromJson(json))
            .toList();

        if (loadMore) {
          enquiryItems.addAll(enquiries);
        } else {
          enquiryItems.value = enquiries;
        }

        totalPages = response['totalPages'] ?? 1;
        totalProducts = response['totalProducts'] ?? 0;
        currentPage = response['page'] ?? 1;
        hasMore.value = currentPage < totalPages;

        print('Fetched ${enquiries.length} enquiries, Total: $totalProducts');
      } else {
        throw Exception('Failed to fetch enquiries');
      }
    } catch (e) {
      print('Error fetching enquiries: $e');
      hasError.value = true;
      errorMessage = e.toString();

      if (!loadMore) {
        enquiryItems.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> createEnquiry(
  //   String productId,
  //   int quantity,
  //   String? comments,
  // ) async {
  //   try {
  //     isLoading.value = true;
  //     hasError.value = false;

  //     final response = await _apiService.postEnqueryData(
  //       productId,
  //       quantity,
  //       comments,
  //     );

  //     if (response['status'] == 'success') {
  //       // Refresh the list to show the new enquiry
  //       await fetchEnquiries();

  //       Get.snackbar(
  //         'Success',
  //         'Enquiry created successfully',
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       throw Exception('Failed to create enquiry');
  //     }
  //   } catch (e) {
  //     print('Error creating enquiry: $e');
  //     hasError.value = true;
  //     errorMessage = e.toString();

  //     Get.snackbar(
  //       'Error',
  //       'Failed to create enquiry: ${e.toString()}',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> createEnquiry(
    context,
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

      if (isSuccess) {
        try {
          await fetchEnquiries();
        } catch (refreshError) {
          print('Error refreshing enquiries after success: $refreshError');
        }
        _showMessage(context, message, Colors.green);
      } else {
        _showMessage(context, message, Colors.red);
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Crash Error creating enquiry: $e');

      hasError.value = true;

      Get.snackbar(
        'Error',
        'Unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreEnquiries() async {
    if (hasMore.value && !isLoading.value) {
      currentPage++;
      await fetchEnquiries(loadMore: true);
    }
  }

  Future<void> refreshEnquiries() async {
    await fetchEnquiries();
  }

  // Group enquiries by date
  Map<String, List<EnquiryModel>> getEnquiriesByDate() {
    final Map<String, List<EnquiryModel>> grouped = {};

    for (final enquiry in enquiryItems) {
      // Assuming you have createdAt date in the model
      // You might need to parse the date and format it
      final date = _formatDate(enquiry.createdAt ?? DateTime.now().toString());
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
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
    final weekdays = [
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
    final months = [
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
