import 'package:flowers_app/screens/login.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flowers_app',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
