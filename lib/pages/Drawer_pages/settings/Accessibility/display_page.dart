import 'package:flutter/material.dart';

class DisplayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Display Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
