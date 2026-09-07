// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:jitco_app/controllers/profile_controller.dart';
// // import 'package:jitco_app/models/contact_model.dart';
// // import 'package:jitco_app/widgets/form_unknown_user.dart';
// // import 'package:velocity_x/velocity_x.dart';

// // class ProfileContactForm extends StatefulWidget {
// //   final String contact;
// //   final String saveContact;
// //   const ProfileContactForm({
// //     super.key,
// //     required this.contact,
// //     required this.saveContact,
// //   });

// //   @override
// //   State<ProfileContactForm> createState() => _ProfileContactFormState();
// // }

// // class _ProfileContactFormState extends State<ProfileContactForm> {
// //   bool isSubmitting = false;
// //   final TextEditingController fullNameController = TextEditingController();
// //   final TextEditingController phoneController = TextEditingController();
// //   final TextEditingController emailController = TextEditingController();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: Text(widget.contact),
// //         backgroundColor: Colors.white,
// //         surfaceTintColor: Colors.white,
// //       ),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               children: [
// //                 FormUnknownUser(
// //                   formTitle: 'Full Name *',
// //                   controller: fullNameController,
// //                 ),
// //                 FormUnknownUser(
// //                   formTitle: 'Phone Number *',
// //                   controller: phoneController,
// //                 ),
// //                 FormUnknownUser(
// //                   formTitle: 'Email *',
// //                   controller: emailController,
// //                   keyboardType: TextInputType.emailAddress,
// //                 ),

// //                 25.heightBox,
// //                 Padding(
// //                   padding: const EdgeInsets.only(bottom: 20),
// //                   child: SizedBox(
// //                     width: double.infinity,
// //                     height: 50,
// //                     child: ElevatedButton(
// //                       style: ElevatedButton.styleFrom(
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         backgroundColor: Colors.deepOrangeAccent,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                       // Update the onPressed in ProfileContactForm
// //                       onPressed: () async {
// //                         if (fullNameController.text.isEmpty ||
// //                             phoneController.text.isEmpty ||
// //                             emailController.text.isEmpty) {
// //                           Get.snackbar(
// //                             'Error',
// //                             'Please fill all required fields',
// //                           );
// //                           return;
// //                         }

// //                         setState(() {
// //                           isSubmitting = true;
// //                         });

// //                         final profileController = Get.find<ProfileController>();
// //                         final contact = ContactModel(
// //                           name: fullNameController.text,
// //                           phone: phoneController.text,
// //                           email: emailController.text,
// //                         );

// //                         final success = await profileController.saveContact(
// //                           contact,
// //                           isUpdate: widget.contact == 'Edit Contact',
// //                         );

// //                         setState(() {
// //                           isSubmitting = false;
// //                         });
// //                       },
// //                       child: isSubmitting
// //                           ? const SizedBox(
// //                               height: 20,
// //                               width: 20,
// //                               child: CircularProgressIndicator(
// //                                 color: Colors.white,
// //                                 strokeWidth: 2,
// //                               ),
// //                             )
// //                           : Text(
// //                               widget.saveContact,
// //                               style: const TextStyle(fontSize: 16),
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/controllers/profile_controller.dart';
// import 'package:jitco_app/models/contact_model.dart';
// import 'package:jitco_app/widgets/form_unknown_user.dart';
// import 'package:velocity_x/velocity_x.dart';

// class ProfileContactForm extends StatefulWidget {
//   final String contact;
//   final String saveContact;
//   const ProfileContactForm({
//     super.key,
//     required this.contact,
//     required this.saveContact,
//   });

//   @override
//   State<ProfileContactForm> createState() => _ProfileContactFormState();
// }

// class _ProfileContactFormState extends State<ProfileContactForm> {
//   bool isSubmitting = false;
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   // Store outlet ID instead of name
//   String? selectedOutletId;
//   List<Map<String, dynamic>> outlets = []; // Store id and name
//   bool isLoadingOutlets = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOutlets();
//   }

//   Future<void> _fetchOutlets() async {
//     setState(() {
//       isLoadingOutlets = true;
//     });

//     try {
//       final profileController = Get.find<ProfileController>();

//       // Use the new method that returns outlets with IDs
//       final outletList = await profileController.getOutletsWithIds();

//       setState(() {
//         outlets = outletList;
//         if (outlets.isNotEmpty) {
//           selectedOutletId = outlets.first['id'];
//         }
//         isLoadingOutlets = false;
//       });

//       print('✅ Loaded ${outlets.length} outlets');
//     } catch (e) {
//       print('❌ Error fetching outlets: $e');
//       setState(() {
//         isLoadingOutlets = false;
//       });
//       Get.snackbar('Error', 'Failed to load outlets');
//     }
//   }

