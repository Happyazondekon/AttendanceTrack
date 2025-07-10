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

              // Récupération des informations de l'ECUE
              final ecue = attendance['ecue'];

              return {
                'id': attendance['id'],
                'date_presence': datePresence != null
                    ? DateFormat('yyyy-MM-dd').format(datePresence)
                    : '',
                'heure': datePresence != null
                    ? DateFormat('HH:mm').format(datePresence)
                    : 'N/A',
                'status': attendance['status'] ?? 'en attente',
                'present': attendance['status'] == 'present',
                'matiere': ecue?['nom'] ?? 'ECUE non définie',
                'code_ecue': ecue?['code'] ?? 'N/A',
                'valide': attendance['valide'] == 1 || attendance['valide'] == true,
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
                fetchAttendance();
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

  List<Color> get attendanceColors => [
    const Color(0xFF0D147F),
    const Color(0xFF059669),
    const Color(0xFFDC2626),
    const Color(0xFF7C3AED),
    const Color(0xFFEA580C),
    const Color(0xFF0891B2),
    const Color(0xFFBE185D),
    const Color(0xFF65A30D),
  ];

  Widget _buildAttendanceCard(
      String matiere,
      String codeEcue,
      String time,
      String status,
      bool isPresent,
      bool isValidated,
      Color accentColor,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isValidated)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'VALIDÉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            matiere,
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            codeEcue,
                            style: const TextStyle(
                              fontFamily: 'Cabin',
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'en attente'
                            ? Colors.orange.withOpacity(0.1)
                            : isPresent
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'en attente'
                                ? Icons.access_time
                                : isPresent
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: status == 'en attente'
                                ? Colors.orange
                                : isPresent
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: status == 'en attente'
                                  ? Colors.orange
                                  : isPresent
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                            'Heure : $time',
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
                              'Historique de Présences',
                              style: TextStyle(
                                fontFamily: 'Cabin',
                                fontSize: 26,
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
                    onRefresh: fetchAttendance,
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
                                    onPressed: fetchAttendance,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4338CA),
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
                              : attendanceData.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucune présence enregistrée',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucun cours ce jour',
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
                            itemCount: attendanceData.length,
                            itemBuilder: (context, index) {
                              final attendance = attendanceData[index];
                              final colorIndex = index % attendanceColors.length;
                              return _buildAttendanceCard(
                                attendance['matiere'],
                                attendance['code_ecue'],
                                attendance['heure'],
                                attendance['status'],
                                attendance['present'],
                                attendance['valide'],
                                attendanceColors[colorIndex],
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