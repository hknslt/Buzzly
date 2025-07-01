import 'package:flutter/material.dart';

class AccountInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Information'),
      ),
      body: Center(
        child: Text(
          'This is the Account Information page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
