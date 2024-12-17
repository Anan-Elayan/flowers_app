import 'package:flowers_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
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
              return const Text("Welcome Admin");
            } else if (snapshot.hasData && snapshot.data != null) {
              return Text("Welcome ${snapshot.data}");
            } else {
              return const Text("Welcome Admin");
            }
          },
        ),
      ),
      body: const Center(
        child: Text("Admin Panel Page"),
      ),
    );
  }
}
