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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA),
              Color(0xFF4C51BF),
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
                // Header
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
                        margin: const EdgeInsets.only(right: 44),
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

                SizedBox(height: screenHeight * 0.08),

                // Zone de scan ou illustration
                Expanded(
                  flex: 3,
                  child: isScanning && cameraController != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MobileScanner(
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
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                      // Bouton Scanner
                      _buildActionButton(
                        context,
                        icon: isScanning ? Icons.stop : Icons.qr_code_scanner,
                        title: isScanning ? 'Arrêter le scan' : 'Scanner un QR Code',
                        isPrimary: true,
                        onTap: () {
                          if (isScanning) {
                            _stopScanning();
                          } else {
                            _startScanning();
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Autres boutons
                      if (!isScanning) ...[
                        _buildActionButton(
                          context,
                          icon: Icons.history,
                          title: 'Historiques de Présences',
                          isPrimary: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceHistoryScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

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