// // // lib/controllers/profile_controller.dart
// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:jitco_app/models/contact_model.dart';
// // import 'package:jitco_app/models/outlet_model.dart';
// // import 'package:jitco_app/services/api_service.dart';

// // class ProfileController extends GetxController {
// //   final ApiService apiService = Get.find<ApiService>();

// //   // Contacts
// //   var contacts = <ContactModel>[].obs;
// //   var contactsLoading = false.obs;
// //   var contactsError = ''.obs;
// //   var primaryContact = Rxn<ContactModel>();

// //   // Outlets
// //   var outlets = <OutletModel>[].obs;
// //   var outletsLoading = false.obs;
// //   var outletsError = ''.obs;

// //   // Selected for editing
// //   var selectedContact = Rxn<ContactModel>();
// //   var selectedOutlet = Rxn<OutletModel>();

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     loadUserData();
// //   }

// //   // Load all user data
// //   Future<void> loadUserData() async {
// //     await Future.wait([fetchContacts(), fetchOutlets()]);
// //   }

// //   // Fetch contacts from API

// //   // Future<void> fetchContacts() async {
// //   //   try {
// //   //     contactsLoading(true);
// //   //     contactsError('');
// //   //     final response = await apiService.getUserContact();
// //   //     if (response['success'] == true) {
// //   //       final List<dynamic> data = response['data'] ?? [];
// //   //       contacts.assignAll(data.map((e) => ContactModel.fromJson(e)).toList());
// //   //       // Find primary contact
// //   //       primaryContact.value = contacts.firstWhereOrNull(
// //   //         (contact) => contact.isPrimary == true,
// //   //       );
// //   //     } else {
// //   //       contactsError(response['message'] ?? 'Failed to load contacts');
// //   //     }
// //   //   } catch (e) {
// //   //     contactsError('Failed to load contacts: $e');
// //   //   } finally {
// //   //     contactsLoading(false);
// //   //   }
// //   // }

// //   Future<void> fetchContacts() async {
// //     try {
// //       print('📞 fetchContacts STARTED');
// //       contactsLoading(true);
// //       contactsError('');

// //       final response = await apiService.getUserContact();

// //       print('📞 API Response:');
// //       print('   Type: ${response.runtimeType}');
// //       print('   Keys: ${response.keys.join(', ')}');

// //       // Debug: Print the entire response
// //       print('📞 FULL RESPONSE STRUCTURE:');
// //       print('   ${jsonEncode(response)}');

// //       if (response['success'] == true) {
// //         // Try different possible data locations
// //         List<dynamic> data = [];

// //         if (response['data'] != null) {
// //           print('✅ Found data in response[\'data\']');
// //           data = response['data'] ?? [];
// //         } else if (response['contacts'] != null) {
// //           print('✅ Found data in response[\'contacts\']');
// //           data = response['contacts'] ?? [];
// //         } else {
// //           // Try to find any list in the response
// //           response.forEach((key, value) {
// //             if (value is List) {
// //               print('✅ Found list in response[\'$key\']');
// //               data = value;
// //             }
// //           });
// //         }

// //         print('📊 Data list length: ${data.length}');
// //         print('📊 Data list type: ${data.runtimeType}');

// //         if (data.isNotEmpty) {
// //           print('📋 First item structure:');
// //           print('   Type: ${data[0].runtimeType}');
// //           if (data[0] is Map) {
// //             print('   Keys in first item: ${(data[0] as Map).keys.join(', ')}');
// //             print('   First item values:');
// //             (data[0] as Map).forEach((key, value) {
// //               print('     $key: $value (${value.runtimeType})');
// //             });
// //           }
// //         }

// //         // Parse contacts
// //         final List<ContactModel> contactList = [];
// //         for (var item in data) {
// //           try {
// //             print('🔄 Parsing contact item: $item');
// //             final contact = ContactModel.fromJson(item);
// //             contactList.add(contact);
// //             print('✅ Parsed contact: ${contact.name}');
// //           } catch (e) {
// //             print('❌ Failed to parse contact: $e');
// //             print('   Item: $item');
// //           }
// //         }

// //         contacts.assignAll(contactList);
// //         print('✅ Total contacts parsed: ${contacts.length}');

// //         // Find primary contact
// //         final primary = contactList.firstWhereOrNull(
// //           (contact) => contact.isPrimary == true,
// //         );
// //         primaryContact.value = primary;
// //         print('✅ Primary contact: ${primary?.name ?? "None"}');
// //       } else {
// //         final errorMessage = response['message'] ?? 'Failed to load contacts';
// //         contactsError(errorMessage);
// //         print('❌ API returned error: $errorMessage');
// //       }
// //     } catch (e, stackTrace) {
// //       contactsError('Failed to load contacts: $e');
// //       print('❌ EXCEPTION in fetchContacts:');
// //       print('   Error: $e');
// //       print('   Stack: $stackTrace');
// //     } finally {
// //       contactsLoading(false);
// //       print('📞 fetchContacts COMPLETED');
// //     }
// //   }

// //   // Add/Update contact
// //   Future<bool> saveContact(
// //     ContactModel contact, {
// //     bool isUpdate = false,
// //   }) async {
// //     try {
// //       final Map<String, dynamic> response;

// //       if (isUpdate && contact.id != null) {
// //         // Update existing contact
// //         response = await apiService.updateUserContact(contact.toJson());
// //       } else {
// //         // Add new contact
// //         response = await apiService.postUserContact(contact.toJson());
// //       }

// //       if (response['success'] == true) {
// //         await fetchContacts(); // Refresh list
// //         Get.back();
// //         Get.snackbar(
// //           'Success',
// //           response['message'] ?? 'Contact saved successfully',
// //         );
// //         return true;
// //       } else {
// //         Get.snackbar('Error', response['message'] ?? 'Failed to save contact');
// //         return false;
// //       }
// //     } catch (e) {
// //       Get.snackbar('Error', 'Failed to save contact: $e');
// //       return false;
// //     }
// //   }

// //   // Delete contact
// //   Future<bool> deleteContact(String contactId) async {
// //     try {
// //       final response = await apiService.deleteUserContact(contactId);

// //       if (response['success'] == true) {
// //         contacts.removeWhere((contact) => contact.id == contactId);
// //         Get.snackbar('Success', 'Contact deleted successfully');
// //         return true;
// //       } else {
// //         Get.snackbar(
// //           'Error',
// //           response['message'] ?? 'Failed to delete contact',
// //         );
// //         return false;
// //       }
// //     } catch (e) {
// //       Get.snackbar('Error', 'Failed to delete contact: $e');
// //       return false;
// //     }
// //   }

