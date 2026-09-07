import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Services/api.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/enquiry_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';

class JmEnquiryController extends GetxController {
  var enquiryItems = <EnquiryModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  String errorMessage = '';

  int currentPage = 1;
  int totalPages = 1;
  int totalProducts = 0;
  var hasMore = true.obs;

  final JMApiService _apiService = Get.find<JMApiService>();

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

      final response = await _apiService.getEnqueryMenuData(
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

  /// ✅ SNACKBAR
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
        comments ?? "",
      );
      final status = response['status'];
      final success = response['success'];
      final bool isSuccess = (status == 'success' || success == true);

      final message = isSuccess
          ? response['message'] ?? 'Successfully added to enquiry'
          : response['message'] ?? 'Something went wrong';

      print('JM Create Enquiry Response: $response');

      if (isSuccess) {
        try {
          await fetchEnquiries();
        } catch (refreshError) {
          print('Error refreshing enquiries after success: $refreshError');
        }
        _showMessage(context, message, Colors.green);
      } else {
        _showMessage(context, message, Colors.red);
      }
    } catch (e) {
      print('Error creating enquiry: $e');
      hasError.value = true;
      errorMessage = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create enquiry: $e'),
          backgroundColor: Colors.red,
        ),
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
