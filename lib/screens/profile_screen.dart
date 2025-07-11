import 'package:eneam/screens/atd_history_screen.dart';
import 'package:eneam/screens/home_screen.dart';
import 'package:eneam/screens/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:eneam/screens/login_screen.dart';

import '../services/user_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = UserManager().user?.email ?? 'Email non disponible';
    final userMatricule = UserManager().user?.matricule ?? 'Indisponible';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA), // Blanc en haut
              Color(0xFFE6E6FA), // Bleu foncé en bas
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header amélioré
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    _buildHeaderButton(
                      icon: Icons.logout,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 25), // Réduit de 40 à 25

                // Section Profile Card - compacte
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20), // Réduit de 25 à 20
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0D147F).withOpacity(0.4),
                        blurRadius: 15, // Réduit de 20 à 15
                        offset: const Offset(0, 8), // Réduit de 10 à 8
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0), // Réduit de 25 à 20
                    child: Column(
                      children: [
                        // Avatar avec effet - réduit
                        Stack(
                          children: [
                            Container(
                              width: 80, // Réduit de 120 à 80
                              height: 80, // Réduit de 120 à 80
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4C51BF),
                                    Color(0xFF0D147F),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4C51BF).withOpacity(0.3),
                                    blurRadius: 10, // Réduit de 15 à 10
                                    offset: const Offset(0, 4), // Réduit de 5 à 4
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40, // Réduit de 60 à 40
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15), // Réduit de 20 à 15

                        // Informations utilisateur
                        _buildUserInfoCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: userEmail,
                        ),
                        const SizedBox(height: 10), // Réduit de 15 à 10
                        _buildUserInfoCard(
                          icon: Icons.badge_outlined,
                          title: 'Matricule',
                          value: userMatricule,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Réduit de 30 à 20

                // Section Raccourcis
                const Text(
                  'Raccourcis',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    color: Color(0xFF0D147F),
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Réduit de 22 à 20
                  ),
                ),
                const SizedBox(height: 10), // Réduit de 15 à 10

                Expanded(
                  child: Column( // Remplacé ListView par Column
                    children: [
                      _buildModernButton(
                        context,
                        icon: Icons.history,
                        title: 'Historique de Présences',
                        subtitle: 'Consultez vos présences passées',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12), // Réduit de 15 à 12
                      _buildModernButton(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Mon Emploi du Temps',
                        subtitle: 'Visualisez votre planning',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmploiDuTempsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12), // Réduit de 15 à 12
                      _buildModernButton(
                        context,
                        icon: Icons.home_outlined,
                        title: 'Retour à l\'Accueil',
                        subtitle: 'Retournez au menu principal',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(nom: '',),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(22.5),
          border: Border.all(
            color: const Color(0xFF4C51BF).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2D3748),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildUserInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Réduit de 15 à 12
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12), // Réduit de 15 à 12
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35, // Réduit de 40 à 35
            height: 35, // Réduit de 40 à 35
            decoration: BoxDecoration(
              color: const Color(0xFF4C51BF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(17.5), // Ajusté
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4C51BF),
              size: 18, // Réduit de 20 à 18
            ),
          ),
          const SizedBox(width: 12), // Réduit de 15 à 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 11, // Réduit de 12 à 11
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 14, // Réduit de 16 à 14
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16), // Réduit de 20 à 16
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18), // Réduit de 20 à 18
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8, // Réduit de 10 à 8
              offset: const Offset(0, 4), // Réduit de 5 à 4
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45, // Réduit de 50 à 45
              height: 45, // Réduit de 50 à 45
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(22.5), // Ajusté
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22, // Réduit de 24 à 22
              ),
            ),
            const SizedBox(width: 12), // Réduit de 15 à 12
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white,
                      fontSize: 15, // Réduit de 16 à 15
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11, // Réduit de 12 à 11
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 14, // Réduit de 16 à 14
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout,
                color: Color(0xFF4C51BF),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(
              fontFamily: 'Cabin',
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D147F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(
                  fontFamily: 'Cabin',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {  // Ajout du async
    try {
      // Nettoyer les données utilisateur de manière sécurisée
      await UserManager().clearUser();  // Utilisation de await car maintenant c'est asynchrone

      // Afficher un message de confirmation
      if (context.mounted) {  // Vérification que le contexte est toujours valide
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Déconnexion réussie',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Redirection vers l'écran de connexion en effaçant la pile de navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,  // Ceci supprime toutes les routes précédentes
        );
      }
    } catch (e) {
      if (context.mounted) {  // Vérification que le contexte est toujours valide
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Erreur lors de la déconnexion',
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}