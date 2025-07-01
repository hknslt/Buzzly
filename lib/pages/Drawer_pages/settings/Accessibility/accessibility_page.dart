import 'package:flutter/material.dart';

class AccessibilityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accessibility Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Accessibility Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
