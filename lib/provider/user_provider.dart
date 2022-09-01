import 'package:flutter/material.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => user!;

  Future<void> refreshUser() async {
    User user1 = await _authMethods.getUserDetails();
    user = user1;
    notifyListeners();
  }
}