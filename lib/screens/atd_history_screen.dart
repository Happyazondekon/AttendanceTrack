import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_manager.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  List<Map<String, dynamic>> attendanceData = [];
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
    fetchAttendance();
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

  Future<void> fetchAttendance() async {
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
        Uri.parse('http://10.0.2.2:8000/api/suivi-presence/presences/etudiant/${user.id}'),
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
            attendanceData = (data['data'] as List).map((attendance) {
              // Conversion de la date de présence
              DateTime? datePresence;
              try {
                datePresence = DateTime.parse(attendance['date_presence']);
              } catch (e) {
                print('Erreur parsing date: $e');
              }

              // Récupération des informations du cours et de l'UE

              // On lit directement l'objet ue attaché à la présence
              final ue = attendance['ue'];

              return {
                'id': attendance['id'],
                'date_presence': datePresence != null
                    ? DateFormat('yyyy-MM-dd').format(datePresence)
                    : '',
                'heure': datePresence != null
                    ? DateFormat('HH:mm').format(datePresence)
                    : 'N/A',
                'status': attendance['status'] ?? 'N/A',
                'present': attendance['status'] == 'present',
                'matiere': ue?['nom'] ?? 'Matière non définie',
                'code_ue': ue?['code'] ?? 'N/A',
                'valide': attendance['valide'] == 1,
              };


            }).where((attendance) {
              return attendance['date_presence'] == currentDateStr;
            }).toList();

            // Tri par heure
            attendanceData.sort((a, b) =>
                (a['heure'] ?? '').compareTo(b['heure'] ?? ''));

            isLoading = false;
          });
        } else {
          throw Exception('Format de données incorrect');
        }
      } else {
        throw Exception('Échec du chargement des présences: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Erreur: ${e.toString()}';
        isLoading = false;
      });
      print('Erreur détaillée: $e');
    }
  }

  Widget _buildCourseCard(
      String matiere,
      String codeUe,
      String time,
      String status,
      bool isPresent,
      bool isValidated,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      matiere,
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      codeUe,
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: isPresent ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heure : $time',
                style: const TextStyle(
                  fontFamily: 'Cabin',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isValidated)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Validé',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                          'Historique de Présences',
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
                      onRefresh: fetchAttendance,
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: weekDays.map((day) {
                                  bool isSelected =
                                      day['date'].day == selectedDate.day &&
                                          day['date'].month == selectedDate.month &&
                                          day['date'].year == selectedDate.year;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDate = day['date'];
                                      });
                                      fetchAttendance();
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
                            ),
                            SizedBox(height: 24),
                            if (isLocaleInitialized) Text(
                              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
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
                                      onPressed: fetchAttendance,
                                      child: Text('Réessayer'),
                                    ),
                                  ],
                                ),
                              )
                                  : attendanceData.isEmpty
                                  ? Center(
                                child: Text(
                                  'Aucun cours ce jour',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                itemCount: attendanceData.length,
                                itemBuilder: (context, index) {
                                  final attendance = attendanceData[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: _buildCourseCard(
                                      attendance['matiere'],
                                      attendance['code_ue'],
                                      attendance['heure'],
                                      attendance['status'],
                                      attendance['present'],
                                      attendance['valide'],
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