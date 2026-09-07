
// // ******************************NEW***************************
// import 'package:flutter/material.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/instance_manager.dart';
// import 'package:intl/intl.dart';
// import 'package:jitco_app/controllers/auth_controllers.dart';
// import 'package:jitco_app/controllers/profile_controller.dart';
// import 'package:jitco_app/models/outlet_model.dart';
// import 'package:jitco_app/models/state_city_model.dart';
// import 'package:jitco_app/screens/Authentication/login.dart';
// import 'package:jitco_app/screens/Home/A_Home%20and%20Drawer/Home_Drawer/drawer_screens/C_Profile_Settings/reusable_date_picker/custom_date_picker.dart';
// import 'package:jitco_app/services/api_service.dart';
// import 'package:jitco_app/widgets/form_unknown_drop_down.dart';
// import 'package:jitco_app/widgets/form_unknown_user.dart';
// import 'package:velocity_x/velocity_x.dart';

// class ProfileOutletForm extends StatefulWidget {
//   final String title;
//   final String saveOutlet;
//   const ProfileOutletForm({
//     super.key,
//     required this.title,
//     required this.saveOutlet,
//   });

//   @override
//   State<ProfileOutletForm> createState() => _ProfileOutletFormState();
// }

// class _ProfileOutletFormState extends State<ProfileOutletForm> {
//   DateTime? _selectedDate;
//   final ApiService apiService = Get.find<ApiService>();
//   final TextEditingController outletNameController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController pinCodeController = TextEditingController();
//   final TextEditingController msmeController = TextEditingController();
//   final TextEditingController fssaiController = TextEditingController();
//   final TextEditingController gstController = TextEditingController();

//   List<StateModel> _stateList = [];
//   List<CityModel> _cityList = [];

//   StateModel? _selectedState;
//   CityModel? _selectedCity;

//   bool _loadingStates = true;
//   bool _loadingCities = false;
//   bool _isSubmitting = false;
//   bool _isLoadingExistingData = false;

//   @override
//   void initState() {
//     super.initState();
//     print('=== ProfileOutletForm INIT ===');
//     print('Title: ${widget.title}');

//     // Fetch states first
//     _fetchStates();

//     // Load existing data if editing
//     if (widget.title == 'Edit Outlet') {
//       _loadExistingOutletData();
//     }
//   }

//   // ✅ Fetch states (from /public/state API)
//   Future<void> _fetchStates() async {
//     try {
//       print('🗺️ Fetching states...');
//       setState(() {
//         _loadingStates = true;
//       });

//       // Use fetchStates() method (not getStates!)
//       final states = await apiService.fetchStates();

//       print('✅ Fetched ${states.length} states');

//       // Debug: Print first few states
//       if (states.isNotEmpty) {
//         for (var i = 0; i < states.length && i < 3; i++) {
//           print('State ${i + 1}: ${states[i].name} (ID: ${states[i].id})');
//         }
//       }

//       setState(() {
//         _stateList = states;
//         _loadingStates = false;
//       });

//       // final profileController = Get.find<ProfileController>();
//       // profileController.setStates(states);

//       // If editing, try to find and select the state
//       if (widget.title == 'Edit Outlet') {
//         _selectExistingState();
//       }
//     } catch (e) {
//       print('❌ Error fetching states: $e');
//       setState(() {
//         _loadingStates = false;
//       });
//     }
//   }

//   // ✅ Fetch cities for selected state
//   Future<void> _fetchCities(int stateId) async {
//     try {
//       print('🏙️ Fetching cities for state ID: $stateId');
//       setState(() {
//         _loadingCities = true;
//         _selectedCity = null; // Reset selected city
//       });

//       // Use fetchCities() method
//       final cities = await apiService.fetchCities(stateId);

//       print('✅ Fetched ${cities.length} cities');

//       // Debug: Print first few cities
//       if (cities.isNotEmpty) {
//         for (var i = 0; i < cities.length && i < 3; i++) {
//           print('City ${i + 1}: ${cities[i].name} (ID: ${cities[i].id})');
//         }
//       }

//       setState(() {
//         _cityList = cities;
//         _loadingCities = false;
//       });

//       // final profileController = Get.find<ProfileController>();
//       // profileController.setCities(cities);

//       // If editing, find and select the city
//       if (widget.title == 'Edit Outlet') {
//         _selectExistingCity();
//       }
//     } catch (e) {
//       print('❌ Error fetching cities: $e');
//       setState(() {
//         _cityList = [];
//         _loadingCities = false;
//       });
//     }
//   }

