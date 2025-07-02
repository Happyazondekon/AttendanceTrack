import '../models/user.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  User? _user;

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  User? get user => _user;

  void setUser(User user) {
    _user = user;
  }

  void clearUser() {
    _user = null;
  }
}
