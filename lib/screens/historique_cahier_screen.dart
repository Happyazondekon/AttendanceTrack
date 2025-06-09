import 'package:flutter/material.dart';
import 'package:eneam/screens/historique_cahier_screen.dart';
import 'package:eneam/screens/edit_courses_screen.dart';

class HistoriqueCahierScreen extends StatefulWidget {
  @override
  _HistoriqueCahierScreenState createState() => _HistoriqueCahierScreenState();
}

class _HistoriqueCahierScreenState extends State<HistoriqueCahierScreen> {
  String selectedFilter = "Tous";
  final List<String> filters = [
    "Tous",
    "Intelligence Artificielle",
    "Bases de données",
    "Anglais des affaires"
  ];

  final TextEditingController searchController = TextEditingController();

  // Simule les données des cours
  final List<Map<String, String>> cours = [
    {
      "date": "23 Avril 2024",
      "jourHeure": "Mardi 14:00 - 16:00",
      "salle": "Salle A5",
      "matiere": "Intelligence Artificielle",
      "desc": "Algorithmes d’application; mise en ..."
    },
    {
      "date": "19 Avril 2024",
      "jourHeure": "Vendredi 14:00 - 16:00",
      "salle": "Salle A5",
      "matiere": "Bases de données",
      "desc": "Algorithmes d’application; mise en ..."
    },
    {
      "date": "09 Avril 2024",
      "jourHeure": "Mercredi 14:00 - 16:00",
      "salle": "Salle A5",
      "matiere": "Anglais des affaires",
      "desc": "Algorithmes d’application; mise en ..."
    },
    {
      "date": "09 Avril 2024",
      "jourHeure": "Mercredi 14:00 - 16:00",
      "salle": "Salle A5",
      "matiere": "Anglais des affaires",
      "desc": "Algorithmes d’application; mise en ..."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCours = selectedFilter == "Tous"
        ? cours
        : cours.where((c) => c["matiere"] == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: Text("Historique des cours", style: TextStyle(color: const Color(0xFF0D147F), fontWeight: FontWeight.bold,
            fontSize: 20,)), 
        centerTitle: true,

        leading: BackButton(color: const Color(0xFF0D147F)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
            
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // 🧠 Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = filter == selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedFilter = filter),
                      selectedColor: Colors.lightBlue[100],
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[900] : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 📘 ListView des cours
            Expanded(
              child: ListView.builder(
                itemCount: filteredCours.length,
                itemBuilder: (context, index) {
                  final course = filteredCours[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course["date"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0D147F))),
                          const SizedBox(height: 4),
                          Text(
                            "${course["matiere"]}",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(0xFF0D147F)),
                          ),
                          Text(
                            "${course["jourHeure"]}   ${course["salle"]}",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(course["desc"]!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),

                        Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              // 🖊️ Button to edit courses
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditCourseScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D147F), // couleur personnalisée
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "Modifiez",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.edit, size: 16, color: Colors.white),
                                ],
                              ),
                            ),

                            ),
                         
                        ],
                      ),
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

