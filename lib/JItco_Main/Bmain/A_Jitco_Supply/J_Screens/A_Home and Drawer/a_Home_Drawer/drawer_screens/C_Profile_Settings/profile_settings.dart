import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/profile_controller.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/contact_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/A_models/outlet_model.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/C_Profile_Settings/profile_contact_form.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/C_Profile_Settings/profile_outlet_form.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (profileController.contactsLoading.value ||
              profileController.outletsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Contacts Section Header
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Contacts',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          5.widthBox,
                          Text(
                            '(${profileController.contacts.length} contact${profileController.contacts.length != 1 ? 's' : ''})',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // Clear any previously selected contact
                              profileController.selectedContact.value = null;
                              Get.to(
                                () => ProfileContactForm(
                                  contact: 'Add Contact',
                                  saveContact: 'Add Contact',
                                ),
                                transition: Transition.rightToLeft,
                              );
                            },
                            child: const Text(
                              '+ Add',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(Icons.edit_outlined, size: 22),
                          // ),
                        ],
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.edit_outlined, size: 22),
                      // ),
                    ],
                  ),
                  10.heightBox,

                  // Display contacts from controller
                  if (profileController.contacts.isEmpty)
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            10.heightBox,
                            Text(
                              'No contacts added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            5.heightBox,
                            Text(
                              'Add your first contact to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Display all contacts
                    ...profileController.contacts.map((contact) {
                      return _buildContactCard(contact, profileController);
                    }).toList(),

                  20.heightBox,

                  // Outlets Section Header
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Your Outlets',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          5.widthBox,
                          Text(
                            '(${profileController.outlets.length} outlet${profileController.outlets.length != 1 ? 's' : ''})',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // Clear any previously selected outlet
                              profileController.selectedOutlet.value = null;
                              Get.to(
                                () => ProfileOutletForm(
                                  title: 'Add New Outlet',
                                  saveOutlet: 'Add Outlet',
                                ),
                                transition: Transition.rightToLeft,
                              );
                            },
                            child: const Text(
                              '+ Add',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(Icons.edit_outlined, size: 22),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  10.heightBox,

                  // Display outlets from controller
                  if (profileController.outlets.isEmpty)
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.store,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                            10.heightBox,
                            Text(
                              'No outlets added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            5.heightBox,
                            Text(
                              'Add your first outlet to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Display all outlets
                    ...profileController.outlets.map((outlet) {
                      return _buildOutletCard(outlet, profileController);
                    }).toList(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContactCard(ContactModel contact, ProfileController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 37,
                        backgroundColor: Colors.grey[300],
                        child: contact.profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(37),
                                child: Image.network(
                                  contact.profileImage!,
                                  fit: BoxFit.cover,
                                  width: 74,
                                  height: 74,
                                ),
                              )
                            : Icon(Icons.person, size: 40),
                      ),
                    ],
                  ),
                  22.widthBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            AutoSizeText(
                              contact.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // const Spacer(),
                            // 40.widthBox,
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: Icon(Icons.edit_outlined),
                            // ),
                            // Icon(Icons.edit_outlined),
                          ],
                        ),
                        7.heightBox,
                        AutoSizeText(
                          contact.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        7.heightBox,
                        AutoSizeText(
                          contact.phone,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                  15.widthBox,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Set the contact to edit
                          controller.selectedContact.value = contact;
                          Get.to(
                            () => ProfileContactForm(
                              contact: 'Edit Contact',
                              saveContact: 'Update Contact',
                            ),
                            transition: Transition.rightToLeft,
                          );
                        },
                        icon: Icon(Icons.edit_outlined, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
              17.heightBox,
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(contact.isPrimary ? 'Primary' : 'Secondary'),
                          ],
                        ),
                        if (contact.outletName != null)
                          Row(
                            children: [
                              const Text(
                                'Outlet: ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(contact.outletName!),
                            ],
                          ),
                      ],
                    ),
                    7.heightBox,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutletCard(OutletModel outlet, ProfileController controller) {
    // // Use controller methods to get display names
    // final stateName = controller.getStateName(outlet.stateName!);
    // final cityName = controller.getCityName(outlet.cityName!);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    outlet.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Set the outlet to edit
                    controller.selectedOutlet.value = outlet;
                    Get.to(
                      () => ProfileOutletForm(
                        title: 'Edit Outlet',
                        saveOutlet: 'Update Outlet',
                      ),
                      transition: Transition.rightToLeft,
                    );
                  },
                  icon: Icon(Icons.edit_outlined),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: Text(
                          outlet.address,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  10.heightBox,
                  userDetail('State: ', outlet.stateName!),
                  10.heightBox,
                  userDetail('City: ', outlet.cityName!),
                  10.heightBox,
                  userDetail('PinCode: ', outlet.pinCode),
                  if (outlet.gstNumber != null &&
                      outlet.gstNumber!.isNotEmpty) ...[
                    10.heightBox,
                    userDetail('GST: ', outlet.gstNumber!),
                  ],
                  if (outlet.msmeNumber != null &&
                      outlet.msmeNumber!.isNotEmpty) ...[
                    10.heightBox,
                    userDetail('MSME: ', outlet.msmeNumber!),
                  ],
                  if (outlet.fssaiNumber != null &&
                      outlet.fssaiNumber!.isNotEmpty) ...[
                    10.heightBox,
                    userDetail('FSSAI: ', outlet.fssaiNumber!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userDetail(String userTitle, String userSubTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          userTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        30.widthBox,
        Expanded(
          child: Text(
            userSubTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 15),
        //   child: SizedBox(
        //     width: double.infinity,
        //     child:
        //         'Add you bio.....................................................................................................................'
        //             .text
        //             .bold
        //             .color(Colors.blue)
        //             .size(14)
        //             .make(),
        //   ),
        // ),