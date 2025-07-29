import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart'; // Ensure this path is correct
import '../services/user_manager.dart'; // Ensure this path is correct

class FormulaireAddScreen extends StatefulWidget {
  final String matiere;
  final String programmationId;

  const FormulaireAddScreen({
    Key? key,
    required this.matiere,
    required this.programmationId
  }) : super(key: key);

  @override
  _FormulaireAddScreenState createState() => _FormulaireAddScreenState();
}

class _FormulaireAddScreenState extends State<FormulaireAddScreen> {
  final _dateController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  final _tempsController = TextEditingController();
  final _libelleController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedHeureDebut;
  TimeOfDay? selectedHeureFin;
  bool _isLoading = false; // For form submission
  bool _isLoadingProgrammation = true; // For initial programmation details fetch
  Map<String, dynamic>? _programmationDetails;

  @override
  void initState() {
    super.initState();
    _loadProgrammationDetails();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _tempsController.dispose();
    _libelleController.dispose();
    super.dispose();
  }

  Future<void> _loadProgrammationDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.181.2:8000/api/gestioncontrat/programmation/${widget.programmationId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _programmationDetails = data['data'];
          _isLoadingProgrammation = false;
        });
      } else {
        // Log the error response body for debugging
        print('Error loading programmation details: ${response.statusCode} - ${response.body}');
        throw Exception('Erreur lors de la récupération des détails: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingProgrammation = false;
        _programmationDetails = null; // Ensure it's null on error
      });
      _showError('Erreur lors du chargement des détails: ${e.toString()}');
      print('Exception during programmation details loading: $e'); // Log the exception
    }
  }

  void _calculerTemps() {
    if (selectedHeureDebut != null && selectedHeureFin != null) {
      final debut = Duration(hours: selectedHeureDebut!.hour, minutes: selectedHeureDebut!.minute);
      final fin = Duration(hours: selectedHeureFin!.hour, minutes: selectedHeureFin!.minute);

      Duration difference = fin - debut;

      // Handle cases where end time is on the next day (e.g., 23:00 to 01:00)
      if (difference.isNegative) {
        difference = difference + const Duration(days: 1);
      }

      final heures = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      String texte;
      if (heures == 0 && minutes == 0) {
        texte = "0 min"; // Or "0 h 0 min" if preferred
      } else if (heures > 0 && minutes > 0) {
        texte = "$heures h $minutes min";
      } else if (heures > 0) {
        texte = "$heures h";
      } else { // minutes > 0
        texte = "$minutes min";
      }

      setState(() {
        _tempsController.text = texte;
      });
    } else {
      setState(() {
        _tempsController.text = "Heure invalide";
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D147F), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D147F), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedHeureDebut ?? TimeOfDay.now(), // Use existing time or now
      helpText: 'Sélectionner une heure',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D147F), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D147F), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formatted = picked.format(context);
        controller.text = formatted;

        if (isStart) {
          selectedHeureDebut = picked;
        } else {
          selectedHeureFin = picked;
        }

        _calculerTemps();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    // Check if programmation details are loaded
    if (_programmationDetails == null) {
      _showError('Détails de la programmation non chargés. Veuillez réessayer.');
      return;
    }

    // Get ecue_id from the nested ecue_relation object
    final int? ecueId = _programmationDetails?['ecue_relation']?['id'];
    if (ecueId == null) {
      _showError('Impossible de récupérer l\'ID ECUE. Données de programmation incomplètes ou ECUE non défini.');
      print('Debug: _programmationDetails: $_programmationDetails'); // Added for debugging
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Date et heure actuelles au format UTC pour created_at/updated_at
      final now = DateTime.now().toUtc();
      final currentDateTimeUtc = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Date sélectionnée au format YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      // Heures au format HH:mm:ss (comme l'API l'a demandé)
      final heureDebut = '${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}:00';
      final heureFin = '${selectedHeureFin!.hour.toString().padLeft(2, '0')}:${selectedHeureFin!.minute.toString().padLeft(2, '0')}:00';

      // Calcul de la durée en minutes (assurez-vous que _calculerTemps a déjà mis à jour _tempsController.text)
      int dureeMinutes = 0;
      final tempsText = _tempsController.text;
      if (tempsText.contains('h')) {
        final parts = tempsText.split('h');
        dureeMinutes = int.parse(parts[0].trim()) * 60;
        if (parts.length > 1 && parts[1].contains('min')) {
          dureeMinutes += int.parse(parts[1].replaceAll('min', '').trim());
        }
      } else if (tempsText.contains('min')) {
        dureeMinutes = int.parse(tempsText.replaceAll('min', '').trim());
      }


      final response = await http.post(
        Uri.parse('http://192.168.181.2:8000/api/gestioncontrat/cahier/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'programmation_id': int.parse(widget.programmationId),
          'ecue_id': ecueId, // Now correctly using the direct 'ecue' ID
          'date': formattedDate,
          'heure_debut': heureDebut,
          'heure_fin': heureFin,
          'duree': dureeMinutes,
          'libelles': _libelleController.text,
          'created_at': currentDateTimeUtc, // Send as UTC
          'updated_at': currentDateTimeUtc  // Send as UTC
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Cahier créé avec succès', Colors.green); // Success message
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final data = json.decode(response.body);
        // Log the full error response from the server
        print('API Error Response: ${response.body}');
        // Display specific error messages from the server if available
        if (data['message'] is Map) {
          String validationErrors = '';
          data['message'].forEach((field, messages) {
            validationErrors += '\n- ${field}: ${messages.join(', ')}';
          });
          _showError('Erreur de validation: $validationErrors');
        } else {
          _showError(data['message'] ?? 'Erreur lors de la création du cahier');
        }
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
      print('Exception during form submission: $e'); // Log the exception
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (selectedDate == null) {
      _showError('Veuillez sélectionner une date');
      return false;
    }
    if (selectedHeureDebut == null || selectedHeureFin == null) {
      _showError('Veuillez sélectionner les heures de début et de fin');
      return false;
    }
    if (_libelleController.text.isEmpty) {
      _showError('Veuillez saisir un libellé');
      return false;
    }
    if (_tempsController.text == "Heure invalide" || _tempsController.text.isEmpty || _tempsController.text == "0 min") {
      _showError('Veuillez saisir des heures valides pour calculer la durée.');
      return false;
    }
    return true;
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

  void _showError(String message) {
    _showSnackBar(message, Colors.red);
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTempsAuto() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _tempsController,
        enabled: false,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, bool isStart) {
    return GestureDetector(
      onTap: () => _selectTime(controller, isStart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.access_time),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibelleInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: TextField(
        controller: _libelleController,
        maxLines: 4,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'Décrivez le contenu du cours...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if programmation details are still being fetched
    if (_isLoadingProgrammation) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D147F)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF0D147F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0D147F)),
        ),
      );
    }

    // Show error if programmation details failed to load
    if (_programmationDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D147F)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF0D147F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Impossible de charger les détails de la programmation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProgrammationDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D147F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    // Safely get UE name and ECUE name
    final ueName = _programmationDetails?['ue']?['nom'] ?? 'Nom UE Inconnu';
    final ecueName = _programmationDetails?['ecue_relation']?['nom'] ?? 'Nom ECUE Inconnu';

    // Main content once data is loaded
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D147F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Remplir le formulaire',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF0D147F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      ueName, // Display UE name
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4), // Small spacing between UE and ECUE
                    Text(
                      ecueName, // Display ECUE name
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("Date"),
              _buildDateInput(),

              _buildLabel("Heure début"),
              _buildTimeInput(_heureDebutController, true),

              _buildLabel("Heure fin"),
              _buildTimeInput(_heureFinController, false),

              _buildLabel("Durée"),
              _buildTempsAuto(),

              _buildLabel("Libellé du cours"),
              _buildLibelleInput(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D147F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Enregistrez les informations",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}