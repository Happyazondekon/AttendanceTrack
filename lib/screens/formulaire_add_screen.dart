


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormulaireAddScreen extends StatefulWidget {
  final String matiere;

  const FormulaireAddScreen({Key? key, required this.matiere}) : super(key: key);

  @override
  _FormulaireAddScreenState createState() => _FormulaireAddScreenState();
}

class _FormulaireAddScreenState extends State<FormulaireAddScreen> {
  final _dateController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  final _tempsController = TextEditingController();


  DateTime? selectedDate;
  TimeOfDay? selectedHeureDebut;
  TimeOfDay? selectedHeureFin;

  @override
  void dispose() {
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _tempsController.dispose();

    super.dispose();
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
        _tempsController.text = texte.isEmpty ? "0 min" : texte;
      });
    } else {
      // Heure de fin avant heure de début
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

        // ➕ Calcul automatique du temps
        _calculerTemps();
      });
    }
  }


  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
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
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }


  Widget _buildInput({int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
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
            decoration: InputDecoration(
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
      onTap: () => _selectTime(controller, isStart), // 👈 Juste l'appel ici
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.access_time),
            ),
          ),
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
          icon: Icon(Icons.arrow_back, color: const Color(0xFF0D147F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Remplir le formulaire',
          style: TextStyle(
            fontSize: 20,
            color: const Color(0xFF0D147F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.matiere,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            _buildLabel("Enseignant"),
            _buildInput(),

            _buildLabel("Date"),
            _buildDateInput(),

            _buildLabel("Heure début"),
            _buildTimeInput(_heureDebutController, true),

            _buildLabel("Heure fin"),
            _buildTimeInput(_heureFinController, false),

            _buildLabel("Temps"),
            _buildTempsAuto(),

            _buildLabel("Libellé"),
            _buildInput(maxLines: 2),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Traitement du formulaire
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D147F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Enregistrez les informations",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