// //   // Fetch outlets from API
// //   //working - fetching 3 outlets
// //   // Future<void> fetchOutlets() async {
// //   //   try {
// //   //     print('=== fetchOutlets START ===');
// //   //     outletsLoading(true);
// //   //     outletsError('');
// //   //     final response = await apiService.getUserOutlet();
// //   //     print('=== API RESPONSE ===');
// //   //     print('Full response: $response');
// //   //     print('Response keys: ${response.keys}');
// //   //     print('"success" value: ${response['success']}');
// //   //     print('"data" value type: ${response['data']?.runtimeType}');
// //   //     print('"data" value: ${response['data']}');
// //   //     // Check if success is true
// //   //     if (response['success'] == true) {
// //   //       print('✅ API call successful');
// //   //       // Get the data
// //   //       final data = response['data'] ?? [];
// //   //       print('📊 Data length: ${data.length}');
// //   //       if (data is List && data.isNotEmpty) {
// //   //         print('📋 First outlet item:');
// //   //         print(data[0]);
// //   //         // Parse outlets
// //   //         final List<OutletModel> outletList = [];
// //   //         for (var item in data) {
// //   //           try {
// //   //             print('🔄 Parsing outlet item...');
// //   //             final outlet = OutletModel.fromJson(item);
// //   //             outletList.add(outlet);
// //   //             print('✅ Parsed outlet: ${outlet.name}');
// //   //             print('  - Address: ${outlet.address}');
// //   //             print('  - State: ${outlet.state}');
// //   //             print('  - City: ${outlet.city}');
// //   //           } catch (e) {
// //   //             print('❌ Failed to parse outlet: $e');
// //   //             print('   Item: $item');
// //   //           }
// //   //         }
// //   //         outlets.assignAll(outletList);
// //   //         print('✅ Total outlets parsed: ${outlets.length}');
// //   //       } else {
// //   //         print('⚠️ No outlet data or data is not a list');
// //   //         outlets.assignAll([]);
// //   //       }
// //   //     } else {
// //   //       print('❌ API call failed');
// //   //       final errorMessage = response['message'] ?? 'Failed to load outlets';
// //   //       outletsError(errorMessage);
// //   //       print('Error message: $errorMessage');
// //   //     }
// //   //   } catch (e, stackTrace) {
// //   //     print('❌ EXCEPTION in fetchOutlets:');
// //   //     print('   Error: $e');
// //   //     print('   Stack: $stackTrace');
// //   //     outletsError('Failed to load outlets: $e');
// //   //   } finally {
// //   //     outletsLoading(false);
// //   //     print('=== fetchOutlets COMPLETED ===');
// //   //   }
// //   // }

// //   Future<void> fetchOutlets() async {
// //     try {
// //       print('=== fetchOutlets START ===');
// //       outletsLoading(true);
// //       outletsError('');

// //       final response = await apiService.getUserOutlet();

// //       print('=== API RESPONSE ===');
// //       print('Full response keys: ${response.keys}');
// //       print('"success" value: ${response['success']}');

// //       // Check if success is true
// //       if (response['success'] == true) {
// //         print('✅ API call successful');

// //         // Get the data
// //         final data = response['data'] ?? [];
// //         print('📊 Data type: ${data.runtimeType}');
// //         print('📊 Data length from API: ${data.length}');

// //         if (data is List && data.isNotEmpty) {
// //           print('=== ALL OUTLET DATA FROM API ===');
// //           for (int i = 0; i < data.length; i++) {
// //             print('Outlet ${i + 1}:');
// //             print(data[i]);
// //             print('---');
// //           }

// //           // Parse outlets
// //           final List<OutletModel> outletList = [];
// //           int successCount = 0;
// //           int errorCount = 0;

// //           for (var item in data) {
// //             try {
// //               print('🔄 Attempting to parse outlet item...');
// //               final outlet = OutletModel.fromJson(item);
// //               outletList.add(outlet);
// //               successCount++;
// //               print('✅ SUCCESS - Parsed outlet: ${outlet.name}');
// //               print('  - ID: ${outlet.id}');
// //               print('  - State: ${outlet.state}');
// //               print('  - City: ${outlet.city}');
// //               print('  - Address: ${outlet.address}');
// //             } catch (e, stackTrace) {
// //               errorCount++;
// //               print('❌ FAILED to parse outlet: $e');
// //               print('   Stack trace: $stackTrace');
// //               print('   Problematic item: $item');
// //             }
// //           }

// //           print('=== PARSING SUMMARY ===');
// //           print('Total items from API: ${data.length}');
// //           print('Successfully parsed: $successCount');
// //           print('Failed to parse: $errorCount');

// //           if (outletList.isNotEmpty) {
// //             outlets.assignAll(outletList);
// //             print('✅ Total outlets in controller: ${outlets.length}');

// //             // Verify the outlets are stored correctly
// //             print('=== VERIFYING OUTLETS IN CONTROLLER ===');
// //             for (int i = 0; i < outlets.length; i++) {
// //               print('Outlet ${i + 1} in controller:');
// //               print('  Name: ${outlets[i].name}');
// //               print('  ID: ${outlets[i].id}');
// //             }
// //           } else {
// //             print('⚠️ No outlets could be parsed');
// //             outlets.assignAll([]);
// //           }
// //         } else {
// //           print('⚠️ No outlet data or data is not a list');
// //           outlets.assignAll([]);
// //         }
// //       } else {
// //         print('❌ API call failed');
// //         final errorMessage = response['message'] ?? 'Failed to load outlets';
// //         outletsError(errorMessage);
// //       }
// //     } catch (e, stackTrace) {
// //       print('❌ EXCEPTION in fetchOutlets:');
// //       print('   Error: $e');
// //       print('   Stack: $stackTrace');
// //       outletsError('Failed to load outlets: $e');
// //     } finally {
// //       outletsLoading(false);
// //       print('=== fetchOutlets COMPLETED ===');
// //     }
// //   }

// //   // Add/Update outlet

// //   // Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
// //   //   try {
// //   //     final Map<String, dynamic> response;
// //   //     if (isUpdate && outlet.id != null) {
// //   //       // Update existing outlet
// //   //       response = await apiService.updateUserOutlet(outlet.toJson());
// //   //     } else {
// //   //       // Add new outlet
// //   //       response = await apiService.postUserOutlet(outlet.toJson());
// //   //     }
// //   //     if (response['success'] == true) {
// //   //       await fetchOutlets(); // Refresh list
// //   //       Get.back();
// //   //       Get.snackbar(
// //   //         'Success',
// //   //         response['message'] ?? 'Outlet saved successfully',
// //   //       );
// //   //       return true;
// //   //     } else {
// //   //       Get.snackbar('Error', response['message'] ?? 'Failed to save outlet');
// //   //       return false;
// //   //     }
// //   //   } catch (e) {
// //   //     Get.snackbar('Error', 'Failed to save outlet: $e');
// //   //     return false;
// //   //   }
// //   // }

