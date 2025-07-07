import 'package:eneam/screens/atd_history_screen.dart';
import 'package:eneam/screens/profile_screen.dart';
import 'package:eneam/screens/scanqrcode_screen.dart';
import 'package:eneam/screens/timetable_screen.dart';
import 'package:eneam/screens/senator_home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:eneam/screens/faq_chatbot.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final bool isSenator;
  final String nom;  // Ajout du prénom

  const HomeScreen({
    super.key,
    this.isSenator = false,  // Par défaut, pas sénateur
    required this.nom,     // nom requis
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFAQChatBot(context),
        backgroundColor: const Color(0xFF0D147F),
        child: const Icon(Icons.chat, color: Colors.white),
        tooltip: 'Assistant FAQ',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              children: [
                const SizedBox(height: 20),
                // Header avec profil modernisé
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salut,',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2D3748).withOpacity(0.8),
                            ),
                          ),
                          Text(
                            nom.isNotEmpty ? nom : 'Utilisateur',
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
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
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4C51BF),
                              Color(0xFF0D147F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(27.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C51BF).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Image centrale avec conteneur décoré
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Lottie.asset(
                      'assets/presence.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Section Menu avec titre
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu Principal',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Boutons de navigation modernisés
                Expanded(
                  child: ListView(
                    children: [
                      _buildModernMenuButton(
                        context,
                        icon: Icons.history,
                        title: 'Historique de Présences',
                        subtitle: 'Consultez vos présences passées',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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

                      const SizedBox(height: 15),

                      _buildModernMenuButton(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Mon Emploi du Temps',
                        subtitle: 'Visualisez votre planning',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
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

                      const SizedBox(height: 15),

                      _buildModernMenuButton(
                        context,
                        icon: Icons.qr_code_scanner,
                        title: 'Scanner pour valider',
                        subtitle: 'Scannez un QR code pour marquer votre présence',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanQRCodeScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      _buildModernMenuButton(
                        context,
                        icon: Icons.person_add,
                        title: 'Je suis un Sénateur',
                        subtitle: isSenator
                            ? 'Accédez à vos fonctions de sénateur'
                            : 'Fonction non disponible',
                        gradient: isSenator
                            ? const LinearGradient(
                          colors: [Color(0xFF1C2674), Color(0xFFFECFEF)],
                        )
                            : LinearGradient(
                          colors: [
                            Colors.grey.shade400,
                            Colors.grey.shade600,
                          ],
                        ),
                        isEnabled: isSenator,
                        onTap: isSenator
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SenateurScreen(),
                            ),
                          );
                        }
                            : null,
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

  Widget _buildModernMenuButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Gradient gradient,
        required VoidCallback? onTap,
        bool isEnabled = true,
      }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isEnabled ? gradient : null,
          color: !isEnabled ? Colors.grey.shade400 : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: isEnabled
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isEnabled
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}