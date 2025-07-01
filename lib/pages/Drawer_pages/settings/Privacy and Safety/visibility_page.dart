import 'package:flutter/material.dart';

class VisibilityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visibility Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Visibility Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
