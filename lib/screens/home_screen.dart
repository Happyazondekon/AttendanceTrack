import 'package:eneam/screens/atd_history_screen.dart';
import 'package:eneam/screens/profile_screen.dart';
import 'package:eneam/screens/scanqrcode_screen.dart';
import 'package:eneam/screens/timetable_screen.dart';
import 'package:eneam/screens/senator_home_screen.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final bool isSenator;

  const HomeScreen({
    super.key,
    this.isSenator = false, // Par défaut, l'utilisateur n'est pas sénateur
  });

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Header avec profil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bonjour Jordy',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(0xFF4C51BF),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4C51BF),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),


          // Image centrale depuis assets
          SizedBox(
            height: 250,
            child: Image.asset(
              'assets/home.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // Boutons de navigation
          Column(
            children: [
              // Historiques de Présences
              _buildMenuButton(
                context,
                icon: Icons.history,
                title: 'Historiques de Présences',
                onTap: () {
                  // Navigation vers l'historique
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AttendanceHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Mon Emploi du Temps
              _buildMenuButton(
                context,
                icon: Icons.schedule,
                title: 'Mon Emploi du Temps',
                onTap: () {
                  // Navigation vers l'emploi du temps
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EmploiDuTempsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Scanner pour valider
              _buildMenuButton(
                context,
                icon: Icons.qr_code_scanner,
                title: 'Scanner pour valider',
                onTap: () {
                  // Navigation vers le scanner
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  ScanQRCodeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Je suis un Sénateur (conditionnel)
              _buildMenuButton(
                context,
                icon: Icons.person_add,
                title: 'Je suis un Sénateur',
                isEnabled: isSenator,
                onTap: isSenator ? () {
                  // Navigation vers l'espace sénateur
                 Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SenateurScreen()),
);
                } : null,
                // onTap: isSenator ? () {
                  // Navigation vers l'espace sénateur
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Navigation vers Espace Sénateur')),
                //   );
                // } : null,
              ),
            ],
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback? onTap,
        bool isEnabled = true,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF4C51BF) : const Color(0xFF9CA3AF),
          borderRadius: BorderRadius.circular(35),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: const Color(0xFF4C51BF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}