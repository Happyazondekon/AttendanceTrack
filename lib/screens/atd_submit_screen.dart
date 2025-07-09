import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/token_service.dart';
import '../services/user_manager.dart';

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

      // Récupérer le token avec débogage amélioré
      print('=== DEBUT DEBUG TOKEN ===');
      final userManager = UserManager();
      await userManager.loadUser();
      final user = userManager.user;

      print('User existe: ${user != null}');
      if (user != null) {
        print('User ID: ${user.id}');
        print('User nom: ${user.nom}');
        print('User email: ${user.email}');
        print('Token existe: ${user.token != null}');
        print('Token complet: ${user.token}');
        print('Token length: ${user.token?.length}');
      }

      final rawToken = await TokenService().getToken();
      // CORRECTION 1: Vérifier si le token contient "|" avant de le diviser
      String? token;
      if (rawToken != null && rawToken.contains('|')) {
        token = rawToken.split('|').last;
        print('Token avec préfixe détecté, token extrait: $token');
      } else {
        token = rawToken;
        print('Token sans préfixe: $token');
      }

      print('UserManager isLoggedIn: ${userManager.isLoggedIn}');
      print('=== FIN DEBUG TOKEN ===');

      if (token == null || token.isEmpty) {
        throw Exception("Token utilisateur non disponible. Veuillez vous reconnecter.");
      }

      // CORRECTION 2: Convertir les coordonnées en string avec plus de précision
      final requestData = {
        'qr_code': widget.qrCode,
        'latitude': position.latitude.toStringAsFixed(6), // Plus de précision
        'longitude': position.longitude.toStringAsFixed(6), // Plus de précision
      };

      print('=== DEBUT DEBUG REQUETE ===');
      print('URL: https://eneam2025.onrender.com/api/valider');
      print('Headers: Authorization: Bearer $token');
      print('Data: $requestData');
      print('Position exacte: ${position.latitude}, ${position.longitude}');
      print('Précision: ${position.accuracy}');
      print('=== FIN DEBUG REQUETE ===');

      // CORRECTION 3: Ajouter un timeout et améliorer les headers
      final response = await http.post(
        Uri.parse('https://eneam2025.onrender.com/api/valider'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'User-Agent': 'Flutter-App/1.0', // Ajouter User-Agent
        },
        body: json.encode(requestData),
      ).timeout(
        const Duration(seconds: 30), // Timeout de 30 secondes
        onTimeout: () {
          throw Exception('Timeout: La requête a pris trop de temps');
        },
      );

      print('=== DEBUT DEBUG REPONSE ===');
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');
      print('=== FIN DEBUG REPONSE ===');

      // CORRECTION 4: Améliorer la gestion des réponses
      if (response.body.isEmpty) {
        throw Exception('Réponse vide du serveur');
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Présence validée avec succès.",
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // CORRECTION 5: Améliorer la gestion des erreurs spécifiques
        String errorMessage;
        if (response.statusCode == 401) {
          errorMessage = "Token expiré. Veuillez vous reconnecter.";
        } else if (response.statusCode == 403) {
          // Erreur spécifique pour les permissions/localisation
          errorMessage = data['message'] ?? "Accès refusé. Vérifiez votre localisation ou vos permissions.";
        } else if (response.statusCode == 422) {
          errorMessage = data['message'] ?? "Données invalides.";
        } else if (response.statusCode == 409) {
          errorMessage = data['message'] ?? "Présence déjà validée.";
        } else {
          errorMessage = data['message'] ?? "Échec de la validation. Code: ${response.statusCode}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('=== ERREUR COMPLETE ===');
      print('Type d\'erreur: ${e.runtimeType}');
      print('Message d\'erreur: $e');
      print('Stack trace: ${StackTrace.current}');
      print('=== FIN ERREUR ===');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur : ${e.toString()}",
              style: const TextStyle(
                fontFamily: 'Cabin',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  // CORRECTION 6: Méthode pour tester la connectivité
  Future<bool> testConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('https://eneam2025.onrender.com/api/test'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('Test connectivité échoué: $e');
      return false;
    }
  }

  // CORRECTION 7: Méthode pour vérifier les permissions avant validation
  Future<bool> checkAllPermissions() async {
    // Vérifier service de localisation
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez activer le service de localisation'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    // Vérifier permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission de localisation refusée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission de localisation refusée définitivement. Veuillez l\'activer dans les paramètres.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C51BF), Color(0xFF0D147F)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C51BF).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Valider Présence',
              style: TextStyle(
                fontFamily: 'Cabin',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Confirmez-vous votre présence ?",
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF4C51BF).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code,
                      color: Color(0xFF4C51BF),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "QR Code: ${widget.qrCode}",
                        style: const TextStyle(
                          fontFamily: 'Cabin',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    Navigator.pop(context);
                    // CORRECTION 8: Vérifier les permissions avant de soumettre
                    if (await checkAllPermissions()) {
                      atdSubmit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C51BF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF4C51BF).withOpacity(0.3),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Valider',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
                      "Valider Présence",
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

                const SizedBox(height: 40),

                // Zone principale avec informations
                Expanded(
                  flex: 3,
                  child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icône principale
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4C51BF), Color(0xFF0D147F)],
                              ),
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4C51BF).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.how_to_reg,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Titre principal
                          const Text(
                            'Validation de Présence',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 15),

                          // Informations QR Code
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF4C51BF).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color: Color(0xFF4C51BF),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'QR Code Scanné',
                                      style: TextStyle(
                                        fontFamily: 'Cabin',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4C51BF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.qrCode,
                                  style: TextStyle(
                                    fontFamily: 'Cabin',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Message informatif
                          Text(
                            'Appuyez sur le bouton ci-dessous pour confirmer votre présence',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Section Actions
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontFamily: 'Cabin',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Bouton principal de validation
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildModernActionButton(
                        context,
                        icon: isSubmitting ? Icons.hourglass_empty : Icons.how_to_reg,
                        title: isSubmitting ? "Validation en cours..." : "Valider ma présence",
                        subtitle: isSubmitting
                            ? "Veuillez patienter pendant la validation"
                            : "Confirmer votre présence avec géolocalisation",
                        gradient: isSubmitting
                            ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade600],
                        )
                            : const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        onTap: isSubmitting ? null : _showValidationDialog,
                        isEnabled: !isSubmitting,
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

  Widget _buildModernActionButton(
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
              child: isSubmitting
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(
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
            if (!isSubmitting)
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