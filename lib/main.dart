import 'package:firebase_deneme/layouts/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/log/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialize
  await Firebase.initializeApp();
  runApp(const BuzzlyApp());
}

class BuzzlyApp extends StatelessWidget {
  const BuzzlyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buzzly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // MainLayout(),
    );
  }
}
