import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/user_manager.dart';

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
  bool _isLoading = false;
  bool _isLoadingProgrammation = true;
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
        Uri.parse('http://192.168.91.2:8000/api/gestioncontrat/programmation/${widget.programmationId}'),
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
        throw Exception('Erreur lors de la récupération des détails');
      }
    } catch (e) {
      setState(() {
        _isLoadingProgrammation = false;

      });
      _showError('Erreur lors du chargement des détails: ${e.toString()}');
    }
  }

  void _calculerTemps() {
    if (selectedHeureDebut != null && selectedHeureFin != null) {
      final debut = Duration(hours: selectedHeureDebut!.hour, minutes: selectedHeureDebut!.minute);
      final fin = Duration(hours: selectedHeureFin!.hour, minutes: selectedHeureFin!.minute);
      final difference = fin - debut;

      if (difference.inMinutes >= 0) {
        final heures = difference.inHours;
        final minutes = difference.inMinutes.remainder(60);
        final texte = "${heures > 0 ? '$heures h ' : ''}${minutes > 0 ? '$minutes min' : ''}".trim();
        setState(() {
          _tempsController.text = texte.isEmpty ? "0 h" : texte;
        });
      } else {
        setState(() {
          _tempsController.text = "Heure invalide";
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      initialTime: TimeOfDay.now(),
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Date et heure actuelles au format UTC
      final now = DateTime.now().toUtc();
      final currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Format pour la date sélectionnée
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      // Format pour les heures
      final heureDebut = '${selectedHeureDebut!.hour.toString().padLeft(2, '0')}:${selectedHeureDebut!.minute.toString().padLeft(2, '0')}:00';
      final heureFin = '${selectedHeureFin!.hour.toString().padLeft(2, '0')}:${selectedHeureFin!.minute.toString().padLeft(2, '0')}:00';

      // Calcul de la durée en minutes
      int dureeMinutes = 0;
      if (_tempsController.text.contains('h')) {
        final parts = _tempsController.text.split('h');
        dureeMinutes = int.parse(parts[0].trim()) * 60;
        if (parts.length > 1 && parts[1].contains('min')) {
          dureeMinutes += int.parse(parts[1].replaceAll('min', '').trim());
        }
      }

      final response = await http.post(
        Uri.parse('http://192.168.91.2:8000/api/gestioncontrat/cahier/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'programmation_id': int.parse(widget.programmationId),
          'ecue_id': _programmationDetails?['ecue'] ?? 1,
          'date': formattedDate,
          'heure_debut': heureDebut,
          'heure_fin': heureFin,
          'duree': dureeMinutes,
          'libelles': _libelleController.text,
          'created_at': currentDateTime,
          'updated_at': currentDateTime
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Erreur lors de la création du cahier');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
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
    if (_tempsController.text == "Heure invalide") {
      _showError('Les heures saisies sont invalides');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                child: Text(
                  widget.matiere,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
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