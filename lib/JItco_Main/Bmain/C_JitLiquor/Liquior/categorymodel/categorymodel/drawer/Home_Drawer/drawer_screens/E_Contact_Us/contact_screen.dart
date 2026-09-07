
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class Contact extends StatefulWidget {
//   const Contact({super.key});

//   @override
//   State<Contact> createState() => _ContactState();
// }

// class _ContactState extends State<Contact> {
//   late final WebViewController controller;
//   bool isLoading = true;
//   int progress = 0; // 0 - 100

//   @override
//   void initState() {
//     super.initState();

//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int p) {
//             // update progress if you want a linear indicator
//             setState(() {
//               progress = p;
//               // treat progress < 100 as loading
//               isLoading = p < 100;
//             });
//           },
//           onPageStarted: (String url) {
//             setState(() {
//               isLoading = true;
//             });
//           },
//           onPageFinished: (String url) {
//             // page finished loading — hide loader and inject CSS/JS
//             setState(() {
//               isLoading = false;
//               progress = 100;
//             });

//             // Inject CSS/JS to hide header/footer and remove spacing
//             controller.runJavaScript("""
//               // Hide header / navbar / footer
//               var header = document.querySelector('header');
//               if(header) header.style.display = 'none';

//               var nav = document.querySelector('nav');
//               if(nav) nav.style.display = 'none';

//               var footer = document.querySelector('footer');
//               if(footer) footer.style.display = 'none';

//               // Remove page container spacing
//               var container = document.querySelector('.container') ||
//                               document.querySelector('#main-content') ||
//                               document.body;

//               if (container) {
//                 container.style.marginTop = '0';
//                 container.style.marginBottom = '0';
//                 container.style.paddingTop = '0';
//                 container.style.paddingBottom = '0';
//               }

//               // Remove body spacing
//               document.body.style.margin = '0';
//               document.body.style.padding = '0';
//             """);
//           },
//           onWebResourceError: (error) {
//             // hide loader on error
//             setState(() {
//               isLoading = false;
//             });
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://jitco.in/contact'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Contact Us'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // The WebView
//           SafeArea(child: WebViewWidget(controller: controller)),

//           // Center circular loader while loading
//           if (isLoading)
//             Container(
//               color: Colors.white.withOpacity(0.8), // optional dim background
//               child: const Center(
//                 child: SizedBox(
//                   width: 56,
//                   height: 56,
//                   child: CircularProgressIndicator(strokeWidth: 4),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
