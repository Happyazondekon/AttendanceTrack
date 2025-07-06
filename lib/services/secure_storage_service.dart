import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    final userData = json.encode(user.toJson());
    await _storage.write(key: _userKey, value: userData);
  }

  Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}