//   // Helper to get outlet name by ID
//   String getOutletName(String id) {
//     final outlet = outlets.firstWhere(
//       (outlet) => outlet['id'] == id,
//       orElse: () => {'name': ''},
//     );
//     return outlet['name'];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.contact),
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 FormUnknownUser(
//                   formTitle: 'Full Name *',
//                   controller: fullNameController,
//                 ),
//                 FormUnknownUser(
//                   formTitle: 'Phone Number *',
//                   controller: phoneController,
//                 ),
//                 FormUnknownUser(
//                   formTitle: 'Email *',
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                 ),

//                 // Outlet Dropdown
//                 15.heightBox,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Outlet *',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     8.heightBox,
//                     Container(
//                       height: 56,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: selectedOutletId != null
//                               ? Colors.deepOrangeAccent
//                               : Colors.grey[300]!,
//                           width: selectedOutletId != null ? 1.5 : 1.0,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: isLoadingOutlets
//                             ? Row(
//                                 children: [
//                                   Text(
//                                     'Loading outlets...',
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                         Colors.deepOrangeAccent,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : outlets.isEmpty
//                             ? Row(
//                                 children: [
//                                   Icon(
//                                     Icons.store_mall_directory_outlined,
//                                     color: Colors.grey[400],
//                                     size: 20,
//                                   ),
//                                   12.widthBox,
//                                   Text(
//                                     'No outlets available',
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   IconButton(
//                                     icon: Icon(
//                                       Icons.refresh,
//                                       size: 20,
//                                       color: Colors.deepOrangeAccent,
//                                     ),
//                                     onPressed: _fetchOutlets,
//                                   ),
//                                 ],
//                               )
//                             : DropdownButtonHideUnderline(
//                                 child: DropdownButton<String>(
//                                   value: selectedOutletId,
//                                   isExpanded: true,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[800],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   icon: Icon(
//                                     Icons.arrow_drop_down,
//                                     color: Colors.black54,
//                                     size: 28,
//                                   ),
//                                   iconSize: 28,
//                                   elevation: 4,
//                                   dropdownColor: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   menuMaxHeight: 300,

//                                   // Show outlet name for selected item
//                                   selectedItemBuilder: (context) {
//                                     return outlets.map((outlet) {
//                                       return Container(
//                                         alignment: Alignment.centerLeft,
//                                         child: Text(
//                                           outlet['name'] ?? '',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.black54,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       );
//                                     }).toList();
//                                   },

//                                   // Create dropdown items with ID as value
//                                   items: outlets.map((outlet) {
//                                     return DropdownMenuItem<String>(
//                                       value: outlet['id'],
//                                       child: Container(
//                                         padding: EdgeInsets.symmetric(
//                                           vertical: 12,
//                                         ),
//                                         child: Text(
//                                           outlet['name'] ?? '',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey[800],
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),

//                                   onChanged: (String? newId) {
//                                     setState(() {
//                                       selectedOutletId = newId;
//                                     });
//                                   },

//                                   // Focus effect
//                                   focusColor: Colors.deepOrangeAccent
//                                       .withOpacity(0.1),
//                                 ),
//                               ),
//                       ),
//                     ),

//                     // Show error if no outlet selected
//                     if (selectedOutletId == null &&
//                         !isLoadingOutlets &&
//                         outlets.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4, left: 4),
//                         child: Text(
//                           'Please select an outlet',
//                           style: TextStyle(fontSize: 12, color: Colors.red),
//                         ),
//                       ),
//                   ],
//                 ),

//                 25.heightBox,
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
//                       onPressed: () async {
//                         // Validate all fields including outlet
//                         if (fullNameController.text.isEmpty ||
//                             phoneController.text.isEmpty ||
//                             emailController.text.isEmpty ||
//                             selectedOutletId == null) {
//                           Get.snackbar(
//                             'Error',
//                             'Please fill all required fields',
//                           );
//                           return;
//                         }

//                         setState(() {
//                           isSubmitting = true;
//                         });

//                         final profileController = Get.find<ProfileController>();

//                         // Create contact with outlet ID
//                         final contact = ContactModel(
//                           name: fullNameController.text,
//                           phone: phoneController.text,
//                           email: emailController.text,
//                           outletId: selectedOutletId, // Send outlet ID
//                         );

//                         final success = await profileController.saveContact(
//                           contact,
//                           isUpdate: widget.contact == 'Edit Contact',
//                         );

//                         setState(() {
//                           isSubmitting = false;
//                         });
//                       },
//                       child: isSubmitting
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               widget.saveContact,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/profile_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/contact_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_drop_down.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/D_widgets/form_unknown_user.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileContactForm extends StatefulWidget {
  final String contact;
  final String saveContact;
  const ProfileContactForm({
    super.key,
    required this.contact,
    required this.saveContact,
  });

  @override
  State<ProfileContactForm> createState() => _ProfileContactFormState();
}

