import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';
import 'package:jitco_app/JItco_Main/Authentication/otp_verify.dart';
import 'package:velocity_x/velocity_x.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    print('1. Send OTP button pressed');

    if (_formKey.currentState!.validate()) {
      print('2. Form is valid');

      String phone = phoneController.text.trim();
      print('3. Phone number: $phone');

      if (phone.length != 10) {
        print('4. Phone validation failed');
        Get.snackbar('Error', 'Please enter a valid 10-digit phone number');
        return;
      }

      String fullPhoneNumber = phone;
      print('5. Full phone: $fullPhoneNumber');

      print('6. Calling authController.sendOtp()...');
      final success = await authController.sendOtp(fullPhoneNumber);
      print('7. Send OTP result: $success');

      if (success) {
        print('8. SUCCESS! Navigating to OtpVerify...');
        Get.to(() => OtpVerify(phoneNumber: fullPhoneNumber));
        print('9. Navigation command sent');
      } else {
        print('8. FAILED! Not navigating');
      }
    } else {
      print('2. Form validation failed');
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   var height = MediaQuery.of(context).size.height - 200;
  //   return Scaffold(
  //     body: SafeArea(
  //       child: Center(
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               70.heightBox,
  //               SvgPicture.asset('assets/logo.svg', width: 200),
  //               80.heightBox,
  //               login.text
  //                   .size(15)
  //                   .center
  //                   .color(Colors.black54)
  //                   .fontWeight(FontWeight.bold)
  //                   .make(),
  //               20.heightBox,
  //               Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 20),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: Column(
  //                       children: [
  //                         TextFormField(
  //                           controller: phoneController,
  //                           maxLength: 10,
  //                           keyboardType: TextInputType.phone,
  //                           decoration: InputDecoration(
  //                             counterText: '',
  //                             labelText: 'Enter your mobile number',
  //                             labelStyle: TextStyle(color: Colors.grey),
  //                             floatingLabelStyle: TextStyle(
  //                               color: Colors.deepOrangeAccent,
  //                             ),
  //                             hintText: 'Ex. 9876543210',
  //                             hintStyle: TextStyle(color: Colors.grey),
  //                             prefixText: '+91 ',
  //                             border: OutlineInputBorder(),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                 color: Colors.deepOrangeAccent,
  //                                 width: 2,
  //                               ),
  //                             ),
  //                           ),
  //                           validator: (value) {
  //                             if (value == null || value.isEmpty) {
  //                               return 'Please enter your phone number';
  //                             }
  //                             if (value.length != 10) {
  //                               return 'Please enter a valid 10-digit number';
  //                             }
  //                             return null;
  //                           },
  //                         ),
  //                         20.heightBox,
  //                         // Error message
  //                         Obx(
  //                           () => authController.error.isNotEmpty
  //                               ? Text(
  //                                   authController.error.value,
  //                                   style: TextStyle(
  //                                     color: Colors.red,
  //                                     fontSize: 14,
  //                                   ),
  //                                   textAlign: TextAlign.center,
  //                                 )
  //                               : SizedBox.shrink(),
  //                         ),
  //                         const Spacer(),
  //                         Obx(
  //                           () => SizedBox(
  //                             width: double.infinity,
  //                             height: 40,
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(17),
  //                                 ),
  //                                 backgroundColor: Colors.deepOrangeAccent,
  //                                 foregroundColor: Colors.white,
  //                               ),
  //                               onPressed: authController.isLoading.value
  //                                   ? null
  //                                   : _sendOtp,
  //                               child: authController.isLoading.value
  //                                   ? SizedBox(
  //                                       height: 20,
  //                                       width: 20,
  //                                       child: CircularProgressIndicator(
  //                                         strokeWidth: 2,
  //                                         valueColor:
  //                                             AlwaysStoppedAnimation<Color>(
  //                                               Colors.white,
  //                                             ),
  //                                       ),
  //                                     )
  //                                   : const Text('Send OTP'),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      70.heightBox,
                      SvgPicture.asset('assets/logo.svg', width: 200),
                      80.heightBox,
                      login.text
                          .size(15)
                          .center
                          .color(Colors.black54)
                          .fontWeight(FontWeight.bold)
                          .make(),
                      20.heightBox,

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: phoneController,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  counterText: '',
                                  labelText: 'Enter your mobile number',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                  ),
                                  hintText: 'Ex. 1234567890',
                                  prefixText: '+91 ',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (value.length != 10) {
                                    return 'Please enter a valid 10-digit number';
                                  }
                                  return null;
                                },
                              ),
                              14.heightBox,

                              Obx(
                                () => authController.error.isNotEmpty
                                    ? Text(
                                        'Something went wrong!',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // BUTTON AT BOTTOM
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            backgroundColor: Colors.deepOrangeAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : _sendOtp,
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Send OTP'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
