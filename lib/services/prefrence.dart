import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

Future<bool> isUsernameExists(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];
  for (var userJson in userList) {
    User user = User.fromJson(userJson);
    if (user.username == username) {
      return true;
    }
  }
  return false;
}

Future<bool> isEmailExists(String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];
  for (var userJson in userList) {
    User user = User.fromJson(userJson);
    if (user.email == email) {
      return true;
    }
  }
  return false;
}

Future<String> registerInPref(
  String userNameController,
  String emailController,
  String passwordController,
  String cityController,
  String phoneNumberController,
  String accountType,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (await isUsernameExists(userNameController)) {
    return "Username already exists! Please choose another.";
  }
  if (await isEmailExists(emailController)) {
    return "Email already exists! Please choose another.";
  }
  User newUser = User(
    username: userNameController,
    email: emailController,
    password: passwordController,
    city: cityController,
    phoneNumber: phoneNumberController,
    accountType: accountType,
  );

  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];

  userList.add(newUser.toJson());
  await prefs.setString('user_list', jsonEncode(userList));
  return "Registration successful!";
}

Future<User> login(String userName, String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];
  for (var userJson in userList) {
    User user = User.fromJson(userJson);
    if (user.username == userName && user.password == password) {
      return user;
    }
  }
  return userList[0];
}

Future<void> saveLoginCredentials(
    String userName, String password, bool rememberMe) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('remember_me', rememberMe);
  if (rememberMe) {
    await prefs.setString('saved_username', userName);
    await prefs.setString('saved_password', password);
  } else {
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
  }
}

Future<void> loadLoginCredentials(
    String userName, String password, bool rememberMe) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool rememberMe = prefs.getBool('remember_me') ?? false;
  if (rememberMe) {
    rememberMe = true;
    userName = prefs.getString('saved_username') ?? '';
    password = prefs.getString('saved_password') ?? '';
  }
}

Future<void> printAllUsers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('user_list');

  if (userData != null) {
    List<dynamic> userList = jsonDecode(userData);
    for (var userJson in userList) {
      User user = User.fromJson(userJson);
      print(
          "Username: ${user.username}, Email: ${user.email}, Type: ${user.accountType} , Password: ${user.password}");
    }
  } else {
    print("No users found.");
  }
}
