import '../models/user.dart';
import 'secure_storage_service.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  final _secureStorage = SecureStorageService();
  User? _user;

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    await _secureStorage.saveUser(user);
  }

  Future<void> loadUser() async {
    _user = await _secureStorage.getUser();
  }

  Future<void> clearUser() async {
    _user = null;
    await _secureStorage.clearUser();
  }
}