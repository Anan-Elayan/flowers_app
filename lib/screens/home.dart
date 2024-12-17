import 'package:flowers_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<String?> _loadLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
        automaticallyImplyLeading: false,
        backgroundColor: thirdColor,
        title: FutureBuilder<String?>(
          future: _loadLoginCredentials(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Welcome ...");
            } else if (snapshot.hasError) {
              return const Text("Welcome Guest");
            } else if (snapshot.hasData && snapshot.data != null) {
              return Text("Welcome ${snapshot.data}");
            } else {
              return const Text("Welcome Guest");
            }
          },
        ),
      ),
      body: const Center(
        child: Text("Home page"),
      ),
    );
  }
}
