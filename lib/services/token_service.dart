import '../models/user.dart';
import '../services/user_manager.dart';

class TokenService {
  Future<String?> getToken() async {
    final userManager = UserManager();

    // Charger l'utilisateur depuis le stockage sécurisé si pas déjà chargé
    if (userManager.user == null) {
      await userManager.loadUser();
    }

    final user = userManager.user;

    // Ajout de débogage
    print('TokenService - User: ${user?.nom}');
    print('TokenService - Token: ${user?.token}');
    print('TokenService - User is logged in: ${userManager.isLoggedIn}');

    return user?.token;
  }
}