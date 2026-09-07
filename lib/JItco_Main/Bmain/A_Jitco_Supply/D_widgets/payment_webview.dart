import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onPaymentSuccess;
  final VoidCallback? onPaymentFailure;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.onPaymentSuccess,
    this.onPaymentFailure,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('PAYMENT WEBVIEW: Page started loading: $url');
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            print('PAYMENT WEBVIEW: Page finished loading: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            print('PAYMENT WEBVIEW: Navigation to: $url');

            // Detect success redirect
            if (_isSuccessUrl(url)) {
              print('PAYMENT WEBVIEW: ✅ Payment SUCCESS detected!');
              _handleSuccess();
              return NavigationDecision.prevent;
            }

            // Detect failure redirect
            if (_isFailureUrl(url)) {
              print('PAYMENT WEBVIEW: ❌ Payment FAILURE detected!');
              _handleFailure();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('PAYMENT WEBVIEW: Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _isSuccessUrl(String url) {
    return url.contains('payment/success') ||
        url.contains('payment-success') ||
        url.contains('status=success') ||
        url.contains('payment_success') ||
        url.contains('/success');
  }

  bool _isFailureUrl(String url) {
    return url.contains('payment/fail') ||
        url.contains('payment-fail') ||
        url.contains('status=fail') ||
        url.contains('payment_fail') ||
        url.contains('payment/cancel') ||
        url.contains('payment-cancel') ||
        url.contains('/failure') ||
        url.contains('/cancel');
  }

  void _handleSuccess() {
    if (!mounted) return;
    Navigator.of(context).pop(); // Close WebView
    widget.onPaymentSuccess();
  }

  void _handleFailure() {
    if (!mounted) return;
    Navigator.of(context).pop(); // Close WebView
    if (widget.onPaymentFailure != null) {
      widget.onPaymentFailure!();
    } else {
      Get.snackbar(
        'Payment Failed',
        'Your payment was not completed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Show confirmation before cancelling payment
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Cancel Payment?'),
                content: const Text(
                    'Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(
                    child: const Text('No, Continue'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  TextButton(
                    child: const Text(
                      'Yes, Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // close dialog
                      Navigator.of(context).pop(); // close webview
                    },
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}