//   // ✅ Select existing state when editing

//   // void _selectExistingState() async {
//   //   try {
//   //     final profileController = Get.find<ProfileController>();
//   //     final outletToEdit = profileController.selectedOutlet.value;
//   //     if (outletToEdit != null && outletToEdit.stateId.isNotEmpty) {
//   //       print('🔍 Looking for existing state ID: ${outletToEdit.stateId}');
//   //       // Parse state ID
//   //       final stateId = int.tryParse(outletToEdit.stateId);
//   //       if (stateId != null && _stateList.isNotEmpty) {
//   //         // Find the state in the list
//   //         StateModel? foundState;
//   //         for (var state in _stateList) {
//   //           if (state.id == stateId) {
//   //             foundState = state;
//   //             break;
//   //           }
//   //         }
//   //         if (foundState != null) {
//   //           print(
//   //             '✅ Found existing state: ${foundState.name} (ID: ${foundState.id})',
//   //           );
//   //           setState(() {
//   //             _selectedState = foundState;
//   //           });
//   //           // Fetch cities for this state
//   //           await _fetchCities(stateId);
//   //         } else {
//   //           print('⚠️ State ID $stateId not found in state list');
//   //           print(
//   //             'Available state IDs: ${_stateList.map((s) => s.id).toList()}',
//   //           );
//   //           print(
//   //             'Available state names: ${_stateList.map((s) => s.name).toList()}',
//   //           );
//   //           // Create a temporary state object
//   //           final tempState = StateModel(
//   //             id: stateId,
//   //             name: 'State $stateId',
//   //             cities: [],
//   //           );
//   //           setState(() {
//   //             _selectedState = tempState;
//   //           });
//   //           // Still try to fetch cities for this state
//   //           await _fetchCities(stateId);
//   //         }
//   //       } else {
//   //         print('⚠️ Invalid state ID format: ${outletToEdit.stateId}');
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error selecting existing state: $e');
//   //   }
//   // }

//   // In profile_outlet_form.dart, update _selectExistingState()
//   void _selectExistingState() async {
//     try {
//       final profileController = Get.find<ProfileController>();
//       final outletToEdit = profileController.selectedOutlet.value;

//       if (outletToEdit != null && outletToEdit.stateId.isNotEmpty) {
//         print('🔍 Looking for existing state ID: ${outletToEdit.stateId}');

//         // Parse state ID
//         final stateId = int.tryParse(outletToEdit.stateId);

//         if (stateId != null && _stateList.isNotEmpty) {
//           // Find the state in the list
//           StateModel? foundState;
//           for (var state in _stateList) {
//             if (state.id == stateId) {
//               foundState = state;
//               break;
//             }
//           }

//           if (foundState != null) {
//             print(
//               '✅ Found existing state: ${foundState.name} (ID: ${foundState.id})',
//             );
//             setState(() {
//               _selectedState = foundState;
//             });
//             // Fetch cities for this state
//             await _fetchCities(stateId);
//           } else {
//             print('⚠️ State ID $stateId not found in state list');
//             // Create a temporary state object
//             final tempState = StateModel(
//               id: stateId,
//               name: outletToEdit.stateName!.isNotEmpty
//                   ? outletToEdit.stateName!
//                   : 'State $stateId',
//               cities: [],
//             );
//             setState(() {
//               _selectedState = tempState;
//             });
//             await _fetchCities(stateId);
//           }
//         } else {
//           print('⚠️ Invalid state ID format: ${outletToEdit.stateId}');
//         }
//       }
//     } catch (e) {
//       print('❌ Error selecting existing state: $e');
//     }
//   }