class _ProfileContactFormState extends State<ProfileContactForm> {
  bool isSubmitting = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Store outlet ID instead of name
  String? selectedOutletId;
  // List<Map<String, dynamic>> outlets = []; // Store id and name
  List<Map<String, String>> outlets = []; // Store id and name
  bool isLoadingOutlets = true;
  bool isLoadingContact = true;

  @override
  void initState() {
    super.initState();
    _loadContactData(); // Load contact data if editing
    _fetchOutlets();
  }

  void _loadContactData() async {
    final profileController = Get.find<ProfileController>();
    final selectedContact = profileController.selectedContact.value;

    // If we're editing, populate the form fields
    if (widget.contact == 'Edit Contact' && selectedContact != null) {
      setState(() {
        isLoadingContact = true;
      });

      // Populate the text fields
      fullNameController.text = selectedContact.name;
      phoneController.text = selectedContact.phone;
      emailController.text = selectedContact.email;

      // Set the outlet ID if available
      if (selectedContact.outletId != null) {
        selectedOutletId = selectedContact.outletId;
      }

      setState(() {
        isLoadingContact = false;
      });
    } else {
      setState(() {
        isLoadingContact = false;
      });
    }
  }

  Future<void> _fetchOutlets() async {
    setState(() {
      isLoadingOutlets = true;
    });

    try {
      final profileController = Get.find<ProfileController>();
      // final outletList = await profileController.getOutletsWithIds();
      final outletList = (await profileController.getOutletsWithIds())
          .map<Map<String, String>>(
            (o) => {'id': o['id'].toString(), 'name': o['name'].toString()},
          )
          .toList();

      setState(() {
        outlets = outletList;
        // If we're editing and haven't set outletId yet, set it to first outlet
        if (selectedOutletId == null && outlets.isNotEmpty) {
          selectedOutletId = outlets.first['id'];
        }
        isLoadingOutlets = false;
      });

      print('Loaded ${outlets.length} outlets');
    } catch (e) {
      print('Error fetching outlets: $e');
      setState(() {
        isLoadingOutlets = false;
      });
      Get.snackbar('Error', 'Failed to load outlets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.contact),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Show loading indicator while loading contact data
                if (isLoadingContact)
                  const Center(child: CircularProgressIndicator()).p32()
                else ...[
                  FormUnknownUser(
                    formTitle: 'Full Name *',
                    controller: fullNameController,
                  ),
                  FormUnknownUser(
                    formTitle: 'Phone Number *',
                    controller: phoneController,
                  ),
                  FormUnknownUser(
                    formTitle: 'Email *',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  // Outlet Dropdown
                  15.heightBox,
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       'Outlet *',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.grey[700],
                  //       ),
                  //     ),
                  //     8.heightBox,
                  //     Container(
                  //       height: 56,
                  //       decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: selectedOutletId != null
                  //               ? Colors.deepOrangeAccent
                  //               : Colors.grey[300]!,
                  //           width: selectedOutletId != null ? 1.5 : 1.0,
                  //         ),
                  //         borderRadius: BorderRadius.circular(8),
                  //         color: Colors.white,
                  //       ),
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 16),
                  //         child: isLoadingOutlets
                  //             ? Row(
                  //                 children: [
                  //                   Text(
                  //                     'Loading outlets...',
                  //                     style: TextStyle(
                  //                       color: Colors.grey[600],
                  //                       fontSize: 16,
                  //                     ),
                  //                   ),
                  //                   Spacer(),
                  //                   SizedBox(
                  //                     width: 20,
                  //                     height: 20,
                  //                     child: CircularProgressIndicator(
                  //                       strokeWidth: 2,
                  //                       valueColor:
                  //                           AlwaysStoppedAnimation<Color>(
                  //                             Colors.deepOrangeAccent,
                  //                           ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               )
                  //             : outlets.isEmpty
                  //             ? Row(
                  //                 children: [
                  //                   Icon(
                  //                     Icons.store_mall_directory_outlined,
                  //                     color: Colors.grey[400],
                  //                     size: 20,
                  //                   ),
                  //                   12.widthBox,
                  //                   Text(
                  //                     'No outlets available',
                  //                     style: TextStyle(
                  //                       color: Colors.grey[600],
                  //                       fontSize: 16,
                  //                     ),
                  //                   ),
                  //                   const Spacer(),
                  //                   IconButton(
                  //                     icon: Icon(
                  //                       Icons.refresh,
                  //                       size: 20,
                  //                       color: Colors.deepOrangeAccent,
                  //                     ),
                  //                     onPressed: _fetchOutlets,
                  //                   ),
                  //                 ],
                  //               )
                  //             : DropdownButtonHideUnderline(
                  //                 child: DropdownButton<String>(
                  //                   value: selectedOutletId,
                  //                   isExpanded: true,
                  //                   style: TextStyle(
                  //                     fontSize: 16,
                  //                     color: Colors.grey[800],
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                   icon: Icon(
                  //                     Icons.arrow_drop_down,
                  //                     color: Colors.black54,
                  //                     size: 28,
                  //                   ),
                  //                   iconSize: 28,
                  //                   elevation: 4,
                  //                   dropdownColor: Colors.white,
                  //                   borderRadius: BorderRadius.circular(12),
                  //                   menuMaxHeight: 300,
                  //                   selectedItemBuilder: (context) {
                  //                     return outlets.map((outlet) {
                  //                       return Container(
                  //                         alignment: Alignment.centerLeft,
                  //                         child: Text(
                  //                           outlet['name'] ?? '',
                  //                           style: TextStyle(
                  //                             fontSize: 16,
                  //                             fontWeight: FontWeight.w500,
                  //                             color: Colors.black54,
                  //                           ),
                  //                           overflow: TextOverflow.ellipsis,
                  //                         ),
                  //                       );
                  //                     }).toList();
                  //                   },
                  //                   items: outlets.map((outlet) {
                  //                     return DropdownMenuItem<String>(
                  //                       value: outlet['id'],
                  //                       child: Container(
                  //                         padding: EdgeInsets.symmetric(
                  //                           vertical: 12,
                  //                         ),
                  //                         child: Text(
                  //                           outlet['name'] ?? '',
                  //                           style: TextStyle(
                  //                             fontSize: 16,
                  //                             color: Colors.grey[800],
                  //                           ),
                  //                           overflow: TextOverflow.ellipsis,
                  //                         ),
                  //                       ),
                  //                     );
                  //                   }).toList(),
                  //                   onChanged: (String? newId) {
                  //                     setState(() {
                  //                       selectedOutletId = newId;
                  //                     });
                  //                   },
                  //                   focusColor: Colors.deepOrangeAccent
                  //                       .withOpacity(0.1),
                  //                 ),
                  //               ),
                  //       ),
                  //     ),
                  //     if (selectedOutletId == null &&
                  //         !isLoadingOutlets &&
                  //         outlets.isNotEmpty)
                  //       Padding(
                  //         padding: const EdgeInsets.only(top: 4, left: 4),
                  //         child: Text(
                  //           'Please select an outlet',
                  //           style: TextStyle(fontSize: 12, color: Colors.red),
                  //         ),
                  //       ),
                  //   ],
                  // ),

                  // Outlet Dropdown with Search
                  15.heightBox,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outlet *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      8.heightBox,
                      GestureDetector(
                        onTap: isLoadingOutlets || outlets.isEmpty
                            ? null
                            : () async {
                                final selected =
                                    await showModalBottomSheet<
                                      Map<String, String>
                                    >(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      backgroundColor: Colors.white,
                                      builder: (_) =>
                                          SearchableListBottomSheet<
                                            Map<String, String>
                                          >(
                                            title: "Select Outlet",
                                            items: outlets,
                                            displayItem: (outlet) =>
                                                outlet['name']!,
                                          ),
                                    );

                                if (selected != null) {
                                  setState(() {
                                    selectedOutletId = selected['id'];
                                  });
                                }
                              },
                        child: Container(
                          height: 56,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedOutletId != null
                                  ? Colors.deepOrangeAccent
                                  : Colors.grey[300]!,
                              width: selectedOutletId != null ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedOutletId != null
                                    ? outlets.firstWhere(
                                        (o) => o['id'] == selectedOutletId,
                                        orElse: () => {'name': 'Select Outlet'},
                                      )['name']!
                                    : 'Select Outlet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedOutletId != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selectedOutletId == null &&
                          !isLoadingOutlets &&
                          outlets.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Please select an outlet',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                    ],
                  ),

                  25.heightBox,
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
                        onPressed: () async {
                          if (fullNameController.text.isEmpty ||
                              phoneController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              selectedOutletId == null) {
                            Get.snackbar(
                              'Error',
                              'Please fill all required fields',
                            );
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                          });

                          final profileController =
                              Get.find<ProfileController>();

                          // Get selected contact for editing
                          final selectedContact =
                              profileController.selectedContact.value;

                          // Create contact with outlet ID
                          final contact = ContactModel(
                            name: fullNameController.text,
                            phone: phoneController.text,
                            email: emailController.text,
                            outletId: selectedOutletId,
                            // Include id if editing
                            id: widget.contact == 'Edit Contact'
                                ? selectedContact?.id
                                : null,
                          );

                          final success = await profileController.saveContact(
                            contact,
                            isUpdate: widget.contact == 'Edit Contact',
                          );

                          setState(() {
                            isSubmitting = false;
                          });

                          if (success) {
                            // Get.back(); // Go back to profile settings
                            Navigator.pop(context);
                          }
                        },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.saveContact,
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
