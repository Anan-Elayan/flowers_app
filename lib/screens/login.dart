import 'package:flowers_app/components/custom_button.dart';
import 'package:flowers_app/components/custom_text_fields.dart';
import 'package:flowers_app/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import '../services/prefrence.dart';
import 'admin_panel.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  User? user;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      user = await login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        await saveLoginCredentials(_usernameController.text.trim(),
            _passwordController.text.trim(), _rememberMe);
      }
      if (user?.accountType == 'User') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPanel(),
          ),
        );
      }
    }
  }

  Future<void> _loadLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  @override
  void initState() {
    _loadLoginCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A5A40),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Icon(
                          Icons.local_florist,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5A40),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Column(
                    children: [
                      CustomTextFields(
                        txtLabel: "User Name",
                        txtPrefixIcon: Icons.account_circle,
                        controller: _usernameController,
                        isVisibleContent: false,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFields(
                        txtLabel: "Password",
                        txtPrefixIcon: Icons.lock,
                        controller: _passwordController,
                        isVisibleContent: true,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the Password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: const Color(0xFF588157),
                        checkColor: Colors.white,
                        value: _rememberMe,
                        onChanged: (newValue) {
                          setState(() {
                            _rememberMe = newValue!;
                          });
                        },
                      ),
                      const Text("Remember Me"),
                    ],
                  ),
                ),
                // Login Button
                CustomButton(
                  buttonText: "Login",
                  bgButtonColor: const Color(0xFF588157),
                  onPress: () {
                    _login();
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFF3A5A40),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
