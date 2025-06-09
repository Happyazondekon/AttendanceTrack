


import 'package:flutter/material.dart';
import 'package:eneam/screens/formulaire_add_screen.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
  {
    'title': 'Intelligence Artificielle',
    'semester': 'Semestre 5',

    'hours': '24h sur 30h',
    'period': 'Du 14/03/2025 au 24/04/2025',
  },
  {
    'title': 'Recherche Opérationnelle',
    'semester': 'Semestre 5',
    'hours': '15h sur 30h',
    'period': 'Du 18/03/2025 au 20/04/2025',
  },


  {
    'title': 'Bases de données',
    'semester': 'Semestre 5',
    'hours': '12h sur 40h',
    'period': 'Du 20/03/2025 au 28/04/2025',
  },
  {
    'title': 'Maths-Info',
    'semester': 'Semestre 5',
    'hours': '16h sur 30h',
    'period': 'Du 10/03/2025 au 10/04/2025',
  },
  {
    'title': 'Comptabilité financière',
    'semester': 'Semestre 6',
    'hours': '06h sur 40h',
    'period': 'Du 01/04/2025 au 15/05/2025',
  },
  {
    'title': 'Développement mobile',
    'semester': 'Semestre 6',
    'hours': '12h sur 30h',
    'period': 'Du 05/04/2025 au 25/05/2025',
  },
];

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
          'Choisir une matière',
          style: TextStyle(
            color: Color(0xFF1C2674),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pour continuer veuillez selectionné la matière concernée.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = subjects[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1F84),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Text(
                                    item['semester']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['hours']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                item['period']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),

                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormulaireAddScreen(matiere: "Développement mobile"),
                              ),
                            );
                          },
                          child: Container(
                            width: 33,
                            height: 33,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB3DEFF),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/oblique.png',
                              color: Color(0xFF0F1F84),
                             ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 













