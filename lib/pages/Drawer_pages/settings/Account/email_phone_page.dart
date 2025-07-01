import 'package:flutter/material.dart';

class EmailPhonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email and Phone Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Email and Phone Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
