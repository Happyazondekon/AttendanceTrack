import 'package:eneam/screens/atd_history_screen.dart';
import 'package:eneam/screens/home_screen.dart';
import 'package:eneam/screens/timetable_screen.dart';
import 'package:flutter/material.dart';

import '../services/user_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = UserManager().user?.email ?? 'Email non disponible';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Blanc en haut
              Color(0xFF0D147F), // Bleu foncé en bas
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4C51BF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2D3748),
                          size: 20,
                        ),
                      ),
                    ),
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Action de déconnexion
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Déconnexion')),
                        );
                        // Vous pouvez ici implémenter la logique de déconnexion
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF4C51BF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Color(0xFF2D3748),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Conteneur principal du profil
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4C51BF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 60,
                                color: Color(0xFF0D147F),
                              ),
                            ),
                            // Vous pouvez ajouter ici un bouton "modifier l'avatar" si nécessaire
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Matricule : ${UserManager().user?.matricule ?? 'Indisponible'}',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Raccourcis',
                          style: TextStyle(
                            fontFamily: 'Cabin',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildProfileButton(
                        context,
                        icon: Icons.history,
                        title: 'Historiques de Présences',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendanceHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildProfileButton(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Mon Emploi du Temps',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmploiDuTempsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildProfileButton(
                        context,
                        icon: Icons.home_outlined,
                        title: 'Retourner à l\'accueil',
                        onTap: () {
                          Navigator.push(
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

  Widget _buildProfileButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF4C51BF).withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cabin',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}