import 'package:flutter/material.dart';

class ScanQRCodeScreen extends StatelessWidget {
  const ScanQRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA), // Lavande clair
              Color(0xFF4C51BF), // Bleu profond
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header avec bouton retour et titre
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF4C51BF).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1A202C),
                          size: 22,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 44), // Compense la largeur du bouton retour
                        child: const Text(
                          'Scanner QR Code',
                          style: TextStyle(
                            fontFamily: 'Cabin',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A365D),
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                // Espace flexible pour centrer le QR code
                SizedBox(height: screenHeight * 0.08),

                // Zone d'illustration principale
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration scan.png
                        SizedBox(
                          height: screenHeight * 0.4,
                          child: Image.asset(
                            'assets/scan.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Boutons d'action
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bouton Scanner un QR Code
                      _buildActionButton(
                        context,
                        icon: Icons.qr_code_scanner,
                        title: 'Scanner un QR Code',
                        isPrimary: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lancement du scanner QR')),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Bouton Historiques de Présences
                      _buildActionButton(
                        context,
                        icon: Icons.history,
                        title: 'Historiques de Présences',
                        isPrimary: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigation vers Historiques')),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

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
                ),

                const SizedBox(height: 24),
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
        height: 64,
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF4C51BF)
              : const Color(0xFF4C51BF).withOpacity(0.85),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C51BF).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
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