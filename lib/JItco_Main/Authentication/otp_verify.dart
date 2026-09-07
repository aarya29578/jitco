import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/jitco_supply_nav_bar.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Authentication/form_screen.dart';
import 'package:jitco_app/JItco_Main/Authentication/login.dart';
import 'package:jitco_app/JItco_Main/jitco_main.dart';
import 'package:jitco_app/A_Widgets/consts/text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:velocity_x/velocity_x.dart';

class OtpVerify extends StatefulWidget {
  final String phoneNumber;

  const OtpVerify({super.key, required this.phoneNumber});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();
  String enteredOtp = '';

  Future<void> _verifyOtp() async {
    if (enteredOtp.length != 6) {
      Get.snackbar('Error', 'Please enter 6-digit OTP');
      return;
    }

    final success = await authController.verifyOtp(enteredOtp);

    if (success) {
      if (authController.isNewUser.value) {
        print('Redirecting NEW USER to registration form');
        Get.offAll(() => FormForUnknownUser());
      } else {
        print('Redirecting EXISTING USER to main app');
        Get.offAll(() => JItcoMain());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                70.heightBox,
                verifyNumber.text
                    .size(27)
                    .center
                    .fontWeight(FontWeight.bold)
                    .color(Colors.black54)
                    .make(),
                10.heightBox,
                Text(
                  'We sent a 6-digit code to ${widget.phoneNumber}',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                // 30.heightBox,
                // subVerifyNumber.text.size(16).color(Colors.black54).make(),
                50.heightBox,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: otpController,
                    onChanged: (value) {
                      setState(() {
                        enteredOtp = value;
                      });
                    },
                    onCompleted: (value) {
                      _verifyOtp();
                    },
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 42,
                      activeFillColor: Colors.white,
                      activeColor: Colors.deepOrangeAccent,
                      inactiveColor: Colors.grey,
                      selectedColor: Colors.blue,
                    ),
                  ),
                ),
                20.heightBox,
                // Error message
                Obx(
                  () => authController.error.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            authController.error.value,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                const Spacer(),
                Obx(
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
                      onPressed:
                          authController.isLoading.value ||
                              enteredOtp.length != 6
                          ? null
                          : _verifyOtp,
                      child: authController.isLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                ),
                20.heightBox,
                TextButton(
                  onPressed: () {
                    Get.offAll(Login());
                    // Get.back();
                  },
                  child: Text(
                    'Change Phone Number',
                    style: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
