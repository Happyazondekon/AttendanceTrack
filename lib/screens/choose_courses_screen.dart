import 'package:flutter/material.dart';
import 'package:eneam/screens/formulaire_add_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_manager.dart';
import 'package:intl/intl.dart';


class ChooseScreen extends StatefulWidget {
  const ChooseScreen({super.key});

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProgrammations();
  }

  Future<void> _loadProgrammations() async {
    try {
      final userManager = UserManager();
      final user = userManager.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await http.get(
        Uri.parse('http://192.168.91.2:8000/api/gestioncontrat/programmation/by-classe?classe_id=${user.classeId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            subjects = (data['data'] as List).map((prog) {
              // Formatage des dates
              String dateDebut = '';
              String dateFin = '';
              if (prog['date_debut'] != null) {
                final debut = DateTime.parse(prog['date_debut']).toLocal(); // ← conversion au fuseau local
                dateDebut = DateFormat('dd/MM/yyyy').format(debut);
              }

              if (prog['date_fin'] != null) {
                final fin = DateTime.parse(prog['date_fin']).toLocal(); // ← conversion au fuseau local
                dateFin = DateFormat('dd/MM/yyyy').format(fin);
              }


              return {
                'title': prog['ue']?['nom'] ?? 'Sans titre', // Utilisation du nom de l'UE
                'semester': 'Semestre ${prog['semestre']?.toString() ?? '?'}',
                'hours': '${prog['heure_execute']?.toString() ?? '0'}h sur ${prog['heure_theorique']?.toString() ?? '0'}h',
                'period': 'Du $dateDebut au $dateFin',
                'id': prog['id']?.toString() ?? '',
                'code_ue': prog['code_ue']?.toString() ?? '',
                'salle': prog['salle']?.toString() ?? 'Non définie'
              };
            }).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Erreur lors de la récupération des programmations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

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
          'Choisir une programmation',
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
              'Pour continuer veuillez selectionné la programmation concernée.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C2674)),
              ))
                  : error != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Erreur: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProgrammations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C2674),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
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
                                builder: (_) => FormulaireAddScreen(
                                  matiere: item['title']!,
                                  programmationId: item['id']!,
                                ),
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
                              color: const Color(0xFF0F1F84),
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