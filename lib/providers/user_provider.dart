import 'package:flutter/material.dart';
import '../model/user.dart';

class UserProvider extends ChangeNotifier{
  User _user = User(
    email: '',
    uid: '',
    username: ''
  );

  User get user => _user;

  setUser(User user){
    _user = user;
    notifyListeners();
  }
}