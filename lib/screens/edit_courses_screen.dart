import 'package:flutter/material.dart';

class EditCourseScreen extends StatelessWidget {
  const EditCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Modifiez le cours',
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
                  Image.asset(
                    'assets/send.png', 
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mardi 23 avril 2024',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '14h00 - 16h00',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Salle A5   Intelligence Artificielle',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🧑‍🏫 Enseignant
            const _CustomLabel(text: 'Enseignant'),
            const _CustomField(initialValue: 'Mr Dupont'),

            const _CustomLabel(text: 'Heure début'),
            const _CustomField(initialValue: '14h00'),

            const _CustomLabel(text: 'Heure fin'),
            const _CustomField(initialValue: '16h00'),

            const _CustomLabel(text: 'Temps'),
            const _CustomField(initialValue: '2h'),

            const _CustomLabel(text: 'Libellé'),
            const _CustomField(
              initialValue: 'Algorithmes d’application, mise en œuvre de cas réels',
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            // 🔘 Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: () {
                      // Sauvegarder les modifications
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D147F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Enregistrez',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// 🔹 Widgets personnalisés pour propre design
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
  final String initialValue;
  final int maxLines;
  const _CustomField({required this.initialValue, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
