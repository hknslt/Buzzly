import 'package:flutter/material.dart';

class SecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Security Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
