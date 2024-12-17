import 'package:flowers_app/services/prefrence.dart';
import 'package:flutter/material.dart';

import '../components/custom_text_fields.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String accountType = "User";

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      String result = await registerInPref(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _cityController.text.trim(),
        _phoneNumberController.text.trim(),
        accountType,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      if (result == "Registration successful!") {
        printAllUsers();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A5A40),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Icon(
                          Icons.app_registration,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  "Create an Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5A40),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  child: Column(
                    children: [
                      CustomTextFields(
                        txtLabel: "Username",
                        txtPrefixIcon: Icons.account_circle,
                        isVisibleContent: false,
                        controller: _usernameController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextFields(
                        txtLabel: "Email",
                        txtPrefixIcon: Icons.email,
                        isVisibleContent: false,
                        controller: _emailController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextFields(
                        txtLabel: "Password",
                        txtPrefixIcon: Icons.lock,
                        isVisibleContent: true,
                        controller: _passwordController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextFields(
                        txtLabel: "City",
                        txtPrefixIcon: Icons.location_city,
                        isVisibleContent: false,
                        controller: _cityController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      CustomTextFields(
                        txtLabel: "Phone Number",
                        txtPrefixIcon: Icons.phone,
                        isVisibleContent: false,
                        controller: _phoneNumberController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Account Type Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Account Type:",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: accountType,
                            items: ["User", "Admin"]
                                .map(
                                  (type) => DropdownMenuItem(
                                      value: type, child: Text(type)),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                accountType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF588157),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color(0xFF3A5A40)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
