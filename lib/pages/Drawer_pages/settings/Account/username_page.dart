import 'package:flutter/material.dart';

class UsernamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Username Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Username Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
