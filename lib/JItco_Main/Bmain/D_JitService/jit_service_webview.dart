import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JitService extends StatefulWidget {
  const JitService({super.key});

  @override
  State<JitService> createState() => _JitServiceState();
}

class _JitServiceState extends State<JitService> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _removeFooter();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jitco-web.salt-tech.com/services'));
  }

  void _removeFooter() {
    controller.runJavaScript("""
      var footer = document.querySelector('footer')
        || document.querySelector('.footer')
        || document.querySelector('#footer');

      if (footer) {
        footer.style.display = 'none';
      }
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
