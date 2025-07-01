import 'package:flutter/material.dart';

class AppsSessionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apps and Sessions'),
      ),
      body: Center(
        child: Text(
          'This is the Apps and Sessions page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
