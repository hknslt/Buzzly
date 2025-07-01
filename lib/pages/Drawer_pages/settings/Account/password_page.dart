import 'package:flutter/material.dart';

class PasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Password Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
