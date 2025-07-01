import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Preferences'),
      ),
      body: Center(
        child: Text(
          'This is the Notification Preferences page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
