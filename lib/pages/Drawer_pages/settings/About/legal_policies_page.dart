import 'package:flutter/material.dart';

class LegalPoliciesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Legal and Policies'),
      ),
      body: Center(
        child: Text(
          'This is the Legal and Policies page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
