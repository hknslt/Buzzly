import 'package:flutter/material.dart';

class MutedBlockedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muted and Blocked'),
      ),
      body: Center(
        child: Text(
          'This is the Muted and Blocked Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
