import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/token_service.dart';

class PresenceValidationScreen extends StatefulWidget {
  final String qrCode;

  const PresenceValidationScreen({
    Key? key,
    required this.qrCode,
  }) : super(key: key);

  @override
  _PresenceValidationScreenState createState() => _PresenceValidationScreenState();
}

class _PresenceValidationScreenState extends State<PresenceValidationScreen> {
  bool isSubmitting = false;

  Future<void> atdSubmit() async {
    setState(() => isSubmitting = true);

    try {
      // Vérifier et demander les permissions de localisation
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Service de localisation désactivé.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          throw Exception('Permission de localisation refusée.');
        }
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Récupérer le token de l’utilisateur
      final token = await TokenService().getToken();
      if (token == null) throw Exception("Token utilisateur non disponible.");

      // Envoyer la requête
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/valider'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'qr_code': widget.qrCode,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Présence validée avec succès."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retour automatique
      } else {
        throw Exception(data['message'] ?? "Échec de la validation.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Valider Présence'),
          ],
        ),
        content: const Text("Confirmez-vous votre présence ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              atdSubmit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C51BF)),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E6FA), Color(0xFF4C51BF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Valider Présence",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // Placeholder pour alignement
                  ],
                ),
                const Spacer(),
                _buildMenuButton(
                  context,
                  title: "Valider la présence",
                  icon: Icons.person,
                  onTap: isSubmitting ? null : _showValidationDialog,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF4C51BF),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C51BF).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
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
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
