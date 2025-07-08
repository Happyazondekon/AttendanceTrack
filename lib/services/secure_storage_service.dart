import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user.dart';


class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    try {
      final userData = json.encode(user.toJson());
      await _storage.write(key: _userKey, value: userData);
      print('User sauvegardé avec token: ${user.token}');
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  Future<User?> getUser() async {
    try {
      final userData = await _storage.read(key: _userKey);
      if (userData != null) {
        final user = User.fromJson(json.decode(userData));
        print('User récupéré avec token: ${user.token}');
        return user;
      }
      print('Aucun utilisateur trouvé dans le stockage');
      return null;
    } catch (e) {
      print('Erreur lors de la récupération: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}