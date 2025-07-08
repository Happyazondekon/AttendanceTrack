import '../models/user.dart';
import 'secure_storage_service.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  User? _user;

  User? get user => _user;

  Future<void> setUser(User user) async {
    _user = user;
    await _secureStorage.saveUser(user);
    print('UserManager - Utilisateur sauvegardé avec token: ${user.token}');
  }

  Future<void> loadUser() async {
    _user = await _secureStorage.getUser();
    if (_user != null) {
      print('UserManager - Utilisateur chargé avec token: ${_user!.token}');
    } else {
      print('UserManager - Aucun utilisateur trouvé');
    }
  }

  Future<void> clearUser() async {
    _user = null;
    await _secureStorage.clearUser();
    print('UserManager - Utilisateur supprimé');
  }

  bool get isLoggedIn => _user != null && _user!.token != null;
}