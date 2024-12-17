class User {
  String username;
  String email;
  String password;
  String city;
  String phoneNumber;
  String accountType;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.city,
    required this.phoneNumber,
    required this.accountType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'city': city,
      'phoneNumber': phoneNumber,
      'accountType': accountType,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      accountType: json['accountType'],
    );
  }
}
