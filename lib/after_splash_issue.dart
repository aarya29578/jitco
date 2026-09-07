import 'package:flutter/material.dart';

class NetworkIssueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("No Internet Connection")));
  }
}

class ServerIssueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Server Temporarily Down")));
  }
}
