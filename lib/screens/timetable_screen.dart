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
        Uri.parse('http://192.168.181.2:8000/api/gestioncontrat/programmation/by-classe?classe_id=${user.classeId}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Réponse vide du serveur');
        }

        dynamic data;
        try {
          data = json.decode(response.body);
        } catch (e) {
          print('Erreur JSON parsing: $e');
          throw Exception('Erreur de format JSON: ${e.toString()}');
        }

        if (data['data'] is List) {
          final currentDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

          setState(() {
            scheduleData = (data['data'] as List).map((course) {
              DateTime? dateDebut;
              try {
                if (course['date_debut'] != null && course['date_debut'].toString().isNotEmpty) {
                  // Interpréter la date comme UTC, puis la convertir en heure locale de l'appareil
                  dateDebut = DateTime.parse(course['date_debut'].toString()).toLocal();
                }
              } catch (e) {
                print('Erreur parsing date_debut: $e');
                dateDebut = null;
              }

              // --- MODIFICATION START ---
              String ecueName = 'N/A'; // Variable to hold the ECUE name
              try {
                // Check if 'ecue_relation' exists and has a 'nom' field
                if (course['ecue_relation'] != null && course['ecue_relation']['nom'] != null) {
                  ecueName = course['ecue_relation']['nom'].toString();
                } else if (course['code_ecue'] != null) { // Fallback to code_ecue if relation not found
                  ecueName = course['code_ecue'].toString();
                }
              } catch (e) {
                print('Erreur parsing ecueName: $e');
              }
              // --- MODIFICATION END ---

              String enseignant = 'N/A';
              try {
                if (course['user'] != null &&
                    course['user']['prenom'] != null &&
                    course['user']['nom'] != null) {
                  enseignant = '${course['user']['prenom']} ${course['user']['nom']}';
                }
              } catch (e) {
                print('Erreur parsing enseignant: $e');
              }

              String plageDebut = '';
              String plageFin = '';
              try {
                if (course['plage_debut'] != null && course['plage_debut'].toString().isNotEmpty) {
                  // Le serveur envoie 'YYYY-MM-DDTHH:mm:ss', ce qui est un format ISO 8601.
                  // DateTime.parse() gère ce format. Nous devons spécifier qu'il s'agit d'UTC
                  // si le serveur envoie l'heure de cette manière, puis la convertir en local.
                  final dateTimeDebut = DateTime.parse(course['plage_debut'].toString()).toLocal();
                  plageDebut = DateFormat('HH:mm').format(dateTimeDebut);
                }
              } catch (e) {
                print('Erreur parsing plage_debut: $e');
                plageDebut = ''; // Assurez-vous qu'elle est vide en cas d'erreur
              }

              try {
                if (course['plage_fin'] != null && course['plage_fin'].toString().isNotEmpty) {
                  // Idem pour la plage de fin
                  final dateTimeFin = DateTime.parse(course['plage_fin'].toString()).toLocal();
                  plageFin = DateFormat('HH:mm').format(dateTimeFin);
                }
              } catch (e) {
                print('Erreur parsing plage_fin: $e');
                plageFin = ''; // Assurez-vous qu'elle est vide en cas d'erreur
              }

              String salle = 'N/A';
              try {
                if (course['salle'] != null) {
                  salle = course['salle'].toString();
                }
              } catch (e) {
                print('Erreur parsing salle: $e');
              }

              int classeId = 0;
              try {
                if (course['classe_id'] != null) {
                  if (course['classe_id'] is int) {
                    classeId = course['classe_id'];
                  } else {
                    classeId = int.tryParse(course['classe_id'].toString()) ?? 0;
                  }
                }
              } catch (e) {
                print('Erreur parsing classe_id: $e');
              }

              return {
                'matiere': ecueName, // Assign the extracted ECUE name here
                'plage_debut': plageDebut,
                'plage_fin': plageFin,
                'salle': salle,
                'enseignant': enseignant,
                'classe_id': classeId,
                'date_debut': dateDebut != null ? DateFormat('yyyy-MM-dd').format(dateDebut) : '',
              };
            }).where((course) {
              return course['classe_id'] == user.classeId &&
                  course['date_debut'] == currentDateStr;
            }).toList();

            scheduleData.sort((a, b) {
              String timeA = a['plage_debut'] ?? '';
              String timeB = b['plage_debut'] ?? '';
              return timeA.compareTo(timeB);
            });

            isLoading = false;
          });
        } else {
          throw Exception('Format de données incorrect - data n\'est pas une liste');
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays.map((day) {
          bool isSelected = day['date'].day == selectedDate.day &&
              day['date'].month == selectedDate.month &&
              day['date'].year == selectedDate.year;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = day['date'];
                });
                fetchSchedule();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0D147F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF0D147F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day['day'],
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day['dayNumber'].toString(),
                      style: TextStyle(
                        fontFamily: 'Cabin',
                        fontSize: 16,
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Color> get courseColors => [
    const Color(0xFF0D147F),
    const Color(0xFF059669),
    const Color(0xFFDC2626),
    const Color(0xFF7C3AED),
    const Color(0xFFEA580C),
    const Color(0xFF0891B2),
    const Color(0xFFBE185D),
    const Color(0xFF65A30D),
  ];

  Widget _buildCourseCard(
      String subject, // This will now be the ECUE name
      String startTime,
      String endTime,
      String room,
      String teacher,
      Color accentColor,
      int index,
      ) {
    final isToday = selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isCurrentCourse = isToday && startTime.isNotEmpty && endTime.isNotEmpty &&
        currentTime.compareTo(startTime) >= 0 && currentTime.compareTo(endTime) <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentCourse ? accentColor : accentColor.withOpacity(0.15),
          width: isCurrentCourse ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isCurrentCourse ? 0.15 : 0.08),
            blurRadius: isCurrentCourse ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isCurrentCourse)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        subject, // This will now display the ECUE name
                        style: TextStyle(
                          fontFamily: 'Cabin',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            startTime.isNotEmpty && endTime.isNotEmpty
                                ? '$startTime - $endTime'
                                : 'Horaires non définis',
                            style: TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 14,
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Salle $room',
                              style: const TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              teacher,
                              style: const TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate() {
    if (!isLocaleInitialized) return '';
    try {
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate);
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA),
              Color(0xFFE6E6FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF4C51BF).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1A202C),
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 48),
                            child: const Text(
                              'Emploi du temps',
                              style: TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                                letterSpacing: -0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: RefreshIndicator(
                    onRefresh: fetchSchedule,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildDaySelector(),
                              if (isLocaleInitialized) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatSelectedDate(),
                                    style: const TextStyle(
                                      fontFamily: 'Cabin',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                            ),
                          )
                              : error != null
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: fetchSchedule,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D147F),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Réessayer',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : scheduleData.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun cours prévu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Profitez de votre journée libre !',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: scheduleData.length,
                            itemBuilder: (context, index) {
                              final course = scheduleData[index];
                              final colorIndex = index % courseColors.length;
                              return _buildCourseCard(
                                course['matiere'], // This now correctly passes the ECUE name
                                course['plage_debut'],
                                course['plage_fin'],
                                course['salle'],
                                course['enseignant'],
                                courseColors[colorIndex],
                                index,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}