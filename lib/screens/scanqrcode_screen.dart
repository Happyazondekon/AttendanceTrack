import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eneam/screens/atd_submit_screen.dart';
import 'package:eneam/screens/atd_history_screen.dart';

class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({Key? key}) : super(key: key);

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen> {
  MobileScannerController? cameraController;
  bool isScanning = false;

  void _startScanning() {
    setState(() {
      isScanning = true;
      cameraController = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    });
  }

  void _stopScanning() {
    setState(() {
      isScanning = false;
      cameraController?.dispose();
      cameraController = null;
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              children: [
                const SizedBox(height: 20),
                // Header modernisé
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Scanner QR Code',
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(width: 45), // Équilibrer l'espace
                  ],
                ),

                const SizedBox(height: 30),

                // Zone de scan principale - réduite
                Container(
                  height: screenHeight * 0.35, // Hauteur fixe réduite
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: isScanning && cameraController != null
                        ? Stack(
                      children: [
                        MobileScanner(
                          controller: cameraController!,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final String? code = barcodes.first.rawValue;
                              if (code != null) {
                                _stopScanning();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PresenceValidationScreen(qrCode: code),
                                  ),
                                ).then((_) {
                                  if (mounted) {
                                    _startScanning();
                                  }
                                });
                              }
                            }
                          },
                        ),
                        // Overlay de scan avec animation
                        Center(
                          child: Container(
                            width: 200, // Réduit de 250 à 200
                            height: 200, // Réduit de 250 à 200
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Coins du cadre
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D147F),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0D147F),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        : Padding(
                      padding: const EdgeInsets.all(20.0), // Réduit de 30 à 20
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80, // Réduit de 120 à 80
                            height: 80, // Réduit de 120 à 80
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4C51BF), Color(0xFF0D147F)],
                              ),
                              borderRadius: BorderRadius.circular(40), // Ajusté
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4C51BF).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 40, // Réduit de 60 à 40
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20), // Réduit de 30 à 20
                          const Text(
                            'Prêt à scanner',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 20, // Réduit de 24 à 20
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 8), // Réduit de 10 à 8
                          Text(
                            'Appuyez sur le bouton pour commencer le scan',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 12, // Réduit de 14 à 12
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Réduit de 30 à 20

                // Section boutons
                if (!isScanning) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Actions',
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        color: Color(0xFF0D147F),
                        fontWeight: FontWeight.bold,
                        fontSize: 20, // Réduit de 22 à 20
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Réduit de 15 à 10
                ],

                // Boutons d'action - maintenant sans scroll
                Expanded(
                  child: Column(
                    children: [
                      // Bouton Scanner principal
                      _buildModernActionButton(
                        context,
                        icon: isScanning ? Icons.stop : Icons.qr_code_scanner,
                        title: isScanning ? 'Arrêter le scan' : 'Commencer le scan',
                        subtitle: isScanning
                            ? 'Touchez pour arrêter'
                            : 'Scannez un QR code pour marquer votre présence',
                        gradient: isScanning
                            ? const LinearGradient(
                          colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                        )
                            : const LinearGradient(
                          colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                        ),
                        onTap: () {
                          if (isScanning) {
                            _stopScanning();
                          } else {
                            _startScanning();
                          }
                        },
                      ),

                      if (!isScanning) ...[
                        const SizedBox(height: 12), // Réduit de 15 à 12

                        _buildModernActionButton(
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

                        _buildModernActionButton(
                          context,
                          icon: Icons.home,
                          title: 'Retour à l\'accueil',
                          subtitle: 'Retournez au menu principal',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D147F), Color(0xFF0D147F)],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
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

  Widget _buildModernActionButton(
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
}