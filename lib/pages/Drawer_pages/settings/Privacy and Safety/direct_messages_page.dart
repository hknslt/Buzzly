import 'package:flutter/material.dart';

class DirectMessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct Messages Settings'),
      ),
      body: Center(
        child: Text(
          'This is the Direct Messages Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