//   // ✅ Select existing city when editing
//   // void _selectExistingCity() {
//   //   try {
//   //     final profileController = Get.find<ProfileController>();
//   //     final outletToEdit = profileController.selectedOutlet.value;
//   //     if (outletToEdit != null &&
//   //         outletToEdit.cityId.isNotEmpty &&
//   //         _selectedState != null) {
//   //       print('🔍 Looking for existing city ID: ${outletToEdit.cityId}');
//   //       // Parse city ID
//   //       final cityId = int.tryParse(outletToEdit.cityId);
//   //       if (cityId != null && _cityList.isNotEmpty) {
//   //         // Find the city in the list
//   //         CityModel? foundCity;
//   //         for (var city in _cityList) {
//   //           if (city.id == cityId) {
//   //             foundCity = city;
//   //             break;
//   //           }
//   //         }
//   //         if (foundCity != null) {
//   //           print(
//   //             '✅ Found existing city: ${foundCity.name} (ID: ${foundCity.id})',
//   //           );
//   //           setState(() {
//   //             _selectedCity = foundCity;
//   //           });
//   //         } else {
//   //           print('⚠️ City ID $cityId not found in city list');
//   //           print('Available city IDs: ${_cityList.map((c) => c.id).toList()}');
//   //           print(
//   //             'Available city names: ${_cityList.map((c) => c.name).toList()}',
//   //           );
//   //           // Create a temporary city object
//   //           final tempCity = CityModel(id: cityId, name: 'City $cityId');
//   //           setState(() {
//   //             _selectedCity = tempCity;
//   //           });
//   //         }
//   //       } else {
//   //         print('⚠️ Invalid city ID format: ${outletToEdit.cityId}');
//   //       }
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error selecting existing city: $e');
//   //   }
//   // }

//   // In profile_outlet_form.dart, update _selectExistingCity()
//   void _selectExistingCity() {
//     try {
//       final profileController = Get.find<ProfileController>();
//       final outletToEdit = profileController.selectedOutlet.value;

//       if (outletToEdit != null &&
//           outletToEdit.cityId.isNotEmpty &&
//           _selectedState != null) {
//         print('🔍 Looking for existing city ID: ${outletToEdit.cityId}');

//         // Parse city ID
//         final cityId = int.tryParse(outletToEdit.cityId);

//         if (cityId != null && _cityList.isNotEmpty) {
//           // Find the city in the list
//           CityModel? foundCity;
//           for (var city in _cityList) {
//             if (city.id == cityId) {
//               foundCity = city;
//               break;
//             }
//           }

//           if (foundCity != null) {
//             print(
//               '✅ Found existing city: ${foundCity.name} (ID: ${foundCity.id})',
//             );
//             setState(() {
//               _selectedCity = foundCity;
//             });
//           } else {
//             print('⚠️ City ID $cityId not found in city list');
//             // Create a temporary city object
//             final tempCity = CityModel(
//               id: cityId,
//               name: outletToEdit.cityName!.isNotEmpty
//                   ? outletToEdit.cityName!
//                   : 'City $cityId',
//             );
//             setState(() {
//               _selectedCity = tempCity;
//             });
//           }
//         } else {
//           print('⚠️ Invalid city ID format: ${outletToEdit.cityId}');
//         }
//       }
//     } catch (e) {
//       print('❌ Error selecting existing city: $e');
//     }
//   }

//   // ✅ Load existing outlet data for editing
//   // Future<void> _loadExistingOutletData() async {
//   //   try {
//   //     setState(() {
//   //       _isLoadingExistingData = true;
//   //     });
//   //     final profileController = Get.find<ProfileController>();
//   //     final outletToEdit = profileController.selectedOutlet.value;
//   //     if (outletToEdit != null) {
//   //       print('=== LOADING EXISTING OUTLET DATA ===');
//   //       print('Outlet to edit: ${outletToEdit.name}');
//   //       print('Outlet ID: ${outletToEdit.id}');
//   //       print('State ID: ${outletToEdit.stateId}');
//   //       print('City ID: ${outletToEdit.cityId}');
//   //       print('Registration Date: ${outletToEdit.registrationDate}');
//   //       // Fill form fields
//   //       outletNameController.text = outletToEdit.name;
//   //       addressController.text = outletToEdit.address;
//   //       pinCodeController.text = outletToEdit.pinCode;
//   //       msmeController.text = outletToEdit.msmeNumber ?? '';
//   //       fssaiController.text = outletToEdit.fssaiNumber ?? '';
//   //       gstController.text = outletToEdit.gstNumber ?? '';
//   //       // Handle registration date
//   //       if (outletToEdit.registrationDate != null) {
//   //         _selectedDate = outletToEdit.registrationDate;
//   //         print('📅 Registration date: $_selectedDate');
//   //       }
//   //       print('=== EXISTING DATA LOADED ===');
//   //     } else {
//   //       print('No outlet selected for editing');
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error loading existing outlet data: $e');
//   //   } finally {
//   //     setState(() {
//   //       _isLoadingExistingData = false;
//   //     });
//   //   }
//   // }

//   // In profile_outlet_form.dart, update _loadExistingOutletData()
//   Future<void> _loadExistingOutletData() async {
//     try {
//       setState(() {
//         _isLoadingExistingData = true;
//       });

