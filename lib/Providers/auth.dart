// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:construction_app/Screen/home_screen.dart';
import 'package:construction_app/constants/utils.dart';
import 'package:flutter/material.dart';
import '../utils/aes_encryption.dart';
import '../utils/app_config.dart';
import '../constants/error_handling.dart';
// import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/crud_config.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  String? _email;
  String? _name;
  String? _password;
  String? _userType;

  // String? _userRole;

  bool get isAuth {
    return userId != null;
  }

  String? get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  int? get userId {
    if (_userId != null) {
      return _userId;
    }
    return null;
  }

  String? get email {
    return _email;
  }

  String? get usertype {
    return _userType;
  }

  String? get password {
    return _password;
  }

  String? get name {
    return _name;
  }

  final CRUD _crud = CRUD();
  final AESEncryption _aesEncryption = AESEncryption();

  // Register
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String name,
    required String password,
  }) async {
    final url = Uri.parse('$uri/createuser');
    Map<String, String> header = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      "name": name,
      "user_type": "subadmin",
      "email": email,
      "password": password,
    };

    try {
      final response = await _crud.create(url, header, body);
      final responseData = json.decode(response.body);
      if (responseData['code'] == "200") {
        print("User created successfully");
        showSnackBar(context, responseData['data']['message']);
      } else {
        print("User creation failed  ${responseData['message']}");
        showSnackBar(context, responseData['message']);
      }

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // login

  Future<void> signInUser(
      {required BuildContext context,
      required String email,
      required String password}) async {
    final url = Uri.parse('$uri/login');

    Map<String, String> header = {
      'Content-Type': 'application/json',
    };
    Map<String, String> body = {"email": email, "password": password};
    try {
      final response = await _crud.create(url, header, body);

      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['code'] == '200') {
          print(responseData['data']['userDetails']['id']);
        _token = responseData['data']['token'];
        _userId = responseData['data']['userDetails']['id'];
        _email = responseData['data']['userDetails']['email'];
        _name = responseData['data']['userDetails']['name'];
        _userType = responseData['data']['userDetails']['user_type'];

        final encryptedToken = _aesEncryption.encryption(_token);
        final encryptedUserId = _aesEncryption.encryption(_userId.toString());
        final encryptedEmail = _aesEncryption.encryption(_email);
        final encryptedUsername = _aesEncryption.encryption(_name);
        final encrypteduserType = _aesEncryption.encryption(_userType);
      

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': encryptedToken,
          'userId': encryptedUserId,
          'email': encryptedEmail,
          'name': encryptedUsername,
          'usertype': encrypteduserType,
        });
        prefs.setString('userData', userData);
        print("userData $userData");
        showSnackBar(context, "Login Successfully!");
      }
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
