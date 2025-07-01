import 'package:flutter/material.dart';

class LanguageRegionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language and Region'),
      ),
      body: Center(
        child: Text(
          'This is the Language and Region page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
