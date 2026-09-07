import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/state_city_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_drop_down.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_user.dart';
import 'package:velocity_x/velocity_x.dart';

class FormForUnknownUser extends StatefulWidget {
  const FormForUnknownUser({super.key});

  @override
  State<FormForUnknownUser> createState() => _FormForUnknownUserState();
}

class _FormForUnknownUserState extends State<FormForUnknownUser> {
  final ApiServices apiService = Get.find<ApiServices>();

  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<StateModel> countries = [];
  List<CityModel> cities = [];

  StateModel? selectedCountry;
  CityModel? selectedCity;

  bool loadingCountries = true;
  bool loadingCities = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    companyNameController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadCountries() async {
    try {
      countries = await apiService.fetchStates();
      setState(() {
        loadingCountries = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        loadingCountries = false;
      });
    }
  }

  Future<void> loadCities(int stateId) async {
    setState(() {
      loadingCities = true;
      selectedCity = null; // Reset selected city when state changes
    });

    try {
      cities = await apiService.fetchCities(stateId);
    } catch (e) {
      print('Error loading cities: $e');
      cities = [];
    } finally {
      setState(() {
        loadingCities = false;
      });
    }
  }

  Future<void> saveCompanyDetails() async {
    // Validate required fields
    if (fullNameController.text.isEmpty ||
        companyNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedCountry == null ||
        selectedCity == null ||
        pinCodeController.text.isEmpty ||
        emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate email format
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Prepare company data
      Map<String, dynamic> companyData = {
        'name': fullNameController.text.trim(),
        'full_name': companyNameController.text.trim(),
        'address': addressController.text.trim(),
        'state': selectedCountry!.id,
        'city': selectedCity!.id,
        'pin_code': pinCodeController.text.trim(),
        'email': emailController.text.trim(),
      };

      // Call API to save company details
      final result = await apiService.saveCompanyDetails(companyData);

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          result['message'] ?? 'Company details saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Optionally clear form or navigate back
        // clearForm();
        // Get.back();
        // Navigate to BottomNavItem after a short delay
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to BottomNavItem and remove all previous routes
        Get.offAll(() => JitcoSupplyNavBar());
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to save company details',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void clearForm() {
    fullNameController.clear();
    companyNameController.clear();
    addressController.clear();
    pinCodeController.clear();
    emailController.clear();
    setState(() {
      selectedCountry = null;
      selectedCity = null;
      cities = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: ListView(
            children: [
              27.heightBox,
              Center(
                child: Text(
                  'Add Company Details',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              20.heightBox,

              // Text Fields
              FormUnknownUser(
                formTitle: 'Your Full Name *',
                controller: fullNameController,
              ),
              FormUnknownUser(
                formTitle: 'Company Name *',
                controller: companyNameController,
              ),
              FormUnknownUser(
                formTitle: 'Address *',
                controller: addressController,
              ),
              10.heightBox,

              /// State Dropdown
              // FormUnknownDropdown<StateModel>(
              //   title: "State *",
              //   hint: loadingCountries ? "Loading states..." : "Select State",
              //   items: countries,
              //   displayItem: (country) => country.name,
              //   selectedValue: selectedCountry,
              //   onChanged: loadingCountries
              //       ? null
              //       : (StateModel? newCountry) {
              //           setState(() {
              //             selectedCountry = newCountry;
              //             selectedCity = null; // Reset city when state changes
              //             if (newCountry != null) {
              //               loadCities(newCountry.id);
              //             } else {
              //               cities = [];
              //             }
              //           });
              //         },
              // ),
              // State Selector
              Text(
                "State *",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              8.heightBox,
              GestureDetector(
                onTap: loadingCountries
                    ? null
                    : () async {
                        final selected = await showModalBottomSheet<StateModel>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          builder: (_) => SearchableListBottomSheet<StateModel>(
                            title: "Select State",
                            items: countries,
                            displayItem: (state) => state.name,
                          ),
                        );

                        if (selected != null) {
                          final isDifferentState =
                              selectedCountry == null ||
                              selectedCountry!.id != selected.id;

                          if (isDifferentState) {
                            setState(() {
                              selectedCountry = selected;
                              selectedCity = null;
                              cities.clear();
                            });

                            await loadCities(selected.id);
                          }
                        }
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCountry?.name ?? "Select State",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              20.heightBox,

              20.heightBox,

              /// City Dropdown
              // FormUnknownDropdown<CityModel>(
              //   title: "City *",
              //   hint: loadingCities
              //       ? "Loading cities..."
              //       : selectedCountry == null
              //       ? "Select State first"
              //       : "Select City",
              //   items: cities,
              //   displayItem: (city) => city.name,
              //   selectedValue: selectedCity,
              //   enabled:
              //       !loadingCities &&
              //       selectedCountry != null &&
              //       cities.isNotEmpty,
              //   onChanged: (CityModel? newCity) {
              //     setState(() {
              //       selectedCity = newCity;
              //     });
              //   },
              // ),
              // City Selector
              Text(
                "City *",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              8.heightBox,
              GestureDetector(
                onTap: (loadingCities || selectedCountry == null)
                    ? null
                    : () async {
                        final selected = await showModalBottomSheet<CityModel>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          builder: (_) => SearchableListBottomSheet<CityModel>(
                            title: "Select City",
                            items: cities,
                            displayItem: (city) => city.name,
                          ),
                        );

                        if (selected != null) {
                          setState(() {
                            selectedCity = selected;
                          });
                        }
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedCountry == null
                          ? Colors.grey.shade300
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: selectedCountry == null
                        ? Colors.grey.shade100
                        : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loadingCities
                            ? "Loading cities..."
                            : selectedCountry == null
                            ? "Select State first"
                            : selectedCity?.name ?? "Select City",
                        style: TextStyle(
                          color: selectedCountry == null
                              ? Colors.grey
                              : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: selectedCountry == null
                            ? Colors.grey
                            : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              10.heightBox,
              FormUnknownUser(
                formTitle: 'PinCode *',
                controller: pinCodeController,
                keyboardType: TextInputType.number,
              ),
              FormUnknownUser(
                formTitle: 'Email *',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              40.heightBox,

              // Submit Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isSubmitting ? null : saveCompanyDetails,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Company Details',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String title,
    TextEditingController controller, [
    TextInputType? keyboardType,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          10.heightBox,
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.deepOrangeAccent,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
