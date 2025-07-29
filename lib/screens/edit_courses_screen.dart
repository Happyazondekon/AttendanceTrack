import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditCourseScreen extends StatefulWidget {
  final Map<String, dynamic>? cahierData;

  const EditCourseScreen({super.key, this.cahierData});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController enseignantController;
  late TextEditingController heureDebutController;
  late TextEditingController heureFinController;
  late TextEditingController tempsController;
  late TextEditingController libelleController;

  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  void initializeControllers() {
    final cahier = widget.cahierData;

    enseignantController = TextEditingController(
        text: cahier?['enseignant_nom'] ?? 'Enseignant non spécifié'
    );

    // Initialise les contrôleurs d'heure avec l'heure locale formatée (ex: "08h47")
    heureDebutController = TextEditingController(
        text: _formatLocalTime(cahier?['heure_debut'])
    );

    heureFinController = TextEditingController(
        text: _formatLocalTime(cahier?['heure_fin'])
    );

    tempsController = TextEditingController(
        text: "${cahier?['duree'] ?? 0} min"
    );

    libelleController = TextEditingController(
        text: cahier?['libelles'] ?? ''
    );
  }

  // Helper: Convertit une chaîne de date/heure ISO 8601 UTC en heure locale formatée (ex: "08h47")
  String _formatLocalTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "";
    try {
      DateTime dateTimeUtc = DateTime.parse(dateTimeString); // Parse comme UTC
      DateTime localDateTime = dateTimeUtc.toLocal(); // Convertir au fuseau horaire local
      return "${localDateTime.hour.toString().padLeft(2, '0')}h${localDateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print("Erreur de formatage d'heure locale: $e");
      return "";
    }
  }

  // Helper: Formate une chaîne de date/heure ISO 8601 UTC en date lisible (ex: "Mardi 29 juillet 2025")
  String formatDisplayDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Date non disponible";
    try {
      DateTime dateTimeUtc = DateTime.parse(dateTimeString); // Parse comme UTC
      DateTime localDate = dateTimeUtc.toLocal(); // Convertir au fuseau horaire local

      final List<String> jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      final List<String> mois = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

      String jourSemaine = jours[localDate.weekday - 1];
      return "$jourSemaine ${localDate.day} ${mois[localDate.month]} ${localDate.year}";
    } catch (e) {
      print("Erreur de formatage de date d'affichage: $e");
      return "Date invalide";
    }
  }

  // NOUVELLE FONCTION: Convertit l'heure saisie par l'utilisateur (ex: "14h00")
  // en format "HH:mm:ss" requis par l'API pour les champs heure_debut/heure_fin.
  String convertTimeToAPIFormat(String timeStr) {
    try {
      RegExp regExp = RegExp(r'(\d{1,2})h(\d{2})');
      Match? match = regExp.firstMatch(timeStr);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        // Le serveur s'attend à HH:mm:ss, donc on ajoute les secondes à 00
        return "${hour.toString().padLeft(2, '0')}:"
            "${minute.toString().padLeft(2, '0')}:00";
      }
    } catch (e) {
      print("Erreur conversion heure '$timeStr' vers API format: $e");
    }
    return ""; // Retourne une chaîne vide en cas d'erreur
  }


  // Calcule la durée en minutes entre deux heures locales saisies par l'utilisateur
  int calculateDuration(String heureDebut, String heureFin) {
    try {
      RegExp regExp = RegExp(r'(\d{1,2})h(\d{2})');

      Match? matchDebut = regExp.firstMatch(heureDebut);
      Match? matchFin = regExp.firstMatch(heureFin);

      if (matchDebut != null && matchFin != null) {
        int heureD = int.parse(matchDebut.group(1)!);
        int minuteD = int.parse(matchDebut.group(2)!);
        int heureF = int.parse(matchFin.group(1)!);
        int minuteF = int.parse(matchFin.group(2)!);

        DateTime dummyDate = DateTime(2000, 1, 1);
        DateTime dtDebut = DateTime(dummyDate.year, dummyDate.month, dummyDate.day, heureD, minuteD);
        DateTime dtFin = DateTime(dummyDate.year, dummyDate.month, dummyDate.day, heureF, minuteF);

        if (dtFin.isBefore(dtDebut)) {
          dtFin = dtFin.add(const Duration(days: 1));
        }

        int duree = dtFin.difference(dtDebut).inMinutes;

        setState(() {
          tempsController.text = "${duree} min";
        });

        return duree;
      }
    } catch (e) {
      print("Erreur calcul durée: $e");
    }
    return widget.cahierData?['duree'] ?? 0;
  }

  // Sauvegarde les modifications via l'API
  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final cahier = widget.cahierData;
    if (cahier == null || cahier['id'] == null) {
      _showSnackBar('Erreur: Données du cahier manquantes pour la modification', Colors.red);
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      int dureeCalculated = calculateDuration(heureDebutController.text, heureFinController.text);

      // --- MODIFICATIONS ICI pour répondre à l'erreur 422 ---
      final Map<String, dynamic> updateData = {
        'programmation_id': cahier['programmation_id'], // Ajouter ce champ
        'ecue_id': cahier['ecue_id'],                   // Ajouter ce champ
        'date': cahier['date']?.split('T').first,       // Ajouter ce champ, prendre seulement la partie date
        'heure_debut': convertTimeToAPIFormat(heureDebutController.text), // Utiliser le nouveau format HH:mm:ss
        'heure_fin': convertTimeToAPIFormat(heureFinController.text),     // Utiliser le nouveau format HH:mm:ss
        'duree': dureeCalculated,
        'libelles': libelleController.text.trim(),
      };
      // --- FIN DES MODIFICATIONS ---

      print('Données envoyées à l\'API: ${json.encode(updateData)}'); // Pour le débogage

      final response = await http.put(
        Uri.parse('http://192.168.181.2:8000/api/gestioncontrat/cahier/update/${cahier['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _showSnackBar('Cahier modifié avec succès', Colors.green);
          Navigator.pop(context, true);
        } else {
          _showSnackBar('Erreur: ${responseData['message'] ?? 'Modification échouée'}', Colors.red);
        }
      } else if (response.statusCode == 422) {
        print('Erreur de validation (422): ${response.body}');
        final errorData = json.decode(response.body);
        String errorMessage = 'Erreur de validation:';
        if (errorData['message'] is Map) { // Vérifier si 'message' est une map (pour Laravel 'errors' structure)
          errorData['message'].forEach((field, messages) {
            errorMessage += '\n- $field: ${messages.join(', ')}';
          });
        } else if (errorData['message'] != null) { // Si 'message' est une simple chaîne
          errorMessage += '\n${errorData['message']}';
        } else {
          errorMessage += '\nRéponse inattendue du serveur.';
        }
        _showSnackBar(errorMessage, Colors.red);
      } else {
        _showSnackBar('Erreur serveur: ${response.statusCode}', Colors.red);
        print('Erreur serveur (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion: $e', Colors.red);
      print('Exception lors de la sauvegarde: $e');
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cahier = widget.cahierData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C2674)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier le cours',
          style: TextStyle(
            color: Color(0xFF1C2674),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B3EFF), Color(0xFF0D147F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.book,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatDisplayDate(cahier?['date']),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatLocalTime(cahier?['heure_debut'])} - ${_formatLocalTime(cahier?['heure_fin'])}',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cahier?['programmation']?['salle'] ?? 'Salle non spécifiée'}   ${cahier?['ecue']?['nom'] ?? 'ECUE non spécifiée'}',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const _CustomLabel(text: 'Enseignant'),
              _CustomField(
                controller: enseignantController,
                enabled: false,
              ),

              const _CustomLabel(text: 'Heure début'),
              _CustomField(
                controller: heureDebutController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir l\'heure de début';
                  }
                  if (!RegExp(r'^\d{1,2}h\d{2}$').hasMatch(value)) {
                    return 'Format attendu: 14h00';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (heureFinController.text.isNotEmpty) {
                    calculateDuration(value, heureFinController.text);
                  }
                },
              ),

              const _CustomLabel(text: 'Heure fin'),
              _CustomField(
                controller: heureFinController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir l\'heure de fin';
                  }
                  if (!RegExp(r'^\d{1,2}h\d{2}$').hasMatch(value)) {
                    return 'Format attendu: 16h00';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (heureDebutController.text.isNotEmpty) {
                    calculateDuration(heureDebutController.text, value);
                  }
                },
              ),

              const _CustomLabel(text: 'Durée'),
              _CustomField(
                controller: tempsController,
                enabled: false,
              ),

              const _CustomLabel(text: 'Libellé'),
              _CustomField(
                controller: libelleController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir un libellé';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D147F),
                        side: const BorderSide(color: Color(0xFF0D147F)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D147F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isSaving
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Enregistrement...', style: TextStyle(color: Colors.white)),
                        ],
                      )
                          : const Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    enseignantController.dispose();
    heureDebutController.dispose();
    heureFinController.dispose();
    tempsController.dispose();
    libelleController.dispose();
    super.dispose();
  }
}

// Widgets personnalisés (inchangés)
class _CustomLabel extends StatelessWidget {
  final String text;
  const _CustomLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _CustomField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _CustomField({
    required this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}