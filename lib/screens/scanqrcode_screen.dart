import 'package:flutter/material.dart';

class ScanQRCodeScreen extends StatelessWidget {
  const ScanQRCodeScreen({super.key});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header avec bouton retour et titre
                Row(
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
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        'Scanner QR Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ],
                ),


                // Zone de scan avec illustration
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Image.asset(
                          'assets/scan.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(

                  children: [
                    // Bouton Scanner un QR Code
                    _buildActionButton(
                      context,
                      icon: Icons.qr_code_scanner,
                      title: 'Scanner un QR Code',
                      isPrimary: true,
                      onTap: () {
                        // Lancer le scanner
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lancement du scanner QR')),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    // Bouton Historiques de Présences
                    _buildActionButton(
                      context,
                      icon: Icons.history,
                      title: 'Historiques de Présences',
                      isPrimary: false,
                      onTap: () {
                        // Navigation vers historiques
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Navigation vers Historiques')),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    // Bouton Retourner à l'accueil
                    _buildActionButton(
                      context,
                      icon: Icons.home,
                      title: 'Retourner à l\'accueil',
                      isPrimary: false,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool isPrimary,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF4C51BF) : const Color(0xFF4C51BF).withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C51BF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(17.5),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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