// //   //PREVIOUSLY USE
// //   Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
// //     try {
// //       print('=== SAVE OUTLET METHOD START ===');
// //       print('Outlet to save:');
// //       print('- Name: ${outlet.name}');
// //       print('- Address: ${outlet.address}');
// //       print('- State: ${outlet.state}');
// //       print('- City: ${outlet.city}');
// //       print('- PinCode: ${outlet.pinCode}');
// //       print('- Is update: $isUpdate');
// //       print('- Outlet ID: ${outlet.id}');
// //       final Map<String, dynamic> response;
// //       final Map<String, dynamic> outletData = outlet.toJson();
// //       print('=== OUTLET DATA FOR API ===');
// //       print(outletData);
// //       if (isUpdate && outlet.id != null) {
// //         print('=== CALLING UPDATE API ===');
// //         print('Endpoint: customer/outlet/${outlet.id}');
// //         response = await apiService.updateUserOutlet(outletData);
// //       } else {
// //         // Remove ID for new outlets
// //         if (!isUpdate) {
// //           outletData.remove('id');
// //         }
// //         print('=== CALLING CREATE API ===');
// //         print('Endpoint: customer/outlet');
// //         print('Data being sent:');
// //         print(outletData);
// //         response = await apiService.postUserOutlet(outletData);
// //       }
// //       print('=== API RESPONSE ===');
// //       print('Response type: ${response.runtimeType}');
// //       print('Full response: $response');
// //       print('Success: ${response['success']}');
// //       print('Message: ${response['message']}');
// //       if (response['success'] == true) {
// //         print('✅ API call SUCCESSFUL');
// //         print('Response data: ${response['data']}');
// //         // Refresh outlets list
// //         print('Refreshing outlets list...');
// //         await fetchOutlets();
// //         // Navigate back
// //         print('Navigating back...');
// //         Get.back();
// //         // Show success message
// //         Get.snackbar(
// //           'Success',
// //           response['message'] ?? 'Outlet saved successfully',
// //           backgroundColor: Colors.green,
// //           colorText: Colors.white,
// //           snackPosition: SnackPosition.BOTTOM,
// //         );
// //         return true;
// //       } else {
// //         print('❌ API call FAILED');
// //         print('Error message: ${response['message']}');
// //         Get.snackbar(
// //           'Error',
// //           response['message'] ?? 'Failed to save outlet',
// //           backgroundColor: Colors.red,
// //           colorText: Colors.white,
// //           snackPosition: SnackPosition.BOTTOM,
// //         );
// //         return false;
// //       }
// //     } catch (e, stackTrace) {
// //       print('=== EXCEPTION IN SAVE OUTLET ===');
// //       print('Error type: ${e.runtimeType}');
// //       print('Error message: $e');
// //       print('Stack trace: $stackTrace');
// //       Get.snackbar(
// //         'Error',
// //         'Failed to save outlet: ${e.toString()}',
// //         backgroundColor: Colors.red,
// //         colorText: Colors.white,
// //         snackPosition: SnackPosition.BOTTOM,
// //       );
// //       return false;
// //     }
// //   }

// //   // Delete outlet
// //   Future<bool> deleteOutlet(String outletId) async {
// //     try {
// //       final response = await apiService.deleteUserOutlet(outletId);

// //       if (response['success'] == true) {
// //         outlets.removeWhere((outlet) => outlet.id == outletId);
// //         Get.snackbar('Success', 'Outlet deleted successfully');
// //         return true;
// //       } else {
// //         Get.snackbar('Error', response['message'] ?? 'Failed to delete outlet');
// //         return false;
// //       }
// //     } catch (e) {
// //       Get.snackbar('Error', 'Failed to delete outlet: $e');
// //       return false;
// //     }
// //   }

// //   // Clear selected items
// //   void clearSelection() {
// //     selectedContact.value = null;
// //     selectedOutlet.value = null;
// //   }
// // }

// // lib/controllers/profile_controller.dart
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/models/contact_model.dart';
// import 'package:jitco_app/models/outlet_model.dart';
// import 'package:jitco_app/services/api_service.dart';

// class ProfileController extends GetxController {
//   final ApiService apiService = Get.find<ApiService>();

//   // Contacts
//   var contacts = <ContactModel>[].obs;
//   var contactsLoading = false.obs;
//   var contactsError = ''.obs;
//   var primaryContact = Rxn<ContactModel>();

//   // Outlets
//   var outlets = <OutletModel>[].obs;
//   var outletsLoading = false.obs;
//   var outletsError = ''.obs;

//   // Selected for editing
//   var selectedContact = Rxn<ContactModel>();
//   var selectedOutlet = Rxn<OutletModel>();

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserData();
//   }

//   // Load all user data
//   Future<void> loadUserData() async {
//     await Future.wait([fetchContacts(), fetchOutlets()]);
//   }

//   // Fetch contacts from API
//   Future<void> fetchContacts() async {
//     try {
//       print('📞 fetchContacts STARTED');
//       contactsLoading(true);
//       contactsError('');

//       final response = await apiService.getUserContact();

//       print('📞 API Response:');
//       print('   Type: ${response.runtimeType}');
//       print('   Keys: ${response.keys.join(', ')}');

//       // Debug: Print the entire response
//       print('📞 FULL RESPONSE STRUCTURE:');
//       print('   ${jsonEncode(response)}');

//       if (response['success'] == true) {
//         // Try different possible data locations
//         List<dynamic> data = [];

//         if (response['data'] != null) {
//           print('✅ Found data in response[\'data\']');
//           data = response['data'] ?? [];
//         } else if (response['contacts'] != null) {
//           print('✅ Found data in response[\'contacts\']');
//           data = response['contacts'] ?? [];
//         } else {
//           // Try to find any list in the response
//           response.forEach((key, value) {
//             if (value is List) {
//               print('✅ Found list in response[\'$key\']');
//               data = value;
//             }
//           });
//         }

//         print('📊 Data list length: ${data.length}');
//         print('📊 Data list type: ${data.runtimeType}');

//         if (data.isNotEmpty) {
//           print('📋 First item structure:');
//           print('   Type: ${data[0].runtimeType}');
//           if (data[0] is Map) {
//             print('   Keys in first item: ${(data[0] as Map).keys.join(', ')}');
//             print('   First item values:');
//             (data[0] as Map).forEach((key, value) {
//               print('     $key: $value (${value.runtimeType})');
//             });
//           }
//         }

//         // Parse contacts
//         final List<ContactModel> contactList = [];
//         for (var item in data) {
//           try {
//             print('🔄 Parsing contact item: $item');
//             final contact = ContactModel.fromJson(item);
//             contactList.add(contact);
//             print('✅ Parsed contact: ${contact.name}');
//           } catch (e) {
//             print('❌ Failed to parse contact: $e');
//             print('   Item: $item');
//           }
//         }

//         contacts.assignAll(contactList);
//         print('✅ Total contacts parsed: ${contacts.length}');