//       final profileController = Get.find<ProfileController>();
//       final outletToEdit = profileController.selectedOutlet.value;

//       if (outletToEdit != null) {
//         print('=== LOADING EXISTING OUTLET DATA ===');
//         print('Outlet to edit: ${outletToEdit.name}');
//         print('Outlet ID: ${outletToEdit.id}');

//         // ✅ FIXED: Use stateId and cityId for editing
//         print('State ID: ${outletToEdit.stateId}');
//         print('City ID: ${outletToEdit.cityId}');
//         print('State Name: ${outletToEdit.stateName}');
//         print('City Name: ${outletToEdit.cityName}');
//         print('Registration Date: ${outletToEdit.registrationDate}');

//         // Fill form fields
//         outletNameController.text = outletToEdit.name;
//         addressController.text = outletToEdit.address;
//         pinCodeController.text = outletToEdit.pinCode;
//         msmeController.text = outletToEdit.msmeNumber ?? '';
//         fssaiController.text = outletToEdit.fssaiNumber ?? '';
//         gstController.text = outletToEdit.gstNumber ?? '';

//         // Handle registration date
//         if (outletToEdit.registrationDate != null) {
//           _selectedDate = outletToEdit.registrationDate;
//           print('📅 Registration date: $_selectedDate');
//         }

//         print('=== EXISTING DATA LOADED ===');
//       } else {
//         print('No outlet selected for editing');
//       }
//     } catch (e) {
//       print('❌ Error loading existing outlet data: $e');
//     } finally {
//       setState(() {
//         _isLoadingExistingData = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     outletNameController.dispose();
//     addressController.dispose();
//     pinCodeController.dispose();
//     msmeController.dispose();
//     fssaiController.dispose();
//     gstController.dispose();
//   }

//   // ✅ Save outlet method
//   Future<void> _saveOutlet() async {
//     print('=== VALIDATION CHECK ===');
//     print('Outlet Name: ${outletNameController.text}');
//     print('Address: ${addressController.text}');
//     print(
//       'Selected State: ${_selectedState?.name} (ID: ${_selectedState?.id})',
//     );
//     print('Selected City: ${_selectedCity?.name} (ID: ${_selectedCity?.id})');
//     print('PinCode: ${pinCodeController.text}');
//     print('Registration Date: $_selectedDate');

//     // Check if user is logged in
//     final authController = Get.find<AuthController>();
//     if (!authController.isLoggedIn.value) {
//       print('User not logged in. Redirecting to login...');
//       _showLoginDialog();
//       return;
//     }

//     // Validation
//     if (outletNameController.text.isEmpty) {
//       _showError('Please enter outlet name');
//       return;
//     }
//     if (addressController.text.isEmpty) {
//       _showError('Please enter address');
//       return;
//     }
//     if (_selectedState == null) {
//       _showError('Please select a state');
//       return;
//     }
//     if (_selectedCity == null) {
//       _showError('Please select a city');
//       return;
//     }
//     if (pinCodeController.text.isEmpty) {
//       _showError('Please enter pin code');
//       return;
//     }
//     if (_selectedDate == null) {
//       _showError('Please select registration date');
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final profileController = Get.find<ProfileController>();

//       // Get outlet ID if editing
//       String? outletId;
//       if (widget.title == 'Edit Outlet') {
//         outletId = profileController.selectedOutlet.value?.id;

//         print('=== EDIT MODE ===');
//         print('Outlet ID from controller: $outletId');

//         if (outletId == null || outletId.isEmpty) {
//           _showError('Cannot update: Outlet ID not found');
//           setState(() {
//             _isSubmitting = false;
//           });
//           return;
//         }
//       }

//       // Create outlet
//       final outlet = OutletModel(
//         id: outletId,
//         name: outletNameController.text.trim(),
//         address: addressController.text.trim(),
//         stateId: _selectedState!.id.toString(),
//         cityId: _selectedCity!.id.toString(),
//         pinCode: pinCodeController.text.trim(),
//         registrationDate: _selectedDate,
//         msmeNumber: msmeController.text.trim().isNotEmpty
//             ? msmeController.text.trim()
//             : null,
//         fssaiNumber: fssaiController.text.trim().isNotEmpty
//             ? fssaiController.text.trim()
//             : null,
//         gstNumber: gstController.text.trim().isNotEmpty
//             ? gstController.text.trim()
//             : null,
//       );

//       print('=== CALLING saveOutlet ===');
//       print('Outlet ID: ${outlet.id}');
//       print('Is update: ${widget.title == 'Edit Outlet'}');
//       print('Outlet data: ${outlet.toJson()}');

