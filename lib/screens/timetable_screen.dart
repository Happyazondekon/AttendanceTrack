import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  const EmploiDuTempsScreen({Key? key}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<EmploiDuTempsScreen> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  List<Map<String, dynamic>> scheduleData = [];
  String? error;
  bool isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('fr_FR', null);
    setState(() {
      isLocaleInitialized = true;
    });
    fetchSchedule();
  }

  List<Map<String, dynamic>> get weekDays {
    DateTime monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    return List.generate(7, (index) {
      DateTime date = monday.add(Duration(days: index));
      String dayName = '';
      switch (index) {
        case 0:
          dayName = 'Lu';
          break;
        case 1:
          dayName = 'Ma';
          break;
        case 2:
          dayName = 'Mer';
          break;
        case 3:
          dayName = 'Jeu';
          break;
        case 4:
          dayName = 'Ven';
          break;
        case 5:
          dayName = 'Sa';
          break;
        case 6:
          dayName = 'Di';
          break;
      }
      return {
        'day': dayName,
        'date': date,
        'dayNumber': date.day,
      };
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> fetchSchedule() async {
    if (!isLocaleInitialized) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userManager = UserManager();
      final user = userManager.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/gestioncontrat/programmation/show'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] is List) {
          final currentDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

          setState(() {
            scheduleData = (data['data'] as List).map((course) {
              // Conversion des dates UTC
              DateTime? dateDebut;
              try {
                dateDebut = DateTime.parse(course['date_debut']);
              } catch (e) {
                print('Erreur parsing date: $e');
              }

              String matiere = course['ue'] != null ?
              course['ue']['nom']?.toString() ?? 'N/A' :
              course['code_ue']?.toString() ?? 'N/A';

              String enseignant = course['user'] != null ?
              '${course['user']['prenom']} ${course['user']['nom']}' :
              'N/A';

              // Formatage des heures
              String plageDebut = '';
              String plageFin = '';
              try {
                if (course['plage_debut'] != null) {
                  final dateTimeDebut = DateTime.parse(course['plage_debut']);
                  plageDebut = DateFormat('HH:mm').format(dateTimeDebut);
                }
                if (course['plage_fin'] != null) {
                  final dateTimeFin = DateTime.parse(course['plage_fin']);
                  plageFin = DateFormat('HH:mm').format(dateTimeFin);
                }
              } catch (e) {
                print('Erreur parsing heure: $e');
              }

              return {
                'matiere': matiere,
                'plage_debut': plageDebut,
                'plage_fin': plageFin,
                'salle': course['salle']?.toString() ?? 'N/A',
                'enseignant': enseignant,
                'classe_id': course['classe_id'] is int
                    ? course['classe_id']
                    : int.tryParse(course['classe_id']?.toString() ?? '0') ?? 0,
                'date_debut': dateDebut != null ? DateFormat('yyyy-MM-dd').format(dateDebut) : '',
              };
            }).where((course) {
              // Filtrer par classe et date
              return course['classe_id'] == user.classeId &&
                  course['date_debut'] == currentDateStr;
            }).toList();

            // Tri par heure de début
            scheduleData.sort((a, b) =>
                (a['plage_debut'] ?? '').compareTo(b['plage_debut'] ?? ''));

            isLoading = false;
          });
        } else {
          throw Exception('Format de données incorrect');
        }
      } else {
        throw Exception('Échec du chargement de l\'emploi du temps: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Erreur: ${e.toString()}';
        isLoading = false;
      });
      print('Erreur détaillée: $e');
    }
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((day) {
          bool isSelected = day['date'].day == selectedDate.day &&
              day['date'].month == selectedDate.month &&
              day['date'].year == selectedDate.year;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = day['date'];
              });
              fetchSchedule();
            },
            child: Column(
              children: [
                Text(
                  day['day'],
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 13,
                    color: isSelected ? Color(0xFF4338CA) : Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF4338CA) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      day['dayNumber'].toString(),
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 15,
                        color: isSelected ? Colors.white : Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseCard(
      String subject,
      String startTime,
      String endTime,
      String room,
      String teacher,
      Color accentColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    fontFamily: 'Cabin',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$startTime à $endTime',
            style: const TextStyle(
              fontFamily: 'Cabin',
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salle $room - Prof. $teacher',
            style: const TextStyle(
              fontFamily: 'Cabin',
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    if (!isLocaleInitialized) return '';
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA),
              Color(0xFF0D147F),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                          'Emploi du temps',
                          style: TextStyle(
                            fontFamily: 'Cabin',
                            fontSize: 26,
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
                SizedBox(height: 30),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: RefreshIndicator(
                      onRefresh: fetchSchedule,
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildDaySelector(),
                            SizedBox(height: 24),
                            if (isLocaleInitialized) Text(
                              _formatSelectedDate(),
                              style: TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                            SizedBox(height: 24),
                            Expanded(
                              child: isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : error != null
                                  ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      error!,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: fetchSchedule,
                                      child: Text('Réessayer'),
                                    ),
                                  ],
                                ),
                              )
                                  : scheduleData.isEmpty
                                  ? Center(
                                child: Text(
                                  'Aucun cours prévu pour ce jour',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                itemCount: scheduleData.length,
                                itemBuilder: (context, index) {
                                  final course = scheduleData[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: _buildCourseCard(
                                      course['matiere'],
                                      course['plage_debut'],
                                      course['plage_fin'],
                                      course['salle'],
                                      course['enseignant'],
                                      Color(0xFF4C51BF),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}