//         // Find primary contact
//         final primary = contactList.firstWhereOrNull(
//           (contact) => contact.isPrimary == true,
//         );
//         primaryContact.value = primary;
//         print('✅ Primary contact: ${primary?.name ?? "None"}');
//       } else {
//         final errorMessage = response['message'] ?? 'Failed to load contacts';
//         contactsError(errorMessage);
//         print('❌ API returned error: $errorMessage');
//       }
//     } catch (e, stackTrace) {
//       contactsError('Failed to load contacts: $e');
//       print('❌ EXCEPTION in fetchContacts:');
//       print('   Error: $e');
//       print('   Stack: $stackTrace');
//     } finally {
//       contactsLoading(false);
//       print('📞 fetchContacts COMPLETED');
//     }
//   }

//   // Add/Update contact
//   Future<bool> saveContact(
//     ContactModel contact, {
//     bool isUpdate = false,
//   }) async {
//     try {
//       final Map<String, dynamic> response;

//       if (isUpdate && contact.id != null) {
//         // Update existing contact
//         response = await apiService.updateUserContact(contact.toJson());
//       } else {
//         // Add new contact
//         response = await apiService.postUserContact(contact.toJson());
//       }

//       if (response['success'] == true) {
//         await fetchContacts(); // Refresh list
//         Get.back();
//         Get.snackbar(
//           'Success',
//           response['message'] ?? 'Contact saved successfully',
//         );
//         return true;
//       } else {
//         Get.snackbar('Error', response['message'] ?? 'Failed to save contact');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to save contact: $e');
//       return false;
//     }
//   }

//   // Delete contact
//   Future<bool> deleteContact(String contactId) async {
//     try {
//       final response = await apiService.deleteUserContact(contactId);

//       if (response['success'] == true) {
//         contacts.removeWhere((contact) => contact.id == contactId);
//         Get.snackbar('Success', 'Contact deleted successfully');
//         return true;
//       } else {
//         Get.snackbar(
//           'Error',
//           response['message'] ?? 'Failed to delete contact',
//         );
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to delete contact: $e');
//       return false;
//     }
//   }

//   // Fetch outlets from API
//   // In ProfileController - Update fetchOutlets method to return List<OutletModel>
//   Future<List<OutletModel>> fetchOutlets() async {
//     try {
//       print('=== fetchOutlets START ===');
//       outletsLoading(true);
//       outletsError('');

//       final response = await apiService.getUserOutlet();

//       print('=== API RESPONSE ===');
//       print('Full response keys: ${response.keys}');
//       print('"success" value: ${response['success']}');

//       // Check if success is true
//       if (response['success'] == true) {
//         print('✅ API call successful');

//         // Get the data
//         final data = response['data'] ?? [];
//         print('📊 Data type: ${data.runtimeType}');
//         print('📊 Data length from API: ${data.length}');

//         if (data is List && data.isNotEmpty) {
//           print('=== ALL OUTLET DATA FROM API ===');
//           for (int i = 0; i < data.length; i++) {
//             print('Outlet ${i + 1}:');
//             print(data[i]);
//             print('---');
//           }

//           // Parse outlets
//           final List<OutletModel> outletList = [];
//           int successCount = 0;
//           int errorCount = 0;

//           for (var item in data) {
//             try {
//               print('🔄 Attempting to parse outlet item...');
//               final outlet = OutletModel.fromJson(item);
//               outletList.add(outlet);
//               successCount++;
//               print('✅ SUCCESS - Parsed outlet: ${outlet.name}');
//               print('  - ID: ${outlet.id}');
//               print('  - State: ${outlet.state}');
//               print('  - City: ${outlet.city}');
//               print('  - Address: ${outlet.address}');
//             } catch (e, stackTrace) {
//               errorCount++;
//               print('❌ FAILED to parse outlet: $e');
//               print('   Stack trace: $stackTrace');
//               print('   Problematic item: $item');
//             }
//           }

//           print('=== PARSING SUMMARY ===');
//           print('Total items from API: ${data.length}');
//           print('Successfully parsed: $successCount');
//           print('Failed to parse: $errorCount');

//           if (outletList.isNotEmpty) {
//             outlets.assignAll(outletList);
//             print('✅ Total outlets in controller: ${outlets.length}');

//             // Verify the outlets are stored correctly
//             print('=== VERIFYING OUTLETS IN CONTROLLER ===');
//             for (int i = 0; i < outlets.length; i++) {
//               print('Outlet ${i + 1} in controller:');
//               print('  Name: ${outlets[i].name}');
//               print('  ID: ${outlets[i].id}');
//             }

//             return outletList; // ADD THIS RETURN
//           } else {
//             print('⚠️ No outlets could be parsed');
//             outlets.assignAll([]);
//             return []; // ADD THIS RETURN
//           }
//         } else {
//           print('⚠️ No outlet data or data is not a list');
//           outlets.assignAll([]);
//           return []; // ADD THIS RETURN
//         }
//       } else {
//         print('❌ API call failed');
//         final errorMessage = response['message'] ?? 'Failed to load outlets';
//         outletsError(errorMessage);
//         return []; // ADD THIS RETURN
//       }
//     } catch (e, stackTrace) {
//       print('❌ EXCEPTION in fetchOutlets:');
//       print('   Error: $e');
//       print('   Stack: $stackTrace');
//       outletsError('Failed to load outlets: $e');
//       return []; // ADD THIS RETURN
//     } finally {
//       outletsLoading(false);
//       print('=== fetchOutlets COMPLETED ===');
//     }
//   }

//   // Also update the fetchOutletNames method:
//   Future<List<String>> fetchOutletNames() async {
//     try {
//       // Check if outlets are already loaded
//       if (outlets.isEmpty && !outletsLoading.value) {
//         final outletList = await fetchOutlets(); // Now returns value
//         return outletList.map((outlet) => outlet.name).toList();
//       } else {
//         // Extract outlet names from already loaded outlets
//         final outletNames = outlets.map((outlet) => outlet.name).toList();
//         print('🔄 Fetched ${outletNames.length} outlet names from cache');
//         return outletNames;
//       }
//     } catch (e) {
//       print('❌ Error fetching outlet names: $e');
//       return [];
//     }
//   }

