// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jitco_app/screens/Home/A_Home%20and%20Drawer/Home_Drawer/drawer_screens/D_About/learn_more.dart';
// import 'package:jitco_app/screens/Home/A_Home%20and%20Drawer/Home_Drawer/drawer_screens/D_About/A_widgets/video_player_aboutUs.dart';
// import 'package:jitco_app/widgets/images.dart';
// import 'package:velocity_x/velocity_x.dart';

// class VideoStack extends StatelessWidget {
//   const VideoStack({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Full-screen video
//         AutoPlayVideo(videoPath: aboutUsVideo, fit: BoxFit.cover),

//         // Optional overlay content (text/buttons) on top of video
//         Positioned(
//           top: 250,
//           right: 20,
//           left: 20,
//           child: Center(
//             child: Column(
//               children: [
//                 Text(
//                   "Your One–Stop Solution for All HORECA Needs",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 6,
//                         color: Colors.black.withOpacity(0.6),
//                         offset: const Offset(2, 2),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 10.heightBox,
//                 Text(
//                   "Comprehensive Products and Services Tailored for Hotels, Restaurants, Cafes, Institutions, Caterers & Corporates.",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 6,
//                         color: Colors.black.withOpacity(0.6),
//                         offset: const Offset(2, 2),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 20.heightBox,
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1), // Shadow color
//                         blurRadius: 6, // How soft the shadow is
//                         offset: Offset(2, 4), // Position of the shadow
//                       ),
//                     ],
//                   ),
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: Colors.white),
//                       foregroundColor: Colors.white,
//                       // backgroundColor: Colors.white,
//                     ),
//                     onPressed: () {
//                       Get.to(
//                         () => LearnMore(),
//                         transition: Transition.rightToLeft,
//                       );
//                     },
//                     child: const Text('Learn More'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
