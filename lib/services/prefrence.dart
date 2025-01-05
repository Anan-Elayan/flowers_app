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

Future<String> registerUser(
  String username,
  String email,
  String password,
  String city,
  String phoneNumber,
  String accountType,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (await isUsernameExists(username)) {
    return "Username already exists! Please choose another.";
  }
  if (await isEmailExists(email)) {
    return "Email already exists! Please choose another.";
  }
  User newUser = User(
    username: username,
    email: email,
    password: password,
    city: city,
    phoneNumber: phoneNumber,
    accountType: accountType,
  );

  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];
  userList.add(newUser.toJson());
  await prefs.setString('user_list', jsonEncode(userList));
  return "Registration successful!";
}

Future<User?> login(String username, String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? existingData = prefs.getString('user_list');
  List<dynamic> userList = existingData != null ? jsonDecode(existingData) : [];
  if (userList.isEmpty) {
    print("No users found.");
    return null;
  }
  for (var userJson in userList) {
    User user = User.fromJson(userJson);
    if (user.username == username && user.password == password) {
      prefs.setString('logged_in_user', jsonEncode(user.toJson()));
      return user;
    }
  }
  print("Invalid username or password.");
  return null;
}

Future<void> saveLoginCredentials(
    String username, String password, bool rememberMe) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('remember_me', rememberMe);
  if (rememberMe) {
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  } else {
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
  }
}
