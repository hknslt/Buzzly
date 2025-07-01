import 'package:flutter/material.dart';

class LanguagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Languages Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Languages Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
