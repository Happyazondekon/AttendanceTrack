import 'package:flutter/material.dart';
import 'package:eneam/screens/edit_courses_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Variables pour gérer l'état de l'API
  List<Map<String, dynamic>> cahiers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCahiers();
  }

  // Fonction pour récupérer les cahiers depuis l'API
  Future<void> fetchCahiers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('http://192.168.181.2:8000/api/gestioncontrat/cahier/show'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data.containsKey('data')) {
          setState(() {
            cahiers = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Format de réponse inattendu';
            isLoading = false;
          });
        }

        // Mettre à jour les filtres basés sur les matières récupérées
        updateFilters();
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: $e';
        isLoading = false;
      });
    }
  }

  // Mettre à jour les filtres basés sur les données récupérées
  void updateFilters() {
    Set<String> matieres = {"Tous"};
    for (var cahier in cahiers) {
      if (cahier['ecue'] != null && cahier['ecue']['nom'] != null) {
        String matiere = cahier['ecue']['nom'];
        if (matiere.isNotEmpty) {
          matieres.add(matiere);
        }
      }
    }

    setState(() {
      filters.clear();
      filters.addAll(matieres.toList());
    });
  }

  // Fonction pour formater la date en utilisant toLocal()
  // et en parsant directement la chaîne ISO 8601 UTC.
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Date non disponible";
    try {
      DateTime dateTime = DateTime.parse(dateTimeString); // Parses as UTC due to 'Z'
      dateTime = dateTime.toLocal(); // Convert to local timezone
      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";
    } catch (e) {
      print("Erreur de formatage de date: $e"); // Good for debugging
      return "Date invalide";
    }
  }

  // Fonction pour formater l'heure en utilisant toLocal()
  // et en parsant directement la chaîne ISO 8601 UTC.
  String formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "";
    try {
      DateTime dateTime = DateTime.parse(dateTimeString); // Parses as UTC due to 'Z'
      dateTime = dateTime.toLocal(); // Convert to local timezone
      return "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print("Erreur de formatage d'heure: $e"); // Good for debugging
      return "";
    }
  }

  // Fonction pour créer la chaîne d'horaire
  String getScheduleString(Map<String, dynamic> cahier) {
    String heureDebut = formatTime(cahier['heure_debut']);
    String heureFin = formatTime(cahier['heure_fin']);
    String salle = cahier['programmation']?['salle'] ?? 'Salle non spécifiée';

    if (heureDebut.isNotEmpty && heureFin.isNotEmpty) {
      return "$heureDebut - $heureFin   $salle";
    }
    return salle;
  }

  // Fonction pour filtrer les cahiers
  List<Map<String, dynamic>> getFilteredCahiers() {
    List<Map<String, dynamic>> filtered = selectedFilter == "Tous"
        ? cahiers
        : cahiers.where((c) {
      String matiere = c['ecue']?['nom'] ?? '';
      return matiere == selectedFilter;
    }).toList();

    // Filtrer par recherche si nécessaire
    if (searchController.text.isNotEmpty) {
      String searchTerm = searchController.text.toLowerCase();
      filtered = filtered.where((c) {
        String matiere = (c['ecue']?['nom'] ?? '').toLowerCase();
        String libelles = (c['libelles'] ?? '').toLowerCase();
        // Use formatDate with the actual 'date' field from the API
        String date = formatDate(c['date']).toLowerCase();
        return matiere.contains(searchTerm) ||
            libelles.contains(searchTerm) ||
            date.contains(searchTerm);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Historique des cours",
            style: TextStyle(
              color: const Color(0xFF0D147F),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )
        ),
        centerTitle: true,
        leading: BackButton(color: const Color(0xFF0D147F)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: const Color(0xFF0D147F)),
            onPressed: fetchCahiers,
          ),
        ],
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
                hintText: "Rechercher...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none
                ),
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

            // 📘 Content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: const Color(0xFF0D147F)),
            const SizedBox(height: 16),
            Text("Chargement des cahiers...", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCahiers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D147F),
                foregroundColor: Colors.white,
              ),
              child: Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    final filteredCahiers = getFilteredCahiers();

    if (filteredCahiers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Aucun cahier trouvé",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredCahiers.length,
      itemBuilder: (context, index) {
        final cahier = filteredCahiers[index];
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
                // Now directly use cahier["date"] because it's already a full ISO 8601 UTC string
                Text(
                    formatDate(cahier["date"]),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D147F)
                    )
                ),
                const SizedBox(height: 4),
                Text(
                  cahier["ecue"]?["nom"] ?? "ECUE non spécifiée",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF0D147F)
                  ),
                ),
                Text(
                  getScheduleString(cahier),
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                    cahier["libelles"] ?? "Libellé non disponible",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13)
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCourseScreen(cahierData: cahier),
                        ),
                      );

                      // Recharger les données si une modification a été effectuée
                      if (result == true) {
                        fetchCahiers();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D147F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Modifier",
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
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}