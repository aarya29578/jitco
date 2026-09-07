//FORM CREATED BY V
// import 'package:flutter/material.dart';
// import 'package:get/get_connect/http/src/utils/utils.dart';
// import 'package:jitco_app/widgets/form_unknown_user.dart';
// import 'package:velocity_x/velocity_x.dart';
// class Contact extends StatefulWidget {
//   const Contact({super.key});
//   @override
//   State<Contact> createState() => _ContactState();
// }
// class _ContactState extends State<Contact> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController commentController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Contact Us'),
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Get in Touch. We are Here to Help!',
//                   style: TextStyle(
//                     fontSize: 25,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 20.heightBox,
//                 // Text Fields
//                 FormUnknownUser(
//                   formTitle: 'Name *',
//                   controller: nameController,
//                 ),
//                 FormUnknownUser(
//                   formTitle: 'Email *',
//                   controller: emailController,
//                 ),
//                 FormUnknownUser(
//                   formTitle: 'Phone number *',
//                   controller: phoneController,
//                 ),
//                 10.heightBox,
//                 Text(
//                   'Comments',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 10.heightBox,
//                 TextFormField(
//                   keyboardType: TextInputType.multiline,
//                   minLines: 5,
//                   maxLines: 8,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(
//                         color: Colors.deepOrangeAccent,
//                         width: 2,
//                       ),
//                     ),
//                     hintText: "How can we help you?",
//                     contentPadding: EdgeInsets.all(16),
//                   ),
//                 ),
//                 40.heightBox,
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       backgroundColor: Colors.orange.shade700,
//                     ),
//                     onPressed: () {},
//                     child: const Text(
//                       'Submit',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 10.heightBox,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

///*************************************** WEB VIEW ************************************* */
///
///METHOD - 1
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// class Contact extends StatefulWidget {
//   const Contact({super.key});
//   @override
//   State<Contact> createState() => _ContactState();
// }
// class _ContactState extends State<Contact> {
//   late final WebViewController controller;
//   @override
//   void initState() {
//     super.initState();
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse('https://jitco.in/contact'));
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // appBar: AppBar(title: Text("Contact Us"), backgroundColor: Colors.white),
//       body: SafeArea(child: WebViewWidget(controller: controller)),
//     );
//   }
// }

///METHOD - 2
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late final WebViewController controller;
  bool isLoading = true;
  int progress = 0; // 0 - 100

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int p) {
            // update progress if you want a linear indicator
            setState(() {
              progress = p;
              // treat progress < 100 as loading
              isLoading = p < 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            // page finished loading — hide loader and inject CSS/JS
            setState(() {
              isLoading = false;
              progress = 100;
            });

            // Inject CSS/JS to hide header/footer and remove spacing
            controller.runJavaScript("""
              // Hide header / navbar / footer
              var header = document.querySelector('header');
              if(header) header.style.display = 'none';

              var nav = document.querySelector('nav');
              if(nav) nav.style.display = 'none';

              var footer = document.querySelector('footer');
              if(footer) footer.style.display = 'none';

              // Remove page container spacing
              var container = document.querySelector('.container') ||
                              document.querySelector('#main-content') ||
                              document.body;

              if (container) {
                container.style.marginTop = '0';
                container.style.marginBottom = '0';
                container.style.paddingTop = '0';
                container.style.paddingBottom = '0';
              }

              // Remove body spacing
              document.body.style.margin = '0';
              document.body.style.padding = '0';
            """);
          },
          onWebResourceError: (error) {
            // hide loader on error
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jitco.in/contact'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // The WebView
          SafeArea(child: WebViewWidget(controller: controller)),

          // Center circular loader while loading
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8), // optional dim background
              child: const Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
