import 'package:flutter/material.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  const EmploiDuTempsScreen({Key? key}) : super(key: key);

  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<EmploiDuTempsScreen> {
  int selectedDay = 26; // Jour sélectionné par défaut (Mer)

  final List<Map<String, dynamic>> weekDays = [
    {'day': 'Lu', 'date': 20},
    {'day': 'Ma', 'date': 21},
    {'day': 'Mer', 'date': 22},
    {'day': 'Jeu', 'date': 23},
    {'day': 'Ven', 'date': 24},
    {'day': 'Sa', 'date': 25},
    {'day': 'Di', 'date': 26},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA), // Lavande clair
              Color(0xFF0D147F), // Bleu profond
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
                      onTap: () {
                        Navigator.pop(context);
                      },
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
                        // Compense la largeur du bouton retour
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

                // Carte principale
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
                            child: Column(
                              children: [
                                // Calendrier hebdomadaire
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children:
                                      weekDays.map((day) {
                                        bool isSelected =
                                            day['date'] == selectedDay;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedDay = day['date'];
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Text(
                                                day['day'],
                                                style: TextStyle(
                                                  fontFamily: 'Cabin',
                                                  fontSize: 13,
                                                  color:
                                                      isSelected
                                                          ? Color(0xFF4338CA)
                                                          : Color(0xFF9CA3AF),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color:
                                                      isSelected
                                                          ? Color(0xFF4338CA)
                                                          : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    day['date'].toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'Cabin',
                                                      fontSize: 15,
                                                      color:
                                                          isSelected
                                                              ? Colors.white
                                                              : Color(
                                                                0xFF374151,
                                                              ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Cours Mathématiques
                          _buildCourseCard(
                            'Mathématiques',
                            '08:00 à 13:00',
                            'D6',
                            'Koffi',
                            Color(0xFF4C51BF),
                          ),

                          SizedBox(height: 20),

                          // Cours Informatique
                          _buildCourseCard(
                            'Informatique',
                            '08:00 à 13:00',
                            'R1',
                            'Maurice',
                            Color(0xFF4C51BF),
                          ),

                          SizedBox(height: 20),

                          // Cours Economie
                          _buildCourseCard(
                            'Economie',
                            '16:00 à 19:00',
                            'A1',
                            'Romuald',
                            Color(0xFF4C51BF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    String subject,
    String time,
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
              Text(
                subject,
                style: TextStyle(
                  fontFamily: 'Cabin',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$time $room $teacher',
            style: const TextStyle(
              fontFamily: 'Cabin',
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