//   // Save outlet method
//   Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
//     try {
//       print('=== SAVE OUTLET METHOD START ===');
//       print('Outlet to save:');
//       print('- Name: ${outlet.name}');
//       print('- Address: ${outlet.address}');
//       print('- State: ${outlet.state}');
//       print('- City: ${outlet.city}');
//       print('- PinCode: ${outlet.pinCode}');
//       print('- Is update: $isUpdate');
//       print('- Outlet ID: ${outlet.id}');
//       final Map<String, dynamic> response;
//       final Map<String, dynamic> outletData = outlet.toJson();
//       print('=== OUTLET DATA FOR API ===');
//       print(outletData);
//       if (isUpdate && outlet.id != null) {
//         print('=== CALLING UPDATE API ===');
//         print('Endpoint: customer/outlet/${outlet.id}');
//         response = await apiService.updateUserOutlet(outletData);
//       } else {
//         // Remove ID for new outlets
//         if (!isUpdate) {
//           outletData.remove('id');
//         }
//         print('=== CALLING CREATE API ===');
//         print('Endpoint: customer/outlet');
//         print('Data being sent:');
//         print(outletData);
//         response = await apiService.postUserOutlet(outletData);
//       }
//       print('=== API RESPONSE ===');
//       print('Response type: ${response.runtimeType}');
//       print('Full response: $response');
//       print('Success: ${response['success']}');
//       print('Message: ${response['message']}');
//       if (response['success'] == true) {
//         print('✅ API call SUCCESSFUL');
//         print('Response data: ${response['data']}');
//         // Refresh outlets list
//         print('Refreshing outlets list...');
//         await fetchOutlets();
//         // Navigate back
//         print('Navigating back...');
//         Get.back();
//         // Show success message
//         Get.snackbar(
//           'Success',
//           response['message'] ?? 'Outlet saved successfully',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return true;
//       } else {
//         print('❌ API call FAILED');
//         print('Error message: ${response['message']}');
//         Get.snackbar(
//           'Error',
//           response['message'] ?? 'Failed to save outlet',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }
//     } catch (e, stackTrace) {
//       print('=== EXCEPTION IN SAVE OUTLET ===');
//       print('Error type: ${e.runtimeType}');
//       print('Error message: $e');
//       print('Stack trace: $stackTrace');
//       Get.snackbar(
//         'Error',
//         'Failed to save outlet: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     }
//   }

//   // Delete outlet
//   Future<bool> deleteOutlet(String outletId) async {
//     try {
//       final response = await apiService.deleteUserOutlet(outletId);

//       if (response['success'] == true) {
//         outlets.removeWhere((outlet) => outlet.id == outletId);
//         Get.snackbar('Success', 'Outlet deleted successfully');
//         return true;
//       } else {
//         Get.snackbar('Error', response['message'] ?? 'Failed to delete outlet');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to delete outlet: $e');
//       return false;
//     }
//   }

//   // Get outlet by name
//   OutletModel? getOutletByName(String name) {
//     try {
//       return outlets.firstWhereOrNull((outlet) => outlet.name == name);
//     } catch (e) {
//       print('❌ Error getting outlet by name: $e');
//       return null;
//     }
//   }

//   // Clear selected items
//   void clearSelection() {
//     selectedContact.value = null;
//     selectedOutlet.value = null;
//   }
// }

