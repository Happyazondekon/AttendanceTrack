import '../models/user.dart';
import '../services/user_manager.dart';

class TokenService {
  Future<String?> getToken() async {
    final userManager = UserManager();
    final user = userManager.user;
    return user?.token;
  }
}