//       final success = await profileController.saveOutlet(
//         outlet,
//         isUpdate: widget.title == 'Edit Outlet',
//       );

//       print('Save outlet result: $success');

//       if (success) {
//         // ✅ SUCCESS
//         _showSuccess('Outlet saved successfully!');

//         // Wait for snackbar to show, then navigate back
//         await Future.delayed(Duration(milliseconds: 1500));

//         // Navigate back
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context, true);
//         } else {
//           Get.back(result: true);
//         }
//       } else {
//         print('Save failed - error shown by controller');
//       }
//     } catch (e, stackTrace) {
//       print('❌ Error saving outlet: $e');
//       print('Stack trace: $stackTrace');
//       _showError('Failed to save outlet: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   // ✅ Helper methods for dialogs and messages
//   void _showLoginDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Login Required'),
//         content: Text('You need to login first to save outlet.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Get.offAll(() => Login());
//             },
//             child: Text('Go to Login'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Outlet Name
//                 FormUnknownUser(
//                   formTitle: 'Outlet Name *',
//                   controller: outletNameController,
//                 ),
//                 10.heightBox,

//                 // Registration Date
//                 Text(
//                   'Registration Date *',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 10.heightBox,
//                 CustomDatePicker(
//                   initialDate: _selectedDate,
//                   onDateChanged: (date) {
//                     setState(() {
//                       _selectedDate = date;
//                     });
//                     String formatted = DateFormat('yyyy-MM-dd').format(date);
//                     print('Selected date: $formatted');
//                   },
//                   labelText: 'Select Date',
//                   hintText: 'Choose a date',
//                   icon: Icons.event,
//                 ),

//                 10.heightBox,

//                 // Address
//                 FormUnknownUser(
//                   formTitle: 'Address *',
//                   controller: addressController,
//                 ),

//                 // State Dropdown
//                 FormUnknownDropdown<StateModel>(
//                   title: "State *",
//                   hint: _loadingStates ? "Loading states..." : "Select State",
//                   items: _stateList,
//                   displayItem: (state) => state.name,
//                   selectedValue: _selectedState,
//                   enabled: !_loadingStates,
//                   onChanged: _loadingStates
//                       ? null
//                       : (StateModel? newState) {
//                           print(
//                             'State changed to: ${newState?.name} (ID: ${newState?.id})',
//                           );
//                           setState(() {
//                             _selectedState = newState;
//                             _selectedCity = null;
//                             _cityList = [];
//                           });
//                           if (newState != null) {
//                             _fetchCities(newState.id);
//                           }
//                         },
//                 ),
//                 20.heightBox,

//                 // City Dropdown
//                 FormUnknownDropdown<CityModel>(
//                   title: "City *",
//                   hint: _loadingCities
//                       ? "Loading cities..."
//                       : _selectedState == null
//                       ? "Select State first"
//                       : "Select City",
//                   items: _cityList,
//                   displayItem: (city) => city.name,
//                   selectedValue: _selectedCity,
//                   enabled: !_loadingCities && _selectedState != null,
//                   onChanged: _loadingCities || _selectedState == null
//                       ? null
//                       : (CityModel? newCity) {
//                           print(
//                             'City changed to: ${newCity?.name} (ID: ${newCity?.id})',
//                           );
//                           setState(() {
//                             _selectedCity = newCity;
//                           });
//                         },
//                 ),

//                 10.heightBox,

//                 // PinCode
//                 FormUnknownUser(
//                   formTitle: 'PinCode *',
//                   controller: pinCodeController,
//                   keyboardType: TextInputType.number,
//                 ),

//                 // MSME Number
//                 FormUnknownUser(
//                   formTitle: 'MSME Number',
//                   controller: msmeController,
//                 ),

//                 // FSSAI Number
//                 FormUnknownUser(
//                   formTitle: 'FSSAI Number',
//                   controller: fssaiController,
//                 ),

//                 // GST Number
//                 FormUnknownUser(
//                   formTitle: 'GST Number',
//                   controller: gstController,
//                 ),

//                 20.heightBox,

//                 // Save Button
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         backgroundColor: Colors.deepOrangeAccent,
//                         foregroundColor: Colors.white,
//                       ),
//                       onPressed: (_isLoadingExistingData || _isSubmitting)
//                           ? null
//                           : _saveOutlet,
//                       child: _isSubmitting
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               widget.saveOutlet,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