// lib/controllers/profile_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/contact_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/state_city_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final ApiServices apiService = Get.find<ApiServices>();

  // Contacts
  var contacts = <ContactModel>[].obs;
  var contactsLoading = false.obs;
  var contactsError = ''.obs;
  var primaryContact = Rxn<ContactModel>();

  // Outlets
  var outlets = <OutletModel>[].obs;
  var outletsLoading = false.obs;
  var outletsError = ''.obs;

  // Selected for editing
  var selectedContact = Rxn<ContactModel>();
  var selectedOutlet = Rxn<OutletModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Load all user data
  Future<void> loadUserData() async {
    await Future.wait([fetchContacts(), fetchOutlets()]);
  }

  // // ✅ Add these to store state and city data for lookup
  // final List<StateModel> _statesList = [];
  // final List<CityModel> _citiesList = [];

  // // ✅ Method to set states (call this after fetching states)
  // void setStates(List<StateModel> states) {
  //   _statesList.clear();
  //   _statesList.addAll(states);
  // }

  // // ✅ Method to set cities (call this after fetching cities for a state)
  // void setCities(List<CityModel> cities) {
  //   _citiesList.clear();
  //   _citiesList.addAll(cities);
  // }

  // ✅ Get display name for state ID
  // String getStateName(String stateId) {
  //   if (stateId.isEmpty) return 'N/A';
  //   final state = _statesList.firstWhere(
  //     (s) => s.id.toString() == stateId,
  //     orElse: () => StateModel(id: -1, name: 'Unknown', cities: []),
  //   );
  //   return state.name;
  // }

  // // ✅ Get display name for city ID
  // String getCityName(String cityId) {
  //   if (cityId.isEmpty) return 'N/A';
  //   final city = _citiesList.firstWhere(
  //     (c) => c.id.toString() == cityId,
  //     orElse: () => CityModel(id: -1, name: 'Unknown'),
  //   );
  //   return city.name;
  // }

  // void updateOutletDisplayNames() {
  //   for (var outlet in outlets) {
  //     // This ensures the outlet model still has IDs, but we can get names
  //     print(
  //       'Outlet: ${outlet.name} - State ID: ${outlet.stateId}, City ID: ${outlet.cityId}',
  //     );
  //     print('State Name: ${getStateName(outlet.stateName!)}');
  //     print('City Name: ${getCityName(outlet.cityName!)}');
  //   }
  // }

  // Fetch contacts from API
  Future<void> fetchContacts() async {
    try {
      print('📞 fetchContacts STARTED');
      contactsLoading(true);
      contactsError('');

      final response = await apiService.getUserContact();

      print('📞 API Response:');
      print('   Type: ${response.runtimeType}');
      print('   Keys: ${response.keys.join(', ')}');

      // Debug: Print the entire response
      print('📞 FULL RESPONSE STRUCTURE:');
      print('   ${jsonEncode(response)}');

      if (response['success'] == true) {
        // Try different possible data locations
        List<dynamic> data = [];

        if (response['data'] != null) {
          print('✅ Found data in response[\'data\']');
          data = response['data'] ?? [];
        } else if (response['contacts'] != null) {
          print('✅ Found data in response[\'contacts\']');
          data = response['contacts'] ?? [];
        } else {
          // Try to find any list in the response
          response.forEach((key, value) {
            if (value is List) {
              print('✅ Found list in response[\'$key\']');
              data = value;
            }
          });
        }

        print('📊 Data list length: ${data.length}');
        print('📊 Data list type: ${data.runtimeType}');

        if (data.isNotEmpty) {
          print('📋 First item structure:');
          print('   Type: ${data[0].runtimeType}');
          if (data[0] is Map) {
            print('   Keys in first item: ${(data[0] as Map).keys.join(', ')}');
            print('   First item values:');
            (data[0] as Map).forEach((key, value) {
              print('     $key: $value (${value.runtimeType})');
            });
          }
        }

        // Parse contacts
        final List<ContactModel> contactList = [];
        for (var item in data) {
          try {
            print('🔄 Parsing contact item: $item');
            final contact = ContactModel.fromJson(item);
            contactList.add(contact);
            print('✅ Parsed contact: ${contact.name}');
          } catch (e) {
            print('❌ Failed to parse contact: $e');
            print('   Item: $item');
          }
        }

        contacts.assignAll(contactList);
        print('✅ Total contacts parsed: ${contacts.length}');

        // Find primary contact
        final primary = contactList.firstWhereOrNull(
          (contact) => contact.isPrimary == true,
        );
        primaryContact.value = primary;
        print('✅ Primary contact: ${primary?.name ?? "None"}');
      } else {
        final errorMessage = response['message'] ?? 'Failed to load contacts';
        contactsError(errorMessage);
        print('❌ API returned error: $errorMessage');
      }
    } catch (e, stackTrace) {
      contactsError('Failed to load contacts: $e');
      print('❌ EXCEPTION in fetchContacts:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
    } finally {
      contactsLoading(false);
      print('📞 fetchContacts COMPLETED');
    }
  }

  // Add/Update contact
  // Future<bool> saveContact(
  //   ContactModel contact, {
  //   bool isUpdate = false,
  // }) async {
  //   try {
  //     final Map<String, dynamic> response;

  //     if (isUpdate && contact.id != null) {
  //       // Update existing contact
  //       response = await apiService.updateUserContact(
  //         contact.toJson(),
  //         contactId: contact.id!,
  //       );
  //     } else {
  //       // Add new contact
  //       response = await apiService.postUserContact(contact.toJson());
  //     }

  //     if (response['success'] == true) {
  //       await fetchContacts(); // Refresh list
  //       Get.back();
  //       Get.snackbar(
  //         'Success',
  //         response['message'] ?? 'Contact saved successfully',
  //       );
  //       return true;
  //     } else {
  //       Get.snackbar('Error', response['message'] ?? 'Failed to save contact');
  //       return false;
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to save contact: $e');
  //     return false;
  //   }
  // }

  Future<bool> saveContact(
    ContactModel contact, {
    bool isUpdate = false,
  }) async {
    try {
      final Map<String, dynamic> response;

      print('💾 ========== SAVING CONTACT ==========');
      print('📝 Operation: ${isUpdate ? "UPDATE" : "CREATE"}');
      print('🔑 Contact ID: ${contact.id ?? "NULL"}');
      print('👤 Contact name: ${contact.name}');
      print('📱 Contact phone: ${contact.phone}');
      print('📧 Contact email: ${contact.email}');
      print('🏪 Contact outletId: ${contact.outletId ?? "NULL"}');
      print('🔄 Contact JSON to send:');

      final jsonToSend = contact.toJson();
      jsonToSend.forEach((key, value) {
        print('   $key: $value');
      });

      print('======================================');

      if (isUpdate && contact.id != null && contact.id!.isNotEmpty) {
        // Update existing contact
        print('🔄 Calling updateUserContact with ID: ${contact.id}');
        response = await apiService.updateUserContact(
          contact.toJson(),
          contactId: contact.id!,
        );

        print('✅ Update API Response:');
        print('   Success: ${response['success']}');
        print('   Message: ${response['message']}');
        print('   Data: ${response['data']}');
      } else {
        // Add new contact
        print('➕ Calling postUserContact...');
        response = await apiService.postUserContact(contact.toJson());

        print('✅ Create API Response:');
        print('   Success: ${response['success']}');
        print('   Message: ${response['message']}');
        print('   Data: ${response['data']}');
      }

      if (response['success'] == true) {
        print('🔄 Refreshing contacts list...');
        await fetchContacts();

        Get.back();
        Get.snackbar(
          'Success ✅',
          response['message'] ?? 'Contact saved successfully',
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error ❌',
          response['message'] ?? 'Failed to save contact',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print('❌❌❌ ERROR in saveContact:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');

      Get.snackbar(
        'Critical Error ⚠️',
        'Failed to save contact: ${e.toString()}',
        colorText: Colors.white,
        backgroundColor: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      return false;
    }
  }

  // Delete contact
  Future<bool> deleteContact(String contactId) async {
    try {
      final response = await apiService.deleteUserContact(contactId);

      if (response['success'] == true) {
        contacts.removeWhere((contact) => contact.id == contactId);
        Get.snackbar('Success', 'Contact deleted successfully');
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to delete contact',
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete contact: $e');
      return false;
    }
  }

  // Fetch outlets from API - returns List<OutletModel>
  Future<List<OutletModel>> fetchOutlets() async {
    try {
      print('=== fetchOutlets START ===');
      outletsLoading(true);
      outletsError('');

      final response = await apiService.getUserOutlet();

      print('=== API RESPONSE ===');
      print('Full response keys: ${response.keys}');
      print('"success" value: ${response['success']}');

      // Check if success is true
      if (response['success'] == true) {
        print('✅ API call successful');

        // Get the data
        final data = response['data'] ?? [];
        print('📊 Data type: ${data.runtimeType}');
        print('📊 Data length from API: ${data.length}');

        if (data is List && data.isNotEmpty) {
          print('=== ALL OUTLET DATA FROM API ===');
          for (int i = 0; i < data.length; i++) {
            print('Outlet ${i + 1}:');
            print(data[i]);
            print('---');
          }

          // Parse outlets
          final List<OutletModel> outletList = [];
          int successCount = 0;
          int errorCount = 0;

          for (var item in data) {
            try {
              print('🔄 Attempting to parse outlet item...');
              final outlet = OutletModel.fromJson(item);
              outletList.add(outlet);
              successCount++;
              print('✅ SUCCESS - Parsed outlet: ${outlet.name}');
              print('  - ID: ${outlet.id}');
              print('  - State: ${outlet.stateId}');
              print('  - City: ${outlet.cityId}');
              print('  - Address: ${outlet.address}');
            } catch (e, stackTrace) {
              errorCount++;
              print('❌ FAILED to parse outlet: $e');
              print('   Stack trace: $stackTrace');
              print('   Problematic item: $item');
            }
          }

          print('=== PARSING SUMMARY ===');
          print('Total items from API: ${data.length}');
          print('Successfully parsed: $successCount');
          print('Failed to parse: $errorCount');

          if (outletList.isNotEmpty) {
            outlets.assignAll(outletList);
            print('✅ Total outlets in controller: ${outlets.length}');

            // Verify the outlets are stored correctly
            print('=== VERIFYING OUTLETS IN CONTROLLER ===');
            for (int i = 0; i < outlets.length; i++) {
              print('Outlet ${i + 1} in controller:');
              print('  Name: ${outlets[i].name}');
              print('  ID: ${outlets[i].id}');
            }

            return outletList;
          } else {
            print('⚠️ No outlets could be parsed');
            outlets.assignAll([]);
            return [];
          }
        } else {
          print('⚠️ No outlet data or data is not a list');
          outlets.assignAll([]);
          return [];
        }
      } else {
        print('❌ API call failed');
        final errorMessage = response['message'] ?? 'Failed to load outlets';
        outletsError(errorMessage);
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in fetchOutlets:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
      outletsError('Failed to load outlets: $e');
      return [];
    } finally {
      outletsLoading(false);
      print('=== fetchOutlets COMPLETED ===');
    }
  }

  // ✅ ADD THIS METHOD: Get outlets list
  Future<List<OutletModel>> getOutletsList() async {
    try {
      // If outlets are already loaded, return them
      if (outlets.isNotEmpty) {
        print('📦 Returning ${outlets.length} cached outlets');
        return outlets.toList();
      }

      // Otherwise fetch and return
      print('📦 Fetching outlets...');
      return await fetchOutlets();
    } catch (e) {
      print('❌ Error in getOutletsList: $e');
      return [];
    }
  }

  // ✅ ADD THIS METHOD: Get outlets as list of maps with id and name
  Future<List<Map<String, dynamic>>> getOutletsWithIds() async {
    try {
      final outletList = await getOutletsList();
      return outletList
          .map((outlet) => {'id': outlet.id, 'name': outlet.name})
          .toList();
    } catch (e) {
      print('❌ Error getting outlets with IDs: $e');
      return [];
    }
  }

  // ✅ UPDATE THIS METHOD: Get outlet names for dropdown
  Future<List<String>> fetchOutletNames() async {
    try {
      final outletList = await getOutletsList();
      return outletList.map((outlet) => outlet.name).toList();
    } catch (e) {
      print('❌ Error fetching outlet names: $e');
      return [];
    }
  }

  // Get outlet by ID
  OutletModel? getOutletById(String id) {
    try {
      return outlets.firstWhereOrNull((outlet) => outlet.id == id);
    } catch (e) {
      print('❌ Error getting outlet by ID: $e');
      return null;
    }
  }

  // Get outlet by name
  OutletModel? getOutletByName(String name) {
    try {
      return outlets.firstWhereOrNull((outlet) => outlet.name == name);
    } catch (e) {
      print('❌ Error getting outlet by name: $e');
      return null;
    }
  }

  // Save outlet method
  // Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
  //   try {
  //     print('=== SAVE OUTLET METHOD START ===');
  //     print('Outlet to save:');
  //     print('- Name: ${outlet.name}');
  //     print('- Address: ${outlet.address}');
  //     print('- State: ${outlet.state}');
  //     print('- City: ${outlet.city}');
  //     print('- PinCode: ${outlet.pinCode}');
  //     print('- Is update: $isUpdate');
  //     print('- Outlet ID: ${outlet.id}');
  //     final Map<String, dynamic> response;
  //     final Map<String, dynamic> outletData = outlet.toJson();
  //     print('=== OUTLET DATA FOR API ===');
  //     print(outletData);
  //     if (isUpdate && outlet.id != null) {
  //       print('=== CALLING UPDATE API ===');
  //       print('Endpoint: customer/outlet/${outlet.id}');
  //       // ✅ Check what parameters updateUserOutlet expects
  //       // Option 1: If it expects (outletId, outletData)
  //       response = await apiService.updateUserOutlet(outlet.id!, outletData);
  //       // Option 2: If it expects (outletData) and uses outlet.id internally
  //       // response = await apiService.updateUserOutlet(outletData);
  //     } else {
  //       // Remove ID for new outlets
  //       if (!isUpdate) {
  //         outletData.remove('id');
  //         outletData.remove('_id'); // Also remove _id for new outlets
  //       }
  //       print('=== CALLING CREATE API ===');
  //       print('Endpoint: customer/outlet');
  //       print('Data being sent:');
  //       print(outletData);
  //       response = await apiService.postUserOutlet(outletData);
  //     }
  //     print('=== API RESPONSE ===');
  //     print('Response type: ${response.runtimeType}');
  //     print('Full response: $response');
  //     print('Success: ${response['success']}');
  //     print('Message: ${response['message']}');
  //     if (response['success'] == true) {
  //       print('✅ API call SUCCESSFUL');
  //       print('Response data: ${response['data']}');
  //       // Refresh outlets list
  //       print('Refreshing outlets list...');
  //       await fetchOutlets();
  //       // Navigate back
  //       print('Navigating back...');
  //       Get.back();
  //       // Show success message
  //       Get.snackbar(
  //         'Success',
  //         response['message'] ?? 'Outlet saved successfully',
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return true;
  //     } else {
  //       print('❌ API call FAILED');
  //       print('Error message: ${response['message']}');
  //       Get.snackbar(
  //         'Error',
  //         response['message'] ?? 'Failed to save outlet',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return false;
  //     }
  //   } catch (e, stackTrace) {
  //     print('=== EXCEPTION IN SAVE OUTLET ===');
  //     print('Error type: ${e.runtimeType}');
  //     print('Error message: $e');
  //     print('Stack trace: $stackTrace');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to save outlet: ${e.toString()}',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return false;
  //   }
  // }

  // Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
  //   try {
  //     print('=== SAVE OUTLET METHOD START ===');
  //     print('Outlet to save:');
  //     print('- Name: ${outlet.name}');
  //     print('- Address: ${outlet.address}');
  //     print('- State: ${outlet.state}');
  //     print('- City: ${outlet.city}');
  //     print('- PinCode: ${outlet.pinCode}');
  //     print('- Is update: $isUpdate');
  //     print('- Outlet ID: ${outlet.id}');
  //     print('- Outlet ID is null: ${outlet.id == null}');
  //     print('- Outlet ID is empty: ${outlet.id?.isEmpty ?? true}');
  //     final Map<String, dynamic> response;
  //     final Map<String, dynamic> outletData = outlet.toJson();
  //     print('=== OUTLET DATA FOR API ===');
  //     print('Keys: ${outletData.keys}');
  //     print('Data: $outletData');
  //     // ✅ CRITICAL: Check which branch we're going into
  //     if (isUpdate && outlet.id != null && outlet.id!.isNotEmpty) {
  //       print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
  //       print('✅ GOING INTO UPDATE BRANCH');
  //       print('✅ Outlet ID: ${outlet.id}');
  //       print('✅ isUpdate: $isUpdate');
  //       print('✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅');
  //       print('=== CALLING UPDATE API ===');
  //       print('Endpoint: customer/outlet/${outlet.id}');
  //       response = await apiService.updateUserOutlet(outlet.id!, outletData);
  //     } else {
  //       print('🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕');
  //       print('🆕 GOING INTO CREATE BRANCH');
  //       print('🆕 Reason:');
  //       print('🆕 - isUpdate: $isUpdate');
  //       print('🆕 - outlet.id: ${outlet.id}');
  //       print('🆕 - outlet.id == null: ${outlet.id == null}');
  //       print('🆕 - outlet.id?.isEmpty: ${outlet.id?.isEmpty ?? true}');
  //       print('🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕🆕');
  //       // Remove ID for new outlets
  //       if (!isUpdate) {
  //         outletData.remove('id');
  //         outletData.remove('_id');
  //       }
  //       print('=== CALLING CREATE API ===');
  //       print('Endpoint: customer/outlet');
  //       print('Data being sent:');
  //       print(outletData);
  //       response = await apiService.postUserOutlet(outletData);
  //     }
  //     print('=== API RESPONSE ===');
  //     print('Response type: ${response.runtimeType}');
  //     print('Full response: $response');
  //     print('Success: ${response['success']}');
  //     print('Message: ${response['message']}');
  //     if (response['success'] == true) {
  //       print('✅ API call SUCCESSFUL');
  //       print('Response data: ${response['data']}');
  //       // Refresh outlets list
  //       print('Refreshing outlets list...');
  //       await fetchOutlets();
  //       // Navigate back
  //       print('Navigating back...');
  //       Get.back(result: true);
  //       // Show success message
  //       Future.delayed(Duration(milliseconds: 100), () {
  //         Get.snackbar(
  //           'Success',
  //           response['message'] ?? 'Outlet saved successfully',
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //           snackPosition: SnackPosition.BOTTOM,
  //         );
  //       });
  //       return true;
  //     } else {
  //       print('❌ API call FAILED');
  //       print('Error message: ${response['message']}');
  //       Get.snackbar(
  //         'Error',
  //         response['message'] ?? 'Failed to save outlet',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return false;
  //     }
  //   } catch (e, stackTrace) {
  //     print('=== EXCEPTION IN SAVE OUTLET ===');
  //     print('Error type: ${e.runtimeType}');
  //     print('Error message: $e');
  //     print('Stack trace: $stackTrace');
  //     Get.snackbar(
  //       'Error',
  //       'Failed to save outlet: ${e.toString()}',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return false;
  //   }
  // }

  Future<bool> saveOutlet(OutletModel outlet, {bool isUpdate = false}) async {
    try {
      print('=== SAVE OUTLET METHOD START ===');
      print('Outlet to save:');
      print('- Name: ${outlet.name}');
      print('- Address: ${outlet.address}');
      print('- State: ${outlet.stateId}');
      print('- City: ${outlet.cityId}');
      print('- PinCode: ${outlet.pinCode}');
      print('- Is update: $isUpdate');
      print('- Outlet ID: ${outlet.id}');

      final Map<String, dynamic> response;
      Map<String, dynamic> outletData = outlet.toJson();

      // ✅ CRITICAL: Get company ID from AuthController
      try {
        final authController = Get.find<AuthController>();

        // Print auth controller state for debugging
        print('🔍 AuthController State:');
        print('   - isLoggedIn: ${authController.isLoggedIn.value}');
        print(
          '   - has companyId: ${authController.companyId.value.isNotEmpty}',
        );
        print('   - companyId: ${authController.companyId.value}');
        print('   - customerId: ${authController.customerId.value}');
        print('   - companyName: ${authController.companyName.value}');

        // Get company ID from auth controller
        final String companyId = authController.companyId.value;

        if (companyId.isNotEmpty) {
          outletData['company'] = companyId;
          print('✅ Added company to outletData: $companyId');

          // Also add customer_id if available
          final String customerId = authController.customerId.value;
          if (customerId.isNotEmpty) {
            outletData['customer_id'] = customerId;
            print('✅ Added customer_id to outletData: $customerId');
          }
        } else {
          print('⚠️ Warning: companyId is empty in AuthController');

          // Try to get from SharedPreferences as fallback
          final prefs = await SharedPreferences.getInstance();
          final savedCompanyId = prefs.getString('company_id') ?? '';
          if (savedCompanyId.isNotEmpty) {
            outletData['company'] = savedCompanyId;
            print('✅ Got company from SharedPreferences: $savedCompanyId');
          } else {
            print('❌ CRITICAL: No company ID found anywhere!');
          }
        }
      } catch (e) {
        print('Error getting company ID: $e');
      }

      print('=== OUTLET DATA FOR API ===');
      print('Keys: ${outletData.keys}');
      print('Data: $outletData');

      // Check if we have company field (REQUIRED by API)
      if (!outletData.containsKey('company')) {
        print('❌ CRITICAL: Company field missing from API payload!');
        print('❌ The API requires: company: "company_id_here"');
        print('❌ Available auth data:');
        print(
          '   - AuthController.companyId: ${Get.find<AuthController>().companyId.value}',
        );

        // Show error and don't proceed
        Get.snackbar(
          'Error',
          'Company information missing. Cannot save outlet.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Check which branch we're going into
      if (isUpdate && outlet.id != null && outlet.id!.isNotEmpty) {
        print('✅ GOING INTO UPDATE BRANCH');
        print('Endpoint: customer/outlet/${outlet.id}');

        // Log the exact request
        print('🌐 API Request: PATCH /customer/outlet/${outlet.id}');
        print('📦 Request Data: $outletData');

        response = await apiService.updateUserOutlet(outlet.id!, outletData);
      } else {
        print('🆕 GOING INTO CREATE BRANCH');

        // Remove ID for new outlets
        if (!isUpdate) {
          outletData.remove('id');
          outletData.remove('_id');
        }

        print('=== CALLING CREATE API ===');
        print('Endpoint: customer/outlet');
        print('Data being sent:');
        print(outletData);

        response = await apiService.postUserOutlet(outletData);
      }

      print('=== API RESPONSE ===');
      print('Full response: $response');
      print('Success: ${response['success']}');

      if (response['success'] == true) {
        print('✅ API call SUCCESSFUL');

        // Refresh outlets list
        await fetchOutlets();

        // Navigate back
        Get.back(result: true);

        // Show success message
        Future.delayed(Duration(milliseconds: 100), () {
          Get.snackbar(
            'Success',
            response['message'] ?? 'Outlet saved successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        });

        return true;
      } else {
        print('❌ API call FAILED');
        print('Error message: ${response['message']}');

        // Check if error is due to missing company field
        final errorMessage =
            response['message']?.toString().toLowerCase() ?? '';
        if (errorMessage.contains('company') ||
            errorMessage.contains('not authorized') ||
            errorMessage.contains('authentication')) {
          print('❌ ERROR LIKELY DUE TO MISSING/INVALID COMPANY FIELD');
          Get.snackbar(
            'Authentication Error',
            'Your session may have expired. Please try logging out and back in.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            response['message'] ?? 'Failed to save outlet',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        return false;
      }
    } catch (e, stackTrace) {
      print('=== EXCEPTION IN SAVE OUTLET ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to save outlet: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    }
  }

  // Delete outlet
  Future<bool> deleteOutlet(String outletId) async {
    try {
      final response = await apiService.deleteUserOutlet(outletId);

      if (response['success'] == true) {
        outlets.removeWhere((outlet) => outlet.id == outletId);
        Get.snackbar('Success', 'Outlet deleted successfully');
        return true;
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to delete outlet');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete outlet: $e');
      return false;
    }
  }

  // Clear selected items
  void clearSelection() {
    selectedContact.value = null;
    selectedOutlet.value = null;
  }
}
